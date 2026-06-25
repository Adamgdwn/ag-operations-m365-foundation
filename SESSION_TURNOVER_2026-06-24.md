# Session Turnover - 2026-06-24

Canonical restart file:
[START_HERE.md](START_HERE.md).

Current working plan:
[docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md).

## Stop Point

Documentation is boxed for the night after the one-agent plan revision and New
Signal alert preparation.

Completed in this closeout:

- Reframed the active plan around one governed `M365 Interaction Agent`, not a
  stack of supervised helpers.
- Selected the first live notification capability: `CRM - New Signals` created
  -> internal Teams channel `New Signal`.
- Parked QUO phone integration until the Teams alert proof is clean.
- Added the New Signal setup runbook:
  `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`.
- Added local scripts for creating/read-back of the Teams channel target and
  for building the SharePoint-to-Teams Power Automate flow.
- Updated routing docs so tomorrow's entry path is `START_HERE.md` -> active
  M365 Interaction Agent plan -> New Signal setup runbook.
- Updated Agent Control Plane, readiness, decision-list, CRM decisions, and
  Coordinator docs so they describe one agent with capabilities.

No confirmed Microsoft 365 live New Signal channel, Teams connector, flow, test
alert, external send, permission change, public form change, delete, QUO action,
or broad unattended automation was completed in this closeout.

## Current State

- Phase 1 / Stages 0-9: complete.
- CRM / Relationships: live and recovery-closed.
- Bookings / Scheduling: live.
- Operations Follow-up Backbone: live.
- Website fallback cleanup for the two brand sites: handled.
- Stage 8 packet archive move: still held for Adam's explicit OK.
- Next selected direction: `M365 Interaction Agent`.
- First selected proof: `CRM - New Signals` created -> `Guided AI Labs / New
  Signal` Teams alert -> agent triage/proposal path.
- Local New Signal scripts/runbook: prepared.
- Live New Signal channel evidence: pending unless
  `inventory/forms-build/new-signal-teams-channel.json` exists.
- Teams Power Automate connector: pending at last check.
- New Signal alert flow: not created or proven yet.

## Next Resume Sequence

1. Open [START_HERE.md](START_HERE.md).
2. Open
   [docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md).
3. Open
   [docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md](docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md).
4. Check whether `inventory/forms-build/new-signal-teams-channel.json` exists.
5. If channel evidence is missing, run the visible channel setup gate and type
   `create-new-signal-channel` only if Adam wants the channel created.
6. Create the standard Teams connector with:
   `pwsh -File scripts\flow-builder\Start-FlowBuilder.ps1 -Phase connections -Only teams`.
7. Dry-run the New Signal flow, then create/start it only after the dry run
   succeeds.
8. Create one test CRM signal and prove exactly one Teams post appears with a
   CRM item link.
9. Record proof before expanding any agent action beyond the alert lane.

## Standing Stop Conditions

Stop before app registration, app consent, Graph/SharePoint/Exchange/Teams/
Planner permission changes, external sends, guest access, sharing changes,
public forms, deletes, billing/client commitments, Dynamics, Dataverse, premium
Power Platform, Copilot connector setup, custom actions, or unattended
automation.

Narrow exception already selected for this proof: one internal standard Teams
channel, one standard Teams Power Automate connection as Adam, and one
create-only SharePoint-to-Teams alert flow. This does not approve QUO,
external messaging, app registration, admin consent, guest/sharing changes, or
broad automation.

## Work Tracking

Also update the Windows-side ledger:

```text
C:\Users\adamg\01. Code Projects\01 Work Tracking\AG Operations Workspace Setup\
```

Use the local evening date if the machine clock is still on 2026-06-23
America/Edmonton.
