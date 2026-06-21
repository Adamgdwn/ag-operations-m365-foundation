// Learn the flow-definition + connectionReferences shape by fetching a public
// template whose pattern matches ours (Microsoft Forms -> SharePoint Create item).
// Also dump the SharePoint + Forms connector swagger operationIds we need for the
// trigger ("When a new response is submitted"), "Get response details", and
// "Create item". Read-only. Output to .local for building create-flow.js.
//
// Usage: node probe-template.js
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
const THOST = '1ca92af521ff42e387ae3bde9c2cc5.01.tenant.api.powerplatform.com';

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(8000);
  const tok = (h) => tokens[h] || tokens[EHOST] || tokens['api.flow.microsoft.com'] || Object.values(tokens)[0];
  const get = async (url) => { const h = new URL(url).host; const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tok(h), accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };

  // 1) Search templates for a Forms -> SharePoint pattern, expand definitions.
  const tUrl = `https://${THOST}/powerautomate/galleries/public/templates?$filter=${encodeURIComponent("properties/categoryNames/all(x:x ne 'designerUnsupported')")}&$expand=definition,connectionReferences.api.properties&$top=200&api-version=1&search=${encodeURIComponent('forms sharepoint')}`;
  let t = await get(tUrl).catch(e => ({ status: -1, body: e.message }));
  log(`templates search -> ${t.status}`);
  fs.writeFileSync(path.join(CAP, 'templates-raw.json'), t.body.slice(0, 1500000));
  let matches = [];
  try {
    const j = JSON.parse(t.body);
    for (const tmpl of (j.value || [])) {
      const refs = tmpl.properties && tmpl.properties.connectionReferences || {};
      const apis = Object.values(refs).map(r => (r.api && r.api.name) || '').join(',');
      if (/microsoftforms/i.test(apis) && /sharepointonline/i.test(apis)) {
        matches.push({ name: tmpl.name, title: tmpl.properties && tmpl.properties.title, apis, hasDef: !!(tmpl.properties && tmpl.properties.definition) });
      }
    }
  } catch (e) { log('parse warn ' + e.message); }
  log(`Forms+SharePoint templates: ${matches.length}`);
  fs.writeFileSync(path.join(CAP, 'template-matches.json'), JSON.stringify(matches, null, 2));

  // Dump the first matching template's full definition (our structural model).
  try {
    const j = JSON.parse(t.body);
    const first = (j.value || []).find(tm => matches.length && tm.name === matches[0].name);
    if (first) fs.writeFileSync(path.join(CAP, 'template-model.json'), JSON.stringify(first, null, 2));
  } catch {}

  // 2) Connector swagger for operationIds (trigger + actions).
  for (const api of ['shared_microsoftforms', 'shared_sharepointonline']) {
    const s = await get(`https://${EHOST}/connectivity/connectors/${api}?$expand=swagger&$filter=environment eq '${ENV}'&api-version=1`).catch(e => ({ status: -1, body: e.message }));
    log(`swagger ${api} -> ${s.status} (${s.body.length} bytes)`);
    fs.writeFileSync(path.join(CAP, `swagger-${api}.json`), s.body.slice(0, 2000000));
    // Extract operationIds + summaries.
    try {
      const j = JSON.parse(s.body);
      const sw = j.properties && j.properties.swagger;
      const ops = [];
      if (sw && sw.paths) for (const p of Object.keys(sw.paths)) for (const m of Object.keys(sw.paths[p])) { const op = sw.paths[p][m]; ops.push({ operationId: op.operationId, summary: op.summary, method: m, path: p, trigger: !!op['x-ms-trigger'] }); }
      fs.writeFileSync(path.join(CAP, `ops-${api}.json`), JSON.stringify(ops, null, 2));
      log(`  ${api} ops: ${ops.map(o => o.operationId).filter(Boolean).slice(0, 20).join(', ')}`);
    } catch (e) { log('  swagger parse warn ' + e.message); }
  }

  await ctx.close();
  log('done');
})();
