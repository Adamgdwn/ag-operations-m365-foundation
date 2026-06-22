// FINAL2: robustly dismiss the onboarding carousel — poll across its variable render delay,
// and ONLY click the top-right "Dismiss" while onboarding TEXT is actually present (so we
// never hit the wizard's identically-placed Dismiss). Then open the shared create wizard,
// fill name + business type, and screenshot. Pauses before advancing past step 1.
//   node scripts/bookings/create-shared-page-final2.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const shot = async (page, n) => { await page.screenshot({ path: path.join(CAP, n), fullPage: true }).catch(() => {}); log('shot ' + n); };

const ONBOARD = 'hassle free scheduling|share your availability|skip the back and forth|simplify scheduling to save time';
// One probe: is onboarding text present? if so, click its top-right Dismiss. Returns status.
const probe = async (page) => page.evaluate((reStr) => {
  const re = new RegExp(reStr, 'i');
  const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none' && r.bottom > 0 && r.top < innerHeight; };
  const hasOnboard = [...document.querySelectorAll('h1,h2,h3,div,span,p')].some(e => vis(e) && re.test((e.innerText || '').slice(0, 200)));
  if (!hasOnboard) return 'no-onboard';
  const ds = [...document.querySelectorAll('button[aria-label="Dismiss"]')].filter(vis).map(b => { const r = b.getBoundingClientRect(); return { b, cx: r.x + r.width / 2, cy: r.y + r.height / 2 }; });
  const hit = ds.find(d => d.cx >= 960 && d.cx <= 1120 && d.cy >= 170 && d.cy <= 310) || ds[0];
  if (hit) { hit.b.click(); return 'clicked'; }
  return 'onboard-no-dismiss';
}, ONBOARD).catch(e => 'ERR:' + e.message);

// Poll until carousel is dismissed (handles the variable render delay).
const killCarousel = async (page, tag) => {
  let sawOnboard = false;
  for (let i = 0; i < 22; i++) {
    const r = await probe(page);
    if (r === 'clicked') { sawOnboard = true; log(`${tag} #${i}: dismissed`); }
    else if (r === 'onboard-no-dismiss') { sawOnboard = true; log(`${tag} #${i}: onboard present, waiting for ×`); }
    else if (r === 'no-onboard') { if (sawOnboard || i >= 11) { log(`${tag} #${i}: clear`); return true; } }
    await page.waitForTimeout(1400);
  }
  return true;
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(6000);
  await killCarousel(page, 'home');
  await page.waitForTimeout(1500);
  await shot(page, 'create-60-home.png');

  // Open shared create wizard.
  let cands = page.getByRole('button', { name: /create booking page/i });
  let n = await cands.count().catch(() => 0);
  if (!n) { await page.waitForTimeout(2500); n = await cands.count().catch(() => 0); }
  log('create-booking-page buttons: ' + n);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(5000);
  await killCarousel(page, 'wizard');  // dismiss any re-pop; safe (text-gated)
  await page.waitForTimeout(1500);
  await shot(page, 'create-61-wizard.png');

  // Fill name.
  const nameLoc = page.locator('input[aria-label="Give your booking page a name"]').first();
  if (await nameLoc.count().catch(() => 0)) { await nameLoc.click().catch(() => {}); await nameLoc.fill('Guided AI Labs').catch(() => {}); log('filled name=Guided AI Labs'); }
  else log('NAME FIELD NOT FOUND');
  await page.waitForTimeout(700);

  // Business type dropdown.
  const bt = page.locator('[aria-label="Choose a business type"]').first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); log('opened business type'); } else log('BT FIELD NOT FOUND');
  await page.waitForTimeout(1500);
  const opts = await page.evaluate(() => [...new Set([...document.querySelectorAll('[role=option],[role=menuitem],[role=menuitemradio]')].map(e => (e.innerText || '').trim()).filter(t => t && t.length < 40))].slice(0, 80)).catch(() => []);
  fs.writeFileSync(path.join(CAP, 'create-62-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-62-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 40).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(900);
  await shot(page, 'create-63-step1.png');

  const state = await page.evaluate(() => ({
    name: (document.querySelector('input[aria-label="Give your booking page a name"]') || {}).value || '(gone)',
    bt: (document.querySelector('[aria-label="Choose a business type"]') || {}).value || '(gone)',
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length > 0 && t.length < 28))].slice(0, 40),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-63-state.json'), JSON.stringify(state, null, 2));
  log('STATE name="' + state.name + '" bt="' + state.bt + '"');
  log('buttons: ' + (state.buttons || []).join(' | '));
  log('PAUSED after step 1 fill.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
