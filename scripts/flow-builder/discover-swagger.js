// Read-only: pull the full connector swagger and extract the exact request parameters
// (names, casing, required, enum) for the specific operationIds the sync layer uses, so
// the flow PATCH uses real 'item/...' keys instead of guesses.
//
// Usage: node discover-swagger.js [--headless]
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

const WANT = {
  shared_office365: ['V4CalendarPostItem', 'V3CalendarGetItem', 'V4CalendarPatchItem', 'CalendarDeleteItem_V2', 'CalendarGetTables_V2'],
  shared_sharepointonline: ['HttpRequest', 'PatchItem', 'GetOnNewItems'],
  shared_planner: ['CreateTask_V4', 'UpdateTask_V3', 'DeleteTask', 'GetTask_V2', 'ListBuckets_V3', 'ListGroupPlans', 'AssignUsers'],
  shared_office365users: ['UserProfile_V2'],
  shared_teams: ['PostMessageToConversation', 'GetAllAssociatedTeams', 'GetChannelsForGroup'],
};

// Flatten a swagger parameter (incl. body schema with x-ms-* keys) into leaf descriptors.
function flattenParam(p, prefix, out) {
  const name = p.name || '';
  const full = prefix ? `${prefix}/${name}` : name;
  if (p.in === 'body' && p.schema) { flattenSchema(p.schema, '', out, p.required); return; }
  out.push({ key: full, in: p.in, type: p.type, required: !!p.required, summary: p['x-ms-summary'] || '', enum: p.enum });
}
function flattenSchema(schema, prefix, out, parentRequired) {
  if (!schema) return;
  const req = schema.required || [];
  if (schema.properties) {
    for (const [k, v] of Object.entries(schema.properties)) {
      const full = prefix ? `${prefix}/${k}` : k;
      if (v.type === 'object' && v.properties) { flattenSchema(v, full, out); }
      else { out.push({ key: full, type: v.type, required: req.includes(k), summary: v['x-ms-summary'] || v.description || '', enum: v.enum, visibility: v['x-ms-visibility'] }); }
    }
  }
}

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[FLOWHOST]) { log('ERROR: no FLOWHOST token (session stale).'); await ctx.close(); process.exit(1); }

  const result = {};
  for (const [api, ops] of Object.entries(WANT)) {
    const r = await page.request.get(`https://${FLOWHOST}/providers/Microsoft.PowerApps/apis/${api}?api-version=2016-11-01`, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json' } });
    let swagger = null;
    try { swagger = JSON.parse(await r.text()).properties.swagger; } catch (e) { log(`  ${api}: cannot parse swagger (${e.message})`); continue; }
    fs.writeFileSync(path.join(OUT, `swagger-${api}.json`), JSON.stringify(swagger, null, 2));
    const byOp = {};
    for (const [pth, methods] of Object.entries(swagger.paths || {})) {
      for (const [method, def] of Object.entries(methods)) {
        if (!def || !def.operationId || !ops.includes(def.operationId)) continue;
        const leaves = [];
        for (const p of (def.parameters || [])) flattenParam(p, '', leaves);
        byOp[def.operationId] = { method: method.toUpperCase(), path: pth, summary: def.summary, params: leaves };
      }
    }
    result[api] = byOp;
    for (const op of ops) {
      const d = byOp[op];
      if (!d) { log(`  [${api}] ${op}: NOT FOUND`); continue; }
      log(`=== [${api}] ${op} (${d.method} ${d.path}) ===`);
      for (const pr of d.params) log(`   ${pr.required ? '*' : ' '} ${pr.key}${pr.in ? ' ['+pr.in+']' : ''}${pr.enum ? ' enum='+JSON.stringify(pr.enum) : ''}  ${pr.summary}`);
    }
  }
  fs.writeFileSync(path.join(OUT, 'swagger-extract.json'), JSON.stringify(result, null, 2));
  await ctx.close();
  log('wrote .local/flow-builder/capture/swagger-extract.json + swagger-<api>.json');
})();
