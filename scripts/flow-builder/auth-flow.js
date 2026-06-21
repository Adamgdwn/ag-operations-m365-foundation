// Headed, surfaced-to-desktop: Adam signs into Power Automate ONCE here; the
// session persists into the same profile the forms-builder uses. As soon as the
// SPA is authenticated, this ALSO runs the read-only discovery probe (environment
// + existing Forms/SharePoint connections) so the one sign-in immediately yields
// what the flow build needs. No secrets written to disk (tokens kept in memory).
//
// Usage (surfaced via Start-FlowBuilder.ps1): node auth-flow.js
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

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1380, height: 920 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  const tokens = {};
  const seenHosts = new Set();
  page.on('request', req => {
    const auth = req.headers()['authorization'];
    if (auth && /^bearer /i.test(auth)) {
      const host = new URL(req.url()).host;
      if (!tokens[host]) tokens[host] = auth.replace(/^bearer\s+/i, '');
      seenHosts.add(host);
    }
  });

  console.log('\n==================================================================');
  console.log('  POWER AUTOMATE SIGN-IN');
  console.log('  A browser window is opening to make.powerautomate.com.');
  console.log('  If a Microsoft sign-in / "Let\'s get started" consent appears,');
  console.log('  complete it ONCE. The session is then remembered for the build.');
  console.log('  You do not need to build anything by hand.');
  console.log('==================================================================\n');

  await page.goto('https://make.powerautomate.com/', { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(e => log('nav warn ' + e.message.split('\n')[0]));

  // Wait until authenticated: on a make.powerautomate.com URL AND a management
  // bearer captured. Poll up to 5 minutes for the human sign-in.
  const deadline = Date.now ? null : null; // Date.now is unavailable in workflow ctx; here in plain node it's fine
  const start = new Date().getTime();
  let authed = false;
  while (new Date().getTime() - start < 300000) {
    const u = page.url();
    const onApp = /make\.powerautomate\.com/i.test(u) && !/login\.microsoftonline|\/oauth2\//i.test(u);
    const haveMgmt = !!(tokens['api.flow.microsoft.com'] || tokens['api.bap.microsoft.com'] || tokens['api.powerapps.com']);
    if (onApp && haveMgmt) { authed = true; break; }
    await page.waitForTimeout(2500);
  }

  if (!authed) {
    log('Sign-in not completed within the window (no management bearer captured).');
    fs.writeFileSync(path.join(CAP, 'probe-result.json'), JSON.stringify({ ok: false, reason: 'auth_timeout', landed: page.url(), bearerHosts: [...seenHosts] }, null, 2));
    console.log('\n[!] Could not confirm sign-in. You can close this window; re-run if needed.\n');
    await page.waitForTimeout(8000);
    await ctx.close();
    process.exit(0);
  }

  log(`authenticated. bearerHosts=[${[...seenHosts].join(', ')}]`);
  console.log('\n[OK] Signed in. Discovering environment + connections...\n');

  const callApi = async (fullUrl) => {
    const host = new URL(fullUrl).host;
    const tok = tokens[host] || tokens['api.flow.microsoft.com'] || tokens['api.bap.microsoft.com'] || tokens['api.powerapps.com'] || Object.values(tokens)[0];
    const r = await page.request.get(fullUrl, { headers: { authorization: 'Bearer ' + tok, accept: 'application/json' } });
    return { status: r.status(), body: await r.text() };
  };

  const result = { ok: true, landed: page.url(), bearerHosts: [...seenHosts], environments: [], connections: [] };

  for (const base of ['https://api.flow.microsoft.com', 'https://api.bap.microsoft.com']) {
    const ev = await callApi(`${base}/providers/Microsoft.ProcessSimple/environments?api-version=2016-11-01`).catch(e => ({ status: -1, body: e.message }));
    log(`environments via ${base} -> ${ev.status}`);
    fs.writeFileSync(path.join(CAP, `environments-${new URL(base).host}.json`), ev.body.slice(0, 300000));
    if (ev.status === 200) {
      try { const j = JSON.parse(ev.body); result.environments = (j.value || []).map(e => ({ name: e.name, displayName: e.properties && e.properties.displayName, isDefault: e.properties && e.properties.isDefault })); } catch {}
      result.environmentsBase = base; break;
    }
  }
  const env = result.environments.find(e => e.isDefault) || result.environments[0];
  log(`environment: ${env ? env.displayName + ' [' + env.name + ']' : '(none)'}`);

  if (env) {
    const base = result.environmentsBase;
    const connUrl = `${base}/providers/Microsoft.PowerApps/connections?api-version=2016-11-01&$filter=environment eq '${env.name}'`;
    const cn = await callApi(connUrl).catch(e => ({ status: -1, body: e.message }));
    log(`connections -> ${cn.status}`);
    fs.writeFileSync(path.join(CAP, 'connections.json'), cn.body.slice(0, 500000));
    if (cn.status === 200) {
      try {
        const j = JSON.parse(cn.body);
        result.connections = (j.value || []).map(c => ({
          name: c.name,
          apiName: c.properties && c.properties.apiId ? c.properties.apiId.split('/').pop() : undefined,
          displayName: c.properties && c.properties.displayName,
          status: c.properties && c.properties.statuses && c.properties.statuses.map(s => s.status).join(','),
        }));
      } catch {}
    }
  }
  result.hasFormsConnection = result.connections.some(c => /form/i.test(c.apiName || ''));
  result.hasSharePointConnection = result.connections.some(c => /sharepoint/i.test(c.apiName || ''));

  fs.writeFileSync(path.join(CAP, 'probe-result.json'), JSON.stringify(result, null, 2));
  log('wrote probe-result.json');
  console.log(`\n[OK] Environment: ${env ? env.displayName : '(none)'}`);
  console.log(`[OK] Forms connection present: ${result.hasFormsConnection}`);
  console.log(`[OK] SharePoint connection present: ${result.hasSharePointConnection}`);
  console.log('\nDONE. You can close this window. Returning control to the build.\n');
  await page.waitForTimeout(6000);
  await ctx.close();
})();
