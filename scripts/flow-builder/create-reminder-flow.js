// Create the one-day-ahead follow-up REMINDER flow:
//   Daily Recurrence -> SharePoint "Get items" (Follow-up date == tomorrow) ->
//   filter out closed/converted -> if any, email Adam a heads-up table.
//
// Standard connectors only (SharePoint + Office 365 Outlook). Read-only against
// the CRM list (Get items; it never edits or closes a record). Mail recipient is
// Adam ONLY. This is the FIRST outbound-mail automation in the tenant; it is a
// scoped, logged unlock of the otherwise-fenced mail-automation capability
// (docs/CRM_FOLLOWUP_REMINDERS_AND_PLANNER.md). Tokens stay in memory.
//
// Usage:
//   node create-reminder-flow.js --dry        # discovery only: list conns, resolve
//                                              # list GUID, write planned flow body,
//                                              # POST nothing, create no connection.
//   node create-reminder-flow.js [--state=Started|Stopped] [--headless]
//                                              # ensure Outlook connection (headed,
//                                              # Adam approves consent once), then
//                                              # create/update the flow.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(CAP, { recursive: true });
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const FLOWHOST = 'api.flow.microsoft.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const RECIPIENT = 'adamgoodwin@guidedailabs.com'; // mail goes to Adam ONLY
const REMINDER_TZ = 'Mountain Standard Time';      // Adam's TZ (UTC-6/MDT); Windows id auto-adjusts DST
const REMINDER_HOUR = '7';                         // local hour the daily check runs
const DISPLAY = 'GAIL — CRM follow-up reminder (one day ahead)';
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;

const dry = process.argv.includes('--dry');
const headless = process.argv.includes('--headless');
const connectOnly = process.argv.includes('--connect-only'); // ensure Outlook conn, then stop
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: dry || headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]}). Sign-in may have lapsed; run Start-FlowBuilder.ps1 -Phase auth.`); await ctx.close(); process.exit(1); }

  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const listConnsOnce = async () => { try { return (JSON.parse((await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`)).body).value) || []; } catch { return []; } };
  // The connectivity list returns a cold empty array for a few seconds after the
  // page primes; retry until it's populated (or settle after N tries).
  const listConns = async (tries = 6) => { let c = []; for (let i = 0; i < tries; i++) { c = await listConnsOnce(); if (c.length) return c; await page.waitForTimeout(3000); } return c; };
  const findConn = (conns, api) => conns.find(c => (c.properties && c.properties.apiId || '').endsWith(api));
  const connStatus = (c) => c && c.properties && c.properties.statuses ? c.properties.statuses.map(s => s.status).join(',') : null;

  // 1) SharePoint connection must already exist (built during Path B).
  let conns = await listConns();
  const spConn = findConn(conns, 'shared_sharepointonline');
  log(`SharePoint conn: ${spConn ? `${spConn.name} (${connStatus(spConn)})` : 'MISSING'}`);
  if (!spConn) { log('ERROR: SharePoint connection missing. Build it first (Start-FlowBuilder.ps1 -Phase connections).'); await ctx.close(); process.exit(2); }

  // 2) Office 365 Outlook connection — the new, scoped capability. Create it
  //    (headed, Adam approves) if absent. In --dry we only report.
  let outlookConn = findConn(conns, 'shared_office365');
  log(`Outlook conn: ${outlookConn ? `${outlookConn.name} (${connStatus(outlookConn)})` : 'MISSING'}`);
  if (!outlookConn && !dry) {
    // Deep-link straight to the Office 365 Outlook connector so the connect button
    // is front-and-centre — no fragile row matching against a long grid.
    const banner = (m) => console.log('\n############################################################\n' + m + '\n############################################################\n');
    banner('  ACTION NEEDED — in THIS browser window (it is signed in as\n  ' + TENANT_ACCT + '):\n\n   1) Click the blue "Create" button on the Office 365 Outlook card.\n   2) Pick your account, then click "Allow"/"Accept".\n\n  Do NOT use your normal browser — only this window is in the right\n  tenant. The script will detect the connection and continue on its own.');
    for (const url of [
      `https://make.powerautomate.com/environments/${ENV}/connections/available?apiName=shared_office365`,
      `https://make.powerautomate.com/environments/${ENV}/connections/available`,
    ]) { await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {}); await page.waitForTimeout(5000); }
    for (const t of ['Accept', 'Reject']) { const b = await page.$(`button:has-text("${t}")`).catch(() => null); if (b) { await b.click().catch(() => {}); break; } }
    const search = await page.$('input[type=search], input[placeholder*="Search" i], [role=searchbox]').catch(() => null);
    if (search) { await search.click().catch(() => {}); await search.fill('Office 365 Outlook').catch(() => {}); await page.waitForTimeout(3500); }
    // Best-effort auto-click of a Create/+ control, trying several strategies; if all
    // miss, the banner above tells Adam to click it himself. Poll up to ~8 min.
    const popupP = ctx.waitForEvent('page', { timeout: 8000 }).catch(() => null);
    let clicked = null;
    for (const sel of ['button:has-text("Create")', 'button[aria-label*="Create" i]', '[role=button][aria-label*="Office 365 Outlook" i]', 'button:has-text("Add")']) {
      const el = await page.$(sel).catch(() => null);
      if (el) { await el.click({ timeout: 4000 }).catch(() => {}); clicked = sel; break; }
    }
    if (!clicked) { for (const row of await page.$$('[role=row], tr, [class*="card" i], li')) { const txt = ((await row.innerText().catch(() => '')) || '').trim(); if (/^Office 365 Outlook/i.test(txt)) { const act = await row.$('button, [role=button], a[aria-label], i[role=button]'); if (act) { await act.click({ timeout: 4000 }).catch(() => {}); clicked = 'row:Office 365 Outlook'; break; } } } }
    log(`  auto-click: ${clicked || '(none — please click Create in the window yourself)'}`);
    const popup = await popupP;
    if (popup) { log('  >>> consent window opened — pick your account / Allow. <<<'); await popup.waitForTimeout(3000).catch(() => {}); }
    log('  Waiting up to ~8 min for the Outlook connection to report Connected...');
    for (let i = 0; i < 120; i++) { conns = await listConns(1); outlookConn = findConn(conns, 'shared_office365'); const st = connStatus(outlookConn); if (i % 3 === 0 || (outlookConn && /connected/i.test(st || ''))) log(`  poll ${i}: present=${!!outlookConn} status=${st || '-'}`); if (outlookConn && /connected/i.test(st || '')) break; await page.waitForTimeout(4000); }
  }
  if (!outlookConn && !dry) { log('ERROR: Outlook connection not Connected. Re-run -Phase reminder after the Create/Allow click.'); await ctx.close(); process.exit(3); }
  if (connectOnly) { log(`CONNECT-ONLY done. Outlook conn: ${outlookConn.name} (${connStatus(outlookConn)}). Now run the build (headless ok).`); await ctx.close(); return; }

  // 3) Resolve the list GUID via SharePoint REST (uses the persisted M365 session).
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const bodyTxt = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(bodyTxt)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(8000); } }
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) { log('ERROR: could not resolve list GUID'); await ctx.close(); process.exit(4); }

  // 4) Build the flow definition.
  //    OData $filter (date-only, reliable): Follow-up date in [tomorrow, day-after).
  //    Status exclusion is done IN-FLOW (Filter array) so a choice-column quirk can
  //    never break the SharePoint query.
  const tomorrow = `formatDateTime(addDays(startOfDay(utcNow()),1),'yyyy-MM-ddTHH:mm:ssZ')`;
  const dayAfter = `formatDateTime(addDays(startOfDay(utcNow()),2),'yyyy-MM-ddTHH:mm:ssZ')`;
  const filterExpr = `@concat('FollowUpDueDate ge ''', ${tomorrow}, ''' and FollowUpDueDate lt ''', ${dayAfter}, '''')`;

  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: {
      Daily_check: {
        type: 'Recurrence',
        recurrence: { frequency: 'Day', interval: 1, timeZone: REMINDER_TZ, schedule: { hours: [REMINDER_HOUR], minutes: [0] } },
      },
    },
    actions: {
      Get_signals_due_tomorrow: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_sharepointonline', operationId: 'GetItems', apiId: apiId('shared_sharepointonline') },
          parameters: { dataset: SITE, table: listId, $filter: filterExpr, $orderby: 'FollowUpDueDate asc', $top: 100 },
          authentication: "@parameters('$authentication')",
        },
      },
      Filter_open_signals: {
        runAfter: { Get_signals_due_tomorrow: ['Succeeded'] },
        type: 'Query',
        inputs: {
          from: "@outputs('Get_signals_due_tomorrow')?['body/value']",
          where: "@not(or(equals(coalesce(item()?['SignalStatus']?['Value'],''),'Closed'),equals(coalesce(item()?['SignalStatus']?['Value'],''),'Converted')))",
        },
      },
      Select_rows: {
        runAfter: { Filter_open_signals: ['Succeeded'] },
        type: 'Select',
        inputs: {
          from: "@body('Filter_open_signals')",
          select: {
            Signal: "@item()?['Title']",
            Person: "@item()?['PersonName']",
            Organization: "@item()?['OrganizationName']",
            'Follow-up date': "@item()?['FollowUpDueDate']",
            Priority: "@item()?['Priority']?['Value']",
            'Next action': "@item()?['NextAction']",
            Open: "@item()?['{Link}']",
          },
        },
      },
      Any_due_tomorrow: {
        runAfter: { Select_rows: ['Succeeded'] },
        type: 'If',
        expression: { greater: ["@length(body('Filter_open_signals'))", 0] },
        actions: {
          Create_HTML_table: {
            runAfter: {},
            type: 'Table',
            inputs: { from: "@body('Select_rows')", format: 'HTML' },
          },
          Send_reminder_email: {
            runAfter: { Create_HTML_table: ['Succeeded'] },
            type: 'OpenApiConnection',
            inputs: {
              host: { connectionName: 'shared_office365', operationId: 'SendEmailV2', apiId: apiId('shared_office365') },
              parameters: {
                'emailMessage/To': RECIPIENT,
                'emailMessage/Subject': "@concat('CRM follow-ups due tomorrow (', length(body('Filter_open_signals')), ')')",
                'emailMessage/Body': "@concat('<p>These CRM signals have a follow-up due <b>tomorrow</b>:</p>', body('Create_HTML_table'), '<p style=\"color:#888;font-size:12px\">Automated one-day-ahead reminder from the CRM - New Signals list. Open each signal to action or reschedule.</p>')",
                'emailMessage/Importance': 'Normal',
              },
              authentication: "@parameters('$authentication')",
            },
          },
        },
        else: { actions: {} },
      },
    },
  };

  const connectionReferences = {
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
    shared_office365: { connectionName: outlookConn ? outlookConn.name : '__PENDING_OUTLOOK_CONNECTION__', source: 'Embedded', id: apiId('shared_office365'), tier: 'NotSpecified' },
  };

  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  fs.writeFileSync(path.join(CAP, 'flow-body-reminder.json'), JSON.stringify(flowBody, null, 2));
  log('wrote planned flow body -> .local/flow-builder/capture/flow-body-reminder.json');

  if (dry) { log('DRY RUN: no flow created. Review the planned body above.'); await ctx.close(); return; }

  // 5) Create (or PATCH if a prior result exists) the flow.
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-reminder.json');
  let existingName = null;
  if (fs.existsSync(resultPath)) { try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {} }
  let cr, created, flowName;
  if (existingName) {
    log(`updating existing reminder flow (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
  } else {
    log(`creating reminder flow: ${DISPLAY}`);
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
  }
  log(`  -> ${cr.status}`);
  fs.writeFileSync(path.join(CAP, 'flow-create-reminder.json'), `status: ${cr.status}\n\n${cr.body}`);
  if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1500)); await ctx.close(); process.exit(5); }
  created = JSON.parse(cr.body);
  flowName = created.name || existingName;
  const result = {
    purpose: 'one-day-ahead CRM follow-up reminder', flowName, displayName: DISPLAY, listId,
    recipient: RECIPIENT, timeZone: REMINDER_TZ, hour: REMINDER_HOUR,
    state: created.properties && created.properties.state, createdStatus: cr.status,
    spConnection: spConn.name, outlookConnection: outlookConn.name,
  };
  fs.writeFileSync(resultPath, JSON.stringify(result, null, 2));
  log(`RESULT: flow=${flowName} state=${result.state}`);
  log('wrote inventory/forms-build/flow-result-reminder.json');
  await ctx.close();
})();
