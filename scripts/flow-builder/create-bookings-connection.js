// Create the Microsoft Bookings Power Automate CONNECTION (the one consent prerequisite for
// the booking->CRM flow) by driving the connections UI in the signed-in Edge profile. May
// complete silently (already signed in) or need a single "Allow" click from Adam. Polls the
// connections API until shared_microsoftbookings appears Connected. Visible window.
//   node scripts/flow-builder/create-bookings-connection.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const shot = async (p, n) => { await p.screenshot({ path: path.join(CAP, n), fullPage: true }).catch(() => {}); log('shot ' + n); };
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const au = req.headers()['authorization']; if (au && /^bearer /i.test(au)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = au.replace(/^bearer\s+/i, ''); } });
  const connExists = async () => {
    if (!tokens[EHOST]) return false;
    try { const r = await page.request.get(`https://${EHOST}/connectivity/connections?api-version=1`, { headers: { authorization: 'Bearer ' + tokens[EHOST], accept: 'application/json' } }); const j = JSON.parse(await r.text()); return (j.value || []).some(c => /shared_microsoftbookings/.test(c.properties && c.properties.apiId || '')); } catch { return false; }
  };

  // Deep link straight to the Bookings connector's create-connection page.
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (await connExists()) { log('Bookings connection ALREADY exists. Done.'); await ctx.close(); return; }
  await shot(page, 'conn-00.png');

  // Click "+ New connection".
  for (const re of [/new connection/i, /\+ new/i]) { const b = page.getByRole('button', { name: re }).first(); if (await b.count().catch(() => 0)) { await b.click().catch(() => {}); log('clicked New connection'); break; } }
  await page.waitForTimeout(3000);
  // Search "Bookings".
  const search = page.getByPlaceholder(/search/i).first();
  if (await search.count().catch(() => 0)) { await search.fill('Bookings').catch(() => {}); log('typed Bookings'); }
  await page.waitForTimeout(3000);
  await shot(page, 'conn-01-search.png');

  // Click the Microsoft Bookings connector row, then its Create.
  const row = page.getByText(/^Microsoft Bookings$/).first();
  if (await row.count().catch(() => 0)) { await row.click().catch(() => {}); log('clicked Microsoft Bookings'); }
  await page.waitForTimeout(2000);
  for (const re of [/^create$/i, /^add$/i, /^continue$/i]) { const b = page.getByRole('button', { name: re }).first(); if (await b.count().catch(() => 0) && await b.isVisible().catch(() => false)) { await b.click().catch(() => {}); log('clicked ' + re.source); break; } }
  await page.waitForTimeout(4000);
  await shot(page, 'conn-02-after-create.png');

  // A consent/permissions popup may appear — try to accept it; otherwise Adam clicks once.
  for (const re of [/^accept$/i, /^allow$/i, /^yes$/i, /^continue$/i]) {
    const b = page.getByRole('button', { name: re }).first();
    if (await b.count().catch(() => 0) && await b.isVisible().catch(() => false)) { await b.click().catch(() => {}); log('auto-clicked consent: ' + re.source); break; }
  }

  // Poll for the connection to appear (gives Adam time to click Allow if a popup is showing).
  let ok = false;
  for (let i = 0; i < 40; i++) {
    if (await connExists()) { ok = true; break; }
    if (i % 5 === 0) log(`waiting for Bookings connection... (${i * 3}s) — if a consent window is open, click Allow/Accept`);
    await page.waitForTimeout(3000);
  }
  await shot(page, 'conn-03-final.png');
  log(ok ? 'SUCCESS: Bookings connection created.' : 'NOT YET: connection not detected. See screenshots; Adam may need to complete consent, then re-run create-booking-flow.js.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
