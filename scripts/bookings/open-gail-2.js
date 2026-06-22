// Robust attempt to open the "Guided AI Labs" shared page editor: longer settle for backend
// provisioning, find any clickable element whose text contains "Guided AI Labs" in the Shared
// section, click it, capture the editor URL + booking-page (book.ms) URL + services + settings.
//   node scripts/bookings/open-gail-2.js
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

  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(18000); // let provisioning + tile render settle
  await page.evaluate(() => { for (const b of document.querySelectorAll('button[aria-label="Dismiss"],button[aria-label="Close"]')) try { b.click(); } catch {} }).catch(() => {});
  await page.waitForTimeout(2500);
  await shot(page, 'g2-00-home.png');

  // Find a clickable element whose text contains "Guided AI Labs" (excluding the personal page header).
  const clicked = await page.evaluate(() => {
    const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
    // candidate clickables (tiles are role=button divs)
    const cands = [...document.querySelectorAll('[role=button],button,a,[tabindex]')].filter(e => vis(e) && /guided ai labs/i.test((e.innerText || '').slice(0, 60)));
    // exclude the big page header "Welcome..." and prefer one inside the lower (shared) area
    const tiles = cands.filter(e => e.getBoundingClientRect().top > 230).sort((a, b) => a.getBoundingClientRect().top - b.getBoundingClientRect().top);
    const t = tiles[0] || cands[0];
    if (t) { t.click(); return (t.innerText || '').slice(0, 40); }
    return null;
  }).catch(() => null);
  log('clicked GAIL clickable: ' + JSON.stringify(clicked));
  await page.waitForTimeout(8000);
  await shot(page, 'g2-01-editor.png');
  log('url after open: ' + page.url());

  const info = await page.evaluate(() => {
    const txt = (e) => (e.innerText || e.getAttribute('aria-label') || '').trim();
    return {
      url: location.href,
      headings: [...document.querySelectorAll('h1,h2,h3')].map(txt).filter(Boolean).slice(0, 12),
      tabs: [...new Set([...document.querySelectorAll('[role=tab],[role=menuitem],[role=treeitem]')].map(txt).filter(t => t && t.length < 30))].slice(0, 30),
      bookLinks: [...new Set([...document.querySelectorAll('a[href]')].map(a => a.href).filter(h => /book\.ms|outlook\.office.*book|selfservice/i.test(h)))].slice(0, 10),
      buttons: [...new Set([...document.querySelectorAll('button')].map(txt).filter(t => t && t.length < 28))].slice(0, 50),
    };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'g2-editor-info.json'), JSON.stringify(info, null, 2));

  const blob = subBlobs.join('\n');
  const urls = [...blob.matchAll(/https?:\\?\/\\?\/[^"'\s\\]*book[^"'\s\\]*/gi)].map(x => x[0].replace(/\\\//g, '/'));
  fs.writeFileSync(path.join(CAP, 'g2-substrate-urls.json'), JSON.stringify({ bookUrls: [...new Set(urls)].slice(0, 12) }, null, 2));
  log('editor url: ' + info.url);
  log('headings: ' + (info.headings || []).join(' | '));
  log('tabs: ' + (info.tabs || []).join(' | '));
  log('bookLinks: ' + (info.bookLinks || []).join(' | '));
  log('substrate book URLs: ' + JSON.stringify([...new Set(urls)].slice(0, 8)));
  await page.waitForTimeout(1500);
  await ctx.close();
})();
