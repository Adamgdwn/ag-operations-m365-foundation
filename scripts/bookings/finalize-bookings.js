// Finalize: (1) neutralize the GuidedAILabs2 duplicate (rename-flag + unpublish via Graph
// direct-id, since business DELETE is tenant-blocked), (2) verify the GAIL public booking URL
// loads ANONYMOUSLY (fresh context, no profile) as a bookable page showing both services.
//   node scripts/bookings/finalize-bookings.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'bookings-builder', 'capture');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);
const CLIENT_ID = '14d82eec-204b-4c2f-b7e8-296a70dab67e';
const REDIRECT = 'http://localhost:8400/';
const AUTH = 'https://login.microsoftonline.com/organizations/oauth2/v2.0';
const SCOPE = 'https://graph.microsoft.com/Bookings.ReadWrite.All offline_access openid profile';
const GBASE = 'https://graph.microsoft.com/v1.0/solutions/bookingBusinesses';
const b64url = (b) => b.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
const PUBLIC_URL = 'https://outlook.office365.com/book/GuidedAILabs1@agoperations.ca/';
const DUP = 'GuidedAILabs2@agoperations.ca';

(async () => {
  // ===== Part 1: Graph cleanup of the duplicate (signed-in profile) =====
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: false, viewport: { width: 1100, height: 800 } });
  const page = ctx.pages()[0] || await ctx.newPage();
  const verifier = b64url(crypto.randomBytes(32)); const challenge = b64url(crypto.createHash('sha256').update(verifier).digest());
  let code = null, resolve; const codeP = new Promise(r => (resolve = r));
  await page.route(REDIRECT + '**', (route) => { try { const c = new URL(route.request().url()).searchParams.get('code'); if (c && !code) { code = c; resolve(c); } } catch {} route.fulfill({ status: 200, body: 'ok' }).catch(() => {}); });
  await page.goto(`${AUTH}/authorize?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT)}&response_mode=query&scope=${encodeURIComponent(SCOPE)}&state=x&code_challenge=${challenge}&code_challenge_method=S256&login_hint=${encodeURIComponent('adamgoodwin@guidedailabs.com')}`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await Promise.race([codeP, new Promise((_, rej) => setTimeout(() => rej(new Error('auth timeout')), 90000))]).catch(() => {});
  let TOKEN = null;
  if (code) { const t = await page.request.post(`${AUTH}/token`, { form: { client_id: CLIENT_ID, grant_type: 'authorization_code', code, redirect_uri: REDIRECT, code_verifier: verifier, scope: SCOPE } }); TOKEN = JSON.parse(await t.text()).access_token; }
  if (TOKEN) {
    const req = async (m, u, b) => { const o = { method: m, headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } }; if (b) { o.headers['content-type'] = 'application/json'; o.data = JSON.stringify(b); } const r = await page.request.fetch(u, o); return { status: r.status(), text: await r.text() }; };
    const D = `${GBASE}/${encodeURIComponent(DUP)}`;
    const rn = await req('PATCH', D, { displayName: 'Guided AI Labs (duplicate – safe to delete)' }); log(`flag duplicate -> ${rn.status}`);
    const un = await req('POST', `${D}/unpublish`); log(`unpublish duplicate -> ${un.status}`);
    const del = await req('DELETE', D); log(`retry delete duplicate -> ${del.status}`);
  } else log('WARN: no token for cleanup (skipping duplicate neutralize)');
  await ctx.close();

  // ===== Part 2: anonymous verification of the public URL (fresh context, no profile) =====
  const anon = await chromium.launch({ channel: 'msedge', headless: false });
  const aCtx = await anon.newContext({ viewport: { width: 1200, height: 950 } });
  const aPage = await aCtx.newPage();
  log('opening public URL anonymously: ' + PUBLIC_URL);
  await aPage.goto(PUBLIC_URL, { waitUntil: 'domcontentloaded', timeout: 90000 }).catch(e => log('nav: ' + e.message));
  await aPage.waitForTimeout(9000);
  await aPage.screenshot({ path: path.join(CAP, 'public-page-anon.png'), fullPage: true }).catch(() => {});
  const probe = await aPage.evaluate(() => ({
    url: location.href,
    title: document.title,
    hasGAIL: /guided ai labs/i.test(document.body.innerText || ''),
    hasIntro: /intro call/i.test(document.body.innerText || ''),
    hasWorking: /working session/i.test(document.body.innerText || ''),
    looksLikeSignIn: /sign in|enter your email|password|to continue to/i.test(document.body.innerText || ''),
    text: (document.body.innerText || '').slice(0, 900),
  })).catch(e => ({ err: e.message }));
  fs.writeFileSync(path.join(CAP, 'public-page-anon.json'), JSON.stringify(probe, null, 2));
  log('anon url: ' + probe.url);
  log('anon: hasGAIL=' + probe.hasGAIL + ' intro=' + probe.hasIntro + ' working=' + probe.hasWorking + ' signInWall=' + probe.looksLikeSignIn);
  log('anon text head: ' + (probe.text || '').replace(/\n+/g, ' / ').slice(0, 400));
  await aPage.waitForTimeout(1500);
  await anon.close();
})();
