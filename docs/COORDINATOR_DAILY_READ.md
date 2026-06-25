# Coordinator Daily Read

Date: 2026-06-20

Status: Active capability under the future `M365 Interaction Agent`. First
"intelligent" G1 loop — the read→reason→propose upgrade of the Stage 9
coordinator loop.

This is the Coordinator capability's daily operations read. It replaces the
canned `CoordinatorSuggestion` action (which wrote a fixed test row) with a
loop that actually reads live operating Lists, applies dated detection rules,
and proposes content-specific attention items. It is a capability of the single
M365 agent, not a separate supervised helper product.

Related: [AGENTIC_M365_READINESS.md](AGENTIC_M365_READINESS.md),
[CARD_PLAN_AGENT_CONTROL_PLANE.md](CARD_PLAN_AGENT_CONTROL_PLANE.md),
[../config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json](../config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json).

## What it does

- **G0 (always, no tenant write):** signs in as `adamgoodwin@guidedailabs.com`,
  reads the Intake Register, Decision Register, Agent Action Log, and the CRM
  Engagements / Touchpoints / Organizations lists, applies the detection rules
  below, and writes a **local digest** under
  `inventory/coordinator-daily-read/coordinator-daily-read-<stamp>.md`.
- **G1 (only with `-Apply`):** records **one** `Suggested` row in the Agent
  Action Log summarising the findings and pointing to the digest. The live write
  asks for a **single Y approval** (one click); sign-in is interactive and
  persisted, so a session signs in once. The row is `Suggested` only — a human
  still approves, rejects, or supersedes it in SharePoint. Nothing is executed
  by this loop.

It never sends mail, invites guests, changes sharing or permissions, grants
consent, changes tenant policy, publishes Forms, deletes records, registers
apps, or runs unattended automation.

## Identity note

The current script uses the existing PnP interactive sign-in path for today,
but `agent-pnp-provisioning` is not the production M365 Interaction Agent
identity.
It is a setup/provisioning helper and must not be treated as durable agent
power. The target agent posture is a separate, purpose-built
`m365-interaction-agent` identity or adapter after permission design, rollback,
and Decision Register approval.

## Detection rules (defaults, tunable via parameters)

| List | Rule | Severity |
|---|---|---|
| Intake Register | High/Urgent priority still in `New` | High |
| Intake Register | Open item with no NextAction | Medium |
| Intake Register | Open item older than `-StaleIntakeDays` (14) | Medium |
| Decision Register | RevisitDate in the past | High |
| Decision Register | RevisitDate within `-RevisitSoonDays` (7) | Medium |
| Agent Action Log | `Suggested` older than `-SuggestionAgeDays` (7) | Medium |
| Agent Action Log | `Approved` but not `Completed`, older than 7 days | Medium |
| CRM - Engagements | RiskLevel/Status `At Risk` | High |
| CRM - Engagements | Status `Waiting on Adam` | High |
| CRM - Engagements | Active, not reviewed in `-EngagementReviewDays` (30) | Medium/Low |
| CRM - Touchpoints | FollowUpRequired and FollowUpDueDate passed | High |
| CRM - Organizations | Active/Client/Partner not touched in `-OrgTouchDays` (60) | Medium/Low |

## How to run

Dry run first (G0 read + digest, no tenant write):

```powershell
pwsh -File scripts\Invoke-M365CoordinatorDailyRead.ps1
```

Or open a visible window via the launcher:

```powershell
pwsh -File scripts\Start-M365CoordinatorDailyReadInteractive.ps1
```

Sign in as `adamgoodwin@guidedailabs.com` when prompted (once per session —
the login is persisted and reused). Read the console summary and the digest
file. When you want the G1 Suggested row recorded:

```powershell
pwsh -File scripts\Invoke-M365CoordinatorDailyRead.ps1 -Apply
# review the findings, then press Y to approve the single record
```

If the signed-in account is wrong, the script stops before reading. Add
`-UseDeviceLogin` to pick the account explicitly, or `-ForceFreshLogin` to
re-authenticate. `-Approve` pre-confirms the write (skips the Y prompt) for
fully scripted runs.

## Governance

- Approval: one sign-in per session (persisted) + a single Y confirmation per
  live write. (This loop's only write is the low-risk G1 Suggested row.)
- Evidence: local digest + transcript under `inventory/coordinator-daily-read/`;
  the G1 row lands in the Agent Action Log (`Needs Review` view) with status
  `Suggested`.
- Stays inside the approved G0/G1 lane from the Chunk 6 readiness pass. No new
  permissions, no licensing dependency, independent of the Founders Hub ticket.

## Next steps (not yet built)

- Finish the `New Signal` Teams alert proof first; that is the selected
  first-minute notification capability for the same M365 agent.
- Run on a cadence (manual for now; Power Automate / scheduled task is a later
  Decision Register item).
- Optional G2 follow-through: turn an approved suggestion into a Planner task or
  a NextAction update — separate approval gate, separate build.
