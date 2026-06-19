# Tasks / Actions Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Tasks / Actions

Owner: Adam until a workspace task owner is delegated.

Primary users:

- employee/operator
- trusted partner/operator
- Adam
- governance reviewer when task rules touch controlled surfaces

Primary workflow:

Track assigned work, due dates, blockers, next actions, and completion state
without splitting daily work invisibly across Planner, Lists, Teams, and pages.

Current live surface:

- Open CRM Actions queue
- Guided AI Labs Operating Plan in Planner
- list-based queues in CRM, intake, support, lifecycle, and agent review
- Teams channels for coordination

Completion gate:

A role-appropriate person can determine where a task belongs, update a safe
internal next action, and find owner, due date, source record, and escalation
path.

Related docs:

- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`
- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json`

## Purpose

The Tasks / Actions card prevents work from disappearing into scattered
personal notes, chat, or uncategorized Planner cards.

## Operator Promise

After receiving access and this runbook, a capable operator can identify the
right task surface for CRM, delivery, intake, support, governance, or agent
work; update the next action; and escalate anything that requires authority
beyond task coordination.

## Source Of Truth Rule

Use the record that owns the work:

- CRM follow-ups live in CRM Action Queue or CRM source records.
- Delivery checklist work lives in CRM Lifecycle Checklist or delivery records.
- Broad workspace tasks live in Guided AI Labs Operating Plan.
- Intake/support work lives in the relevant intake or support register.
- Agent suggestions live in Agent Action Log until approved for a real task.
- Decisions and exceptions do not become tasks without a linked Decision or
  Exception Register item.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open the assigned queue or Planner bucket.
3. Confirm each active item has owner, due date, status, source record, and next
   action.
4. Update work state in the owning surface.
5. Create or update Planner tasks only when work is cross-card or coordination
   oriented.
6. Escalate authority, scope, access, external/client, billing, or automation
   issues.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| CRM follow-up due | Open CRM Actions | CRM action has owner, due date, status, next action | Follow-up changes scope, pricing, promise, or external send. |
| Delivery checklist due | Lifecycle Checklist | Checklist status and evidence link are updated | Item blocks go-live/offramp or requires client approval. |
| Intake needs work | Intake Register / Attention Now | Intake row has status, owner, next action, linked task if needed | Item belongs in CRM, support, or external/client lane. |
| Cross-card coordination | Guided AI Labs Operating Plan | Planner task links to source record and owner | Task would create permission, sharing, app, or policy work. |
| Agent suggested action | Agent Action Log / Needs Review | Suggested action is approved, rejected, or converted to task | Action writes, sends, grants, deletes, or affects clients. |

## Surfaces

Pages:

- Operations Cockpit
- CRM Command Center
- Active Delivery
- Intake
- Decisions
- Agent Setup, only for controlled agent tasks

Lists:

- `CRM - Action Queue`
- `CRM - Lifecycle Checklist`
- `Guided AI Labs - Intake Register`
- `Change Leadership Tools - Support Register`
- Decision Register
- Exception Register
- Agent Action Log

Planner:

- Guided AI Labs - Operating Plan

Planner buckets:

- Intake Triage
- Client Discovery
- Active Delivery
- Content / IP
- Agent Setup
- Waiting / Follow-up
- Admin / Governance

Teams or channels:

- General
- Intake
- Client Discovery
- Active Delivery
- Agent Setup
- Methods and IP

Current cockpit link or queue:

- Open CRM Actions
- Attention Now
- Agent Action Log / Needs Review

Reference-only or superseded surfaces:

- old one-off task notes in build packet docs
- unlinked Teams chat as a task source of truth

Admin-only or controlled surfaces:

- Planner/Team ownership changes
- automation that creates or updates tasks
- app grants and permission changes

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until a task coordinator is assigned.

Review cadence:

- Daily for open/due tasks.
- Weekly for bucket hygiene, stale tasks, and source-of-truth drift.
- At every card handoff.

Evidence location:

- Owning List/Planner item for work state.
- Source record link back to CRM, intake, support, delivery, decision, exception,
  or action log.

## Access Model

Employee/operator access:

- A2 for assigned tasks, Planner buckets, and source records.

Trusted partner/operator full access:

- A3 for cross-card work queues within assigned scope.

Governance reviewer / controlled builder:

- A4 only when task rules touch governance, app, permission, or agent surfaces.

Admin-only authority:

- Planner/Team ownership, permission repair, automation task writers, external
  guest access, and app consent.

Blocked access escalation:

- Escalate with task link, source record, action needed, and business reason.

## Data Model

Required fields:

- title
- owner
- status
- priority
- due date when time-bound
- next action
- source record link
- blocker/escalation note when blocked

Useful fields:

- card/workstream
- bucket
- related decision
- related evidence
- follow-up date
- completion note

Fields hidden from daily operators:

- Graph IDs, central OS IDs, connector IDs, automation payloads, and hidden audit
  fields unless needed for controlled review.

Required views:

- Open CRM Actions
- Checklist Due
- Attention Now
- Active Support
- Needs Review
- Planner buckets by operating area

Record and file ownership:

- Task state lives in the task surface.
- Business context lives in the source record.
- Evidence lives in the relevant library.

Data quality rules:

- No orphan tasks without a source or business context.
- No completed tasks with unresolved client, billing, permission, or governance
  blockers.
- Chat may coordinate, but it does not replace task state.

## Runbook

Start of day:

- Open Operations Cockpit.
- Review assigned queue and Planner bucket.
- Sort by urgency, due date, and blocked state.

Primary workflow:

- Update owning record first.
- Add Planner only for coordination or cross-card work.
- Link every task to its source record or evidence.
- Escalate blocked authority decisions.

End of day:

- Due tasks are updated or escalated.
- Stale next actions are cleaned up.
- Completed tasks have resolution notes or source-record updates.

Escalation:

- Escalate missing access, unclear source of truth, duplicate tasks, client
  commitments, billing, external sends, permissions, app consent, public forms,
  deletes, and unattended automation.

## Acceptance Standard

Tasks / Actions is complete when operators can see what to do next and can trace
every task back to the record that owns the work.

## Agentic Opportunities

Read-only suggestions:

- Find overdue tasks, missing owners, orphan tasks, stale blockers, and duplicate
  action items.

Draft generation:

- Draft next-action text, task summaries, blocker notes, and end-of-day briefs.

Write-capable actions:

- Future only. Supervised task creation or update may be allowed after explicit
  approval gates and evidence.

Required approval gate:

- Human approval before any Planner/List task write.
- Decision Register entry before automation creates or updates tasks.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for automated task-writing posture.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- task source-of-truth rules are documented;
- each card's task surface is known;
- operator access is limited to assigned work;
- admin-only task automation and ownership changes are controlled;
- safe internal acceptance evidence is recorded.

Chunk 7 closeout carry-forwards:

- Exact future operator permission groups must be read back before any grant.

Future enhancements:

- Add dashboard views for cross-card task health.
- Add supervised Planner writes only after agent/governance gates mature.

## Acceptance Test

Given a capable operator with assigned task access:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Identify whether a sample action belongs in CRM, delivery, intake/support,
   Planner, Decision Register, or Agent Action Log.
4. Open the correct surface.
5. Create or simulate a safe internal task/action update.
6. Confirm owner, due date, status, source record, next action, and escalation
   path.
7. Confirm no daily task step requires admin links or automation.

Evidence to record:

- test date;
- role used;
- task/source record name;
- source-of-truth decision;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- task work requires Planner/Team ownership changes, permissions, guest access,
  sharing, app consent, public forms, production mail, deletes, billing, client
  commitments, Dynamics, Dataverse, premium Power Platform, or unattended
  automation;
- tasks are split across surfaces without a source-record link;
- operators need access beyond assigned card scope to complete routine tasks.
