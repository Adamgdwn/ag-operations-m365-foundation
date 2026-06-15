# Stage 6 First Agent Loop Runbook

Generated: 2026-06-14 19:04

Purpose: provide a controlled first run after the Stage 6 Lists exist. This keeps the first agent-assisted workflow small, reviewable, and human-approved.

## Preconditions

1. The four Stage 6 Lists exist.
2. `.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly` has passed, or Adam has manually confirmed the Lists and columns.
3. Planner/Teams setup is either deferred or built from `STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md`.
4. No consent/security/MFA/admin prompt is waiting for unattended approval.

## Starter Files

| File | Target | Purpose |
|---|---|---|
| `guided-ai-labs-intake-register-starter.csv` | Guided AI Labs - Intake Register | One safe starter intake row |
| `change-leadership-tools-support-register-starter.csv` | Change Leadership Tools - Support Register | One safe starter support row |
| `agent-action-log-starter.csv` | Agent Action Log | Initial Codex action log entries |
| `decision-register-starter.csv` | Decision Register | The human-supervised Stage 6 operating decision |

## First Loop

1. Add the Decision Register starter row.
2. Add the Agent Action Log starter rows.
3. Add the Intake starter row only if Adam wants a visible test item.
4. Select one real `contact@` message for Codex to classify.
5. Codex drafts an intake row, a proposed acknowledgement, and a Planner task only if there is a next action.
6. Adam reviews before anything external is sent or any calendar/task commitment is made.
7. Log the suggestion/outcome in Agent Action Log.

## Boundaries

- No autonomous external replies.
- No meeting booking without Adam approval.
- No permissions, guest access, app consent, or tenant policy changes.
- No deletion or archiving of messages in the first loop.
- No broad automation until Stage 7/9 governance is ready.

