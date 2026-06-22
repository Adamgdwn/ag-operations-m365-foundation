# Master Execution Map

> **What this is:** the single page that places *every* piece of work in this
> project on one pathway, so no session ever sprints on a tile without seeing the
> whole board. Open this first, then drill into the canonical roadmap or a
> specific function plan.
> **Status:** master map. Points to the canonical sources; does not replace them.
> **Owner:** Adam (absolute superuser). **Last updated:** 2026-06-22 (Phase 1 complete; Phase 2 — CRM + Bookings + Follow-up backbone all LIVE).

Canonical sources this map sits over:
[M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) (the spine),
[00_INDEX.md](00_INDEX.md) (the document map),
[docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md) (the function backlog).

---

## 0. The one idea that organises everything

There are **two fundamentally different kinds of work**, and they must not be run
the same way:

| | **Phase 1 — Infrastructure (the spine)** | **Phase 2 — Functions (operate it)** |
|---|---|---|
| What | Identity, records, governance, the substrate and safety rails | Onboarding, CRM, delivery, finance, support — how *Adam* actually operates |
| Whose decisions | Generic — roughly the same for any operator | Specific — encodes Adam's judgment, roles, and choices |
| How it's built | Agent builds most of it; Adam approves gates | **Interactive** — Adam drives each one; takes real time from him |
| How often | Built **once**, then done | A series of **mini-projects**, one at a time |
| Order | Strict sequence (Stages 0→9) | **No forced order** — pick the function that matters most next |

**The pathway in one line:** finish the shared infrastructure once → then walk
down each function deliberately, with Adam, one at a time.

---

## 1. Phase 1 — the infrastructure spine (Stages 0–9)

The canonical 10-stage roadmap. This is the "alphabet." Status as of 2026-06-20:

| Stage | Name | Status |
|---|---|---|
| 0 | Setup Control Room | ✅ Done |
| 1 | Current-State Inventory | ✅ Done |
| 2 | Identity & Admin Foundation | ✅ Done |
| 3 | SharePoint Information Architecture | ✅ Done |
| 4 | OneDrive / Local Machine Dovetail | ✅ Done |
| 5 | Exchange & Communication Routing | ✅ Design complete (no writes needed yet) |
| 6 | Teams / Planner / Lists / Operating State | ✅ Live, verified |
| 7 | Security, Governance & External Sharing | ✅ Closed 2026-06-20 — support MFA registered, Viva Engage external sharing disabled, app grants left consented (accepted risk); closeout recorded in Decision Register + Agent Action Log |
| 8 | Client Workspace Reference Pattern | ✅ Cockpit + CRM live; usability Chunks 1–7 done |
| 9 | Agentic OS Bridge Readiness | ✅ Declared ready 2026-06-20 — production adapter **intentionally deferred** (the later bridge); closeout recorded in the registers |

**Spine work remaining: none — Phase 1 is complete (2026-06-20).** The three
final interactive actions are done: (a) support-mailbox MFA registered, (b) Viva
Engage external sharing disabled (gated apply), (c) the Stage 7 + Stage 9 closeout
records written to the Decision Register + Agent Action Log (single-Y apply). The
production agentic adapter remains **intentionally deferred** — the "cross that
bridge later" decision, made deliberately, not spine work. The substrate is now
"finished once"; the project moves to Phase 2 (operating functions).

> Note: the **Workspace Usability pass (Chunks 1–7)** was not a separate roadmap —
> it lived *inside* Stage 8 and is how the workspace became operator-ready. Done
> and pushed. See [docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md](docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md).

---

## 2. Phase 2 — the functions (the ten operating cards)

Once the spine is finished, the project becomes **operating the substrate with
real workflows**. These are already mapped as the ten operating cards in
[docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md). Each is its own interactive
build-out with Adam — **pick the one that matters most next; there is no forced
order among them.**

**Status as of 2026-06-22:** the first function (**CRM / Relationships**) was
chosen and built end-to-end, and two adjacent functions came online on top of it.
Three things are now LIVE and verified; the rest remain plan-only.

| Function (card) | Plan file | Build-out state |
|---|---|---|
| Workspace Home | [docs/CARD_PLAN_WORKSPACE_HOME.md](docs/CARD_PLAN_WORKSPACE_HOME.md) | Plan + live cockpit |
| **CRM / Relationships** | [docs/CARD_PLAN_CRM_RELATIONSHIPS.md](docs/CARD_PLAN_CRM_RELATIONSHIPS.md) | ✅ **LIVE** — full website→CRM intake loop verified both brands (Path B); intent field done; test records cleaned. One gate open: **V5** (portal human-browser pass + page authoring) + Chunk 8 doc closeout. Build via [docs/CRM_EXECUTION_PLAN.md](docs/CRM_EXECUTION_PLAN.md) |
| **Bookings / Scheduling** | [docs/BOOKINGS_SCHEDULING_PLAN.md](docs/BOOKINGS_SCHEDULING_PLAN.md) | ✅ **LIVE** — native MS Bookings page (anon-verified), website→Bookings→CRM loop verified, 0 residue. CRM intake consumer #2 |
| **Operations Follow-up Backbone** | (see memory: operations-followup-backbone) | ✅ **LIVE** — all 3 layers (Email + two-way Calendar + one-way Planner) verified; one 15-min sync engine drives reminders/calendar/Planner off CRM |
| Delivery / Projects | [docs/CARD_PLAN_DELIVERY_PROJECTS.md](docs/CARD_PLAN_DELIVERY_PROJECTS.md) | Plan only |
| Decisions / Governance | [docs/CARD_PLAN_DECISIONS_GOVERNANCE.md](docs/CARD_PLAN_DECISIONS_GOVERNANCE.md) | Plan only |
| Tasks / Actions | [docs/CARD_PLAN_TASKS_ACTIONS.md](docs/CARD_PLAN_TASKS_ACTIONS.md) | Plan only |
| Knowledge / Records | [docs/CARD_PLAN_KNOWLEDGE_RECORDS.md](docs/CARD_PLAN_KNOWLEDGE_RECORDS.md) | Plan only |
| Support / Intake | [docs/CARD_PLAN_SUPPORT_INTAKE.md](docs/CARD_PLAN_SUPPORT_INTAKE.md) | Plan only |
| Finance / Closeout | [docs/CARD_PLAN_FINANCE_CLOSEOUT.md](docs/CARD_PLAN_FINANCE_CLOSEOUT.md) | Plan only |
| Agent Control Plane | [docs/CARD_PLAN_AGENT_CONTROL_PLANE.md](docs/CARD_PLAN_AGENT_CONTROL_PLANE.md) | Plan + Stage 9 readiness |
| **Access / Onboarding** | [docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md](docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md) | Active access model (net-new pieces need §3 reconcile first) |

---

## 3. Where the new-hire onboarding work fits

The "one-click new hire" work is **the Access / Onboarding function** in Phase 2 —
not a new stage, and not a greenfield area. Parts of it already exist and must be
**reconciled, not duplicated**:

| Onboarding piece | Already lives in |
|---|---|
| Role tiers, access matrix, first-day walkthrough, escalation | [docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md](docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md) |
| Partner/client onboarding checklist, training path, readiness scorecard | [inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md](inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md) |
| Daily-use / first-day operator guide | [docs/WORKSPACE_INSTRUCTION_MANUAL.md](docs/WORKSPACE_INSTRUCTION_MANUAL.md) |
| Governance ladder G0–G4 + approval pattern | [docs/AGENTIC_M365_READINESS.md](docs/AGENTIC_M365_READINESS.md) |

The **net-new** parts (not yet anywhere): the requisition / "start-before" stage,
the hiring funnel, the Role Library as reusable templates, and the one-click
packet assembler. These are drafted in
[People/PEOPLE_NEW_HIRE_ONBOARDING_PLAN.md](People/PEOPLE_NEW_HIRE_ONBOARDING_PLAN.md),
which must be **folded into the artifacts above** so there is one onboarding
source of truth — that reconcile is step ③ below, before any net-new build.

---

## 4. The master pathway, in sequence

```
PHASE 1 — INFRASTRUCTURE (finished once)  ✅ COMPLETE 2026-06-20
  ✅ Stages 0–6, Stage 8 + Chunks 1–7        substrate built, workspace usable
  ✅ Spine closeout = 3 interactive Adam actions, all done:
       a. Register support-mailbox MFA            (done)
       b. Disable Viva Engage external sharing    (gated apply, done)
       c. Stage 7 + Stage 9 closeout records      (single-Y apply, done)
     ▸ Production agentic adapter = intentionally deferred (the later bridge)
        └─ the spine is DONE

PHASE 2 — FUNCTIONS (interactive, one at a time, Adam-driven, any order)  ← CURRENT FOCUS
  ✅ CRM / Relationships built end-to-end + LIVE (Path B intake loop, intent field, cleanup)
       └─ one gate open: V5 (portal browser pass + page authoring) + Chunk 8 doc closeout
  ✅ Bookings / Scheduling LIVE  (native MS Bookings → CRM, intake consumer #2)
  ✅ Operations Follow-up Backbone LIVE  (Email + two-way Calendar + one-way Planner; 15-min sync engine)
     ▸ NEXT: close CRM V5, then pick the next function to build out
     ③ Reconcile onboarding into existing artifacts   (do before any onboarding build)
     ④ Build the next chosen function end-to-end       (onboarding, delivery, finance, support, …)
     ⑤ Operate it live                                (e.g. first real hire — needs a license seat)
```

**Plain reading:** the spine is complete and the first function (CRM) plus two
adjacent functions (Bookings, Follow-up backbone) are LIVE → close the one open CRM
gate (V5), then pick the next function and build it out with Adam. Repeat per
function. The open decision is §6: which function next.

---

## 5. How to use this map each session

1. Open this map. Confirm where the spine stands (§1) and which function is active (§2).
2. The spine (§1) is complete — no infrastructure items remain. If a function has an open gate (e.g. CRM V5, §4), work that.
3. If building a function, open its plan file from §2 first — **never start a function build without its plan**, and for onboarding do the reconcile (§3) first.
4. Keep the governance model: G0/G1 free, G2 single-`Y`, G3 gated/Adam-only, G4 blocked.
5. Update §1 status and the active-function note in §2 when a stage or function changes state.

---

## 6. Open decision for Adam

- **Resolved:** the first function was **CRM / Relationships** — built end-to-end
  and LIVE, with **Bookings** and the **Operations Follow-up Backbone** coming
  online on top of it.
- **Open now — two parts:**
  1. **Close CRM V5** (portal human-browser pass + page authoring) + Chunk 8 doc
     closeout — the one remaining gate before CRM is fully sealed.
  2. **Which function gets built out next?** Onboarding is drafted (needs the §3
     reconcile first), but Delivery, Finance, or Support could each be higher
     value. No forced order — Adam's call.
