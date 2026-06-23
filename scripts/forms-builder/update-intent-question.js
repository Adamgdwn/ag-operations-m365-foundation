// Update the intent/path question on both live brand forms to the richer wording
// Adam approved ("keep consistency, richer", relayed via the Journey site agent).
// In-place PATCH of the existing "Who is this for?" Choice question -> new title
// "What best describes your situation?" + four descriptive choices. The question
// id and the public form URL/id do NOT change. Idempotent: if the new title is
// already present it skips; if neither old nor new is present it adds the question
// before the consent question. Reuses the reverse-engineered Forms formapi
// (persisted .local session).
//
// IMPORTANT: NEW_CHOICES must stay byte-identical to the IntentPath column choices
// in config/crm.sharepoint.json so the Path B flow's pass-through always matches.
//
// Usage: node update-intent-question.js
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

const OLD_TITLE = 'Who is this for?';
const NEW_TITLE = 'What best describes your situation?';
const NEW_CHOICES = [
  'Just me — I want to grow my own AI skills',
  'My team — I want to build team capability',
  'My organization — we need a broader AI strategy',
  'Governance or policy — we need frameworks and oversight',
];
const REQUIRED = false; // friction-light: capture when answered, never block submission

const FORMS = {
  labs: JSON.parse(fs.readFileSync(path.join(OUT, 'result-labs.json'), 'utf8')).formId,
  journey: JSON.parse(fs.readFileSync(path.join(OUT, 'result-journey.json'), 'utf8')).formId,
};

const questionInfo = () => JSON.stringify({
  Choices: NEW_CHOICES.map(c => ({ Description: c, IsGenerated: false })),
  ChoiceType: 1, AllowOtherAnswer: false, OptionDisplayStyle: 'ListAll', ChoiceRestrictionType: 'None',
});

const HEADED = process.argv.includes('--headed') || process.env.HEADED === '1';
const TOKEN_WAIT_MS = HEADED ? 180000 : 20000; // headed: give time to sign in once

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: !HEADED, viewport: { width: 1400, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  let hdr = null;
  page.on('request', req => { if (!hdr && req.headers()['__requestverificationtoken']) hdr = req.headers(); });
  const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
  const haveToken = () => hdr && hdr['__requestverificationtoken'];
  // Poll until the verification token is observed. In headed mode this gives the
  // operator time to complete a single Microsoft sign-in; the form design page
  // re-issues formapi requests that carry the token once authenticated.
  const deadline = Date.now() + TOKEN_WAIT_MS;
  let firstPass = true;
  while (!haveToken() && Date.now() < deadline) {
    const url = firstPass ? 'https://forms.office.com/' : `https://forms.office.com/Pages/DesignPageV2.aspx?origin=Link&subpage=design&id=${FORMS.labs}`;
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {});
    await page.waitForTimeout(3000);
    const b = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
    if (/Pick an account/i.test(b)) { const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null); if (t) { await t.click().catch(() => {}); await page.waitForTimeout(6000); } }
    if (firstPass && HEADED) log('  if a Microsoft sign-in appears, complete it once; this window will continue automatically');
    firstPass = false;
    if (!haveToken()) await page.waitForTimeout(3000);
  }
  if (!haveToken()) { log('ERROR: no verification token (sign-in not completed in time)'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];
  const api = {
    post: (url, body) => page.request.post(url, { headers: H, data: JSON.stringify(body) }),
    patch: (url, body) => page.request.patch(url, { headers: H, data: JSON.stringify(body) }),
    get: (url) => page.request.get(url, { headers: H }),
  };

  let allOk = true;
  for (const [brand, id] of Object.entries(FORMS)) {
    log(`=== ${brand} (${id.slice(0, 16)}...) ===`);
    const qs = JSON.parse(await (await api.get(`${ITEM}('${id}')/questions`)).text()).value || [];
    const lc = (t) => (t || '').trim().toLowerCase();
    const already = qs.find(q => lc(q.title) === NEW_TITLE.toLowerCase());
    if (already) { log('  new title already present; skipping'); continue; }
    const old = qs.find(q => lc(q.title) === OLD_TITLE.toLowerCase());
    if (old) {
      // In-place update: keep the question id and order, swap title + choices.
      const body = { title: NEW_TITLE, questionInfo: questionInfo(), type: 'Question.Choice', required: REQUIRED, order: old.order };
      const r = await api.patch(`${ITEM}('${id}')/questions('${old.id}')`, body);
      log(`  PATCH "${OLD_TITLE}" -> "${NEW_TITLE}" (id ${old.id.slice(0, 10)}, order ${old.order}) -> ${r.status()}`);
      if (r.status() >= 300) { log('    body: ' + (await r.text()).slice(0, 400)); allOk = false; continue; }
    } else {
      // Neither present: add it before the consent question.
      const consent = qs.find(q => /^i agree/i.test(q.title || ''));
      const hear = qs.find(q => /^how did you hear/i.test(q.title || ''));
      let order;
      if (consent && hear && consent.order > hear.order) order = Math.floor((hear.order + consent.order) / 2);
      else if (consent) order = consent.order - 1;
      else order = Math.max(...qs.map(q => q.order || 0), 1000000) + 1000;
      const body = { questionInfo: questionInfo(), type: 'Question.Choice', title: NEW_TITLE, id: qid(), order, isQuiz: false, required: REQUIRED };
      const r = await api.post(`${ITEM}('${id}')/questions`, body);
      log(`  + Choice "${NEW_TITLE}" (order ${order}) -> ${r.status()}`);
      if (r.status() >= 300) { log('    body: ' + (await r.text()).slice(0, 400)); allOk = false; continue; }
    }
    // Readback confirm: new title present, choices match.
    const qs2 = JSON.parse(await (await api.get(`${ITEM}('${id}')/questions`)).text()).value || [];
    const now = qs2.find(q => lc(q.title) === NEW_TITLE.toLowerCase());
    const choices = now ? (JSON.parse(now.questionInfo || '{}').Choices || []).map(c => c.Description) : [];
    const choicesOk = JSON.stringify(choices) === JSON.stringify(NEW_CHOICES);
    log(`  readback: present=${!!now} choicesOk=${choicesOk} totalQuestions=${qs2.length}`);
    if (!now || !choicesOk) allOk = false;
  }
  await ctx.close();
  log(`done allOk=${allOk}`);
  process.exit(allOk ? 0 : 1);
})();
