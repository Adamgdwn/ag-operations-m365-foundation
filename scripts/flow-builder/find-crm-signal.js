// Read-only: find CRM - New Signals items by Journey portalEventId/correlation
// text in SourceText and save a small evidence packet.
//
// Usage:
//   node scripts/flow-builder/find-crm-signal.js --portalEventId=<uuid>
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'm365-interaction-agent-b7');
const CDP_PORT = process.env.CDP_PORT || '9222';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const portalEventId = (process.argv.find(a => a.startsWith('--portalEventId=')) || '').split('=')[1];
const top = Number((process.argv.find(a => a.startsWith('--top=')) || '=5').split('=')[1] || 5);
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

if (!portalEventId) {
  console.error('Usage: node scripts/flow-builder/find-crm-signal.js --portalEventId=<uuid>');
  process.exit(2);
}

function escapeODataString(value) {
  return String(value).replaceAll("'", "''");
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

(async () => {
  let ctx, browser, ownCtx = false;
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

  const select = '$select=Id,Title,PersonName,PersonEmail,OrganizationName,NeedSummary,SourceText,NextAction,SignalType,IntakeSource,IntentPath,SignalStatus,Priority,Created';
  const url = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?${select}&$orderby=Id desc&$top=${Math.max(top, 50)}`;
  const response = await page.request.get(url, { headers: { accept: 'application/json;odata=nometadata' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    log(`ERROR: CRM read failed HTTP ${response.status()} ${bodyText.slice(0, 500)}`);
    await cleanup();
    process.exit(1);
  }

  const body = JSON.parse(bodyText);
  const scannedItems = body.value || [];
  const items = scannedItems.filter((item) => String(item.SourceText || '').includes(portalEventId)).slice(0, top);
  const evidence = {
    capturedAt: new Date().toISOString(),
    site: SITE,
    listTitle: LIST_TITLE,
    portalEventId,
    scannedCount: scannedItems.length,
    count: items.length,
    items,
    checks: {
      foundExactlyOne: items.length === 1,
      intakeSourceJourney: items.length === 1 ? items[0].IntakeSource === 'Guided AI Journey' : false,
      signalStatusNew: items.length === 1 ? items[0].SignalStatus === 'New' : false,
      sourceTextHasPortalEventId: items.length === 1 ? String(items[0].SourceText || '').includes(portalEventId) : false,
      sourceTextHasLeadSourceDetail: items.length === 1 ? /Lead source detail:/i.test(String(items[0].SourceText || '')) : false,
      sourceTextHasJourneyAdminInviteSource: items.length === 1 ? /Lead source detail:\s*Journey admin invite/i.test(String(items[0].SourceText || '')) : false,
    },
  };
  fs.mkdirSync(OUT, { recursive: true });
  const safeId = portalEventId.replace(/[^a-zA-Z0-9-]/g, '_');
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-');
  const outPath = path.join(OUT, `b7-crm-readback-${safeId}-${stamp}.json`);
  fs.writeFileSync(outPath, JSON.stringify(evidence, null, 2));

  log(`found ${items.length} CRM item(s) for portalEventId=${portalEventId}`);
  if (items[0]) log(`top item: #${items[0].Id} ${items[0].Title}`);
  log(`evidence: ${outPath}`);
  await cleanup();
  process.exit(evidence.checks.foundExactlyOne ? 0 : 3);
})();
