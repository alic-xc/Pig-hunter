// Tiny local helper: the browser pane POSTs a PNG data URL, this writes it into web/art/.
// Only listens on localhost.   node scripts/save-server.mjs
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const ROOT = path.resolve('web/art');
http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); res.setHeader('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') { res.end(); return; }
  const name = new URL(req.url, 'http://x').searchParams.get('name') || '';
  if (req.method !== 'POST' || !/^[\w\-/]+\.png$/.test(name)) { res.statusCode = 400; res.end('bad'); return; }
  let body = ''; req.on('data', c => body += c);
  req.on('end', () => {
    const out = path.join(ROOT, name); if (!out.startsWith(ROOT)) { res.statusCode = 400; res.end('bad'); return; }
    fs.mkdirSync(path.dirname(out), { recursive: true });
    fs.writeFileSync(out, Buffer.from(body.replace(/^data:image\/png;base64,/, ''), 'base64'));
    res.end(JSON.stringify({ saved: name, bytes: fs.statSync(out).size }));
  });
}).listen(5180, '127.0.0.1', () => console.log('save server on 5180'));
