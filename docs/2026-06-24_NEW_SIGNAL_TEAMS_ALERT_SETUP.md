# New Signal Teams Alert Setup

Date: 2026-06-24

Status: forms verified live on 2026-06-25; Teams notification activation is
pending the Teams channel and Teams Power Automate connector auth gates.
Channel and flow scripts exist and local checks passed.

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

## Setup Sequence

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

- Create one test item in `CRM - New Signals`.
- Confirm exactly one post appears in `Guided AI Labs / New Signal`.
- Confirm the Teams post links back to the CRM item.
- Capture the test item title, created time, Teams post time, flow run status,
  and whether duplicate posts occurred.

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

## Boxed State On 2026-06-24

- SharePoint Power Automate connection was present and connected.
- Teams Power Automate connection was not present at last check.
- Channel evidence file was not confirmed.
- Flow was not created or proven.
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
- SharePoint and Microsoft Forms Power Automate connections are `Connected`.
- Microsoft Teams Power Automate connection is still missing.
- `inventory/forms-build/new-signal-teams-channel.json` is still missing.
- `Microsoft.Graph.Authentication` was installed locally for the current user
  on 2026-06-25, but embedded WAM auth failed and device-code auth timed out
  before the channel could be read or created.

Next required operator handoff:

1. Complete Teams/Graph sign-in as `adamgoodwin@guidedailabs.com`.
2. Approve creating the standard internal `New Signal` channel if it is
   missing.
3. Approve creating the standard Microsoft Teams Power Automate connector.
4. After those two artifacts exist, run the dry/live New Signal flow creation
   and one test CRM signal proof.

## Notes

- The flow polls SharePoint every minute using the standard SharePoint
  `When an item is created` trigger.
- The Teams action posts as Flow bot to the `New Signal` channel.
- The alert body includes priority, type, source, person, organization, need,
  created time, suggested first move, and the CRM item link.
- The flow does not update the CRM item. Duplicate prevention is verified by the
  proof step rather than by writing alert metadata back into CRM.
