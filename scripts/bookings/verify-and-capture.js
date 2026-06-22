// Verify the "Guided AI Labs" shared booking page exists and capture its identity by reading
// the substrate responses the web app itself makes (GetBookingMailboxes / GetBookingServices),
// plus screenshot the homepage Shared-booking-pages section. No Graph, no writes.
//   node scripts/bookings/verify-and-capture.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  const captures = {};
  let bearer = null;
  ctx.on('request', (req) => { const a = req.headers()['authorization']; if (a && a.startsWith('Bearer ') && /bookings\.cloud\.microsoft/.test(req.url()) && !bearer) bearer = a.slice(7); });
  ctx.on('response', async (res) => {
    const url = res.url();
    const m = url.match(/action=(GetBookingMailboxes|GetBookingServices|GetStaff|GetBookingBusiness)/i);
    if (m) { try { const body = await res.text(); captures[m[1]] = (captures[m[1]] || []); captures[m[1]].push(body.slice(0, 8000)); } catch {} }
  });

  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(12000);
  // Dismiss any teaching popups so the screenshot is clean.
  await page.evaluate(() => { for (const b of document.querySelectorAll('button[aria-label="Dismiss"],button[aria-label="Close"]')) try { b.click(); } catch {} }).catch(() => {});
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(CAP, 'verify-home.png'), fullPage: true }).catch(() => {});

  // Pull the shared booking pages list text from the page.
  const sharedText = await page.evaluate(() => {
    const all = [...document.querySelectorAll('*')];
    const h = all.find(e => /shared booking pages/i.test((e.innerText || '').slice(0, 40)) && (e.tagName === 'H2' || e.tagName === 'H3'));
    return document.body.innerText.slice(0, 2500);
  }).catch(() => '');
  fs.writeFileSync(path.join(CAP, 'verify-home-text.txt'), sharedText);

  fs.writeFileSync(path.join(CAP, 'verify-substrate.json'), JSON.stringify({ hasBearer: !!bearer, captures }, null, 2));
  if (bearer) fs.writeFileSync(path.join(CAP, 'substrate-token.txt'), bearer);

  // Parse mailbox list for the GAIL business.
  let summary = { found: false };
  try {
    const mb = (captures.GetBookingMailboxes || []).join('\n');
    fs.writeFileSync(path.join(CAP, 'GetBookingMailboxes.json'), mb);
    const smtps = [...mb.matchAll(/"SmtpAddress"\s*:\s*"([^"]+)"/gi)].map(x => x[1]);
    const names = [...mb.matchAll(/"DisplayName"\s*:\s*"([^"]+)"/gi)].map(x => x[1]);
    summary = { found: /guided ai labs/i.test(mb), smtps: [...new Set(smtps)], names: [...new Set(names)] };
  } catch (e) { summary.err = e.message; }
  fs.writeFileSync(path.join(OUT, 'bookings-verify.json'), JSON.stringify(summary, null, 2));
  log('GAIL present in mailboxes? ' + summary.found);
  log('mailbox SMTPs: ' + JSON.stringify(summary.smtps || []));
  log('mailbox names: ' + JSON.stringify(summary.names || []));
  log('captured actions: ' + Object.keys(captures).join(', '));
  await ctx.close();
})();
