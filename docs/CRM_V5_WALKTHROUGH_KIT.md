# CRM V5 — Human Operator Walkthrough Kit (Chunk 6 acceptance)

> **What this is:** the self-contained kit for the one CRM gate a script cannot
> close — the human MFA browser pass. Everything a script *can* prove is already
> PASS (verifier 2026-06-21 11:53: **0 failures / 0 warnings / 184 checks**; both
> pages present, zero legacy routes). This kit makes your pass ~10 minutes and
> produces exactly the evidence Chunk 8 needs to close.
> **Owner:** Adam. **Created:** 2026-06-22.

---

## ⏸ PAUSED — RESUME HERE (2026-06-22)

**Status: V5 IN PROGRESS, paused mid-pass.** Adam opened the path and created a new
signal item, then stopped — the intake felt **cumbersome** (fatigue noted as a
caveat, but logged as a genuine usability observation, not dismissed). Boxed up to
continue another session.

**What was confirmed before pausing:** the click path works — Operations Cockpit →
CRM Command Center → New Signal reached the **clean `CRM - New Signals` form** (not
the legacy Intake Register), and a new item could be created. The remaining
lifecycle walk (triage → qualify → next action → handoff → closeout) and the formal
verdict were **not** completed.

**Open finding to weigh next session:** the daily intake felt cumbersome. Decide
deliberately — (a) accept it (works, just verbose) and finish the walk to PASS, or
(b) treat the friction as real and streamline the front door *before* declaring
PASS (e.g. fewer required fields — the `crm.intake.json` "requiredVsCardPlanNote"
already flags a required-fields UX call; a quick-add/Power Apps front door is
listed under CRM "Future Work"). This is Adam's call.

**First step on resume — cleanup:** a dummy signal may be sitting in the live
`CRM - New Signals` list. If it was saved with **Person = `GAIL-INTERNAL-WALKTHROUGH`**,
run `node scripts/flow-builder/delete-test-records.js` (scoped to that exact prefix
— cannot touch a real signal). If it was saved with different values, delete it by
hand or tell Claude the title. Leaving it overnight is harmless (clearly internal).

**Then:** either finish Steps 4–6 below, or take the front-door-UX decision first.

---

## Before you start

- Sign in as a **normal operator** (MFA), *not* as admin — the whole point is to
  see what a capable employee/partner sees.
- Have this file open to tick the evidence boxes as you go.
- You will create **one** dummy record and then delete it at the end (reusing the
  existing scoped-delete script — see Cleanup).

---

## Step 1 — The click path (Browser Path Test)

```
Operations Cockpit  →  CRM Command Center card  →  New Signal  →  CRM - New Signals form
```

Tick as each holds true:

- [ ] Operations Cockpit opens (`Guided-AI-Labs-Operations-Cockpit.aspx`).
- [ ] The **CRM Command Center** card opens the command center page
      (`Relationship-CRM-Command-Center.aspx`).
- [ ] The **New Signal** action opens the **clean `CRM - New Signals` form** —
      NOT `Guided AI Labs - Intake Register/NewForm.aspx`.
- [ ] CRM Command Center labels are business-facing (no raw list names / technical jargon).
- [ ] After save, the **next action is obvious** (you can see where the record went).

---

## Step 2 — Create the dummy record

On the clean `CRM - New Signals` form, enter exactly these values. The
`GAIL-INTERNAL-WALKTHROUGH` text in **Person** is the cleanup key — keep it exact.

| Form field (display) | Internal name | Value to enter |
|---|---|---|
| Signal summary *(required)* | Title | `GAIL-INTERNAL-WALKTHROUGH — V5 acceptance` |
| Person | PersonName | `GAIL-INTERNAL-WALKTHROUGH` |
| Email | PersonEmail | `walkthrough@example.com` |
| Organization | OrganizationName | `Internal Test` |
| Signal type *(required)* | SignalType | `Referral` |
| Source *(required)* | IntakeSource | `Direct` |
| Priority *(required)* | Priority | `Normal` |
| Need / opportunity *(required)* | NeedSummary | `Internal V5 walkthrough — confirms the operator path end to end.` |
| Email or context paste *(required)* | SourceText | `Manual capture during the V5 human acceptance pass.` |
| Next action *(required)* | NextAction | `Triage, then walk through to closeout.` |
| Status *(required)* | SignalStatus | `New` |

Leave Follow-up date / Related link / Owner / Reminders / Track on blank (optional).

Tick:

- [ ] All **8 required** fields were clearly marked and accepted the values.
- [ ] The form saved without error.

---

## Step 3 — Hidden Field Test (while the form is open)

Confirm **none** of these technical fields appear anywhere on the new/edit form:

- [ ] None visible: `SourceMailbox`, `SourceMessageId`, `ReceivedDate`,
      `IntakeStatus`, `DurableHome`, `PlannerTaskUrl`, `CentralOSLink`,
      `GraphNodeId`, `AgentConfidence`, `op_CalendarEventId`, `op_PlannerTaskId`,
      `op_LastSyncedDue`, `op_SyncNote`.
- [ ] **Owner** (`ItemOwner`), **Reminders** (`op_Reminders`), **Track on**
      (`op_TrackOn`) *are* present — these are intentionally operator-facing.

---

## Step 4 — Walk the lifecycle (Workflow Test)

Move the same record through each stage. You can do this by editing Status /
Next action and using the command center cards/views.

- [ ] **Triage:** the saved record appears in the Triage / New Signal Queue.
- [ ] **Qualify:** record a qualification or closure decision (e.g. set Status to
      a qualified/working value; note the next action).
- [ ] **Next action:** the next action and owner/status/due are visible.
- [ ] **Handoff / evidence:** you can see where proposal / evidence / handoff
      links live (RelatedLink or the delivery route).
- [ ] **Closeout / invoice:** you can find the `CRM - Closeout Invoice Queue`
      route for final evidence + invoice handoff + closure.

---

## Step 5 — Governance + escalation read (sanity)

- [ ] Nothing in the daily path asked you to change permissions, invite guests,
      widen sharing, grant app consent, send mail, create public forms, delete, or
      touch Dynamics/Dataverse.
- [ ] You can tell **what to escalate to Adam**: access problems, client
      commitments, billing ambiguity, data-quality problems, automation, sharing,
      app consent, production mail, public forms, deletes, Dynamics/Dataverse,
      premium Power Platform.

---

## Step 6 — Record the verdict

Fill this in, then tell Claude "V5 done" (paste this block back or just the result):

```
V5 result:        PASS / FAIL
Date / signer:    2026-06-__  /  Adam Goodwin (operator MFA)
Friction found:   <none, or list each item>
Screenshots:      <path, if captured>
```

---

## Cleanup — delete the dummy record

The dummy uses `PersonName == GAIL-INTERNAL-WALKTHROUGH`, which is exactly the
filter the existing scoped-delete script targets — so cleanup is one command, and
it **cannot** match a real signal:

```
node scripts/flow-builder/delete-test-records.js
```

It lists the matching `GAIL-INTERNAL-WALKTHROUGH` record(s), deletes them, and
verifies 0 residue. (Run by Claude under the standing scoped-delete authorization,
or by you.)

---

## What happens after PASS

Claude records the evidence into `docs/CRM_DEFERRED_VERIFICATION_LOG.md` (V5) and
`docs/CRM_RECOVERY_PLAN.md`, then closes **Chunk 8** (final supersession/closeout;
the Stage 8 packet archive move still waits on your explicit OK). CRM is then fully
sealed.
