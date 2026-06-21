// Throwaway probe: find which API lists the existing connections (we know SP conn
// 4c53f079... exists because the Path B flows reference + run it). Captures tokens
// from the persisted session, tries several connection-list endpoints, prints which
// return the known connection. Read-only.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }
const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const KNOWN = '4c53f079bec84a81a87ed7d58c67401e';
const log = (m) => console.log(m);

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  // Visit the connections page so the SPA itself fetches the list and reveals the real endpoint.
  const seen = [];
  page.on('response', r => { const u = r.url(); if (/connection/i.test(u) && /api-version|connectivity|apiHub|connections/i.test(u)) seen.push(`${r.status()} ${r.request().method()} ${u}`); });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(12000);
  log('=== connection-related responses the SPA made ===');
  [...new Set(seen)].forEach(s => log('  ' + s));

  const tok = (host) => tokens[host] || tokens[EHOST];
  const tryGet = async (url) => {
    const host = new URL(url).host;
    const t = tok(host);
    if (!t) return `NO-TOKEN-FOR ${host}`;
    try { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + t, accept: 'application/json' } }); const b = await r.text(); return `${r.status()} hits=${(b.match(new RegExp(KNOWN, 'g')) || []).length} len=${b.length}`; }
    catch (e) { return 'ERR ' + e.message.split('\n')[0]; }
  };
  const urls = [
    `https://${EHOST}/connectivity/connections?api-version=1`,
    `https://${EHOST}/connectivity/connections?$filter=environment eq '${ENV}'&api-version=1`,
    `https://${EHOST}/connectivity/connections?api-version=2`,
    `https://api.powerapps.com/providers/Microsoft.PowerApps/connections?api-version=2016-11-01&$filter=environment eq '${ENV}'`,
    `https://api.powerapps.com/providers/Microsoft.PowerApps/apis/shared_sharepointonline/connections?api-version=2016-11-01&$filter=environment eq '${ENV}'`,
    `https://api.flow.microsoft.com/providers/Microsoft.PowerApps/apis/shared_sharepointonline/connections?api-version=2016-11-01&$filter=environment eq '${ENV}'`,
    `https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/${ENV}/apis/shared_sharepointonline/connections?api-version=2016-11-01`,
  ];
  log('\n=== endpoint probes (hits = times known conn id appears) ===');
  for (const u of urls) log(`  ${await tryGet(u)}  <-  ${u}`);
  log('\ntokens captured for hosts: ' + Object.keys(tokens).join(', '));
  await ctx.close();
})();
