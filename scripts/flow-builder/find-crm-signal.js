// Read-only: find CRM - New Signals items by Journey portalEventId/correlation.
// B8-aware behavior:
//   - If first-class PortalEventId / SourceCorrelationId fields exist, query them.
//   - Otherwise fall back to the historical SourceText metadata scan.
// Saves a small evidence packet. No writes.
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
const CDP_PORT = process.env.CDP_PORT || '9222';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const portalEventId = (process.argv.find(a => a.startsWith('--portalEventId=')) || '').split('=')[1];
const sourceCorrelationId = (process.argv.find(a => a.startsWith('--sourceCorrelationId=')) || '').split('=')[1];
const evidenceChunk = (process.argv.find(a => a.startsWith('--chunk=')) || '=b8').split('=')[1].replace(/[^a-zA-Z0-9-]/g, '');
const OUT = path.join(REPO, 'inventory', `m365-interaction-agent-${evidenceChunk || 'b8'}`);
const top = Number((process.argv.find(a => a.startsWith('--top=')) || '=5').split('=')[1] || 5);
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

if (!portalEventId && !sourceCorrelationId) {
  console.error('Usage: node scripts/flow-builder/find-crm-signal.js --portalEventId=<uuid> [--sourceCorrelationId=<id>] [--chunk=b8]');
  process.exit(2);
}

function escapeODataString(value) {
  return String(value).replaceAll("'", "''");
}

async function getVisibleFieldNames(page) {
  const fieldUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/fields?$select=InternalName,Title,Hidden`;
  const response = await page.request.get(fieldUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    log(`WARN: field read failed HTTP ${response.status()} ${bodyText.slice(0, 300)}`);
    return new Set();
  }
  const body = JSON.parse(bodyText);
  return new Set((body.value || []).filter((field) => !field.Hidden).map((field) => field.InternalName));
}

async function readCrmItems(page, selectFields, filter, orderBy, limit) {
  const select = `$select=${selectFields.join(',')}`;
  const filterPart = filter ? `&$filter=${encodeURIComponent(filter)}` : '';
  const orderPart = orderBy ? `&$orderby=${encodeURIComponent(orderBy)}` : '';
  const url = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?${select}${filterPart}${orderPart}&$top=${limit}`;
  const response = await page.request.get(url, { headers: { accept: 'application/json;odata=nometadata' } });
  const bodyText = await response.text();
  if (response.status() < 200 || response.status() >= 300) {
    throw new Error(`CRM read failed HTTP ${response.status()} ${bodyText.slice(0, 500)}`);
  }
  const body = JSON.parse(bodyText);
  return body.value || [];
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

  const baseFields = ['Id', 'Title', 'PersonName', 'PersonEmail', 'OrganizationName', 'NeedSummary', 'SourceText', 'NextAction', 'SignalType', 'IntakeSource', 'IntentPath', 'SignalStatus', 'Priority', 'Created'];
  const visibleFields = await getVisibleFieldNames(page);
  const hasPortalEventField = visibleFields.has('PortalEventId');
  const hasCorrelationField = visibleFields.has('SourceCorrelationId');
  const selectFields = [...baseFields];
  if (hasPortalEventField) selectFields.push('PortalEventId');
  if (hasCorrelationField) selectFields.push('SourceCorrelationId');

  let lookupMode = 'SourceTextScan';
  let scannedItems = [];
  let items = [];
  const filters = [];
  if (portalEventId && hasPortalEventField) filters.push(`PortalEventId eq '${escapeODataString(portalEventId)}'`);
  if (sourceCorrelationId && hasCorrelationField) filters.push(`SourceCorrelationId eq '${escapeODataString(sourceCorrelationId)}'`);
  if (filters.length) {
    lookupMode = 'FirstClassField';
    scannedItems = await readCrmItems(page, selectFields, filters.length > 1 ? `(${filters.join(' or ')})` : filters[0], 'Id desc', Math.max(top, 50));
    items = scannedItems.slice(0, top);
  }
  if (!items.length) {
    const needleValues = [portalEventId, sourceCorrelationId].filter(Boolean);
    lookupMode = filters.length ? 'FirstClassFieldThenSourceTextFallback' : 'SourceTextScan';
    scannedItems = await readCrmItems(page, selectFields, null, 'Id desc', Math.max(top, 50));
    items = scannedItems.filter((item) => needleValues.some((needle) => String(item.SourceText || '').includes(needle))).slice(0, top);
  }
  const evidence = {
    capturedAt: new Date().toISOString(),
    site: SITE,
    listTitle: LIST_TITLE,
    portalEventId,
    sourceCorrelationId,
    lookupMode,
    fields: {
      portalEventId: hasPortalEventField ? 'present' : 'absent',
      sourceCorrelationId: hasCorrelationField ? 'present' : 'absent',
    },
    scannedCount: scannedItems.length,
    count: items.length,
    items,
    checks: {
      foundExactlyOne: items.length === 1,
      intakeSourceJourney: items.length === 1 ? items[0].IntakeSource === 'Guided AI Journey' : false,
      signalStatusNew: items.length === 1 ? items[0].SignalStatus === 'New' : false,
      firstClassPortalEventId: items.length === 1 && hasPortalEventField && portalEventId ? items[0].PortalEventId === portalEventId : false,
      firstClassSourceCorrelationId: items.length === 1 && hasCorrelationField && sourceCorrelationId ? items[0].SourceCorrelationId === sourceCorrelationId : false,
      sourceTextHasPortalEventId: items.length === 1 && portalEventId ? String(items[0].SourceText || '').includes(portalEventId) : false,
      sourceTextHasSourceCorrelationId: items.length === 1 && sourceCorrelationId ? String(items[0].SourceText || '').includes(sourceCorrelationId) : false,
      sourceTextHasLeadSourceDetail: items.length === 1 ? /Lead source detail:/i.test(String(items[0].SourceText || '')) : false,
      sourceTextHasJourneyAdminInviteSource: items.length === 1 ? /Lead source detail:\s*Journey admin invite/i.test(String(items[0].SourceText || '')) : false,
    },
  };
  fs.mkdirSync(OUT, { recursive: true });
  const safeId = (portalEventId || sourceCorrelationId).replace(/[^a-zA-Z0-9-]/g, '_');
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-');
  const outPath = path.join(OUT, `${evidenceChunk}-crm-readback-${safeId}-${stamp}.json`);
  fs.writeFileSync(outPath, JSON.stringify(evidence, null, 2));

  log(`lookup mode: ${lookupMode}`);
  log(`first-class fields: PortalEventId=${hasPortalEventField} SourceCorrelationId=${hasCorrelationField}`);
  log(`found ${items.length} CRM item(s) for portalEventId=${portalEventId || '(none)'} sourceCorrelationId=${sourceCorrelationId || '(none)'}`);
  if (items[0]) log(`top item: #${items[0].Id} ${items[0].Title}`);
  log(`evidence: ${outPath}`);
  await cleanup();
  process.exit(evidence.checks.foundExactlyOne ? 0 : 3);
})();
