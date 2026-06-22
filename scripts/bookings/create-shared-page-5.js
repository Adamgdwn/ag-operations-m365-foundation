// Step 5: FULLY complete the 3-slide onboarding carousel once (click Next through every
// slide to the terminal "Get started"/"Done" button, which permanently dismisses it via
// user-config), confirm the homepage is clean, THEN open the shared create-page wizard and
// fill name + business type. Carousel discriminator: it has BOTH "Previous" and "Next";
// the wizard step 1 has no "Previous".
//   node scripts/bookings/create-shared-page-5.js
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

// Operate on the carousel card = smallest element containing BOTH a Previous and a
// Next/terminal button. Click terminal if present, else Next. Returns a status string.
const stepCarousel = async (page) => {
  return await page.evaluate(() => {
    const visible = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none'; };
    const btnText = (b) => (b.innerText || b.getAttribute('aria-label') || '').trim();
    const cards = [...document.querySelectorAll('div,section,aside')].filter(e => {
      if (!visible(e)) return false;
      const bs = [...e.querySelectorAll('button,[role=button]')].filter(visible);
      const hasPrev = bs.some(b => /^previous$/i.test(btnText(b)));
      const hasNextOrTerm = bs.some(b => /^next$|^get started$|^done$|^got it$|^finish$/i.test(btnText(b)));
      return hasPrev && hasNextOrTerm;
    });
    if (!cards.length) return 'gone';
    // smallest such card
    let card = cards[0]; for (const c of cards) if (card.contains(c)) card = c;
    const bs = [...card.querySelectorAll('button,[role=button]')].filter(visible);
    const term = bs.find(b => /^get started$|^done$|^got it$|^finish$/i.test(btnText(b)));
    if (term) { term.click(); return 'terminal:' + btnText(term); }
    const next = bs.find(b => /^next$/i.test(btnText(b)));
    if (next) { next.click(); return 'next'; }
    return 'stuck';
  }).catch(e => 'ERR:' + e.message);
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(8000);

  // Complete the carousel.
  for (let i = 0; i < 8; i++) {
    const r = await stepCarousel(page);
    log('carousel step#' + i + ': ' + r);
    if (r === 'gone' || r.startsWith('terminal') || r.startsWith('ERR') || r === 'stuck') { await page.waitForTimeout(1500); if (r.startsWith('terminal')) { /* one more to confirm gone */ } else break; }
    await page.waitForTimeout(1400);
    if (await stepCarousel(page) === 'gone') { log('carousel confirmed gone'); break; }
  }
  await page.waitForTimeout(1500);
  await shot(page, 'create-30-home-clean.png');

  // Open shared create wizard.
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  log('create-booking-page buttons: ' + n);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(5000);
  // In case carousel re-appears, complete it again.
  for (let i = 0; i < 6; i++) { const r = await stepCarousel(page); if (r === 'gone') break; log('carousel(on-wizard) step#' + i + ': ' + r); await page.waitForTimeout(1400); }
  await page.waitForTimeout(1500);
  await shot(page, 'create-31-wizard.png');

  // Fill name (real input).
  const nameLoc = page.locator('input[aria-label="Give your booking page a name"]').first();
  if (await nameLoc.count().catch(() => 0)) { await nameLoc.click().catch(() => {}); await nameLoc.fill('Guided AI Labs').catch(() => {}); log('filled name'); }
  else log('NAME FIELD NOT FOUND at create-31');
  await page.waitForTimeout(700);

  // Business type combobox.
  const bt = page.locator('[aria-label="Choose a business type"]').first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); log('opened business type'); } else log('BT FIELD NOT FOUND');
  await page.waitForTimeout(1500);
  const opts = await page.evaluate(() => [...new Set([...document.querySelectorAll('[role=option],[role=menuitem],[role=menuitemradio]')].map(e => (e.innerText || '').trim()).filter(t => t && t.length < 40))].slice(0, 80)).catch(() => []);
  fs.writeFileSync(path.join(CAP, 'create-32-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-32-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 40).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(900);
  await shot(page, 'create-33-filled.png');

  const state = await page.evaluate(() => ({
    name: (document.querySelector('input[aria-label="Give your booking page a name"]') || {}).value || '(field gone)',
    bt: (document.querySelector('[aria-label="Choose a business type"]') || {}).value || '(field gone)',
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length < 30 && t.length > 0))].slice(0, 40),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-33-state.json'), JSON.stringify(state, null, 2));
  log('STATE name="' + state.name + '" bt="' + state.bt + '"');
  log('buttons: ' + (state.buttons || []).join(' | '));
  log('PAUSED: filled, NOT submitted.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
