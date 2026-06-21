// Capture the PATCH fired when selecting "Anyone can respond" in the share panel.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }
const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, '.local', 'forms-builder', 'capture');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const COLL = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/light/forms`;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1536, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  let hdr = null;
  page.on('request', req => { if (!hdr && /light\/forms/i.test(req.url()) && req.method() === 'GET') hdr = req.headers(); });
  const calls = [];
  page.on('request', req => {
    if (req.method() === 'GET' || req.method() === 'OPTIONS') return;
    if (!/forms\.office\.com|office\.com\/formapi|sharepoint/i.test(req.url())) return;
    let b = null; try { b = req.postData(); } catch {}
    calls.push({ method: req.method(), url: req.url().replace(/\?.*$/, ''), body: b ? b.slice(0, 2500) : null });
  });

  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(3500);
  if (!hdr || !hdr['__requestverificationtoken']) { log('no token'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];
  const cr = await page.request.post(COLL, { headers: H, data: JSON.stringify({ title: 'GAIL-API-PROBE4', description: '' }) });
  const id = JSON.parse(await cr.text()).id;
  log(`form id: ${id}`);

  await page.goto(`https://forms.office.com/Pages/DesignPageV2.aspx?origin=NeoPortalPage&formid=${encodeURIComponent(id)}`, { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(6000);

  const click = async (rxs, pause = 2500) => {
    for (const rx of rxs) {
      for (const loc of [page.getByRole('button', { name: rx }).first(), page.getByText(rx, { exact: false }).first(), page.locator(`[aria-label*="${rx.source} i"]`).first()]) {
        if (await loc.isVisible({ timeout: 1000 }).catch(() => false)) { await loc.click().catch(() => {}); await page.waitForTimeout(pause); return true; }
      }
    }
    return false;
  };

  log('open share panel');
  const opened = await click([/collect responses/i, /share/i, /send/i], 3500);
  log('share opened: ' + opened);
  await page.screenshot({ path: path.join(OUT, 'anon-1-panel.png'), fullPage: true }).catch(() => {});

  log('click Anyone can respond radio');
  let clicked = false;
  for (const loc of [page.getByRole('radio', { name: /anyone can respond/i }).first(), page.getByText(/anyone can respond/i).first()]) {
    if (await loc.isVisible({ timeout: 1500 }).catch(() => false)) { await loc.click().catch(() => {}); clicked = true; break; }
  }
  log('anyone clicked: ' + clicked);
  await page.waitForTimeout(3000);
  await page.screenshot({ path: path.join(OUT, 'anon-2-after.png'), fullPage: true }).catch(() => {});

  log('click Copy link to force persistence');
  for (const loc of [page.getByRole('button', { name: /^copy link$/i }).first(), page.getByText(/^copy link$/i).first()]) {
    if (await loc.isVisible({ timeout: 1500 }).catch(() => false)) { await loc.click().catch(() => {}); break; }
  }
  await page.waitForTimeout(3500);
  await page.screenshot({ path: path.join(OUT, 'anon-3-copied.png'), fullPage: true }).catch(() => {});

  // Read back the form settings after the toggle.
  const got = await page.request.get(`${COLL}('${id}')?$select=settings,title,id`, { headers: H });
  let readback = ''; try { readback = await got.text(); } catch {}

  fs.writeFileSync(path.join(OUT, 'anon-calls.json'), JSON.stringify(calls, null, 2));
  fs.writeFileSync(path.join(OUT, 'anon-readback.json'), readback);
  log(`captured ${calls.length} calls`);
  await ctx.close();
  log('done');
})();
