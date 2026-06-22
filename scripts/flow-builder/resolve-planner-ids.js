// Resolve (and, if missing, CREATE) the Planner plan for the Operations follow-up engine,
// then write its groupId + planId into config/followup.registry.json — so Adam's consent
// session needs NO manual Planner-UI step and NO GUID copying. Run this AFTER the planner +
// office365users connections are consented.
//
//   groupId : resolved from SharePoint REST (the GuidedAILabs site's owning M365 group) —
//             uses the persisted M365 session, no new consent.
//   planId  : found via Microsoft Graph (GET /groups/{groupId}/planner/plans), matched by
//             plan title. If no plan with that title exists and --write is passed, the plan
//             is CREATED via Graph (POST /planner/plans, owner = the group). Idempotent:
//             an existing plan is reused, never duplicated. Uses a silent first-party
//             delegated token (PKCE through the signed-in Edge profile) — same pattern as
//             the bookings scripts. Scope: Tasks.ReadWrite + Group.ReadWrite.All.
//
// Usage:
//   node scripts/flow-builder/resolve-planner-ids.js ["Plan Title"] [--headless] [--write]
//   default title "CRM Follow-ups". Without --write it only REPORTS (and will say whether
//   it would create the plan); with --write it creates-if-missing and persists the ids.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const REG_PATH = path.join(REPO, 'config', 'followup.registry.json');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const OWNER_EMAIL = 'adamgoodwin@guidedailabs.com';
const CLIENT_ID = '14d82eec-204b-4c2f-b7e8-296a70dab67e';
const REDIRECT = 'http://localhost:8400/';
const AUTH = 'https://login.microsoftonline.com/organizations/oauth2/v2.0';
const SCOPE = 'https://graph.microsoft.com/Tasks.ReadWrite https://graph.microsoft.com/Group.ReadWrite.All offline_access openid profile';
const b64url = (buf) => buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const args = process.argv.slice(2);
const headless = args.includes('--headless');
const doWrite = args.includes('--write');
const PLAN_TITLE = (args.find(a => !a.startsWith('--')) || 'CRM Follow-ups');

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless, viewport: { width: 1400, height: 950 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  // ---- groupId from SharePoint (no new consent) ----
  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(4000);
  const siteRes = await page.request.get(`${SITE}/_api/site?$select=GroupId`, { headers: { accept: 'application/json;odata=nometadata' } });
  const groupId = (JSON.parse(await siteRes.text()) || {}).GroupId;
  if (!groupId || /^0{8}-/.test(groupId)) { log(`FATAL: could not resolve the site's M365 group id (got ${groupId}). Is the GuidedAILabs site group-connected?`); await ctx.close(); process.exit(1); }
  log(`groupId (GuidedAILabs M365 group): ${groupId}`);

  // ---- silent Graph token (PKCE through the profile) ----
  const verifier = b64url(crypto.randomBytes(32));
  const challenge = b64url(crypto.createHash('sha256').update(verifier).digest());
  let authCode = null, resolveCode; const codeP = new Promise(r => (resolveCode = r));
  await page.route(REDIRECT + '**', (route) => { try { const c = new URL(route.request().url()).searchParams.get('code'); if (c && !authCode) { authCode = c; resolveCode(c); } } catch {} route.fulfill({ status: 200, contentType: 'text/html', body: 'ok' }).catch(() => {}); });
  const authUrl = `${AUTH}/authorize?client_id=${CLIENT_ID}&response_type=code&redirect_uri=${encodeURIComponent(REDIRECT)}&response_mode=query&scope=${encodeURIComponent(SCOPE)}&state=x&code_challenge=${challenge}&code_challenge_method=S256&login_hint=${encodeURIComponent(OWNER_EMAIL)}`;
  await page.goto(authUrl, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await Promise.race([codeP, new Promise((_, rej) => setTimeout(() => rej(new Error('auth timeout')), 120000))]).catch(e => log('  ' + e.message));
  if (!authCode) { log('FATAL: no auth code (sign-in / consent may be required in the visible window).'); await ctx.close(); process.exit(2); }
  const tokRes = await page.request.post(`${AUTH}/token`, { form: { client_id: CLIENT_ID, grant_type: 'authorization_code', code: authCode, redirect_uri: REDIRECT, code_verifier: verifier, scope: SCOPE } });
  const TOKEN = JSON.parse(await tokRes.text()).access_token;
  if (!TOKEN) { log('FATAL: no Graph token'); await ctx.close(); process.exit(3); }
  log('Graph token acquired');

  // ---- list the group's plans, match by title ----
  const plansRes = await page.request.get(`https://graph.microsoft.com/v1.0/groups/${groupId}/planner/plans`, { headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json' } });
  if (plansRes.status() >= 300) { log(`FATAL: list plans -> ${plansRes.status()} ${(await plansRes.text()).slice(0, 300)}`); await ctx.close(); process.exit(4); }
  const plans = (JSON.parse(await plansRes.text()).value) || [];
  log(`group has ${plans.length} plan(s): ${plans.map(p => `"${p.title}"`).join(', ') || '(none)'}`);
  let match = plans.find(p => (p.title || '').trim().toLowerCase() === PLAN_TITLE.trim().toLowerCase());

  if (!match) {
    if (!doWrite) { log(`No plan titled "${PLAN_TITLE}" in this group yet. Re-run with --write to CREATE it and persist the ids.`); await ctx.close(); process.exit(0); }
    log(`No plan titled "${PLAN_TITLE}" — creating it via Graph (owner = group ${groupId})…`);
    // v1.0 create plannerPlan: owner = group id. (owner is the established form; container is
    // the newer alias — fall back to it if owner is rejected as deprecated.)
    let cr = await page.request.post('https://graph.microsoft.com/v1.0/planner/plans', { headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify({ owner: groupId, title: PLAN_TITLE }) });
    if (cr.status() >= 300) {
      const t = await cr.text();
      log(`  owner-form create -> ${cr.status()} ${t.slice(0, 200)}; retrying with container form…`);
      cr = await page.request.post('https://graph.microsoft.com/v1.0/planner/plans', { headers: { authorization: 'Bearer ' + TOKEN, accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify({ container: { url: `https://graph.microsoft.com/v1.0/groups/${groupId}` }, title: PLAN_TITLE }) });
    }
    if (cr.status() >= 300) { log(`FATAL: could not create plan -> ${cr.status()} ${(await cr.text()).slice(0, 400)}`); await ctx.close(); process.exit(5); }
    match = JSON.parse(await cr.text());
    log(`  created plan "${match.title}" -> ${match.id}`);
  }
  log(`planId for "${match.title}": ${match.id}`);

  if (doWrite) {
    const reg = JSON.parse(fs.readFileSync(REG_PATH, 'utf8'));
    const row = (reg.lists || []).find(l => l.key === 'crm-new-signals');
    if (!row) { log('FATAL: crm-new-signals row missing from registry'); await ctx.close(); process.exit(6); }
    row.planner = row.planner || {};
    row.planner.groupId = groupId;
    row.planner.planId = match.id;
    fs.writeFileSync(REG_PATH, JSON.stringify(reg, null, 2) + '\n');
    log(`WROTE groupId + planId into ${path.relative(REPO, REG_PATH)}. Next: rebuild the engine (node create-followup-engine-flow.js) then run planner-smoke-test.js.`);
  } else {
    log('DRY: pass --write to persist groupId + planId into the registry.');
  }
  await ctx.close();
})();
