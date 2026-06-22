// Step 2 of shared-page creation: dismiss the onboarding carousel, fill the wizard
// (name = "Guided AI Labs", business type), skip logo, advance step-by-step with shots.
//   node scripts/bookings/create-shared-page-2.js
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
      options: [...new Set(q('[role=option],[role=menuitemradio],li[role=option]').map(e => (e.innerText || '').trim()).filter(Boolean))].slice(0, 60),
      text: (document.body.innerText || '').slice(0, 1500),
    };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, n), JSON.stringify(info, null, 2));
  return info;
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(8000);

  // Open the shared "Create booking page" wizard.
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  await page.waitForTimeout(5000);

  // Dismiss onboarding carousel: click every visible Close (×) once, then Escape.
  for (let i = 0; i < 3; i++) {
    const closes = page.locator('button[aria-label="Close"], button[title="Close"], [aria-label="Close dialog"], [data-icon-name="Cancel"]');
    const cc = await closes.count().catch(() => 0);
    if (cc) { await closes.first().click().catch(() => {}); log('clicked a Close (' + cc + ' present)'); await page.waitForTimeout(1200); }
    else break;
  }
  await page.waitForTimeout(1500);
  await shot(page, 'create-02-after-carousel.png');

  // Fill the name field.
  const name = page.getByRole('textbox', { name: /give your booking page a name|business name|name/i }).first();
  if (await name.count().catch(() => 0)) { await name.click().catch(() => {}); await name.fill('Guided AI Labs').catch(async () => { await name.type('Guided AI Labs'); }); log('filled name'); }
  else { log('NAME FIELD NOT FOUND'); }
  await page.waitForTimeout(800);

  // Business type dropdown: open + screenshot options.
  const bt = page.getByRole('combobox', { name: /business type/i }).first();
  let btCount = await bt.count().catch(() => 0);
  if (!btCount) { const alt = page.getByText(/choose a business type/i).first(); if (await alt.count().catch(() => 0)) { await alt.click().catch(() => {}); btCount = 1; } }
  else { await bt.click().catch(() => {}); }
  await page.waitForTimeout(1500);
  const optInfo = await dump(page, 'create-03-businesstype-options.json');
  await shot(page, 'create-03-businesstype.png');
  log('business-type options: ' + (optInfo.options || []).join(' | '));

  // Choose a sensible type: prefer Consulting / Professional services / Other.
  const wanted = [/consult/i, /professional/i, /business/i, /other/i, /technology|software|it/i];
  let picked = null;
  for (const re of wanted) {
    const opt = page.getByRole('option', { name: re }).first();
    if (await opt.count().catch(() => 0)) { picked = (await opt.innerText().catch(() => '')) || re.source; await opt.click().catch(() => {}); break; }
  }
  if (!picked) { const anyOpt = page.getByRole('option').first(); if (await anyOpt.count().catch(() => 0)) { picked = await anyOpt.innerText().catch(() => '(first)'); await anyOpt.click().catch(() => {}); } }
  log('picked business type: ' + picked);
  await page.waitForTimeout(1000);
  await shot(page, 'create-04-step1-filled.png');
  const after = await dump(page, 'create-04-step1-filled.json');
  log('step1 buttons now: ' + (after.buttons || []).join(' | '));

  log('PAUSED with step 1 filled (name=Guided AI Labs, type=' + picked + '); NOT submitted yet.');
  await page.waitForTimeout(1500);
  await ctx.close();
})();
