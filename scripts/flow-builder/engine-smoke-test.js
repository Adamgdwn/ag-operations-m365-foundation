// Smoke test for the Operations follow-up engine (email layer).
//
// Creates 3 throwaway signals on CRM - New Signals, each timed so its minutes-until-due
// lands in exactly one offset window, with the matching op_Reminders ticked:
//   A '1 day before'      -> due now + 1447 min   (window [1440,1455))
//   B '30 minutes before' -> due now + 38 min     (window [30,45))
//   C 'Day after'         -> due now - 1432 min    (window [-1440,-1425))
// Owner is left empty so all 3 reminder emails fall back to Adam. Then it triggers an
// on-demand run of the engine flow so we don't wait for the 15-min tick. Each record's
// Person is exactly 'GAIL-INTERNAL-WALKTHROUGH' so scripts/flow-builder/delete-test-records.js
// can scope-delete them afterward. Test data only; no schema/permission/flow changes.
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
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const FLOWHOST = 'api.flow.microsoft.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TRIGGER = 'Every_15_min';
const PERSON = 'GAIL-INTERNAL-WALKTHROUGH';
const headless = process.argv.includes('--headless');
const noRun = process.argv.includes('--no-run'); // create the records but don't trigger

const minutesFromNowIso = (m) => new Date(Date.now() + m * 60000).toISOString();
const CASES = [
  { tag: 'A', choice: '1 day before', mins: 1447 },
  { tag: 'B', choice: '30 minutes before', mins: 38 },
  { tag: 'C', choice: 'Day after', mins: -1432 },
];

(async () => {
  const flowName = JSON.parse(fs.readFileSync(path.join(OUT, 'flow-result-engine.json'), 'utf8')).flowName;
  log(`engine flow: ${flowName}`);

  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  // Prime the Power Automate session to capture the FLOWHOST token (for the on-demand run).
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);

  // Resolve list GUID + form digest using the persisted SharePoint cookie session.
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(4000);
  const listId = JSON.parse(await (await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } })).text()).Id;
  log(`list GUID: ${listId}`);
  const digest = JSON.parse(await (await page.request.post(`${SITE}/_api/contextinfo`, { headers: { accept: 'application/json;odata=nometadata' } })).text()).FormDigestValue;

  const created = [];
  for (const c of CASES) {
    const body = {
      Title: `${PERSON} engine ${c.tag} (${c.choice})`,
      SignalType: 'Referral',
      IntakeSource: 'Direct',
      Priority: 'Normal',
      SignalStatus: 'New',
      NeedSummary: `Smoke test of the follow-up engine, offset "${c.choice}".`,
      SourceText: 'Automated engine smoke test record. Safe to delete.',
      NextAction: 'Confirm the reminder email arrived, then delete.',
      PersonName: PERSON,
      FollowUpDueDate: minutesFromNowIso(c.mins),
      op_Reminders: [c.choice],
    };
    const r = await page.request.post(`${SITE}/_api/web/lists(guid'${listId}')/items`, {
      headers: { accept: 'application/json;odata=nometadata', 'content-type': 'application/json;odata=nometadata', 'X-RequestDigest': digest },
      data: JSON.stringify(body),
    });
    const txt = await r.text();
    if (r.status() >= 200 && r.status() < 300) { const id = JSON.parse(txt).Id; created.push({ ...c, id }); log(`  [OK] case ${c.tag} -> item ${id} (due ${body.FollowUpDueDate})`); }
    else { log(`  [FAIL] case ${c.tag}: ${r.status()} ${txt.slice(0, 400)}`); }
  }

  if (!noRun) {
    if (!tokens[FLOWHOST]) { log('WARN: no FLOWHOST token; cannot trigger on-demand run. The flow will still fire on its next 15-min tick.'); }
    else {
      const runUrl = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowName}/triggers/${TRIGGER}/run?api-version=2016-11-01`;
      const rr = await page.request.post(runUrl, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json', 'content-type': 'application/json' }, data: '{}' });
      log(`on-demand run -> ${rr.status()}${rr.status() >= 300 ? ' ' + (await rr.text()).slice(0, 400) : ''}`);
    }
  }

  fs.writeFileSync(path.join(OUT, 'engine-smoke-result.json'), JSON.stringify({ generated: new Date().toISOString(), flowName, listId, created }, null, 2));
  log(`created ${created.length}/3 test signals. Expect ${created.length} reminder emails to Adam shortly.`);
  log('After confirming, run: node scripts/flow-builder/delete-test-records.js');
  await ctx.close();
})();
