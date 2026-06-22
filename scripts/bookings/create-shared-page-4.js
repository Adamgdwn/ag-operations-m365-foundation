// Step 4: robustly kill the onboarding carousel via in-page JS (click its Next / final
// button by text, scoped to the overlay holding "Hassle free scheduling"), then fill the
// wizard fields by exact aria-label and advance. Screenshots throughout. NOT auto-submitted.
//   node scripts/bookings/create-shared-page-4.js
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

// Kill carousel: returns label clicked, or null when it's gone.
const killCarousel = async (page) => {
  return await page.evaluate(() => {
    const all = [...document.querySelectorAll('div,section,aside')];
    const root = all.find(e => /hassle free scheduling/i.test(e.innerText || '') && e.querySelector('button'));
    if (!root) return null;
    // smallest container that still holds the heading (the carousel card)
    let card = root;
    for (const e of all) { if (/hassle free scheduling/i.test(e.innerText || '') && root.contains(e) && e.querySelector('button')) card = e; }
    const btns = [...card.querySelectorAll('button,[role=button]')];
    const byText = (re) => btns.find(b => re.test((b.innerText || b.getAttribute('aria-label') || '').trim()));
    const target = byText(/^get started$/i) || byText(/^done$/i) || byText(/^got it$/i) || byText(/^finish$/i) || byText(/^next$/i) || byText(/close/i);
    if (target) { const lbl = (target.innerText || target.getAttribute('aria-label') || '').trim(); target.click(); return lbl || '(unnamed)'; }
    return '(no-button)';
  }).catch(e => 'ERR:' + e.message);
};
const carouselGone = async (page) => !(await page.locator('text=/hassle free scheduling/i').first().isVisible().catch(() => false));

const fillByLabel = async (page, label, value) => {
  return await page.evaluate(({ label, value }) => {
    const el = document.querySelector(`input[aria-label="${label}"], textarea[aria-label="${label}"]`);
    if (!el) return false;
    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value') || Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value');
    setter.set.call(el, value);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    return true;
  }, { label, value }).catch(() => false);
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(8000);

  // Kill carousel (pre-wizard).
  for (let i = 0; i < 8 && !(await carouselGone(page)); i++) { const r = await killCarousel(page); log('carousel kill#' + i + ': ' + r); await page.waitForTimeout(1300); }
  log('carousel gone (pre-wizard)? ' + await carouselGone(page));

  // Open the shared "Create booking page" wizard (last button = shared section).
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(5000);

  // Carousel re-pops on the wizard — kill again.
  for (let i = 0; i < 8 && !(await carouselGone(page)); i++) { const r = await killCarousel(page); log('carousel(2) kill#' + i + ': ' + r); await page.waitForTimeout(1300); }
  log('carousel gone (on wizard)? ' + await carouselGone(page));
  await page.waitForTimeout(1500);
  await shot(page, 'create-20-wizard-clear.png');

  // Fill name.
  const okName = await fillByLabel(page, 'Give your booking page a name', 'Guided AI Labs');
  log('filled name? ' + okName);
  await page.waitForTimeout(800);

  // Business type: it's likely a combobox; click then pick.
  const btSel = '[aria-label="Choose a business type"]';
  await page.locator(btSel).first().click().catch(() => log('bt click failed'));
  await page.waitForTimeout(1500);
  const opts = await page.evaluate(() => [...new Set([...document.querySelectorAll('[role=option],[role=menuitem],[role=menuitemradio],li')].map(e => (e.innerText || '').trim()).filter(t => t && t.length < 40))].slice(0, 60)).catch(() => []);
  fs.writeFileSync(path.join(CAP, 'create-21-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-21-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 30).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(1000);
  await shot(page, 'create-22-filled.png');

  const state = await page.evaluate(() => ({
    name: (document.querySelector('input[aria-label="Give your booking page a name"]') || {}).value || '',
    bt: (document.querySelector('[aria-label="Choose a business type"]') || {}).value || '',
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length < 30))].slice(0, 40),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-22-state.json'), JSON.stringify(state, null, 2));
  log('state: name="' + state.name + '" bt="' + state.bt + '"');
  log('buttons: ' + (state.buttons || []).join(' | '));
  log('PAUSED: filled, NOT submitted.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
