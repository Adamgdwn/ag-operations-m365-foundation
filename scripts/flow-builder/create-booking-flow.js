// Create the create-only BOOKING intake flow:
//   Microsoft Bookings "When an appointment is Created" (CreateAppointment trigger on the
//   Guided AI Labs shared page SMTP) -> SharePoint Create item in "CRM - New Signals".
// Standard connectors only (shared_microsoftbookings is STANDARD); create-only; no deletes,
// updates, or mail. The appointment payload is IN the trigger output (no Get-details step,
// unlike the Forms flow). Resolves the Bookings + SharePoint connections + list GUID at
// runtime, then POSTs/PATCHes the flow. Tokens stay in memory.
//
// PREREQ: a Microsoft Bookings connection must exist (one consent click by Adam in
//   make.powerautomate.com > Connections > + New > "Microsoft Bookings"). Until then this
//   script exits with a clear message. Only a Bookings ADMIN can create appointment-trigger
//   flows (Adam is); max 5 flows/mailbox (we use 1).
//
// Usage: node create-booking-flow.js [--state=Started|Stopped]
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
const BOOKING_SMTP = 'GuidedAILabs1@agoperations.ca';
const OWNER_EMAIL = 'adamgoodwin@guidedailabs.com';
const DISPLAY = 'GAIL — Bookings to CRM (create-only)';
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];

const NL = "decodeUriComponent('%0A')";
const a = (f) => `triggerOutputs()?['body/${f}']`;
const staff0 = (prop) => `first(${a('StaffMembers')})?['${prop}']`;

(async () => {
  // TOKEN CAPTURE — WARM-INSTANCE (CDP) MODE (Adam's fix):
  // Power Automate's SPA caches data and only issues fresh token-bearing API calls intermittently
  // on a COLD launch, which makes headless header-interception flaky. The reliable fix is to run
  // against a WARM, already-signed-in HEADED Edge instance kept open and reused: start it once with
  // scripts/flow-builder/warm-edge.js (launches msedge --remote-debugging-port=9222 on the signed-in
  // profile and navigates to Power Automate), then this script connects to it over CDP and drives
  // the SPA in a real browser that actually issues tokens. Set CDP_PORT to enable (default 9222).
  // If CDP connect fails, fall back to the old cold persistent-context launch (headed, not headless).
  const CDP_PORT = process.env.CDP_PORT || '9222';
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT} (contexts=${browser.contexts().length})`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); falling back to cold headed launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const page = ctx.pages()[0] || await ctx.newPage();
  // Only tear down a context WE launched; for the warm Edge, do NOTHING (let the node process
  // exit, which detaches CDP without killing Edge — so it stays warm for the next run).
  const done = async () => { try { if (ownCtx) await ctx.close(); } catch {} };
  const tokens = {};
  page.on('request', req => { const au = req.headers()['authorization']; if (au && /^bearer /i.test(au)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = au.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  for (let i = 0; i < 5 && (!tokens[EHOST] || !tokens[FLOWHOST]); i++) { await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {}); await page.waitForTimeout(7000); }
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]}); hosts=${Object.keys(tokens).join(',')}`); await done(); process.exit(1); }
  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };

  // 1) Resolve connections (Bookings consent is the one prerequisite). Retry — the list can
  //    come back empty on the first call right after token capture.
  let cl = { value: [] };
  for (let i = 0; i < 5 && (cl.value || []).length === 0; i++) {
    const raw = await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`);
    try { cl = JSON.parse(raw.body); } catch { cl = { value: [] }; }
    log(`connections GET #${i}: status=${raw.status} count=${(cl.value || []).length}`);
    if ((cl.value || []).length === 0) await page.waitForTimeout(3000);
  }
  const findConn = (api) => (cl.value || []).find(c => (c.properties && c.properties.apiId || '').endsWith(api));
  const spConn = findConn('shared_sharepointonline');
  const bkConn = findConn('shared_microsoftbookings');
  log(`SharePoint conn: ${spConn ? spConn.name : 'MISSING'} | Bookings conn: ${bkConn ? bkConn.name : 'MISSING'}`);
  if (!bkConn) {
    log('BLOCKED: no Microsoft Bookings connection found. Adam must add it once:');
    log('  make.powerautomate.com > Connections > + New connection > search "Microsoft Bookings" > Create (one consent).');
    log('  Then re-run this script. (Run scripts/flow-builder/open-bookings-consent.js to open that page.)');
    await done(); process.exit(2);
  }
  if (!spConn) { log('ERROR: SharePoint connection missing.'); await done(); process.exit(2); }

  // 2) Resolve the list GUID via SharePoint REST (persisted M365 session).
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const b = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(b)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(8000); } }
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) { log('ERROR: could not resolve list GUID'); await done(); process.exit(3); }

  // 3) Build the flow definition.
  const titleExpr = `@concat('Guided AI Labs — booking — ', coalesce(${a('CustomerName')}, ${a('CustomerEmail')}, 'New booking'))`;
  const ownerClaims = `@concat('i:0#.f|membership|', coalesce(${staff0('EmailAddress')}, '${OWNER_EMAIL}'))`;
  const sourceTextExpr = `@concat(` +
    `'Service: ', coalesce(${a('ServiceName')},''), ${NL}, ` +
    `'Start: ', coalesce(${a('StartTime')},''), ${NL}, ` +
    `'End: ', coalesce(${a('EndTime')},''), ${NL}, ` +
    `'Duration (min): ', coalesce(string(${a('Duration')}),''), ${NL}, ` +
    `'Teams link: ', coalesce(${a('JoinWebURL')},''), ${NL}, ` +
    `'Customer phone: ', coalesce(${a('CustomerPhone')},''), ${NL}, ` +
    `'Customer notes: ', coalesce(${a('CustomerNotes')},''), ${NL}, ` +
    `'Additional info: ', coalesce(${a('AdditionalInfo')},''), ${NL}, ` +
    `'Custom answers (raw): ', coalesce(string(${a('CustomQuestionAnswers')}),''), ${NL}, ` +
    `'Booked with: ', coalesce(${staff0('DisplayName')},''), ${NL}, ${NL}, ` +
    `'— Provenance —', ${NL}, ` +
    `'Source: Guided AI Labs (Microsoft Bookings)', ${NL}, ` +
    `'Booking page: ${BOOKING_SMTP}', ${NL}, ` +
    `'Self-service appointment id: ', coalesce(${a('SelfServiceAppointmentId')},''), ${NL}, ` +
    `'Capture: Auto-captured via Microsoft Bookings')`;

  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: {
      When_an_appointment_is_created: {
        type: 'OpenApiConnectionWebhook',
        inputs: {
          host: { connectionName: 'shared_microsoftbookings', operationId: 'CreateAppointment', apiId: apiId('shared_microsoftbookings') },
          parameters: { SMTPAddress: BOOKING_SMTP },
          authentication: "@parameters('$authentication')",
        },
      },
    },
    actions: {
      Create_item: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_sharepointonline', operationId: 'PostItem', apiId: apiId('shared_sharepointonline') },
          parameters: {
            dataset: SITE,
            table: listId,
            'item/Title': titleExpr,
            'item/PersonName': `@${a('CustomerName')}`,
            'item/PersonEmail': `@${a('CustomerEmail')}`,
            'item/NeedSummary': `@${a('CustomerNotes')}`,
            'item/SourceText': sourceTextExpr,
            'item/NextAction': 'Prepare for booked call',
            'item/FollowUpDueDate': `@${a('StartTime')}`,
            'item/ItemOwner/Claims': ownerClaims,
            'item/SignalType/Value': 'Website',
            'item/IntakeSource/Value': 'Guided AI Labs',
            'item/SignalStatus/Value': 'Follow-up scheduled',
            'item/Priority/Value': 'Normal',
          },
          authentication: "@parameters('$authentication')",
        },
      },
    },
  };

  const connectionReferences = {
    shared_microsoftbookings: { connectionName: bkConn.name, source: 'Embedded', id: apiId('shared_microsoftbookings'), tier: 'NotSpecified' },
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
  };

  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  fs.writeFileSync(path.join(CAP, 'flow-body-booking.json'), JSON.stringify(flowBody, null, 2));

  // 4) Create or PATCH (idempotent via stored flowName).
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-booking.json');
  let existingName = null;
  if (fs.existsSync(resultPath)) { try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {} }
  let cr, created, flowName;
  if (existingName) {
    log(`updating existing flow: ${DISPLAY} (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
    log(`  update -> ${cr.status}`);
    fs.writeFileSync(path.join(CAP, 'flow-update-booking.json'), `status: ${cr.status}\n\n${cr.body}`);
    if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1800)); await done(); process.exit(4); }
    created = JSON.parse(cr.body); flowName = created.name || existingName;
  } else {
    log(`creating flow: ${DISPLAY}`);
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
    log(`  create -> ${cr.status}`);
    fs.writeFileSync(path.join(CAP, 'flow-create-booking.json'), `status: ${cr.status}\n\n${cr.body}`);
    if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1800)); await done(); process.exit(4); }
    created = JSON.parse(cr.body); flowName = created.name;
  }
  const result = {
    source: 'Guided AI Labs (Bookings)', flowName, displayName: DISPLAY, bookingSmtp: BOOKING_SMTP, listId,
    state: created.properties && created.properties.state, createdStatus: cr.status,
    spConnection: spConn.name, bookingsConnection: bkConn.name,
  };
  fs.writeFileSync(resultPath, JSON.stringify(result, null, 2));
  log(`RESULT: flow=${flowName} state=${result.state}`);
  log('wrote inventory/forms-build/flow-result-booking.json');
  await done();
})();
