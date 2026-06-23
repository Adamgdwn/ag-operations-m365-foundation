// End-to-end test for the brand intake flow: submit a clearly-marked internal
// test response through the REAL public Microsoft Form (a fresh, unauthenticated
// browser context = a true website visitor), then poll "CRM - New Signals" using
// the persisted tenant session until the matching item appears. Proves the full
// path Form -> flow -> CRM, including the operator-visible Source + in-band
// provenance footer. The test item is named GAIL-INTERNAL-WALKTHROUGH so Adam can
// spot and triage/delete it. Read-only against the tenant (only the public form
// is written, which is the intended create path).
//
// Usage: node e2e-test.js --brand=labs|journey
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const brandArg = (process.argv.find(a => a.startsWith('--brand=')) || '=labs').split('=')[1];
const BRANDS = { labs: 'Guided AI Labs', journey: 'Guided AI Journey' };
const expectedSource = BRANDS[brandArg] || BRANDS.labs;

const result = JSON.parse(fs.readFileSync(path.join(REPO, 'inventory', 'forms-build', `result-${brandArg}.json`), 'utf8'));
const FORM_URL = result.publicUrl;
const MARK = 'GAIL-INTERNAL-WALKTHROUGH';
const ANS = {
  'Full name': MARK,
  'Email': 'intake-test@guidedailabs.com',
  'Organization': 'GAIL Internal QA',
  'What are you looking for': `E2E flow verification for ${expectedSource} — please triage or delete. Confirms website intake reaches the CRM.`,
  'How did you hear about us': 'Internal walkthrough',
};

(async () => {
  // 1) Submit the public form as an anonymous visitor (fresh, no tenant cookies).
  const visitor = await chromium.launch({ channel: 'msedge', headless: true });
  const vctx = await visitor.newContext({ viewport: { width: 1200, height: 1000 } });
  const vp = await vctx.newPage();
  log(`opening public form: ${FORM_URL.slice(0, 70)}...`);
  await vp.goto(FORM_URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await vp.waitForTimeout(6000);
  // Fill each text question by its accessible name (Forms sets aria-label to the title).
  for (const [label, value] of Object.entries(ANS)) {
    const box = vp.getByRole('textbox', { name: new RegExp(label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i') }).first();
    try { await box.waitFor({ timeout: 8000 }); await box.fill(value); log(`  filled "${label}"`); }
    catch { log(`  WARN could not fill "${label}"`); }
  }
  // Choice questions: pick an intent/path option, then the consent option.
  // Two choice questions now exist ("What best describes your situation?" + the
  // "I agree" consent), so select each by its visible option label to avoid index
  // ambiguity. INTENT_PICK matches the start of the "My team..." rich choice.
  const INTENT_PICK = 'My team';
  const INTENT_EXPECT = 'My team — I want to build team capability';
  let intentDone = false, consentDone = false;
  try { await vp.getByRole('radio', { name: new RegExp(INTENT_PICK, 'i') }).first().click({ timeout: 6000 }); intentDone = true; } catch {}
  try { await vp.getByRole('radio', { name: /I agree/i }).first().click({ timeout: 6000 }); consentDone = true; } catch {}
  if (!consentDone) { const radios = await vp.$$('[role="radio"], input[type="radio"]'); if (radios.length) { await radios[radios.length - 1].click().catch(() => {}); consentDone = true; } }
  log(`  intent selected: ${intentDone} (${INTENT_PICK}) | consent selected: ${consentDone}`);
  await vp.waitForTimeout(1000);
  await vp.screenshot({ path: path.join(CAP, `e2e-${brandArg}-1-filled.png`), fullPage: true }).catch(() => {});
  // Submit.
  const submit = vp.getByRole('button', { name: /^Submit$/i }).first();
  await submit.click({ timeout: 10000 }).catch(async () => { const b = await vp.$('button:has-text("Submit")'); if (b) await b.click().catch(() => {}); });
  await vp.waitForTimeout(7000);
  const after = await vp.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  const submitted = /thank|response was submitted|submit another|recorded/i.test(after);
  await vp.screenshot({ path: path.join(CAP, `e2e-${brandArg}-2-submitted.png`), fullPage: true }).catch(() => {});
  log(`form submitted: ${submitted}`);
  await visitor.close();
  if (!submitted) { log('ERROR: submission not confirmed; aborting CRM poll'); process.exit(2); }

  // 2) Poll the CRM list (persisted tenant session) for the new item.
  const tctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1200, height: 900 } });
  const tp = tctx.pages()[0] || await tctx.newPage();
  await tp.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await tp.waitForTimeout(4000);
  const b = await tp.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(b)) { const t = await tp.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await tp.waitForTimeout(7000); } }
  const sel = '$select=Id,Title,PersonName,PersonEmail,OrganizationName,NeedSummary,SourceText,NextAction,SignalType,IntakeSource,IntentPath,SignalStatus,Priority,Created';
  const url = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?${sel}&$filter=PersonName eq '${MARK}'&$orderby=Id desc&$top=5`;
  let found = null;
  for (let i = 0; i < 24; i++) { // up to ~4 min
    const r = await tp.request.get(url, { headers: { accept: 'application/json;odata=nometadata' } });
    const j = JSON.parse(await r.text());
    if (j.value && j.value.length) { found = j.value[0]; break; }
    log(`  poll ${i}: not yet in CRM...`);
    await tp.waitForTimeout(10000);
  }
  if (!found) { log('ERROR: test item did not appear in CRM within timeout'); await tctx.close(); process.exit(3); }
  fs.writeFileSync(path.join(CAP, `e2e-${brandArg}-crm-item.json`), JSON.stringify(found, null, 2));
  log('\n=== CRM ITEM CREATED ===');
  log(`  Id: ${found.Id}  Title: ${found.Title}`);
  log(`  Source (IntakeSource): ${found.IntakeSource}  [expected: ${expectedSource}]`);
  log(`  IntentPath (column): ${found.IntentPath}  [expected: ${INTENT_EXPECT}]`);
  log(`  SignalType: ${found.SignalType}  SignalStatus: ${found.SignalStatus}  Priority: ${found.Priority}`);
  log(`  PersonName: ${found.PersonName}  Email: ${found.PersonEmail}  Org: ${found.OrganizationName}`);
  log(`  NeedSummary: ${(found.NeedSummary || '').slice(0, 80)}`);
  log(`  NextAction: ${found.NextAction}`);
  log(`  Created: ${found.Created}`);
  log('  --- SourceText (with provenance footer) ---');
  for (const line of (found.SourceText || '').split('\n')) log('    ' + line);
  const checks = {
    sourceMatches: found.IntakeSource === expectedSource,
    statusNew: found.SignalStatus === 'New',
    typeWebsite: found.SignalType === 'Website',
    provenanceFooter: /Provenance/i.test(found.SourceText || '') && /Auto-captured/i.test(found.SourceText || ''),
    hasResponseId: /Forms response id:/i.test(found.SourceText || ''),
    intentColumn: (found.IntentPath || '') === INTENT_EXPECT,
    intentInSourceText: new RegExp(`Situation:\\s*${INTENT_PICK}`, 'i').test(found.SourceText || ''),
  };
  log('\n=== CHECKS ===');
  for (const [k, v] of Object.entries(checks)) log(`  ${v ? 'PASS' : 'FAIL'}  ${k}`);
  const allPass = Object.values(checks).every(Boolean);
  log(`\nRESULT: ${allPass ? 'ALL CHECKS PASS' : 'SOME CHECKS FAILED'}`);
  await tctx.close();
  process.exit(allPass ? 0 : 4);
})();
