// Step 3: properly dismiss the onboarding carousel by stepping THROUGH its own Next
// button (scoped to the carousel dialog), then fill the create-shared-page wizard.
//   node scripts/bookings/create-shared-page-3.js
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
const dump = async (page, n) => {
  const info = await page.evaluate(() => {
    const q = (sel) => [...document.querySelectorAll(sel)];
    return {
      fields: q('input,textarea,[role=combobox],[role=textbox]').map(e => ({ tag: e.tagName, aria: e.getAttribute('aria-label') || '', placeholder: e.placeholder || '', value: (e.value || '').slice(0, 60) })),
      buttons: [...new Set(q('button,[role=button]').map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(Boolean))].slice(0, 50),
      options: [...new Set(q('[role=option],[role=menuitemradio]').map(e => (e.innerText || '').trim()).filter(Boolean))].slice(0, 60),
    };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, n), JSON.stringify(info, null, 2));
  return info;
};
const carouselVisible = async (page) => {
  return await page.locator('text=/hassle free scheduling/i').first().isVisible().catch(() => false);
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(8000);

  // ---- Dismiss the onboarding carousel FIRST (it overlays everything) ----------
  // It can appear before we even open the wizard. Step through its Next/last-slide button.
  for (let i = 0; i < 6 && await carouselVisible(page); i++) {
    const carousel = page.locator('[role=dialog]').filter({ hasText: /hassle free scheduling/i }).last();
    const labels = ['Get started', 'Done', 'Got it', 'Finish', 'Close', 'Next'];
    let did = false;
    for (const lab of labels) {
      const b = carousel.getByRole('button', { name: new RegExp('^' + lab + '$', 'i') }).first();
      if (await b.count().catch(() => 0) && await b.isVisible().catch(() => false)) {
        await b.click().catch(() => {}); log('carousel: clicked "' + lab + '" (slide ' + i + ')'); did = true; break;
      }
    }
    if (!did) { log('carousel: no actionable button found on slide ' + i); break; }
    await page.waitForTimeout(1400);
  }
  await page.waitForTimeout(1500);
  await shot(page, 'create-10-no-carousel.png');
  log('carousel still visible? ' + await carouselVisible(page));

  // ---- Open the shared "Create booking page" wizard ----------------------------
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(5000);
  // Carousel may re-pop on top of the wizard — clear it again the same way.
  for (let i = 0; i < 4 && await carouselVisible(page); i++) {
    const carousel = page.locator('[role=dialog]').filter({ hasText: /hassle free scheduling/i }).last();
    for (const lab of ['Get started', 'Done', 'Got it', 'Finish', 'Next']) {
      const b = carousel.getByRole('button', { name: new RegExp('^' + lab + '$', 'i') }).first();
      if (await b.count().catch(() => 0) && await b.isVisible().catch(() => false)) { await b.click().catch(() => {}); log('carousel(2): "' + lab + '"'); break; }
    }
    await page.waitForTimeout(1400);
  }
  await page.waitForTimeout(1500);
  await shot(page, 'create-11-wizard.png');

  // ---- Fill name ---------------------------------------------------------------
  const name = page.getByRole('textbox', { name: /give your booking page a name|business name|^name$/i }).first();
  if (await name.count().catch(() => 0)) { await name.click().catch(() => {}); await name.fill('Guided AI Labs').catch(() => {}); log('filled name=Guided AI Labs'); }
  else {
    // Fallback: first visible text input inside the wizard dialog.
    const wiz = page.locator('[role=dialog]').last();
    const t = wiz.locator('input[type=text], textbox').first();
    if (await t.count().catch(() => 0)) { await t.fill('Guided AI Labs').catch(() => {}); log('filled name via fallback'); } else log('NAME FIELD NOT FOUND');
  }
  await page.waitForTimeout(800);

  // ---- Business type -----------------------------------------------------------
  const bt = page.getByRole('combobox', { name: /business type/i }).first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); }
  else { const alt = page.getByText(/choose a business type/i).first(); if (await alt.count().catch(() => 0)) await alt.click().catch(() => {}); }
  await page.waitForTimeout(1500);
  const optInfo = await dump(page, 'create-12-btoptions.json');
  await shot(page, 'create-12-btoptions.png');
  log('business-type options: ' + (optInfo.options || []).join(' | '));

  let picked = null;
  for (const re of [/consult/i, /professional/i, /^business/i, /technology|software|it services/i, /other/i]) {
    const opt = page.getByRole('option', { name: re }).first();
    if (await opt.count().catch(() => 0) && await opt.isVisible().catch(() => false)) { picked = await opt.innerText().catch(() => re.source); await opt.click().catch(() => {}); break; }
  }
  if (!picked) { const o = page.getByRole('option').first(); if (await o.count().catch(() => 0)) { picked = await o.innerText().catch(() => '(first)'); await o.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(1000);
  await shot(page, 'create-13-filled.png');
  const after = await dump(page, 'create-13-filled.json');
  log('buttons now: ' + (after.buttons || []).join(' | '));
  log('fields now: ' + JSON.stringify((after.fields || []).map(f => (f.aria || f.placeholder) + '=' + f.value)));
  log('PAUSED: step 1 filled, NOT submitted.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
