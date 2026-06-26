// Read-only: fetch a Power Automate flow's current display name/state and save a
// small non-secret evidence packet.
//
// Usage:
//   node scripts/flow-builder/get-flow-state.js --result=flow-result-http-intake.json
//   node scripts/flow-builder/get-flow-state.js --flowName=<flow-guid>
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const FLOWHOST = 'api.flow.microsoft.com';
const CDP_PORT = process.env.CDP_PORT || '9222';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';

const headless = process.argv.includes('--headless');
const flowNameArg = (process.argv.find(a => a.startsWith('--flowName=')) || '').split('=')[1];
const resultArg = (process.argv.find(a => a.startsWith('--result=')) || '=flow-result-http-intake.json').split('=')[1];
const flowName = flowNameArg || JSON.parse(fs.readFileSync(path.join(OUT, resultArg), 'utf8')).flowName;

async function selectTenantAccountIfPrompted(page) {
  await page.waitForTimeout(1500);
  const body = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (!/Pick an account/i.test(body)) return false;
  const byId = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null);
  if (byId) {
    await byId.click().catch(() => {});
    await page.waitForTimeout(8000);
    return true;
  }
  const byText = page.locator(`text=${TENANT_ACCT}`).first();
  if (await byText.count().catch(() => 0)) {
    await byText.click().catch(() => {});
    await page.waitForTimeout(8000);
    return true;
  }
  return false;
}

(async () => {
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT}`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); cold launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const cleanup = async () => { try { if (ownCtx) await ctx.close(); else if (browser) await browser.close(); } catch {} };
  const page = await ctx.newPage();
  const tokens = {};
  const seenHosts = new Set();
  page.on('request', (req) => {
    const auth = req.headers()['authorization'];
    if (auth && /^bearer /i.test(auth)) {
      const host = new URL(req.url()).host;
      if (!tokens[host]) tokens[host] = auth.replace(/^bearer\s+/i, '');
      seenHosts.add(host);
    }
  });

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await selectTenantAccountIfPrompted(page);
  await page.waitForTimeout(15000);
  const token = tokens[FLOWHOST] || tokens['api.bap.microsoft.com'] || tokens['api.powerapps.com'] || Object.values(tokens)[0];
  if (!token) {
    log(`ERROR: no management token captured. bearerHosts=[${[...seenHosts].join(', ')}]`);
    log('Run Start-FlowBuilder.ps1 -Phase auth in a visible signed-in session.');
    await cleanup();
    process.exit(1);
  }

  const url = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowName}?api-version=2016-11-01`;
  const response = await page.request.get(url, { headers: { authorization: 'Bearer ' + token, accept: 'application/json' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    log(`ERROR: flow state read failed HTTP ${response.status()} ${bodyText.slice(0, 500)}`);
    await cleanup();
    process.exit(2);
  }
  const body = JSON.parse(bodyText);
  const props = body.properties || {};
  const evidence = {
    capturedAt: new Date().toISOString(),
    environment: ENV,
    flowName,
    displayName: props.displayName || null,
    state: props.state || null,
    createdTime: props.createdTime || null,
    lastModifiedTime: props.lastModifiedTime || null,
    suspensionInfo: props.suspensionInfo || null,
  };
  fs.mkdirSync(OUT, { recursive: true });
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-');
  const outPath = path.join(OUT, `flow-state-${flowName}-${stamp}.json`);
  fs.writeFileSync(outPath, JSON.stringify(evidence, null, 2));
  log(`flow "${evidence.displayName}" state=${evidence.state}`);
  if (evidence.suspensionInfo) log(`suspensionInfo=${JSON.stringify(evidence.suspensionInfo).slice(0, 500)}`);
  log(`evidence: ${outPath}`);
  await cleanup();
})();
