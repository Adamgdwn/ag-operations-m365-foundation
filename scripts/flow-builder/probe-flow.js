// Read-only probe of the Power Automate / Power Platform management plane, using
// the SAME persisted authed M365 profile the forms-builder uses. Goal: discover
// (1) whether the session carries to make.powerautomate.com, (2) the bearer
// token audiences in play, (3) the environment id, and (4) any existing
// Microsoft Forms + SharePoint connections we can reference when creating the
// create-only flow. Writes everything to the gitignored .local capture dir.
//
// Usage: node probe-flow.js
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile'); // reuse the signed-in tenant session
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const redact = (t) => (t || '').replace(/(Bearer\s+)[A-Za-z0-9._\-]+/g, '$1<redacted>');

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  // Capture bearer tokens by audience host as the SPA boots and calls its APIs.
  const tokens = {}; // host -> bearer (kept in memory only; redacted on disk)
  const seenHosts = new Set();
  page.on('request', req => {
    const auth = req.headers()['authorization'];
    if (auth && /^bearer /i.test(auth)) {
      const host = new URL(req.url()).host;
      if (!tokens[host]) { tokens[host] = auth.replace(/^bearer\s+/i, ''); }
      seenHosts.add(host);
    }
  });

  log('navigating to make.powerautomate.com (silent SSO via persisted cookies)...');
  await page.goto('https://make.powerautomate.com/', { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(e => log('nav warn ' + e.message.split('\n')[0]));
  // Let the SPA boot and fire its management calls.
  await page.waitForTimeout(12000);
  const url = page.url();
  const onSignIn = /login\.microsoftonline|signin|\/oauth2\//i.test(url);
  log(`landed url: ${url}`);
  log(`signInWall=${onSignIn} bearerHosts=[${[...seenHosts].join(', ')}]`);

  fs.writeFileSync(path.join(CAP, 'probe-hosts.txt'), `landed: ${url}\nsignInWall: ${onSignIn}\nbearerHosts:\n${[...seenHosts].map(h => '  ' + h).join('\n')}\n`);

  if (onSignIn || Object.keys(tokens).length === 0) {
    log('No bearer captured (likely needs an interactive sign-in to Power Automate). Stopping probe.');
    fs.writeFileSync(path.join(CAP, 'probe-result.json'), JSON.stringify({ ok: false, reason: onSignIn ? 'sign_in_wall' : 'no_bearer', landed: url, bearerHosts: [...seenHosts] }, null, 2));
    await ctx.close();
    process.exit(0);
  }

  // Helper: call a management API with the bearer for that host, via page.request.
  const callApi = async (fullUrl) => {
    const host = new URL(fullUrl).host;
    const tok = tokens[host] || tokens['api.flow.microsoft.com'] || tokens['api.bap.microsoft.com'] || Object.values(tokens)[0];
    const r = await page.request.get(fullUrl, { headers: { authorization: 'Bearer ' + tok, accept: 'application/json' } });
    const body = await r.text();
    return { status: r.status(), body };
  };

  const result = { ok: true, landed: url, bearerHosts: [...seenHosts], environments: [], connections: [] };

  // 1) Environments (BAP). Try flow host first, then bap host.
  for (const base of ['https://api.flow.microsoft.com', 'https://api.bap.microsoft.com']) {
    const ev = await callApi(`${base}/providers/Microsoft.ProcessSimple/environments?api-version=2016-11-01`).catch(e => ({ status: -1, body: e.message }));
    log(`environments via ${base} -> ${ev.status}`);
    fs.writeFileSync(path.join(CAP, `environments-${new URL(base).host}.json`), ev.body.slice(0, 200000));
    if (ev.status === 200) {
      try {
        const j = JSON.parse(ev.body);
        result.environments = (j.value || []).map(e => ({ name: e.name, displayName: e.properties && e.properties.displayName, isDefault: e.properties && e.properties.isDefault }));
      } catch {}
      result.environmentsBase = base;
      break;
    }
  }

  const env = (result.environments.find(e => e.isDefault) || result.environments[0]);
  log(`default/first environment: ${env ? (env.displayName + ' [' + env.name + ']') : '(none found)'}`);

  // 2) Connections in that environment (look for Forms + SharePoint).
  if (env) {
    const base = result.environmentsBase || 'https://api.flow.microsoft.com';
    const cu = `${base}/providers/Microsoft.PowerApps/apis?api-version=2016-11-01`; // not strictly needed
    const connUrl = `${base}/providers/Microsoft.PowerApps/connections?api-version=2016-11-01&$filter=environment eq '${env.name}'`;
    const cn = await callApi(connUrl).catch(e => ({ status: -1, body: e.message }));
    log(`connections -> ${cn.status}`);
    fs.writeFileSync(path.join(CAP, 'connections.json'), cn.body.slice(0, 400000));
    if (cn.status === 200) {
      try {
        const j = JSON.parse(cn.body);
        result.connections = (j.value || []).map(c => ({
          name: c.name,
          apiName: c.properties && c.properties.apiId ? c.properties.apiId.split('/').pop() : (c.properties && c.properties.apiName),
          displayName: c.properties && c.properties.displayName,
          status: c.properties && c.properties.statuses && c.properties.statuses.map(s => s.status).join(','),
        }));
      } catch {}
    }
  }

  const forms = result.connections.filter(c => /form/i.test(c.apiName || ''));
  const spo = result.connections.filter(c => /sharepoint/i.test(c.apiName || ''));
  result.hasFormsConnection = forms.length > 0;
  result.hasSharePointConnection = spo.length > 0;
  log(`Forms connections: ${forms.length} | SharePoint connections: ${spo.length}`);

  fs.writeFileSync(path.join(CAP, 'probe-result.json'), JSON.stringify(result, null, 2));
  log('wrote probe-result.json (tokens NOT written to disk)');
  await ctx.close();
})();
