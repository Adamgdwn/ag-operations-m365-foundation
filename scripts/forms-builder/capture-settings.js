// Capture the remaining unknowns: Choice question schema, the "anyone can
// respond" (anonymous) settings PATCH, and the public response link.
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

  const calls = [];
  page.on('request', req => {
    const u = req.url();
    if (/formapi/i.test(u) && req.method() !== 'GET') {
      let b = null; try { b = req.postData(); } catch {}
      calls.push({ kind: 'req', method: req.method(), url: u.replace(/\?.*$/, ''), body: b ? b.slice(0, 3000) : null });
    }
  });
  page.on('response', async resp => {
    const u = resp.url();
    if (/formapi/i.test(u) && resp.request().method() !== 'GET') {
      let t = null; try { t = (await resp.text()).slice(0, 2500); } catch {}
      calls.push({ kind: 'resp', status: resp.status(), method: resp.request().method(), url: u.replace(/\?.*$/, ''), body: t });
    }
    if (/ResponsePage\.aspx|forms\.office\.com\/r\//i.test(u)) calls.push({ kind: 'link', url: u });
  });

  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(3500);
  if (!hdr || !hdr['__requestverificationtoken']) { log('no token'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];

  const cr = await page.request.post(COLL, { headers: H, data: JSON.stringify({ title: 'GAIL-API-PROBE3', description: '' }) });
  const id = JSON.parse(await cr.text()).id;
  log(`form id: ${id}`);
  fs.writeFileSync(path.join(OUT, 'probe3-id.txt'), id);

  await page.goto(`https://forms.office.com/Pages/DesignPageV2.aspx?origin=NeoPortalPage&formid=${encodeURIComponent(id)}`, { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(6000);

  const click = async (rxs, pause = 2500) => {
    for (const rx of rxs) {
      let el = page.getByRole('button', { name: rx }).first();
      if (await el.isVisible({ timeout: 1200 }).catch(() => false)) { await el.click().catch(() => {}); await page.waitForTimeout(pause); return true; }
      el = page.getByText(rx, { exact: false }).first();
      if (await el.isVisible({ timeout: 1200 }).catch(() => false)) { await el.click().catch(() => {}); await page.waitForTimeout(pause); return true; }
      el = page.locator(`[aria-label*="${rx.source || rx}" i]`).first();
      if (await el.isVisible({ timeout: 1000 }).catch(() => false)) { await el.click().catch(() => {}); await page.waitForTimeout(pause); return true; }
    }
    return false;
  };

  // 1) Add a Choice question to learn its schema.
  log('add new -> Choice');
  await click([/add new/i, /add question/i]);
  await click([/^choice$/i, /\bchoice\b/i]);
  await page.waitForTimeout(3500);
  await page.screenshot({ path: path.join(OUT, 's1-choice.png'), fullPage: true }).catch(() => {});

  // 2) Open Settings and choose "Anyone can respond".
  log('open settings');
  await click([/^settings$/i, /more (form )?settings/i, /more options/i], 2500);
  await page.screenshot({ path: path.join(OUT, 's2-settings.png'), fullPage: true }).catch(() => {});
  log('choose anyone can respond');
  await click([/anyone can respond/i, /anyone with the link/i, /anyone$/i], 2500);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, 's3-after-anyone.png'), fullPage: true }).catch(() => {});

  // 3) Open Collect responses / Share to surface the public link.
  log('open collect responses / share');
  await click([/collect responses/i, /share/i, /send/i], 3000);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, 's4-share.png'), fullPage: true }).catch(() => {});
  // Read any visible response URL on the page.
  const pageLinks = await page.evaluate(() => {
    const out = [];
    document.querySelectorAll('input,textarea,a').forEach(e => {
      const v = e.value || e.href || '';
      if (/ResponsePage\.aspx|forms\.office\.com\/r\//i.test(v)) out.push(v);
    });
    return [...new Set(out)];
  }).catch(() => []);

  // 4) Read back the final form via API (questions + settings).
  const got = await page.request.get(`${COLL}('${id}')?$expand=questions`, { headers: H });
  let formJson = ''; try { formJson = (await got.text()).slice(0, 6000); } catch {}

  fs.writeFileSync(path.join(OUT, 'settings-calls.json'), JSON.stringify(calls, null, 2));
  fs.writeFileSync(path.join(OUT, 'form-readback.json'), formJson);
  fs.writeFileSync(path.join(OUT, 'page-links.txt'), pageLinks.join('\n'));
  log(`captured ${calls.length} calls; pageLinks=${pageLinks.length}`);
  await ctx.close();
  log('done');
})();
