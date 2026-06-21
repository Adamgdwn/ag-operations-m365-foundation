// Read-only discovery of exact connector operationIds, so the engine PATCH references
// real operations (a wrong operationId fails the flow create). Lists apiOperations for
// the Office 365 Outlook + SharePoint connectors and dumps name+summary, highlighting
// the calendar/event + HTTP-request operations the sync layer needs.
//
// Usage: node discover-operations.js [--headless]
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, '.local', 'flow-builder', 'capture');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const FLOWHOST = 'api.flow.microsoft.com';
const headless = process.argv.includes('--headless');

const CONNECTORS = ['shared_office365', 'shared_sharepointonline', 'shared_planner', 'shared_office365users'];
const INTEREST = /event|calendar|httprequest|http request|send an http|patch|update item|get item|create item|task|plan|bucket|user profile/i;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[FLOWHOST]) { log('ERROR: no FLOWHOST token (session stale). Run Start-FlowBuilder.ps1 -Phase auth in a visible window first.'); await ctx.close(); process.exit(1); }

  const summary = {};
  for (const api of CONNECTORS) {
    const url = `https://${FLOWHOST}/providers/Microsoft.PowerApps/apis/${api}/apiOperations?api-version=2016-11-01`;
    const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json' } });
    let ops = [];
    try { ops = (JSON.parse(await r.text()).value) || []; } catch { ops = []; }
    const mapped = ops.map(o => ({ name: o.name, summary: (o.properties && o.properties.summary) || '', visibility: (o.properties && o.properties.visibility) || '' }));
    fs.writeFileSync(path.join(OUT, `ops-${api}.json`), JSON.stringify(mapped, null, 2));
    const hits = mapped.filter(o => INTEREST.test(o.name + ' ' + o.summary));
    summary[api] = { total: mapped.length, status: r.status(), hits };
    log(`=== ${api}: ${mapped.length} ops (HTTP ${r.status()}) — ${hits.length} of interest ===`);
    for (const h of hits) log(`   ${h.name}  ::  ${h.summary}`);
  }
  fs.writeFileSync(path.join(OUT, 'ops-summary.json'), JSON.stringify(summary, null, 2));
  await ctx.close();
  log('wrote .local/flow-builder/capture/ops-*.json');
})();
