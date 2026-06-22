// Step 6: dismiss the onboarding carousel by clicking ITS OWN close (×) — found via JS
// scoped to the card containing the onboarding heading, so it can never hit the wizard's ×
// (which triggers a quit-confirm). Wait long enough for the carousel to render first. Then
// open the shared create-page wizard, dismiss any re-pop, and fill name + business type.
//   node scripts/bookings/create-shared-page-6.js
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

const ONBOARD_RE = 'hassle free scheduling|share your availability|skip the back and forth|book time with people|email signature';
const carouselVisible = async (page) => await page.locator(`text=/${ONBOARD_RE}/i`).first().isVisible().catch(() => false);

// Click the carousel's OWN close button (scoped to its card). Returns status.
const closeCarousel = async (page) => {
  return await page.evaluate((reStr) => {
    const re = new RegExp(reStr, 'i');
    const visible = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
    const txt = (b) => (b.innerText || b.getAttribute('aria-label') || b.getAttribute('title') || '').trim();
    // candidate cards: visible, contain an onboarding phrase, hold a button, are reasonably modal-sized
    let cards = [...document.querySelectorAll('div,section,aside')].filter(e => visible(e) && re.test(e.innerText || '') && e.querySelector('button'));
    if (!cards.length) return 'gone';
    let card = cards[0]; for (const c of cards) if (card.contains(c)) card = c;  // smallest
    const bs = [...card.querySelectorAll('button,[role=button]')].filter(visible);
    // prefer an explicit Close
    let close = bs.find(b => /^close$/i.test(txt(b)) || /close/i.test(b.getAttribute('aria-label') || ''));
    // else the top-right icon-only button within the card
    if (!close) {
      const cr = card.getBoundingClientRect();
      const iconBtns = bs.filter(b => !(b.innerText || '').trim());
      close = iconBtns.sort((a, b) => {
        const ra = a.getBoundingClientRect(), rb = b.getBoundingClientRect();
        return (Math.abs(ra.top - cr.top) + Math.abs(ra.right - cr.right)) - (Math.abs(rb.top - cr.top) + Math.abs(rb.right - cr.right));
      })[0];
    }
    if (close) { close.click(); return 'closed:' + (txt(close) || 'icon'); }
    return 'no-close-found';
  }, ONBOARD_RE).catch(e => 'ERR:' + e.message);
};

const dismissLoop = async (page, tag) => {
  for (let i = 0; i < 5; i++) {
    if (!(await carouselVisible(page))) { log(tag + ': carousel not visible'); return true; }
    const r = await closeCarousel(page);
    log(tag + ' close#' + i + ': ' + r);
    await page.waitForTimeout(1600);
  }
  return !(await carouselVisible(page));
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  // Wait for the carousel to actually render (it appears ~8-12s after load).
  await page.waitForTimeout(12000);
  log('carousel visible after settle? ' + await carouselVisible(page));
  await dismissLoop(page, 'home');
  await page.waitForTimeout(1500);
  await shot(page, 'create-40-home.png');

  // Open shared create wizard.
  let cands = page.getByRole('button', { name: /create booking page/i });
  let n = await cands.count().catch(() => 0);
  if (!n) { await page.waitForTimeout(3000); cands = page.getByRole('button', { name: /create booking page/i }); n = await cands.count().catch(() => 0); }
  log('create-booking-page buttons: ' + n);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(6000);

  // Carousel may re-pop atop the wizard — dismiss via its own × (scoped; safe).
  await dismissLoop(page, 'wizard');
  await page.waitForTimeout(1500);
  await shot(page, 'create-41-wizard.png');

  // Fill name.
  const nameLoc = page.locator('input[aria-label="Give your booking page a name"]').first();
  if (await nameLoc.count().catch(() => 0)) { await nameLoc.click().catch(() => {}); await nameLoc.fill('Guided AI Labs').catch(() => {}); log('filled name'); }
  else log('NAME FIELD NOT FOUND');
  await page.waitForTimeout(700);

  // Business type.
  const bt = page.locator('[aria-label="Choose a business type"]').first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); log('opened bt'); } else log('BT FIELD NOT FOUND');
  await page.waitForTimeout(1500);
  const opts = await page.evaluate(() => [...new Set([...document.querySelectorAll('[role=option],[role=menuitem],[role=menuitemradio]')].map(e => (e.innerText || '').trim()).filter(t => t && t.length < 40))].slice(0, 80)).catch(() => []);
  fs.writeFileSync(path.join(CAP, 'create-42-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-42-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 40).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(900);
  await shot(page, 'create-43-filled.png');

  const state = await page.evaluate(() => ({
    name: (document.querySelector('input[aria-label="Give your booking page a name"]') || {}).value || '(field gone)',
    bt: (document.querySelector('[aria-label="Choose a business type"]') || {}).value || '(field gone)',
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length < 30 && t.length > 0))].slice(0, 40),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-43-state.json'), JSON.stringify(state, null, 2));
  log('STATE name="' + state.name + '" bt="' + state.bt + '"');
  log('buttons: ' + (state.buttons || []).join(' | '));
  log('PAUSED: filled, NOT submitted.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
