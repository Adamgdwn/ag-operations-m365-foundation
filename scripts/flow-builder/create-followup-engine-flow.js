// Operations Follow-up & Task Backbone — the sync ENGINE flow (email layer first).
//
// docs/OPERATIONS_FOLLOWUP_BACKBONE.md. This replaces the old one-day-ahead daily
// reminder. One flow on a 15-minute Recurrence; for every open signal that has a
// Follow-up date and >=1 ticked Reminder, it computes minutes-until-due and emails
// the OWNER when a ticked relative-offset window is hit:
//   '1 day before'      -> minutesUntil in [1440, 1455)
//   '30 minutes before' -> [30, 45)
//   'Day after'         -> [-1440, -1425)
// Window width == recurrence interval (15 min) => exactly-once per offset, no dedup
// state, timezone-independent (offsets are relative). Read-only on the CRM in this
// layer (the calendar + Planner two-way layer is added next, as a PATCH to this same
// flow). Standard connectors only: SharePoint (existing) + Office 365 Outlook
// (existing). Mail goes to each signal's Owner (coalesced to Adam if Owner is empty).
//
// Usage:
//   node create-followup-engine-flow.js --dry     # discovery + write planned body, POST nothing
//   node create-followup-engine-flow.js [--state=Started|Stopped] [--headless]
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
const FALLBACK_OWNER = 'adamgoodwin@guidedailabs.com'; // if a signal has no Owner
const DISPLAY = 'GAIL — Operations follow-up engine';
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;

// Planner layer is GATED on the registry: it is added to the flow only when BOTH
// groupId and planId are present for the CRM row. Until Adam's consent session fills
// them in, this stays null and the deployed flow is byte-identical to the email+calendar
// flow that is already live. (groupId + planId are both required by CreateTask_V4 and
// ListBuckets_V3.)
const REGISTRY = JSON.parse(fs.readFileSync(path.join(REPO, 'config', 'followup.registry.json'), 'utf8'));
const CRM_ROW = (REGISTRY.lists || []).find(l => l.key === 'crm-new-signals') || {};
const PLANNER = CRM_ROW.planner || {};
const PLAN_ID = PLANNER.planId || null;
const GROUP_ID = PLANNER.groupId || null;
const PLANNER_ACTIVE = !!(PLAN_ID && GROUP_ID);

const dry = process.argv.includes('--dry');
const headless = process.argv.includes('--headless');
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];

// Relative-offset windows (minutes). [lo, hi) with hi-lo == recurrence interval.
const OFFSETS = [
  { choice: '1 day before', lo: 1440, hi: 1455, label: 'tomorrow', when: 'due in ~1 day' },
  { choice: '30 minutes before', lo: 30, hi: 45, label: 'in ~30 minutes', when: 'due in ~30 minutes' },
  { choice: 'Day after', lo: -1440, hi: -1425, label: 'yesterday (overdue)', when: 'was due yesterday' },
];

// item() helpers reused across the per-offset condition blocks.
const DUE = "item()?['FollowUpDueDate']";
const MINS = "@div(sub(ticks(item()?['FollowUpDueDate']), ticks(utcNow())), 600000000)";
const OPEN = "@not(or(equals(coalesce(item()?['SignalStatus']?['Value'],''),'Closed'),equals(coalesce(item()?['SignalStatus']?['Value'],''),'Converted')))";
const OWNER_TO = "@coalesce(item()?['ItemOwner']?['Email'], '" + FALLBACK_OWNER + "')";
// MultiChoice is stringified so membership works whether the connector returns an
// array of strings or of objects.
const hasChoice = (c) => `@contains(string(coalesce(item()?['op_Reminders'],'')), '${c}')`;

// ---------------------------------------------------------------------------
// Calendar two-way layer (5b). Delegation model: each follow-up event lives on
// the OWNER's own calendar. v1 = the automation account's default calendar
// (resolved at top via Get_calendars). Conflict rule = CRM-wins (predictable,
// matches "CRM is master"): if the CRM date moved we push it to the calendar;
// only if the CRM date did NOT move do we pull a calendar drag back into the CRM.
// Loop-safe via the op_LastSyncedDue shadow + a >1-min change tolerance.
// ---------------------------------------------------------------------------
const CAL_TRACK = "@contains(string(coalesce(item()?['op_TrackOn'],'')), 'Calendar')";
const CAL_HASID = "@not(empty(coalesce(item()?['op_CalendarEventId'], '')))";
const CALID_REF = "@outputs('Compose_calendar_id')";
const EVENTID_REF = "item()?['op_CalendarEventId']";
const TITLE_EXPR = "coalesce(item()?['Title'],'(untitled signal)')";
const DUE_PLAIN = "formatDateTime(item()?['FollowUpDueDate'],'yyyy-MM-ddTHH:mm:ss')";          // event start, tz=UTC
const DUE_END_PLAIN = "formatDateTime(addMinutes(item()?['FollowUpDueDate'],30),'yyyy-MM-ddTHH:mm:ss')";
const DUE_UTC = "concat(formatDateTime(item()?['FollowUpDueDate'],'yyyy-MM-ddTHH:mm:ss'),'Z')"; // shadow write (UTC ISO)
// startWithTimeZone carries the offset, so ticks()/writeback are timezone-proof regardless
// of the connector's default time zone.
const EVENT_START = "body('Get_event')?['startWithTimeZone']";
const SHADOW_REF = "coalesce(item()?['op_LastSyncedDue'],'1900-01-01T00:00:00Z')";
const EVENT_BODY =
  "@concat('<p>CRM follow-up (synced from CRM - New Signals; drag to reschedule).</p><ul>'," +
  "'<li><b>Person:</b> ', coalesce(item()?['PersonName'],''),'</li>'," +
  "'<li><b>Organization:</b> ', coalesce(item()?['OrganizationName'],''),'</li>'," +
  "'<li><b>Next action:</b> ', coalesce(item()?['NextAction'],''),'</li></ul>'," +
  "'<p><a href=\"', coalesce(item()?['{Link}'],''),'\">Open the signal</a></p>')";

// |ticks(a) - ticks(b)| > 1 minute  =>  treat as a real change (absorbs sub-minute round-trip drift).
function changedExpr(aExpr, bExpr) {
  const d = `@sub(ticks(${aExpr}),ticks(${bExpr}))`;
  return { or: [{ greater: [d, 600000000] }, { less: [d, -600000000] }] };
}

// Field-scoped writeback via "Send an HTTP request to SharePoint" (MERGE). Avoids the
// connector's Update-item required-field demands; only the named fields are touched.
function spMerge(listId, actionName, runAfter, pairs) {
  let parts = ["'{'"];
  pairs.forEach(([k, v], i) => { parts.push(`'${i ? ',' : ''}\"${k}\":\"'`); parts.push(v); parts.push("'\"'"); });
  parts.push("'}'");
  return {
    [actionName]: {
      runAfter,
      type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_sharepointonline', operationId: 'HttpRequest', apiId: apiId('shared_sharepointonline') },
        parameters: {
          dataset: SITE,
          'parameters/method': 'POST',
          'parameters/uri': `@concat('_api/web/lists(guid''${listId}'')/items(', string(item()?['ID']), ')')`,
          'parameters/headers': { 'X-HTTP-Method': 'MERGE', 'IF-MATCH': '*', 'Accept': 'application/json;odata=nometadata', 'Content-Type': 'application/json;odata=nometadata' },
          'parameters/body': '@concat(' + parts.join(', ') + ')',
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
}

function buildCalendarActions(listId) {
  const createEvent = {
    Create_event: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365', operationId: 'V4CalendarPostItem', apiId: apiId('shared_office365') },
        parameters: {
          table: CALID_REF,
          'item/subject': `@concat('Follow-up: ', ${TITLE_EXPR})`,
          'item/start': `@${DUE_PLAIN}`,
          'item/end': `@${DUE_END_PLAIN}`,
          'item/timeZone': '(UTC) Coordinated Universal Time',
          'item/body': EVENT_BODY,
          'item/isReminderOn': true,
          'item/reminderMinutesBeforeStart': 15,
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  const updateEvent = {
    Update_event: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365', operationId: 'V4CalendarPatchItem', apiId: apiId('shared_office365') },
        parameters: {
          table: CALID_REF, id: `@${EVENTID_REF}`,
          'item/subject': `@concat('Follow-up: ', ${TITLE_EXPR})`,
          'item/start': `@${DUE_PLAIN}`,
          'item/end': `@${DUE_END_PLAIN}`,
          'item/timeZone': '(UTC) Coordinated Universal Time',
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  const getEvent = {
    Get_event: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365', operationId: 'V3CalendarGetItem', apiId: apiId('shared_office365') },
        parameters: { table: CALID_REF, id: `@${EVENTID_REF}` },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  const deleteEvent = {
    Delete_event: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365', operationId: 'CalendarDeleteItem_V2', apiId: apiId('shared_office365') },
        parameters: { calendar: CALID_REF, event: `@${EVENTID_REF}` },
        authentication: "@parameters('$authentication')",
      },
    },
  };

  return {
    // CREATE: tracked + open + no event yet.
    Cal_create: {
      runAfter: { Compose_open: ['Succeeded'] }, type: 'If',
      expression: { and: [{ equals: [CAL_TRACK, true] }, { equals: [OPEN, true] }, { equals: [CAL_HASID, false] }] },
      actions: Object.assign({}, createEvent, spMerge(listId, 'Hub_after_create', { Create_event: ['Succeeded'] }, [
        ['op_CalendarEventId', "body('Create_event')?['id']"],
        ['op_LastSyncedDue', DUE_UTC],
        ['op_SyncNote', "concat('calendar event created ',utcNow())"],
      ])),
      else: { actions: {} },
    },
    // RECONCILE: tracked + open + event exists -> CRM-wins two-way on date.
    Cal_reconcile: {
      runAfter: { Compose_open: ['Succeeded'] }, type: 'If',
      expression: { and: [{ equals: [CAL_TRACK, true] }, { equals: [OPEN, true] }, { equals: [CAL_HASID, true] }] },
      actions: Object.assign({}, getEvent, {
        Due_changed: {
          runAfter: { Get_event: ['Succeeded'] }, type: 'If',
          expression: changedExpr("item()?['FollowUpDueDate']", SHADOW_REF),
          actions: Object.assign({}, updateEvent, spMerge(listId, 'Hub_after_push', { Update_event: ['Succeeded'] }, [
            ['op_LastSyncedDue', DUE_UTC],
            ['op_SyncNote', "concat('pushed CRM date to calendar ',utcNow())"],
          ])),
          else: {
            actions: {
              Event_changed: {
                runAfter: {}, type: 'If',
                expression: changedExpr(EVENT_START, SHADOW_REF),
                actions: spMerge(listId, 'Hub_after_pull', {}, [
                  ['FollowUpDueDate', EVENT_START],
                  ['op_LastSyncedDue', EVENT_START],
                  ['op_SyncNote', "concat('pulled calendar move into CRM ',utcNow())"],
                ]),
                else: { actions: {} },
              },
            },
          },
        },
      }),
      else: { actions: {} },
    },
    // TEARDOWN: event exists but no longer tracked or no longer open -> delete + clear id.
    Cal_teardown: {
      runAfter: { Compose_open: ['Succeeded'] }, type: 'If',
      expression: { and: [{ equals: [CAL_HASID, true] }, { or: [{ equals: [CAL_TRACK, false] }, { equals: [OPEN, false] }] }] },
      actions: Object.assign({}, deleteEvent, spMerge(listId, 'Hub_after_delete', { Delete_event: ['Succeeded', 'Failed'] }, [
        ['op_CalendarEventId', "''"],
        ['op_SyncNote', "concat('calendar event removed ',utcNow())"],
      ])),
      else: { actions: {} },
    },
  };
}

// ---------------------------------------------------------------------------
// Planner layer (5b, hub-driven ONE-WAY: CRM -> Planner). Unlike the calendar layer
// (two-way on the date), Planner is driven entirely from the CRM hub: the engine
// creates a task assigned to the owner, pushes the CRM due onto it when the CRM date
// moves, and deletes it on untrack/close. Standard connectors only: shared_planner +
// shared_office365users (email -> AAD id for assignment). Multi-operator personalisation
// is free via assignment: an assigned task surfaces in that owner's Planner "Assigned to
// me" and rolls up into their Microsoft To Do — no per-mailbox write, no Graph app.
//
// Loop-safety: Planner reuses the same op_LastSyncedDue shadow as the calendar layer.
// The Plan_* blocks run AFTER the Cal_* blocks (runAfter), so the two layers' SharePoint
// MERGE writes are serialised within an iteration (never a concurrent write to the same
// item), and both write the identical DUE_UTC value, so order does not matter.
const PLAN_TRACK = "@contains(string(coalesce(item()?['op_TrackOn'],'')), 'Planner')";
const PLAN_HASID = "@not(empty(coalesce(item()?['op_PlannerTaskId'], '')))";
const PLAN_TASKID = "item()?['op_PlannerTaskId']";

function buildPlannerActions(listId) {
  const createTask = {
    Create_task: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_planner', operationId: 'CreateTask_V4', apiId: apiId('shared_planner') },
        parameters: {
          'body/groupId': GROUP_ID,
          'body/planId': PLAN_ID,
          'body/title': `@concat('Follow-up: ', ${TITLE_EXPR})`,
          'body/bucketId': "@outputs('Compose_bucket_id')",
          'body/dueDateTime': `@${DUE_UTC}`,
          // Assigned User Ids (AAD object id). Empty string => unassigned (owner unresolved).
          'body/assignments': "@coalesce(body('Get_owner_aad')?['id'], '')",
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  const updateTask = {
    Update_task: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_planner', operationId: 'UpdateTask_V3', apiId: apiId('shared_planner') },
        parameters: {
          id: `@${PLAN_TASKID}`,
          'body/title': `@concat('Follow-up: ', ${TITLE_EXPR})`,
          'body/dueDateTime': `@${DUE_UTC}`,
          'body/bucketId': "@outputs('Compose_bucket_id')",
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  const deleteTask = {
    Delete_task: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_planner', operationId: 'DeleteTask', apiId: apiId('shared_planner') },
        parameters: { id: `@${PLAN_TASKID}` },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  // All three plan branches wait for the per-item prep (owner AAD + bucket) and for the
  // calendar branches, so SharePoint MERGE writes never race.
  const planRunAfter = {
    Compose_bucket_id: ['Succeeded'],
    Get_owner_aad: ['Succeeded', 'Failed'],
    Cal_create: ['Succeeded'], Cal_reconcile: ['Succeeded'], Cal_teardown: ['Succeeded'],
  };

  return {
    // CREATE: tracked + open + no task yet.
    Plan_create: {
      runAfter: planRunAfter, type: 'If',
      expression: { and: [{ equals: [PLAN_TRACK, true] }, { equals: [OPEN, true] }, { equals: [PLAN_HASID, false] }] },
      actions: Object.assign({}, createTask, spMerge(listId, 'Hub_after_task_create', { Create_task: ['Succeeded'] }, [
        ['op_PlannerTaskId', "body('Create_task')?['id']"],
        ['op_LastSyncedDue', DUE_UTC],
        ['op_SyncNote', "concat('planner task created ',utcNow())"],
      ])),
      else: { actions: {} },
    },
    // UPDATE: tracked + open + task exists + CRM due moved vs the shadow -> push due (one-way).
    Plan_update: {
      runAfter: planRunAfter, type: 'If',
      expression: {
        and: [
          { equals: [PLAN_TRACK, true] }, { equals: [OPEN, true] }, { equals: [PLAN_HASID, true] },
          changedExpr("item()?['FollowUpDueDate']", SHADOW_REF),
        ],
      },
      actions: Object.assign({}, updateTask, spMerge(listId, 'Hub_after_task_update', { Update_task: ['Succeeded'] }, [
        ['op_LastSyncedDue', DUE_UTC],
        ['op_SyncNote', "concat('pushed CRM date to planner ',utcNow())"],
      ])),
      else: { actions: {} },
    },
    // TEARDOWN: task exists but no longer tracked or no longer open -> delete + clear id.
    Plan_teardown: {
      runAfter: planRunAfter, type: 'If',
      expression: { and: [{ equals: [PLAN_HASID, true] }, { or: [{ equals: [PLAN_TRACK, false] }, { equals: [OPEN, false] }] }] },
      actions: Object.assign({}, deleteTask, spMerge(listId, 'Hub_after_task_delete', { Delete_task: ['Succeeded', 'Failed'] }, [
        ['op_PlannerTaskId', "''"],
        ['op_SyncNote', "concat('planner task removed ',utcNow())"],
      ])),
      else: { actions: {} },
    },
  };
}

// Per-item prep actions the Planner branches depend on (owner email -> AAD id, and the
// per-priority bucket pick from the once-fetched bucket list).
function buildPlannerPrep() {
  return {
    Compose_priority: {
      runAfter: {}, type: 'Compose',
      inputs: "@coalesce(item()?['Priority']?['Value'], '')",
    },
    Get_owner_aad: {
      runAfter: {}, type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365users', operationId: 'UserProfile_V2', apiId: apiId('shared_office365users') },
        parameters: { id: OWNER_TO, '$select': 'id,displayName,mail' },
        authentication: "@parameters('$authentication')",
      },
    },
    Filter_bucket: {
      runAfter: { Compose_priority: ['Succeeded'] }, type: 'Query',
      inputs: {
        from: "@outputs('List_buckets')?['body/value']",
        where: "@equals(toLower(coalesce(item()?['name'],'')), toLower(coalesce(outputs('Compose_priority'),'')))",
      },
    },
    Compose_bucket_id: {
      runAfter: { Filter_bucket: ['Succeeded'] }, type: 'Compose',
      inputs: "@coalesce(first(body('Filter_bucket'))?['id'], first(outputs('List_buckets')?['body/value'])?['id'])",
    },
  };
}

function buildOffsetIf(offset, idx) {
  const send = {
    [`Send_${idx}`]: {
      runAfter: {},
      type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_office365', operationId: 'SendEmailV2', apiId: apiId('shared_office365') },
        parameters: {
          'emailMessage/To': OWNER_TO,
          'emailMessage/Subject': `@concat('Follow-up ${offset.label}: ', coalesce(item()?['Title'],'(untitled signal)'))`,
          'emailMessage/Body':
            "@concat('<p>This CRM signal " + offset.when + ":</p><ul>'," +
            "'<li><b>Signal:</b> ', coalesce(item()?['Title'],''), '</li>'," +
            "'<li><b>Person:</b> ', coalesce(item()?['PersonName'],''), '</li>'," +
            "'<li><b>Organization:</b> ', coalesce(item()?['OrganizationName'],''), '</li>'," +
            "'<li><b>Follow-up:</b> ', coalesce(item()?['FollowUpDueDate'],''), '</li>'," +
            "'<li><b>Next action:</b> ', coalesce(item()?['NextAction'],''), '</li></ul>'," +
            "'<p><a href=\"', coalesce(item()?['{Link}'],''), '\">Open the signal</a></p>'," +
            "'<p style=\"color:#888;font-size:12px\">Operations follow-up engine. Reminder offset: " + offset.choice + ".</p>')",
          'emailMessage/Importance': 'Normal',
        },
        authentication: "@parameters('$authentication')",
      },
    },
  };
  return {
    [`Offset_${idx}`]: {
      runAfter: { Compose_open: ['Succeeded'] },
      type: 'If',
      expression: {
        and: [
          { equals: [OPEN, true] },
          { equals: [hasChoice(offset.choice), true] },
          { greaterOrEquals: [MINS, offset.lo] },
          { less: [MINS, offset.hi] },
        ],
      },
      actions: send,
      else: { actions: {} },
    },
  };
}

(async () => {
  // --dry no longer forces headless: a dry run in a visible window can refresh a
  // stale sign-in. Headless is opt-in via --headless (use only when the session is warm).
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]}). Run Start-FlowBuilder.ps1 -Phase auth.`); await ctx.close(); process.exit(1); }

  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const listConnsOnce = async () => { try { return (JSON.parse((await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`)).body).value) || []; } catch { return []; } };
  const listConns = async (tries = 6) => { let c = []; for (let i = 0; i < tries; i++) { c = await listConnsOnce(); if (c.length) return c; await page.waitForTimeout(3000); } return c; };
  const findConn = (conns, api) => conns.find(c => (c.properties && c.properties.apiId || '').endsWith(api));
  const connStatus = (c) => c && c.properties && c.properties.statuses ? c.properties.statuses.map(s => s.status).join(',') : null;

  const conns = await listConns();
  const spConn = findConn(conns, 'shared_sharepointonline');
  const outlookConn = findConn(conns, 'shared_office365');
  log(`SharePoint conn: ${spConn ? `${spConn.name} (${connStatus(spConn)})` : 'MISSING'}`);
  log(`Outlook conn:    ${outlookConn ? `${outlookConn.name} (${connStatus(outlookConn)})` : 'MISSING'}`);
  if (!spConn || !outlookConn) { log('ERROR: email layer needs the existing SharePoint + Office 365 Outlook connections.'); await ctx.close(); process.exit(2); }

  // Planner layer is added only when the registry has BOTH groupId and planId.
  log(`Planner layer: ${PLANNER_ACTIVE ? `ACTIVE (group=${GROUP_ID}, plan=${PLAN_ID})` : 'INACTIVE (registry planner.groupId/planId not set) — building email+calendar only'}`);
  let plannerConn = null, usersConn = null;
  if (PLANNER_ACTIVE) {
    plannerConn = findConn(conns, 'shared_planner');
    usersConn = findConn(conns, 'shared_office365users');
    log(`Planner conn:    ${plannerConn ? `${plannerConn.name} (${connStatus(plannerConn)})` : 'MISSING'}`);
    log(`Users conn:      ${usersConn ? `${usersConn.name} (${connStatus(usersConn)})` : 'MISSING'}`);
    if (!plannerConn || !usersConn) {
      log('ERROR: Planner layer is registry-active but its connections are missing. Run the consent session first:');
      log('       node scripts/flow-builder/create-connections.js --only=planner,office365users --headed');
      await ctx.close(); process.exit(3);
    }
  }

  // Resolve list GUID via SharePoint REST (persisted M365 session).
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) { log('ERROR: could not resolve list GUID'); await ctx.close(); process.exit(4); }

  // Build the per-signal action set: email offsets (5a) + calendar two-way (5b)
  // + planner one-way (5b, when registry-active).
  const offsetActions = {};
  OFFSETS.forEach((o, i) => Object.assign(offsetActions, buildOffsetIf(o, i)));
  const calendarActions = buildCalendarActions(listId);
  const plannerPrep = PLANNER_ACTIVE ? buildPlannerPrep() : {};
  const plannerActions = PLANNER_ACTIVE ? buildPlannerActions(listId) : {};

  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: {
      Every_15_min: { type: 'Recurrence', recurrence: { frequency: 'Minute', interval: 15 } },
    },
    actions: {
      Get_dated_signals: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_sharepointonline', operationId: 'GetItems', apiId: apiId('shared_sharepointonline') },
          parameters: { dataset: SITE, table: listId, $filter: 'FollowUpDueDate ne null', $orderby: 'FollowUpDueDate asc', $top: 500 },
          authentication: "@parameters('$authentication')",
        },
      },
      // Resolve the owner's calendar id (v1 = automation account's default calendar).
      Get_calendars: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_office365', operationId: 'CalendarGetTables_V2', apiId: apiId('shared_office365') },
          parameters: {},
          authentication: "@parameters('$authentication')",
        },
      },
      // 'filter' is not a workflow expression function — use the Filter array (Query) action.
      Filter_default_calendar: {
        runAfter: { Get_calendars: ['Succeeded'] },
        type: 'Query',
        inputs: {
          from: "@outputs('Get_calendars')?['body/value']",
          where: "@equals(toLower(coalesce(item()?['name'],'')), 'calendar')",
        },
      },
      Compose_calendar_id: {
        runAfter: { Filter_default_calendar: ['Succeeded'] },
        type: 'Compose',
        inputs: "@coalesce(first(body('Filter_default_calendar'))?['id'], first(outputs('Get_calendars')?['body/value'])?['id'])",
      },
      // Planner buckets are fetched ONCE per run (when the Planner layer is active);
      // each item picks its bucket from this list by Priority name.
      ...(PLANNER_ACTIVE ? {
        List_buckets: {
          runAfter: {}, type: 'OpenApiConnection',
          inputs: {
            host: { connectionName: 'shared_planner', operationId: 'ListBuckets_V3', apiId: apiId('shared_planner') },
            parameters: { groupId: GROUP_ID, id: PLAN_ID },
            authentication: "@parameters('$authentication')",
          },
        },
      } : {}),
      For_each_signal: {
        runAfter: Object.assign(
          { Get_dated_signals: ['Succeeded'], Compose_calendar_id: ['Succeeded'] },
          PLANNER_ACTIVE ? { List_buckets: ['Succeeded'] } : {},
        ),
        type: 'Foreach',
        foreach: "@outputs('Get_dated_signals')?['body/value']",
        actions: Object.assign(
          {
            Compose_open: { runAfter: {}, type: 'Compose', inputs: OPEN },
          },
          offsetActions,
          calendarActions,
          plannerPrep,
          plannerActions,
        ),
        runtimeConfiguration: { concurrency: { repetitions: 1 } },
      },
    },
  };

  const connectionReferences = Object.assign(
    {
      shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
      shared_office365: { connectionName: outlookConn.name, source: 'Embedded', id: apiId('shared_office365'), tier: 'NotSpecified' },
    },
    PLANNER_ACTIVE ? {
      shared_planner: { connectionName: plannerConn.name, source: 'Embedded', id: apiId('shared_planner'), tier: 'NotSpecified' },
      shared_office365users: { connectionName: usersConn.name, source: 'Embedded', id: apiId('shared_office365users'), tier: 'NotSpecified' },
    } : {},
  );

  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  fs.writeFileSync(path.join(CAP, 'flow-body-engine.json'), JSON.stringify(flowBody, null, 2));
  log('wrote planned flow body -> .local/flow-builder/capture/flow-body-engine.json');

  if (dry) { log('DRY RUN: no flow created.'); await ctx.close(); return; }

  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-engine.json');
  let existingName = null;
  if (fs.existsSync(resultPath)) { try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {} }
  let cr;
  if (existingName) { log(`updating existing engine flow (${existingName})`); cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody); }
  else { log(`creating engine flow: ${DISPLAY}`); cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody); }
  log(`  -> ${cr.status}`);
  fs.writeFileSync(path.join(CAP, 'flow-create-engine.json'), `status: ${cr.status}\n\n${cr.body}`);
  if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1800)); await ctx.close(); process.exit(5); }
  const created = JSON.parse(cr.body);
  const flowName = created.name || existingName;
  const result = {
    purpose: 'Operations follow-up engine (email + calendar' + (PLANNER_ACTIVE ? ' + planner' : '') + ' layers)',
    flowName, displayName: DISPLAY, listId,
    state: created.properties && created.properties.state, createdStatus: cr.status,
    spConnection: spConn.name, outlookConnection: outlookConn.name,
    plannerLayer: PLANNER_ACTIVE ? { plannerConnection: plannerConn.name, usersConnection: usersConn.name, groupId: GROUP_ID, planId: PLAN_ID } : 'inactive (registry planner.groupId/planId not set)',
    offsets: OFFSETS.map(o => o.choice),
  };
  fs.writeFileSync(resultPath, JSON.stringify(result, null, 2));
  log(`RESULT: flow=${flowName} state=${result.state}`);
  log('wrote inventory/forms-build/flow-result-engine.json');
  await ctx.close();
})();
