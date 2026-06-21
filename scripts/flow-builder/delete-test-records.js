// One-off cleanup: delete ONLY the internal end-to-end test records from
// "CRM - New Signals". Safety-scoped — it filters to items whose PersonName is
// exactly GAIL-INTERNAL-WALKTHROUGH, lists them for confirmation, and deletes
// only those. It cannot touch a real website signal (different PersonName).
// Adam explicitly authorized this delete (automation deletes are otherwise out
// of scope). Uses the persisted tenant session + a SharePoint form digest.
//
// Usage: node delete-test-records.js [--dry]
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const MARK = 'GAIL-INTERNAL-WALKTHROUGH';
const DRY = process.argv.includes('--dry');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1200, height: 900 } });
  const p = ctx.pages()[0] || await ctx.newPage();
  await p.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await p.waitForTimeout(4000);
  const body = await p.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(body)) { const t = await p.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await p.waitForTimeout(7000); } }

  // 1) List only the test records.
  const listUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?$select=Id,Title,PersonName,IntakeSource,Created&$filter=PersonName eq '${MARK}'&$orderby=Id asc&$top=50`;
  const lr = await p.request.get(listUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const lj = JSON.parse(await lr.text());
  const items = lj.value || [];
  log(`found ${items.length} test record(s) named "${MARK}":`);
  for (const it of items) log(`  Id ${it.Id}  Source=${it.IntakeSource}  Created=${it.Created}`);
  if (!items.length) { log('nothing to delete.'); await ctx.close(); process.exit(0); }
  if (DRY) { log('dry run — not deleting.'); await ctx.close(); process.exit(0); }

  // 2) Get a form digest for write operations.
  const dr = await p.request.post(`${SITE}/_api/contextinfo`, { headers: { accept: 'application/json;odata=nometadata' } });
  const digest = JSON.parse(await dr.text()).FormDigestValue;

  // 3) Delete each by Id (scoped to the listed test items only).
  let ok = 0;
  for (const it of items) {
    const delUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items(${it.Id})`;
    const resp = await p.request.fetch(delUrl, { method: 'POST', headers: { accept: 'application/json;odata=nometadata', 'X-RequestDigest': digest, 'IF-MATCH': '*', 'X-HTTP-Method': 'DELETE' } });
    if (resp.status() === 200 || resp.status() === 204) { ok++; log(`  deleted Id ${it.Id}`); }
    else log(`  FAILED Id ${it.Id} -> ${resp.status()} ${(await resp.text()).slice(0, 200)}`);
  }

  // 4) Verify none remain.
  const vr = await p.request.get(listUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const remaining = (JSON.parse(await vr.text()).value || []).length;
  log(`\nDeleted ${ok}/${items.length}. Remaining "${MARK}" records: ${remaining}`);
  await ctx.close();
  process.exit(remaining === 0 ? 0 : 5);
})();
