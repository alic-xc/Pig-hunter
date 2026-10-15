// Build a green-screen start frame for image-to-video from frame 1 of a run sheet.
// Keeps only the largest connected drawing in the first ~sixth (drops neighbours' tails).
//   node scripts/make-start.mjs <run-sheet.png> <out.png>
import { createRequire } from 'node:module';
const require = createRequire('/Users/aladelekan/Documents/save d bunny/scripts/package.json');
const sharp = require('sharp');
const [src, out] = process.argv.slice(2);
const meta = await sharp(src).metadata();
const cw = Math.min(meta.width, Math.round(meta.width / 6 + 90));
const { data, info } = await sharp(src).extract({ left: 0, top: 0, width: cw, height: meta.height }).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
const W = info.width, H = info.height, lab = new Int32Array(W * H).fill(-1), sizes = [];
for (let s = 0; s < W * H; s++) {
  if (lab[s] !== -1 || data[s * 4 + 3] < 40) continue;
  const id = sizes.length; let n = 0; const st = [s]; lab[s] = id;
  while (st.length) { const i = st.pop(); n++; const x = i % W;
    for (const j of [i - 1, i + 1, i - W, i + W]) if (j >= 0 && j < W * H && lab[j] === -1 && data[j * 4 + 3] >= 40 && Math.abs((j % W) - x) <= 1) { lab[j] = id; st.push(j); } }
  sizes.push(n);
}
const main = sizes.indexOf(Math.max(...sizes));
for (let i = 0; i < W * H; i++) if (lab[i] !== main) data[i * 4 + 3] = 0;
const frame = await sharp(await sharp(data, { raw: { width: W, height: H, channels: 4 } }).png().toBuffer()).trim().png().toBuffer();
const Wv = 854, Hv = 480;
const scaled = await sharp(frame).resize({ height: Math.round(Hv * .62) }).png().toBuffer();
const sm = await sharp(scaled).metadata();
await sharp({ create: { width: Wv, height: Hv, channels: 3, background: { r: 0, g: 255, b: 0 } } })
  .composite([{ input: scaled, left: Math.round((Wv - sm.width) / 2), top: Math.round(Hv * .8 - sm.height) }])
  .png().toFile(out);
console.log(JSON.stringify({ placed: [sm.width, sm.height] }));
