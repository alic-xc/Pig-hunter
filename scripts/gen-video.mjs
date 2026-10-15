// Generate one image-to-video clip with OpenRouter and log what it cost (adapted from Save D Bunny).
// ONLY run this after the user has approved the job and its estimated cost.
//
//   node scripts/gen-video.mjs <out.mp4> <first-frame.png> --prompt-file <prompt.txt> [--model id] [--duration 5] [--resolution 480p] [--aspect 16:9]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const env = Object.fromEntries(fs.readFileSync(path.join(ROOT, '.env'), 'utf8').split('\n').filter((l) => l.includes('=')).map((l) => l.split(/=(.*)/s).slice(0, 2)));
const KEY = env.OPENROUTER_API_KEY?.trim();
if (!KEY) throw new Error('OPENROUTER_API_KEY missing from .env');

const args = process.argv.slice(2);
const flag = (name, def) => { const i = args.indexOf(name); if (i < 0) return def; const v = args[i + 1]; args.splice(i, 2); return v; };
const model = flag('--model', 'bytedance/seedance-2.0-mini');
const duration = Number(flag('--duration', 5));
const resolution = flag('--resolution', '480p');
const aspect = flag('--aspect', '16:9');
const prompt = fs.readFileSync(flag('--prompt-file'), 'utf8').trim();
const [out, firstFrame] = args;
if (!out || !firstFrame) { console.error('usage: node scripts/gen-video.mjs <out.mp4> <first-frame.png> --prompt-file f.txt'); process.exit(1); }

const headers = { Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json', 'X-Title': 'Pig Hunter' };
const image = `data:image/png;base64,${fs.readFileSync(path.resolve(ROOT, firstFrame)).toString('base64')}`;
const body = {
  model, prompt, duration, resolution, aspect_ratio: aspect, generate_audio: false,
  frame_images: [{ type: 'image_url', image_url: { url: image }, frame_type: 'first_frame' }],
};

const submit = await fetch('https://openrouter.ai/api/v1/videos', { method: 'POST', headers, body: JSON.stringify(body) });
let job = await submit.json();
if (!submit.ok || job.error) { console.error('submit failed:', JSON.stringify(job, null, 2)); process.exit(1); }
console.log('submitted', job.id, job.status);

const started = Date.now();
while (!['completed', 'failed', 'cancelled', 'expired'].includes(job.status)) {
  if (Date.now() - started > 15 * 60 * 1000) { console.error('gave up waiting after 15 minutes; job', job.id); process.exit(1); }
  await new Promise((r) => setTimeout(r, 15000));
  const res = await fetch(`https://openrouter.ai/api/v1/videos/${job.id}`, { headers });
  job = await res.json();
  console.log(`  ${Math.round((Date.now() - started) / 1000)}s: ${job.status}`);
}
if (job.status !== 'completed') { console.error('job ended:', JSON.stringify(job, null, 2)); process.exit(1); }

// download: try the content endpoint first, then the unsigned URL
let video = await fetch(`https://openrouter.ai/api/v1/videos/${job.id}/content?index=0`, { headers });
if (!video.ok && job.unsigned_urls?.[0]) video = await fetch(job.unsigned_urls[0]);
if (!video.ok) { console.error('download failed', video.status); process.exit(1); }
const outPath = path.resolve(ROOT, out);
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, Buffer.from(await video.arrayBuffer()));

const cost = Number(job.usage?.cost ?? 0);
fs.appendFileSync(path.join(ROOT, 'USAGE.md'),
  `| ${new Date().toISOString().slice(0, 16).replace('T', ' ')} | ${model} (video ${duration}s ${resolution}) | ${cost.toFixed(4)} | ${path.relative(ROOT, outPath)} | ${prompt.replace(/\s+/g, ' ').slice(0, 60).replace(/\|/g, '/')}… |\n`);
console.log(JSON.stringify({ saved: path.relative(ROOT, outPath), cost, id: job.id }));
