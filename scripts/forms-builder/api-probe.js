// Probe: can we create a Microsoft Form via formapi POST using a captured token?
// Creates a THROWAWAY form titled "GAIL-API-PROBE" to confirm the create path,
// then prints the new form id + share-link discovery. Secrets stay in-process;
// only redacted, non-secret results go to .local/.
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const OUT = path.join(REPO, '.local', 'forms-builder', 'capture');
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const TENANT = '1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const USER = '8344f12a-4ee9-4bb5-954a-056ec0a09008';
const FORMS_COLLECTION = `https://forms.office.com/formapi/api/${TENANT}/users/${USER}/light/forms`;

(async () => {
  const ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: true, viewport: { width: 1536, height: 900 } });
  const page = ctx.pages()[0] || await ctx.newPage();

  // formapi auth = session cookie (carried by page.request) + anti-forgery token
  // (__requestverificationtoken) + odata/x-ms-form headers. Harvest the full set.
  let apiHeaders = null;
  page.on('request', req => {
    if (apiHeaders) return;
    if (/formapi\/api\/.+\/light\/forms/i.test(req.url()) && req.method() === 'GET') {
      apiHeaders = req.headers();
    }
  });

  log('loading forms.office.com to harvest formapi headers ...');
  await page.goto('https://forms.office.com/', { waitUntil: 'networkidle', timeout: 45000 }).catch(e => log('nav warn ' + e.message.split('\n')[0]));
  await page.waitForTimeout(4000);

  if (!apiHeaders || !apiHeaders['__requestverificationtoken']) {
    log('ERROR: could not harvest __requestverificationtoken from formapi traffic.');
    fs.writeFileSync(path.join(OUT, 'probe-result.txt'), 'FAILED: no verification token harvested; keys=' + (apiHeaders ? Object.keys(apiHeaders).join(',') : 'none'));
    await ctx.close();
    process.exit(1);
  }
  log(`harvested verification token (len=${apiHeaders['__requestverificationtoken'].length}); attempting create ...`);

  // Replay the auth-relevant headers; page.request adds session cookies automatically.
  const passthrough = ['__requestverificationtoken', 'odata-maxverion', 'odata-version', 'x-ms-form-request-ring', 'x-ms-form-request-source', 'x-ms-form-muid', 'x-usersessionid', 'x-fsw-api', 'x-fsw-enable', 'x-correlationid'];
  const headers = { 'content-type': 'application/json; charset=UTF-8', 'accept': 'application/json' };
  for (const h of passthrough) { if (apiHeaders[h]) headers[h] = apiHeaders[h]; }

  const createBody = { title: 'GAIL-API-PROBE', description: '' };
  let result = { ok: false };
  try {
    const resp = await page.request.post(FORMS_COLLECTION, { headers, data: JSON.stringify(createBody) });
    const status = resp.status();
    let text = ''; try { text = await resp.text(); } catch {}
    result.status = status;
    result.bodyHead = text.slice(0, 1500);
    // Try to extract the new form id.
    let id = null; try { id = JSON.parse(text).id; } catch {}
    result.formId = id;
    result.ok = status >= 200 && status < 300 && !!id;
    log(`create POST status=${status} formId=${id || '(none)'}`);
    fs.writeFileSync(path.join(OUT, 'probe-result.txt'),
      `CREATE ${FORMS_COLLECTION}\nstatus: ${status}\nformId: ${id}\nbodyHead:\n${text.slice(0, 2000)}\n`);
  } catch (e) {
    log('create error: ' + e.message.split('\n')[0]);
    fs.writeFileSync(path.join(OUT, 'probe-result.txt'), 'ERROR: ' + e.message);
  }
  await ctx.close();
  log('probe done');
})();
