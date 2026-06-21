// Phased smoke test for the calendar two-way layer of the Operations follow-up engine.
// Drives one throwaway signal through create -> move -> untrack -> delete, triggering an
// on-demand engine run at each step, and reads the CRM row back so the two-way is proven
// (not assumed). Person is exactly 'GAIL-INTERNAL-WALKTHROUGH' so the scoped delete script
// can clean up. Test data only; no schema/permission/flow changes.
//
// Phases:
//   create     create a Calendar-tracked signal due in ~2 days, run engine  -> event appears
//   status     print the CRM row's due + op_ fields (calendar event id, shadow, sync note)
//   movecrm    push FollowUpDueDate +90 min, run engine                      -> event should move
//   pullcheck  (after you DRAG the event in Outlook) run engine + status     -> CRM due follows
//   untrack    clear op_TrackOn, run engine                                  -> event deleted
//   cleanup    delete the test record
//
// Usage: node calendar-smoke-test.js <phase> [--headless]
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(OUT, { recursive: true });
const STATE = path.join(OUT, 'calendar-smoke-state.json');
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
  if (!['create', 'run', 'status', 'movecrm', 'pullcheck', 'untrack', 'cleanup'].includes(phase)) {
    log('usage: node calendar-smoke-test.js <create|run|status|movecrm|pullcheck|untrack|cleanup> [--headless]'); process.exit(2);
  }
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  ctx.on('page', p => p.on('request', (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } }));

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
  const getItem = async (id) => JSON.parse(await (await page.request.get(`${itemsUrl}(${id})?$select=Id,Title,FollowUpDueDate,op_TrackOn,op_CalendarEventId,op_LastSyncedDue,op_SyncNote`, { headers: J })).text());
  const merge = async (id, body) => { const r = await page.request.post(`${itemsUrl}(${id})`, { headers: { ...J, 'content-type': 'application/json;odata=nometadata', 'X-RequestDigest': digest, 'X-HTTP-Method': 'MERGE', 'IF-MATCH': '*' }, data: JSON.stringify(body) }); return r.status(); };
  const showItem = (it) => log(`  CRM row ${it.Id}: due=${it.FollowUpDueDate}  TrackOn=${JSON.stringify(it.op_TrackOn)}  eventId=${(it.op_CalendarEventId || '').slice(0, 24)}${it.op_CalendarEventId ? '…' : ''}  shadow=${it.op_LastSyncedDue}  note="${it.op_SyncNote || ''}"`);

  if (phase === 'create') {
    const due = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000); // ~2 days out
    const body = {
      Title: `${PERSON} calendar test`, SignalType: 'Referral', IntakeSource: 'Direct', Priority: 'Normal', SignalStatus: 'New',
      NeedSummary: 'Calendar two-way smoke test. Safe to delete.', SourceText: 'Automated calendar smoke test record.',
      NextAction: 'Confirm the Outlook event appears, then drag it to test pull-back.', PersonName: PERSON,
      FollowUpDueDate: due.toISOString(), op_TrackOn: ['Calendar'],
    };
    const r = await page.request.post(itemsUrl, { headers: { ...J, 'content-type': 'application/json;odata=nometadata', 'X-RequestDigest': digest }, data: JSON.stringify(body) });
    const txt = await r.text();
    if (r.status() >= 300) { log(`  [FAIL] create: ${r.status()} ${txt.slice(0, 300)}`); await ctx.close(); process.exit(1); }
    const id = JSON.parse(txt).Id;
    fs.writeFileSync(STATE, JSON.stringify({ id, listId, createdDue: due.toISOString() }, null, 2));
    log(`  [OK] created item ${id}  due=${due.toISOString()} (local ${due.toString()})`);
    await runEngine();
    log('  -> check your Outlook calendar (~2 days out) for "Follow-up: GAIL-INTERNAL-WALKTHROUGH calendar test".');
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
    log('  -> the Outlook event should shift +90 min within the run. Re-run "status" to confirm shadow updated.');
  } else if (phase === 'pullcheck') {
    log('  (assumes you DRAGGED the event in Outlook) triggering engine to pull the change into the CRM…');
    await runEngine(); await page.waitForTimeout(6000);
    showItem(await getItem(readState().id));
    log('  -> CRM due should now equal the time you dragged the event to.');
  } else if (phase === 'untrack') {
    const { id } = readState();
    log(`  clearing op_TrackOn -> merge ${await merge(id, { op_TrackOn: [] })}`);
    await runEngine();
    log('  -> the Outlook event should be deleted within the run. Re-run "status": eventId should be empty.');
  } else if (phase === 'cleanup') {
    const { id } = readState();
    const r = await page.request.post(`${itemsUrl}(${id})`, { headers: { ...J, 'X-RequestDigest': digest, 'X-HTTP-Method': 'DELETE', 'IF-MATCH': '*' } });
    log(`  delete item ${id} -> ${r.status()}`);
    if (fs.existsSync(STATE)) fs.unlinkSync(STATE);
  }
  await ctx.close();
})();
