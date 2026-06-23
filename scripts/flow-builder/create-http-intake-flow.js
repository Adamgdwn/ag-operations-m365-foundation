// Build the CUSTOM-FORM intake flow: an HTTP-triggered Power Automate flow that
// accepts a JSON POST from a brand website's hand-built form and creates an item
// in "CRM - New Signals" with full parity to the Microsoft Forms intake flow
// (same columns + provenance footer). ONE flow serves both brands; the payload's
// `source` field selects the IntakeSource. Create-only; no updates/deletes/mail.
//
// Guard (validated inside the flow before any write):
//   - header  x-intake-secret  must equal the shared secret
//   - body    company          (honeypot) must be empty
//   - body    source           must be exactly one of the two brand strings
//   - body    needSummary      must be non-empty
// Anything else -> Terminate (Cancelled), no item created. No CAPTCHA by decision
// (secret + honeypot only, 2026-06-22); Turnstile remains optional future hardening.
//
// Secret: read from .local/flow-builder/http-intake-secret.txt if present, else
// generated and saved there (gitignored). NEVER printed in full or committed.
//
// Token capture reuses the warm-Edge/CDP recipe (see scripts/forms-builder/warm-edge.js).
//
// Usage: node create-http-intake-flow.js [--state=Started|Stopped]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const SECRET_DIR = path.join(REPO, '.local', 'flow-builder');
const SECRET_FILE = path.join(SECRET_DIR, 'http-intake-secret.txt');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(CAP, { recursive: true });
fs.mkdirSync(SECRET_DIR, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const FLOWHOST = 'api.flow.microsoft.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const CDP_PORT = process.env.CDP_PORT || '9222';
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];
const DISPLAY = 'GAIL — Custom site intake to CRM (create-only, HTTP)';
const TRIGGER = 'manual';

// Shared secret (load or mint).
function loadSecret() {
  if (fs.existsSync(SECRET_FILE)) return fs.readFileSync(SECRET_FILE, 'utf8').trim();
  const s = crypto.randomBytes(24).toString('base64url');
  fs.writeFileSync(SECRET_FILE, s + '\n', { mode: 0o600 });
  log(`minted new shared secret -> ${SECRET_FILE} (gitignored)`);
  return s;
}
const SECRET = loadSecret();
const VALID_SOURCES = ['Guided AI Labs', 'Guided AI Journey'];

// Field accessors from the HTTP trigger body.
const B = (k) => `triggerBody()?['${k}']`;
const NL = "decodeUriComponent('%0A')";
const titleExpr = `@concat(coalesce(${B('source')},'Website'), ' — ', coalesce(${B('fullName')}, ${B('organization')}, ${B('email')}, 'New website signal'))`;
const sourceTextExpr = `@concat('Full name: ', coalesce(${B('fullName')},''), ${NL}, 'Email: ', coalesce(${B('email')},''), ${NL}, 'Organization: ', coalesce(${B('organization')},''), ${NL}, 'What are you looking for: ', coalesce(${B('needSummary')},''), ${NL}, 'How did you hear about us: ', coalesce(${B('heardFrom')},''), ${NL}, 'Situation: ', coalesce(${B('situation')},''), ${NL}, 'Consent: ', if(equals(coalesce(${B('consent')},false), true), 'I agree', ''), ${NL}, ${NL}, '— Provenance —', ${NL}, 'Source: ', coalesce(${B('source')},''), ${NL}, 'Intake: custom site form', ${NL}, 'Intake id: ', guid(), ${NL}, 'Submitted: ', utcNow(), ${NL}, 'Capture: Auto-captured via custom site form')`;

const requestSchema = {
  type: 'object',
  properties: {
    source: { type: 'string' }, fullName: { type: 'string' }, email: { type: 'string' },
    organization: { type: 'string' }, needSummary: { type: 'string' }, situation: { type: 'string' },
    heardFrom: { type: 'string' }, consent: { type: 'boolean' }, company: { type: 'string' },
  },
};

// Guard expression: secret + honeypot empty + valid source + need present.
const guard = `@and(equals(coalesce(triggerOutputs()?['headers']?['x-intake-secret'], triggerOutputs()?['headers']?['X-Intake-Secret'], ''), '${SECRET}'), equals(trim(coalesce(${B('company')},'')), ''), or(equals(${B('source')}, '${VALID_SOURCES[0]}'), equals(${B('source')}, '${VALID_SOURCES[1]}')), greater(length(trim(coalesce(${B('needSummary')},''))), 0))`;

(async () => {
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT} (contexts=${browser.contexts().length})`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); cold headless launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const cleanup = async () => { try { if (ownCtx) await ctx.close(); else if (browser) await browser.close(); } catch {} };
  const page = await ctx.newPage();
  const tokens = {};
  page.on('request', req => { const a = req.headers()['authorization']; if (a && /^bearer /i.test(a)) { const h = new URL(req.url()).host; if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, ''); } });
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]})`); await cleanup(); process.exit(1); }
  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };

  // 1) SharePoint connection.
  const cl = JSON.parse((await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`)).body);
  const spConn = (cl.value || []).find(c => (c.properties && c.properties.apiId || '').endsWith('shared_sharepointonline'));
  log(`SharePoint conn: ${spConn ? spConn.name : 'MISSING'}`);
  if (!spConn) { log('ERROR: SharePoint connection (Connected) required.'); await cleanup(); process.exit(2); }

  // 2) List GUID.
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const bdy = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(bdy)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(8000); } }
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) { log('ERROR: could not resolve list GUID'); await cleanup(); process.exit(3); }

  // 3) Flow definition: Request trigger -> If(guard){ Create item } else { Terminate }.
  const createItem = {
    runAfter: {}, type: 'OpenApiConnection',
    inputs: {
      host: { connectionName: 'shared_sharepointonline', operationId: 'PostItem', apiId: apiId('shared_sharepointonline') },
      parameters: {
        dataset: SITE, table: listId,
        'item/Title': titleExpr,
        'item/PersonName': `@${B('fullName')}`,
        'item/PersonEmail': `@${B('email')}`,
        'item/OrganizationName': `@${B('organization')}`,
        'item/NeedSummary': `@${B('needSummary')}`,
        'item/SourceText': sourceTextExpr,
        'item/NextAction': 'Triage new website signal',
        'item/SignalType/Value': 'Website',
        'item/IntakeSource/Value': `@${B('source')}`,
        'item/IntentPath/Value': `@coalesce(${B('situation')},'')`,
        'item/SignalStatus/Value': 'New',
        'item/Priority/Value': 'Normal',
      },
      authentication: "@parameters('$authentication')",
    },
  };
  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: { [TRIGGER]: { type: 'Request', kind: 'Http', inputs: { schema: requestSchema } } },
    actions: {
      Guard: {
        runAfter: {}, type: 'If', expression: guard,
        actions: { Create_item: createItem },
        else: { actions: { Terminate: { runAfter: {}, type: 'Terminate', inputs: { runStatus: 'Cancelled' } } } },
      },
    },
  };
  const connectionReferences = {
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
  };
  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  // redact the secret in the saved copy
  fs.writeFileSync(path.join(CAP, 'flow-body-http-intake.json'), JSON.stringify(flowBody, null, 2).replaceAll(SECRET, '<<SECRET>>'));

  // 4) Create or update (idempotent via flow-result-http-intake.json).
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-http-intake.json');
  let existingName = null;
  if (fs.existsSync(resultPath)) { try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {} }
  let cr;
  if (existingName) {
    log(`updating existing flow (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
  } else {
    log('creating flow');
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
  }
  log(`  ${existingName ? 'update' : 'create'} -> ${cr.status}`);
  fs.writeFileSync(path.join(CAP, 'flow-http-intake-result.txt'), `status: ${cr.status}\n\n${cr.body.replaceAll(SECRET, '<<SECRET>>')}`);
  if (cr.status < 200 || cr.status >= 300) { log('  body: ' + cr.body.replaceAll(SECRET, '<<SECRET>>').slice(0, 1500)); await cleanup(); process.exit(4); }
  const created = JSON.parse(cr.body);
  const flowName = created.name || existingName;
  log(`  flowName: ${flowName}  state: ${(created.properties || {}).state}`);

  // 5) Fetch the trigger callback URL (the public POST endpoint).
  let callbackUrl = null;
  const cb = await post(FLOWHOST, `${base}/${flowName}/triggers/${TRIGGER}/listCallbackUrl?api-version=2016-11-01`, {});
  log(`  listCallbackUrl -> ${cb.status}`);
  if (cb.status >= 200 && cb.status < 300) { try { const j = JSON.parse(cb.body); callbackUrl = j.response && j.response.value || j.value || null; } catch {} }
  if (!callbackUrl) { log('  WARN: could not auto-fetch callback URL; body: ' + cb.body.slice(0, 300)); }

  // 6) Persist result (URL is a capability-secret -> .local only, never git).
  fs.writeFileSync(resultPath, JSON.stringify({ flowName, displayName: DISPLAY, state: (created.properties || {}).state || stateArg, createdAtNote: 'set externally', listId }, null, 2));
  if (callbackUrl) fs.writeFileSync(path.join(SECRET_DIR, 'http-intake-endpoint.txt'), callbackUrl + '\n', { mode: 0o600 });
  log('\n=== DONE ===');
  log(`  flow: ${DISPLAY}`);
  log(`  flowName: ${flowName}`);
  log(`  endpoint saved: ${callbackUrl ? path.join(SECRET_DIR, 'http-intake-endpoint.txt') : 'NOT captured'}`);
  log(`  secret file: ${SECRET_FILE}`);
  await cleanup();
  process.exit(0);
})();
