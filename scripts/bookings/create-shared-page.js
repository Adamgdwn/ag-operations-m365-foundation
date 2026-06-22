// Create the SHARED "Guided AI Labs" booking page (classic bookingBusiness) through the
// working Bookings web app in the already-signed-in persistent Edge profile. This is the
// one creation step the Graph API keeps 403-ing; doing it in the web app also provisions
// the tenant Bookings backend. Step-driven + screenshots so each wizard page is verifiable.
//   node scripts/bookings/create-shared-page.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const shot = async (page, n) => { await page.screenshot({ path: path.join(CAP, n), fullPage: true }).catch(() => {}); log('shot ' + n); };
const dumpInputs = async (page, n) => {
  const info = await page.evaluate(() => {
    const q = (sel) => [...document.querySelectorAll(sel)];
    const fields = q('input,textarea,select,[role=combobox],[role=textbox]').map(e => ({
      tag: e.tagName, type: e.type || '', name: e.name || '', id: e.id || '',
      placeholder: e.placeholder || '', aria: e.getAttribute('aria-label') || '',
      role: e.getAttribute('role') || '', value: (e.value || '').slice(0, 60),
    }));
    const buttons = q('button,[role=button],a[role=button]').map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(Boolean);
    return { fields, buttons: [...new Set(buttons)].slice(0, 40), text: (document.body.innerText || '').slice(0, 2500) };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, n), JSON.stringify(info, null, 2));
  return info;
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  log('opening Bookings homepage...');
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(8000);

  // Dismiss the welcome/onboarding modal if present (X button or Escape).
  for (const sel of ['button[aria-label="Close"]', 'button[title="Close"]', '[aria-label="Close dialog"]']) {
    const el = page.locator(sel).first();
    if (await el.count().catch(() => 0)) { await el.click().catch(() => {}); log('closed modal via ' + sel); break; }
  }
  await page.keyboard.press('Escape').catch(() => {});
  await page.waitForTimeout(2000);
  await shot(page, 'create-00-home.png');

  // Click the SHARED "Create booking page" (not the personal "Create meeting type").
  // The shared section header is "Shared booking pages"; its button text is "Create booking page".
  let clicked = false;
  const candidates = page.getByRole('button', { name: /create booking page/i });
  const n = await candidates.count().catch(() => 0);
  log('found ' + n + ' "Create booking page" button(s)');
  // Prefer the LAST one (the shared section sits below the personal section).
  if (n > 0) { await candidates.nth(n - 1).click().catch(async () => { await candidates.first().click().catch(() => {}); }); clicked = true; }
  if (!clicked) {
    const link = page.getByText(/create booking page/i).last();
    if (await link.count().catch(() => 0)) { await link.click().catch(() => {}); clicked = true; }
  }
  log('clicked create booking page: ' + clicked);
  await page.waitForTimeout(6000);
  await shot(page, 'create-01-wizard.png');
  const info = await dumpInputs(page, 'create-01-wizard-fields.json');
  log('wizard buttons: ' + (info.buttons || []).join(' | '));
  log('wizard fields: ' + JSON.stringify((info.fields || []).map(f => f.aria || f.placeholder || f.name || f.id).filter(Boolean)));

  log('PAUSED at wizard step 1 for inspection (no data entered).');
  await page.waitForTimeout(2000);
  await ctx.close();
})();
