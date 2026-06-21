// Read-only: fetch the engine flow's most recent run(s) and print each action's status,
// drilling into failures (incl. inside For_each_signal) so a flow bug is visible without
// guessing. Usage: node get-last-run.js [--headless] [--n=1]
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
const headless = process.argv.includes('--headless');
const N = parseInt((process.argv.find(a => a.startsWith('--n=')) || '=1').split('=')[1], 10) || 1;
const flowName = JSON.parse(fs.readFileSync(path.join(OUT, 'flow-result-engine.json'), 'utf8')).flowName;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[FLOWHOST]) { log('no FLOWHOST token'); await ctx.close(); process.exit(1); }
  const T = { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json' };
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowName}`;
  const gj = async (url) => { const r = await page.request.get(url, { headers: T }); try { return { s: r.status(), j: JSON.parse(await r.text()) }; } catch { return { s: r.status(), j: null }; } };

  const runs = (await gj(`${base}/runs?api-version=2016-11-01&$top=${N}`)).j;
  for (const run of (runs && runs.value || [])) {
    log(`RUN ${run.name}  status=${run.properties.status}  start=${run.properties.startTime}`);
    if (run.properties.error) log(`  run error: ${JSON.stringify(run.properties.error)}`);
    const acts = (await gj(`${base}/runs/${run.name}/actions?api-version=2016-11-01`)).j;
    for (const a of (acts && acts.value || [])) {
      const p = a.properties || {};
      log(`  ${a.name}: ${p.status}${p.code ? ' ('+p.code+')' : ''}`);
      if (p.status === 'Failed') {
        // pull error detail
        const link = p.error || (p.outputsLink && p.outputsLink.uri);
        if (p.error) log(`     error: ${JSON.stringify(p.error).slice(0, 500)}`);
        if (p.outputsLink && p.outputsLink.uri) { const o = await page.request.get(p.outputsLink.uri); log(`     outputs: ${(await o.text()).slice(0, 600)}`); }
      }
    }
    // Drill into the foreach repetitions for action-level failures.
    const reps = (await gj(`${base}/runs/${run.name}/actions/For_each_signal/scopeRepetitions?api-version=2016-11-01`)).j;
    if (reps && reps.value) {
      for (const rep of reps.value) {
        const rp = rep.properties || {};
        if (rp.status === 'Failed') {
          log(`  For_each_signal[rep ${rep.name}]: Failed`);
          const ra = (await gj(`${base}/runs/${run.name}/actions/For_each_signal/repetitions/${rep.name}?api-version=2016-11-01`)).j;
          log(`     ${JSON.stringify(ra && ra.properties && ra.properties.actions ? Object.keys(ra.properties.actions) : ra).slice(0, 300)}`);
        }
      }
    }
  }
  await ctx.close();
})();
