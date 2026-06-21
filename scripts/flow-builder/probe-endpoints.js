// Learn the EXACT management endpoints the Power Automate SPA uses by intercepting
// its own network calls while we visit the Connections and My-Flows pages. We do
// NOT create anything here — read-only reconnaissance to nail the connections-list
// and flow-create contract (paths, api-versions, hosts). Tokens stay in memory.
//
// Usage: node probe-endpoints.js
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

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  const tokens = {};
  const calls = []; // {method, url, status}
  const interesting = /connection|\/flows|ProcessSimple|connectivity|apis\b/i;
  page.on('request', req => {
    const auth = req.headers()['authorization'];
    if (auth && /^bearer /i.test(auth)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = auth.replace(/^bearer\s+/i, ''); }
  });
  page.on('response', async resp => {
    const u = resp.url();
    if (interesting.test(u) && /api|powerplatform|powerapps|flow|bap/i.test(new URL(u).host)) {
      calls.push({ method: resp.request().method(), status: resp.status(), url: u });
    }
  });

  const visit = async (url, waitMs) => { log('visit ' + url); await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(e => log('  warn ' + e.message.split('\n')[0])); await page.waitForTimeout(waitMs); };

  await visit(`https://make.powerautomate.com/environments/${ENV}/connections`, 12000);
  await visit(`https://make.powerautomate.com/environments/${ENV}/flows`, 9000);
  // Also poke the connectors gallery so the SPA resolves connector apiIds for Forms + SharePoint.
  await visit(`https://make.powerautomate.com/environments/${ENV}/connections/available`, 9000);

  // De-dupe by method+path (strip query for grouping but keep one full sample).
  const seen = new Map();
  for (const c of calls) {
    const key = c.method + ' ' + c.url.split('?')[0];
    if (!seen.has(key)) seen.set(key, c);
  }
  const uniq = [...seen.values()];
  fs.writeFileSync(path.join(CAP, 'endpoint-calls.json'), JSON.stringify(uniq, null, 2));
  log(`captured ${uniq.length} unique management calls -> endpoint-calls.json`);

  // Now actually try to LIST connections via the most likely endpoints to see which returns 200.
  const tok = (host) => tokens[host] || tokens['api.flow.microsoft.com'] || tokens['api.bap.microsoft.com'] || Object.values(tokens)[0];
  const tryGet = async (url) => { const h = new URL(url).host; const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tok(h), accept: 'application/json' } }).catch(e => null); return r ? { status: r.status(), body: (await r.text()).slice(0, 4000) } : { status: -1, body: 'threw' }; };

  const envHost = `default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com`;
  const candidates = [
    `https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/${ENV}/connections?api-version=2016-11-01`,
    `https://api.flow.microsoft.com/providers/Microsoft.PowerApps/connections?api-version=2016-11-01&$filter=environment eq '${ENV}'`,
    `https://${envHost}/connectivity/connections?api-version=1&$filter=environment eq '${ENV}'`,
    `https://${envHost}/connectivity/connections?api-version=1`,
  ];
  const probes = {};
  for (const url of candidates) { const r = await tryGet(url); probes[url] = { status: r.status, sample: r.body.slice(0, 500) }; log(`  GET ${url.split('?')[0]} -> ${r.status}`); }
  fs.writeFileSync(path.join(CAP, 'connections-endpoint-probe.json'), JSON.stringify(probes, null, 2));

  await ctx.close();
  log('done');
})();
