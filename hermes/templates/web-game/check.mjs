// check.mjs — local headless self-check for a zero-build web game.
// Usage: node check.mjs <gamedir> <outdir>
// Serves <gamedir> on localhost, drives headless Chromium, runs
// <gamedir>/check-flow.mjs if present (default export async (page, shot)),
// captures console errors / page errors / failed requests, saves a
// screenshot series + report.json. Exit 0 iff no problems, else 1.
// Hard timeout 60s. NEVER uses any cloud browser service.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { chromium } from 'playwright';

const [gamedir, outdir] = process.argv.slice(2);
if (!gamedir || !outdir) {
  console.error('usage: node check.mjs <gamedir> <outdir>');
  process.exit(1);
}
const root = path.resolve(gamedir);
const out = path.resolve(outdir);
fs.mkdirSync(out, { recursive: true });

const MIME = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.css': 'text/css', '.json': 'application/json', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
};
const server = http.createServer((req, res) => {
  let p;
  try {
    p = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  } catch {
    res.writeHead(400); res.end('bad request'); return;
  }
  if (p === '/') p = '/index.html';
  const f = path.join(root, p);
  if (!f.startsWith(root) || !fs.existsSync(f) || !fs.statSync(f).isFile()) {
    res.writeHead(404); res.end('not found'); return;
  }
  res.writeHead(200, { 'Content-Type': MIME[path.extname(f)] || 'application/octet-stream' });
  fs.createReadStream(f).pipe(res);
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const port = server.address().port;

const report = { consoleErrors: [], pageErrors: [], failedRequests: [], steps: [] };
const timer = setTimeout(() => {
  console.error('check.mjs: hard timeout after 60s');
  process.exit(1);
}, 60000);

let browser;
try {
  try {
    browser = await chromium.launch({ headless: true });
  } catch (e) {
    console.error('check.mjs: failed to launch headless Chromium: ' + e.message);
    process.exit(1);
  }
  const page = await browser.newPage({ viewport: { width: 520, height: 700 } });
  page.on('console', (m) => { if (m.type() === 'error') report.consoleErrors.push(m.text()); });
  page.on('pageerror', (e) => report.pageErrors.push(String(e)));
  page.on('requestfailed', (r) => report.failedRequests.push(r.url() + ' ' + (r.failure()?.errorText || '')));
  const shot = async (name) => {
    await page.screenshot({ path: path.join(out, name + '.png') });
    report.steps.push(name);
  };

  await page.goto(`http://127.0.0.1:${port}/`, { waitUntil: 'load', timeout: 30000 });
  await page.waitForTimeout(800);
  await shot('boot');

  const flow = path.join(root, 'check-flow.mjs');
  if (fs.existsSync(flow)) {
    try {
      const mod = await import(pathToFileURL(flow).href);
      await mod.default(page, shot);
    } catch (e) {
      report.pageErrors.push('flow: ' + String(e));
    }
  }
  await shot('final');
} catch (e) {
  report.pageErrors.push('check: ' + String(e));
} finally {
  if (browser) await browser.close().catch(() => {});
  server.close();
  clearTimeout(timer);
}

fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2));
const bad = report.consoleErrors.length + report.pageErrors.length + report.failedRequests.length;
console.log(`check.mjs: ${report.steps.length} screenshots, ${bad} problems -> ${path.join(out, 'report.json')}`);
process.exit(bad ? 1 : 0);
