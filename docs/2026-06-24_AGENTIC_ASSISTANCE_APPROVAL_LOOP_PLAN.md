# M365 Interaction Agent MVP Plan

Date generated: 2026-06-24

Status: **B1-B4 live proof complete; paused before B5** (updated 2026-06-25).
Adam paused because two agents are writing to M365 accounts and competing. This
revision follows the plan review that separated real agent capability from the
old supervised setup-helper path, and Adam's decision that this should be one
M365 interaction agent with governed capabilities rather than separate
supervised helper layers.

Owner: Adam.

Related docs:

- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`
- `docs/AGENTIC_M365_READINESS.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`
- `docs/COORDINATOR_DAILY_READ.md`
- `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`
- `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`
- `config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json`
- `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md`

## Night Box-Up Snapshot

Boxed on 2026-06-24, updated after the 2026-06-25 proof:

- Active product direction is one `M365 Interaction Agent`, not separate helper
  bots.
- First live notification capability is `CRM - New Signals` created -> internal
  Teams channel `New Signal`; this lane is now proven with synthetic CRM item
  `#19`.
- QUO remains parked until a later source-expansion decision.
- Local scripts and runbook exist for channel setup, Teams connector setup,
  dry-run flow body, live flow creation, B1 proof capture, B2/B3 local triage
  and similar-record advisory, and B4 Suggested Agent Action Log rows.
- Live proof evidence now shows the channel target, Teams connector, started
  flow, one Teams post from one test CRM item, B2/B3 triage, and one B4
  `Suggested` Agent Action Log row.
- Work is now paused before B5 because another M365-writing agent may compete
  with this repo's live write actions.

Resume at:

1. `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`
2. `SESSION_TURNOVER_2026-06-25.md`
3. Competing-writer audit
4. B5 durable permission decision
5. B6 source expansion after B5

## Pause Protocol - 2026-06-25

Do not run additional M365 writes from this repo while the pause is active.
That includes `-Apply`, `-Approve`, connector creation, flow creation/update,
synthetic proof item creation, Agent Action Log writes, permission grants, QUO
setup, and external sends.

Safe while paused:

- documentation review;
- local evidence review;
- parser/lint checks;
- read-only triage only if Adam explicitly asks for it.

First resume decision:

- Which live agent owns each M365 write surface?
- Does the already-started `GAIL - New Signal Teams alert` flow stay active?
- Does this repo retain the G1 `Suggested` Agent Action Log lane, or does
  another agent become the only writer?
- What is the revoke/disable path for each writer?

Record those answers in B5 before expanding source inputs, permissions, or
unattended behavior.

## Plan Review Findings

The previous plan was too approval-loop-first. The approval loop is necessary,
but it is not the product. The product is a working agent lane with clear
permission boundaries, evidence, and pause/revoke controls.

Current repo evidence already points the right way:

- One durable M365 interaction agent is the target. `M365 Coordinator` is the
  first operating capability/mode, not a separate little helper.
- Support, CRM, Teams, Planner, Lists, SharePoint, Forms, mailbox, and later
  phone lanes should become capabilities of the same governed M365 agent unless
  a security boundary later forces a separate adapter.
- `agent-pnp-provisioning` is a broad setup/provisioning helper only.
- Broad setup-helper grants must not become production agent power.
- A production agent needs a purpose-built identity or adapter posture, not
  inherited setup authority.
- Freedom (`Adamgdwn/the-freedom-engine-os`) is the architectural reference:
  one named governed agent identity with tools, capability contracts, evidence,
  approvals, and visible autonomy state.

## Revised Purpose

Build the first useful M365 operating agent:

```text
source records -> M365 Interaction Agent -> reasoned proposal ->
Agent Action Log -> Adam approval when needed -> controlled internal action ->
evidence + rollback/pause note
```

The approval loop remains the control layer. The single agent is the main build
target.

## First Agent MVP

Agent name:

- `M365 Interaction Agent`

First operating capability:

- `Coordinator`

Operating purpose:

- Read live operations, CRM, follow-up, action-log, and decision records.
- Handle M365 interactions through one governed identity/capability model rather
  than separate notification, CRM, Teams, Planner, or support bots.
- Detect stale work, missing next actions, overdue follow-ups, and governance
  gaps.
- Prepare useful proposed actions with source links, risk level, owner, and
  next step.
- Record suggestions in the Agent Action Log only when the write lane is
  explicitly allowed.

Initial read surfaces:

- Intake Register
- Decision Register
- Agent Action Log
- Automation Backlog
- Tool Permission Review
- CRM Organizations, Contacts, Engagements, Touchpoints, and Lifecycle records
- Readiness/evidence references already approved for operating review

Initial write surface:

- Agent Action Log `Suggested` rows only.

First-minute alert surface:

- A dedicated Teams channel named `New Signal`, fed by an immediate alert lane
  when a new `CRM - New Signals` item is created.
- The CRM list remains the source of truth; Teams is the attention surface.
- Alert content should include source, priority, person/organization, signal
  summary, created time, item link, and the suggested first move.
- The 15-minute follow-up backbone is not fast enough for first-contact alerts;
  it remains the task/calendar/reminder backbone after triage.

Later supervised G2 candidates:

- update an internal `NextAction`;
- add or update an internal CRM touchpoint;
- create or update an internal Planner/List follow-up task;
- record an approved Decision Register entry.

Blocked actions:

- external sends;
- guest invites;
- sharing or permission changes;
- app registration or consent;
- tenant policy changes;
- public/client Forms;
- deletes;
- billing/client commitments;
- auto-replies or outbound phone/SMS messages;
- unattended client-impacting automation.

## Hot Signal Alert Lane

Purpose:

- Make Adam aware within the first few minutes when a new opportunity, referral,
  inbound message, missed call, or urgent CRM signal lands.

Recommended design:

```text
new signal source -> CRM - New Signals item -> New Signal Teams channel alert ->
Adam/operator triage -> Coordinator Agent proposal -> follow-up backbone if needed
```

Why this is separate from the follow-up backbone:

- The follow-up engine is scheduled and optimized for due dates, tasks, and
  calendar state.
- First-contact alerting needs event-driven behavior and should fire as soon as
  the CRM item exists.

Initial alert rule:

- Trigger on new items in `CRM - New Signals`.
- Post to Teams channel `New Signal`.
- Include a direct link back to the CRM item.
- Mark the alert as internal-only; do not notify the prospect automatically.

Escalation rules to design:

- High/Urgent priority should produce a louder Teams alert and a suggested
  "respond now" action.
- Missed phone call, voicemail, or repeated inbound signal should be treated as
  time-sensitive by default.
- Normal website form submissions can still alert immediately, but without
  implying a promised response time until Adam sets the rule.

Evidence to add before build:

- alert owner;
- channel name and team;
- trigger source;
- duplicate prevention rule;
- alert message template;
- expected latency target;
- read-back proof that a test signal produced exactly one Teams alert.

## QUO Phone Service Integration

Status: **Parked** (2026-06-24). The good news is that QUO can fit this model
later, but it is not part of the notification setup chunk.

QUO should become an inbound signal source, not a separate CRM.

Target pattern:

```text
QUO call/SMS/voicemail event -> verified ingress -> CRM - New Signals ->
New Signal Teams alert -> Coordinator Agent proposal -> approved response path
```

Useful QUO event classes:

- inbound SMS or conversation message;
- incoming/ringing call;
- completed call;
- missed call or voicemail;
- recording, transcript, or call summary when available;
- contact created or updated.

MVP inbound behavior:

- create or update a `CRM - New Signals` item with `IntakeSource = QUO`;
- classify the signal as Phone, SMS, Voicemail, or Call Summary;
- preserve caller/contact details and a QUO conversation/call link when
  available;
- alert the `New Signal` Teams channel immediately;
- let the Coordinator Agent summarize and suggest the first response.

Outbound boundary:

- No automatic SMS reply or callback in the MVP.
- The agent may draft a suggested SMS/call-back note for Adam.
- Sending through QUO API is a later G3 decision with an approval phrase,
  evidence, and rollback/pause path.

Implementation options to compare before build:

1. **Manual bridge first:** Adam keeps QUO notifications on the phone and enters
   or forwards important signals into CRM. Lowest risk, not enough automation.
2. **No-code webhook bridge:** QUO webhook into Make/Zapier/Power Automate,
   then create `CRM - New Signals`. Faster to prove, but introduces a third-party
   automation/secrets surface.
3. **Purpose-built ingress adapter:** small verified `quo-signal-ingress`
   endpoint that checks QUO webhook signatures, normalizes payloads, writes one
   CRM item, and lets the CRM alert lane post to Teams. Best production shape.

Open questions:

- Which QUO number(s) count as business-intake numbers?
- Which events should create new CRM signals versus append to an existing one?
- What is the hot-response SLA for phone/SMS signals?
- Should missed calls be High by default?
- Where should raw QUO payload evidence live, and how long should it be kept?
- Is a third-party automation bridge acceptable for proof, or should we go
  straight to a purpose-built adapter?

## Identity And Permission Strategy

Do not approve `agent-pnp-provisioning` as an agent identity.

Accepted use of `agent-pnp-provisioning`:

- time-boxed setup/provisioning only;
- manual review or cleanup when Adam intentionally chooses setup work;
- never as the production M365 Interaction Agent.

Target agent posture:

- design a purpose-built `m365-interaction-agent` identity or adapter;
- prefer least-privilege SharePoint/List access over broad tenant-wide grants;
- document exact read/write surfaces before any app creation or consent;
- complete a pause/revoke worksheet before any app-based write permission;
- record the app posture in Decision Register before granting anything.

Open permission-design question:

- whether the first durable agent should use SharePoint Selected permissions,
  a different narrow Microsoft 365 adapter, or remain local/read-only until the
  permission boundary is proven.

## Chunk A1 - Agent Contract And Boundary

Objective:

Turn the selected MVP into a real agent contract before any tenant permission
change.

Actions:

1. Freeze `agent-pnp-provisioning` as setup-only in this plan.
2. Define the `M365 Interaction Agent` contract: sources, allowed writes,
   blocked actions, evidence target, and rollback/pause owner.
3. Confirm the live Agent Action Log and Decision Register fields/views are
   enough for agent evidence, using read-only evidence first.
4. Define the `New Signal` alert contract: Teams channel, trigger, message
   template, duplicate rule, latency target, and proof record.
5. Define the minimum proposal packet: source, affected card, action type,
   governance level, human owner, approval needed, result target, evidence
   target, and rollback/pause note.
6. Keep QUO parked until the first-minute Teams alert is proven.
7. Draft the least-privilege permission posture for `m365-interaction-agent`,
   including explicit non-goals and revocation path.
8. Run the Teams alert proof as the first live notification capability of the
   single M365 agent.

Acceptance:

- The first agent has a named job, named surfaces, and named blocked actions.
- The approval loop is documented as the control layer, not the main product.
- First-minute CRM alerting is part of the MVP path, not a future afterthought.
- QUO is documented as parked, with outbound messaging blocked until a separate
  decision.
- The setup helper is explicitly rejected as production agent capability.
- No app registration, consent, or broad permission grant is approved by this
  chunk.
- Adam can decide whether the next proof should be local-only, delegated G1, or
  purpose-built app based on the permission design.

## Chunk A2 - Coordinator Agent G0/G1 Proof

Objective:

Prove the agent produces useful operating judgment before expanding write
capability.

Preferred workflow:

- Source: CRM / Bookings / follow-up records already live.
- Agent work: summarize the record, detect stale or risky work, propose the
  next operating action, classify it G0-G4, and prepare an Agent Action Log
  entry.
- Human gate: Adam approves, rejects, or sends it back for detail.
- Evidence: Agent Action Log links to the source record, decision if needed,
  result, and rollback/pause note.

Proof options:

1. **Local-only G0 proof:** agent writes a local digest/proposal packet only.
2. **G1 suggested-row proof:** agent records one `Suggested` row after the
   exact write lane and approval phrase are confirmed.
3. **Teams hot-alert proof:** one internal test signal creates exactly one
   `New Signal` Teams alert and links back to the CRM item.
4. **QUO inbound proof, parked:** one future test QUO call/SMS event creates or
   maps to a CRM signal and triggers the Teams alert, with no outbound reply.
5. **Purpose-built app proof:** wait until `m365-interaction-agent` app posture,
   least-privilege scopes, and revoke path are approved.

Default next proof:

- Teams hot-alert proof selected on 2026-06-24: one internal test CRM signal
  creates exactly one `New Signal` Teams post and links back to the CRM item.
  Local B2/B3 triage plus similar-record advisory now runs through
  `scripts/Invoke-M365NewSignalTriage.ps1`. The same script can perform the B4
  G1 suggested-row proof with `-Apply` after Adam approves the one Agent Action
  Log write.

Acceptance:

- The agent produces at least one useful, source-linked operating proposal.
- Suggested is visibly separate from approved.
- Approved is visibly separate from executed.
- Evidence and rollback/pause notes exist before any supervised write.
- The proof does not rely on broad setup-helper power.

## Chunk A3 - Production Agent Posture Decision

Objective:

Choose the durable permission model for the first real M365 agent.

Decision packet must include:

- agent name and owner;
- purpose and non-goals;
- exact read surfaces;
- exact write surfaces;
- blocked actions;
- proposed Microsoft permissions;
- why narrower options are insufficient, if applicable;
- approval phrase;
- revoke/disable path;
- review date;
- evidence location.

Stop until this is approved:

- app registration;
- admin consent;
- SharePoint Selected grants;
- Exchange Application RBAC;
- connector setup;
- QUO webhook/API setup;
- unattended automation.

## Immediate Next Actions

Expanded build chunks are documented in
`docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`.

Paused. Completed items:

1. Internal Teams channel `Guided AI Labs / New Signal` exists.
2. Standard Power Automate Microsoft Teams connection exists for
   `adamgoodwin@guidedailabs.com`.
3. Create-only notification flow exists and is `Started`:
   `CRM - New Signals` created -> `New Signal` Teams post.
4. Synthetic proof item `#19` produced exactly one observed Teams alert with a
   CRM item link.
5. Local B2/B3 triage and similar-record packet exists.
6. B4 `Suggested` Agent Action Log row `#9` exists.

Next when resumed:

1. Resolve the competing M365-writing agent issue.
2. Record the B5 durable permission/adapter posture.
3. Keep QUO parked.
4. Then decide B6 source expansion.

## Stop Conditions

Stop before app registration, app consent, broad Graph/SharePoint/Exchange/
Teams/Planner permission changes, selected permission grants, mailbox adapter
work, external sends, QUO webhook/API setup, phone/SMS auto-replies, guest
access, sharing changes, public forms, deletes, billing/client commitments,
Dynamics, Dataverse, premium Power Platform, Copilot connector setup, custom
actions, or unattended client-impacting automation.

Narrow exception selected on 2026-06-24: create one internal standard Teams
channel named `New Signal`, create/use the standard Microsoft Teams Power
Automate connector as Adam, and create one internal SharePoint-to-Teams alert
flow for `CRM - New Signals`. This exception does not approve app registration,
admin consent, external messaging, guest access, broad automation, or QUO.

Stop immediately if a setup-helper grant is being treated as production agent
capability.

Stop immediately if another M365-writing agent is active and the write-owner
boundary has not been intentionally decided.
