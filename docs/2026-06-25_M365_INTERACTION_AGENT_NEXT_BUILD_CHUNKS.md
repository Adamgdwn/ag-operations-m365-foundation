# M365 Interaction Agent Next Build Chunks

Date: 2026-06-25

Status: B1-B4 live proof completed on 2026-06-25, then paused by Adam because
two agents are writing to M365 accounts and competing. The first lane now has a
live Teams channel, standard Teams Power Automate connector, started
SharePoint-to-Teams flow, synthetic CRM proof item, Teams post evidence,
B2/B3 triage packet, similar-record advisory, and one B4 `Suggested` Agent
Action Log row. B5 is the next build gate after a competing-writer audit.

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

- Adam has two agents writing to M365 accounts, and they are competing.
- The next session should resume only when Adam can focus on this lane and
  confirm which agent owns which M365 write surface.

What is already live:

- `Guided AI Labs / New Signal` Teams channel exists.
- Microsoft Teams Power Automate connector exists as
  `adamgoodwin@guidedailabs.com`.
- Flow `GAIL - New Signal Teams alert`
  (`c54964d6-0042-430d-b542-90214e49224b`) is `Started`.
- The flow may continue posting internal Teams alerts for new
  `CRM - New Signals` items unless Adam disables it in Power Automate.

What not to run during the pause:

- `scripts/Invoke-M365NewSignalAlertProof.ps1 -Apply`.
- `scripts/Invoke-M365NewSignalTriage.ps1 ... -Apply`.
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
- Run `scripts/Invoke-M365NewSignalTriage.ps1` only without `-Apply` if Adam
  explicitly wants a read-only packet; otherwise leave M365 untouched.

First resume action:

1. Identify the other M365-writing agent and its live write surfaces.
2. Decide whether this repo's M365 agent lane is the only writer, or whether
   surfaces are intentionally split.
3. Record that decision in B5 before expanding permissions or source inputs.
4. Only then continue B5/B6.

## Current Starting Point

Already live or verified:

- `Guided AI Labs - Get started` Microsoft Form.
- `Guided AI Journey - Get started` Microsoft Form.
- Both Forms create items in the same `CRM - New Signals` list.
- `CRM - New Signals` is the source of truth for new opportunities and signals.
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

Still pending:

- Durable B5 permission decision for the real `m365-interaction-agent` posture,
  including the competing-writer boundary.
- B6 source expansion after B5 decides the agent identity/adapter boundary.

## Build Sequence

| Chunk | Name | Governance lane | Primary output |
|---|---|---|---|
| B1 | New Signal Teams alert proof | Narrow approved internal flow proof | One CRM signal creates exactly one Teams post. |
| B2 | Signal triage packet | G0 local read/reason | Agent produces a useful triage packet for a new signal. |
| B3 | Similar-lead advisory | G0 local read/reason | Agent flags possible related CRM records without merging. |
| B4 | Agent Action Log suggested row | G1 propose/log | Agent writes one `Suggested` row for human review. |
| B5 | Durable permission decision | Decision Register | Adam chooses the real `m365-interaction-agent` posture. |
| B6 | Source expansion | Later G2/G3 per source | More inbound sources feed the same CRM -> agent lane. |

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
- Webhook secrets without a storage and revoke plan.
- Third-party automation without source owner and rollback.
- Any source that bypasses `CRM - New Signals`.

## Recommended Execution Order

Completed before pause:

1. B1 created and proved the New Signal Teams alert lane.
2. B2/B3 generated local G0 triage and similar-record advisory.
3. B4 created one G1 `Suggested` Agent Action Log row.

Resume order:

1. Confirm the competing M365-writing agent is paused, separated, or explicitly
   coordinated.
2. Record B5 permission decision after the agent has proved it is worth
   granting durable power.
3. Start B6 with one source at a time, using the same CRM signal lane.

## Immediate Next Work

Pause here.

Do not continue B1-B4 setup or proof commands during the pause. The immediate
next work is a B5 resume review:

```text
competing M365 write agents
-> exact writer/surface inventory
-> one-writer or split-surface decision
-> revoke/disable path
-> durable m365-interaction-agent permission posture
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
competing with another live M365-writing agent.
