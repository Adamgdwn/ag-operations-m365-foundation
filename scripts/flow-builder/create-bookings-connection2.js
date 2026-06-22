// Create the Microsoft Bookings connection — corrected: use the CONNECTOR-LIST search (not the
// global top-nav search, which shows templates) and click the "+" on the Microsoft Bookings row.
//   node scripts/flow-builder/create-bookings-connection2.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const shot = async (p, n) => { await p.screenshot({ path: path.join(CAP, n), fullPage: true }).catch(() => {}); log('shot ' + n); };
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const au = req.headers()['authorization']; if (au && /^bearer /i.test(au)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = au.replace(/^bearer\s+/i, ''); } });
  const connExists = async () => { if (!tokens[EHOST]) return false; try { const r = await page.request.get(`https://${EHOST}/connectivity/connections?api-version=1`, { headers: { authorization: 'Bearer ' + tokens[EHOST], accept: 'application/json' } }); const j = JSON.parse(await r.text()); return (j.value || []).some(c => /shared_microsoftbookings/.test(c.properties && c.properties.apiId || '')); } catch { return false; } };

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (await connExists()) { log('Bookings connection ALREADY exists.'); await ctx.close(); return; }

  // New connection -> connector list.
  for (const re of [/new connection/i]) { const b = page.getByRole('button', { name: re }).first(); if (await b.count().catch(() => 0)) { await b.click().catch(() => {}); log('clicked New connection'); break; } }
  await page.waitForTimeout(4000);
  await page.keyboard.press('Escape').catch(() => {}); // close any global search dropdown

  // Use the connector-list search (rightmost visible search box), NOT the global top-nav one.
  const typedOk = await page.evaluate(() => {
    const vis = (e) => { const r = e.getBoundingClientRect(); return r.width > 40 && r.height > 4 && getComputedStyle(e).visibility !== 'hidden'; };
    const inputs = [...document.querySelectorAll('input[type=text],input[type=search],input[placeholder]')].filter(vis);
    // the connector-list search sits in the content area (cy > 50, and not the blue top bar at cy<40)
    const content = inputs.filter(i => i.getBoundingClientRect().top > 45).sort((a, b) => b.getBoundingClientRect().right - a.getBoundingClientRect().right);
    const target = content[0] || inputs[0];
    if (!target) return false;
    target.focus();
    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    setter.call(target, 'Bookings'); target.dispatchEvent(new Event('input', { bubbles: true }));
    return true;
  }).catch(() => false);
  log('typed into connector-list search: ' + typedOk);
  await page.waitForTimeout(4000);
  await shot(page, 'conn2-01-search.png');

  // Click the "+" (create connection) on the Microsoft Bookings row.
  const clicked = await page.evaluate(() => {
    const vis = (e) => { const r = e.getBoundingClientRect(); return r.width > 2 && r.height > 2 && getComputedStyle(e).visibility !== 'hidden'; };
    // find a row/cell containing exactly "Microsoft Bookings"
    const labels = [...document.querySelectorAll('*')].filter(e => vis(e) && (e.innerText || '').trim() === 'Microsoft Bookings');
    if (!labels.length) return 'no-row';
    // climb to the row container, then find a create/add button (+) within it
    let row = labels[0];
    for (let i = 0; i < 6 && row.parentElement; i++) { row = row.parentElement; if (row.querySelector('button')) break; }
    const btns = [...row.querySelectorAll('button,[role=button]')].filter(vis);
    const plus = btns.find(b => /create|add|\+|connection/i.test((b.getAttribute('aria-label') || b.title || b.innerText || '').trim())) || btns[btns.length - 1];
    if (plus) { plus.click(); return 'clicked:' + (plus.getAttribute('aria-label') || plus.title || plus.innerText || '+').trim(); }
    // else click the label itself (row may be clickable)
    labels[0].click(); return 'clicked-label';
  }).catch(e => 'ERR:' + e.message);
  log('Microsoft Bookings row action: ' + clicked);
  await page.waitForTimeout(4000);
  await shot(page, 'conn2-02-after-plus.png');

  // Accept any consent dialog.
  for (const re of [/^create$/i, /^accept$/i, /^allow$/i, /^continue$/i, /^sign in$/i, /^yes$/i]) {
    const b = page.getByRole('button', { name: re }).first();
    if (await b.count().catch(() => 0) && await b.isVisible().catch(() => false)) { await b.click().catch(() => {}); log('clicked consent: ' + re.source); await page.waitForTimeout(2500); }
  }

  let ok = false;
  for (let i = 0; i < 40; i++) { if (await connExists()) { ok = true; break; } if (i % 5 === 0) log(`waiting for Bookings connection... (${i * 3}s)`); await page.waitForTimeout(3000); }
  await shot(page, 'conn2-03-final.png');
  log(ok ? 'SUCCESS: Bookings connection created.' : 'NOT YET — see conn2-*.png; consent may need Adam.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
