// Teardown for the Bookings -> CRM end-to-end test (Phase 4): cancel the test appointment on the
// Guided AI Labs booking page AND scope-delete the GAIL-INTERNAL-WALKTHROUGH record(s) from
// "CRM - New Signals" -> 0 residue. Runs over the WARM signed-in Edge via CDP (profile is locked).
// Scope-safe: the CRM delete filters PersonName == GAIL-INTERNAL-WALKTHROUGH exactly, so it can
// never touch a real website/booking signal.
//   node scripts/bookings/teardown-booking-e2e.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const OUT = path.join(REPO, 'inventory', 'forms-build');
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

(async () => {
  let apptId = null;
  try { apptId = JSON.parse(fs.readFileSync(path.join(OUT, 'booking-e2e-result.json'), 'utf8')).appointmentId; } catch {}

  const browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
  const ctx = browser.contexts()[0] || await browser.newContext();
  const page = await ctx.newPage();
  log(`connected to warm Edge over CDP :${CDP_PORT}`);

  // ---- silent Graph token ----
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

  // ---- 1) cancel the appointment (removes Outlook event + Teams meeting, notifies) ----
  if (apptId) {
    const B = `${GBASE}/${encodeURIComponent(BUSINESS_ID)}/appointments/${encodeURIComponent(apptId)}`;
    const c = await page.request.fetch(`${B}/cancel`, { method: 'POST', headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify({ cancellationMessage: 'Internal end-to-end verification booking — cancelled (safe to ignore).' }) });
    log(`cancel appointment -> ${c.status()}`);
    if (c.status() >= 300) {
      const t = await c.text();
      log('  cancel body: ' + t.slice(0, 300));
      // fall back to hard DELETE if cancel is not permitted
      const d = await page.request.fetch(B, { method: 'DELETE', headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } });
      log(`  fallback DELETE appointment -> ${d.status()}`);
    }
  } else { log('WARN: no appointment id on file; skipping appointment cancel.'); }

  // ---- 2) scope-delete the CRM test record(s) ----
  const listUrl = `${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items?$select=Id,Title,PersonName,IntakeSource,Created&$filter=PersonName eq '${MARK}'&$orderby=Id asc&$top=50`;
  const lr = await page.request.get(listUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const items = (JSON.parse(await lr.text()).value) || [];
  log(`found ${items.length} CRM test record(s) named "${MARK}":`);
  for (const it of items) log(`  Id ${it.Id}  Source=${it.IntakeSource}  Created=${it.Created}`);
  let ok = 0;
  if (items.length) {
    const dr = await page.request.post(`${SITE}/_api/contextinfo`, { headers: { accept: 'application/json;odata=nometadata' } });
    const digest = JSON.parse(await dr.text()).FormDigestValue;
    for (const it of items) {
      const resp = await page.request.fetch(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')/items(${it.Id})`, { method: 'POST', headers: { accept: 'application/json;odata=nometadata', 'X-RequestDigest': digest, 'IF-MATCH': '*', 'X-HTTP-Method': 'DELETE' } });
      if (resp.status() === 200 || resp.status() === 204) { ok++; log(`  deleted Id ${it.Id}`); }
      else log(`  FAILED Id ${it.Id} -> ${resp.status()} ${(await resp.text()).slice(0, 200)}`);
    }
  }
  // verify 0 remaining
  const vr = await page.request.get(listUrl, { headers: { accept: 'application/json;odata=nometadata' } });
  const remaining = (JSON.parse(await vr.text()).value || []).length;
  log(`\nDeleted ${ok}/${items.length} CRM record(s). Remaining "${MARK}": ${remaining}`);
  log(remaining === 0 ? '0 RESIDUE — teardown clean.' : 'WARNING: residue remains.');
  await browser.close();
  process.exit(remaining === 0 ? 0 : 5);
})();
