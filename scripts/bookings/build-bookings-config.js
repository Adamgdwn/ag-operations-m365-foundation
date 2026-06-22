// Configure the GAIL shared booking page via Microsoft Graph using DIRECT-ID addressing
// (the Bookings LIST endpoint 403s tenant-wide, but GET/PATCH/POST/DELETE by business id work).
// Auth = silent delegated token through the signed-in Edge profile (login_hint, no device code).
//   - delete the duplicate GuidedAILabs2 from the double-create
//   - make the page PUBLIC (bookingPageSettings.accessControl = 'unrestricted')  [approved unlock]
//   - currency CAD, website url, ensure Adam is administrator staff (free/busy on)
//   - clean services to exactly: Intro call (30 min), Working session (60 min) [Teams online, staff-assigned]
//   - custom questions: Organization (optional), What would you like to cover?
//   - re-publish; capture publicUrl + SMTP -> inventory/forms-build/bookings-result.json
//   node scripts/bookings/build-bookings-config.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(CAP, { recursive: true }); fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const CLIENT_ID = '14d82eec-204b-4c2f-b7e8-296a70dab67e';
const REDIRECT = 'http://localhost:8400/';
const AUTH = 'https://login.microsoftonline.com/organizations/oauth2/v2.0';
const SCOPE = 'https://graph.microsoft.com/Bookings.ReadWrite.All offline_access openid profile';
const GBASE = 'https://graph.microsoft.com/v1.0/solutions/bookingBusinesses';
const b64url = (buf) => buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const BUSINESS_ID = 'GuidedAILabs1@agoperations.ca';
const DUPLICATE_ID = 'GuidedAILabs2@agoperations.ca';
const OWNER_EMAIL = 'adamgoodwin@guidedailabs.com';
const SERVICES = [
  { displayName: 'Intro call (30 min)', defaultDuration: 'PT30M', postBuffer: 'PT10M', notes: 'A short introductory call.' },
  { displayName: 'Working session (60 min)', defaultDuration: 'PT1H', postBuffer: 'PT15M', notes: 'A focused working session.' },
];
const QUESTIONS = [
  { displayName: 'Organization (optional)', answerInputType: 'text' },
  { displayName: 'What would you like to cover?', answerInputType: 'text' },
];

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1200, height: 850 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  // ---- silent auth-code + PKCE ----
  const verifier = b64url(crypto.randomBytes(32));
  const challenge = b64url(crypto.createHash('sha256').update(verifier).digest());
  let authCode = null, resolveCode; const codeP = new Promise(r => (resolveCode = r));
  await page.route(REDIRECT + '**', (route) => { try { const c = new URL(route.request().url()).searchParams.get('code'); if (c && !authCode) { authCode = c; resolveCode(c); } } catch {} route.fulfill({ status: 200, contentType: 'text/html', body: 'ok' }).catch(() => {}); });
  const authUrl = `${AUTH}/authorize?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT)}&response_mode=query&scope=${encodeURIComponent(SCOPE)}&state=x&code_challenge=${challenge}&code_challenge_method=S256&login_hint=${encodeURIComponent(OWNER_EMAIL)}`;
  await page.goto(authUrl, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await Promise.race([codeP, new Promise((_, rej) => setTimeout(() => rej(new Error('auth timeout')), 120000))]);
  const tokRes = await page.request.post(`${AUTH}/token`, { form: { client_id: CLIENT_ID, grant_type: 'authorization_code', code: authCode, redirect_uri: REDIRECT, code_verifier: verifier, scope: SCOPE } });
  const TOKEN = JSON.parse(await tokRes.text()).access_token;
  if (!TOKEN) { log('FATAL: no token'); await ctx.close(); process.exit(1); }
  log('token acquired');
  const req = async (method, url, body) => {
    const opts = { method, headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } };
    if (body) { opts.headers['content-type'] = 'application/json'; opts.data = JSON.stringify(body); }
    const r = await page.request.fetch(url, opts); const text = await r.text();
    return { status: r.status(), text, json: (() => { try { return JSON.parse(text); } catch { return null; } })() };
  };
  const B = `${GBASE}/${encodeURIComponent(BUSINESS_ID)}`;
  const errors = [];

  // ---- 0. delete the duplicate ----
  const del = await req('DELETE', `${GBASE}/${encodeURIComponent(DUPLICATE_ID)}`);
  log(`delete duplicate ${DUPLICATE_ID} -> ${del.status}`);
  if (del.status >= 300 && del.status !== 404) errors.push('delete dup: ' + del.status + ' ' + del.text.slice(0, 150));

  // ---- 1. PATCH business: PUBLIC access, currency, website ----
  const patch = await req('PATCH', B, {
    webSiteUrl: 'https://guidedailabs.com',
    defaultCurrencyIso: 'CAD',
    bookingPageSettings: { accessControl: 'unrestricted', isBusinessLogoDisplayEnabled: true },
  });
  log(`patch business (public/currency/site) -> ${patch.status}`);
  if (patch.status >= 300) errors.push('patch business: ' + patch.status + ' ' + patch.text.slice(0, 250));

  // ---- 2. staff (ensure Adam = administrator) ----
  const sl = await req('GET', `${B}/staffMembers`);
  let staffId = ((sl.json && sl.json.value) || []).find(s => (s.emailAddress || '').toLowerCase() === OWNER_EMAIL.toLowerCase())?.id;
  if (!staffId) {
    const sc = await req('POST', `${B}/staffMembers`, { '@odata.type': '#microsoft.graph.bookingStaffMember', displayName: 'Adam Goodwin', emailAddress: OWNER_EMAIL, role: 'administrator', useBusinessHours: true, availabilityIsAffectedByPersonalCalendar: true });
    log(`create staff -> ${sc.status}`); staffId = sc.json && sc.json.id; if (sc.status >= 300) errors.push('staff: ' + sc.status + ' ' + sc.text.slice(0, 200));
  } else log(`staff Adam present: ${staffId}`);

  // ---- 3. custom questions (idempotent by displayName) ----
  const ql = await req('GET', `${B}/customQuestions`);
  const qByName = {}; ((ql.json && ql.json.value) || []).forEach(q => { qByName[(q.displayName || '').toLowerCase()] = q.id; });
  const questionIds = [];
  for (const q of QUESTIONS) {
    let qid = qByName[q.displayName.toLowerCase()];
    if (!qid) { const qc = await req('POST', `${B}/customQuestions`, q); log(`question "${q.displayName}" -> ${qc.status}`); if (qc.status < 300) qid = qc.json && qc.json.id; else errors.push('q: ' + qc.status + ' ' + qc.text.slice(0, 150)); }
    if (qid) questionIds.push(qid);
  }

  // ---- 4. services: make desired set, remove others (the auto default) ----
  const svl = await req('GET', `${B}/services?$select=id,displayName`);
  const existing = ((svl.json && svl.json.value) || []);
  const desiredNames = SERVICES.map(s => s.displayName.toLowerCase());
  const builtServices = [];
  for (const svc of SERVICES) {
    const body = {
      displayName: svc.displayName, defaultDuration: svc.defaultDuration, preBuffer: 'PT0M', postBuffer: svc.postBuffer,
      isLocationOnline: true, notes: svc.notes, maximumAttendeesCount: 1,
      staffMemberIds: staffId ? [staffId] : [],
      defaultReminders: [{ offset: 'P1D', recipients: 'allAttendees', message: 'Reminder: your session is tomorrow.' }],
      customQuestions: questionIds.map(qid => ({ questionId: qid, isRequired: false })),
    };
    const found = existing.find(s => (s.displayName || '').toLowerCase() === svc.displayName.toLowerCase());
    let res, sid;
    if (found) { res = await req('PATCH', `${B}/services/${encodeURIComponent(found.id)}`, body); sid = found.id; log(`patch service "${svc.displayName}" -> ${res.status}`); }
    else { res = await req('POST', `${B}/services`, body); sid = res.json && res.json.id; log(`create service "${svc.displayName}" -> ${res.status}`); }
    if (res.status >= 300) errors.push('svc ' + svc.displayName + ': ' + res.status + ' ' + res.text.slice(0, 200));
    builtServices.push({ displayName: svc.displayName, id: sid || null, status: res.status });
  }
  // delete any non-desired services (the auto-created "30-min meeting" default)
  for (const s of existing) {
    if (!desiredNames.includes((s.displayName || '').toLowerCase())) {
      const d = await req('DELETE', `${B}/services/${encodeURIComponent(s.id)}`);
      log(`delete default service "${s.displayName}" -> ${d.status}`);
      if (d.status >= 300 && d.status !== 404) errors.push('del svc: ' + d.status);
    }
  }

  // ---- 5. publish + capture ----
  const pub = await req('POST', `${B}/publish`); log(`publish -> ${pub.status}`); if (pub.status >= 300) errors.push('publish: ' + pub.status + ' ' + pub.text.slice(0, 150));
  const finalB = await req('GET', `${B}?$select=id,displayName,email,publicUrl,isPublished,webSiteUrl,defaultCurrencyIso,bookingPageSettings`);
  fs.writeFileSync(path.join(CAP, 'config-final.json'), finalB.text);
  const fb = finalB.json || {};
  const result = {
    businessId: BUSINESS_ID, businessSmtp: BUSINESS_ID, displayName: fb.displayName,
    publicUrl: fb.publicUrl || null, isPublished: fb.isPublished,
    accessControl: fb.bookingPageSettings && fb.bookingPageSettings.accessControl,
    defaultCurrencyIso: fb.defaultCurrencyIso, webSiteUrl: fb.webSiteUrl,
    staffId, services: builtServices, questionIds, errors,
  };
  fs.writeFileSync(path.join(OUT, 'bookings-result.json'), JSON.stringify(result, null, 2));
  log(`RESULT: publicUrl=${result.publicUrl} access=${result.accessControl} published=${result.isPublished} currency=${result.defaultCurrencyIso}`);
  log(`services: ${builtServices.map(s => s.displayName + ':' + s.status).join(', ')}`);
  if (errors.length) log(`ERRORS(${errors.length}): ${errors.join(' | ')}`); else log('no errors');
  await ctx.close();
})();
