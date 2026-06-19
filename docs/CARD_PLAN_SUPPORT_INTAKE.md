# Support / Intake Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Support / Intake

Owner: Adam until an intake/support owner is delegated.

Primary users:

- employee/operator
- trusted partner/operator assigned to intake/support
- Adam
- future support agent reviewer after approval gates mature

Primary workflow:

Capture and triage broad Guided AI Labs intake, Change Leadership Tools support,
internal asks, feedback, and routing questions while keeping CRM New Signal
separate from legacy technical intake.

Current live surface:

- Operations card -> Intake page
- Guided AI Labs - Intake Register / Attention Now
- Change Leadership Tools - Support Register
- support and contact mailbox lanes, subject to current manual posture

Completion gate:

A role-appropriate person can triage an intake/support item, decide the correct
lane, update a safe internal record, and identify when the item belongs in CRM,
delivery, governance, support, or Adam escalation.

Related docs:

- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json`
- `GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md`

## Purpose

The Support / Intake card makes incoming work visible and routable without
turning every inquiry into CRM or every support issue into a delivery project.

## Operator Promise

After receiving assigned access and this runbook, a capable operator can open
the intake/support queues, classify new items, set owner/status/next action, and
escalate messages that require external response, scheduling, client promise,
billing, access, app, or automation decisions.

## Lane Rule

Use the right front door:

- CRM relationship/opportunity signals go to the CRM clean path:
  `CRM - New Signals`.
- Broad Guided AI Labs intake, internal asks, discovery signals, and routing
  questions use `Guided AI Labs - Intake Register`.
- Change Leadership Tools product support uses
  `Change Leadership Tools - Support Register`.
- Support mailbox actions wait for `support@changeleadershiptools.com` MFA and
  explicit approval before mailbox-dependent workflows.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open Operations / Intake or the Attention Now queue.
3. Review new intake/support items.
4. Classify the item and choose the owning lane.
5. Update owner, status, priority, next action, and durable home.
6. Link or create a task only when a real next action exists.
7. Escalate external sends, scheduling, client commitments, billing, access, or
   automation.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Broad GAIL inquiry | Intake Register / Attention Now | Intake row has class, owner, status, next action | It is a CRM opportunity or client commitment. |
| Product support request | Support Register / Active Support | Support row has severity, status, owner, next action | External response, refund/billing, or support mailbox access is needed. |
| Scheduling request | Intake Register | Draft next action; no calendar commitment | Calendar hold, external send, or commitment is needed. |
| Knowledge candidate | Support Register or Intake Register | Candidate is flagged for Knowledge / Records review | It contains sensitive or client-specific content. |
| Noise/spam | Intake/support register | Item is closed/archived with reason | Deletion, mailbox rule, or blocking policy is proposed. |

## Surfaces

Pages:

- Intake
- Operations Cockpit
- CRM Command Center, when item is a relationship/opportunity signal

Lists:

- Guided AI Labs - Intake Register
- Change Leadership Tools - Support Register
- CRM - New Signals
- Decision Register
- Agent Action Log

Libraries:

- Readiness Evidence, for intake/support proof and review notes
- Published Methods, only after knowledge review

Mailboxes or aliases:

- `contact@guidedailabs.com`
- `support@changeleadershiptools.com`
- `adamgoodwin@guidedailabs.com` for Adam-owned communication

Teams or channels:

- Guided AI Labs / Intake
- Change Leadership Tools support surfaces when active

Current cockpit link or queue:

- Operations card -> Intake
- Guided AI Labs - Intake Register / Attention Now

Reference-only or superseded surfaces:

- `Guided AI Labs - Intake Register/NewForm.aspx` as the daily CRM route
- old CRM technical intake links

Admin-only or controlled surfaces:

- mailbox automation
- public/client Forms
- external sends
- guest access and external sharing
- support identity changes
- app consent and connectors

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until an intake/support backup is named.

Review cadence:

- Daily for Attention Now and Active Support when the lanes are active.
- Weekly for stale intake/support items.
- Before any support mailbox, Forms, or automation expansion.

Evidence location:

- Intake/support registers for workflow state.
- CRM for relationship/opportunity signals.
- Decision Register for external/client, support policy, or automation choices.
- Agent Action Log for AI/agent suggestions and assisted actions.

## Access Model

Employee/operator access:

- A2 for assigned intake/support queues and records.

Trusted partner/operator full access:

- A3 for assigned intake/support lanes.

Governance reviewer / controlled builder:

- A4 for routing, Forms, mailbox, and agent-support review when assigned.

Admin-only authority:

- public Forms, mailbox rules/delegates, external sends, guest access, sharing,
  support identity changes, app consent, and unattended automation.

Blocked access escalation:

- Escalate with queue/item link, needed action, lane decision, and risk.

## Data Model

Required fields:

- title
- source mailbox or lane
- received date
- requester name/email when available
- class or issue type
- priority/severity
- status
- owner
- next action
- human approval required

Useful fields:

- organization
- product area
- durable home
- Planner task URL
- resolution summary
- knowledge candidate
- agent notes

Fields hidden from daily operators:

- source message ID
- Graph node ID
- central OS link until used
- agent confidence unless relevant to supervised review

Required views:

- Attention Now
- Waiting External
- Agent Suggested
- Done / Archived
- Active Support
- Blocking / High
- Knowledge Candidates
- Resolved

Record and file ownership:

- Intake/support registers own workflow state.
- CRM owns relationship/opportunity state.
- Published knowledge requires review before reuse.

Data quality rules:

- Every active item has owner, status, priority/severity, and next action.
- No external response is assumed sent unless explicitly recorded.
- CRM opportunities do not stay buried in broad intake.
- Support issues do not become delivery tasks unless assigned.

## Runbook

Start of day:

- Open Attention Now and Active Support.
- Sort by priority/severity and waiting state.

Primary workflow:

- Classify the item.
- Route it to the owning lane.
- Update owner, status, next action, and durable home.
- Draft replies or task notes only when approved.

End of day:

- Urgent/high items have owner and next action.
- Items waiting on Adam or external parties are clearly marked.
- Knowledge candidates are flagged but not silently published.

Escalation:

- Escalate external sends, calendar commitments, support mailbox access, billing,
  refunds, client promises, guest access, sharing, Forms, app consent, deletes,
  and unattended automation.

## Acceptance Standard

Support / Intake is complete when operators can route incoming items into the
right lane and leave visible, auditable state without confusing support,
intake, CRM, and delivery.

## Agentic Opportunities

Read-only suggestions:

- Classify intake/support items, flag urgent issues, suggest lane routing, and
  identify stale waiting items.

Draft generation:

- Draft acknowledgement, support reply, triage summary, and knowledge candidate
  summary.

Write-capable actions:

- Future only. Support/intake List writes and mailbox drafts require approval.
  External sends remain separately gated.

Required approval gate:

- Human approval before intake/support writes beyond suggestions.
- Adam approval before any external send, mailbox change, Forms change, support
  adapter, or client-impacting action.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for mailbox, Forms, support policy, app, permission,
  or external/client impact.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- support/intake lanes are separated from CRM New Signal;
- register views and task handoffs are understood;
- owner, backup owner, cadence, and evidence location are known;
- support mailbox MFA gap is carried as a blocker;
- admin-only surfaces remain controlled;
- acceptance evidence is recorded.

Current blockers before final workspace acceptance:

- `support@changeleadershiptools.com` still needs MFA before support mailbox
  workflows depend on it.
- Browser/live-user acceptance evidence remains for Chunk 7.
- Exact future operator permission groups must be read back before any grant.

Future enhancements:

- Build public/client Forms only after explicit approval.
- Add support mailbox draft loop only after support MFA and adapter posture are
  approved.

## Acceptance Test

Given a capable operator with intake/support access:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open Attention Now or Active Support.
4. Classify a safe internal intake/support test item.
5. Decide whether it belongs in broad intake, support, CRM, delivery, governance,
   or Adam escalation.
6. Update or simulate owner, status, priority/severity, next action, and durable
   home.
7. Confirm no external reply, calendar commitment, public form, mailbox rule, or
   automation is required for the daily path.

Evidence to record:

- test date;
- role used;
- safe test item name;
- lane decision;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- support/intake work requires mailbox MFA, mailbox rules, delegates, external
  sends, public/client Forms, guest access, sharing, app consent, permissions,
  deletes, billing/refund decisions, Dynamics, Dataverse, premium Power
  Platform, or unattended automation;
- CRM signals are being routed through legacy technical intake;
- support records expose sensitive requester or product data to the wrong role.
