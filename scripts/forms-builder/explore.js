// Headless explorer: reuse the authed profile, map the Forms create path.
// No visible window (Adam already signed in; cookies persist in the profile).
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build', 'explore');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const DUMP = () => {
  const sel = 'button, a, [role="button"], [role="link"], [role="menuitem"], [role="tab"], [role="option"], [aria-label], [title]';
  const out = [];
  document.querySelectorAll(sel).forEach(el => {
    const r = el.getBoundingClientRect();
    const cs = getComputedStyle(el);
    const visible = r.width > 1 && r.height > 1 && cs.visibility !== 'hidden' && cs.display !== 'none';
    const t = (el.innerText || el.getAttribute('aria-label') || el.getAttribute('title') || '').trim().replace(/\s+/g, ' ').slice(0, 90);
    if (t) out.push(`${visible ? 'V' : 'h'} <${el.tagName.toLowerCase()}${el.getAttribute('role') ? ' role=' + el.getAttribute('role') : ''}> ${t}`);
  });
  return [...new Set(out)].slice(0, 500).join('\n');
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1536, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const steps = [
    { tag: 'v1blank', url: 'https://forms.office.com/Pages/DesignPage.aspx' },
    { tag: 'scenario', url: 'https://forms.office.com/', clickText: 'Workflow Solution' },
  ];
  for (const step of steps) {
    const { tag, url, clickText } = step;
    try {
      log(`goto ${tag} ${url}`);
      await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 }).catch(e => log('nav warn: ' + e.message.split('\n')[0]));
      await page.waitForTimeout(4000);
      if (clickText) {
        try {
          await page.getByText(clickText, { exact: false }).first().click({ timeout: 6000 });
          log(`clicked "${clickText}"`);
          await page.waitForTimeout(5000);
        } catch (e) { log(`click warn: ` + e.message.split('\n')[0]); }
      }
      await page.mouse.wheel(0, 1200).catch(() => {});
      await page.waitForTimeout(1500);
      await page.screenshot({ path: path.join(OUT, `${tag}.png`), fullPage: true }).catch(() => {});
      const dump = await page.evaluate(DUMP).catch(e => 'DUMP ERROR ' + e.message);
      const text = await page.evaluate(() => document.body.innerText.replace(/\n{2,}/g, '\n').slice(0, 3000)).catch(() => '');
      fs.writeFileSync(path.join(OUT, `${tag}.txt`), `URL: ${page.url()}\n\n=== INTERACTIVE ===\n${dump}\n\n=== BODY TEXT ===\n${text}`);
      log(`dumped ${tag} -> ${tag}.txt / ${tag}.png  (final ${page.url()})`);
    } catch (e) { log(`ERR ${tag}: ` + e.message.split('\n')[0]); }
  }
  await ctx.close();
  log('explore done');
})();
