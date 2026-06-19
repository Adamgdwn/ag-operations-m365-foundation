# Finance / Closeout Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Finance / Closeout

Owner: Adam until a closeout owner is delegated.

Primary users:

- employee/operator preparing closeout evidence
- trusted partner/operator assigned to delivery closeout
- Adam for billing, payment, pricing, and client acceptance decisions

Primary workflow:

Prepare final evidence, handoff state, invoice-readiness notes, payment
follow-up context, and archive path without granting billing authority to daily
operators.

Current live surface:

- Projects In Flight card
- Handoff Packets link
- Client Handoff Packets library
- Handoff Packet Register
- CRM Closeout Invoice Queue
- CRM Lifecycle Checklist

Completion gate:

A role-appropriate person can identify what is ready for handoff/closeout,
prepare evidence, record invoice-readiness notes, and escalate billing/payment
authority to Adam.

Related docs:

- `docs/CARD_PLAN_DELIVERY_PROJECTS.md`
- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`

## Purpose

The Finance / Closeout card makes the end of work visible: handoff evidence,
acceptance state, invoice readiness, payment follow-up, and archive readiness.

## Operator Promise

After receiving assigned access and this runbook, a capable operator can prepare
closeout materials, identify missing evidence, record what is invoice-ready,
and escalate pricing, billing, payment, or legal questions to Adam.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open Projects In Flight or CRM Closeout / Invoice Watch.
3. Review handoff packets, lifecycle blockers, and invoice-readiness notes.
4. Confirm final evidence exists and is linked.
5. Prepare closeout summary and handoff packet state.
6. Escalate billing, payment, client acceptance, legal, or external commitment
   decisions.
7. Archive only after closeout/record rules are met.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Handoff review | Handoff Packets | Packet has owner, status, evidence, next action | Client acceptance or sharing is needed. |
| Invoice readiness | CRM Closeout Invoice Queue | Invoice-readiness note and missing evidence are clear | Pricing, billing authority, or payment terms are unclear. |
| Payment follow-up | Closeout queue or Decision Register | Follow-up owner and next action are recorded | External send, promise, or disputed payment is involved. |
| Delivery cannot close | Lifecycle Checklist | Blocker and owner are visible | Blocker involves scope, client approval, or go-live/offramp issue. |
| Archive completed work | Archive | Archive-ready state is documented | Retention, deletion, or client ownership is unclear. |

## Surfaces

Pages:

- Operations Cockpit
- Active Delivery
- CRM Command Center
- Decisions, when closeout requires approval

Lists:

- CRM - Closeout Invoice Queue
- CRM - Engagements
- CRM - Lifecycle Checklist
- Handoff Packet Register
- Decision Register
- Exception Register, for temporary closeout exceptions

Libraries:

- Client Handoff Packets
- Delivery Working Documents
- Readiness Evidence
- Archive
- Restricted Build Evidence, for sensitive closeout evidence

Teams or channels:

- Guided AI Labs / Active Delivery
- General, for internal coordination only

Current cockpit link or queue:

- Projects In Flight card
- Handoff Packets link
- Open Lifecycle Checklist link

Reference-only or superseded surfaces:

- unlinked invoice notes in chat/email
- old build packet closeout notes unless cited by current plans

Admin-only or controlled surfaces:

- billing systems
- payment decisions
- legal commitments
- external sharing and client access
- deletion and retention decisions

## Ownership And Cadence

Human owner:

- Adam.

Backup owner:

- Adam until a closeout backup is named.

Review cadence:

- Weekly for active delivery closeout candidates.
- At every handoff, invoice-readiness point, payment blocker, and archive move.

Evidence location:

- Handoff Packet Register and Client Handoff Packets.
- CRM Closeout Invoice Queue for invoice-readiness state.
- Decision Register for billing, payment, scope, or accepted-risk decisions.
- Archive after closeout/archive rule is satisfied.

## Access Model

Employee/operator access:

- A2 to prepare closeout evidence, handoff state, and invoice-readiness notes.

Trusted partner/operator full access:

- A3 to help prepare closeout and payment-follow-up evidence within assigned
  scope.

Governance reviewer / controlled builder:

- A4 for closeout standards, restricted evidence, or exception review.

Admin-only authority:

- billing authority, payment decisions, legal commitments, accounting records,
  external client commitments, deletion, retention, guest access, and sharing.

Blocked access escalation:

- Escalate with closeout/handoff link, action needed, authority requested, and
  risk.

## Data Model

Required fields:

- client/project/engagement
- handoff owner
- closeout status
- invoice readiness
- final evidence link
- next action
- due date or follow-up date
- blocker/escalation note when blocked

Useful fields:

- payment follow-up status
- acceptance state
- handoff packet link
- related decision
- archive readiness
- final summary

Fields hidden from daily operators:

- accounting system identifiers
- sensitive payment/legal details
- admin-only client access or sharing controls

Required views:

- Closeout / Invoice Watch
- Handoff Packet review
- Lifecycle blockers
- Archive-ready candidates, if later created

Record and file ownership:

- Closeout state lives in CRM closeout/handoff records.
- Handoff evidence lives in Client Handoff Packets and related libraries.
- Billing/payment/legal decisions live with Adam and Decision Register notes,
  not ordinary operator authority.

Data quality rules:

- Invoice readiness requires evidence, owner, and explicit handoff state.
- Payment follow-up must not imply an external send occurred.
- Closeout is not archive until retention/ownership is clear.

## Runbook

Start of day:

- Review closeout candidates and handoff packets.
- Check blockers and missing evidence.

Primary workflow:

- Prepare final evidence links.
- Update handoff/closeout state.
- Record invoice-readiness notes.
- Flag payment follow-up or acceptance questions for Adam.

End of day:

- No closeout item lacks owner, next action, or evidence status.
- Billing/payment/legal ambiguity is escalated.
- Archive candidates are not moved without review.

Escalation:

- Escalate billing, payment, pricing, legal, client acceptance, external sends,
  sharing, guest access, deletion, retention, public forms, app consent,
  Dynamics/Dataverse, premium Power Platform, and unattended automation.

## Acceptance Standard

Finance / Closeout is complete when closeout work can be prepared by an
operator while billing/payment authority remains with Adam.

## Agentic Opportunities

Read-only suggestions:

- Identify closeout records missing evidence, stale payment follow-up, handoff
  packets ready for review, and lifecycle blockers.

Draft generation:

- Draft closeout summaries, invoice-readiness notes, missing-evidence checklists,
  and internal follow-up prompts.

Write-capable actions:

- Future only. Internal closeout status updates may be approved later; billing,
  payment, and external sends remain restricted.

Required approval gate:

- Human approval before closeout writes.
- Adam approval before any billing/payment/client-impacting action.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for billing, payment, client acceptance, scope, or
  policy changes.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- handoff, closeout, invoice-readiness, payment follow-up, and archive paths are
  defined;
- operator prep is separated from billing/payment authority;
- evidence locations are known;
- owner, backup owner, cadence, and escalation rules are clear;
- acceptance evidence is recorded.

Chunk 7 closeout carry-forwards:

- Exact future operator permission groups must be read back before any grant.

Future enhancements:

- Add a closeout dashboard if volume warrants it.
- Add accounting-system integration only after separate finance/legal approval.

## Acceptance Test

Given a capable operator with closeout access:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open Projects In Flight or CRM Closeout / Invoice Watch.
4. Find or simulate a safe internal closeout item.
5. Identify final evidence, handoff packet, invoice-readiness state, owner, next
   action, and blocker.
6. Explain which billing/payment/client actions require Adam.
7. Confirm no daily closeout step requires admin links, external sharing, or
   accounting authority.

Evidence to record:

- test date;
- role used;
- safe closeout test record;
- evidence/handoff path;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- closeout work requires billing, payment, pricing, legal, accounting, client
  acceptance, guest access, external sharing, public forms, production mail,
  permissions, deletes, retention, Dynamics, Dataverse, premium Power Platform,
  or unattended automation;
- evidence is missing or stored in the wrong location;
- an operator role would imply billing/payment authority.
