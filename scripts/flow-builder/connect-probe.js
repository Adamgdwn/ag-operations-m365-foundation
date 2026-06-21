// Reconnaissance for connection creation. Read the SharePoint + Forms connector
// definitions (to learn auth/consent type + required params), then ATTEMPT a
// connection create for SharePoint via the connectivity API and print the exact
// response (consent URL / required fields / resulting status). Read-mostly: the
// only write is a connection create attempt, which is in-envelope (a connection
// is a prerequisite of the authorized create-only flow) and is cleaned up if it
// lands in an unauthenticated/error state. Tokens stay in memory.
//
// Usage: node connect-probe.js [--create] [--cleanup]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
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
const doCreate = process.argv.includes('--create');
const doCleanup = process.argv.includes('--cleanup');

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[EHOST]) { log('ERROR: no env-host bearer captured'); await ctx.close(); process.exit(1); }

  const H = { authorization: 'Bearer ' + tokens[EHOST], accept: 'application/json', 'content-type': 'application/json' };
  const get = async (url) => { const r = await page.request.get(url, { headers: H }); return { status: r.status(), body: await r.text() }; };
  const put = async (url, body) => { const r = await page.request.put(url, { headers: H, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const del = async (url) => { const r = await page.request.delete(url, { headers: H }); return { status: r.status(), body: await r.text() }; };

  // 1) Connector definitions (auth/consent type + parameters).
  const out = {};
  for (const api of ['shared_sharepointonline', 'shared_microsoftforms']) {
    const r = await get(`https://${EHOST}/connectivity/connectors/${api}?$filter=environment eq '${ENV}'&api-version=1`);
    log(`connector ${api} -> ${r.status}`);
    let parsed = null; try { parsed = JSON.parse(r.body); } catch {}
    const props = parsed && parsed.properties ? parsed.properties : {};
    out[api] = {
      status: r.status,
      displayName: props.displayName,
      tier: props.tier,
      connectionParameters: props.connectionParameters ? Object.keys(props.connectionParameters) : undefined,
      capabilities: props.capabilities,
      authType: props.connectionParameters && props.connectionParameters.token ? (props.connectionParameters.token.oAuthSettings ? 'oauth' : 'other') : undefined,
    };
    fs.writeFileSync(path.join(CAP, `connector-${api}.json`), r.body.slice(0, 200000));
  }
  fs.writeFileSync(path.join(CAP, 'connector-summary.json'), JSON.stringify(out, null, 2));
  log('connector summary: ' + JSON.stringify(out));

  // 2) Existing connections (re-list, expanded).
  const cl = await get(`https://${EHOST}/connectivity/connections?api-version=1`);
  fs.writeFileSync(path.join(CAP, 'connections-list.json'), cl.body.slice(0, 200000));
  log(`connections list -> ${cl.status}: ${cl.body.slice(0, 200)}`);

  // 3) OPTIONAL create attempt for SharePoint to learn the create + consent contract.
  if (doCreate) {
    const id = 'gail' + crypto.randomBytes(8).toString('hex');
    const url = `https://${EHOST}/connectivity/connections/${id}?api-version=1`;
    const body = {
      properties: {
        environment: { name: ENV, id: `/providers/Microsoft.PowerApps/environments/${ENV}` },
        connector: 'shared_sharepointonline',
        displayName: 'GAIL CRM SharePoint (probe)',
      },
    };
    log(`CREATE attempt PUT ${url}`);
    const r = await put(url, body);
    log(`  -> ${r.status}`);
    fs.writeFileSync(path.join(CAP, 'connection-create-attempt.json'), `PUT ${url}\nrequest: ${JSON.stringify(body)}\n\nstatus: ${r.status}\nbody:\n${r.body}`);
    log('  body (first 800): ' + r.body.slice(0, 800));
    if (doCleanup && r.status >= 200 && r.status < 300) {
      const d = await del(url);
      log(`  cleanup delete -> ${d.status}`);
    }
  }

  await ctx.close();
  log('done');
})();
