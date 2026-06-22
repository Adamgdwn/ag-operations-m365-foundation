// Phase 4 end-to-end verification for the Bookings -> CRM create-only flow.
// Creates a REAL appointment on the live Guided AI Labs booking page (customer name =
// GAIL-INTERNAL-WALKTHROUGH so it is scope-deletable), which fires the same
// "When an appointment is Created" trigger a public-page visitor would, then polls
// "CRM - New Signals" for the resulting create-only record and validates the field mapping.
//
// Runs against the WARM, signed-in Edge over CDP (profile is locked by warm-edge; CDP is the
// only way in). Silent Graph token via login_hint PKCE (direct-id Bookings API). Read-only to the
// CRM here — teardown (cancel appointment + scope-delete record) is a SEPARATE explicit step.
//   node scripts/bookings/verify-booking-e2e.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const OUT = path.join(REPO, 'inventory', 'forms-build');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
fs.mkdirSync(OUT, { recursive: true }); fs.mkdirSync(CAP, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const CDP_PORT = process.env.CDP_PORT || '9222';
const CLIENT_ID = '14d82eec-204b-4c2f-b7e8-296a70dab67e';
const REDIRECT = 'http://localhost:8400/';
const AUTH = 'https://login.microsoftonline.com/organizations/oauth2/v2.0';
const SCOPE = 'https://graph.microsoft.com/Bookings.ReadWrite.All offline_access openid profile';
const GBASE = 'https://graph.microsoft.com/v1.0/solutions/bookingBusinesses';
const b64url = (buf) => buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const BUSINESS_ID = 'GuidedAILabs1@agoperations.ca';
const OWNER_EMAIL = 'adamgoodwin@guidedailabs.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const MARK = 'GAIL-INTERNAL-WALKTHROUGH';
const SERVICE_ID = '1a1b5504-9b2a-45d2-bfdc-d27f5fc95ee1'; // Intro call (30 min)
const SERVICE_NAME = 'Intro call (30 min)';
const STAFF_ID = '48d5de9a-4d90-4acc-abcf-eb2854241fd3';
const Q_ORG = '3329ead7-f492-4f85-bb47-0e81d4e93c90';
const Q_COVER = 'd5594675-0f3c-4ae8-bfea-57c88c18f3c5';

// A clearly-valid future weekday slot (Wed 2026-06-24, 16:30-17:00 UTC = 10:30 MDT).
const START = '2026-06-24T16:30:00';
const END = '2026-06-24T17:00:00';

(async () => {
  const browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
  const ctx = browser.contexts()[0] || await browser.newContext();
  const page = await ctx.newPage();
  log(`connected to warm Edge over CDP :${CDP_PORT}`);

  // ---- silent Graph token (auth-code + PKCE, login_hint) ----
  const verifier = b64url(crypto.randomBytes(32));
  const challenge = b64url(crypto.createHash('sha256').update(verifier).digest());
  let authCode = null, resolveCode; const codeP = new Promise(r => (resolveCode = r));
  await page.route(REDIRECT + '**', (route) => { try { const c = new URL(route.request().url()).searchParams.get('code'); if (c && !authCode) { authCode = c; resolveCode(c); } } catch {} route.fulfill({ status: 200, contentType: 'text/html', body: 'ok' }).catch(() => {}); });
  const authUrl = `${AUTH}/authorize?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT)}&response_mode=query&scope=${encodeURIComponent(SCOPE)}&state=x&code_challenge=${challenge}&code_challenge_method=S256&login_hint=${encodeURIComponent(OWNER_EMAIL)}`;
  await page.goto(authUrl, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await Promise.race([codeP, new Promise((_, rej) => setTimeout(() => rej(new Error('auth timeout')), 120000))]);
  const tokRes = await page.request.post(`${AUTH}/token`, { form: { client_id: CLIENT_ID, grant_type: 'authorization_code', code: authCode, redirect_uri: REDIRECT, code_verifier: verifier, scope: SCOPE } });
  const TOKEN = JSON.parse(await tokRes.text()).access_token;
  if (!TOKEN) { log('FATAL: no Graph token'); await browser.close(); process.exit(1); }
  log('Graph token acquired');
  const greq = async (method, url, body) => {
    const opts = { method, headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } };
    if (body) { opts.headers['content-type'] = 'application/json'; opts.data = JSON.stringify(body); }
    const r = await page.request.fetch(url, opts); const text = await r.text();
    return { status: r.status(), text, json: (() => { try { return JSON.parse(text); } catch { return null; } })() };
  };
  const B = `${GBASE}/${encodeURIComponent(BUSINESS_ID)}`;

  // ---- create the test appointment ----
  const apptBody = {
    '@odata.type': '#microsoft.graph.bookingAppointment',
    customerTimeZone: 'America/Edmonton',
    serviceId: SERVICE_ID,
    serviceName: SERVICE_NAME,
    isLocationOnline: true,
    optOutOfCustomerEmail: false,
    startDateTime: { '@odata.type': '#microsoft.graph.dateTimeTimeZone', dateTime: START, timeZone: 'UTC' },
    endDateTime: { '@odata.type': '#microsoft.graph.dateTimeTimeZone', dateTime: END, timeZone: 'UTC' },
    staffMemberIds: [STAFF_ID],
    customers: [{
      '@odata.type': '#microsoft.graph.bookingCustomerInformation',
      name: MARK,
      emailAddress: OWNER_EMAIL,
      notes: 'Internal end-to-end verification booking. Safe to cancel/delete.',
      customQuestionAnswers: [
        { '@odata.type': '#microsoft.graph.bookingQuestionAnswer', questionId: Q_ORG, question: 'Organization (optional)', answer: 'GAIL Internal Test', answerInputType: 'text' },
        { '@odata.type': '#microsoft.graph.bookingQuestionAnswer', questionId: Q_COVER, question: 'What would you like to cover?', answer: 'E2E verification of booking->CRM flow', answerInputType: 'text' },
      ],
    }],
  };
  const ac = await greq('POST', `${B}/appointments`, apptBody);
  log(`create appointment -> ${ac.status}`);
  if (ac.status >= 300) { log('  body: ' + ac.text.slice(0, 800)); await browser.close(); process.exit(2); }
  const apptId = ac.json && ac.json.id;
  const joinUrl = ac.json && (ac.json.joinWebUrl || (ac.json.onlineMeeting && ac.json.onlineMeeting.joinUrl));
  log(`appointment id: ${apptId}`);
  fs.writeFileSync(path.join(CAP, 'verify-appointment.json'), ac.text);

  // ---- poll CRM - New Signals for the create-only record ----
  const listUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?$select=Id,Title,PersonName,PersonEmail,NeedSummary,SourceText,NextAction,FollowUpDueDate,SignalType,IntakeSource,SignalStatus,Priority,ItemOwner/Title,Created&$expand=ItemOwner&$filter=PersonName eq '${MARK}'&$orderby=Id desc&$top=10`;
  let rec = null;
  for (let i = 0; i < 40; i++) { // up to ~6 min
    const r = await page.request.get(listUrl, { headers: { accept: 'application/json;odata=nometadata' } });
    if (r.status() === 200) {
      const j = JSON.parse(await r.text());
      const items = j.value || [];
      if (items.length) { rec = items[0]; break; }
    } else if (i === 0) {
      log(`CRM list GET status ${r.status()} (will retry)`);
    }
    if (i % 4 === 0) log(`waiting for CRM record... (${i * 9}s)`);
    await page.waitForTimeout(9000);
  }

  const checks = [];
  const add = (name, ok, got) => { checks.push({ name, ok, got }); log(`${ok ? 'PASS' : 'FAIL'}  ${name}${got !== undefined ? `  [${got}]` : ''}`); };
  if (!rec) {
    log('FAIL: no CRM record appeared within timeout (trigger may not have fired for a Graph-created appt).');
    fs.writeFileSync(path.join(OUT, 'booking-e2e-result.json'), JSON.stringify({ pass: false, reason: 'no-crm-record', appointmentId: apptId }, null, 2));
    await browser.close(); process.exit(3);
  }
  log(`CRM record found: Id=${rec.Id} Title="${rec.Title}"`);
  fs.writeFileSync(path.join(CAP, 'verify-crm-record.json'), JSON.stringify(rec, null, 2));
  add('PersonName == GAIL-INTERNAL-WALKTHROUGH', rec.PersonName === MARK, rec.PersonName);
  add('PersonEmail captured', (rec.PersonEmail || '').toLowerCase() === OWNER_EMAIL.toLowerCase(), rec.PersonEmail);
  add('IntakeSource == Guided AI Labs', rec.IntakeSource === 'Guided AI Labs', rec.IntakeSource);
  add('SignalType == Website', rec.SignalType === 'Website', rec.SignalType);
  add('SignalStatus == Follow-up scheduled', rec.SignalStatus === 'Follow-up scheduled', rec.SignalStatus);
  add('Priority == Normal', rec.Priority === 'Normal', rec.Priority);
  add('NextAction == Prepare for booked call', rec.NextAction === 'Prepare for booked call', rec.NextAction);
  const fud = (rec.FollowUpDueDate || '').slice(0, 16);
  add('FollowUpDueDate == StartTime', fud.startsWith('2026-06-24T16:30'), rec.FollowUpDueDate);
  add('SourceText has service name', /Intro call/.test(rec.SourceText || ''), (rec.SourceText || '').length + ' chars');
  add('SourceText has Teams link', /https?:\/\/.*teams|JoinWebURL|Teams link: http/i.test(rec.SourceText || ''), /Teams link: http/i.test(rec.SourceText || '') ? 'present' : 'absent');
  add('SourceText has provenance', /Auto-captured via Microsoft Bookings/.test(rec.SourceText || ''), undefined);
  add('ItemOwner set', !!(rec.ItemOwner && rec.ItemOwner.Title), rec.ItemOwner && rec.ItemOwner.Title);

  const pass = checks.every(c => c.ok);
  const result = { pass, appointmentId: apptId, joinUrl: joinUrl || null, crmItemId: rec.Id, crmTitle: rec.Title, start: START, checks, sourceTextPreview: (rec.SourceText || '').slice(0, 600) };
  fs.writeFileSync(path.join(OUT, 'booking-e2e-result.json'), JSON.stringify(result, null, 2));
  log(`\n==== ${pass ? 'ALL CHECKS PASS' : 'SOME CHECKS FAILED'} ==== (CRM item ${rec.Id}, appointment ${apptId})`);
  log('wrote inventory/forms-build/booking-e2e-result.json');
  await browser.close();
})();
