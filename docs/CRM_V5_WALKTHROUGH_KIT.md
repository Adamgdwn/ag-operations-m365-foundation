# CRM V5 — Human Operator Walkthrough Kit (optional post-closeout evidence)

> **What this is:** the self-contained kit for the human MFA browser pass. V5 was
> accepted as operator-accepted on 2026-06-22, the exhaustive lifecycle walk was
> waived as a non-blocker, and Chunk 8 is closed. Everything a script *can* prove is
> already PASS (verifier 2026-06-21 11:53: **0 failures / 0 warnings / 184 checks**;
> both pages present, zero legacy routes). Keep this kit for an optional deeper
> manual lifecycle pass if Adam ever wants that evidence on record.
> **Owner:** Adam. **Created:** 2026-06-22.

---

## Current Status — ACCEPTED / OPTIONAL (2026-06-24)

**Status: V5 accepted; CRM recovery closed.** Adam reached the path and created a
new signal item on 2026-06-22. The intake felt **cumbersome**, so the front door was
streamlined to require only Title + NeedSummary; the verifier re-ran cleanly. Adam
then accepted the operator path and directed the Chunk 8 closeout. The full
lifecycle walk remains useful optional evidence, not a blocking gate.

**What was confirmed before pausing:** the click path works — Operations Cockpit →
CRM Command Center → New Signal reached the **clean `CRM - New Signals` form** (not
the legacy Intake Register), and a new item could be created. The remaining
lifecycle walk (triage → qualify → next action → handoff → closeout) and the formal
verdict were **not** completed, and were later waived as non-blocking.

**Optional first step before a fresh walk:** a dummy signal may be sitting in the live
`CRM - New Signals` list. If it was saved with **Person = `GAIL-INTERNAL-WALKTHROUGH`**,
run `node scripts/flow-builder/delete-test-records.js` (scoped to that exact prefix
— cannot touch a real signal). If it was saved with different values, delete it by
hand or tell Claude the title. Leaving it overnight is harmless (clearly internal).

**Then:** finish Steps 4–6 below only if Adam wants the optional manual lifecycle
walk captured after closeout.

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

> **STREAMLINED 2026-06-22:** the front door now requires **only 2 fields**
> (Signal summary + Need / opportunity) instead of 8 — this is the fix for the
> "cumbersome" finding that paused V5. Everything else is optional; the Choice
> fields still default sensibly (Referral / Direct / Normal / New). Part of the
> walk is confirming this lighter capture actually feels right.

On the clean `CRM - New Signals` form, enter these values. The
`GAIL-INTERNAL-WALKTHROUGH` text in **Person** is the cleanup key — keep it exact.

| Form field (display) | Internal name | Value to enter |
|---|---|---|
| Signal summary *(required)* | Title | `GAIL-INTERNAL-WALKTHROUGH — V5 acceptance` |
| Need / opportunity *(required)* | NeedSummary | `Internal V5 walkthrough — confirms the operator path end to end.` |
| Person *(optional)* | PersonName | `GAIL-INTERNAL-WALKTHROUGH` |
| Email *(optional)* | PersonEmail | `walkthrough@example.com` |
| Organization *(optional)* | OrganizationName | `Internal Test` |
| Signal type *(optional, default Referral)* | SignalType | `Referral` |
| Source *(optional, default Direct)* | IntakeSource | `Direct` |
| Priority *(optional, default Normal)* | Priority | `Normal` |
| Email or context paste *(optional)* | SourceText | `Manual capture during the V5 human acceptance pass.` |
| Next action *(optional)* | NextAction | `Triage, then walk through to closeout.` |
| Status *(optional, default New)* | SignalStatus | `New` |

Leave Follow-up date / Related link / Owner / Reminders / Track on blank (optional).

**First, test the streamlined capture:** fill ONLY the two required fields
(Signal summary + Need / opportunity) and save. Confirm it saves with just those
two — that is the new lighter front door. Then re-open the item and fill the rest
to continue the walk.

Tick:

- [ ] Only **2 fields** (Signal summary + Need / opportunity) were marked required.
- [ ] The form **saved with just those two filled** (the defaults supplied type /
      source / priority / status).
- [ ] The lighter capture feels acceptable (this is the V5 usability re-check).
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

## What happens after optional PASS

Claude records the added evidence into `docs/CRM_DEFERRED_VERIFICATION_LOG.md` (V5)
and `docs/CRM_RECOVERY_PLAN.md`. Chunk 8 is already closed; the Stage 8 packet
archive move still waits on Adam's explicit OK.
