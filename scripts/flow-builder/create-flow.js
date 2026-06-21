// Create the create-only intake flow for a brand:
//   Microsoft Forms (new response) -> Get response details -> SharePoint Create item
// in "CRM - New Signals", stamping operator-visible Source + provenance into the
// hidden technical fields. Standard connectors only; create-only; no deletes,
// updates, or mail. Resolves the two connections + the list GUID at runtime, then
// POSTs the flow definition to the Flow management API. Tokens stay in memory.
//
// Usage: node create-flow.js --brand=labs|journey [--state=Started|Stopped]
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
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;

const brandArg = (process.argv.find(a => a.startsWith('--brand=')) || '=labs').split('=')[1];
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];
const BRANDS = {
  labs: { source: 'Guided AI Labs', mailbox: 'Guided AI Labs intake form', display: 'GAIL — Guided AI Labs intake to CRM (create-only)' },
  journey: { source: 'Guided AI Journey', mailbox: 'Guided AI Journey intake form', display: 'GAIL — Guided AI Journey intake to CRM (create-only)' },
};
const brand = BRANDS[brandArg] || BRANDS.labs;

const fq = JSON.parse(fs.readFileSync(path.join(CAP, 'form-questions.json'), 'utf8'))[brandArg];
const FORM_ID = fq.formId;
const qid = (titleStartsWith) => { const q = fq.questions.find(x => x.title.toLowerCase().startsWith(titleStartsWith.toLowerCase())); if (!q) throw new Error('question not found: ' + titleStartsWith); return q.id; };
const qidOpt = (titleStartsWith) => { const q = fq.questions.find(x => x.title.toLowerCase().startsWith(titleStartsWith.toLowerCase())); return q ? q.id : null; };
const Q = {
  full: qid('Full name'), email: qid('Email'), org: qid('Organization'),
  need: qid('What are you looking for'), hear: qid('How did you hear'),
  intent: qidOpt('Who is this for'), consent: qid('I agree'),
};
const ans = (id) => `outputs('Get_response_details')?['body/${id}']`;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]})`); await ctx.close(); process.exit(1); }
  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };

  // 1) Resolve the two connections.
  const cl = JSON.parse((await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`)).body);
  const findConn = (api) => (cl.value || []).find(c => (c.properties && c.properties.apiId || '').endsWith(api));
  const spConn = findConn('shared_sharepointonline');
  const formsConn = findConn('shared_microsoftforms');
  log(`SharePoint conn: ${spConn ? spConn.name : 'MISSING'} | Forms conn: ${formsConn ? formsConn.name : 'MISSING'}`);
  if (!spConn || !formsConn) { log('ERROR: both connections must exist (Connected) before building the flow.'); await ctx.close(); process.exit(2); }

  // 2) Resolve the list GUID via SharePoint REST (uses the persisted M365 session).
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const b = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(b)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(8000); } }
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) { log('ERROR: could not resolve list GUID'); await ctx.close(); process.exit(3); }

  // 3) Build the flow definition.
  // SourceText carries the full labelled answer dump PLUS an in-band provenance
  // footer. The recovered list has no hidden technical fields (Stage 8C removed
  // them), so provenance lives here + in the native Created timestamp instead of
  // separate hidden columns. Brand also lands in the operator-visible Source choice.
  const NL = "decodeUriComponent('%0A')";
  const submitDate = "outputs('Get_response_details')?['body/submitDate']";
  const responseId = "triggerOutputs()?['body/resourceData/responseId']";
  const intentLine = Q.intent ? `'Who is this for: ', coalesce(${ans(Q.intent)},''), ${NL}, ` : '';
  const sourceTextExpr = `@concat('Full name: ', coalesce(${ans(Q.full)},''), ${NL}, 'Email: ', coalesce(${ans(Q.email)},''), ${NL}, 'Organization: ', coalesce(${ans(Q.org)},''), ${NL}, 'What are you looking for: ', coalesce(${ans(Q.need)},''), ${NL}, 'How did you hear about us: ', coalesce(${ans(Q.hear)},''), ${NL}, ${intentLine}'Consent: ', coalesce(${ans(Q.consent)},''), ${NL}, ${NL}, '— Provenance —', ${NL}, 'Source: ${brand.source}', ${NL}, 'Intake form: ${brand.mailbox}', ${NL}, 'Forms response id: ', coalesce(${responseId},''), ${NL}, 'Submitted: ', coalesce(${submitDate},''), ${NL}, 'Capture: Auto-captured via website intake flow')`;
  const titleExpr = `@concat('${brand.source} — ', coalesce(${ans(Q.full)}, ${ans(Q.org)}, ${ans(Q.email)}, 'New website signal'))`;

  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: {
      When_a_new_response_is_submitted: {
        type: 'OpenApiConnectionWebhook',
        splitOn: "@triggerOutputs()?['body/value']",
        inputs: {
          host: { connectionName: 'shared_microsoftforms', operationId: 'CreateFormWebhook', apiId: apiId('shared_microsoftforms') },
          parameters: { form_id: FORM_ID },
          authentication: "@parameters('$authentication')",
        },
      },
    },
    actions: {
      Get_response_details: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_microsoftforms', operationId: 'GetFormResponseById', apiId: apiId('shared_microsoftforms') },
          parameters: { form_id: FORM_ID, response_id: "@triggerOutputs()?['body/resourceData/responseId']" },
          authentication: "@parameters('$authentication')",
        },
      },
      Create_item: {
        runAfter: { Get_response_details: ['Succeeded'] },
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_sharepointonline', operationId: 'PostItem', apiId: apiId('shared_sharepointonline') },
          parameters: {
            dataset: SITE,
            table: listId,
            'item/Title': titleExpr,
            'item/PersonName': `@${ans(Q.full)}`,
            'item/PersonEmail': `@${ans(Q.email)}`,
            'item/OrganizationName': `@${ans(Q.org)}`,
            'item/NeedSummary': `@${ans(Q.need)}`,
            'item/SourceText': sourceTextExpr,
            'item/NextAction': 'Triage new website signal',
            'item/SignalType/Value': 'Website',
            'item/IntakeSource/Value': brand.source,
            'item/SignalStatus/Value': 'New',
            'item/Priority/Value': 'Normal',
          },
          authentication: "@parameters('$authentication')",
        },
      },
    },
  };

  const connectionReferences = {
    shared_microsoftforms: { connectionName: formsConn.name, source: 'Embedded', id: apiId('shared_microsoftforms'), tier: 'NotSpecified' },
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
  };

  const flowBody = { properties: { displayName: brand.display, state: stateArg, definition, connectionReferences } };
  fs.writeFileSync(path.join(CAP, `flow-body-${brandArg}.json`), JSON.stringify(flowBody, null, 2));

  // 4) Update an existing flow (idempotent) or create a new one. If a prior
  //    flow-result file records this brand's flowName, PATCH it so re-runs edit
  //    the live flow in place instead of creating duplicates.
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, `flow-result-${brandArg}.json`);
  let existingName = null;
  if (fs.existsSync(resultPath)) { try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {} }
  let cr, created, flowName;
  if (existingName) {
    log(`updating existing flow: ${brand.display} (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
    log(`  update -> ${cr.status}`);
    fs.writeFileSync(path.join(CAP, `flow-update-${brandArg}.json`), `status: ${cr.status}\n\n${cr.body}`);
    if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1500)); await ctx.close(); process.exit(4); }
    created = JSON.parse(cr.body);
    flowName = created.name || existingName;
  } else {
    log(`creating flow: ${brand.display}`);
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
    log(`  create -> ${cr.status}`);
    fs.writeFileSync(path.join(CAP, `flow-create-${brandArg}.json`), `status: ${cr.status}\n\n${cr.body}`);
    if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.slice(0, 1500)); await ctx.close(); process.exit(4); }
    created = JSON.parse(cr.body);
    flowName = created.name;
  }
  const result = {
    brand: brand.source, flowName, displayName: brand.display, formId: FORM_ID, listId,
    state: created.properties && created.properties.state, createdStatus: cr.status,
    spConnection: spConn.name, formsConnection: formsConn.name,
  };
  fs.writeFileSync(path.join(OUT, `flow-result-${brandArg}.json`), JSON.stringify(result, null, 2));
  log(`RESULT: flow=${flowName} state=${result.state}`);
  log(`wrote inventory/forms-build/flow-result-${brandArg}.json`);
  await ctx.close();
})();
