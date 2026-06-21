// Agentic Microsoft Forms builder (Playwright, installed Edge channel).
//
// Microsoft Forms has no creation API, so this drives a real signed-in browser.
// Adam signs in ONCE in the visible window; this script does the building and
// screenshots every step so the agent can read the real UI and adapt.
//
// Phases:
//   auth   - open forms.office.com, wait for sign-in, capture dashboard + the
//            new-form editor, then stop. (Use this first to SEE the real UI.)
//   build  - reuse the persisted session, create the form from the spec.
//   all    - auth-wait then build.
//
// Persisted profile (so re-runs need no re-login):
//   <repo>/.local/forms-builder/profile   (gitignored)
// Output (screenshots + status), NOT secret:
//   <repo>/inventory/forms-build/<run>/

const fs = require('fs');
const path = require('path');

let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const phase = (process.argv[2] || 'auth').toLowerCase();
const specArg = process.argv.find(a => a.startsWith('--spec='));
const runStamp = (process.argv.find(a => a.startsWith('--run=')) || '=run').split('=')[1] || 'run';
const OUT = path.join(REPO, 'inventory', 'forms-build', runStamp);

fs.mkdirSync(PROFILE_DIR, { recursive: true });
fs.mkdirSync(OUT, { recursive: true });

const log = (m) => { const line = `[${new Date().toISOString()}] ${m}`; console.log(line); fs.appendFileSync(path.join(OUT, 'run.log'), line + '\n'); };
let shotN = 0;
async function shot(page, name) {
  shotN += 1;
  const file = path.join(OUT, `${String(shotN).padStart(2, '0')}-${name}.png`);
  try { await page.screenshot({ path: file, fullPage: false }); log(`screenshot -> ${path.basename(file)}`); }
  catch (e) { log(`screenshot FAILED (${name}): ${e.message.split('\n')[0]}`); }
}

const DEFAULT_SPEC = {
  brand: 'Guided AI Labs',
  title: 'Guided AI Labs — Get started',
  intakeSource: 'Guided AI Labs',
  anonymous: true,
  questions: [
    { type: 'text', title: 'Full name', required: true, longAnswer: false },
    { type: 'text', title: 'Email', required: true, longAnswer: false, restrictEmail: true },
    { type: 'text', title: 'Organization', required: false, longAnswer: false },
    { type: 'text', title: 'What are you looking for?', required: true, longAnswer: true },
    { type: 'text', title: 'How did you hear about us?', required: false, longAnswer: true },
    { type: 'choice', title: 'I agree to be contacted about my enquiry.', required: true, options: ['I agree'] },
  ],
};

function loadSpec() {
  if (specArg) {
    const p = specArg.split('=')[1];
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  }
  return DEFAULT_SPEC;
}

async function waitForAuth(page) {
  log('navigating to forms.office.com ...');
  await page.goto('https://forms.office.com/', { waitUntil: 'domcontentloaded' }).catch(e => log('goto warn: ' + e.message.split('\n')[0]));
  log('Waiting for sign-in / Forms dashboard (up to 6 minutes). Complete any Microsoft sign-in in this window.');
  const deadline = Date.now() + 6 * 60 * 1000;
  let lastShot = 0;
  let stableOnForms = 0;
  while (Date.now() < deadline) {
    const url = page.url();
    const onForms = /forms\.(office|cloud\.microsoft)/i.test(url) && !/login|signin|microsoftonline|\/auth/i.test(url);
    // Authenticated markers on the (re-branded) landing / dashboard.
    let marker = false;
    if (onForms) {
      const probes = [
        'text=/welcome to microsoft forms/i',
        'text=/recommended|recent|my forms|all my forms/i',
        'text=/new form/i', 'text=/new quiz/i',
        '[aria-label*="New Form" i]', '[title*="New Form" i]',
      ];
      for (const sel of probes) {
        if (await page.locator(sel).first().isVisible({ timeout: 500 }).catch(() => false)) { marker = true; break; }
      }
      // Fallback: stable on the forms domain (not login) for ~8s counts as authed.
      stableOnForms += 2.5;
    } else {
      stableOnForms = 0;
    }
    if (onForms && (marker || stableOnForms >= 8)) {
      log(`Authenticated; on Forms (marker=${marker}, stable=${stableOnForms}s).`);
      return true;
    }
    if (Date.now() - lastShot > 20000) { await shot(page, 'waiting-auth'); lastShot = Date.now(); }
    await page.waitForTimeout(2500);
  }
  return false;
}

async function dumpControls(page, tag) {
  try {
    const btns = await page.getByRole('button').allInnerTexts();
    const links = await page.getByRole('link').allInnerTexts();
    const labels = await page.locator('[aria-label]').evaluateAll(els =>
      els.map(e => e.getAttribute('aria-label')).filter(Boolean).slice(0, 200));
    const out = [
      `# URL: ${page.url()}`,
      `## buttons (${btns.length})`, ...btns.filter(Boolean),
      `## links (${links.length})`, ...links.filter(Boolean),
      `## aria-labels (${labels.length})`, ...labels,
    ].join('\n');
    fs.writeFileSync(path.join(OUT, `controls-${tag}.txt`), out);
    log(`controls dumped -> controls-${tag}.txt (btn=${btns.length} link=${links.length} aria=${labels.length})`);
  } catch (e) { log(`control dump warn (${tag}): ` + e.message.split('\n')[0]); }
}

async function captureNewFormUI(page) {
  await page.waitForTimeout(2000);
  try { await page.screenshot({ path: path.join(OUT, 'dashboard-full.png'), fullPage: true }); log('screenshot -> dashboard-full.png (fullPage)'); }
  catch (e) { log('dashboard full shot warn: ' + e.message.split('\n')[0]); }
  await shot(page, 'dashboard');
  await dumpControls(page, 'dashboard');

  // Most reliable way to open a blank form editor: navigate the design page URL.
  log('Opening a blank form editor via DesignPageV2 ...');
  const designUrls = [
    'https://forms.office.com/Pages/DesignPageV2.aspx?origin=NeoPortalPage&subpage=design',
    'https://forms.office.com/Pages/DesignPageV2.aspx',
  ];
  for (const u of designUrls) {
    try {
      await page.goto(u, { waitUntil: 'domcontentloaded', timeout: 30000 });
      await page.waitForTimeout(5000);
      log(`navigated editor url -> ${page.url()}`);
      break;
    } catch (e) { log('editor nav warn: ' + e.message.split('\n')[0]); }
  }
  await page.waitForTimeout(2000);
  try { await page.screenshot({ path: path.join(OUT, 'editor-full.png'), fullPage: true }); log('screenshot -> editor-full.png (fullPage)'); }
  catch (e) { log('editor full shot warn: ' + e.message.split('\n')[0]); }
  await shot(page, 'editor');
  await dumpControls(page, 'editor');
  try { fs.writeFileSync(path.join(OUT, 'final-url.txt'), page.url()); } catch {}
}

(async () => {
  log(`phase=${phase} profile=${PROFILE_DIR} out=${OUT}`);
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, {
    channel: 'msedge',
    headless: false,
    viewport: { width: 1536, height: 864 },
    args: ['--window-size=1560,1000', '--window-position=0,0'],
  });
  const page = ctx.pages()[0] || await ctx.newPage();
  let status = { phase, ok: false, notes: '' };
  try {
    const authed = await waitForAuth(page);
    if (!authed) { status.notes = 'sign-in not detected within timeout'; log('AUTH TIMEOUT'); }
    else if (phase === 'auth') {
      await captureNewFormUI(page);
      status.ok = true; status.notes = 'auth + UI capture complete';
    } else {
      // build phase to be authored against captured UI; placeholder until then.
      await captureNewFormUI(page);
      status.ok = true; status.notes = 'build phase not yet authored; captured UI';
    }
  } catch (e) {
    status.notes = 'ERROR: ' + e.message.split('\n')[0];
    log(status.notes);
    await shot(page, 'error');
  } finally {
    fs.writeFileSync(path.join(OUT, 'status.json'), JSON.stringify(status, null, 2));
    log('done; leaving browser open 8s for any final state ...');
    await page.waitForTimeout(8000);
    await ctx.close();
  }
})();
