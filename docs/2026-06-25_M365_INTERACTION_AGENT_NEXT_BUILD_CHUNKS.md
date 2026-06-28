# M365 Interaction Agent Next Build Chunks

Date: 2026-06-25

Status: B1-B7 live-proof baseline established on 2026-06-25/26. The proven
lane now includes New Signal Teams alerting, B2/B3 triage evidence,
similar-record advisory, one G1 `Suggested` Agent Action Log row, B5 one-writer
posture, B6 Guided AI Journey source proof, B7 Journey CRM receipt
acknowledgement, and lead-source display in CRM provenance and Teams alerts.
The current planning update on 2026-06-27 moves the build from proof to
low-volume operation: B8 hardens the Journey receipt/replay loop, B9 exercises
selected-signal triage in normal use, and B10 brings QUO forward as an
inbound-only source proof while call volume is still low. QUO is still outside
the immediate hardening step, but it is no longer an indefinite parking-lot
item. B8a local hardening design and B8b live schema/flow/replay proof are now
executed. B9a local selected-signal operating packet is also executed, so the
next B9 tenant touch is only a selected G0 read, or a selected G1 `Suggested`
row if Adam approves that specific item. B10a local QUO inbound source readiness
is now executed as a no-live-touch packet; B10b live proof remains gated by
exact number, event, ingress, secret, retention, disable, and outbound-block
approvals.

Owner: Adam.

Related docs:

- `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`
- `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`
- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`
- `docs/COORDINATOR_DAILY_READ.md`

## Purpose

Build the first useful M365 agent lane in the order it should actually come
online:

```text
CRM signal created
-> first-minute Teams alert
-> agent triage packet
-> similar-lead advisory
-> Agent Action Log Suggested row
-> durable agent permission decision
-> more inbound sources
-> source receipt acknowledgement where needed
-> operational hardening and near-term QUO inbound proof
```

This is a build plan, not standing approval for tenant writes. Each live write,
connector, app, permission, external send, or source expansion still needs its
own approval boundary.

Operator interaction rule: Adam should never have to guess where an approval,
sign-in, MFA prompt, source selection, or source proof interaction is supposed
to happen. Before waiting on Adam, the agent must open or name the exact visible
window/browser/admin surface, give it a clear title, and record where the local
evidence will land. For B8/B9/B10 approval captures, use
`scripts/Start-M365InteractionAgentApprovalWindow.ps1`; it opens a visible
PowerShell window, shows the approved scope and stop conditions, and writes a
local `.local/interaction-agent-approvals/*.json` capture without performing
tenant/source work.

## Guided AI Labs OS Alignment

The Guided AI Labs central-nervous-system vision does not change the B8/B9/B10
order. It clarifies what this M365 lane is responsible for.

- M365 is the enterprise body: records, collaboration, communications, tasks,
  files, and governed internal execution.
- `CRM - New Signals`, Forms/Journey, and QUO are sensory portals into that
  body. B10 is the first Phone / Voice / Text sensory proof.
- Teams, Power Automate, scripts, M365 agents, APIs, product apps, and later
  actions are execution channels, not independent brains.
- Freedom is the executive-cognition/coordinator layer, Guided AI Labs
  Operating System is the governance/autonomic-management layer, and Graphify
  is the relationship/context-graph layer.
- B8/B9/B10 should leave stable event ids, source ids, relationship hints,
  governance labels, and evidence packets that those layers can consume later.
  They should not couple this repo directly to Freedom or Graphify yet.

Authority vocabulary:

| Org authority level | Local M365 build gate | Current interpretation |
|---|---|---|
| R0 Observe | G0 | Read, classify, summarize, detect gaps, and produce local evidence. |
| R1 Propose | G1 | Write or prepare supervised `Suggested` rows only. |
| R2 Internal Act | G2 | Approved internal List/task/draft writes with rollback evidence. |
| R3 Restricted | G3 | External, access, connector, or callback-impacting work with Decision Register approval and typed phrase. |
| R4 Delegated Autonomous | Not enabled | No B8/B9/B10 work creates autonomous delegated authority. |
| R5 Human Only | G4 blocked/escalate | Adam keeps final authority for client commitments, legal/billing, access/admin, deletes/merges, external sends, and any R4 delegation decision. |

Keep using `G0-G4` in current M365 scripts and docs until there is a deliberate
rename. Use `R0-R5` as the organization-level interpretation of the same
authority boundary.

## Pause Handover - 2026-06-25

Pause reason:

- Adam was switching between the Guided AI Labs lane and Prime Boiler 365 setup
  under separate accounts/sessions.
- The next session should keep those account lanes separated and record that
  this repo owns the Guided AI Labs `CRM - New Signals` path.

What is already live:

- `Guided AI Labs / New Signal` Teams channel exists.
- Microsoft Teams Power Automate connector exists as
  `adamgoodwin@guidedailabs.com`.
- Flow `GAIL - New Signal Teams alert`
  (`c54964d6-0042-430d-b542-90214e49224b`) is `Started`.
- The flow may continue posting internal Teams alerts for new
  `CRM - New Signals` items unless Adam disables it in Power Automate.
- The create-only intake flows are also `Started`:
  - `GAIL - Guided AI Labs intake to CRM (create-only)`
  - `GAIL - Guided AI Journey intake to CRM (create-only)`
- Those two intake flows create `CRM - New Signals` rows. They are source
  ingress automations, not agent decision writers.
- B5 one-writer posture is recorded in Decision Register `#6`; evidence row is
  Agent Action Log `#10`.

What not to rerun without a fresh approval boundary:

- `scripts/Invoke-M365NewSignalAlertProof.ps1 -Apply`.
- `scripts/Invoke-M365NewSignalTriage.ps1 ... -Apply`.
- `scripts/Invoke-M365B5InteractionAgentDecision.ps1 -Apply` unless Adam uses
  the exact B5 approval phrase.
- Any command using `-Approve` for an M365 write.
- `scripts/flow-builder/Start-FlowBuilder.ps1 -Phase connections`.
- `scripts/flow-builder/Start-FlowBuilder.ps1 -Phase new-signal -State Started`.
- Any connector creation, flow creation/update, synthetic CRM item creation,
  Agent Action Log write, permission grant, app registration, external send, or
  QUO integration.

Safe work while paused:

- Read docs and evidence.
- Run `git status --short`.
- Review local inventory files.
- Run parser/lint checks that do not touch M365.
- Run `scripts/Invoke-M365B5InteractionAgentDecision.ps1 -LocalOnly -NoPause`
  to preview the B5 recorder without connecting to Microsoft 365.
- Run `scripts/Invoke-M365B6JourneyIntakeProof.ps1 -NoPause` to prepare the B6
  Journey intake proof packet without connecting to Microsoft 365.
- Run `scripts/New-M365B8JourneyLoopHardeningPacket.ps1 -NoPause` to regenerate
  the B8a local hardening packet without connecting to Microsoft 365.
- Run `scripts/New-M365B9SelectedSignalOperatingTriagePacket.ps1 -NoPause` to
  regenerate the B9a local selected-signal operating packet, queue template, and
  review template without connecting to Microsoft 365.
- Run `scripts/New-M365B10QuoInboundSourceProofPacket.ps1 -NoPause` to
  regenerate the B10a local QUO inbound source proof packet, event mapping,
  decision worksheet, and proof checklist without connecting to QUO or
  Microsoft 365.
- After Adam manually submits the selected Journey proof intake, run
  `scripts/Start-M365B6JourneyIntakeProofInteractive.ps1 -Verify -ForceFreshLogin`
  to verify the CRM signal read-only.
- Run `scripts/Invoke-M365NewSignalTriage.ps1` only without `-Apply` if Adam
  explicitly wants a read-only packet; otherwise leave M365 untouched.

First resume action:

1. B5 local audit recording is done: Prime Boiler 365 setup is a separate
   account/session lane, and this repo owns the Guided AI Labs `New Signal`
   path.
2. B5 durable permission packet is recorded in Decision Register `#6` and Agent
   Action Log `#10`.
3. B5 recorder script is retained for evidence, local preview, tenant dry run,
   or a later explicitly approved superseding record.
4. Guided AI Journey client intake is staged as the first B6 source proof,
   through the existing create-only Form/CRM path.
5. B6 helper local prep is complete; only the manual/client-style intake
   submission can create the CRM proof item.
6. Only run a follow-on G1 Suggested-row write after Adam explicitly approves
   that specific step.

## Current Starting Point

Already live or verified:

- `Guided AI Labs - Get started` Microsoft Form.
- `Guided AI Journey - Get started` Microsoft Form.
- Both Forms create items in the same `CRM - New Signals` list.
- `CRM - New Signals` is the source of truth for new opportunities and signals.
- Guided AI Journey client invites should point first to the Journey Form or a
  website CTA/embed that reaches the same intake. A later custom website form
  contract exists locally, but any proof still has to preserve server-side
  secrets and the same `CRM - New Signals` shape.
- SharePoint and Microsoft Forms Power Automate connections are connected.
- Agent governance model exists: G0 read, G1 propose/log, G2 approved internal
  write, G3 restricted external/access write, G4 blocked.

Completed live proof:

- `Guided AI Labs / New Signal` Teams channel evidence exists.
- Microsoft Teams Power Automate connector is connected as
  `adamgoodwin@guidedailabs.com`.
- Live SharePoint-created-item to Teams alert flow is `Started`.
- CRM proof item `#19` produced one Teams post with a CRM link.
- Power Automate run succeeded; `Post_to_New_Signal_channel` returned
  `Created`.
- B2/B3 triage packet and similar-record advisory were generated.
- B4 wrote Agent Action Log row `#9` with status `Suggested`.
- B5 recorded the one-writer posture in Decision Register `#6` and Agent Action
  Log `#10`.
- B6 Guided AI Journey Form submission created CRM signal `#21`; verification
  passed, the source-specific Teams alert proof passed, and Agent Action Log
  `#11` was recorded as `Suggested`.
- B7 live proof completed the Journey -> M365 -> Journey CRM receipt loop for
  invite/admin/lifecycle signals. Final synthetic `portalEventId`:
  `db8d3f91-002b-4729-b6ac-556ee5813d3d`; final CRM record:
  `CRM - New Signals` item `#25`; final Journey status: `crm_received`.

B7 evidence:

- Live proof packet:
  `inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md`.
- M365 callback run:
  `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040557.json`.
- Journey ledger read-back:
  `inventory/m365-interaction-agent-b7/b7-journey-ledger-db8d3f91-002b-4729-b6ac-556ee5813d3d-20260626-040612.json`.
- Teams alert run:
  `inventory/forms-build/flow-runs-c54964d6-0042-430d-b542-90214e49224b-20260626-040647.json`.

## Build Sequence

| Chunk | Name | Governance lane | Primary output |
|---|---|---|---|
| B1 | New Signal Teams alert proof | Narrow approved internal flow proof | One CRM signal creates exactly one Teams post. |
| B2 | Signal triage packet | G0 local read/reason | Agent produces a useful triage packet for a new signal. |
| B3 | Similar-lead advisory | G0 local read/reason | Agent flags possible related CRM records without merging. |
| B4 | Agent Action Log suggested row | G1 propose/log | Agent writes one `Suggested` row for human review. |
| B5 | Durable permission decision | Decision Register | Adam chooses the real `m365-interaction-agent` posture. |
| B6 | Source expansion | Later G2/G3 per source | More inbound sources feed the same CRM -> agent lane. |
| B7 | Journey minimal signal + CRM receipt ack | Source ingress plus restricted external callback | Journey invite/admin signal creates CRM item, then M365 confirms receipt back to Journey dashboard. |
| B8 | Journey loop hardening | B8a G0/R0 complete; B8b G2/G3 live proof complete | First-class `portalEventId`/receipt state, idempotent replay, and pending cleanup plan. |
| B9 | Selected signal operating triage | B9a G0/R0 complete; B9b G0/G1 selected only | Run the proven triage/advisory path on selected CRM items and optionally record one Suggested row per approved item. |
| B10 | QUO inbound source proof | B10a G0/R0 complete; B10b G3 by exact source proof approval | Low-volume QUO call/SMS/voicemail events create or map CRM signals through the existing alert and triage lane as the first Phone / Voice / Text sensory portal. |

## Live Proof Record

Completed on 2026-06-25:

- CRM proof item: `CRM - New Signals` `#19`,
  `B1 New Signal Teams alert proof 20260625-161858`.
- Flow: `GAIL - New Signal Teams alert`,
  `c54964d6-0042-430d-b542-90214e49224b`, state `Started`.
- Teams proof: `Guided AI Labs / New Signal`, post observed at
  `2026-06-25 16:19 America/Edmonton`.
- B1 pass packet:
  `inventory/new-signal-alert/new-signal-alert-proof-20260625-162306.md`.
- Teams web evidence:
  `inventory/new-signal-alert/new-signal-teams-web-proof-20260625-161858.png`
  and `.txt`.
- B2/B3 packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-162403.md`.
- B4 applied packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-162436.md`.
- Agent Action Log row: `#9`, status `Suggested`.

Important boundary: this proof created one synthetic CRM signal, one internal
Teams post, and one `Suggested` log row. It did not update CRM fields, create
Planner/calendar work, send external messages, merge records, grant
permissions, or call QUO.

## Shared Rules

- Keep `CRM - New Signals` as the source of truth.
- Keep Teams as an internal attention surface, not the system of record.
- Keep the agent as one named capability set, not separate CRM, Teams, Planner,
  phone, and support bots.
- Keep M365 as the governed enterprise body and execution substrate, not the
  full executive brain or graph intelligence layer.
- Do not reuse `agent-pnp-provisioning` as production agent authority.
- Treat `Suggested` as not approved.
- Treat `Approved` as not executed.
- Treat completed flow/script output as unproven until read-back evidence exists.
- Do not merge, update, suppress, send, invite, share, grant, delete, or make
  client commitments without the matching approval gate.

## B1 - New Signal Teams Alert Proof

Objective:

Prove that the first few minutes are covered. When a new item is created in
`CRM - New Signals`, Adam sees an internal Teams alert quickly enough to triage
the opportunity.

Build:

- Ensure the internal Teams channel `Guided AI Labs / New Signal`.
- Create the standard Microsoft Teams Power Automate connector as
  `adamgoodwin@guidedailabs.com`.
- Create or update the flow:
  `CRM - New Signals` item created -> post to `New Signal` channel.
- Alert body includes source, priority, signal type, person, organization,
  need, created time, suggested first move, and CRM item link.
- Capture proof with one synthetic CRM signal and operator-observed Teams
  evidence.

Implementation artifacts:

- `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`
- `scripts/Start-M365NewSignalTeamsChannelInteractive.ps1`
- `scripts/Ensure-M365NewSignalTeamsChannel.ps1`
- `scripts/flow-builder/Start-FlowBuilder.ps1 -Phase new-signal`
- `scripts/flow-builder/create-new-signal-teams-flow.js`
- `scripts/Invoke-M365NewSignalAlertProof.ps1`
- `inventory/forms-build/new-signal-teams-channel.json`
- `inventory/forms-build/flow-result-new-signal-teams.json`
- `inventory/new-signal-alert/new-signal-alert-proof-<stamp>.md`
- `inventory/new-signal-alert/new-signal-alert-proof-<stamp>.json`
- `.local/flow-builder/capture/flow-create-new-signal-teams.json`

Acceptance:

- Channel evidence file exists and identifies the team/channel target.
- Teams connector exists and is connected as Adam.
- Flow exists, is `Started`, and uses the intended SharePoint list id.
- One synthetic test item in `CRM - New Signals` produces exactly one Teams
  post in `Guided AI Labs / New Signal`.
- Teams post links back to the CRM item.
- Evidence records test item title, item created time, Teams post time, flow run
  status, and whether duplicate posts occurred.

Stop conditions:

- Any external/prospect notification.
- Any app registration, admin consent, Graph permission grant, sharing change,
  guest access, delete, billing/client commitment, or QUO hookup.

## B2 - Signal Triage Packet

Objective:

Turn the alert into agent judgment. The M365 Interaction Agent should read a new
signal and produce a concise triage packet that helps Adam decide the first
move.

Build:

- Read the newest or selected `CRM - New Signals` item.
- Normalize the core fields:
  `Title`, `PersonName`, `PersonEmail`, `OrganizationName`, `SignalType`,
  `IntakeSource`, `Priority`, `SignalStatus`, `NeedSummary`, `SourceText`,
  `NextAction`, `FollowUpDueDate`, created time, modified time, and item link.
- Produce a local triage packet under
  `inventory/new-signal-triage/new-signal-triage-<stamp>.md`.
- Do not write back to SharePoint in this chunk.

Triage packet fields:

- source CRM item link;
- signal summary;
- apparent urgency;
- suggested first move;
- missing information;
- suggested owner;
- suggested follow-up due window;
- whether this should become qualification, nurture, support, referral, or
  close/no-fit;
- governance level for the next action;
- blocked actions and required approvals.

Suggested decision rules:

- `Priority = Urgent` or `High` means attention now.
- Missed call, voicemail, repeated inbound signal, or explicit deadline should
  be treated as time-sensitive by default.
- Website forms usually alert immediately but do not imply a promised response
  SLA until Adam defines one.
- Blank email or unclear organization increases triage uncertainty.
- Any external reply remains a draft/proposal only.

Implementation:

- `scripts/Invoke-M365NewSignalTriage.ps1` runs G0 first and produces local
  markdown/json packets.
- It supports `-ItemId`, `-Newest`, and `-InputJson` modes.
- It persists local digest/evidence before any B4/G1 write.
- Without `-Apply`, it does not update SharePoint, create tasks, send messages,
  merge records, or write Agent Action Log rows.

Acceptance:

- Given a known CRM signal, the agent produces a packet Adam can act on.
- Packet links to the CRM source item.
- Packet names the recommended first move and the missing info.
- Packet clearly states whether the next step is G0, G1, G2, G3, or G4.
- No tenant write occurs.

Stop conditions:

- Updating `NextAction`, `SignalStatus`, owner, follow-up date, or any CRM field.
- Creating Planner tasks or calendar reminders.
- Sending email, Teams chats, SMS, calls, or prospect replies.

## B3 - Similar-Lead Advisory

Objective:

Help Adam notice related or duplicate records without silently merging or
suppressing anything.

Build:

- Extend the triage packet with an advisory section:
  `Possible related CRM records`.
- Search existing CRM relationship surfaces:
  `CRM - New Signals`, `CRM - Organizations`, `CRM - Contacts`,
  `CRM - Engagements`, and `CRM - Touchpoints`.
- Score likely matches and provide links, confidence, and why each matched.
- Keep this advisory-only. The agent does not merge records, update lookups, or
  prevent a new signal from existing.

Match signals, strongest first:

- exact email match;
- exact phone match, when phone fields exist in a source;
- exact normalized organization name;
- email domain matching organization domain;
- close person name plus same organization;
- close organization name by normalized text;
- similar need/opportunity keywords;
- recent active engagement, open signal, or waiting-on-Adam item;
- same source link or same submitted text, if present.

Suggested scoring bands:

- High: exact email, exact phone, or exact org/domain plus same person.
- Medium: same organization/domain with similar need or recent active record.
- Low: fuzzy name/org or similar need only.

Packet output:

- `No obvious related records found`, or
- list of possible related records with source list, title, link, confidence,
  and reason.

Implementation:

- `scripts/Invoke-M365NewSignalTriage.ps1` now includes B3 by default.
- `-IncludeSimilar` defaults on for local G0 runs and live SharePoint reads.
- `-RelatedRecordsJson <path>` supports offline/local smoke tests without a
  tenant read.
- Raw match evidence is written to
  `inventory/new-signal-triage/new-signal-match-<stamp>.json`.
- Matching remains advisory-only and is included in the triage markdown/json
  packet under `Possible Related CRM Records`.

Acceptance:

- A signal with a known matching email flags the existing contact or signal.
- A signal with a known matching organization flags the existing organization.
- A signal with no plausible match says so plainly.
- Confidence reasons are understandable to Adam.
- No records are merged, suppressed, updated, deleted, or hidden.

Stop conditions:

- Automatic dedupe.
- Lookup conversion.
- Any record update.
- Any decision that a lead is "the same" without Adam review.

## B4 - Agent Action Log Suggested Row

Objective:

Give the agent a real but low-risk write lane. After B2/B3 produce useful
judgment locally, the agent can record one `Suggested` row for human review.

Build:

- Add an explicit `-Apply` mode to the triage path.
- Prompt for a single human confirmation before writing.
- Write one row to `Agent Action Log` with status `Suggested`.
- Do not mark the action approved, completed, executed, or verified.
- Refuse another Suggested row for the same CRM signal unless
  `-AllowDuplicateSuggestion` is explicitly supplied.

Current Agent Action Log fields to use:

- `Title`: short action title, such as
  `Triage new CRM signal - <person/org>`.
- `ActionDate`: current timestamp.
- `AgentSurface`: `Codex`.
- `ActionSource`: CRM item link.
- `ActionType`: `recommend` or `draft`.
- `ActionStatus`: `Suggested`.
- `HumanApprover`: blank unless Adam later approves in SharePoint.
- `Result`: triage summary, similar-record advisory, recommended first move,
  governance level, evidence path, and rollback/pause note.
- `CentralOSLink`: blank unless a future Freedom/Central OS record exists.
- `GraphNodeId`: blank unless a future bridge creates one.

Implementation:

- `scripts/Invoke-M365NewSignalTriage.ps1 -Apply` performs the B4 write.
- Without `-Apply`, the script previews the exact Suggested row and writes only
  local evidence.
- With `-Apply`, the script connects to SharePoint if needed, checks for an
  existing Suggested row referencing the same CRM item, asks for `Y` approval
  unless `-Approve` is supplied, and then writes one row only.
- The row result includes the triage summary, similar-record advisory,
  recommended first move, governance level, local evidence paths, and
  pause/rollback note.

Acceptance:

- One selected signal creates one `Suggested` row in Agent Action Log.
- Row appears in `Agent Action Log / Needs Review`.
- Row links back to the source CRM item.
- Row includes local evidence path.
- Suggested row is visibly not approved and not executed.

Stop conditions:

- Writing directly to CRM fields.
- Creating tasks or reminders.
- Sending messages.
- Running unattended.
- Writing more than one row per selected signal without Adam selecting that
  behavior.

## B5 - Durable Agent Permission Decision

Objective:

Choose the production posture for the real `m365-interaction-agent` after the
useful loop is proven, instead of letting delegated setup power become the
agent's permanent authority.

Local resume packet:

- `inventory/m365-interaction-agent-b5/B5_COMPETING_WRITER_AUDIT_2026-06-25.md`
  records the repo-visible competing writer audit, Adam's Prime Boiler
  clarification, recommended one-writer posture, source-ingress exceptions, and
  pause/revoke map. It is local-only and does not record a tenant Decision
  Register item.
- `inventory/m365-interaction-agent-b5/B5_DURABLE_PERMISSION_DECISION_2026-06-25.md`
  converts the B5 audit into a Decision Register-ready durable permission
  packet.
- `inventory/m365-interaction-agent-b5/decision-register-draft-b5-one-writer-20260625.csv`
  and `.json` hold import-ready draft values for the B5 Decision Register row.
- `scripts/Invoke-M365B5InteractionAgentDecision.ps1` records the B5 decision
  in dry-run-first mode and requires the exact B5 approval phrase before any
  live write.
- `scripts/Start-M365B5InteractionAgentDecisionInteractive.ps1` opens the same
  recorder in a visible interactive PowerShell window for account selection.
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-174036.json`
  and `.log` prove the recorder local-previewed the two intended rows without
  connecting to Microsoft 365.
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-175449.json`
  and `.log` prove the approved live recording created Decision Register `#6`
  and Agent Action Log `#10` as `adamgoodwin@guidedailabs.com`.

Decision packet must include:

- agent name;
- human owner;
- purpose;
- non-goals;
- exact read surfaces;
- exact write surfaces;
- blocked actions;
- proposed Microsoft permissions;
- identity/adapter approach;
- why narrower options are insufficient, if applicable;
- approval phrase;
- recorder command;
- revoke/disable path;
- review date;
- evidence location.

Options to compare:

- Keep G0/G1 delegated/manual for now.
- Use a narrowly scoped SharePoint/List adapter.
- Use SharePoint Selected permissions after explicit approval.
- Use a local/Freedom-style adapter that invokes M365 tools through a governed
  bridge.
- Defer app registration until more live value is proven.

Acceptance:

- Decision Register contains the selected posture or an explicit deferral.
- Tool Permission Review captures any app/tool scope under review.
- Rollback or revoke path is written before any app or selected permission
  grant.
- `agent-pnp-provisioning` remains setup-only.

Stop conditions:

- App registration.
- Admin consent.
- SharePoint Selected permission grant.
- Exchange Application RBAC.
- Broad Graph/Teams/Planner permission grant.
- Connector expansion beyond the already scoped New Signal proof.

## B6 - Source Expansion

Objective:

Feed more inbound signals into the same agent lane only after the CRM -> Teams
-> triage -> suggestion loop works.

Candidate sources:

- Guided AI Journey client-invite intake through the existing Journey
  Microsoft Form or website CTA/embed.
- Microsoft Bookings appointment events already feeding CRM.
- Support mailbox signals, after support MFA and mailbox adapter design.
- Manual CRM entries from Adam/operator.
- QUO calls, SMS, voicemail, and call summaries, queued for B10 after B8/B9.
- Future website or event/referral sources.

Build pattern:

```text
source event
-> verified ingress
-> CRM - New Signals item
-> New Signal Teams alert
-> M365 Interaction Agent triage
-> similar-lead advisory
-> Agent Action Log Suggested row when approved
```

Source-expansion packet for each source:

- source owner;
- event types;
- data captured;
- dedupe/advisory rules;
- source link or evidence location;
- expected latency;
- privacy/security notes;
- stop conditions;
- rollback or disable path;
- test proof.

Local B6 packet:

- `inventory/m365-interaction-agent-b6/B6_GUIDED_AI_JOURNEY_CLIENT_INTAKE_2026-06-25.md`
  records Guided AI Journey client-invite intake as the first source expansion
  through the existing create-only Form -> CRM -> triage lane.
- `scripts/Invoke-M365B6JourneyIntakeProof.ps1` prepares dummy Journey proof
  values locally and verifies the resulting CRM signal read-only after Form
  submission.
- `scripts/Start-M365B6JourneyIntakeProofInteractive.ps1` opens the B6 helper
  in a visible PowerShell window for account selection.
- `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-180736.md`
  and `.json` prove the B6 helper local-prepared the selected direct Journey
  Form proof without connecting to Microsoft 365.
- `inventory/m365-interaction-agent-b6/b6-journey-form-submission-20260626-001841.json`
  records the live Microsoft Form submission confirmation.
- `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-182051.md`
  and `.json` prove the resulting `CRM - New Signals` item `#21` passed the
  B6 shape checks.
- `inventory/new-signal-triage/new-signal-triage-20260625-182141.md` and
  `.json` prove the B2/B3 triage packet and G1 `Suggested` Agent Action Log
  row `#11`.
- `inventory/new-signal-alert/new-signal-alert-proof-20260625-184447.md` and
  `.json` prove CRM item `#21` produced exactly one observed internal Teams
  alert with CRM link text.

Selected first proof completed:

- Entry point: direct Journey Microsoft Form link.
- Marker: `GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY`.
- CRM item: `#21`
  (`Guided AI Journey — GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY`).
- Teams alert: one observed `Guided AI Labs / New Signal` post at
  `2026-06-25 18:19 America/Edmonton` with CRM link text.
- Agent Action Log: `#11`, status `Suggested`, boundary only; no CRM update,
  task, reminder, message, merge, permission, or external action.

QUO now has B10a local readiness complete. B10b live proof waits until:

- Adam chooses which QUO numbers and events count as business intake;
- Adam chooses the ingress option, secret/signature storage, payload retention,
  duplicate rule, and disable path;
- inbound-only behavior is approved for one no-real-client or internal event;
- outbound SMS/callback is explicitly blocked or separately approved in a later
  G3 decision.

Acceptance:

- New source creates or maps to a CRM signal.
- Existing New Signal alert fires once.
- Agent triage packet handles the source without a separate helper bot.
- No external auto-response occurs.
- Evidence proves source event, CRM item, Teams alert, and agent packet.

Stop conditions:

- Phone/SMS auto-reply.
- Prospect email send.
- Direct website-to-CRM POST route or tenant secret in a public website repo.
- Webhook secrets without a storage and revoke plan.
- Third-party automation without source owner and rollback.
- Any source that bypasses `CRM - New Signals`.

## B7 - Journey Minimal Signal And CRM Receipt Ack

Objective:

Let Guided AI Journey send a system signal when Adam invites a person, acts as
an admin for an organization, or saves a portal lifecycle event, then let M365
confirm back to the Journey dashboard after the CRM item exists.

Intended loop:

```text
Guided AI Journey invite/admin/lifecycle action
-> Journey saves Supabase transaction first
-> Journey writes crm_lifecycle_events row with stable portalEventId
-> Journey backend sends minimal system signal to M365
-> M365 creates CRM - New Signals item
-> New Signal Teams alert fires internally
-> M365 sends CRM receipt ack back to a fixed Journey dashboard endpoint
-> Journey dashboard marks the invite/lead as CRM received
```

Local B7 packet:

- `inventory/m365-interaction-agent-b7/B7_JOURNEY_MINIMAL_SIGNAL_ACK_CONTRACT_2026-06-25.md`
  records the contract, data-minimization rule, acknowledgement shape, and
  proof plan.
- `inventory/m365-interaction-agent-b7/journey-minimal-signal-ack-contract-20260625.json`
  provides the machine-readable contract.
- `inventory/m365-interaction-agent-b7/WINDOWS_TO_LINUX__journey-minimal-signal-ack-contract-20260625.md`
  is the original DirectLink handoff copy for the Journey/Linux side; it is now
  marked superseded by the Linux-proposed `portalEventId` handshake.
- `inventory/m365-interaction-agent-b7/WINDOWS_TO_LINUX__2026-06-25-m365-two-way-handshake-response.md`
  and `windows-to-linux-m365-two-way-handshake-response-20260625.json` answer
  the Linux/Journey questions and define the current v1 payload/ack shape.
- `scripts/New-M365B7JourneySignalAckPacket.ps1` generates a synthetic
  no-real-client test payload and expected acknowledgement packet locally.
- `scripts/flow-builder/create-http-intake-flow.js` now preserves optional
  Journey signal metadata in `SourceText`: schema version, signal mode, event
  type, `portalEventId`, correlation id, company/engagement/invite ids, Journey
  invite/org/lead ids, invite role, source action, portal deep link, event
  timestamp, and ack requested. If local ack endpoint/secret files exist, the
  builder can add a signed M365 -> Journey receipt action after `Create_item`.
- `scripts/flow-builder/http-intake-e2e.js` now includes Journey correlation
  and portal lifecycle metadata in the Journey happy-path test payload.

Slim signal principle:

- The invite/admin trigger is a system event, so it should ask the client
  nothing.
- Journey should send what it already knows: invite id, correlation id, email,
  name if known, organization if known, role/context, and a short lead context.
- Any later client-facing form should be separate and slim: prefilled
  name/email/org, one useful free-text prompt, one optional intent choice, and
  one consent checkbox when a human is submitting.

Completed live work:

- Journey confirmed `POST <<JOURNEY_ACK_ENDPOINT_SERVER_SIDE_ONLY>>`
  as the fixed server-side acknowledgement endpoint, `x-m365-ack-secret` as the
  header name, HTTP `200` as the success status, and a 15-minute dashboard
  pending timeout. M365 does not call a callback URL supplied inside the inbound
  payload.
- M365 read-only verified the custom HTTP intake flow state as `Started` on
  2026-06-25, with evidence in
  `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-032732.json`.
- Journey production was deployed with the server-side ack secret outside git.
- The M365 custom HTTP intake flow was updated to send a signed post-create CRM
  receipt callback.
- The no-real-subject proof created one CRM item, sent the acknowledgement, and
  Journey read back `crm_received`.
- The follow-on lead-source display proof added `Lead source detail` to CRM
  provenance and Teams alerts.

Final no-real-subject proof:

```text
portalEventId: db8d3f91-002b-4729-b6ac-556ee5813d3d
crmItemId: 25
journeyStatus: crm_received
teamsAlert: posted successfully
proof: inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md
realClientSubject: no
```

Lead-source display proof:

```text
portalEventId: journey-portal-event-1782447883236
crmItemId: 27
leadSourceDetail: Journey admin invite
teamsAlert: posted successfully with lead-source row
proof: inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md
realClientSubject: no
```

Acceptance result:

- Journey dashboard records the test invite/admin signal.
- M365 creates exactly one `CRM - New Signals` item with
  `IntakeSource = Guided AI Journey`.
- CRM `SourceText` contains the portal event id, correlation id, and Journey
  invite id.
- The New Signal Teams alert appears once.
- M365 ack callback updates Journey dashboard to `crm_received`.
- Result: pass for the internal no-real-subject proof.

M365-side answer to Linux/Journey questions:

- Current flow builder stores `portalEventId` in CRM `SourceText`; B8 evaluates
  first-class SharePoint storage for dedupe/read-back.
- The builder calls the signed ack endpoint after item creation only when the
  local endpoint/secret files exist. Secret values stay in `.local` or
  production server-side stores, not git or DirectLink.
- Safe return fields are the CRM item id, display-form URL, title, status,
  priority, and optional Power Automate run id.
- Keep v1 lifecycle events in `CRM - New Signals` to reuse the proven alert and
  triage lane. Consider a dedicated lifecycle ledger later if these become
  operational-history events rather than new-work signals.
- Include now: `portalEventId`, `eventType`, `companyId`, `engagementId`,
  `inviteId`, `sourceAction`, `eventTimestamp`, `portalDeepLink`, and
  `leadContext`.

Stop conditions:

- Browser-side intake secret or ack secret.
- Callback URL accepted from an inbound payload.
- Real client invite used for a proof without explicit selection.
- CRM update, merge, task, external reply, guest invite, or permission change.
- Any signal path that bypasses `CRM - New Signals`.

## B8 - Journey Loop Hardening

Objective:

Turn the live Journey receipt loop into a small operating system: easy to
dedupe, easy to read back, and recoverable when a Journey event is stuck at
`crm_failed_or_timed_out`.

Execution status - 2026-06-27:

- B8a local-only hardening packet generated. No Microsoft 365 connection, HTTP
  send, CRM write, flow update, secret read, or Journey callback was performed.
- B8b live schema/flow/replay proof completed after Adam approved the exact
  scope in a visible approval window. Proof packet:
  `inventory/m365-interaction-agent-b8/B8B_LIVE_PROOF_2026-06-27.md`.
- Indexed `PortalEventId` and `SourceCorrelationId` fields now exist on
  `CRM - New Signals`.
- The live HTTP intake flow now performs a pre-create lookup by `PortalEventId`.
  A replay of the same event returns the existing CRM item path and does not
  create a duplicate signal.
- B8b synthetic/internal Journey replay proof used portal event
  `0dd7d7e8-3aba-43cc-9024-8250fbd7a4ca`; the first post created CRM item
  `#32`, and the replay left the CRM count at one.
- Config:
  `config/M365_INTERACTION_AGENT_B8_JOURNEY_LOOP_HARDENING.json`.
- Packet:
  `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.md`.
- Summary JSON:
  `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.json`.
- Packet generator:
  `scripts/New-M365B8JourneyLoopHardeningPacket.ps1`.
- Read-only lookup helper
  `scripts/flow-builder/find-crm-signal.js` is now B8-aware: it can use
  first-class `PortalEventId` / `SourceCorrelationId` fields when present, and
  falls back to current `SourceText` metadata scanning while those fields are
  absent.
- Recommended default: add `PortalEventId` and `SourceCorrelationId`; defer
  `ReceiptStatus` until operators need CRM-local receipt state.
- Duplicate/replay rule: one existing match returns the existing CRM item id/url
  to Journey without creating a new CRM item; zero matches creates one item and
  acks receipt; more than one match stops for Adam review. Compatibility note:
  the Journey receiver currently accepts the B7 receipt shape, so the
  existing-item branch keeps the receiver-compatible `crmStatus` value while
  returning the existing CRM item id/url and message.
- Live approval phrase consumed for B8b:
  `approve-b8-journey-loop-hardening-live-update-20260627`.

Scope:

- Keep `CRM - New Signals` as the source of truth for new-work signals.
- Keep the Journey ledger as the source of truth for portal event state.
- Add first-class storage only where it improves dedupe, read-back, or operator
  recovery.
- Treat any further schema, flow-update, cleanup, backfill, or replay write as a
  fresh approval gate.

Build:

- SharePoint schema change for first-class `portalEventId` storage is complete.
  Candidate fields:
  - `PortalEventId` as a single-line text column;
  - `SourceCorrelationId` as a single-line text column;
  - `ReceiptStatus` or equivalent only if CRM needs local receipt state rather
    than deriving it from Journey.
- HTTP intake flow update is complete: Journey metadata still lands in
  `SourceText`, and approved first-class fields are populated directly.
- Pre-create idempotency rule is complete: replaying the same `portalEventId`
  must not silently create duplicate work.
- Decide whether duplicate handling should:
  - return the existing CRM item id to Journey;
  - create a new Agent Action Log advisory;
  - or stop and require Adam review.
- Define a Journey operator retry/replay action for
  `crm_failed_or_timed_out` that reuses the same `portalEventId`.
- Define a no-delete cleanup policy for older synthetic pending rows: mark,
  backfill, or leave with an evidence note.
- Record expected evidence paths before any live flow update or replay test.

Acceptance:

- B8a local packet names exact fields, duplicate policy, replay policy, cleanup
  policy, evidence paths, stop conditions, and the live approval phrase.
- B8b proof shows a Journey event can be found from `portalEventId` without
  scraping long notes.
- B8b proof shows replaying the same `portalEventId` does not create an
  unreviewed duplicate CRM signal.
- A failed or timed-out Journey CRM receipt can now be retried by an operator
  with an evidence trail.
- Existing B7 proof behavior still works: CRM item created, Teams alert posted,
  and Journey receives `crm_received`.
- No secret value is committed to git, DirectLink, docs, or inventory.

Stop conditions:

- SharePoint schema changes without Adam's explicit approval.
- Live flow update without approval, rollback note, and evidence target.
- Browser-side secret exposure.
- Callback URL accepted from inbound payload.
- Automatic CRM merge, delete, or suppression.
- Real client replay test before the synthetic replay path passes.
- Any additional B8 write, replay, cleanup, or backfill without a fresh
  approval boundary.

## B9 - Selected Signal Operating Triage

Objective:

Use the proven triage/advisory/Suggested-row lane on selected CRM items so the
agent starts helping with real operating judgment, without becoming unattended
automation.

Local execution status - 2026-06-27:

- B9a local-only operating packet generated. No Microsoft 365 connection, live
  tenant read, CRM write, Agent Action Log write, flow update, HTTP send, or
  secret read was performed.
- Config:
  `config/M365_INTERACTION_AGENT_B9_SELECTED_SIGNAL_OPERATING_TRIAGE.json`.
- Packet:
  `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.md`.
- Summary JSON:
  `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.json`.
- Queue template:
  `inventory/m365-interaction-agent-b9/b9-selected-signal-queue-20260627-093338.csv`.
- Review template:
  `inventory/m365-interaction-agent-b9/b9-operating-review-20260627-093338.csv`.
- Packet generator:
  `scripts/New-M365B9SelectedSignalOperatingTriagePacket.ps1`.
- Seed evidence indexes prior B1 CRM item `#19` and B6 Journey CRM item `#21`
  as packet-shape examples only; both already have prior Suggested rows and
  should not be duplicated unless Adam explicitly approves a superseding row.

Build:

- Adam selects one or more CRM item ids, source types, or a narrow time window.
- Run G0 triage first: local packet, similar-record advisory, missing-info
  summary, recommended first move, and governance level.
- Compare the packet against what Adam would actually do and tune only the
  decision rules that are visibly useful.
- If Adam approves, write one G1 `Suggested` Agent Action Log row for the
  selected item.
- Preserve the duplicate guard: no second Suggested row for the same source
  item unless Adam explicitly chooses that behavior.
- Keep a small operating note that distinguishes:
  - useful triage;
  - noisy or premature recommendation;
  - missing field/data issue;
  - source-ingress problem;
  - future automation candidate.

Acceptance:

- B9a local packet names the operating routine, selection policy, review labels,
  duplicate policy, evidence paths, and stop conditions.
- Queue and review CSV templates exist for selected-signal operation.
- Selected real or internal CRM items produce useful local packets.
- The packet identifies the source, the likely first move, related-record
  advisory, missing info, and blocked actions.
- Any Agent Action Log write remains `Suggested`, linked to evidence, and not
  approved or executed.
- The routine can be stopped after G0 with no tenant write.

Stop conditions:

- Unattended or broad scanning.
- Writing CRM fields, tasks, reminders, or messages.
- External replies, calls, SMS, or client commitments.
- Treating the advisory match as automatic dedupe.
- Using old proof approvals as permission for new live writes.

## B10 - QUO Inbound Source Proof

Objective:

Bring QUO into the same CRM -> Teams -> triage lane while call volume is low,
so phone/SMS/voicemail signals are governed before they become urgent operating
load.

Local execution status - 2026-06-27:

- B10a local-only source proof readiness packet generated. No QUO connection,
  Microsoft 365 connection, CRM write, Teams post, flow update, HTTP send,
  `.local` secret read, or outbound phone/SMS action was performed.
- Config:
  `config/M365_INTERACTION_AGENT_B10_QUO_INBOUND_SOURCE_PROOF.json`.
- Packet:
  `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`.
- Summary JSON:
  `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.json`.
- Event mapping:
  `inventory/m365-interaction-agent-b10/b10-quo-event-mapping-20260627-094929.csv`.
- Live decision worksheet:
  `inventory/m365-interaction-agent-b10/b10-quo-live-decision-worksheet-20260627-094929.csv`.
- Proof checklist:
  `inventory/m365-interaction-agent-b10/b10-quo-proof-checklist-20260627-094929.csv`.
- Packet generator:
  `scripts/New-M365B10QuoInboundSourceProofPacket.ps1`.
- Future live approval phrase prepared, not consumed:
  `approve-b10-quo-inbound-source-proof-20260627`.

Position:

- QUO is later than B8/B9 because the Journey loop should be recoverable and
  the selected-signal triage routine should be familiar first.
- QUO is not much later than that. It should be the next source proof before
  broad G2 internal writes, support mailbox adapters, Copilot custom actions,
  or other source expansions.

Inbound-only MVP:

- Approved QUO number(s) only.
- Approved event classes only:
  - inbound SMS or conversation message;
  - missed call;
  - voicemail;
  - completed call summary or transcript, if available and approved.
- Create or map to a `CRM - New Signals` item with `IntakeSource = QUO`.
- Use `SignalType` values such as `Phone`, `SMS`, `Voicemail`, or
  `Call Summary`.
- Preserve caller/contact details, QUO conversation/call link, event timestamp,
  and source event id when available.
- Default missed calls and voicemails to at least `High` until Adam chooses a
  more nuanced rule.
- Let the existing New Signal Teams alert and B2/B3 triage lane do the rest.

Design decisions before any live QUO hookup:

- Which QUO number(s) count as business intake.
- Which event classes create new CRM signals versus append/advisory only.
- Whether the first proof uses manual bridge, no-code webhook bridge, or a
  purpose-built signed ingress adapter.
- Signature verification and secret storage/revoke plan.
- Raw payload evidence location and retention.
- Duplicate window and idempotency rule.
- Disable/pause path if the source gets noisy.

Acceptance:

- B10a local packet names event classes, ingress options, normalized CRM shape,
  duplicate rule, raw payload policy, disable path, evidence targets, stop
  conditions, and the future approval phrase.
- Event mapping, live decision worksheet, and proof checklist CSVs exist.
- One no-real-client QUO test event creates or maps exactly one CRM signal.
- Existing New Signal Teams alert posts once.
- Triage packet handles the QUO source without a separate helper bot.
- No automatic SMS reply, callback, external message, or client commitment
  occurs.
- Evidence proves source event, normalized CRM item, Teams alert, triage packet,
  and rollback/pause path.

Stop conditions:

- Automatic SMS reply or callback.
- Outbound QUO API send.
- Real customer call/SMS proof before the synthetic or internal proof passes.
- Webhook/API secret without storage and revoke plan.
- Third-party automation without named owner and disable path.
- Any QUO path that bypasses `CRM - New Signals`.

## Recommended Execution Order

Completed baseline:

1. B1 created and proved the New Signal Teams alert lane.
2. B2/B3 generated local G0 triage and similar-record advisory.
3. B4 created one G1 `Suggested` Agent Action Log row.
4. B5 recorded the durable one-writer posture in Decision Register `#6` and
   Agent Action Log `#10`.
5. B6 recorded the direct Journey source proof with CRM item `#21`, Teams alert
   proof, and Agent Action Log `#11` as `Suggested`.
6. B7 proved the Journey -> M365 -> Journey CRM receipt loop with CRM item `#25`
   and Journey status `crm_received`.
7. Lead-source display proof recorded CRM item `#27` with
   `Lead source detail: Journey admin invite`.
8. B8a local Journey hardening packet is complete.
9. B8b live Journey loop hardening proof is complete.
10. B9a local selected-signal operating packet, queue template, and review
   template are complete.
11. B10a local QUO inbound source proof packet, event mapping, live decision
    worksheet, and proof checklist are complete.

Next sequence:

1. B9a local selected-signal operating packet is complete; B9b runs selected
   read-only triage only after Adam chooses item ids, source, or window.
2. B10a local QUO readiness packet is complete; B10b brings QUO in live only
   after exact proof approvals.

## Immediate Next Work

Local B5 packet/recorder work, live B5 recording, B6 source-ingress proof, B6
CRM verification, source-specific Teams alert proof, read-only triage, the
approved G1 Suggested row, B7 callback proof, and B7 lead-source display proof
are now done. Do not rerun any follow-on Suggested-row write or live flow update
without a fresh approval; the existing B6 Suggested row is Agent Action Log
`#11`.

B8b live Journey loop hardening is executed. It added first-class
`PortalEventId` / `SourceCorrelationId` storage, updated the HTTP intake flow
for idempotency, and proved one synthetic/internal replay without creating a
duplicate CRM item. Any further SharePoint schema change, flow update, replay
test, cleanup/backfill, Agent Action Log write, or other tenant write requires
fresh approval for scope, target, evidence, rollback, and the matching approval
phrase. That approval should be captured in a visible window launched with
`scripts/Start-M365InteractionAgentApprovalWindow.ps1` so Adam can see the exact
interaction surface before the live chunk begins.

B9a local operating readiness is executed. The next B9 tenant touch is a
selected G0 read-only triage run after Adam chooses exact CRM item id(s), source,
or window. A G1 Suggested row remains a separate per-item approval and does not
approve or execute the recommendation.

B10a local QUO readiness is executed. The next B10 tenant/source touch is B10b:
one selected no-real-client or internal QUO event through an approved ingress
path, only after Adam names the QUO number(s), event class, ingress option,
secret/signature storage and revoke path, raw payload retention/redaction rule,
duplicate rule, owner/disable path, evidence target, and outbound block. B10b
still allows no automatic SMS reply, callback, outbound QUO API send, real
customer proof, CRM merge/delete/suppression, or external commitment. Broader
write-capable automation, support mailbox adapters, and custom Copilot actions
remain later.

```text
Prime Boiler separated from Guided AI Labs
-> B5 recorded in Decision Register #6 and Agent Action Log #10
-> B6 direct Journey Form proof packet prepared
-> B6 Journey Form submitted live
-> CRM - New Signals #21 verified
-> B6 Teams alert observed once
-> B6 B2/B3 triage packet
-> Agent Action Log #11 recorded as Suggested
-> B7 minimal Journey invite/admin signal contract staged
-> Linux/Journey side proposed portalEventId handshake
-> M365 local builder updated for portalEventId + optional signed ack
-> Journey/Linux side exact ack endpoint origin/secret-header confirmation
-> Adam approved live callback build
-> M365 receiver state verified Started
-> M365 receiver updated with ack action
-> internal B7 proof
-> B7 lead-source display proof
-> B8a local Journey loop hardening packet
-> B8b live Journey loop hardening proof
-> B9a local selected-signal operating packet
-> B9b selected G0/G1 operating triage after item selection
-> B10a local QUO inbound source proof packet
-> B10b live QUO inbound source proof after exact approval
```

Read-only evidence to review first:

```powershell
git status --short
Get-Content inventory\forms-build\flow-result-new-signal-teams.json
Get-Content inventory\new-signal-alert\new-signal-alert-proof-20260625-162306.md
Get-Content inventory\new-signal-triage\new-signal-triage-20260625-162436.md
Get-Content inventory\m365-interaction-agent-b7\B7_LIVE_PROOF_2026-06-25.md
Get-Content inventory\m365-interaction-agent-b7\B7_LEAD_SOURCE_PROOF_2026-06-25.md
```

For a read-only smoke test against the newest CRM signal:

```powershell
pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -Newest
```

For a local/offline B3 test, provide a signal JSON plus a related-record corpus:

```powershell
pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -InputJson <signal.json> -RelatedRecordsJson <related-records.json>
```

## Boxed Boundary

The next build is not a general automation expansion. It is a narrow sequence
that makes the M365 Interaction Agent useful while keeping the control plane
honest:

```text
alert fast
reason clearly
flag related records
log suggestions
earn durable permission
harden receipt/replay
exercise selected operating triage
then add QUO as the next inbound source
```

QUO stays behind the B8/B9 guardrails, but it should be brought in while call
volume is low enough to prove calmly.
