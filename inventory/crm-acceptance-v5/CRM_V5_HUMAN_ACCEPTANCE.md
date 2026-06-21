# CRM V5 — Human Operator Acceptance Walkthrough

Deferred-verification item: **V5** (Chunk 6 — Browser And Operator Acceptance).
Spec: `docs/CRM_EXECUTION_PLAN.md` Chunk 6, `docs/CRM_ACCEPTANCE_TESTS.md`,
`docs/CRM_RUNBOOK.md`.

Operator: Adam Goodwin (signed in with MFA).
Date: 2026-06-21.
Mode: HUMAN browser pass. No script writes; the only tenant write is the one
dummy CRM record created through the normal operator UI.

Standing rule honoured: governance test — no permissions, guests, external
sharing, app consent, mail, public forms, deletes, Dynamics/Dataverse, or premium
Power Platform changes are part of this pass.

---

## Checkpoint 1 — Operations Cockpit reachable

URL: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx`

- [x] Cockpit opens; the CRM card is visible.

Observation: PASS (2026-06-21). Cockpit opens; CRM card visible and functioning.

## Checkpoint 2 — CRM Command Center + daily cards

URL: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx`

- [x] Command Center opens from the cockpit (not a raw list).
- [x] Daily cards present: Triage Queue, Follow Up Today, Proposal / Decision
      Blockers, Active Delivery, Closeout / Invoice Watch.
- [x] Card/section labels are business-facing (not system/field names).

Observation: PASS (2026-06-21). Six cards visible: New Signal, Triage Queue,
Follow Up Today, Proposal / Decision Blockers, Active Delivery, Closeout / Invoice
Watch. Labels business-facing.

## Checkpoint 3 — New Signal opens the CLEAN intake path

- [x] "New Signal" opens the `CRM - New Signals` intake form.
- [x] It does NOT land on `Guided AI Labs - Intake Register/NewForm.aspx`.
- [x] No technical/hidden fields on the form: SourceMailbox, SourceMessageId,
      ReceivedDate, IntakeStatus, ItemOwner, DurableHome, PlannerTaskUrl,
      CentralOSLink, GraphNodeId, AgentConfidence.

Observation: PASS (2026-06-21). Operator confirms New Signal opens the clean
`CRM - New Signals` form; fields are all business-facing, none of the 10 forbidden
technical fields appear.

## Checkpoint 4 — Create the dummy record

Enter by the form's DISPLAY labels (Person must be EXACTLY
`GAIL-INTERNAL-WALKTHROUGH` so the existing cleanup tool can remove it later).
Form label -> value (internal name in parens):

- Signal summary *: `GAIL-INTERNAL-WALKTHROUGH V5 acceptance` (Title)
- Person: `GAIL-INTERNAL-WALKTHROUGH` (PersonName)
- Email: `adamgoodwin@guidedailabs.com` (PersonEmail)
- Organization: `Guided AI Labs (internal test)` (OrganizationName)
- Signal type *: `Referral` (SignalType)
- Source *: `Direct` — leave at default (IntakeSource)
- Priority *: `Normal` (Priority)
- Need / opportunity *: `Internal V5 walkthrough — verifying the clean operator path` (NeedSummary)
- Email or context paste *: `Internal acceptance test record, safe to delete` (SourceText)
- Next action *: `Triage` (NextAction)
- Follow-up date: optional (today) (FollowUpDueDate)
- Related file/link: leave blank (RelatedLink)
- Status *: `New` (SignalStatus)
- Owner: leave blank (ItemOwner)

- [x] Required fields were clear; nothing technical was demanded.
- [x] Save succeeds.

Friction noted (2026-06-21): the original capture sheet listed internal column
names (Title, PersonName, NeedSummary...) instead of the form's business display
labels (Signal summary, Person, Need / opportunity...), and omitted the required
`Source` (IntakeSource) field. Form labels themselves are clean/business-facing
(CP3 still PASS); the mismatch was runbook-vs-form, now corrected above.

Observation: PASS (2026-06-21). Record saved through the clean New Signal form with
no technical field demanded; it appears in the **New Signal Queue** view
(`GAIL-INTERNAL-WALKTHROUGH V5 acceptance`, Status New, Type Referral, Source
Direct, Priority Normal). New item Id: _read from the list item when convenient —
needed only for the scoped cleanup later._

## Checkpoint 5 — Triage Queue visibility + obvious next action

- [x] The saved record appears in the queue (New Signal Queue, Status = New).
- [ ] The next action is obvious from the queue/record.

Observation: PARTIAL (2026-06-21). Record is visible in the New Signal Queue view
immediately after save. Still to confirm in-browser: move it into Triage and check
the next action reads obviously from the queue/record.

## Checkpoint 6 — Move through the pipeline

Move/mark the record forward (status + next action + owner + due date as you go):
triage -> qualification (or closure decision) -> next action -> handoff/evidence
pointer -> closeout/invoice watch route.

- [ ] Qualification or closure decision recorded.
- [ ] Next action visible.
- [ ] Delivery/handoff/evidence OR closeout/invoice route is visible when relevant
      (`CRM - Closeout Invoice Queue`).

Observation: _pending_

## Checkpoint 7 — Escalation clarity

- [ ] From the record/queues it is clear what to escalate to Adam (access,
      client commitments, billing ambiguity, data quality, automation, sharing,
      app consent, public forms, deletes, Dynamics/Dataverse, premium Power
      Platform).

Observation: _pending_

---

## Verdict

Result: _pending_

Friction / gaps found: _pending_

Cleanup: the dummy record (`PersonName == GAIL-INTERNAL-WALKTHROUGH`) can be
removed afterward via `scripts/flow-builder/delete-test-records.js` (scoped to that
exact PersonName) or manually from the list. Note its Id here: _pending_
