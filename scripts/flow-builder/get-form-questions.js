// Fetch the question ids for both brand forms via the formapi (reusing the
// persisted forms.office.com cookie session). The Power Automate "Get response
// details" action returns answers keyed by these question ids, so the flow needs
// them to map each answer to a CRM field. Writes a compact map to .local.
//
// Usage: node get-form-questions.js
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
const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const ITEM = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/forms`;

const FORMS = {
  labs: JSON.parse(fs.readFileSync(path.join(REPO, 'inventory', 'forms-build', 'result-labs.json'), 'utf8')).formId,
  journey: JSON.parse(fs.readFileSync(path.join(REPO, 'inventory', 'forms-build', 'result-journey.json'), 'utf8')).formId,
};

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1200, height: 800 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  let hdr = null;
  page.on('request', req => { if (!hdr && req.headers()['__requestverificationtoken']) hdr = req.headers(); });
  const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
  const handlePicker = async () => {
    const body = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
    if (/Pick an account/i.test(body)) {
      log('account picker shown; selecting ' + TENANT_ACCT);
      const tile = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null);
      if (tile) { await tile.click().catch(() => {}); await page.waitForTimeout(8000); log('  tile clicked; url=' + page.url().slice(0, 60)); }
      else log('  tile not found by data-test-id');
    }
  };
  await page.goto('https://forms.office.com/', { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(4000);
  await handlePicker();
  await page.waitForTimeout(3000);
  if (!hdr) { await page.goto(`https://forms.office.com/Pages/DesignPageV2.aspx?origin=Link&subpage=design&id=${FORMS.labs}`, { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {}); await page.waitForTimeout(4000); await handlePicker(); await page.waitForTimeout(5000); }
  if (!hdr || !hdr['__requestverificationtoken']) { log('ERROR: no verification token'); await ctx.close(); process.exit(1); }
  const H = { 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];

  const out = {};
  for (const [brand, id] of Object.entries(FORMS)) {
    const r = await page.request.get(`${ITEM}('${id}')/questions`, { headers: H });
    const j = JSON.parse(await r.text());
    const qs = (j.value || []).sort((a, b) => a.order - b.order).map(q => ({ id: q.id, title: q.title, type: q.type, order: q.order }));
    out[brand] = { formId: id, questions: qs };
    log(`${brand}: ${qs.length} questions`);
    for (const q of qs) log(`   ${q.id}  ${q.title}  (${q.type})`);
  }
  fs.writeFileSync(path.join(CAP, 'form-questions.json'), JSON.stringify(out, null, 2));
  log('wrote form-questions.json');
  await ctx.close();
})();
