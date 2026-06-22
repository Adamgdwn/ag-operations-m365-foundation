// Phased smoke test for the PLANNER (one-way, hub-driven) layer of the Operations
// follow-up engine. Drives one throwaway signal through create -> move -> untrack/close,
// triggering an on-demand engine run at each step, and reads the CRM row back so the
// hub-driven sync is proven (not assumed). Person is exactly 'GAIL-INTERNAL-WALKTHROUGH'
// so the scoped delete script can clean up. Test data only; no schema/permission changes.
//
// Planner is ONE-WAY (CRM -> Planner): there is no "pull" phase. Teardown can be proven
// two ways — by unticking op_TrackOn (untrack) or by closing the signal (close).
//
// Prereqs (Adam's consent session, done once):
//   1. node scripts/flow-builder/create-connections.js --only=planner,office365users --headed
//   2. create the "CRM Follow-ups" plan; put its groupId + planId into config/followup.registry.json
//   3. node scripts/flow-builder/create-followup-engine-flow.js   (rebuild PATCH with planner active)
//
// Phases:
//   create     create a Planner-tracked signal due in ~2 days, run engine -> task appears, assigned to owner
//   status     print the CRM row's due + op_ fields (planner task id, shadow, sync note)
//   movecrm    push FollowUpDueDate +90 min, run engine                    -> task due should move
//   untrack    clear op_TrackOn, run engine                                -> task deleted, id cleared
//   close      set SignalStatus=Closed, run engine                         -> task deleted (teardown-on-close)
//   cleanup    delete the test record
//
// Usage: node planner-smoke-test.js <phase> [--headless]
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(OUT, { recursive: true });
const STATE = path.join(OUT, 'planner-smoke-state.json');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const FLOWHOST = 'api.flow.microsoft.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TRIGGER = 'Every_15_min';
const PERSON = 'GAIL-INTERNAL-WALKTHROUGH';

const phase = (process.argv[2] || '').toLowerCase();
const headless = process.argv.includes('--headless');
const flowName = JSON.parse(fs.readFileSync(path.join(OUT, 'flow-result-engine.json'), 'utf8')).flowName;

(async () => {
  if (!['create', 'run', 'status', 'movecrm', 'untrack', 'close', 'cleanup'].includes(phase)) {
    log('usage: node planner-smoke-test.js <create|run|status|movecrm|untrack|close|cleanup> [--headless]'); process.exit(2);
  }
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(4000);

  const J = { accept: 'application/json;odata=nometadata' };
  const listId = JSON.parse(await (await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: J })).text()).Id;
  const digest = JSON.parse(await (await page.request.post(`${SITE}/_api/contextinfo`, { headers: J })).text()).FormDigestValue;
  const itemsUrl = `${SITE}/_api/web/lists(guid'${listId}')/items`;

  const runEngine = async () => {
    if (!tokens[FLOWHOST]) { log('  WARN: no FLOWHOST token; flow will fire on its next 15-min tick instead.'); return; }
    const r = await page.request.post(`https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${flowName}/triggers/${TRIGGER}/run?api-version=2016-11-01`, { headers: { authorization: 'Bearer ' + tokens[FLOWHOST], accept: 'application/json', 'content-type': 'application/json' }, data: '{}' });
    log(`  on-demand run -> ${r.status()}`);
  };
  const readState = () => fs.existsSync(STATE) ? JSON.parse(fs.readFileSync(STATE, 'utf8')) : {};
  const getItem = async (id) => JSON.parse(await (await page.request.get(`${itemsUrl}(${id})?$select=Id,Title,FollowUpDueDate,SignalStatus,op_TrackOn,op_PlannerTaskId,op_LastSyncedDue,op_SyncNote`, { headers: J })).text());
  const merge = async (id, body) => { const r = await page.request.post(`${itemsUrl}(${id})`, { headers: { ...J, 'content-type': 'application/json;odata=nometadata', 'X-RequestDigest': digest, 'X-HTTP-Method': 'MERGE', 'IF-MATCH': '*' }, data: JSON.stringify(body) }); return r.status(); };
  const showItem = (it) => log(`  CRM row ${it.Id}: due=${it.FollowUpDueDate}  status=${(it.SignalStatus && it.SignalStatus.Value) || it.SignalStatus}  TrackOn=${JSON.stringify(it.op_TrackOn)}  taskId=${(it.op_PlannerTaskId || '').slice(0, 24)}${it.op_PlannerTaskId ? '…' : ''}  shadow=${it.op_LastSyncedDue}  note="${it.op_SyncNote || ''}"`);

  if (phase === 'create') {
    const due = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000); // ~2 days out
    const body = {
      Title: `${PERSON} planner test`, SignalType: 'Referral', IntakeSource: 'Direct', Priority: 'Normal', SignalStatus: 'New',
      NeedSummary: 'Planner one-way smoke test. Safe to delete.', SourceText: 'Automated planner smoke test record.',
      NextAction: 'Confirm the Planner task appears (assigned to owner), then test move + teardown.', PersonName: PERSON,
      FollowUpDueDate: due.toISOString(), op_TrackOn: ['Planner'],
    };
    const r = await page.request.post(itemsUrl, { headers: { ...J, 'content-type': 'application/json;odata=nometadata', 'X-RequestDigest': digest }, data: JSON.stringify(body) });
    const txt = await r.text();
    if (r.status() >= 300) { log(`  [FAIL] create: ${r.status()} ${txt.slice(0, 300)}`); await ctx.close(); process.exit(1); }
    const id = JSON.parse(txt).Id;
    fs.writeFileSync(STATE, JSON.stringify({ id, listId, createdDue: due.toISOString() }, null, 2));
    log(`  [OK] created item ${id}  due=${due.toISOString()} (local ${due.toString()})`);
    await runEngine();
    log('  -> check Planner "CRM Follow-ups" (and your To Do "Assigned to me") for "Follow-up: GAIL-INTERNAL-WALKTHROUGH planner test".');
  } else if (phase === 'run') {
    await runEngine(); await page.waitForTimeout(8000); showItem(await getItem(readState().id));
  } else if (phase === 'status') {
    const { id } = readState(); showItem(await getItem(id));
  } else if (phase === 'movecrm') {
    const { id } = readState(); const it = await getItem(id);
    const moved = new Date(new Date(it.FollowUpDueDate).getTime() + 90 * 60000).toISOString();
    log(`  setting CRM due ${it.FollowUpDueDate} -> ${moved} (+90 min)`);
    log(`  merge -> ${await merge(id, { FollowUpDueDate: moved })}`);
    await runEngine();
    log('  -> the Planner task due should shift +90 min within the run. Re-run "status" to confirm shadow updated.');
  } else if (phase === 'untrack') {
    const { id } = readState();
    log(`  clearing op_TrackOn -> merge ${await merge(id, { op_TrackOn: [] })}`);
    await runEngine();
    log('  -> the Planner task should be deleted within the run. Re-run "status": taskId should be empty.');
  } else if (phase === 'close') {
    const { id } = readState();
    log(`  setting SignalStatus=Closed -> merge ${await merge(id, { SignalStatus: 'Closed' })}`);
    await runEngine();
    log('  -> teardown-on-close: the Planner task should be deleted within the run. Re-run "status": taskId should be empty.');
  } else if (phase === 'cleanup') {
    const { id } = readState();
    const r = await page.request.post(`${itemsUrl}(${id})`, { headers: { ...J, 'X-RequestDigest': digest, 'X-HTTP-Method': 'DELETE', 'IF-MATCH': '*' } });
    log(`  delete item ${id} -> ${r.status()}`);
    if (fs.existsSync(STATE)) fs.unlinkSync(STATE);
  }
  await ctx.close();
})();
