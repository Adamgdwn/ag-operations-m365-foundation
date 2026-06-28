// B8b replay proof for the custom HTTP intake flow.
// Posts one synthetic Guided AI Journey lifecycle payload twice with the same
// portalEventId, then verifies CRM - New Signals still has exactly one matching
// item using the first-class PortalEventId / SourceCorrelationId fields.
//
// Reads the endpoint + secret from .local/flow-builder (gitignored). Does not
// print or write those secret values to inventory evidence.
//
// Usage:
//   node scripts/flow-builder/b8-replay-proof.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const SECRET_DIR = path.join(REPO, '.local', 'flow-builder');
const OUT = path.join(REPO, 'inventory', 'm365-interaction-agent-b8');
const CDP_PORT = process.env.CDP_PORT || '9222';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const repoRelative = (filePath) => path.relative(REPO, filePath).split(path.sep).join('/');

const endpoint = fs.readFileSync(path.join(SECRET_DIR, 'http-intake-endpoint.txt'), 'utf8').trim();
const secret = fs.readFileSync(path.join(SECRET_DIR, 'http-intake-secret.txt'), 'utf8').trim();
const stamp = new Date().toISOString().replace(/[-:.TZ]/g, '').slice(0, 14);
const portalEventIdArg = (process.argv.find((arg) => arg.startsWith('--portalEventId=')) || '').split('=')[1];
const portalEventId = portalEventIdArg || crypto.randomUUID();
const correlationId = portalEventId;
const source = 'Guided AI Journey';

const payload = {
  schemaVersion: 'journey.crm-signal.v1',
  signalMode: 'portal-lifecycle-event',
  eventType: 'organization_setup_saved',
  portalEventId,
  correlationId,
  companyId: 'journey-company-internal-b8',
  engagementId: 'journey-engagement-internal-b8',
  inviteId: `journey-invite-b8-${stamp}`,
  journeyInviteId: `journey-invite-b8-${stamp}`,
  journeyOrganizationId: 'journey-org-internal-b8',
  sourceAction: 'scripts.b8_replay_proof',
  portalDeepLink: 'https://www.guidedaijourney.com/dashboard/internal-b8-replay-proof',
  eventTimestamp: new Date().toISOString(),
  ackRequested: true,
  source,
  fullName: 'GAIL Internal B8 Replay Proof',
  email: `adam+b8-replay-${stamp}@guidedailabs.com`,
  organization: 'Guided AI Labs Internal Walkthrough',
  needSummary: `B8 replay proof for ${portalEventId}. Synthetic internal event; safe to triage or delete later.`,
  situation: 'My organization - we need a broader AI strategy',
  heardFrom: 'Internal B8 replay proof',
  consent: true,
  company: '',
};

async function postPayload(label) {
  log(`POST ${label} to configured M365 HTTP intake endpoint`);
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-intake-secret': secret },
    body: JSON.stringify(payload),
  });
  const text = await response.text();
  log(`  ${label} -> HTTP ${response.status}`);
  return { label, status: response.status, bodyPreview: text.slice(0, 120) };
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

async function getVisibleFieldNames(page) {
  const fieldUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/fields?$select=InternalName,Title,Hidden`;
  const response = await page.request.get(fieldUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    throw new Error(`Field read failed HTTP ${response.status()} ${bodyText.slice(0, 300)}`);
  }
  const body = JSON.parse(bodyText);
  return new Set((body.value || []).filter((field) => !field.Hidden).map((field) => field.InternalName));
}

async function readCrmItems(page) {
  const selectFields = [
    'Id', 'ID', 'Title', 'PersonName', 'PersonEmail', 'OrganizationName',
    'NeedSummary', 'SourceText', 'NextAction', 'SignalType', 'IntakeSource',
    'IntentPath', 'SignalStatus', 'Priority', 'PortalEventId',
    'SourceCorrelationId', 'Created',
  ];
  const filter = encodeURIComponent(`PortalEventId eq '${portalEventId}'`);
  const select = `$select=${selectFields.join(',')}`;
  const url = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?${select}&$filter=${filter}&$orderby=ID desc&$top=10`;
  const response = await page.request.get(url, { headers: { accept: 'application/json;odata=nometadata' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    throw new Error(`CRM read failed HTTP ${response.status()} ${bodyText.slice(0, 500)}`);
  }
  const body = JSON.parse(bodyText);
  return body.value || [];
}

async function waitForCrmCount(page, expectedCount, maxTries, label) {
  for (let i = 0; i < maxTries; i++) {
    const items = await readCrmItems(page);
    log(`  ${label} poll ${i}: count=${items.length}`);
    if (items.length === expectedCount) return items;
    await page.waitForTimeout(10000);
  }
  return readCrmItems(page);
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const post1 = await postPayload('initial');

  let browser, ctx, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT}`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); cold launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const cleanup = async () => { try { if (ownCtx) await ctx.close(); else if (browser) await browser.close(); } catch {} };
  const page = await ctx.newPage();
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await selectTenantAccountIfPrompted(page);
  await page.waitForTimeout(3000);

  const fields = await getVisibleFieldNames(page);
  const fieldChecks = {
    portalEventIdFieldPresent: fields.has('PortalEventId'),
    sourceCorrelationIdFieldPresent: fields.has('SourceCorrelationId'),
  };
  if (!fieldChecks.portalEventIdFieldPresent || !fieldChecks.sourceCorrelationIdFieldPresent) {
    throw new Error('B8 first-class fields are not present/readable on CRM - New Signals.');
  }

  const afterInitial = await waitForCrmCount(page, 1, 24, 'after initial');
  const firstItemId = afterInitial[0] ? (afterInitial[0].ID || afterInitial[0].Id) : null;

  const post2 = await postPayload('replay');
  await page.waitForTimeout(15000);
  const afterReplay = await waitForCrmCount(page, 1, 6, 'after replay');
  const secondItemId = afterReplay[0] ? (afterReplay[0].ID || afterReplay[0].Id) : null;

  const item = afterReplay[0] || afterInitial[0] || null;
  const checks = {
    initialPostAccepted: post1.status >= 200 && post1.status < 300,
    replayPostAccepted: post2.status >= 200 && post2.status < 300,
    exactlyOneAfterInitial: afterInitial.length === 1,
    exactlyOneAfterReplay: afterReplay.length === 1,
    sameCrmItemAfterReplay: firstItemId && secondItemId && String(firstItemId) === String(secondItemId),
    portalEventIdFirstClass: item ? item.PortalEventId === portalEventId : false,
    sourceCorrelationIdFirstClass: item ? item.SourceCorrelationId === correlationId : false,
    intakeSourceJourney: item ? item.IntakeSource === source : false,
    signalStatusNew: item ? item.SignalStatus === 'New' : false,
    sourceTextHasPortalEventId: item ? String(item.SourceText || '').includes(portalEventId) : false,
    sourceTextHasB8Marker: item ? /B8 replay proof/i.test(String(item.SourceText || item.NeedSummary || '')) : false,
  };
  const pass = Object.values(checks).every(Boolean);
  const evidence = {
    generatedAt: new Date().toISOString(),
    chunk: 'B8b',
    result: pass ? 'PASS' : 'FAIL',
    portalEventId,
    correlationId,
    postResults: [post1, post2],
    fieldChecks,
    counts: {
      afterInitial: afterInitial.length,
      afterReplay: afterReplay.length,
    },
    crmItem: item ? {
      id: item.ID || item.Id,
      title: item.Title,
      portalEventId: item.PortalEventId,
      sourceCorrelationId: item.SourceCorrelationId,
      intakeSource: item.IntakeSource,
      signalStatus: item.SignalStatus,
      priority: item.Priority,
      created: item.Created,
    } : null,
    checks,
    boundary: [
      'Synthetic/internal Journey event only.',
      'No real client replay.',
      'No delete or merge.',
      'No external message send.',
      'No callback URL accepted from payload.',
      'No QUO setup.',
      'No R4 delegated autonomy.',
    ],
  };

  const suffix = `${portalEventId}-${new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-')}`;
  const jsonPath = path.join(OUT, `b8-replay-proof-${suffix}.json`);
  const mdPath = path.join(OUT, `b8-replay-proof-${suffix}.md`);
  fs.writeFileSync(jsonPath, JSON.stringify(evidence, null, 2));
  const lines = [
    '# B8b Replay Proof',
    '',
    `Generated: ${new Date().toISOString()}`,
    '',
    `Status: ${evidence.result}`,
    '',
    `PortalEventId: \`${portalEventId}\``,
    `SourceCorrelationId: \`${correlationId}\``,
    '',
    '| Check | Result |',
    '|---|---|',
    ...Object.entries(checks).map(([key, value]) => `| ${key} | ${value ? 'PASS' : 'FAIL'} |`),
    '',
    `CRM item: ${evidence.crmItem ? `#${evidence.crmItem.id} ${evidence.crmItem.title}` : 'not found'}`,
    `Count after initial POST: ${afterInitial.length}`,
    `Count after replay POST: ${afterReplay.length}`,
    '',
    'Boundary: synthetic/internal event only; no real client replay, delete, merge, external message, QUO setup, or R4 autonomy.',
    '',
    `JSON evidence: ${repoRelative(jsonPath)}`,
  ];
  fs.writeFileSync(mdPath, lines.join('\n') + '\n');

  log(`result=${evidence.result}`);
  log(`evidence: ${mdPath}`);
  await cleanup();
  process.exit(pass ? 0 : 4);
})();
