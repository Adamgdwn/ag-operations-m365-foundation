// Add the intent/path Choice question requested by the website agent to both
// live brand forms, placed just before the consent question. Reuses the
// reverse-engineered Forms formapi (persisted .local session). Idempotent: if a
// question with the same title already exists on a form, it is left as-is. The
// public form URL/id does NOT change. After this, re-run get-form-questions.js so
// the flow can map the new answer.
//
// Usage: node add-intent-question.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const ITEM = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/forms`;
const qid = () => 'r' + crypto.randomBytes(16).toString('hex');

const TITLE = 'Who is this for?';
const CHOICES = ['For me', 'For my team', 'For my organization', 'Governance or policy'];
const REQUIRED = false; // friction-light: capture when answered, do not block submission

const FORMS = {
  labs: JSON.parse(fs.readFileSync(path.join(OUT, 'result-labs.json'), 'utf8')).formId,
  journey: JSON.parse(fs.readFileSync(path.join(OUT, 'result-journey.json'), 'utf8')).formId,
};

function choiceBody(order) {
  const choices = CHOICES.map(c => ({ Description: c, IsGenerated: false }));
  return { questionInfo: JSON.stringify({ Choices: choices, ChoiceType: 1, AllowOtherAnswer: false, OptionDisplayStyle: 'ListAll', ChoiceRestrictionType: 'None' }), type: 'Question.Choice', title: TITLE, id: qid(), order, isQuiz: false, required: REQUIRED };
}

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  let hdr = null;
  page.on('request', req => { if (!hdr && req.headers()['__requestverificationtoken']) hdr = req.headers(); });
  const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
  await page.goto('https://forms.office.com/', { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(4000);
  const b = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(b)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(7000); } }
  await page.waitForTimeout(2000);
  if (!hdr || !hdr['__requestverificationtoken']) { await page.goto(`https://forms.office.com/Pages/DesignPageV2.aspx?origin=Link&subpage=design&id=${FORMS.labs}`, { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {}); await page.waitForTimeout(5000); }
  if (!hdr || !hdr['__requestverificationtoken']) { log('ERROR: no verification token'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];
  const api = {
    post: (url, body) => page.request.post(url, { headers: H, data: JSON.stringify(body) }),
    get: (url) => page.request.get(url, { headers: H }),
  };

  for (const [brand, id] of Object.entries(FORMS)) {
    log(`=== ${brand} (${id.slice(0, 16)}...) ===`);
    const qs = JSON.parse(await (await api.get(`${ITEM}('${id}')/questions`)).text()).value || [];
    if (qs.some(q => (q.title || '').trim().toLowerCase() === TITLE.toLowerCase())) { log(`  already present; skipping`); continue; }
    // Place just before the consent question ("I agree...").
    const consent = qs.find(q => /^i agree/i.test(q.title || ''));
    const hear = qs.find(q => /^how did you hear/i.test(q.title || ''));
    let order;
    if (consent && hear && consent.order > hear.order) order = Math.floor((hear.order + consent.order) / 2);
    else if (consent) order = consent.order - 1;
    else order = Math.max(...qs.map(q => q.order || 0), 1000000) + 1000;
    const r = await api.post(`${ITEM}('${id}')/questions`, choiceBody(order));
    log(`  + Choice "${TITLE}" (order ${order}) required=${REQUIRED} -> ${r.status()}`);
    if (r.status() >= 300) { log('    body: ' + (await r.text()).slice(0, 400)); continue; }
    // Readback confirm.
    const qs2 = JSON.parse(await (await api.get(`${ITEM}('${id}')/questions`)).text()).value || [];
    const present = qs2.some(q => (q.title || '').trim().toLowerCase() === TITLE.toLowerCase());
    log(`  readback present=${present} totalQuestions=${qs2.length}`);
  }
  await ctx.close();
  log('done');
})();
