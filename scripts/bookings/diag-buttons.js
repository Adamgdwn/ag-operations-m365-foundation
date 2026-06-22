// Diagnostic: enumerate EVERY visible clickable in the viewport with bbox + aria + html,
// so we can identify the carousel close (×) by geometry (top-right of the centered modal).
//   node scripts/bookings/diag-buttons.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }
const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto('https://bookings.cloud.microsoft/bookings/homepage', { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await page.waitForTimeout(13000);

  const btns = await page.evaluate(() => {
    const visible = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none' && r.top < innerHeight && r.left < innerWidth && r.bottom > 0 && r.right > 0; };
    return [...document.querySelectorAll('button,[role=button],a[role=button],i[role=button],span[role=button]')].filter(visible).map(b => {
      const r = b.getBoundingClientRect();
      return { text: (b.innerText || '').trim().slice(0, 25), aria: b.getAttribute('aria-label') || '', title: b.getAttribute('title') || '', icon: b.getAttribute('data-icon-name') || '', cx: Math.round(r.x + r.width / 2), cy: Math.round(r.y + r.height / 2), w: Math.round(r.width), h: Math.round(r.height), html: b.outerHTML.slice(0, 130) };
    }).sort((a, b) => a.cy - b.cy || a.cx - b.cx);
  }).catch(e => [{ err: e.message }]);

  fs.writeFileSync(path.join(CAP, 'diag-buttons.json'), JSON.stringify(btns, null, 2));
  log('total visible buttons: ' + btns.length);
  // Focus on the centered-modal region: x in [340,1070], y in [120,860]
  const inModal = btns.filter(b => b.cx > 320 && b.cx < 1090 && b.cy > 110 && b.cy < 870);
  log('--- buttons inside centered-modal region ---');
  inModal.forEach((b, i) => log(`  "${b.text || b.aria || b.title || b.icon || '(icon)'}" @${b.cx},${b.cy} ${b.w}x${b.h} | html: ${b.html}`));
  await ctx.close();
})();
