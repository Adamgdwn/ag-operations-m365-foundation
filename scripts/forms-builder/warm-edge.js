// Keep ONE signed-in Edge alive on the shared automation profile so future
// token-capture / SPA-driving scripts never re-trigger a Microsoft sign-in.
//
// Launches a headed msedge against .local/forms-builder/profile with a CDP
// debugging port (default 9222), DETACHED so it survives this process and the
// Claude session. Idempotent: if something already answers on the CDP port it
// just verifies and exits. The warm instance LOCKS the profile, so every script
// that touches it must attach over CDP (connectOverCDP) rather than
// launchPersistentContext — see create-connections.js for the canonical
// "CDP-first, cold-launch fallback" pattern.
//
// Usage:
//   node warm-edge.js            # launch if needed, then verify signed-in state
//   node warm-edge.js --status   # verify only (do not launch)
//   CDP_PORT=9222 node warm-edge.js
const fs = require('fs');
const path = require('path');
const { spawn, execSync } = require('child_process');
const http = require('http');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const PORT = process.env.CDP_PORT || '9222';
const STATUS_ONLY = process.argv.includes('--status');
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const EDGE_CANDIDATES = [
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
];

// Does the CDP endpoint already answer? (an Edge is warm on this port)
function cdpUp() {
  return new Promise((resolve) => {
    const req = http.get({ host: '127.0.0.1', port: PORT, path: '/json/version', timeout: 2500 }, (res) => {
      let b = ''; res.on('data', (d) => (b += d)); res.on('end', () => resolve(res.statusCode === 200));
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
  });
}

async function launch() {
  const exe = EDGE_CANDIDATES.find((p) => fs.existsSync(p));
  if (!exe) { log('ERROR: msedge.exe not found'); process.exit(1); }
  fs.mkdirSync(PROFILE_DIR, { recursive: true });
  const args = [
    `--remote-debugging-port=${PORT}`,
    `--user-data-dir=${PROFILE_DIR}`,
    '--no-first-run',
    '--no-default-browser-check',
    '--restore-last-session',
    'https://forms.office.com/',
  ];
  log(`launching warm Edge (detached) on :${PORT} ...`);
  const child = spawn(exe, args, { detached: true, stdio: 'ignore' });
  child.unref();
  // Wait for the CDP port to come up.
  for (let i = 0; i < 30; i++) {
    if (await cdpUp()) { log('  CDP endpoint is up'); return; }
    await new Promise((r) => setTimeout(r, 1000));
  }
  log('WARN: CDP endpoint did not come up within 30s');
}

(async () => {
  let up = await cdpUp();
  if (up) log(`warm Edge already running on :${PORT} (idempotent — not relaunching)`);
  else if (STATUS_ONLY) { log(`no warm Edge on :${PORT} (status-only; not launching)`); process.exit(3); }
  else { await launch(); up = await cdpUp(); }
  if (!up) { log('ERROR: no CDP endpoint after launch'); process.exit(1); }

  // Verify the session is actually signed in by hitting the Forms SPA over CDP
  // and reading whether a sign-in wall is shown.
  const browser = await chromium.connectOverCDP(`http://127.0.0.1:${PORT}`, { timeout: 8000 });
  const ctx = browser.contexts()[0] || await browser.newContext();
  const page = ctx.pages().find((p) => /forms\.office\.com/i.test(p.url())) || await ctx.newPage();
  await page.goto('https://forms.office.com/', { waitUntil: 'domcontentloaded', timeout: 45000 }).catch(() => {});
  await page.waitForTimeout(4000);
  const body = await page.evaluate(() => (document.body ? document.body.innerText : '')).catch(() => '');
  const wall = /Sign in|Pick an account|Enter your email|Sign in to continue/i.test(body) && !/Forms|My forms|Recent/i.test(body);
  const signedIn = !wall && body.length > 0;
  log(`signed-in: ${signedIn} (contexts=${browser.contexts().length})`);
  await browser.close(); // detaches CDP only; does NOT close the warm Edge
  if (!signedIn) {
    log('ACTION: complete the Microsoft sign-in ONCE in the visible Edge window; the session then persists for all CDP scripts.');
    process.exit(2);
  }
  log('warm signed-in Edge is live; CDP scripts can attach on :' + PORT);
  process.exit(0);
})();
