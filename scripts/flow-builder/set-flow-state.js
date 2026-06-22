// Turn a Power Automate flow ON or OFF (reversible — does NOT delete it).
// Uses the persisted Edge profile to capture a FLOWHOST bearer token, then POSTs
// the flow's /start or /stop management action.
// Usage: node set-flow-state.js <flowId> <start|stop> [--headless]
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const FLOWHOST = 'api.flow.microsoft.com';

const flowId = process.argv[2];
const action = (process.argv[3] || '').toLowerCase();
const headless = process.argv.includes('--headless');
if (!flowId || !['start', 'stop'].includes(action)) { log('usage: node set-flow-state.js <flowId> <start|stop> [--headless]'); process.exit(2); }

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[FLOWHOST]) { log('FATAL: no FLOWHOST token captured'); await ctx.close(); process.exit(1); }
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowId}`;
  // Read current state first.
  const g = await page.request.get(`${base}?api-version=2016-11-01`, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json' } });
  let cur = '(unknown)', name = '(unknown)';
  try { const j = JSON.parse(await g.text()); cur = j.properties && j.properties.state; name = j.properties && j.properties.displayName; } catch {}
  log(`flow "${name}" current state=${cur}`);
  const r = await page.request.post(`${base}/${action}?api-version=2016-11-01`, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json', 'content-type': 'application/json' }, data: '{}' });
  log(`  ${action} -> ${r.status()}${r.status() >= 300 ? ' ' + (await r.text()).slice(0, 200) : ''}`);
  await page.waitForTimeout(2500);
  const g2 = await page.request.get(`${base}?api-version=2016-11-01`, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json' } });
  try { log(`  new state=${JSON.parse(await g2.text()).properties.state}`); } catch {}
  await ctx.close();
})();
