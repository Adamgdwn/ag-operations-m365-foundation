// Create the first-minute CRM signal alert flow:
//   SharePoint "CRM - New Signals" item created -> Microsoft Teams channel post
//
// This is an internal alert lane only. It does not update CRM, send mail, send
// external messages, create guests, change permissions, or call QUO.
//
// Usage:
//   node create-new-signal-teams-flow.js --dry
//   node create-new-signal-teams-flow.js [--state=Started|Stopped] [--headless]
const fs = require('fs');
const path = require('path');
let chromium;
try { ({ chromium } = require('@playwright/test')); }
catch { ({ chromium } = require(path.join(process.env.APPDATA || 'C:/Users/adamg/AppData/Roaming', 'npm/node_modules/@playwright/test'))); }

const REPO = path.resolve(__dirname, '..', '..');
const PROFILE_DIR = path.join(REPO, '.local', 'forms-builder', 'profile');
const CAP = path.join(REPO, '.local', 'flow-builder', 'capture');
const OUT = path.join(REPO, 'inventory', 'forms-build');
fs.mkdirSync(CAP, { recursive: true });
fs.mkdirSync(OUT, { recursive: true });
const log = (m) => console.log(`[${new Date().toISOString()}] ${m}`);

const ENV = 'Default-1ca92af5-21ff-42e3-87ae-3bde9c2cc501';
const EHOST = 'default1ca92af521ff42e387ae3bde9c2cc5.01.environment.api.powerplatform.com';
const FLOWHOST = 'api.flow.microsoft.com';
const SITE = 'https://agoperationsltd.sharepoint.com/sites/GuidedAILabs';
const LIST_TITLE = 'CRM - New Signals';
const TENANT_ACCT = 'adamgoodwin@guidedailabs.com';
const DISPLAY = 'GAIL - New Signal Teams alert';
const CHANNEL_TARGET = path.join(OUT, 'new-signal-teams-channel.json');
const apiId = (n) => `/providers/Microsoft.PowerApps/apis/${n}`;

const dry = process.argv.includes('--dry');
const headless = process.argv.includes('--headless');
const stateArg = (process.argv.find(a => a.startsWith('--state=')) || '=Started').split('=')[1];

function readChannelTarget() {
  if (!fs.existsSync(CHANNEL_TARGET)) {
    throw new Error(`Missing ${CHANNEL_TARGET}. Run scripts/Ensure-M365NewSignalTeamsChannel.ps1 first.`);
  }
  const target = JSON.parse(fs.readFileSync(CHANNEL_TARGET, 'utf8'));
  if (!target.groupId || !target.channelId) {
    throw new Error(`${CHANNEL_TARGET} is missing groupId or channelId.`);
  }
  return target;
}

function html(expr) {
  return `replace(replace(replace(string(${expr}),'&','&amp;'),'<','&lt;'),'>','&gt;')`;
}

function field(name) {
  return `coalesce(triggerOutputs()?['body/${name}'],'')`;
}

function choice(name) {
  return `coalesce(triggerOutputs()?['body/${name}']?['Value'],triggerOutputs()?['body/${name}'],'')`;
}

function sourceTextLine(label) {
  const sourceText = field('SourceText');
  const marker = `${label}: `;
  return `trim(if(contains(${sourceText}, '${marker}'), first(split(last(split(${sourceText}, '${marker}')), decodeUriComponent('%0A'))), ''))`;
}

function itemLinkExpr() {
  return `coalesce(triggerOutputs()?['body/{Link}'],concat('${SITE}/Lists/CRM%20%20New%20Signals/DispForm.aspx?ID=',triggerOutputs()?['body/ID']))`;
}

function buildMessageExpr() {
  const priority = html(choice('Priority'));
  const signalType = html(choice('SignalType'));
  const intakeSource = html(choice('IntakeSource'));
  const leadSourceDetailRaw = sourceTextLine('Lead source detail');
  const leadSource = html(`if(greater(length(${leadSourceDetailRaw}), 0), ${leadSourceDetailRaw}, ${choice('IntakeSource')})`);
  const title = html(field('Title'));
  const person = html(field('PersonName'));
  const org = html(field('OrganizationName'));
  const need = html(field('NeedSummary'));
  const nextAction = html(`coalesce(triggerOutputs()?['body/NextAction'],'Open CRM item and triage owner/next action')`);
  const created = html(field('Created'));
  const link = itemLinkExpr();

  return `@concat(` +
    `'<p><b>New CRM signal</b> - <b>',${priority},'</b></p>',` +
    `'<p><b>',${title},'</b></p>',` +
    `'<ul>',` +
    `'<li><b>Type:</b> ',${signalType},'</li>',` +
    `'<li><b>Source:</b> ',${intakeSource},'</li>',` +
    `'<li><b>Lead source:</b> ',${leadSource},'</li>',` +
    `'<li><b>Person:</b> ',${person},'</li>',` +
    `'<li><b>Organization:</b> ',${org},'</li>',` +
    `'<li><b>Need:</b> ',${need},'</li>',` +
    `'<li><b>Created:</b> ',${created},'</li>',` +
    `'<li><b>Suggested first move:</b> ',${nextAction},'</li>',` +
    `'</ul>',` +
    `'<p><a href="',${link},'">Open CRM signal</a></p>',` +
    `'<p><i>No external message has been sent. CRM remains the source of truth.</i></p>'` +
  `)`;
}

(async () => {
  let channelTarget;
  try { channelTarget = readChannelTarget(); }
  catch (e) { log(`ERROR: ${e.message}`); process.exit(1); }

  const CDP_PORT = process.env.CDP_PORT || '9222';
  let ctx, browser, ownCtx = false;
  try {
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`, { timeout: 8000 });
    ctx = browser.contexts()[0] || await browser.newContext();
    log(`connected to WARM Edge over CDP :${CDP_PORT} (contexts=${browser.contexts().length})`);
  } catch (e) {
    log(`CDP connect failed (${e.message.split('\n')[0]}); falling back to cold ${dry || headless ? 'headless' : 'headed'} launch`);
    ctx = await chromium.launchPersistentContext(PROFILE_DIR, { channel: 'msedge', headless: dry || headless, viewport: { width: 1400, height: 950 } });
    ownCtx = true;
  }
  const page = ctx.pages()[0] || await ctx.newPage();
  const tokens = {};
  const grab = (req) => {
    const a = req.headers()['authorization'];
    if (a && /^bearer /i.test(a)) {
      const h = new URL(req.url()).host;
      if (!tokens[h]) tokens[h] = a.replace(/^bearer\s+/i, '');
    }
  };
  page.on('request', grab);
  ctx.on('page', p => p.on('request', grab));

  const cleanup = async () => {
    try {
      if (ownCtx) await ctx.close();
      else if (browser) await browser.close();
    } catch {}
  };
  await page.goto(`https://make.powerautomate.com/environments/${ENV}/flows`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(9000);
  for (let i = 0; i < 5 && (!tokens[EHOST] || !tokens[FLOWHOST]); i++) {
    await page.goto(`https://make.powerautomate.com/environments/${ENV}/connections`, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
    await page.waitForTimeout(7000);
  }
  if (!tokens[EHOST] || !tokens[FLOWHOST]) {
    log(`ERROR: missing token (EHOST=${!!tokens[EHOST]} FLOW=${!!tokens[FLOWHOST]}); hosts=${Object.keys(tokens).join(',')}`);
    log('Run scripts/forms-builder/warm-edge.js and complete sign-in in the visible Edge window if prompted.');
    await cleanup();
    process.exit(2);
  }

  const get = async (host, url) => {
    const r = await page.request.get(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json' } });
    return { status: r.status(), body: await r.text() };
  };
  const post = async (host, url, body) => {
    const r = await page.request.post(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) });
    return { status: r.status(), body: await r.text() };
  };
  const patch = async (host, url, body) => {
    const r = await page.request.patch(url, { headers: { authorization: 'Bearer ' + tokens[host], accept: 'application/json', 'content-type': 'application/json' }, data: JSON.stringify(body) });
    return { status: r.status(), body: await r.text() };
  };
  const listConnsOnce = async (attempt) => {
    const raw = await get(EHOST, `https://${EHOST}/connectivity/connections?api-version=1`);
    let parsed = {};
    try { parsed = JSON.parse(raw.body); }
    catch {
      log(`connections GET #${attempt}: status=${raw.status} parse failed body=${raw.body.slice(0, 200)}`);
      return [];
    }
    const value = parsed.value || [];
    log(`connections GET #${attempt}: status=${raw.status} count=${value.length}`);
    return value;
  };
  const listConns = async (tries = 6) => {
    let c = [];
    for (let i = 0; i < tries; i++) {
      c = await listConnsOnce(i);
      if (c.length) return c;
      await page.waitForTimeout(3000);
    }
    return c;
  };
  const findConn = (conns, api) => conns.find(c => (c.properties && c.properties.apiId || '').endsWith(api));
  const connStatus = (c) => c && c.properties && c.properties.statuses ? c.properties.statuses.map(s => s.status).join(',') : null;

  let conns = await listConns();
  const spConn = findConn(conns, 'shared_sharepointonline');
  const teamsConn = findConn(conns, 'shared_teams');
  log(`SharePoint conn: ${spConn ? `${spConn.name} (${connStatus(spConn)})` : 'MISSING'}`);
  log(`Teams conn: ${teamsConn ? `${teamsConn.name} (${connStatus(teamsConn)})` : 'MISSING'}`);
  if (!spConn) {
    log('ERROR: SharePoint connection missing. Build it first (Start-FlowBuilder.ps1 -Phase connections -Only sharepoint).');
    await cleanup();
    process.exit(3);
  }
  if (!teamsConn) {
    log('ERROR: Teams connection missing. Build it first (Start-FlowBuilder.ps1 -Phase connections -Only teams).');
    await cleanup();
    process.exit(4);
  }

  await page.goto(SITE, { waitUntil: 'domcontentloaded', timeout: 60000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const bodyTxt = await page.evaluate(() => document.body ? document.body.innerText : '').catch(() => '');
  if (/Pick an account/i.test(bodyTxt)) {
    const t = await page.$(`[data-test-id="${TENANT_ACCT}"]`).catch(() => null);
    if (t) { await t.click().catch(() => {}); await page.waitForTimeout(8000); }
  }
  const lr = await page.request.get(`${SITE}/_api/web/lists/getbytitle('${LIST_TITLE}')?$select=Id`, { headers: { accept: 'application/json;odata=nometadata' } });
  const listId = JSON.parse(await lr.text()).Id;
  log(`list GUID: ${listId}`);
  if (!listId) {
    log('ERROR: could not resolve list GUID');
    await cleanup();
    process.exit(5);
  }

  const definition = {
    $schema: 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#',
    contentVersion: '1.0.0.0',
    parameters: { $connections: { defaultValue: {}, type: 'Object' }, $authentication: { defaultValue: {}, type: 'SecureObject' } },
    triggers: {
      When_new_CRM_signal_is_created: {
        recurrence: { frequency: 'Minute', interval: 1 },
        splitOn: "@triggerOutputs()?['body/value']",
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_sharepointonline', operationId: 'GetOnNewItems', apiId: apiId('shared_sharepointonline') },
          parameters: { dataset: SITE, table: listId },
          authentication: "@parameters('$authentication')",
        },
      },
    },
    actions: {
      Post_to_New_Signal_channel: {
        runAfter: {},
        type: 'OpenApiConnection',
        inputs: {
          host: { connectionName: 'shared_teams', operationId: 'PostMessageToConversation', apiId: apiId('shared_teams') },
          parameters: {
            poster: 'Flow bot',
            location: 'Channel',
            'body/recipient': { groupId: channelTarget.groupId, channelId: channelTarget.channelId },
            'body/messageBody': buildMessageExpr(),
          },
          authentication: "@parameters('$authentication')",
        },
      },
    },
  };

  const connectionReferences = {
    shared_sharepointonline: { connectionName: spConn.name, source: 'Embedded', id: apiId('shared_sharepointonline'), tier: 'NotSpecified' },
    shared_teams: { connectionName: teamsConn.name, source: 'Embedded', id: apiId('shared_teams'), tier: 'NotSpecified' },
  };
  const flowBody = { properties: { displayName: DISPLAY, state: stateArg, definition, connectionReferences } };
  fs.writeFileSync(path.join(CAP, 'flow-body-new-signal-teams.json'), JSON.stringify(flowBody, null, 2));
  log('wrote planned flow body -> .local/flow-builder/capture/flow-body-new-signal-teams.json');

  if (dry) {
    log('DRY RUN: no flow created. Review the planned body above.');
    await cleanup();
    return;
  }

  const base = `https://${FLOWHOST}/providers/Microsoft.ProcessSimple/environments/${ENV}/flows`;
  const resultPath = path.join(OUT, 'flow-result-new-signal-teams.json');
  let existingName = null;
  if (fs.existsSync(resultPath)) {
    try { existingName = JSON.parse(fs.readFileSync(resultPath, 'utf8')).flowName; } catch {}
  }
  let cr, created, flowName;
  if (existingName) {
    log(`updating existing New Signal Teams flow (${existingName})`);
    cr = await patch(FLOWHOST, `${base}/${existingName}?api-version=2016-11-01`, flowBody);
  } else {
    log(`creating New Signal Teams flow: ${DISPLAY}`);
    cr = await post(FLOWHOST, `${base}?api-version=2016-11-01`, flowBody);
  }
  log(`  -> ${cr.status}`);
  fs.writeFileSync(path.join(CAP, 'flow-create-new-signal-teams.json'), `status: ${cr.status}\n\n${cr.body}`);
  if (cr.status < 200 || cr.status >= 300) {
    log('  body: ' + cr.body.slice(0, 1500));
    await cleanup();
    process.exit(6);
  }

  created = JSON.parse(cr.body);
  flowName = created.name || existingName;
  const result = {
    purpose: 'first-minute CRM new signal Teams alert',
    flowName,
    displayName: DISPLAY,
    listId,
    state: created.properties && created.properties.state,
    createdStatus: cr.status,
    spConnection: spConn.name,
    teamsConnection: teamsConn.name,
    team: channelTarget.teamDisplayName || channelTarget.groupDisplayName,
    groupId: channelTarget.groupId,
    channel: channelTarget.channelDisplayName,
    channelId: channelTarget.channelId,
  };
  fs.writeFileSync(resultPath, JSON.stringify(result, null, 2));
  log(`RESULT: flow=${flowName} state=${result.state}`);
  log('wrote inventory/forms-build/flow-result-new-signal-teams.json');
  await cleanup();
})();
