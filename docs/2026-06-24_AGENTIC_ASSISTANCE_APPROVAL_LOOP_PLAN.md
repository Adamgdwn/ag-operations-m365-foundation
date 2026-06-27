# M365 Interaction Agent MVP Plan

Date generated: 2026-06-24

Status: **B1-B7 live proof complete; B8a, B9a, and B10a local packets complete; B8b/B9b/B10b live work gated** (updated 2026-06-27).
The 2026-06-25 pause before B5 was resolved by the B5 durable one-writer
decision. This revision follows the plan review that separated real agent
capability from the old supervised setup-helper path, and Adam's decision that
this should be one M365 interaction agent with governed capabilities rather
than separate supervised helper layers. The next chunks are B8b Journey
receipt/replay hardening if approved, B9b selected-signal operating triage after
item selection, and B10b QUO inbound source proof if approved. B8a local
hardening design, B9a local operating readiness, and B10a local QUO readiness
are executed; B8b/B9b/B10b live work remains gated.

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

Boxed on 2026-06-24, updated after the 2026-06-25/26 proof:

- Active product direction is one `M365 Interaction Agent`, not separate helper
  bots.
- First live notification capability is `CRM - New Signals` created -> internal
  Teams channel `New Signal`; this lane is now proven with synthetic CRM item
  `#19`.
- Journey source and receipt acknowledgement are also proven: CRM item `#25`
  reached Journey status `crm_received`, and CRM item `#27` proved
  `Lead source detail` in CRM provenance and Teams.
- QUO now has B10a local readiness, and B10b remains the near-term live source
  proof while call volume is still low.
- B8a local Journey loop hardening packet is generated with field, duplicate,
  replay, cleanup, and approval-boundary decisions. B8b live work remains
  unapproved until the exact scope and phrase are used.
- B9a local selected-signal operating packet is generated with queue/review
  templates and operating labels. B9b tenant activity waits for selected item
  ids, source, or window; any G1 row remains per-item approval.
- B10a local QUO inbound source proof packet is generated with event mapping,
  live decision worksheet, proof checklist, duplicate/payload/disable policies,
  and the future B10b approval boundary.
- Local scripts and runbooks exist for channel setup, Teams connector setup,
  flow creation/update, B1 proof capture, B2/B3 local triage and
  similar-record advisory, B4 Suggested rows, B5 decision recording, B6 Journey
  source proof, B7 Journey acknowledgement, B8a Journey hardening packet
  generation, B9a selected-signal operating packet generation, and B10a QUO
  inbound source proof packet generation.
- Live proof evidence now shows the channel target, Teams connector, started
  flow, one Teams post from one test CRM item, B2/B3 triage, B4 `Suggested`
  row, B5 one-writer posture, B6 Journey source proof, B7 receipt ack, and
  lead-source display.

Resume at:

1. `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`
2. `SESSION_TURNOVER_2026-06-25.md`
3. B8b Journey loop hardening live update, if approved
4. B9b selected-signal operating triage after item selection
5. B10b QUO inbound source proof, if approved

## Approval Protocol - 2026-06-27

Do not run additional M365 writes from this repo without a fresh approval
boundary. That includes `-Apply`, `-Approve`, connector creation, flow
creation/update, synthetic proof item creation, Agent Action Log writes,
permission grants, QUO setup, and external sends.

Safe without a fresh write approval:

- documentation review;
- local evidence review;
- parser/lint checks;
- read-only triage only if Adam explicitly asks for it.

Resolved by B5:

- Prime Boiler 365 setup is separate from this Guided AI Labs lane.
- The B5 durable one-writer posture is recorded in Decision Register `#6`.
- The evidence row is Agent Action Log `#10`.
- `agent-pnp-provisioning` remains setup-only.

Next approval decisions:

- Whether to approve B8b live update with phrase
  `approve-b8-journey-loop-hardening-live-update-20260627`.
- Whether to add `PortalEventId` and `SourceCorrelationId` to
  `CRM - New Signals` for B8b.
- Whether to update the live HTTP intake flow for B8b idempotency and
  created/existing receipt acknowledgements.
- Which CRM item ids, source, or time window Adam wants for B9b selected
  read-only triage, and whether any selected item may receive a G1 Suggested
  row.
- Which QUO number(s), event class, ingress option, secret/signature storage,
  payload retention, duplicate rule, owner/disable path, and outbound block are
  allowed for B10b.

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
- In the broader Guided AI Labs operating-system model, this repo is building
  the M365 enterprise-body lane. Freedom remains the executive/coordinator
  layer, Guided AI Labs Operating System remains the governance/autonomic layer,
  and Graphify remains the relationship/context-graph layer. B8/B9/B10 should
  produce stable evidence and source metadata for those layers without coupling
  this repo directly to them yet.
- The local `G0-G4` gates map to the organization-level `R0-R5` authority
  ladder. Current work enables R0/R1 and narrowly approved R2/R3 only; R4
  delegated autonomy is not enabled, and R5 human-only decisions remain with
  Adam.

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

Status: **B10a local readiness complete; B10b live proof gated** (updated
2026-06-27). QUO is not part of B8 Journey hardening or B9 selected-signal
triage, but it is the intended B10 source proof while call volume is still low.
B10a produced the local packet, event mapping, live decision worksheet, and
proof checklist without touching QUO or Microsoft 365.

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
- Future B10b live approval phrase prepared, not consumed:
  `approve-b10-quo-inbound-source-proof-20260627`.

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

B10a evidence:

- Packet:
  `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`.
- Event mapping:
  `inventory/m365-interaction-agent-b10/b10-quo-event-mapping-20260627-094929.csv`.
- Live decision worksheet:
  `inventory/m365-interaction-agent-b10/b10-quo-live-decision-worksheet-20260627-094929.csv`.
- Proof checklist:
  `inventory/m365-interaction-agent-b10/b10-quo-proof-checklist-20260627-094929.csv`.
- Config:
  `config/M365_INTERACTION_AGENT_B10_QUO_INBOUND_SOURCE_PROOF.json`.
- Packet generator:
  `scripts/New-M365B10QuoInboundSourceProofPacket.ps1`.

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
6. Keep QUO live setup behind B8/B9 guardrails; B10a local readiness is done
   and B10b live proof remains approval-gated.
7. Draft the least-privilege permission posture for `m365-interaction-agent`,
   including explicit non-goals and revocation path.
8. Run the Teams alert proof as the first live notification capability of the
   single M365 agent.

Acceptance:

- The first agent has a named job, named surfaces, and named blocked actions.
- The approval loop is documented as the control layer, not the main product.
- First-minute CRM alerting is part of the MVP path, not a future afterthought.
- QUO is documented with B10a local readiness complete, while live setup and
  outbound messaging stay blocked until separate decisions.
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
4. **QUO inbound proof, B10b:** one future approved no-real-client or internal
   QUO call/SMS event creates or maps to a CRM signal and triggers the Teams
   alert, with no outbound reply.
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

Completed items:

1. Internal Teams channel `Guided AI Labs / New Signal` exists.
2. Standard Power Automate Microsoft Teams connection exists for
   `adamgoodwin@guidedailabs.com`.
3. Create-only notification flow exists and is `Started`:
   `CRM - New Signals` created -> `New Signal` Teams post.
4. Synthetic proof item `#19` produced exactly one observed Teams alert with a
   CRM item link.
5. Local B2/B3 triage and similar-record packet exists.
6. B4 `Suggested` Agent Action Log row `#9` exists.
7. B5 durable posture is recorded in Decision Register `#6` and Agent Action
   Log `#10`.
8. B6 Guided AI Journey source proof created CRM item `#21` and Agent Action
   Log `#11`.
9. B7 Journey CRM receipt proof created CRM item `#25` and reached Journey
   status `crm_received`.
10. Lead-source display proof created CRM item `#27` with
    `Lead source detail: Journey admin invite`.
11. B10a local QUO inbound source proof packet, event mapping, decision
    worksheet, and proof checklist exist.

Next when resumed:

1. Run B8b live Journey hardening only if approved by exact scope and phrase.
2. Run B9b selected-signal operating triage under G0/G1 after item selection.
3. Run B10b QUO inbound-only live proof only after exact number/event/ingress,
   secret, retention, duplicate, disable, and outbound-block approval.

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
