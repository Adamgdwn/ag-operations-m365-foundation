// Recon the Microsoft Bookings Power Automate connector: fetch its swagger to extract the
// trigger + action operationIds and their parameters (esp. the booking-business SMTP param),
// and check whether a shared_microsoftbookings CONNECTION already exists (consent done?).
//   node scripts/flow-builder/recon-bookings-connector.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const FLOWHOST = 'api.flow.microsoft.com';

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[FLOWHOST]) { log('ERROR: no FLOW token'); await ctx.close(); process.exit(1); }
  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };

  // 1) existing connections — is a Bookings connection already present?
  if (tokens[EHOST]) {
    const cl = JSON.parse((await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`)).body);
    const conns = (cl.value || []).map(c => ({ name: c.name, api: (c.properties && c.properties.apiId || '').split('/').pop(), status: c.properties && c.properties.statuses && c.properties.statuses.map(s => s.status).join(',') }));
    fs.writeFileSync(path.join(CAP, 'connections-list.json'), JSON.stringify(conns, null, 2));
    const bk = conns.filter(c => /booking/i.test(c.api));
    log('Bookings connection(s): ' + JSON.stringify(bk));
    log('all connection apis: ' + conns.map(c => c.api).join(', '));
  }

  // 2) connector swagger
  const apiUrl = `https://${FLOWHOST}/providers/Microsoft.PowerApps/apis/shared_microsoftbookings?api-version=2016-11-01&$expand=properties/connectionParameters,properties/apiDefinitions`;
  const api = await get(FLOWHOST, apiUrl);
  fs.writeFileSync(path.join(CAP, 'bookings-connector-api.json'), api.body);
  log('connector api -> ' + api.status);
  let swaggerUrl = null;
  try { const j = JSON.parse(api.body); swaggerUrl = j.properties && j.properties.apiDefinitions && j.properties.apiDefinitions.originalSwaggerUrl; } catch {}
  log('swaggerUrl: ' + swaggerUrl);
  if (swaggerUrl) {
    const sw = await page.request.get(swaggerUrl).catch(() => null);
    if (sw) {
      const body = await sw.text();
      fs.writeFileSync(path.join(CAP, 'bookings-swagger.json'), body);
      try {
        const s = JSON.parse(body);
        const ops = [];
        for (const p of Object.keys(s.paths || {})) {
          for (const m of Object.keys(s.paths[p])) {
            const o = s.paths[p][m];
            if (!o.operationId) continue;
            ops.push({ operationId: o.operationId, method: m, path: p, summary: o.summary || '', isTrigger: !!(o['x-ms-trigger']), params: (o.parameters || []).map(pa => ({ name: pa.name, in: pa.in, required: pa.required, type: pa.type })) });
          }
        }
        fs.writeFileSync(path.join(CAP, 'bookings-operations.json'), JSON.stringify(ops, null, 2));
        log('--- TRIGGERS ---');
        ops.filter(o => o.isTrigger).forEach(o => log(`  ${o.operationId} (${o.summary}) params: ${o.params.map(p => p.name + (p.required ? '*' : '')).join(',')}`));
        log('--- ACTIONS (appointment-related) ---');
        ops.filter(o => !o.isTrigger && /appoint|booking/i.test(o.operationId + o.summary)).forEach(o => log(`  ${o.operationId} (${o.summary}) params: ${o.params.map(p => p.name + (p.required ? '*' : '')).join(',')}`));
      } catch (e) { log('swagger parse err: ' + e.message); }
    }
  }
  await ctx.close();
})();
