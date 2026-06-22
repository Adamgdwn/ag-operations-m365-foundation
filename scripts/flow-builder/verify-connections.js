// Quick read-only check: connect to the warm Edge over CDP and list the
// environment's connections, confirming the named apis are present + Connected.
// Usage: node verify-connections.js [shared_planner shared_office365users ...]
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const want = process.argv.slice(2).length ? process.argv.slice(2) : ['shared_planner', 'shared_office365users'];

(async () => {
  const CDP_PORT = process.env.CDP_PORT || '9222';
  const browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
  const ctx = browser.contexts()[0] || await browser.newContext();
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(7000);
  if (!tokens[EHOST]) { log('no EHOST token captured yet; waiting a bit more'); await page.waitForTimeout(6000); }
  const r = await page.request.get(`https://${EHOST}/connectivity/connections?api-version=1`, { headers: { authorization: 'Bearer ' + tokens[EHOST], accept: 'application/json' } });
  let conns = [];
  try { conns = JSON.parse(await r.text()).value || []; } catch { log('list parse failed: ' + (await r.text()).slice(0, 200)); }
  log(`total connections: ${conns.length}`);
  for (const api of want) {
    const matches = conns.filter(c => ((c.properties && c.properties.apiId) || '').includes(api));
    if (!matches.length) { log(`  ${api}: NOT PRESENT`); continue; }
    for (const m of matches) {
      const st = (m.properties.statuses || []).map(s => s.status).join(',');
      log(`  ${api}: ${m.properties.displayName} -> ${st} (${m.name})`);
    }
  }
})();
