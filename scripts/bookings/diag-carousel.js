// Diagnostic: dump the onboarding carousel's exact DOM — every button in/around the card
// (text, aria-label, title, role, bbox, outerHTML head) plus the card's own outerHTML head.
//   node scripts/bookings/diag-carousel.js
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

  const data = await page.evaluate(() => {
    const re = /hassle free scheduling|share your availability|skip the back and forth/i;
    const visible = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 4 && r.height > 4 && s.visibility !== 'hidden' && s.display !== 'none'; };
    let cards = [...document.querySelectorAll('div,section,aside')].filter(e => visible(e) && re.test(e.innerText || '') && e.querySelector('button'));
    if (!cards.length) return { found: false };
    let card = cards[0]; for (const c of cards) if (card.contains(c)) card = c;
    const cr = card.getBoundingClientRect();
    // all buttons in the whole document that are visible & near/in the card OR at its top-right
    const allBtns = [...document.querySelectorAll('button,[role=button],[aria-label],[title]')].filter(visible);
    const near = allBtns.filter(b => { const r = b.getBoundingClientRect(); return r.top >= cr.top - 30 && r.bottom <= cr.bottom + 30 && r.left >= cr.left - 30 && r.right <= cr.right + 30; });
    const describe = (b) => ({
      tag: b.tagName, text: (b.innerText || '').trim().slice(0, 30), aria: b.getAttribute('aria-label') || '', title: b.getAttribute('title') || '',
      role: b.getAttribute('role') || '', dataIcon: b.getAttribute('data-icon-name') || '',
      bbox: (() => { const r = b.getBoundingClientRect(); return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) }; })(),
      html: b.outerHTML.slice(0, 160),
    });
    return {
      found: true,
      card: { bbox: { x: Math.round(cr.x), y: Math.round(cr.y), w: Math.round(cr.width), h: Math.round(cr.height) }, htmlHead: card.outerHTML.slice(0, 300) },
      buttonsNear: near.map(describe),
      // also: any svg/icon clickable in top-right region of viewport over the card
    };
  }).catch(e => ({ err: e.message }));

  fs.writeFileSync(path.join(CAP, 'diag-carousel.json'), JSON.stringify(data, null, 2));
  log('found=' + data.found + ' buttonsNear=' + ((data.buttonsNear || []).length));
  (data.buttonsNear || []).forEach((b, i) => log(`  [${i}] "${b.text}" aria="${b.aria}" title="${b.title}" icon="${b.dataIcon}" @${b.bbox.x},${b.bbox.y} ${b.bbox.w}x${b.bbox.h}`));
  if (data.card) log('card @ ' + JSON.stringify(data.card.bbox));
  await ctx.close();
})();
