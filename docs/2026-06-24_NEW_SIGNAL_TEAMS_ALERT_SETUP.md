# New Signal Teams Alert Setup

Date: 2026-06-24

Status: live B1-B4 proof completed on 2026-06-25, then paused by Adam because
two agents are writing to M365 accounts and competing. The New Signal Teams
alert lane is active for `CRM - New Signals` creates, with proof evidence
captured for synthetic CRM item `#19`.

Purpose:

- Notify Adam/operator in Teams within the first few minutes when a new
  `CRM - New Signals` item is created.
- Keep `CRM - New Signals` as the source of truth.
- Treat this as the first notification capability of the single
  `M365 Interaction Agent`, not a separate notification bot.

Boundary:

- Internal Teams post only.
- No email sends.
- No external/prospect notification.
- No QUO hook.
- No guest access, sharing, permissions, tenant policy, app registration, admin
  consent, deletes, billing, or client commitment changes.
- During the 2026-06-25 pause, do not rerun setup, proof, connector, flow, or
  `-Apply` commands from this runbook unless Adam explicitly resumes this lane
  and confirms the competing M365 writer is paused, separated, or coordinated.

## Pause Handover - 2026-06-25

The setup is no longer waiting on B1-B4. It is waiting on focus and write-owner
clarity.

Already proven:

- `Guided AI Labs / New Signal` exists and is visible.
- Teams connector is connected as `adamgoodwin@guidedailabs.com`.
- Flow `GAIL - New Signal Teams alert`
  (`c54964d6-0042-430d-b542-90214e49224b`) is `Started`.
- Synthetic CRM proof item `#19` produced exactly one observed Teams post.
- B2/B3 triage evidence exists.
- B4 Agent Action Log row `#9` exists with status `Suggested`.

Leave alone during pause:

- Do not create more synthetic CRM proof items.
- Do not rerun the flow builder.
- Do not create or update connectors.
- Do not run triage with `-Apply` or `-Approve`.
- Do not disable the live alert flow from this repo unless Adam explicitly asks
  for a quiet/disable action. This closeout did not turn it off.

Resume gate:

1. Identify the competing M365-writing agent.
2. Decide whether the New Signal flow remains the only writer for CRM-created
   Teams alerts.
3. Decide whether this repo's agent may continue writing only G1 `Suggested`
   rows, or whether all writes should move to one other agent.
4. Record that in B5 before B6 source expansion.

## Setup Sequence

This sequence is historical/resume reference. Do not run it while the
2026-06-25 pause is active.

0. Resume check:

```powershell
Test-Path inventory\forms-build\new-signal-teams-channel.json
```

If the file exists, read it before creating anything:

```powershell
Get-Content inventory\forms-build\new-signal-teams-channel.json
```

If a visible "New Signal Teams channel setup" PowerShell window is still open
from 2026-06-24, finish or close that window before rerunning the launcher.

1. Ensure the internal Teams channel exists:

```powershell
pwsh -File scripts\Start-M365NewSignalTeamsChannelInteractive.ps1 -Apply
```

In the visible window, sign in as `adamgoodwin@guidedailabs.com` if prompted and
type:

```text
create-new-signal-channel
```

Expected evidence:

- `inventory/forms-build/new-signal-teams-channel.json`
- `inventory/new-signal-alert/new-signal-teams-channel-<stamp>.log`

2. Create the standard Teams connector connection for Power Automate:

```powershell
pwsh -File scripts\flow-builder\Start-FlowBuilder.ps1 -Phase connections -Only teams
```

Use the visible browser window to create/approve the Microsoft Teams connector
as `adamgoodwin@guidedailabs.com`.

3. Dry-run the flow body:

```powershell
pwsh -File scripts\flow-builder\Start-FlowBuilder.ps1 -Phase new-signal -Dry
```

Expected evidence:

- `.local/flow-builder/capture/flow-body-new-signal-teams.json`

4. Create or update the live flow:

```powershell
pwsh -File scripts\flow-builder\Start-FlowBuilder.ps1 -Phase new-signal -State Started
```

Expected evidence:

- `inventory/forms-build/flow-result-new-signal-teams.json`
- `.local/flow-builder/capture/flow-create-new-signal-teams.json`

5. Prove the alert:

```powershell
pwsh -File scripts\Invoke-M365NewSignalAlertProof.ps1 -Apply
```

The proof script creates one synthetic `CRM - New Signals` item only after the
typed approval phrase `create-new-signal-proof-item`. It then prompts for the
operator-observed Teams evidence:

- exact Teams post count for the proof title;
- whether the Teams post includes the CRM item link;
- Teams post time;
- optional Teams post/channel URL;
- optional Power Automate run status;
- duplicate or error notes.

Expected evidence:

- `inventory/new-signal-alert/new-signal-alert-proof-<stamp>.md`
- `inventory/new-signal-alert/new-signal-alert-proof-<stamp>.json`

6. Produce the B2/B3 triage packet for the proven CRM signal:

```powershell
pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -ItemId <proof item id>
```

Expected evidence:

- `inventory/new-signal-triage/new-signal-triage-<stamp>.md`
- `inventory/new-signal-triage/new-signal-triage-<stamp>.json`
- `inventory/new-signal-triage/new-signal-match-<stamp>.json`

7. If Adam wants the agent proposal queued for review, write one B4 Suggested
   row:

```powershell
pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -ItemId <proof item id> -Apply
```

## Current Local Changes

- `config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json` now expects a `New Signal`
  Teams channel.
- `scripts/Ensure-M365NewSignalTeamsChannel.ps1` can read back or create the
  channel with a typed confirmation.
- `scripts/Start-M365NewSignalTeamsChannelInteractive.ps1` opens the visible
  channel setup window.
- `scripts/flow-builder/create-connections.js` can create a Teams connector
  connection using `--only=teams`.
- `scripts/flow-builder/create-new-signal-teams-flow.js` builds the
  SharePoint-created-item to Teams-channel alert flow.
- `scripts/flow-builder/Start-FlowBuilder.ps1` has a `new-signal` phase and
  `-Only` connection selector.
- `scripts/Invoke-M365NewSignalAlertProof.ps1` captures the B1 proof packet and
  gates the one synthetic CRM create behind a typed approval phrase.
- `scripts/Invoke-M365NewSignalTriage.ps1` produces the B2/B3 local triage and
  similar-record packet from a selected or newest CRM signal, and can write one
  B4 `Suggested` Agent Action Log row with `-Apply`.

## Historical Boxed State On 2026-06-24

- At that time, SharePoint Power Automate connection was present and connected.
- At that time, Teams Power Automate connection was not present.
- At that time, channel evidence file was not confirmed.
- At that time, flow was not created or proven.
- Local validation passed for the new JavaScript and PowerShell scripts.
- A dry run correctly stopped when channel evidence was missing.

## Live Verification On 2026-06-25

- `Guided AI Labs - Get started` Microsoft Form is live and anonymous.
- `Guided AI Journey - Get started` Microsoft Form is live and anonymous.
- Power Automate reports both brand intake flows as `Started`:
  - `GAIL - Guided AI Labs intake to CRM (create-only)`
  - `GAIL - Guided AI Journey intake to CRM (create-only)`
- Both flows target the same `CRM - New Signals` list id:
  `a64ef810-ad45-407b-b1ea-516533a8611d`.
- Prior end-to-end proof exists from 2026-06-23:
  - Labs form created CRM item `Id=12` with `IntakeSource=Guided AI Labs`.
  - Journey form created CRM item `Id=13` with
    `IntakeSource=Guided AI Journey`.
- SharePoint, Microsoft Forms, and Microsoft Teams Power Automate connections
  are `Connected`.
- `inventory/forms-build/new-signal-teams-channel.json` identifies
  `Guided AI Labs / New Signal`.
- `inventory/forms-build/flow-result-new-signal-teams.json` records flow
  `c54964d6-0042-430d-b542-90214e49224b` as `Started`.
- Synthetic CRM proof item `#19` was created after the flow was started.
- Power Automate run history shows the run succeeded and
  `Post_to_New_Signal_channel` succeeded with `Created`.
- Teams web proof found the exact title in `Guided AI Labs / New Signal`.
- B1 pass packet:
  `inventory/new-signal-alert/new-signal-alert-proof-20260625-162306.md`.
- B2/B3 packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-162403.md`.
- B4 applied packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-162436.md`.
- Agent Action Log row `#9` was created with status `Suggested`.

Next required build handoff:

1. Treat B1-B4 as proven for the synthetic lane.
2. Resolve the competing M365-writing agent boundary.
3. Run B5: decide the durable `m365-interaction-agent` permission/adapter
   posture before expanding writes or unattended behavior.
4. Then run B6 source expansion, one source at a time, through the same
   CRM -> Teams -> triage -> Suggested-row lane.

## Notes

- The flow polls SharePoint every minute using the standard SharePoint
  `When an item is created` trigger.
- The Teams action posts as Flow bot to the `New Signal` channel.
- The alert body includes priority, type, source, person, organization, need,
  created time, suggested first move, and the CRM item link.
- The flow does not update the CRM item. Duplicate prevention is verified by the
  proof step rather than by writing alert metadata back into CRM.
- The proof script does not request extra Graph Teams message-read scopes; the
  Teams evidence is operator-observed and locally recorded.
- The triage script now covers B2/B3 by default: it reads one signal, writes
  local evidence, and includes an advisory-only similar-record section.
- With `-Apply`, the triage script covers B4 by writing at most one G1
  `Suggested` Agent Action Log row after confirmation. It still does not update
  CRM, create Planner/calendar items, send messages, merge records, or change
  permissions.
