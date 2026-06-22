// Open the CLASSIC Bookings admin (outlook.office.com/bookings) which reliably lists shared
// booking businesses, lets us select "Guided AI Labs", and exposes Booking page / publish /
// who-can-book / public URL. Screenshot + dump nav, business name, and any book.ms URL.
//   node scripts/bookings/open-classic.js
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

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const subBlobs = [];
  ctx.on('response', async (res) => { if (/service\.svc\?action=/i.test(res.url())) { try { subBlobs.push(await res.text()); } catch {} } });

  await page.goto('https://outlook.office.com/bookings/', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(14000);
  await shot(page, 'classic-00.png');
  log('url: ' + page.url());

  const info = await page.evaluate(() => {
    const txt = (e) => (e.innerText || e.getAttribute('aria-label') || '').trim();
    return {
      url: location.href,
      bodyHead: (document.body.innerText || '').slice(0, 1200),
      navItems: [...new Set([...document.querySelectorAll('[role=tab],[role=menuitem],[role=treeitem],nav a,nav button,[role=navigation] button,[role=navigation] a')].map(txt).filter(t => t && t.length < 30))].slice(0, 40),
      hasGAIL: /guided ai labs/i.test(document.body.innerText || ''),
      bookLinks: [...new Set([...document.querySelectorAll('a[href]')].map(a => a.href).filter(h => /book\.ms|bookwithme|selfservice|outlook\.office.*book/i.test(h)))].slice(0, 10),
      buttons: [...new Set([...document.querySelectorAll('button')].map(txt).filter(t => t && t.length < 28))].slice(0, 50),
    };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'classic-info.json'), JSON.stringify(info, null, 2));
  const blob = subBlobs.join('\n');
  const urls = [...blob.matchAll(/https?:\\?\/\\?\/[^"'\s\\]*(?:book\.ms|bookwithme|bookings)[^"'\s\\]*/gi)].map(x => x[0].replace(/\\\//g, '/'));
  fs.writeFileSync(path.join(CAP, 'classic-substrate-urls.json'), JSON.stringify({ bookUrls: [...new Set(urls)].slice(0, 15) }, null, 2));
  log('url: ' + info.url);
  log('hasGAIL: ' + info.hasGAIL);
  log('navItems: ' + (info.navItems || []).join(' | '));
  log('bookLinks: ' + (info.bookLinks || []).join(' | '));
  log('buttons: ' + (info.buttons || []).slice(0, 30).join(' | '));
  await page.waitForTimeout(1500);
  await ctx.close();
})();
