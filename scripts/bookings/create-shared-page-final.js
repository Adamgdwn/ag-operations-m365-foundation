// FINAL create flow: dismiss the onboarding carousel via aria-label="Dismiss" (its × at the
// modal top-right), open the shared "Create booking page" wizard, fill name + business type,
// advance one step, and screenshot each step. Pauses before anything irreversible.
//   node scripts/bookings/create-shared-page-final.js
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

const ONBOARD_RE = /hassle free scheduling|share your availability|skip the back and forth/i;
const onboardVisible = async (page) => await page.locator(`text=${ONBOARD_RE.source}`).first().isVisible().catch(() => false);

// Dismiss the carousel using its top-right "Dismiss" icon button, but only while the
// onboarding text is showing (so we never click the wizard's own Dismiss/close).
const dismissCarousel = async (page, tag) => {
  for (let i = 0; i < 6; i++) {
    if (!(await onboardVisible(page))) { log(tag + ': carousel gone'); return true; }
    // The carousel Dismiss sits at the modal's top-right (cy ~ 220-260). Pick the topmost Dismiss.
    const picked = await page.evaluate(() => {
      const vis = (e) => { const r = e.getBoundingClientRect(); return r.width > 4 && r.height > 4 && getComputedStyle(e).visibility !== 'hidden'; };
      const ds = [...document.querySelectorAll('button[aria-label="Dismiss"]')].filter(vis).map(b => { const r = b.getBoundingClientRect(); return { b, cy: r.y + r.height / 2 }; }).sort((a, z) => a.cy - z.cy);
      if (!ds.length) return false; ds[0].b.click(); return true;
    }).catch(() => false);
    log(tag + ' dismiss#' + i + ': ' + picked);
    await page.waitForTimeout(1600);
  }
  return !(await onboardVisible(page));
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(13000);
  await dismissCarousel(page, 'home');
  await page.waitForTimeout(1500);
  await shot(page, 'create-50-home.png');

  // Open shared create wizard (last "Create booking page" button = shared section).
  let cands = page.getByRole('button', { name: /create booking page/i });
  let n = await cands.count().catch(() => 0);
  log('create-booking-page buttons: ' + n);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(6000);
  // carousel might re-pop atop the wizard
  if (await onboardVisible(page)) await dismissCarousel(page, 'wizard');
  await page.waitForTimeout(1500);
  await shot(page, 'create-51-wizard.png');

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
  fs.writeFileSync(path.join(CAP, 'create-52-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-52-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 40).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(900);
  await shot(page, 'create-53-step1-filled.png');

  const state = await page.evaluate(() => ({
    name: (document.querySelector('input[aria-label="Give your booking page a name"]') || {}).value || '(gone)',
    bt: (document.querySelector('[aria-label="Choose a business type"]') || {}).value || '(gone)',
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length > 0 && t.length < 28))].slice(0, 40),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-53-state.json'), JSON.stringify(state, null, 2));
  log('STATE name="' + state.name + '" bt="' + state.bt + '"');
  log('buttons: ' + (state.buttons || []).join(' | '));
  log('PAUSED after step 1 fill (name + business type). NOT advanced/submitted.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
