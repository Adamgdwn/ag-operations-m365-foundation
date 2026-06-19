# Knowledge / Records Card Plan

Date: 2026-06-19

Status: Active Chunk 5 card plan. Local evidence only; no tenant read or write
was performed for this plan.

## Card Plan Header

Name: Knowledge / Records

Owner: Adam until a records owner is delegated.

Primary users:

- employee/operator
- trusted partner/operator
- governance reviewer / controlled builder
- Adam

Primary workflow:

Find official methods, reusable IP, delivery evidence, readiness evidence,
handoff packets, restricted build evidence, and archive records without relying
on memory or build history.

Current live surface:

- Methods and IP navigation
- Published Methods library
- Readiness Evidence library
- Restricted Build Evidence library
- Delivery Working Documents library
- Client Handoff Packets library
- Archive library

Completion gate:

A role-appropriate person can find the official record location for a method,
evidence item, reusable asset, handoff packet, or historical record and know
where contribution or publication requires review.

Related docs:

- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
- `M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md`

## Purpose

The Knowledge / Records card is the workspace memory: official methods,
evidence, reusable assets, delivery records, and historical material.

## Operator Promise

After receiving role-appropriate access and this runbook, a capable operator can
locate official records, avoid saving sensitive material in the wrong place,
submit reusable knowledge for review, and distinguish active working files from
published methods or archived evidence.

## Daily Workflow

1. Start from Operations Cockpit or workspace navigation.
2. Use Published Methods for approved templates, playbooks, training paths, and
   reusable assets.
3. Use Delivery Working Documents for active delivery work.
4. Use Readiness Evidence for operating/workspace readiness proof.
5. Use Restricted Build Evidence for sensitive build, governance, or security
   material.
6. Use Client Handoff Packets for handoff materials.
7. Use Archive only when closeout/archive rules are met.
8. Escalate unclear sensitivity, client ownership, retention, or publication
   decisions.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Find a playbook/template | Published Methods | Operator opens approved method or reusable asset | Method is stale, sensitive, or unapproved. |
| Save active delivery work | Delivery Working Documents | File is stored and linked from delivery record | File contains sensitive build/client/security material. |
| Record readiness proof | Readiness Evidence | Evidence is stored and linked from the relevant plan | Evidence contains restricted admin/security details. |
| Publish reusable IP | Published Methods candidate path | Review/decision request is recorded | Publishing exposes client-specific or sensitive information. |
| Archive completed work | Archive | Record is moved only after closeout rule is met | Retention, deletion, or ownership is unclear. |

## Surfaces

Pages:

- Methods And IP
- Client Workspace Pattern
- Operating Model
- Decisions, when publication or retention requires approval

Lists:

- Decision Register
- Exception Register
- Handoff Packet Register
- Client Workspace Register
- Agent Action Log, when AI/agent suggestions touch knowledge or records

Libraries:

- Published Methods
- Delivery Working Documents
- Readiness Evidence
- Restricted Build Evidence
- Client Handoff Packets
- Archive

Published Methods folders:

- Templates
- Playbooks
- Training Paths
- Reusable Assets

Archive folders:

- Completed Work
- Historical Evidence

Teams or channels:

- Guided AI Labs / Methods and IP
- Guided AI Labs / Active Delivery for active working files

Current cockpit link or queue:

- No dedicated top cockpit card yet; current access is through navigation and
  cross-card links.

Reference-only or superseded surfaces:

- build packet docs that have been replaced by active `docs/` plans
- unlinked local drafts

Admin-only or controlled surfaces:

- Restricted Build Evidence
- retention, sensitivity, deletion, and broad library permissions
- reusable IP publication when it contains client or sensitive material

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until a records backup is named.

Review cadence:

- Weekly while card/runbook work is active.
- Monthly for methods/IP freshness and archive hygiene.
- At every handoff, closeout, or publication decision.

Evidence location:

- Official records in the relevant SharePoint library.
- Publication, retention, and sensitivity decisions in Decision Register.
- Temporary exceptions in Exception Register.

## Access Model

Employee/operator access:

- A1 read for approved methods.
- A2 contribute to assigned evidence and working documents.

Trusted partner/operator full access:

- A3 for assigned methods, evidence, and handoff records.

Governance reviewer / controlled builder:

- A4 for Restricted Build Evidence, reusable IP review, archive rules, and
  sensitive evidence review.

Admin-only authority:

- retention, deletion, broad permissions, external sharing, sensitivity labels,
  and publishing sensitive methods/IP.

Blocked access escalation:

- Escalate with record link, intended use, sensitivity question, and business
  reason.

## Data Model

Required fields or metadata:

- title
- record type
- owner
- status or lifecycle state
- source/related work item
- sensitivity or restriction note when needed
- last reviewed date for published knowledge

Useful fields:

- client/project/engagement
- method category
- reusable asset category
- version
- source evidence
- archive/retention note

Fields hidden from daily operators:

- security-sensitive build evidence
- app/permission details
- admin-only audit or tenant configuration evidence

Required views:

- published method folders by type
- readiness evidence by project/workstream
- restricted evidence by review need
- handoff packet review
- archive by completed/historical category

Record and file ownership:

- Files hold the record.
- Lists hold workflow state, decisions, exceptions, and handoff state.
- Published knowledge needs an owner and review cadence.

Data quality rules:

- Official records must be linkable from the owning task, decision, delivery, or
  handoff record.
- Client-specific material is not reusable IP until reviewed.
- Restricted evidence is not copied into broad methods or daily pages.
- Archive is not deletion.

## Runbook

Start of day:

- Open the card or navigation area tied to the needed record.
- Search official libraries before creating duplicate files.

Primary workflow:

- Read approved methods from Published Methods.
- Save active files to Delivery Working Documents.
- Save proof to Readiness Evidence or Restricted Build Evidence based on
  sensitivity.
- Link files from the owning record.
- Record publication or archive decisions when needed.

End of day:

- New files have an owner and related record.
- Evidence created during work is linked.
- Knowledge candidates are flagged for review instead of published silently.

Escalation:

- Escalate sensitivity, client ownership, retention, deletion, publishing,
  external sharing, permission, app, or AI/agent grounding questions.

## Acceptance Standard

Knowledge / Records is complete when a role-appropriate person can find and
place official material without guessing whether it belongs in active delivery,
published methods, restricted evidence, handoff packets, or archive.

## Agentic Opportunities

Read-only suggestions:

- Find stale methods, unlinked evidence, duplicate files, knowledge candidates,
  and records that appear to be in the wrong library.

Draft generation:

- Draft method summaries, handoff record indexes, archive notes, and knowledge
  candidate review briefs.

Write-capable actions:

- Future only. File moves, metadata writes, publication, and archive actions
  require explicit approval and rollback path.

Required approval gate:

- Human approval before any file move, publication, archive action, or metadata
  write.
- Decision Register entry before sensitivity, retention, sharing, or agent
  grounding posture changes.

Required evidence:

- Agent Action Log entry for AI/agent suggestions.
- Decision Register entry for publication, sensitivity, retention, sharing, or
  agent grounding changes.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- official record locations are clear;
- read/contribute/restricted access boundaries are defined;
- active work, published methods, evidence, handoff, and archive are separated;
- publication and archive decisions have owners and review cadence;
- acceptance evidence is recorded.

Current blockers before final workspace acceptance:

- Browser/live-user acceptance evidence remains for Chunk 7.
- A visible cockpit route may be needed if final walkthrough shows records are
  too hidden.

Future enhancements:

- Add a dedicated Knowledge / Records cockpit card or dashboard if usage
  warrants it.
- Add metadata views for published methods and evidence review.

## Acceptance Test

Given a capable operator with records access:

1. Sign in with MFA.
2. Open Operations Cockpit or workspace navigation.
3. Find an approved method or template.
4. Identify where an active delivery file belongs.
5. Identify where sensitive build evidence belongs.
6. Identify where a completed handoff or historical record belongs.
7. Confirm publication, archive, retention, and deletion require review.
8. Confirm no daily record path requires admin authority.

Evidence to record:

- test date;
- role used;
- sample method/evidence/record names;
- friction points;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- records work requires retention, deletion, labels, broad permissions, external
  sharing, client data exposure, app consent, public forms, production mail,
  Dynamics, Dataverse, premium Power Platform, or unattended automation;
- sensitive evidence is visible to the wrong role;
- the official record location cannot be determined from the card plan.
