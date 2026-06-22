// Build (and publish) the "Guided AI Labs" Microsoft Bookings calendar AGENTICALLY via
// the Microsoft Graph Bookings API. Auth uses the ALREADY-SIGNED-IN persistent Edge
// profile (.local/forms-builder/profile) to run an OAuth auth-code + PKCE flow against
// Microsoft's FIRST-PARTY public client "Microsoft Graph Command Line Tools" -- NO app
// registration, no secret, no device code, no re-login. If the Bookings.ReadWrite.All
// scope isn't yet consented, the browser shows a one-time "Allow" (an in-session consent
// click, not a sign-in); afterwards it is silent. Then we POST/PATCH /solutions/
// bookingBusinesses ourselves with the resulting delegated token.
//
//   node build-bookings-business.js --probe   # read-only: get token + list businesses
//   node build-bookings-business.js           # build + publish (idempotent by displayName)
// Output: inventory/forms-build/bookings-result.json (+ raw bodies in .local capture)
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
fs.mkdirSync(CAP, { recursive: true });
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const probe = process.argv.includes('--probe');
const CLIENT_ID = '14d82eec-204b-4c2f-b7e8-296a70dab67e'; // Microsoft Graph Command Line Tools (first-party public client)
const REDIRECT = 'http://localhost:8400/';
const AUTH = 'https://login.microsoftonline.com/organizations/oauth2/v2.0';
const SCOPE = 'https://graph.microsoft.com/Bookings.ReadWrite.All offline_access openid profile';
const GBASE = 'https://graph.microsoft.com/v1.0/solutions/bookingBusinesses';
const b64url = (buf) => buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

// ---- Desired calendar (sensible defaults; trivially adjustable) --------------
const BUSINESS = { displayName: 'Guided AI Labs', businessType: 'Other', email: 'adamgoodwin@guidedailabs.com', webSiteUrl: 'https://guidedailabs.com', languageTag: 'en-US', defaultCurrencyIso: 'CAD' };
const STAFF = { '@odata.type': '#microsoft.graph.bookingStaffMember', displayName: 'Adam Goodwin', emailAddress: 'adamgoodwin@guidedailabs.com', role: 'administrator', useBusinessHours: true, availabilityIsAffectedByPersonalCalendar: true };
const WORKDAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
const BUSINESS_HOURS = WORKDAYS.map(day => ({ day, timeSlots: [{ startTime: '09:00:00.0000000', endTime: '17:00:00.0000000' }] }));
const SCHEDULING = { timeSlotInterval: 'PT30M', minimumLeadTime: 'PT24H', maximumAdvance: 'P30D', sendConfirmationsToOwner: true, allowStaffSelection: true };
const SERVICES = [
  { displayName: 'Intro call (30 min)', defaultDuration: 'PT30M', postBuffer: 'PT10M', notes: 'A short introductory call.' },
  { displayName: 'Working session (60 min)', defaultDuration: 'PT1H', postBuffer: 'PT15M', notes: 'A focused working session.' },
];
const QUESTIONS = [
  { displayName: 'Organization (optional)', answerInputType: 'text' },
  { displayName: 'What would you like to cover?', answerInputType: 'text' },
];

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1280, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  // ---- OAuth auth-code + PKCE through the signed-in profile -------------------
  const verifier = b64url(crypto.randomBytes(32));
  const challenge = b64url(crypto.createHash('sha256').update(verifier).digest());
  const state = b64url(crypto.randomBytes(8));
  let authCode = null, resolveCode;
  const codeP = new Promise(r => (resolveCode = r));
  await page.route(REDIRECT + '**', (route) => {
    try { const u = new URL(route.request().url()); const c = u.searchParams.get('code'); if (c && !authCode) { authCode = c; resolveCode(c); } } catch {}
    route.fulfill({ status: 200, contentType: 'text/html', body: '<h2>Authorized — you can close this tab.</h2>' }).catch(() => {});
  });
  const authUrl = `${AUTH}/authorize?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT)}&response_mode=query&scope=${encodeURIComponent(SCOPE)}&state=${state}&code_challenge=${challenge}&code_challenge_method=S256&login_hint=${encodeURIComponent('adamgoodwin@guidedailabs.com')}`;
  log('opening authorize endpoint in the signed-in profile (silent if already consented; one Allow click otherwise)...');
  await page.goto(authUrl, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  const timeout = new Promise((_, rej) => setTimeout(() => rej(new Error('timeout waiting for auth code')), 180000));
  try { await Promise.race([codeP, timeout]); }
  catch (e) { log('ERROR: ' + e.message + ' — if a consent/sign-in page is showing, complete it and re-run.'); await ctx.close(); process.exit(1); }
  log('auth code received; exchanging for a delegated Graph token...');

  const tok = await page.request.post(`${AUTH}/token`, { form: { client_id: CLIENT_ID, grant_type: 'authorization_code', code: authCode, redirect_uri: REDIRECT, code_verifier: verifier, scope: SCOPE } });
  const tokJson = JSON.parse(await tok.text());
  if (!tokJson.access_token) { log('ERROR: token exchange failed: ' + JSON.stringify(tokJson).slice(0, 400)); await ctx.close(); process.exit(1); }
  const TOKEN = tokJson.access_token;
  log(`token acquired (scopes: ${tokJson.scope || '?'})`);

  const req = async (method, url, body) => {
    const opts = { method, headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } };
    if (body) { opts.headers['content-type'] = 'application/json'; opts.data = JSON.stringify(body); }
    const r = await page.request.fetch(url, opts);
    const text = await r.text();
    return { status: r.status(), text, json: (() => { try { return JSON.parse(text); } catch { return null; } })() };
  };
  const dump = (n, res) => fs.writeFileSync(path.join(CAP, n), `status: ${res.status}\n\n${res.text}`);

  // ---- Identity + READ (gates write) -----------------------------------------
  const me = await req('GET', 'https://graph.microsoft.com/v1.0/me?$select=userPrincipalName,id,mail');
  dump('00-me.json', me);
  log(`/me -> ${me.status} ${me.json ? (me.json.userPrincipalName || '') : me.text.slice(0, 200)}`);
  const listed = await req('GET', `${GBASE}?$select=id,displayName`);
  dump('00-list-businesses.json', listed);
  log(`list businesses -> ${listed.status} (${listed.json && listed.json.value ? listed.json.value.length : '?'})`);
  const listOk = listed.status >= 200 && listed.status < 300;
  if (!listOk) log(`WARN: list returned ${listed.status} (${(listed.json && listed.json.error && listed.json.error.code) || '?'}); body: ${listed.text.slice(0, 300)}`);
  let existing = listOk ? (listed.json.value || []).find(b => (b.displayName || '').trim().toLowerCase() === BUSINESS.displayName.toLowerCase()) : null;

  if (probe) {
    // Direct GET by known SMTP id (list can 403 while direct GET works).
    for (const id of ['GuidedAILabs1@agoperations.ca']) {
      const enc = encodeURIComponent(id);
      const g = await req('GET', `${GBASE}/${enc}`); dump(`direct-get-${id}.json`, g);
      const svc = await req('GET', `${GBASE}/${enc}/services?$select=id,displayName`); dump(`direct-services-${id}.json`, svc);
      const stf = await req('GET', `${GBASE}/${enc}/staffMembers?$select=id,displayName,emailAddress`); dump(`direct-staff-${id}.json`, stf);
      log(`DIRECT ${id}: business=${g.status} services=${svc.status} staff=${stf.status}`);
      if (g.status < 300) log(`  business body: ${g.text.slice(0, 400)}`);
    }
    // Diagnose the 403: is the Bookings service plan licensed? does beta behave differently?
    const lic = await req('GET', 'https://graph.microsoft.com/v1.0/me/licenseDetails');
    dump('00-license.json', lic);
    const BOOKINGS_PLAN = '199a5c09-e0ca-4e37-8f7c-b05d533e1ea2'; // MICROSOFTBOOKINGS service plan id
    const plans = [];
    ((lic.json && lic.json.value) || []).forEach(l => (l.servicePlans || []).forEach(sp => { if (/booking/i.test(sp.servicePlanName || '') || sp.servicePlanId === BOOKINGS_PLAN) plans.push({ sku: l.skuPartNumber, name: sp.servicePlanName, status: sp.provisioningStatus }); }));
    const beta = await req('GET', 'https://graph.microsoft.com/beta/solutions/bookingBusinesses?$select=id,displayName');
    dump('00-list-beta.json', beta);
    log(`license -> ${lic.status}; bookings plans: ${JSON.stringify(plans)}`);
    log(`beta list -> ${beta.status}`);
    fs.writeFileSync(path.join(OUT, 'bookings-result.json'), JSON.stringify({ probe: true, me: me.json || me.text, listStatusV1: listed.status, listStatusBeta: beta.status, bookingsServicePlans: plans, allSkus: ((lic.json && lic.json.value) || []).map(l => l.skuPartNumber), existing: existing || null }, null, 2));
    log(`PROBE done. v1=${listed.status} beta=${beta.status} bookingsPlans=${plans.map(p => p.name + ':' + p.status).join(',') || '(none found)'}`);
    await ctx.close(); return;
  }

  const errors = [];
  let businessId = existing ? existing.id : null;

  if (!businessId) {
    const cr = await req('POST', GBASE, Object.assign({}, BUSINESS, { businessHours: BUSINESS_HOURS, schedulingPolicy: SCHEDULING }));
    dump('01-create-business.json', cr);
    log(`create business -> ${cr.status}`);
    if (cr.status < 200 || cr.status >= 300) { log('FATAL create body: ' + cr.text.slice(0, 1200)); await ctx.close(); process.exit(3); }
    businessId = cr.json && cr.json.id;
    if (!businessId) { const rl = await req('GET', `${GBASE}?$select=id,displayName`); businessId = ((rl.json && rl.json.value) || []).find(b => (b.displayName || '').trim().toLowerCase() === BUSINESS.displayName.toLowerCase())?.id; }
    log(`business id: ${businessId}`);
  } else {
    log(`reusing business: ${businessId}`);
    const up = await req('PATCH', `${GBASE}/${encodeURIComponent(businessId)}`, { businessHours: BUSINESS_HOURS, schedulingPolicy: SCHEDULING, webSiteUrl: BUSINESS.webSiteUrl });
    dump('01-patch-business.json', up); log(`patch business -> ${up.status}`);
    if (up.status >= 300) errors.push('patch business: ' + up.status + ' ' + up.text.slice(0, 200));
  }
  if (!businessId) { log('FATAL: no business id'); await ctx.close(); process.exit(3); }
  const B = `${GBASE}/${encodeURIComponent(businessId)}`;

  // ---- Staff (idempotent by email) ------------------------------------------
  let staffId = null;
  const sl = await req('GET', `${B}/staffMembers`);
  staffId = ((sl.json && sl.json.value) || []).find(s => (s.emailAddress || '').toLowerCase() === STAFF.emailAddress.toLowerCase())?.id;
  if (!staffId) {
    const sc = await req('POST', `${B}/staffMembers`, STAFF);
    dump('02-create-staff.json', sc); log(`create staff -> ${sc.status}`);
    if (sc.status >= 200 && sc.status < 300) staffId = sc.json && sc.json.id; else errors.push('staff: ' + sc.status + ' ' + sc.text.slice(0, 300));
  } else log(`reusing staff: ${staffId}`);

  // ---- Custom questions (idempotent by displayName) -------------------------
  const ql = await req('GET', `${B}/customQuestions`);
  const qByName = {}; ((ql.json && ql.json.value) || []).forEach(q => { qByName[(q.displayName || '').toLowerCase()] = q.id; });
  const questionIds = [];
  for (const q of QUESTIONS) {
    let qid = qByName[q.displayName.toLowerCase()];
    if (!qid) { const qc = await req('POST', `${B}/customQuestions`, q); dump(`03-question-${questionIds.length}.json`, qc); log(`question "${q.displayName}" -> ${qc.status}`); if (qc.status >= 200 && qc.status < 300) qid = qc.json && qc.json.id; else errors.push('question: ' + qc.status + ' ' + qc.text.slice(0, 200)); }
    if (qid) questionIds.push(qid);
  }

  // ---- Services (idempotent by displayName) ---------------------------------
  const svl = await req('GET', `${B}/services?$select=id,displayName`);
  const svByName = {}; ((svl.json && svl.json.value) || []).forEach(s => { svByName[(s.displayName || '').toLowerCase()] = s.id; });
  const builtServices = [];
  for (const svc of SERVICES) {
    const body = {
      displayName: svc.displayName, defaultDuration: svc.defaultDuration, preBuffer: 'PT0M', postBuffer: svc.postBuffer,
      isLocationOnline: true, notes: svc.notes, maximumAttendeesCount: 1,
      staffMemberIds: staffId ? [staffId] : [], schedulingPolicy: SCHEDULING,
      defaultReminders: [{ offset: 'P1D', recipients: 'allAttendees', message: 'Reminder: your session is tomorrow.' }],
      customQuestions: questionIds.map(qid => ({ questionId: qid, isRequired: false })),
    };
    const sid0 = svByName[svc.displayName.toLowerCase()];
    let res, sid;
    if (sid0) { res = await req('PATCH', `${B}/services/${encodeURIComponent(sid0)}`, body); sid = sid0; log(`patch service "${svc.displayName}" -> ${res.status}`); }
    else { res = await req('POST', `${B}/services`, body); sid = res.json && res.json.id; log(`create service "${svc.displayName}" -> ${res.status}`); }
    dump(`04-service-${builtServices.length}.json`, res);
    if (res.status < 200 || res.status >= 300) errors.push('service ' + svc.displayName + ': ' + res.status + ' ' + res.text.slice(0, 300));
    builtServices.push({ displayName: svc.displayName, id: sid || null, status: res.status });
  }

  // ---- Publish ---------------------------------------------------------------
  const pub = await req('POST', `${B}/publish`);
  dump('05-publish.json', pub); log(`publish -> ${pub.status}`);
  if (pub.status < 200 || pub.status >= 300) errors.push('publish: ' + pub.status + ' ' + pub.text.slice(0, 300));

  // ---- Resolve public URL + SMTP --------------------------------------------
  const finalB = await req('GET', `${B}?$select=id,displayName,email,publicUrl,isPublished,webSiteUrl,defaultTimeZone`);
  dump('06-final-business.json', finalB);
  const fb = finalB.json || {};
  const result = { businessId, businessSmtp: fb.email || businessId, displayName: fb.displayName, publicUrl: fb.publicUrl || null, isPublished: fb.isPublished, defaultTimeZone: fb.defaultTimeZone, staffId, services: builtServices, questionIds, errors };
  fs.writeFileSync(path.join(OUT, 'bookings-result.json'), JSON.stringify(result, null, 2));
  log(`RESULT: business=${businessId} published=${fb.isPublished} publicUrl=${fb.publicUrl || '(see 06-final)'}`);
  if (errors.length) log(`NOTE: ${errors.length} sub-step error(s) — see bookings-result.json`);
  log('wrote inventory/forms-build/bookings-result.json');
  await ctx.close();
})();
