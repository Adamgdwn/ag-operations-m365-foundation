// Drive the full 4-step "Create a new shared booking page" wizard to create the GAIL page:
//   Step 1: Name="Guided AI Labs", Business type="Other", hours=default (Mon-Fri 9-5).
//   Step 2: Invite staff — creator (Adam) auto-added as Administrator; dismiss autocomplete, no extra staff.
//   Step 3/4: accept sensible defaults; click the terminal Create/Finish.
// Screenshots + a fields/buttons dump at every step. Step tracked via "Step X of 4".
//   node scripts/bookings/create-wizard-run.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const shot = async (page, n) => { await page.screenshot({ path: path.join(CAP, n), fullPage: true }).catch(() => {}); log('shot ' + n); };
const NAME_SEL = 'input[aria-label="Give your booking page a name"]';

const dismissTeachers = async (page) => page.evaluate(() => {
  const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
  let c = 0; for (const b of [...document.querySelectorAll('button[aria-label="Dismiss"], button[aria-label="Close"], button[title="Close"]')].filter(vis)) { b.click(); c++; } return c;
});
const getStep = async (page) => page.evaluate(() => { const m = (document.body.innerText || '').match(/Step\s+(\d)\s+of\s+(\d)/i); return m ? +m[1] : 0; }).catch(() => 0);
const dump = async (page, n) => {
  const info = await page.evaluate(() => ({
    headings: [...document.querySelectorAll('h1,h2,h3')].map(h => (h.innerText || '').trim()).filter(Boolean).slice(0, 8),
    fields: [...document.querySelectorAll('input,textarea,[role=combobox]')].map(e => ({ aria: e.getAttribute('aria-label') || '', ph: e.placeholder || '', val: (e.value || '').slice(0, 40) })).filter(f => f.aria || f.ph),
    buttons: [...new Set([...document.querySelectorAll('button')].map(e => (e.innerText || e.getAttribute('aria-label') || '').trim()).filter(t => t && t.length > 0 && t.length < 30))].slice(0, 45),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, n), JSON.stringify(info, null, 2));
  return info;
};
// Click the BOTTOMMOST visible enabled button matching re. The wizard's footer button is
// always the lowest on screen; the homepage's "Create booking page" sits higher, so the
// bottommost match is reliably the wizard primary (no fragile modal scoping needed).
const clickPrimary = async (page, re) => page.evaluate((reStr) => {
  const re = new RegExp(reStr, 'i');
  const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none' && !e.disabled && e.getAttribute('aria-disabled') !== 'true'; };
  const btns = [...document.querySelectorAll('button')].filter(vis).filter(b => re.test((b.innerText || b.getAttribute('aria-label') || '').trim()));
  if (!btns.length) return 'none';
  btns.sort((a, b) => b.getBoundingClientRect().bottom - a.getBoundingClientRect().bottom); // bottommost first
  btns[0].click();
  return 'clicked:' + (btns[0].innerText || btns[0].getAttribute('aria-label') || '').trim();
}, re.source).catch(e => 'ERR:' + e.message);

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  for (let i = 0; i < 10; i++) { await page.waitForTimeout(1700); const c = await dismissTeachers(page).catch(() => 0); if (c) log('home dismiss: ' + c); }
  await shot(page, 'wz-00-home.png');

  // Open shared wizard.
  const cands = page.getByRole('button', { name: /create booking page/i });
  const n = await cands.count().catch(() => 0);
  if (n > 0) await cands.nth(n - 1).click().catch(() => {});
  // wait for name field
  let ready = false;
  for (let i = 0; i < 18; i++) { if (await page.locator(NAME_SEL).first().isVisible().catch(() => false)) { ready = true; break; } await dismissTeachers(page).catch(() => {}); await page.waitForTimeout(1200); }
  log('wizard open? ' + ready);
  if (!ready) { await shot(page, 'wz-ERR-noopen.png'); await ctx.close(); return; }

  // ---- STEP 1 ----
  const nameLoc = page.locator(NAME_SEL).first();
  await nameLoc.click().catch(() => {}); await nameLoc.fill('Guided AI Labs').catch(() => {});
  const bt = page.locator('[aria-label="Choose a business type"]').first();
  if (await bt.count().catch(() => 0)) { await bt.click().catch(() => {}); await page.waitForTimeout(1200); const o = page.getByRole('option', { name: /^Other$/i }).first(); if (await o.count().catch(() => 0)) { await o.click().catch(() => {}); log('business type=Other'); } }
  await page.waitForTimeout(700);
  await dump(page, 'wz-s1.json'); await shot(page, 'wz-s1.png');
  let r = await clickPrimary(page, /^next$/i); log('step1 next: ' + r);
  await page.waitForTimeout(3000);

  // ---- STEP 2..4 loop ----
  for (let guard = 0; guard < 6; guard++) {
    const step = await getStep(page);
    const info = await dump(page, `wz-step${step}.json`);
    await shot(page, `wz-step${step}.png`);
    log(`now at step ${step}; headings: ${(info.headings || []).join(' | ')}`);
    log(`  buttons: ${(info.buttons || []).join(' | ')}`);

    if (step === 0) { log('no step indicator — wizard likely closed (created) or different view.'); break; }

    // NOTE: do NOT press Escape here — on non-dropdown steps it closes the whole wizard.
    // Unselected staff autocomplete suggestions are never added, so no dismissal is needed.
    let res;
    if (step >= 4) {
      // Final step: click the terminal button (modal-scoped).
      res = await clickPrimary(page, /^(create|finish|add booking page|create booking page|done|save|publish|got it)$/i);
      if (res === 'none') res = await clickPrimary(page, /^next$/i);
      log(`  terminal advance: ${res}`);
      await page.waitForTimeout(5000); await shot(page, 'wz-after-terminal.png');
      break;
    }
    // Steps 1-3: Next only (modal-scoped, so homepage buttons are never hit).
    res = await clickPrimary(page, /^next$/i);
    log(`  next: ${res}`);
    if (res === 'none') { log('  no Next in modal — breaking.'); break; }
    await page.waitForTimeout(3000);
  }

  // ---- WAIT for "Setting up your booking page" to fully complete (do NOT close early!) ----
  // Poll until the setting-up text disappears AND we land in an editor/calendar view, or 120s.
  const subBlobs = [];
  ctx.on('response', async (res) => { if (/service\.svc\?action=/i.test(res.url())) { try { subBlobs.push(await res.text()); } catch {} } });
  let settled = false;
  for (let i = 0; i < 40; i++) {
    const st = await page.evaluate(() => ({
      settingUp: /setting up your booking page/i.test(document.body.innerText || ''),
      url: location.href,
      hasEditorNav: /\b(Calendar|Booking page|Customers|Staff|Services|Business information)\b/.test(document.body.innerText || ''),
    })).catch(() => ({}));
    if (i % 4 === 0) log(`setup poll #${i}: settingUp=${st.settingUp} url=${st.url}`);
    if (!st.settingUp && (st.hasEditorNav || /calendar|services|businessinformation|bookingpage/i.test(st.url || ''))) { settled = true; break; }
    await page.waitForTimeout(3000);
  }
  log('setup settled into editor? ' + settled);
  await page.waitForTimeout(3000);
  await shot(page, 'wz-99-final.png');

  const finalState = await page.evaluate(() => {
    const txt = (e) => (e.innerText || e.getAttribute('aria-label') || '').trim();
    return {
      url: location.href,
      headings: [...document.querySelectorAll('h1,h2,h3')].map(txt).filter(Boolean).slice(0, 12),
      navItems: [...new Set([...document.querySelectorAll('[role=tab],[role=menuitem],[role=treeitem],nav a,nav button')].map(txt).filter(t => t && t.length < 30))].slice(0, 40),
      bookLinks: [...new Set([...document.querySelectorAll('a[href]')].map(a => a.href).filter(h => /book\.ms|bookwithme|selfservice/i.test(h)))].slice(0, 10),
      buttons: [...new Set([...document.querySelectorAll('button')].map(txt).filter(t => t && t.length < 28))].slice(0, 50),
      text: (document.body.innerText || '').slice(0, 1500),
    };
  }).catch(e => ({ err: e.message }));
  const blob = subBlobs.join('\n');
  const urls = [...blob.matchAll(/https?:\\?\/\\?\/[^"'\s\\]*(?:book\.ms|bookwithme)[^"'\s\\]*/gi)].map(x => x[0].replace(/\\\//g, '/'));
  finalState.substrateBookUrls = [...new Set(urls)].slice(0, 10);
  finalState.settled = settled;
  fs.writeFileSync(path.join(OUT, 'bookings-wizard-result.json'), JSON.stringify(finalState, null, 2));
  log('final url: ' + finalState.url);
  log('final headings: ' + (finalState.headings || []).join(' | '));
  log('nav items: ' + (finalState.navItems || []).join(' | '));
  log('book links: ' + (finalState.bookLinks || []).join(' | '));
  log('substrate book URLs: ' + JSON.stringify(finalState.substrateBookUrls));
  await page.waitForTimeout(2000);
  await ctx.close();
})();
