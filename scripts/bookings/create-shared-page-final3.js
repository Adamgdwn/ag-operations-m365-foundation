// FINAL3: the big carousel is already dismissable; the bug was matching the STATIC page
// header "skip the back and forth". Here we (1) dismiss any teaching popups on the homepage
// by clicking visible Dismiss/Close buttons (safe: no wizard open yet), (2) click the shared
// "Create booking page", (3) POLL for the name field to appear (wizard open), dismissing the
// carousel only if its SPECIFIC modal heading shows, then (4) fill name + business type and
// advance one step with screenshots.
//   node scripts/bookings/create-shared-page-final3.js
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

const NAME_SEL = 'input[aria-label="Give your booking page a name"]';

// Dismiss teaching popups on the HOMEPAGE only (no wizard open → safe to click any Dismiss/Close).
const dismissTeachers = async (page) => page.evaluate(() => {
  const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
  let clicked = 0;
  for (const b of [...document.querySelectorAll('button[aria-label="Dismiss"], button[aria-label="Close"], button[title="Close"]')].filter(vis)) { b.click(); clicked++; }
  return clicked;
});
// Dismiss the carousel ONLY when its specific modal heading is present (safe vs wizard).
const dismissCarouselIfModal = async (page) => page.evaluate(() => {
  const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
  const re = /hassle free scheduling|share your availability with people|quick-start with templates/i;
  const hasModal = [...document.querySelectorAll('h1,h2,h3')].some(e => vis(e) && re.test((e.innerText || '').slice(0, 80)));
  if (!hasModal) return 'no-modal';
  const ds = [...document.querySelectorAll('button[aria-label="Dismiss"], button[aria-label="Close"]')].filter(vis);
  if (ds.length) { ds[0].click(); return 'dismissed'; }
  return 'modal-no-x';
});

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));

  // Wait for the page + carousel to render, then clear teaching popups (poll ~20s window).
  for (let i = 0; i < 12; i++) { await page.waitForTimeout(1700); const c = await dismissTeachers(page).catch(() => 0); if (c) log('homepage dismiss: clicked ' + c); }
  await page.waitForTimeout(1200);
  await shot(page, 'create-70-home.png');

  // Click the shared "Create booking page" (last one).
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  log('create-booking-page buttons: ' + n);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});

  // Poll for the wizard name field to appear; dismiss carousel re-pop if its modal heading shows.
  let nameReady = false;
  for (let i = 0; i < 20; i++) {
    if (await page.locator(NAME_SEL).first().count().catch(() => 0) && await page.locator(NAME_SEL).first().isVisible().catch(() => false)) { nameReady = true; break; }
    const d = await dismissCarouselIfModal(page).catch(() => 'err');
    if (d === 'dismissed') log('carousel dismissed on wizard (#' + i + ')');
    await page.waitForTimeout(1300);
  }
  log('name field ready? ' + nameReady);
  await shot(page, 'create-71-wizard.png');
  if (!nameReady) { log('WIZARD DID NOT OPEN — aborting for inspection.'); await ctx.close(); return; }

  // Fill name.
  const nameLoc = page.locator(NAME_SEL).first();
  await nameLoc.click().catch(() => {}); await nameLoc.fill('Guided AI Labs').catch(() => {});
  log('filled name=Guided AI Labs');
  await page.waitForTimeout(700);

  // Business type.
  const bt = page.locator('[aria-label="Choose a business type"]').first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); log('opened business type'); } else log('BT FIELD NOT FOUND');
  await page.waitForTimeout(1500);
  const opts = await page.evaluate(() => [...new Set([...document.querySelectorAll('[role=option],[role=menuitem],[role=menuitemradio]')].map(e => (e.innerText || '').trim()).filter(t => t && t.length < 40))].slice(0, 80)).catch(() => []);
  fs.writeFileSync(path.join(CAP, 'create-72-btoptions.json'), JSON.stringify(opts, null, 2));
  await shot(page, 'create-72-btoptions.png');
  log('bt options (' + opts.length + '): ' + opts.slice(0, 40).join(' | '));
  let picked = null;
  for (const re of [/consult/i, /professional/i, /technology|software|IT/i, /^business/i, /other/i]) {
    const o = page.getByRole('option', { name: re }).first();
    if (await o.count().catch(() => 0) && await o.isVisible().catch(() => false)) { picked = await o.innerText().catch(() => re.source); await o.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(900);
  await shot(page, 'create-73-step1.png');

  // Advance one step (Next) — reversible navigation; screenshot step 2.
  const nextBtn = page.getByRole('button', { name: /^next$/i }).last();
  if (await nextBtn.count().catch(() => 0)) { await nextBtn.click().catch(() => {}); log('clicked Next'); }
  await page.waitForTimeout(3000);
  await shot(page, 'create-74-step2.png');
  const step2 = await page.evaluate(() => ({
    fields: [...document.querySelectorAll('input,textarea,[role=combobox],[role=textbox]')].map(e => ({ aria: e.getAttribute('aria-label') || '', ph: e.placeholder || '', val: (e.value || '').slice(0, 40) })).filter(f => f.aria || f.ph),
    buttons: [...new Set([...document.querySelectorAll('button,[role=button]')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length > 0 && t.length < 28))].slice(0, 40),
    headings: [...document.querySelectorAll('h1,h2,h3')].map(h => (h.innerText || '').trim()).filter(Boolean).slice(0, 10),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'create-74-step2.json'), JSON.stringify(step2, null, 2));
  log('STEP2 headings: ' + (step2.headings || []).join(' | '));
  log('STEP2 fields: ' + JSON.stringify((step2.fields || []).map(f => f.aria || f.ph)));
  log('STEP2 buttons: ' + (step2.buttons || []).join(' | '));
  log('PAUSED at step 2. NOT submitted/published.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
