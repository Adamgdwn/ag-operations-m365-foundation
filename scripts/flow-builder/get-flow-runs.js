// Read-only: fetch recent Power Automate runs and action statuses for a flow.
//
// Usage:
//   node scripts/flow-builder/get-flow-runs.js --result=flow-result-http-intake.json --top=5
//   node scripts/flow-builder/get-flow-runs.js --flowName=<flow-guid> --runName=<run-id>
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const FLOWHOST = 'api.flow.microsoft.com';
const CDP_PORT = process.env.CDP_PORT || '9222';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const flowNameArg = (process.argv.find(a => a.startsWith('--flowName=')) || '').split('=')[1];
const resultArg = (process.argv.find(a => a.startsWith('--result=')) || '=flow-result-http-intake.json').split('=')[1];
const flowName = flowNameArg || JSON.parse(fs.readFileSync(path.join(OUT, resultArg), 'utf8')).flowName;
const top = Number((process.argv.find(a => a.startsWith('--top=')) || '=10').split('=')[1] || 10);
const runNameArg = (process.argv.find(a => a.startsWith('--runName=')) || '').split('=')[1];

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

function summarizeAction(action) {
  const props = action.properties || {};
  const error = props.error || (props.outputs && props.outputs.body && props.outputs.body.error) || null;
  const outputs = props.outputs ? {
    statusCode: props.outputs.statusCode || null,
    body: props.outputs.body || null,
  } : null;
  return {
    name: action.name,
    type: props.type || null,
    status: props.status || null,
    code: props.code || null,
    startTime: props.startTime || null,
    endTime: props.endTime || null,
    outputs,
    error,
  };
}

(async () => {
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT}`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); cold launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const cleanup = async () => { try { if (ownCtx) await ctx.close(); else if (browser) await browser.close(); } catch {} };
  const page = await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => {
    const auth = req.headers()['authorization'];
    if (auth && /^bearer /i.test(auth)) {
      const host = new URL(req.url()).host;
      if (!tokens[host]) tokens[host] = auth.replace(/^bearer\s+/i, '');
    }
  });

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await selectTenantAccountIfPrompted(page);
  await page.waitForTimeout(12000);
  const token = tokens[FLOWHOST] || Object.values(tokens)[0];
  if (!token) {
    log('ERROR: no management token captured.');
    await cleanup();
    process.exit(1);
  }

  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowName}`;
  const headers = { authorization: 'Bearer ' + token, accept: 'application/json' };
  const runsResponse = await page.request.get(`${base}/runs?api-version=2016-11-01&$top=${top}`, { headers });
  const runsBody = await runsResponse.text();
  if (runsResponse.status() < 200 || runsResponse.status() >= 300) {
    log(`ERROR: runs read failed HTTP ${runsResponse.status()} ${runsBody.slice(0, 500)}`);
    await cleanup();
    process.exit(2);
  }
  const runsJson = JSON.parse(runsBody);
  const runs = (runsJson.value || []).map((run) => ({
    name: run.name,
    status: run.properties && run.properties.status || null,
    startTime: run.properties && run.properties.startTime || null,
    endTime: run.properties && run.properties.endTime || null,
    triggerName: run.properties && run.properties.trigger && run.properties.trigger.name || null,
  }));

  const selectedRunName = runNameArg || (runs[0] && runs[0].name);
  let actions = [];
  if (selectedRunName) {
    const actionsResponse = await page.request.get(`${base}/runs/${selectedRunName}/actions?api-version=2016-11-01`, { headers });
    const actionsBody = await actionsResponse.text();
    if (actionsResponse.status() >= 200 && actionsResponse.status() < 300) {
      const actionsJson = JSON.parse(actionsBody);
      const listedActions = actionsJson.value || [];
      actions = [];
      for (const action of listedActions) {
        const detailResponse = await page.request.get(`${base}/runs/${selectedRunName}/actions/${encodeURIComponent(action.name)}?api-version=2016-11-01`, { headers });
        if (detailResponse.status() >= 200 && detailResponse.status() < 300) {
          actions.push(summarizeAction(JSON.parse(await detailResponse.text())));
        } else {
          actions.push(summarizeAction(action));
        }
      }
    } else {
      actions = [{ name: 'actions-read-failed', status: String(actionsResponse.status()), error: actionsBody.slice(0, 500) }];
    }
  }

  const evidence = {
    capturedAt: new Date().toISOString(),
    environment: ENV,
    flowName,
    selectedRunName,
    runs,
    actions,
  };
  fs.mkdirSync(OUT, { recursive: true });
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-');
  const outPath = path.join(OUT, `flow-runs-${flowName}-${stamp}.json`);
  fs.writeFileSync(outPath, JSON.stringify(evidence, null, 2));
  log(`latest run=${selectedRunName || 'none'} status=${runs[0] ? runs[0].status : 'none'}`);
  for (const action of actions) log(`  ${action.name}: ${action.status}${action.error ? ' ERROR' : ''}`);
  log(`evidence: ${outPath}`);
  await cleanup();
})();
