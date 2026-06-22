// Recon ONLY: open the Microsoft Bookings web app in the already-signed-in persistent Edge
// profile, screenshot the landing state, and capture the substrate (outlook.office.com /
// bookings.cloud.microsoft) bearer token + the GetBookingMailboxes response so we can see
// whether a calendar already exists and which create/admin surface is available. NO writes.
//   node scripts/bookings/recon-bookings-web.js
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

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  const tokens = {};
  const substrateCalls = [];
  ctx.on('request', (req) => {
    const url = req.url();
    const auth = req.headers()['authorization'];
    if (auth && auth.startsWith('Bearer ')) {
      try { const host = new URL(url).host; if (!tokens[host]) tokens[host] = auth.slice(7); } catch {}
    }
    if (/service\.svc\?action=/i.test(url)) substrateCalls.push(url.replace(/.*action=/, 'action=').slice(0, 120));
  });

  log('opening Bookings admin (bookings.cloud.microsoft)...');
  await page.goto('https://bookings.cloud.microsoft/', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav1: ' + e.message));
  await page.waitForTimeout(9000);
  await page.screenshot({ path: path.join(CAP, 'recon-01-landing.png'), fullPage: true }).catch(() => {});
  log('url after landing: ' + page.url());

  // Try the classic OWA bookings entry as a fallback view
  const bodyText = await page.evaluate(() => document.body ? document.body.innerText.slice(0, 4000) : '').catch(() => '');
  fs.writeFileSync(path.join(CAP, 'recon-01-bodytext.txt'), bodyText);

  await page.waitForTimeout(4000);
  await page.screenshot({ path: path.join(CAP, 'recon-02-settled.png'), fullPage: true }).catch(() => {});

  fs.writeFileSync(path.join(CAP, 'recon-tokens-hosts.json'), JSON.stringify({ hosts: Object.keys(tokens), substrateCalls: [...new Set(substrateCalls)] }, null, 2));
  // Persist the substrate token (host outlook.office.com or substrate) for later API replay
  const substrateHost = Object.keys(tokens).find(h => /outlook\.office|substrate|bookings\.cloud/i.test(h));
  if (substrateHost) fs.writeFileSync(path.join(CAP, 'recon-substrate-token.txt'), tokens[substrateHost]);
  log('token hosts captured: ' + Object.keys(tokens).join(', '));
  log('substrate actions seen: ' + [...new Set(substrateCalls)].join(', '));
  log('screenshots + bodytext in .local/bookings-builder/capture/');
  await ctx.close();
})();
