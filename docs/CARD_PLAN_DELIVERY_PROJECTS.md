# Delivery / Projects Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Delivery / Projects

Owner: Adam until a delivery owner is delegated.

Primary users:

- employee/operator assigned to delivery work
- trusted partner/operator assigned to active delivery
- Adam for scope, client, and escalation decisions

Primary workflow:

Move assigned work from active engagement through lifecycle checklist,
evidence, handoff packet, and closeout prep.

Current live surface:

- Projects In Flight card
- Active Delivery page
- Delivery Control view
- Lifecycle Checklist
- Client Discovery page
- Client Handoff Packets library

Completion gate:

A role-appropriate person can open Projects In Flight, identify active delivery
items, update a harmless internal lifecycle item, link evidence, and explain the
handoff and closeout path without touching sharing, guest access, billing, or
admin settings.

Related docs:

- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`
- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`

## Purpose

The Delivery / Projects card helps operators run active work, keep lifecycle
state visible, attach evidence, and prepare handoff without burying client
commitments in notes or informal chat.

## Operator Promise

After receiving assigned delivery access and this runbook, a capable operator
can open active delivery, find the current engagement or internal project,
update the next action/checklist state, link evidence, and escalate scope,
sharing, or client commitment decisions to Adam.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open Projects In Flight.
3. Review Delivery Control and due lifecycle checklist items.
4. Update status, owner, next action, due date, risk, and evidence link.
5. Store or link working files in the approved delivery/evidence location.
6. Prepare handoff packet entries when delivery is ready for review.
7. Escalate client commitments, external sharing, billing, or permission needs.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Review active work | Projects In Flight -> Active Delivery | Engagement/project has status, owner, next milestone, next action | Work lacks owner, due date, or scope clarity. |
| Clear a lifecycle item | Lifecycle Checklist | Checklist item updated with status and evidence link | Item blocks go-live/offramp or requires client approval. |
| Attach delivery evidence | Delivery Working Documents or Readiness Evidence | Evidence is linked from engagement/checklist | Evidence is sensitive or belongs in Restricted Build Evidence. |
| Prepare handoff | Client Handoff Packets | Handoff packet draft or register item is ready for review | Packet implies client acceptance, external sharing, or invoice readiness. |
| Discovery becomes delivery | Client Discovery -> Delivery Control | Delivery item is linked to CRM/client record | Discovery path is really CRM intake or support intake. |

## Surfaces

Pages:

- Operations Cockpit
- Active Delivery
- Client Discovery
- CRM Command Center, when delivery is tied to CRM

Lists:

- `CRM - Engagements`
- `CRM - Lifecycle Checklist`
- `CRM - Action Queue`
- Client Workspace Register
- Handoff Packet Register
- Decision Register
- Agent Action Log, only for AI/agent suggestions or assisted actions

Libraries:

- Delivery Working Documents
- Client Handoff Packets
- Readiness Evidence
- Restricted Build Evidence, only for sensitive build/governance evidence
- Archive, after closeout rules are met

Teams or channels:

- Guided AI Labs / Active Delivery
- Guided AI Labs / Client Discovery

Current cockpit link or queue:

- Projects In Flight card -> Active Delivery
- Delivery Control link
- Open Lifecycle Checklist link
- Handoff Packets link

Reference-only or superseded surfaces:

- old CRM operations pages unless current CRM/delivery plans point to them

Admin-only or controlled surfaces:

- external sharing and guest access
- site/library permissions
- App Grants and Tool Permission Review
- client-facing public forms
- billing or legal commitments

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until a delivery backup is named.

Review cadence:

- Daily for active delivery due today or blocked items.
- Weekly for lifecycle health, evidence, and handoff readiness.
- At every engagement transition: discovery, onboarding, active delivery,
  handoff, closeout.

Evidence location:

- Delivery state in CRM/list records.
- Files in Delivery Working Documents, Client Handoff Packets, Readiness
  Evidence, or Restricted Build Evidence as appropriate.
- Scope/approval decisions in Decision Register.

## Access Model

Employee/operator access:

- A2 to assigned delivery pages, records, files, and checklist items.

Trusted partner/operator full access:

- A3 for assigned active delivery, delivery files, handoff packets, and
  closeout prep when deliberately granted.

Admin-only authority:

- guest/client access, external sharing, permission changes, app consent,
  client tenant commitments, billing authority, and deletes.

Blocked access escalation:

- Escalate with project/engagement link, needed action, business reason, risk if
  granted, and risk if blocked.

## Data Model

Required fields:

- engagement or project title
- organization/client when applicable
- owner
- status/stage
- priority/risk/health
- next action
- due date or target milestone
- evidence link

Useful fields:

- current package
- execution stage
- target go-live date
- handoff status
- checklist phase
- required-for-go-live flag
- blocks-offramp flag

Fields hidden from daily operators:

- Graph/internal IDs
- migration IDs
- automation audit fields
- admin-only permission or connector data

Required views:

- Delivery Control
- Checklist Due
- Go-Live / Offramp Blockers
- Handoff packet review

Record and file ownership:

- Lists hold state and next action.
- Libraries hold files and evidence.
- Decision Register holds scope/approval decisions.

Data quality rules:

- Every active delivery item has owner, next action, due date, and evidence
  location.
- A handoff is not invoice-ready just because files exist.
- Client commitments must be explicit and owned by Adam unless delegated.

## Runbook

Start of day:

- Open Projects In Flight and Delivery Control.
- Check overdue checklist items and blockers.

Primary workflow:

- Update engagement/project state.
- Work the lifecycle checklist.
- Link evidence as files are created or reviewed.
- Prepare handoff material only after delivery evidence is coherent.

End of day:

- Confirm blocked items have an owner and escalation note.
- Confirm files created during work are linked from the record.
- Confirm handoff or closeout state is not buried in Teams/chat notes.

Escalation:

- Escalate scope ambiguity, client commitments, sensitive evidence, missing
  access, external sharing, guest access, public forms, billing, deletes,
  automation, or app consent.

## Acceptance Standard

Delivery / Projects is complete when assigned work can move from active item to
evidence and handoff state with visible owner, next action, status, and
escalation trail.

## Agentic Opportunities

Read-only suggestions:

- Identify overdue checklist items, missing evidence links, stale next actions,
  and blocked delivery records.

Draft generation:

- Draft handoff summaries, checklist updates, delivery status notes, and
  internal review questions.

Write-capable actions:

- Future only. Possible approved writes include lifecycle status updates,
  internal task creation, and handoff draft records.

Required approval gate:

- Human approval before any delivery write.
- Decision Register entry before client-impacting delivery, sharing, app,
  permission, billing, or automation changes.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for scope, client, policy, app, permission, or billing
  impact.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- Projects In Flight opens the active delivery path;
- Delivery Control and lifecycle views are usable by role;
- handoff and evidence locations are known;
- owner, backup owner, cadence, and evidence location are known;
- employee/operator and trusted partner access boundaries are defined;
- admin-only authority remains separate;
- a safe internal delivery test has recorded acceptance evidence.

Current blockers before final workspace acceptance:

- Browser/live-user acceptance evidence remains for Chunk 7.
- Exact future operator permission groups must be read back before any grant.

Future enhancements:

- Add tighter cockpit labels if operators confuse delivery, support, and CRM.
- Add a dedicated handoff/readiness dashboard if closeout volume grows.

## Acceptance Test

Given a capable operator with delivery access:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open Projects In Flight.
4. Find one safe internal delivery/test item.
5. Update or simulate a lifecycle checklist item.
6. Link an approved internal evidence file or note where it should live.
7. Identify owner, due date, next action, handoff path, closeout path, and
   escalation path.
8. Confirm no daily delivery step requires admin links or external sharing.

Evidence to record:

- test date;
- role used;
- safe test record name;
- screenshots/exported read-back where available;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- delivery work requires guest access, external sharing, public forms, client
  tenant commitments, billing decisions, app consent, permissions, deletes, or
  unattended automation;
- sensitive client or build evidence appears in the wrong library;
- the delivery path cannot be separated from CRM or support intake without a
  broader information architecture change.
