// Learn the formapi add-question + settings payloads by creating a fresh form
// via API, opening its editor, and capturing the exact POST/PATCH the UI sends.
// All output is non-secret schema; written to gitignored .local/.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, '.local', 'forms-builder', 'capture');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const COLL = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/light/forms`;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1536, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  let hdr = null;
  page.on('request', req => { if (!hdr && /light\/forms/i.test(req.url()) && req.method() === 'GET') hdr = req.headers(); });

  const qcalls = [];
  page.on('request', req => {
    const u = req.url();
    if (/formapi/i.test(u) && (req.method() === 'POST' || req.method() === 'PATCH' || req.method() === 'PUT') && /question|forms\('|settings|getResponseLinks|distributionInfo/i.test(u)) {
      let b = null; try { b = req.postData(); } catch {}
      qcalls.push({ kind: 'req', method: req.method(), url: u, body: b ? b.slice(0, 4000) : null });
    }
  });
  page.on('response', async resp => {
    const u = resp.url();
    if (/formapi/i.test(u) && /question|forms\('|settings|getResponseLinks/i.test(u) && resp.request().method() !== 'GET') {
      let t = null; try { t = (await resp.text()).slice(0, 3000); } catch {}
      qcalls.push({ kind: 'resp', status: resp.status(), method: resp.request().method(), url: u, body: t });
    }
  });

  log('harvesting headers ...');
  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(3500);
  if (!hdr || !hdr['__requestverificationtoken']) { log('no token'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];

  log('creating fresh form via API ...');
  const cr = await page.request.post(COLL, { headers: H, data: JSON.stringify({ title: 'GAIL-API-PROBE2', description: '' }) });
  const form = JSON.parse(await cr.text());
  const id = form.id;
  log(`form id: ${id}`);
  fs.writeFileSync(path.join(OUT, 'probe2-id.txt'), id);

  const editor = `https://forms.office.com/Pages/DesignPageV2.aspx?origin=NeoPortalPage&formid=${encodeURIComponent(id)}`;
  log(`opening editor: ${editor}`);
  await page.goto(editor, { waitUntil: 'networkidle', timeout: 45000 }).catch(e => log('editor nav warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(6000);
  await page.screenshot({ path: path.join(OUT, 'editor-existing.png'), fullPage: true }).catch(() => {});

  // Dump editor controls so we can author selectors.
  const dump = await page.evaluate(() => {
    const sel = 'button, a, [role="button"], [role="menuitem"], [aria-label], [title], [data-automation-id]';
    const out = [];
    document.querySelectorAll(sel).forEach(el => {
      const r = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      const vis = r.width > 1 && r.height > 1 && cs.visibility !== 'hidden' && cs.display !== 'none';
      const t = (el.innerText || el.getAttribute('aria-label') || el.getAttribute('title') || el.getAttribute('data-automation-id') || '').trim().replace(/\s+/g, ' ').slice(0, 70);
      if (t) out.push(`${vis ? 'V' : 'h'} <${el.tagName.toLowerCase()}> ${t}`);
    });
    return [...new Set(out)].slice(0, 300).join('\n');
  }).catch(e => 'dump err ' + e.message);
  fs.writeFileSync(path.join(OUT, 'editor-controls.txt'), `URL: ${page.url()}\n\n${dump}`);

  // Attempt to add a question: click "Add new", then "Text".
  const tryClick = async (rxs) => {
    for (const rx of rxs) {
      const el = page.getByText(rx, { exact: false }).first();
      if (await el.isVisible({ timeout: 1500 }).catch(() => false)) { await el.click().catch(() => {}); return true; }
      const el2 = page.locator(`[aria-label*="${rx.source || rx}" i]`).first();
      if (await el2.isVisible({ timeout: 800 }).catch(() => false)) { await el2.click().catch(() => {}); return true; }
    }
    return false;
  };
  log('clicking Add new ...');
  await tryClick([/add new/i, /add question/i]);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, 'after-addnew.png'), fullPage: true }).catch(() => {});
  log('clicking Text type ...');
  await tryClick([/^text$/i, /\btext\b/i]);
  await page.waitForTimeout(4000);
  await page.screenshot({ path: path.join(OUT, 'after-text.png'), fullPage: true }).catch(() => {});

  fs.writeFileSync(path.join(OUT, 'question-calls.json'), JSON.stringify(qcalls, null, 2));
  log(`captured ${qcalls.length} question/settings calls -> question-calls.json`);
  await ctx.close();
  log('done');
})();
