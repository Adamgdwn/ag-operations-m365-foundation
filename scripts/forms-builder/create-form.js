// Production builder: create a brand intake Microsoft Form end-to-end via the
// formapi (no manual clicking). Create form -> add questions (required flags) ->
// make public (IsAnonymous) -> verify by readback -> emit the public URL.
//
// Usage: node create-form.js --brand=labs|journey [--cleanup-probes]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const COLL = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/light/forms`; // create + list + GET readback
const ITEM = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/forms`;      // item writes: questions, PATCH, DELETE (NO "light/")
const qid = () => 'r' + crypto.randomBytes(16).toString('hex');

const brandArg = (process.argv.find(a => a.startsWith('--brand=')) || '=labs').split('=')[1];
const cleanup = process.argv.includes('--cleanup-probes');
const BRANDS = {
  labs: { title: 'Guided AI Labs — Get started', source: 'Guided AI Labs' },
  journey: { title: 'Guided AI Journey — Get started', source: 'Guided AI Journey' },
};
const brand = BRANDS[brandArg] || BRANDS.labs;

// Question set (identical across brands).
const QUESTIONS = [
  { kind: 'text', title: 'Full name', required: true, multiline: false },
  { kind: 'text', title: 'Email', required: true, multiline: false },
  { kind: 'text', title: 'Organization', required: false, multiline: false },
  { kind: 'text', title: 'What are you looking for?', required: true, multiline: true },
  { kind: 'text', title: 'How did you hear about us?', required: false, multiline: true },
  { kind: 'choice', title: 'I agree to be contacted about my enquiry.', required: true, choices: ['I agree'] },
];

function questionBody(q, order) {
  if (q.kind === 'text') {
    return { questionInfo: JSON.stringify({ Multiline: !!q.multiline }), type: 'Question.TextField', title: q.title, id: qid(), order, isQuiz: false, required: !!q.required };
  }
  const choices = q.choices.map(c => ({ Description: c, IsGenerated: false }));
  return { questionInfo: JSON.stringify({ Choices: choices, ChoiceType: 1, AllowOtherAnswer: false, OptionDisplayStyle: 'ListAll', ChoiceRestrictionType: 'None' }), type: 'Question.Choice', title: q.title, id: qid(), order, isQuiz: false, required: !!q.required };
}

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1400, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  let hdr = null;
  page.on('request', req => { if (!hdr && /light\/forms/i.test(req.url()) && req.method() === 'GET') hdr = req.headers(); });
  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(3500);
  if (!hdr || !hdr['__requestverificationtoken']) { log('ERROR: no verification token'); await ctx.close(); process.exit(1); }
  const H = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-correlationid']) if (hdr[h]) H[h] = hdr[h];
  const api = {
    post: (url, body) => page.request.post(url, { headers: H, data: JSON.stringify(body) }),
    patch: (url, body) => page.request.patch(url, { headers: H, data: JSON.stringify(body) }),
    get: (url) => page.request.get(url, { headers: H }),
    del: (url) => page.request.delete(url, { headers: H }),
  };

  if (cleanup) {
    log('cleanup: deleting probe + prior same-title forms ...');
    const list = JSON.parse(await (await api.get(`${COLL}?$select=id,title`)).text());
    for (const f of (list.value || [])) {
      if (/^GAIL-API-PROBE/i.test(f.title) || f.title === brand.title) { const r = await api.del(`${ITEM}('${f.id}')`); log(`  deleted ${f.title} -> ${r.status()}`); }
    }
  }

  log(`creating form: ${brand.title}`);
  const cr = await api.post(COLL, { title: brand.title, description: '' });
  if (cr.status() < 200 || cr.status() >= 300) { log('create failed ' + cr.status()); log(await cr.text()); await ctx.close(); process.exit(1); }
  const id = JSON.parse(await cr.text()).id;
  log(`form id: ${id}`);

  let order = 1000000;
  for (const q of QUESTIONS) {
    order += 1000;
    const r = await api.post(`${ITEM}('${id}')/questions`, questionBody(q, order));
    log(`  + ${q.kind} "${q.title}" required=${q.required} -> ${r.status()}`);
    if (r.status() >= 300) log('    body: ' + (await r.text()).slice(0, 300));
  }

  log('making form public (IsAnonymous) ...');
  const pr = await api.patch(`${ITEM}('${id}')`, { settings: JSON.stringify({ IsAnonymous: true, RequiresUniqueResponse: false, NotRecordIdentity: false }) });
  log(`  settings PATCH -> ${pr.status()}`);

  // Verify by readback: questions come from the item route, settings from light.
  const rb = JSON.parse(await (await api.get(`${COLL}('${id}')?$select=id,title,settings`)).text());
  const qres = JSON.parse(await (await api.get(`${ITEM}('${id}')/questions`)).text());
  const qs = (qres.value || []).sort((a, b) => a.order - b.order);
  const settings = rb.settings ? JSON.parse(rb.settings) : {};
  const publicUrl = `https://forms.office.com/Pages/ResponsePage.aspx?id=${id}`;

  const verify = {
    brand: brand.source,
    title: rb.title,
    formId: id,
    publicUrl,
    isAnonymous: settings.IsAnonymous === true,
    questionCount: qs.length,
    expectedCount: QUESTIONS.length,
    questions: qs.map(q => ({ title: q.title, type: q.type, required: q.required })),
    requiredOk: QUESTIONS.every((want, i) => qs[i] && qs[i].required === want.required && qs[i].title === want.title),
  };
  verify.PASS = verify.isAnonymous && verify.questionCount === verify.expectedCount && verify.requiredOk;

  const outFile = path.join(OUT, `result-${brandArg}.json`);
  fs.writeFileSync(outFile, JSON.stringify(verify, null, 2));
  log(`RESULT: PASS=${verify.PASS} anon=${verify.isAnonymous} q=${verify.questionCount}/${verify.expectedCount} requiredOk=${verify.requiredOk}`);
  log(`PUBLIC URL: ${publicUrl}`);
  log(`wrote ${outFile}`);
  await ctx.close();
})();
