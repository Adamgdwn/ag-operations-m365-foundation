# M365 Interaction Agent Next Build Chunks

Date: 2026-06-25

Status: B1-B4 live proof completed on 2026-06-25, then paused by Adam while
separate Prime Boiler 365 setup work was happening under another account. Adam
clarified that the Guided AI Labs `New Signal` path remains canonical for this
repo. The first lane now has a live Teams channel, standard Teams Power
Automate connector, started SharePoint-to-Teams flow, synthetic CRM proof item,
Teams post evidence, B2/B3 triage packet, similar-record advisory, and one B4
`Suggested` Agent Action Log row. The B5 local audit and durable permission
decision were recorded live on 2026-06-25 as Decision Register item `#6` and
Agent Action Log item `#10`. B6 Guided AI Journey direct Form proof is now live:
the Microsoft Form was submitted on 2026-06-25 at 18:18 MDT, the create-only
Journey flow created `CRM - New Signals` item `#21`, verification passed, Teams
web proof found exactly one `Guided AI Labs / New Signal` post for item `#21`,
and Adam's G1 approval recorded Agent Action Log `#11` as `Suggested`. B7 is
now live and proved as the Guided AI Journey minimal invite/admin signal plus
CRM receipt acknowledgement loop. Journey production is deployed with
`POST /api/crm/lifecycle/ack`, Vercel production has the server-side ack
secret, and the M365 custom HTTP intake flow now sends a signed post-create
receipt callback. Synthetic portal event
`db8d3f91-002b-4729-b6ac-556ee5813d3d` created `CRM - New Signals` item `#25`,
the M365 callback action succeeded, Journey read back `crm_received`, and the
New Signal Teams alert flow posted successfully. Follow-on source display proof
on 2026-06-25/26 added `Lead source detail` to CRM provenance and Teams alerts:
direct synthetic Journey source event `journey-portal-event-1782447883236`
created CRM item `#27` with `Lead source detail: Journey admin invite`, and the
patched Teams alert flow posted successfully.

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
```

This is a build plan, not standing approval for tenant writes. Each live write,
connector, app, permission, external send, or source expansion still needs its
own approval boundary.

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
- QUO calls, SMS, voicemail, and call summaries, still parked until selected.
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

QUO remains parked until:

- B1 through B4 are proven;
- Adam chooses which QUO numbers and events count as business intake;
- inbound-only behavior is approved;
- outbound SMS/callback is explicitly blocked or separately approved.

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

Open live work:

- Journey confirmed `POST https://www.guidedaijourney.com/api/crm/lifecycle/ack`
  as the fixed server-side acknowledgement endpoint, `x-m365-ack-secret` as the
  header name, HTTP `200` as the success status, and a 15-minute dashboard
  pending timeout. M365 must not call a callback URL supplied inside the inbound
  payload.
- M365 read-only verified the custom HTTP intake flow state as `Started` on
  2026-06-25, with evidence in
  `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-032732.json`.
- M365 must build/enable the outbound CRM receipt callback flow only after the
  Journey production deploy readiness checks pass and the real ack secret is
  stored locally. Adam has approved the live callback build; do not use a
  placeholder secret.

No-real-subject proof:

```text
portalEventId: GAIL-B7-PORTAL-EVENT-20260625
correlationId: GAIL-B7-PORTAL-EVENT-20260625
companyId: journey-company-internal-walkthrough
engagementId: journey-engagement-internal-walkthrough
journeyInviteId: journey-invite-test-20260625
name: GAIL INTERNAL CRM ACK TEST
email: adam+journey-crm-ack-20260625@guidedailabs.com
organization: Guided AI Labs Internal Walkthrough
```

Acceptance:

- Journey dashboard records the test invite/admin signal.
- M365 creates exactly one `CRM - New Signals` item with
  `IntakeSource = Guided AI Journey`.
- CRM `SourceText` contains the portal event id, correlation id, and Journey
  invite id.
- The New Signal Teams alert appears once.
- M365 ack callback updates Journey dashboard to `crm_received`.

M365-side answer to Linux/Journey questions:

- Current flow builder can store `portalEventId` in CRM `SourceText` now; a
  first-class SharePoint column is a later schema chunk if strict dedupe becomes
  necessary.
- The builder can call the signed ack endpoint after item creation, but only
  when `.local/flow-builder/journey-crm-ack-endpoint.txt` and
  `.local/flow-builder/journey-crm-ack-secret.txt` exist. Adam has approved the
  live callback build; the remaining gate is real secret plus deployed endpoint,
  not human approval.
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
- Real client invite used for the first proof.
- CRM update, merge, task, external reply, guest invite, or permission change.
- Any signal path that bypasses `CRM - New Signals`.

## Recommended Execution Order

Completed before pause:

1. B1 created and proved the New Signal Teams alert lane.
2. B2/B3 generated local G0 triage and similar-record advisory.
3. B4 created one G1 `Suggested` Agent Action Log row.

Current resume state:

1. Prime Boiler 365 setup is separated from the Guided AI Labs M365
   lane.
2. B5 permission decision evidence is recorded: Decision Register `#6` and Agent
   Action Log `#10`.
3. B6 direct Journey Form proof is recorded: `CRM - New Signals` `#21` and
   Agent Action Log `#11` as a G1 `Suggested` row.
4. Source-specific Teams alert observation for CRM item `#21` is recorded:
   exactly one `Guided AI Labs / New Signal` post with CRM link text.
5. B7 local Journey minimal signal and CRM receipt acknowledgement contract is
   staged and ready for DirectLink handoff.

## Immediate Next Work

Local B5 packet/recorder work, live B5 recording, B6 source-ingress proof, B6
CRM verification, source-specific Teams alert proof, read-only triage, and the
approved G1 Suggested row are now done. Do not rerun any follow-on
Suggested-row write without a fresh approval; the existing B6 Suggested row is
Agent Action Log `#11`.

The immediate next work is B7: wait for Linux/Journey to report production
readiness for the ack endpoint and generate one real synthetic `portalEventId`,
then store the real ack secret locally, update the M365 custom HTTP receiver
with the ack action, and run one internal no-real-subject proof.

```text
Prime Boiler separated from Guided AI Labs
-> exact writer/surface inventory
-> one-writer or split-surface decision
-> revoke/disable path
-> durable m365-interaction-agent permission posture
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
-> M365 local endpoint/header prepared; ack secret pending
-> Journey implementation built and locally validated; production deploy pending
-> M365 receiver state verified Started
-> Journey/Linux side production deploy readiness
-> M365 receiver updated with ack action
-> internal B7 proof
```

Read-only evidence to review first:

```powershell
git status --short
Get-Content inventory\forms-build\flow-result-new-signal-teams.json
Get-Content inventory\new-signal-alert\new-signal-alert-proof-20260625-162306.md
Get-Content inventory\new-signal-triage\new-signal-triage-20260625-162436.md
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
then add more sources
```

While paused, "earn durable permission" includes proving that this repo is not
competing with the separate Prime Boiler account/session lane.
