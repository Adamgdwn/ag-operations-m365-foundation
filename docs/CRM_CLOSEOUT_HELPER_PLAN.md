# CRM Closeout Helper — pre-close AI review (planned, not built)

Status: **PLANNED future work.** Not a recovery blocker. Raised 2026-06-21 (Adam,
during V5). Build in the natural pipeline progression "as we go" — do NOT build now.

## The idea (Adam's words, paraphrased)

When a signal reaches **Ready to Close**, an AI agent reviews the whole record and
runs a fuzzy match across all fields, then **flags** — "hey, there might be an issue
in X field" — before the record is closed out / sent to invoice. A last-second
quality gate that catches the mistype, the duplicate, the half-filled field, the
inconsistency, while it's still cheap to fix.

## Where it sits in the pipeline

```
New Signal → Triage → Qualification → Active Delivery → [READY TO CLOSE] → Closeout/Invoice
                                                              ▲
                                                   Closeout Helper runs HERE
```

It is the bookend to intake-assist:
- **Intake-assist** (front of pipeline): narrative → structured signal; normalize
  name/email/org on the way IN.
- **Closeout Helper** (back of pipeline): review the finished record on the way OUT.

Both lean on the SAME fuzzy-match / entity-resolution engine — build the matcher
once (see `docs/CRM_INTAKE_SURFACE_ALIGNMENT.md` → "Entity resolution"), call it at
both ends.

## What it checks (first cut)

1. **Entity dedup / fuzzy match.** Person & Organization vs existing People/Org
   lists — "this looks like an existing client 'John Smith'; you wrote 'Jon Smith'."
   Email is the strongest key.
2. **Completeness.** Required-for-close fields actually filled (owner, outcome,
   evidence pointer, invoice route when relevant) — not just required-at-intake.
3. **Internal consistency.** Status vs Next action vs dates agree (e.g. Status =
   Closed but Next action still "Triage"; Follow-up date in the past; Closeout route
   set but no evidence link).
4. **Provenance sanity.** SourceText / IntakeSource present and coherent for
   website-origin signals.
5. **Test-record guard.** Flag anything still carrying `GAIL-INTERNAL-WALKTHROUGH`
   or obvious placeholder text before it reaches invoice.

## Design rules (non-negotiable, match Adam's working style)

- **Advisory, never destructive.** It FLAGS; it does not auto-edit or auto-close.
  The operator decides. (Adam: non-destructive, one decision at a time.)
- **Non-blocking by default.** A flag is a heads-up, not a hard stop — operator can
  acknowledge and close anyway. (Could add an optional "block on hard issues" toggle
  later.)
- **Reads, doesn't write** (beyond an optional "reviewed" stamp the operator
  approves). No governance boundary crossed: no permissions, sharing, consent, mail,
  deletes, Dynamics/Dataverse, premium Power Platform.
- **Cheap-first.** Most checks are deterministic (rules + string distance); only the
  ambiguous "is this the same entity?" call needs the AI/extractor.

## Build sequencing (when we get there)

1. Land the shared fuzzy-match / entity-resolution engine (driven first by
   intake-assist need).
2. Add deterministic closeout checks (completeness + consistency + test-guard) —
   these need no AI and could ship as a simple review card on the Ready-to-Close /
   Closeout queue.
3. Layer the AI entity-dedup + narrative review on top.
4. Optional: "block on hard issues" toggle.

Slots into `docs/CRM_EXECUTION_PLAN.md` → "Future Work After Recovery" and the
Phase-2 operating-functions roadmap. Revisit after intake-assist design.
