# CRM Onboarding Package

Date: 2026-06-20

Status: CRM recovery Chunk 7 output. Hand-over index for giving a capable
employee or trusted partner CRM operating access. This file does NOT redefine
roles, levels, or escalation - those live in the source-of-truth docs below. It
ties them together for the CRM function and records the exact CRM grant decision.

## What this package is

When Adam hands someone CRM access, this is the one page to start from. It points
to everything they need and records the specific decision for this person.

Source-of-truth docs (read, do not duplicate):

- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` - roles, access levels A0-A7,
  the CRM access-matrix row, admin-only authority, standard grant path, first-day
  walkthrough, escalation, review cadence, and stop conditions.
- `docs/CRM_RUNBOOK.md` - first-day setup, daily CRM operating instructions, and
  CRM escalation.
- `docs/CRM_ACCEPTANCE_TESTS.md` - what a clean CRM path must prove.
- `docs/CRM_DECISIONS.md` - CRM design decisions and rationale.
- `People/PEOPLE_NEW_HIRE_ONBOARDING_PLAN.md` - the broader new-hire plan this
  CRM package slots into.

## The exact CRM grant decision

For CRM / Relationships, the access decision reduces to one of two operating
levels (from the access model's CRM row):

| Person type | CRM access level | What it includes | What it never includes |
|---|---|---|---|
| Employee / operator | A2 - card contributor | New signals, triage, qualification, action queue, meeting notes, artifacts, handoff links for assigned CRM work. | Permission changes, external sharing, app consent, mailbox automation, public Forms, Dynamics, Dataverse, deletes. |
| Trusted partner / operator | A3 - full operating access | Full CRM and related delivery operating access when deliberately granted. | The same admin-only authority above; A3 is still an operating role, not tenant/global admin. |

"Full access" for a trusted partner means full CRM operating access, not admin
authority. The admin-only list in the access model stays with Adam regardless of
operating level.

## Exact access-group notes (READ-BACK REQUIRED before any grant)

The access model's own rule applies: do not guess exact SharePoint/Microsoft 365
group names from memory. Before granting CRM access, read back the live target
groups and site permissions and fill these in:

- Microsoft 365 group for internal members: _read back (e.g. GuidedAILabs@agoperations.ca - confirm live)_
- SharePoint site: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
- SharePoint permission group used for CRM contributors (A2): _read back and record exact name_
- SharePoint permission group / role for full operating access (A3): _read back and record exact name_
- Whether membership in the private Guided AI Labs M365 group is appropriate for
  this person: _decide per standard grant path step 5_

This read-back is deferred-log item tied to the Chunk 2 baseline run; see
`docs/CRM_DEFERRED_VERIFICATION_LOG.md`. Do not grant from this package until the
exact group names are confirmed live.

## First-day checklist for the CRM operator

Run this with the person on day one. It reuses the access model's first-day
walkthrough, scoped to CRM and using a safe internal dummy record.

1. Sign in with the assigned account and MFA.
2. Open the Operations Cockpit, then the CRM Command Center; bookmark both
   (see `docs/CRM_RUNBOOK.md`, First-Day Setup And Access).
3. Confirm the five daily cards are visible and open.
4. Create one internal dummy record prefixed `GAIL-INTERNAL-WALKTHROUGH` via the
   New Signal card. Confirm it is the clean CRM - New Signals form, NOT the legacy
   Intake Register, and that no technical/automation fields appear.
5. Confirm the record appears in the Triage Queue and the next action is obvious.
6. Walk it forward: triage -> qualification -> next action -> handoff/evidence ->
   closeout/invoice watch.
7. Confirm the person can state what they must NOT touch (admin-only list).
8. Record friction, missing access, and the access review date.

Do not use a real client commitment, billing decision, guest invite, external
sharing link, app grant, public form, or unattended automation as the first-day
test.

## CRM escalation (what goes back to Adam)

Escalate (do not work around) when CRM work would touch: missing/broader access,
unclear client commitments, unclear invoice/payment status, duplicated or wrong
data, or anything requiring external sharing, guest access, app consent, public
Forms, production mail automation, deletes, Dynamics, Dataverse, or premium Power
Platform. Full detail and the escalation note format are in
`docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` and `docs/CRM_RUNBOOK.md`.

## Acceptance gate for this package

This package is complete when Adam can, for a specific person, answer without
guessing:

1. Employee/operator (A2) or trusted partner/operator (A3)?
2. Which exact live groups/permissions grant that level (read back, not from
   memory)?
3. What does "full access" mean for them, and what stays admin-only?
4. What first-day CRM walkthrough proves the role works?
5. What sends a CRM decision back to Adam?

The role model, walkthrough, and escalation answers exist now. Answer 2 (exact
live group names) is intentionally deferred to the read-back before any grant.
