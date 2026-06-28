// Build the CUSTOM-FORM intake flow: an HTTP-triggered Power Automate flow that
// accepts a JSON POST from a brand website's hand-built form or a minimal
// Journey invite/admin signal and creates an item in "CRM - New Signals" with
// full parity to the Microsoft Forms intake flow (same columns + provenance
// footer). ONE flow serves both brands; the payload's `source` field selects the
// IntakeSource. Create-only; no updates/deletes/mail.
//
// Guard (validated inside the flow before any write):
//   - header  x-intake-secret  must equal the shared secret
//   - body    company          (honeypot) must be empty
//   - body    source           must be exactly one of the two brand strings
//   - body    must include either need/lead context or at least one lead identity
//             field (email/name/organization)
// Anything else -> Terminate (Cancelled), no item created. No CAPTCHA by decision
// (secret + honeypot only, 2026-06-22); Turnstile remains optional future hardening.
//
// Optional Journey invite/admin/lifecycle metadata is recorded into SourceText
// so a later CRM receipt callback can update the Journey dashboard by
// portalEventId, correlationId, or journeyInviteId without adding friction to
// the client-facing form. The same metadata now carries a readable lead-source
// detail for operators and Teams alerts. The legacy body.company field remains
// a honeypot; use companyId/portalCompanyName for Journey company data.
//
// Secret: read from .local/flow-builder/http-intake-secret.txt if present, else
// generated and saved there (gitignored). NEVER printed in full or committed.
// Optional CRM receipt ack config is read from .local/flow-builder:
//   journey-crm-ack-endpoint.txt
//   journey-crm-ack-secret.txt
//   journey-crm-ack-secret-header.txt  (optional, defaults x-m365-ack-secret)
// If either endpoint or secret is missing, the builder emits receive-only flow
// actions and does not include the external callback.
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
const ACK_ENDPOINT_FILE = path.join(SECRET_DIR, 'journey-crm-ack-endpoint.txt');
const ACK_SECRET_FILE = path.join(SECRET_DIR, 'journey-crm-ack-secret.txt');
const ACK_SECRET_HEADER_FILE = path.join(SECRET_DIR, 'journey-crm-ack-secret-header.txt');
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

function loadAckConfig() {
  const hasEndpoint = fs.existsSync(ACK_ENDPOINT_FILE);
  const hasSecret = fs.existsSync(ACK_SECRET_FILE);
  if (!hasEndpoint && !hasSecret) return null;
  if (!hasEndpoint || !hasSecret) {
    throw new Error(`Ack config incomplete. Need both ${ACK_ENDPOINT_FILE} and ${ACK_SECRET_FILE}, or neither.`);
  }
  const endpoint = fs.readFileSync(ACK_ENDPOINT_FILE, 'utf8').trim();
  const secret = fs.readFileSync(ACK_SECRET_FILE, 'utf8').trim();
  const headerName = fs.existsSync(ACK_SECRET_HEADER_FILE)
    ? fs.readFileSync(ACK_SECRET_HEADER_FILE, 'utf8').trim()
    : 'x-m365-ack-secret';
  if (!/^https:\/\//i.test(endpoint)) throw new Error('Ack endpoint must be an https URL.');
  if (!secret) throw new Error('Ack secret file is empty.');
  if (!/^[A-Za-z0-9-]+$/.test(headerName)) throw new Error('Ack secret header name must be a simple HTTP header token.');
  return { endpoint, secret, headerName };
}
const ACK = loadAckConfig();
function redactSecrets(text) {
  let redacted = text.replaceAll(SECRET, '<<INTAKE_SECRET>>');
  if (ACK) {
    redacted = redacted
      .replaceAll(ACK.secret, '<<ACK_SECRET>>')
      .replaceAll(ACK.endpoint, '<<ACK_ENDPOINT>>');
  }
  return redacted;
}

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

// Field accessors from the HTTP trigger body.
const B = (k) => `triggerBody()?['${k}']`;
const NL = "decodeUriComponent('%0A')";
const nonEmpty = (k) => `greater(length(trim(coalesce(${B(k)},''))), 0)`;
const firstNonEmpty = (keys, fallback) => keys.reduceRight((acc, k) => `if(${nonEmpty(k)}, ${B(k)}, ${acc})`, fallback);
const eventTypeExpr = firstNonEmpty(['eventType', 'journeyEventType'], "'website.intake.submitted'");
const portalEventIdExpr = firstNonEmpty(['portalEventId'], "''");
const correlationIdExpr = firstNonEmpty(['correlationId', 'portalEventId'], "''");
const companyIdExpr = firstNonEmpty(['companyId', 'portalCompanyId', 'journeyCompanyId'], "''");
const engagementIdExpr = firstNonEmpty(['engagementId', 'portalEngagementId', 'journeyEngagementId'], "''");
const inviteIdExpr = firstNonEmpty(['inviteId', 'journeyInviteId'], "''");
const journeyLeadIdExpr = firstNonEmpty(['journeyLeadId', 'dashboardLeadId'], "''");
const personNameValueExpr = firstNonEmpty(['fullName', 'inviteeName', 'invitedName', 'email', 'inviteeEmail', 'invitedEmail'], "''");
const personEmailValueExpr = firstNonEmpty(['email', 'inviteeEmail', 'invitedEmail'], "''");
const organizationValueExpr = firstNonEmpty(['organization', 'organizationName', 'journeyOrganizationName', 'portalCompanyName', 'companyDisplayName'], "''");
const leadIdentityValueExpr = firstNonEmpty(['fullName', 'inviteeName', 'invitedName', 'email', 'inviteeEmail', 'invitedEmail', 'organization', 'organizationName', 'journeyOrganizationName', 'portalCompanyName', 'companyDisplayName', 'portalEventId'], "'unknown lead'");
const needValueExpr = firstNonEmpty(['needSummary', 'leadContext'], `concat('Guided AI Journey signal: ', ${eventTypeExpr}, ' for ', ${leadIdentityValueExpr})`);
const sourceActionLabelExpr = `if(equals(${B('sourceAction')}, 'admin_invited_person'), 'Journey admin invite', if(equals(${B('sourceAction')}, 'organization_admin_invited_person'), 'Journey organization admin invite', if(equals(${B('sourceAction')}, 'client_invited_person'), 'Journey client invite', if(${nonEmpty('sourceAction')}, concat('Journey action: ', ${B('sourceAction')}), if(${nonEmpty('eventType')}, concat('Journey event: ', ${eventTypeExpr}), 'Guided AI Journey')))))`;
const leadSourceFallbackExpr = `if(equals(${B('source')}, '${VALID_SOURCES[1]}'), ${sourceActionLabelExpr}, if(${nonEmpty('heardFrom')}, concat('Heard from: ', ${B('heardFrom')}), 'Guided AI Labs website'))`;
const leadSourceDetailExpr = firstNonEmpty(['leadSourceDetail', 'leadSource', 'attributionSource', 'referralSource'], leadSourceFallbackExpr);
const titleExpr = `@concat(coalesce(${B('source')},'Website'), ' — ', ${firstNonEmpty(['fullName', 'inviteeName', 'invitedName', 'organization', 'organizationName', 'portalCompanyName', 'companyDisplayName', 'email', 'inviteeEmail', 'invitedEmail', 'portalEventId'], "'New website signal'")})`;
const sourceTextCoreExpr = `@concat('Full name: ', ${personNameValueExpr}, ${NL}, 'Email: ', ${personEmailValueExpr}, ${NL}, 'Organization: ', ${organizationValueExpr}, ${NL}, 'Lead source detail: ', ${leadSourceDetailExpr}, ${NL}, 'What are you looking for: ', ${needValueExpr}, ${NL}, 'How did you hear about us: ', coalesce(${B('heardFrom')},''), ${NL}, 'Situation: ', coalesce(${B('situation')},''), ${NL}, 'Consent: ', if(equals(coalesce(${B('consent')},false), true), 'I agree', ''))`;
const sourceTextMetadataExpr = `@concat(${NL}, ${NL}, '— Journey signal metadata —', ${NL}, 'Schema version: ', coalesce(${B('schemaVersion')},''), ${NL}, 'Signal mode: ', coalesce(${B('signalMode')},''), ${NL}, 'Event type: ', ${eventTypeExpr}, ${NL}, 'Portal event id: ', ${portalEventIdExpr}, ${NL}, 'Correlation id: ', ${correlationIdExpr}, ${NL}, 'Company id: ', ${companyIdExpr}, ${NL}, 'Engagement id: ', ${engagementIdExpr}, ${NL}, 'Invite id: ', ${inviteIdExpr}, ${NL}, 'Journey invite id: ', coalesce(${B('journeyInviteId')},''), ${NL}, 'Journey organization id: ', coalesce(${B('journeyOrganizationId')},''), ${NL}, 'Journey lead id: ', ${journeyLeadIdExpr}, ${NL}, 'Invite role: ', coalesce(${B('inviteRole')},''), ${NL}, 'Source action: ', coalesce(${B('sourceAction')},''), ${NL}, 'Portal deep link: ', coalesce(${B('portalDeepLink')},''), ${NL}, 'Event timestamp: ', ${firstNonEmpty(['eventTimestamp', 'occurredAt'], "''")}, ${NL}, 'Ack requested: ', string(coalesce(${B('ackRequested')},false)), ${NL}, ${NL}, '— Provenance —', ${NL}, 'Source: ', coalesce(${B('source')},''), ${NL}, 'Intake: custom site form', ${NL}, 'Intake id: ', guid(), ${NL}, 'Submitted: ', utcNow(), ${NL}, 'Capture: Auto-captured via custom site form')`;

const stringOrNull = { type: ['string', 'null'] };
const booleanOrNull = { type: ['boolean', 'null'] };
const requestSchema = {
  type: 'object',
  properties: {
    source: stringOrNull, fullName: stringOrNull, email: stringOrNull,
    organization: stringOrNull, needSummary: stringOrNull, situation: stringOrNull,
    heardFrom: stringOrNull, consent: booleanOrNull, company: stringOrNull,
    schemaVersion: stringOrNull, signalMode: stringOrNull, eventType: stringOrNull,
    journeyEventType: stringOrNull, portalEventId: stringOrNull,
    correlationId: stringOrNull, companyId: stringOrNull,
    portalCompanyId: stringOrNull, journeyCompanyId: stringOrNull,
    engagementId: stringOrNull, portalEngagementId: stringOrNull,
    journeyEngagementId: stringOrNull, inviteId: stringOrNull,
    journeyInviteId: stringOrNull, journeyOrganizationId: stringOrNull,
    journeyOrganizationName: stringOrNull, journeyLeadId: stringOrNull,
    dashboardLeadId: stringOrNull, inviteRole: stringOrNull,
    inviteeName: stringOrNull, invitedName: stringOrNull,
    inviteeEmail: stringOrNull, invitedEmail: stringOrNull,
    organizationName: stringOrNull, portalCompanyName: stringOrNull,
    companyDisplayName: stringOrNull, leadContext: stringOrNull,
    leadSource: stringOrNull, leadSourceDetail: stringOrNull,
    attributionSource: stringOrNull, referralSource: stringOrNull,
    sourceAction: stringOrNull, portalDeepLink: stringOrNull,
    eventTimestamp: stringOrNull, occurredAt: stringOrNull,
    ackRequested: booleanOrNull,
  },
};

// Guard expression: secret + honeypot empty + valid source + useful lead signal.
const usefulLeadOrLifecycleSignal = `or(${nonEmpty('needSummary')}, ${nonEmpty('leadContext')}, ${nonEmpty('email')}, ${nonEmpty('inviteeEmail')}, ${nonEmpty('invitedEmail')}, ${nonEmpty('fullName')}, ${nonEmpty('inviteeName')}, ${nonEmpty('invitedName')}, ${nonEmpty('organization')}, ${nonEmpty('organizationName')}, ${nonEmpty('journeyOrganizationName')}, ${nonEmpty('portalCompanyName')}, ${nonEmpty('companyDisplayName')}, and(${nonEmpty('portalEventId')}, ${nonEmpty('eventType')}))`;
const guard = `@and(equals(coalesce(triggerOutputs()?['headers']?['x-intake-secret'], triggerOutputs()?['headers']?['X-Intake-Secret'], ''), '${SECRET}'), equals(trim(coalesce(${B('company')},'')), ''), or(equals(${B('source')}, '${VALID_SOURCES[0]}'), equals(${B('source')}, '${VALID_SOURCES[1]}')), ${usefulLeadOrLifecycleSignal})`;
const itemIdExpr = `coalesce(outputs('Create_item')?['body/ID'], outputs('Create_item')?['body/Id'])`;
const crmItemUrlExpr = `coalesce(outputs('Create_item')?['body/{Link}'], concat('${SITE}/Lists/CRM%20%20New%20Signals/DispForm.aspx?ID=', ${itemIdExpr}))`;
const ackKeyExpr = firstNonEmpty(['portalEventId', 'correlationId', 'journeyInviteId', 'inviteId', 'journeyLeadId', 'dashboardLeadId'], "''");
const shouldSendAckExpr = `@and(equals(${B('source')}, '${VALID_SOURCES[1]}'), equals(coalesce(${B('ackRequested')}, false), true), greater(length(trim(${ackKeyExpr})), 0))`;
const nullIfBlank = (expr) => `if(greater(length(trim(coalesce(${expr},''))), 0), ${expr}, null)`;

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
  await selectTenantAccountIfPrompted(page);
  await page.waitForTimeout(9000);
  if (!tokens[EHOST] || !tokens[FLOWHOST]) { log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]})`); await cleanup(); process.exit(1); }
  const get = async (host, url) => { const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } }); return { status: r.status(), body: await r.text() }; };
  const post = async (host, url, body) => { const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };
  const patch = async (host, url, body) => { const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) }); return { status: r.status(), body: await r.text() }; };

  // 1) SharePoint connection.
  const listConnsOnce = async (attempt) => {
    const raw = await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`);
    let parsed = {};
    try { parsed = JSON.parse(raw.body); }
    catch {
      log(`connections GET #${attempt}: status=${raw.status} parse failed body=${raw.body.slice(0, 200)}`);
      return [];
    }
    const value = parsed.value || [];
    log(`connections GET #${attempt}: status=${raw.status} count=${value.length}`);
    return value;
  };
  const listConns = async (tries = 6) => {
    let c = [];
    for (let i = 0; i < tries; i++) {
      c = await listConnsOnce(i);
      if (c.length) return c;
      await page.waitForTimeout(3000);
    }
    return c;
  };
  const connStatus = (c) => c && c.properties && c.properties.statuses ? c.properties.statuses.map(s => s.status).join(',') : null;
  const conns = await listConns();
  const spConn = conns.find(c => (c.properties && c.properties.apiId || '').endsWith('shared_sharepointonline'));
  log(`SharePoint conn: ${spConn ? `${spConn.name} (${connStatus(spConn)})` : 'MISSING'}`);
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

  // 3) Flow definition: Request trigger -> guard -> B8 idempotency -> create/ack.
  const findPortalEventFilterExpr = `@if(greater(length(trim(${portalEventIdExpr})), 0), concat('PortalEventId eq ''', ${portalEventIdExpr}, ''''), 'ID eq -1')`;
  const existingMatchCountExpr = "length(outputs('Find_existing_CRM_items')?['body/value'])";
  const existingItemExpr = "first(outputs('Find_existing_CRM_items')?['body/value'])";
  const existingItemIdExpr = `coalesce(${existingItemExpr}?['ID'], ${existingItemExpr}?['Id'])`;
  const existingCrmItemUrlExpr = `concat('${SITE}/Lists/CRM%20%20New%20Signals/DispForm.aspx?ID=', ${existingItemIdExpr})`;

  const buildCreateItemAction = (runAfter) => ({
    runAfter, type: 'OpenApiConnection',
    inputs: {
      host: { connectionName: 'shared_sharepointonline', operationId: 'PostItem', apiId: apiId('shared_sharepointonline') },
      parameters: {
        dataset: SITE, table: listId,
        'item/Title': titleExpr,
        'item/PersonName': `@${personNameValueExpr}`,
        'item/PersonEmail': `@${personEmailValueExpr}`,
        'item/OrganizationName': `@${organizationValueExpr}`,
        'item/NeedSummary': `@${needValueExpr}`,
        'item/SourceText': "@concat(outputs('Build_CRM_source_text_core'), outputs('Build_CRM_source_text_metadata'))",
        'item/NextAction': 'Triage new website signal',
        'item/SignalType/Value': 'Website',
        'item/IntakeSource/Value': `@${B('source')}`,
        'item/IntentPath/Value': `@coalesce(${B('situation')},'')`,
        'item/SignalStatus/Value': 'New',
        'item/Priority/Value': 'Normal',
        'item/PortalEventId': `@${portalEventIdExpr}`,
        'item/SourceCorrelationId': `@${correlationIdExpr}`,
      },
      authentication: "@parameters('$authentication')",
    },
  });

  const buildReceiptAckIf = (runAfter, postActionName, crmStatus, refs) => ({
    runAfter,
    type: 'If',
    expression: shouldSendAckExpr,
    actions: {
      [postActionName]: {
        runAfter: {},
        type: 'Http',
        inputs: {
          method: 'POST',
          uri: ACK.endpoint,
          headers: {
            'content-type': 'application/json',
            [ACK.headerName]: ACK.secret,
          },
          body: {
            schemaVersion: 'journey.crm-receipt.v1',
            eventType: 'm365.crm_signal.received',
            receivedEventType: `@${eventTypeExpr}`,
            source: 'Guided AI Journey',
            portalEventId: `@${portalEventIdExpr}`,
            correlationId: `@${correlationIdExpr}`,
            companyId: `@${nullIfBlank(companyIdExpr)}`,
            engagementId: `@${nullIfBlank(engagementIdExpr)}`,
            inviteId: `@${nullIfBlank(inviteIdExpr)}`,
            journeyInviteId: `@${nullIfBlank(B('journeyInviteId'))}`,
            journeyOrganizationId: `@${nullIfBlank(B('journeyOrganizationId'))}`,
            journeyLeadId: `@${nullIfBlank(journeyLeadIdExpr)}`,
            crmStatus,
            received: true,
            crmRecordId: refs.recordId,
            crmRecordUrl: refs.recordUrl,
            crmItemId: refs.itemId,
            crmItemUrl: refs.itemUrl,
            crmTitle: refs.title,
            signalStatus: 'New',
            priority: 'Normal',
            flowRunId: "@workflow()?['run']?['name']",
            receivedAt: refs.receivedAt,
            processedAt: '@utcNow()',
            ackGeneratedAt: '@utcNow()',
            message: refs.message,
          },
        },
      },
    },
    else: { actions: {} },
  });

  const createActions = {
    Create_item: buildCreateItemAction({}),
  };
  if (ACK) {
    createActions.Maybe_send_created_CRM_receipt_ack_to_Journey = buildReceiptAckIf(
      { Create_item: ['Succeeded'] },
      'Post_created_CRM_receipt_ack_to_Journey',
      'created',
      {
        recordId: `@string(${itemIdExpr})`,
        recordUrl: `@${crmItemUrlExpr}`,
        itemId: `@${itemIdExpr}`,
        itemUrl: `@${crmItemUrlExpr}`,
        title: `@outputs('Create_item')?['body/Title']`,
        receivedAt: `@coalesce(outputs('Create_item')?['body/Created'], utcNow())`,
        message: 'CRM - New Signals item created in Microsoft 365.',
      },
    );
  }

  const existingActions = ACK ? {
    Maybe_send_existing_CRM_receipt_ack_to_Journey: buildReceiptAckIf(
      {},
      'Post_existing_CRM_receipt_ack_to_Journey',
      // Journey's B7 receiver currently accepts the created receipt shape.
      // The replay branch still returns the existing CRM item id/url and an
      // existing-item message; a future Journey receiver update can add an
      // explicit crmStatus=existing enum without changing the M365 dedupe path.
      'created',
      {
        recordId: `@string(${existingItemIdExpr})`,
        recordUrl: `@${existingCrmItemUrlExpr}`,
        itemId: `@${existingItemIdExpr}`,
        itemUrl: `@${existingCrmItemUrlExpr}`,
        title: `@${existingItemExpr}?['Title']`,
        receivedAt: `@coalesce(${existingItemExpr}?['Created'], utcNow())`,
        message: 'CRM - New Signals item already existed for this Journey portalEventId.',
      },
    ),
  } : {};

  const guardActions = {
    Build_CRM_source_text_core: { runAfter: {}, type: 'Compose', inputs: sourceTextCoreExpr },
    Build_CRM_source_text_metadata: { runAfter: { Build_CRM_source_text_core: ['Succeeded'] }, type: 'Compose', inputs: sourceTextMetadataExpr },
    Find_existing_CRM_items: {
      runAfter: { Build_CRM_source_text_metadata: ['Succeeded'] },
      type: 'OpenApiConnection',
      inputs: {
        host: { connectionName: 'shared_sharepointonline', operationId: 'GetItems', apiId: apiId('shared_sharepointonline') },
        parameters: { dataset: SITE, table: listId, $filter: findPortalEventFilterExpr, $orderby: 'ID desc', $top: 2 },
        authentication: "@parameters('$authentication')",
      },
    },
    Existing_CRM_item_found: {
      runAfter: { Find_existing_CRM_items: ['Succeeded'] },
      type: 'If',
      expression: `@equals(${existingMatchCountExpr}, 1)`,
      actions: existingActions,
      else: {
        actions: {
          Multiple_CRM_items_found: {
            runAfter: {},
            type: 'If',
            expression: `@greater(${existingMatchCountExpr}, 1)`,
            actions: {
              Stop_for_duplicate_review: {
                runAfter: {},
                type: 'Terminate',
                inputs: { runStatus: 'Failed', runError: { code: 'B8DuplicatePortalEventId', message: 'More than one CRM item matched this Journey portalEventId. Adam review required.' } },
              },
            },
            else: { actions: createActions },
          },
        },
      },
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
        actions: guardActions,
        else: { actions: { Terminate: { runAfter: {}, type: 'Terminate', inputs: { runStatus: 'Cancelled' } } } },
      },
    },
  };
  const connectionReferences = {
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
  };
  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  // redact the secret in the saved copy
  fs.writeFileSync(path.join(CAP, 'flow-body-http-intake.json'), redactSecrets(JSON.stringify(flowBody, null, 2)));

  // 4) Create or update (idempotent via flow-result-http-intake.json).
  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-http-intake.json');
  let existingName = null;
  let existingResult = {};
  if (fs.existsSync(resultPath)) {
    try {
      existingResult = JSON.parse(fs.readFileSync(resultPath, 'utf8'));
      existingName = existingResult.flowName || null;
    } catch {}
  }
  let cr;
  if (existingName) {
    log(`updating existing flow (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
  } else {
    log('creating flow');
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
  }
  log(`  ${existingName ? 'update' : 'create'} -> ${cr.status}`);
  fs.writeFileSync(path.join(CAP, 'flow-http-intake-result.txt'), `status: ${cr.status}\n\n${redactSecrets(cr.body)}`);
  if (cr.status < 200 || cr.status >= 300) { log('  body: ' + redactSecrets(cr.body).slice(0, 1500)); await cleanup(); process.exit(4); }
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
  fs.writeFileSync(resultPath, JSON.stringify({
    ...existingResult,
    flowName,
    displayName: DISPLAY,
    state: (created.properties || {}).state || stateArg,
    createdAtNote: 'set externally',
    listId,
    ackConfigured: !!ACK,
    ackSecretHeader: ACK ? ACK.headerName : null,
  }, null, 2));
  if (callbackUrl) fs.writeFileSync(path.join(SECRET_DIR, 'http-intake-endpoint.txt'), callbackUrl + '\n', { mode: 0o600 });
  log('\n=== DONE ===');
  log(`  flow: ${DISPLAY}`);
  log(`  flowName: ${flowName}`);
  log(`  endpoint saved: ${callbackUrl ? path.join(SECRET_DIR, 'http-intake-endpoint.txt') : 'NOT captured'}`);
  log(`  secret file: ${SECRET_FILE}`);
  log(`  Journey CRM receipt ack: ${ACK ? `configured (${ACK.headerName})` : 'not configured; receive-only flow body'}`);
  await cleanup();
  process.exit(0);
})();
