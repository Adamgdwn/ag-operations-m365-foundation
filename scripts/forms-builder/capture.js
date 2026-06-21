// Headless capture harness: learn Microsoft Forms' internal formapi by watching
// the real network traffic while a form is created from a template.
//
// SECRET HANDLING: formapi requests carry a bearer token. This script REDACTS
// the Authorization header in all saved output and writes only to the gitignored
// .local/ tree. We capture endpoints, payloads, and response shapes ONLY.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, '.local', 'forms-builder', 'capture'); // gitignored
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const isApi = (u) => /formapi|\/api\/.*forms|light\/forms|DesignerApi|\/responses|\/questions/i.test(u);
const redactHeaders = (h) => { const o = {}; for (const k in h) o[k] = /authoriz|cookie|token/i.test(k) ? `[REDACTED len=${(h[k] || '').length}]` : h[k]; return o; };

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1536, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const calls = [];

  page.on('request', req => {
    const u = req.url();
    if (!isApi(u)) return;
    let body = null;
    try { body = req.postData(); } catch {}
    calls.push({ kind: 'req', method: req.method(), url: u, headers: redactHeaders(req.headers()), body: body ? body.slice(0, 4000) : null, ts: Date.now() });
  });
  page.on('response', async resp => {
    const u = resp.url();
    if (!isApi(u)) return;
    let text = null;
    try { const ct = resp.headers()['content-type'] || ''; if (/json|text/i.test(ct)) text = (await resp.text()).slice(0, 8000); } catch {}
    calls.push({ kind: 'resp', status: resp.status(), method: resp.request().method(), url: u, body: text, ts: Date.now() });
  });

  log('landing ...');
  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(e => log('nav warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(4000);

  // Open template gallery, then pick the first template tile to trigger a create.
  log('opening template gallery ...');
  await page.getByText('Workflow Solution', { exact: false }).first().click({ timeout: 8000 }).catch(e => log('scenario click warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(5000);

  // Click the first template tile in the gallery.
  const tile = page.locator('div[role="list"] div[role="button"], div[role="list"] >> div').first();
  await tile.click({ timeout: 8000 }).catch(e => log('tile click warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(4000);

  // A preview/dialog often appears; click a create/use/edit affordance if present.
  for (const name of [/use template/i, /customize/i, /create/i, /edit/i, /preview/i]) {
    const b = page.getByRole('button', { name }).first();
    if (await b.isVisible({ timeout: 1500 }).catch(() => false)) { await b.click().catch(() => {}); log(`clicked ${name}`); await page.waitForTimeout(5000); break; }
  }
  await page.waitForTimeout(6000);
  log(`final url: ${page.url()}`);
  await page.screenshot({ path: path.join(OUT, 'after-create.png'), fullPage: true }).catch(() => {});

  fs.writeFileSync(path.join(OUT, 'calls.json'), JSON.stringify(calls, null, 2));
  // Readable digest: unique endpoint+method, with first request body and a response sample.
  const seen = new Map();
  for (const c of calls) {
    const key = `${c.method} ${c.url.split('?')[0]}`;
    if (!seen.has(key)) seen.set(key, { key, reqBody: null, respSample: null });
    const e = seen.get(key);
    if (c.kind === 'req' && c.body && !e.reqBody) e.reqBody = c.body;
    if (c.kind === 'resp' && c.body && !e.respSample) e.respSample = c.body.slice(0, 1200);
  }
  const digest = [...seen.values()].map(e => `### ${e.key}\nREQ BODY: ${e.reqBody || '(none)'}\nRESP: ${e.respSample || '(none)'}`).join('\n\n');
  fs.writeFileSync(path.join(OUT, 'digest.txt'), `final url: ${page.url()}\ncalls: ${calls.length}\n\n${digest}`);
  log(`captured ${calls.length} formapi calls -> .local/forms-builder/capture/{calls.json,digest.txt}`);
  await ctx.close();
  log('capture done');
})();
