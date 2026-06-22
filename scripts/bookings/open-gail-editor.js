// Open the "Guided AI Labs" shared booking page editor from the homepage, screenshot it,
// capture substrate responses (booking page URL / business / services), and dump the editor
// navigation + any "self-service page" link so we can find the publish/who-can-book controls.
//   node scripts/bookings/open-gail-editor.js
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
  const subResp = {};
  ctx.on('response', async (res) => { const m = res.url().match(/action=(\w+)/); if (m && /Booking|Staff|Service|Page|SelfService/i.test(m[1])) { try { subResp[m[1]] = (subResp[m[1]] || ''); subResp[m[1]] += '\n' + (await res.text()).slice(0, 6000); } catch {} } });

  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(12000);
  await page.evaluate(() => { for (const b of document.querySelectorAll('button[aria-label="Dismiss"],button[aria-label="Close"]')) try { b.click(); } catch {} }).catch(() => {});
  await page.waitForTimeout(2000);
  await shot(page, 'ed-00-home.png');

  // Click the "Guided AI Labs" shared booking page tile/link.
  let opened = false;
  const byText = page.getByText(/^Guided AI Labs$/).first();
  if (await byText.count().catch(() => 0)) { await byText.click().catch(() => {}); opened = true; log('clicked GAIL by text'); }
  if (!opened) {
    const tile = page.getByRole('button', { name: /guided ai labs/i }).first();
    if (await tile.count().catch(() => 0)) { await tile.click().catch(() => {}); opened = true; log('clicked GAIL tile'); }
  }
  await page.waitForTimeout(7000);
  await shot(page, 'ed-01-editor.png');
  log('url after open: ' + page.url());

  // Dump editor navigation + any book.ms / self-service links.
  const nav = await page.evaluate(() => {
    const txt = (e) => (e.innerText || e.getAttribute('aria-label') || '').trim();
    const navItems = [...document.querySelectorAll('[role=tab],[role=menuitem],nav a,nav button,[role=navigation] *')].map(txt).filter(t => t && t.length < 30);
    const links = [...document.querySelectorAll('a[href]')].map(a => a.href).filter(h => /book\.ms|bookings|selfservice|outlook\.office/i.test(h));
    const buttons = [...document.querySelectorAll('button')].map(txt).filter(t => t && t.length < 30);
    return { navItems: [...new Set(navItems)].slice(0, 40), links: [...new Set(links)].slice(0, 20), buttons: [...new Set(buttons)].slice(0, 50) };
  }).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'ed-nav.json'), JSON.stringify(nav, null, 2));
  // Search substrate responses for a public booking URL.
  const blob = Object.values(subResp).join('\n');
  const urls = [...blob.matchAll(/https?:\/\/[^"'\s]*book[^"'\s]*/gi)].map(x => x[0]);
  fs.writeFileSync(path.join(CAP, 'ed-substrate.json'), JSON.stringify({ actions: Object.keys(subResp), bookUrls: [...new Set(urls)].slice(0, 10) }, null, 2));
  log('nav items: ' + (nav.navItems || []).join(' | '));
  log('links: ' + (nav.links || []).join(' | '));
  log('substrate actions: ' + Object.keys(subResp).join(', '));
  log('book URLs in substrate: ' + JSON.stringify([...new Set(urls)].slice(0, 6)));
  await page.waitForTimeout(1500);
  await ctx.close();
})();
