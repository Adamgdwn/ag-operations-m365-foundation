# Decisions / Governance Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Decisions / Governance

Owner: Adam until a governance reviewer is delegated.

Primary users:

- Adam
- employee/operator recording routine decisions within assigned scope
- trusted partner/operator with assigned governance contribution
- governance reviewer / controlled builder

Primary workflow:

Record decisions, approvals, exceptions, review dates, app/tool posture, sharing
questions, and scope boundaries so work is auditable and reversible.

Current live surface:

- Decisions page
- Decision Register
- Exception Register
- App Grants
- External Sharing Rules
- Tool Permission Review
- Agent Action Log for agent/AI evidence

Completion gate:

A role-appropriate person can record or find an approved decision, identify when
Adam must approve, open related exception/app/tool surfaces, and avoid treating
governance pages as permission to change the tenant.

Related docs:

- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `docs/AGENTIC_M365_READINESS.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`

## Purpose

The Decisions / Governance card keeps decisions visible: what was approved,
why, by whom, when it should be revisited, and what authority it did or did not
grant.

## Operator Promise

After receiving role-appropriate access, a capable operator can record routine
operating decisions, link source evidence, flag exceptions, and know which
choices require Adam or admin authority before anything changes.

## Daily Workflow

1. Start from Operations Cockpit or Decisions page.
2. Review Recent Decisions and Revisit Soon.
3. Record routine operating decisions within assigned scope.
4. Use Exception Register for temporary deviations and expiry/review dates.
5. Use Tool Permission Review and App Grants only as controlled governance
   surfaces.
6. Escalate admin, sharing, app, billing, client, policy, or automation impact.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Routine operating choice | Decision Register | Decision, rationale, owner, area, source link, revisit date | Decision changes client scope, pricing, sharing, app, or policy posture. |
| Temporary exception | Exception Register | Exception, owner, expiry, closure path | Exception weakens access, sharing, security, or records posture. |
| App/tool review | Tool Permission Review or App Grants | Review item and decision link | Consent, Graph scope, app registration, or connector change is needed. |
| Agent action approval | Agent Action Log -> Decision Register | Approved/rejected action with evidence | Action writes, sends, grants, deletes, or affects external/client work. |
| External sharing question | External Sharing Rules | Decision or escalation note | Guest invite, external link, or site sharing change is requested. |

## Surfaces

Pages:

- Decisions
- App Grants
- External Sharing Rules
- Access Model
- Agent Setup, when decision is agent-related

Lists:

- Decision Register
- Exception Register
- Tool Permission Review
- Automation Backlog
- Agent Action Log

Libraries:

- Restricted Build Evidence
- Readiness Evidence
- Archive, for historical governance evidence after review

Teams or channels:

- Guided AI Labs / General for normal discussion
- Guided AI Labs / Agent Setup for controlled agent/governance discussion

Current cockpit link or queue:

- Operations card signals for recent decisions
- Tools card links for app/tool/agent governance

Reference-only or superseded surfaces:

- old Stage 7/8/9 packet docs unless they are cited as provenance

Admin-only or controlled surfaces:

- Entra roles
- SharePoint permissions
- app registrations and app consent
- external sharing policy
- tenant security settings
- public forms, mailbox automation, and unattended agents

## Ownership And Cadence

Human owner:

- Adam.

Backup owner:

- Adam until a governance reviewer is assigned.

Review cadence:

- Weekly for open decisions and exceptions during active build.
- Monthly for app/tool grants, broad delegated grants, and agent posture.
- At every access, sharing, app, or client-impacting change.

Evidence location:

- Decision Register for approvals and accepted decisions.
- Exception Register for temporary deviations.
- Tool Permission Review for app/tool reviews.
- Agent Action Log for AI/agent suggestions and assisted actions.
- Restricted Build Evidence for sensitive evidence.

## Access Model

Employee/operator access:

- A2 to record routine decisions, blockers, and escalation notes within assigned
  authority.

Trusted partner/operator full access:

- A3 to maintain decisions related to assigned work.

Governance reviewer / controlled builder:

- A4 to review exceptions, app grants, sharing rules, tool permissions, and
  sensitive evidence when assigned.

Admin-only authority:

- Tenant policy, security settings, role assignments, app consent, external
  sharing, guest invites, broad permissions, and accepted-risk decisions.

Blocked access escalation:

- Record the needed decision and stop until Adam approves the authority path.

## Data Model

Required fields:

- decision title
- decision date
- decision owner
- area
- decision text
- rationale
- source link
- revisit date when needed

Useful fields:

- affected card
- risk level
- approval phrase
- related exception
- related agent action
- rollback or closure note

Fields hidden from daily operators:

- admin-only app IDs, permission payloads, secret material, and sensitive
  evidence links unless role-approved.

Required views:

- Recent Decisions
- Revisit Soon
- Agent / Governance
- Client / Delivery
- Open Exceptions
- Tool Permission Review / Needs Review

Record and file ownership:

- Register rows hold the decision state.
- Evidence libraries hold supporting files.
- The decision itself must not live only in chat, email, or script output.

Data quality rules:

- A decision without owner or source link is incomplete.
- Approval must be explicit; do not infer it from context.
- Temporary exceptions need expiry or review date.
- Admin-only authority must be named separately from operating access.

## Runbook

Start of day:

- Review Revisit Soon and open exceptions.
- Check Agent Action Log items needing decision review.

Primary workflow:

- Record the decision or exception in the right register.
- Link source evidence and affected card.
- Note whether the decision approves action, rejects action, or only records
  context.
- Escalate if authority is outside the operator role.

End of day:

- Confirm every active exception has owner and review date.
- Confirm risky decisions have evidence and rollback/closure note.

Escalation:

- Escalate missing authority, ambiguous approval, broad access, app consent,
  external sharing, billing/client commitments, public forms, production mail,
  deletes, Dynamics/Dataverse, premium Power Platform, and unattended
  automation.

## Acceptance Standard

Decisions / Governance is complete when the workspace has a visible memory of
why meaningful choices were made and what they allow.

## Agentic Opportunities

Read-only suggestions:

- Find decisions needing revisit, exceptions without expiry, app/tool reviews
  without closure, and action-log items awaiting approval.

Draft generation:

- Draft decision summaries, exception closure notes, app/tool review questions,
  and rollback notes.

Write-capable actions:

- Future only. Recording approved decisions or exceptions may become a
  supervised internal write after gates are proven.

Required approval gate:

- Adam approval before writing decisions that approve action.
- Separate approval phrase before any tenant write.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for policy, scope, app, permission, external/client,
  billing, or agent posture changes.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- Decision Register and Exception Register paths are clear;
- Tool Permission Review, App Grants, and External Sharing Rules are controlled;
- operator versus admin authority is separated;
- decisions have owner, rationale, source link, and revisit date when needed;
- accepted-risk and approval decisions are explicit;
- acceptance evidence is recorded.

Current blockers before final workspace acceptance:

- Browser/live-user acceptance evidence remains for Chunk 7.
- Broad delegated app grants still need a resting-state decision.
- Support MFA remains open before support mailbox agent work.

Future enhancements:

- Add formal approval phrases for non-CRM tenant-writing chunks.
- Add dashboard views for open exceptions and revisit dates.

## Acceptance Test

Given a capable operator or governance reviewer with the right role:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open Decisions or Decision Register.
4. Create or simulate a safe internal decision record.
5. Link source evidence.
6. Identify whether the decision is routine, governance-sensitive, admin-only,
   or blocked.
7. Find where exceptions, app grants, sharing rules, and agent approvals belong.
8. Confirm no daily governance path grants permission by itself.

Evidence to record:

- test date;
- role used;
- safe test decision title;
- source link or simulated source;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- a decision would authorize tenant/global admin action, guest access, sharing,
  app consent, public forms, production mail, deletes, billing, client
  commitments, Dynamics, Dataverse, premium Power Platform, or unattended
  automation;
- the operator cannot distinguish a decision record from permission to act;
- sensitive evidence would be exposed to the wrong role.
