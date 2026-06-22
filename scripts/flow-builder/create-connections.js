// Create the two Standard OAuth connections the create-only flow needs
// (SharePoint + Microsoft Forms) by driving the Power Automate SPA's own
// "add connection" path, and CAPTURE the exact create network call so we learn
// the contract. Tries headless first: if first-party in-tenant consent is silent,
// no human interaction is needed. Screenshots + non-GET network go to .local.
//
// Usage: node create-connections.js [--headed] [--only=key1,key2]
//   keys: sharepoint | forms | planner | office365users
//   For the Operations follow-up sync layer: --only=planner,office365users --headed
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
const headed = process.argv.includes('--headed');
const onlyArg = (process.argv.find(a => a.startsWith('--only=')) || '').split('=')[1];
const only = onlyArg ? onlyArg.split(',').map(s => s.trim()).filter(Boolean) : null;

const CONNECTORS = [
  { key: 'sharepoint', api: 'shared_sharepointonline', label: 'SharePoint' },
  { key: 'forms', api: 'shared_microsoftforms', label: 'Microsoft Forms' },
  { key: 'planner', api: 'shared_planner', label: 'Planner' },
  { key: 'office365users', api: 'shared_office365users', label: 'Office 365 Users' },
].filter(c => !only || only.includes(c.key));

(async () => {
  // Prefer the already-signed-in WARM Edge over CDP (it locks the profile, so a cold
  // launchPersistentContext would fail while it is up); fall back to a cold headed launch.
  const CDP_PORT = process.env.CDP_PORT || '9222';
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT} (contexts=${browser.contexts().length})`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); cold headed launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: !headed, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const netlog = [];
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab)); // popups too
  page.on('request', req => { if (req.method() !== 'GET' && /connectivity|connections|powerapps|api\.flow|powerplatform/i.test(req.url())) netlog.push({ method: req.method(), url: req.url(), postData: (req.postData() || '').slice(0, 1500) }); });

  const H = () => ({ authorization: 'Bearer ' + tokens[EHOST], accept: 'application/json' });
  const listConns = async () => { const r = await page.request.get(`https://${EHOST}/connectivity/connections?api-version=1`, { headers: H() }); try { return (JSON.parse(await r.text()).value) || []; } catch { return []; } };

  // Prime a token.
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(8000);

  for (const c of CONNECTORS) {
    log(`=== creating connection: ${c.label} (${c.api}) ===`);
    const before = (await listConns()).filter(x => (x.properties && x.properties.apiId || '').includes(c.api)).length;

    // Open the "New connection" list and filter to the exact connector via search.
    await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections/available`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(e => log('  nav warn ' + e.message.split('\n')[0]));
    await page.waitForTimeout(6000);
    // Dismiss cookie banner if present.
    for (const t of ['Accept', 'Reject']) { const b = await page.$(`button:has-text("${t}")`).catch(() => null); if (b) { await b.click().catch(() => {}); break; } }
    // Type the connector name into the search box to filter the long list.
    const search = await page.$('input[type=search], input[placeholder*="Search" i], [role=searchbox]').catch(() => null);
    if (search) { await search.click().catch(() => {}); await search.fill(c.label).catch(() => {}); await page.waitForTimeout(3500); }
    await page.screenshot({ path: path.join(CAP, `conn-${c.key}-1-available.png`), fullPage: true }).catch(() => {});

    // Click the "+" / add action on the row whose name matches the connector exactly.
    const popupP = ctx.waitForEvent('page', { timeout: 9000 }).catch(() => null);
    let clicked = null;
    const rows = await page.$$('[role=row], tr');
    for (const row of rows) {
      const txt = ((await row.innerText().catch(() => '')) || '').trim();
      // Match the name cell starting with the exact label (avoid OneDrive/SharePoint-adjacent rows).
      if (new RegExp('^' + c.label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i').test(txt)) {
        const act = await row.$('button, [role=button], a[aria-label], i[role=button]');
        if (act) { await act.click({ timeout: 4000 }).catch(() => {}); clicked = txt.split('\n')[0]; break; }
      }
    }
    // Fallback: any element whose aria-label mentions creating a connection for this label.
    if (!clicked) { const el = await page.$(`[aria-label*="${c.label}" i][role=button], [aria-label*="Create" i]`).catch(() => null); if (el) { await el.click().catch(() => {}); clicked = 'aria:' + c.label; } }
    log(`  clicked row: ${clicked || '(none found)'}`);
    const popup = await popupP;
    if (popup) {
      if (headed) {
        log('  >>> OAuth popup opened. Please pick your account / click Allow to grant the connection. <<<');
        await popup.waitForTimeout(3000).catch(() => {});
      } else {
        log('  OAuth popup opened; letting it settle/redirect...');
        await popup.waitForTimeout(6000).catch(() => {});
        for (const rx of [/^(Accept|Allow|Yes|Continue)$/i]) { const bs = await popup.$$('button, input[type=submit], [role=button]').catch(() => []); for (const b of bs) { const t = ((await b.innerText().catch(() => '')) || (await b.getAttribute('value').catch(() => '')) || '').trim(); if (rx.test(t)) { await b.click().catch(() => {}); log('  popup approved: ' + t); break; } } }
        await popup.waitForTimeout(4000).catch(() => {});
        await popup.screenshot({ path: path.join(CAP, `conn-${c.key}-2-popup.png`) }).catch(() => {});
      }
    }
    await page.waitForTimeout(6000);
    await page.screenshot({ path: path.join(CAP, `conn-${c.key}-3-after.png`), fullPage: true }).catch(() => {});

    // Poll for the connection to appear Connected (longer when headed, to allow the human consent).
    let made = null;
    const polls = headed ? 60 : 12; // headed: up to ~4 min per connector
    for (let i = 0; i < polls; i++) {
      const conns = await listConns();
      made = conns.find(x => (x.properties && x.properties.apiId || '').includes(c.api));
      const status = made && made.properties && made.properties.statuses ? made.properties.statuses.map(s => s.status).join(',') : null;
      log(`  poll ${i}: present=${!!made} status=${status}`);
      if (made && status && /connected/i.test(status)) break;
      await page.waitForTimeout(4000);
    }
    fs.writeFileSync(path.join(CAP, `conn-${c.key}-result.json`), JSON.stringify(made || { created: false }, null, 2));
  }

  fs.writeFileSync(path.join(CAP, 'connection-create-netlog.json'), JSON.stringify(netlog, null, 2));
  const finalList = await listConns();
  fs.writeFileSync(path.join(CAP, 'connections-final.json'), JSON.stringify(finalList.map(c => ({ name: c.name, apiId: c.properties && c.properties.apiId, displayName: c.properties && c.properties.displayName, status: c.properties && c.properties.statuses && c.properties.statuses.map(s => s.status).join(',') })), null, 2));
  log(`final connections: ${finalList.length}`);
  if (ownCtx) await ctx.close(); // never kill the warm Edge; detach only
  log('done');
})();
