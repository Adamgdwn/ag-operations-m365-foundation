// End-to-end test for the CUSTOM-FORM HTTP intake flow. POSTs a clearly-marked
// internal test payload to the flow's callback endpoint (exactly as a brand
// website's backend would), then polls "CRM - New Signals" until the matching
// item appears and checks field/provenance parity with the Microsoft Forms path.
// Also exercises the guard: negative cases must NOT create an item.
//
// Reads the endpoint + secret from .local/flow-builder/ (gitignored). Requires the
// flow to be ACTIVATED (needs Power Automate Premium) — otherwise POSTs are accepted
// but the run is skipped by the licensing suspension.
//
// Usage:
//   node http-intake-e2e.js --brand=labs|journey            # happy path
//   node http-intake-e2e.js --brand=labs --case=badsecret   # expect NO item
//   node http-intake-e2e.js --brand=labs --case=honeypot    # expect NO item
//   node http-intake-e2e.js --brand=labs --case=badsource   # expect NO item
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const SECRET_DIR = path.join(REPO, '.local', 'flow-builder');
const CDP_PORT = process.env.CDP_PORT || '9222';
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const MARK = 'GAIL-INTERNAL-WALKTHROUGH';
const INTENT_EXPECT = 'My team — I want to build team capability';

const brandArg = (process.argv.find(a => a.startsWith('--brand=')) || '=labs').split('=')[1];
const testCase = (process.argv.find(a => a.startsWith('--case=')) || '=happy').split('=')[1];
const ackArg = (process.argv.find(a => a.startsWith('--ack=')) || '').split('=')[1];
const BRANDS = { labs: 'Guided AI Labs', journey: 'Guided AI Journey' };
const source = BRANDS[brandArg] || BRANDS.labs;
const ackRequested = ackArg ? /^true$/i.test(ackArg) : brandArg === 'journey';
const stamp = Date.now();
const portalEventId = `${brandArg}-portal-event-${stamp}`;

const endpoint = fs.readFileSync(path.join(SECRET_DIR, 'http-intake-endpoint.txt'), 'utf8').trim();
const secret = fs.readFileSync(path.join(SECRET_DIR, 'http-intake-secret.txt'), 'utf8').trim();

const payload = {
  schemaVersion: 'journey.crm-signal.v1',
  signalMode: brandArg === 'journey' ? 'portal-lifecycle-event' : 'website-intake',
  eventType: brandArg === 'journey' ? 'organization_setup_saved' : 'website.intake.submitted',
  portalEventId: brandArg === 'journey' ? portalEventId : '',
  correlationId: brandArg === 'journey' ? portalEventId : `${brandArg}-http-intake-e2e-${stamp}`,
  companyId: brandArg === 'journey' ? 'journey-company-internal-qa' : '',
  engagementId: brandArg === 'journey' ? 'journey-engagement-internal-qa' : '',
  inviteId: brandArg === 'journey' ? `journey-invite-e2e-${stamp}` : '',
  journeyInviteId: brandArg === 'journey' ? `journey-invite-e2e-${stamp}` : '',
  journeyOrganizationId: brandArg === 'journey' ? 'journey-org-internal-qa' : '',
  sourceAction: brandArg === 'journey' ? 'admin_invited_person' : '',
  portalDeepLink: brandArg === 'journey' ? 'https://www.guidedaijourney.com/dashboard/internal-qa' : '',
  eventTimestamp: new Date().toISOString(),
  ackRequested,
  source, fullName: MARK, email: 'intake-test@guidedailabs.com', organization: 'GAIL Internal QA',
  needSummary: `Custom-form e2e for ${source} — please triage or delete.`,
  situation: INTENT_EXPECT, heardFrom: 'Internal walkthrough', consent: true, company: '',
};
let headerSecret = secret;
if (testCase === 'badsecret') headerSecret = 'wrong-secret';
if (testCase === 'honeypot') payload.company = 'bot-filled';
if (testCase === 'badsource') payload.source = 'Totally Fake Brand';
const expectItem = testCase === 'happy';

(async () => {
  // 1) POST to the endpoint exactly like a site backend would.
  log(`POST ${endpoint.slice(0, 60)}...  case=${testCase} brand=${brandArg}`);
  let status, text;
  try {
    const r = await fetch(endpoint, { method: 'POST', headers: { 'content-type': 'application/json', 'x-intake-secret': headerSecret }, body: JSON.stringify(payload) });
    status = r.status; text = await r.text();
  } catch (e) { log('POST failed: ' + e.message); process.exit(2); }
  log(`  -> HTTP ${status} ${text.slice(0, 120)}`);

  // 2) Poll the CRM for the test item via the warm Edge (CDP) tenant session.
  let browser, ctx, ownCtx = false;
  try { browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 }); ctx = browser.contexts()[0] || await browser.newContext(); }
  catch { ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true }); ownCtx = true; }
  const cleanup = async () => { try { if (ownCtx) await ctx.close(); else if (browser) await browser.close(); } catch {} };
  const tp = await ctx.newPage();
  await tp.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await tp.waitForTimeout(3000);
  const sel = '$select=Id,Title,PersonName,PersonEmail,OrganizationName,NeedSummary,SourceText,NextAction,SignalType,IntakeSource,IntentPath,SignalStatus,Priority,Created';
  const url = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?${sel}&$filter=PersonName eq '${MARK}'&$orderby=Id desc&$top=5`;
  let found = null;
  const tries = expectItem ? 18 : 6; // happy: wait up to ~3min; negative: brief confirm of absence
  for (let i = 0; i < tries; i++) {
    const r = await tp.request.get(url, { headers: { accept: 'application/json;odata=nometadata' } });
    const j = JSON.parse(await r.text());
    if (j.value && j.value.length) { found = j.value[0]; break; }
    log(`  poll ${i}: no item yet`);
    await tp.waitForTimeout(10000);
  }

  if (!expectItem) {
    const pass = !found;
    log(`\nNEGATIVE case '${testCase}': item created = ${!!found} (expected none)`);
    log(`RESULT: ${pass ? 'PASS (guard blocked the write)' : 'FAIL (guard let it through!)'}`);
    if (found) log(`  stray item Id ${found.Id} — delete via delete-test-records.js`);
    await cleanup(); process.exit(pass ? 0 : 5);
  }

  if (!found) { log('ERROR: happy-path item did not appear (flow not activated? premium not assigned?)'); await cleanup(); process.exit(3); }
  log('\n=== CRM ITEM CREATED ===');
  log(`  Id ${found.Id}  Title: ${found.Title}`);
  log(`  IntakeSource: ${found.IntakeSource} [${source}]  IntentPath: ${found.IntentPath} [${INTENT_EXPECT}]`);
  log(`  SignalType: ${found.SignalType}  Status: ${found.SignalStatus}  Priority: ${found.Priority}`);
  for (const line of (found.SourceText || '').split('\n')) log('    ' + line);
  const checks = {
    sourceMatches: found.IntakeSource === source,
    intentColumn: found.IntentPath === INTENT_EXPECT,
    statusNew: found.SignalStatus === 'New',
    typeWebsite: found.SignalType === 'Website',
    customProvenance: /custom site form/i.test(found.SourceText || ''),
    intakeId: /Intake id:/i.test(found.SourceText || ''),
    leadSourceDetail: /Lead source detail:/i.test(found.SourceText || ''),
    journeyAdminInviteSource: brandArg === 'journey' ? /Lead source detail:\s*Journey admin invite/i.test(found.SourceText || '') : true,
    portalEventProvenance: brandArg === 'journey' ? /Portal event id:/i.test(found.SourceText || '') : true,
    correlationProvenance: brandArg === 'journey' ? /Correlation id:/i.test(found.SourceText || '') : true,
    journeyInviteProvenance: brandArg === 'journey' ? /Journey invite id:/i.test(found.SourceText || '') : true,
  };
  log('\n=== CHECKS ===');
  for (const [k, v] of Object.entries(checks)) log(`  ${v ? 'PASS' : 'FAIL'}  ${k}`);
  const allPass = Object.values(checks).every(Boolean);
  log(`\nRESULT: ${allPass ? 'ALL CHECKS PASS' : 'SOME CHECKS FAILED'}  (clean up with delete-test-records.js)`);
  await cleanup();
  process.exit(allPass ? 0 : 4);
})();
