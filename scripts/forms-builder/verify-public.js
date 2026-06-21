// Anonymous render check: load the public form URL in a CLEAN browser (no
// profile, no cookies) to prove a signed-out visitor can fill it out.
const fs = require('fs');
const path = require('path');
const os = require('os');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }
const REPO = path.resolve(__dirname, '..', '..');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const result = JSON.parse(fs.readFileSync(path.join(OUT, `result-${(process.argv.find(a=>a.startsWith('--brand='))||'=labs').split('=')[1]}.json`), 'utf8'));
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

(async () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'forms-anon-'));
  const ctx = await chromium.launchPersistentContext(tmp, { channel: 'msedge', headless: true, viewport: { width: 1200, height: 1000 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  log(`anon load: ${result.publicUrl}`);
  await page.goto(result.publicUrl, { waitUntil: 'networkidle', timeout: 45000 }).catch(e => log('nav warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(5000);
  await page.screenshot({ path: path.join(OUT, `public-render-${result.brand.replace(/\s+/g,'-')}.png`), fullPage: true }).catch(() => {});
  const body = await page.evaluate(() => document.body.innerText.slice(0, 1500)).catch(() => '');
  const url = page.url();
  const signInWall = /sign in|login\.microsoftonline|enter your email|to continue/i.test(body) && !/Get started/i.test(body);
  const showsForm = /Full name|What are you looking for|Get started/i.test(body);
  log(`final url: ${url}`);
  log(`showsForm=${showsForm} signInWall=${signInWall}`);
  fs.writeFileSync(path.join(OUT, 'public-render-body.txt'), `url: ${url}\nshowsForm: ${showsForm}\nsignInWall: ${signInWall}\n\n${body}`);
  await ctx.close();
  try { fs.rmSync(tmp, { recursive: true, force: true }); } catch {}
  log('done');
})();
