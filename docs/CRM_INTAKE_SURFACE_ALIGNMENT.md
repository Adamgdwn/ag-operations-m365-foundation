# CRM Intake Surface Alignment (client form ↔ operator form)

Status: **QUEUED — approval-gated tenant write, not yet applied.**
Raised: 2026-06-21 (Adam, during V5 walkthrough).
Principle: the two intake front doors serve different perspectives (client vs
consultant) but should match **where practicable** — familiarity reduces friction.

## The two surfaces

- **Client front door:** public Microsoft Forms (Path B), one per brand
  (Guided AI Labs, Guided AI Journey). 7 questions. Built via
  `scripts/forms-builder/` + `scripts/flow-builder/`.
- **Operator front door:** SharePoint-native form on `CRM - New Signals`.
  14 fields. Defined in `config/crm.intake.json`.

Both write into the SAME list: `CRM - New Signals`.

## Alignment decision

### Make identical — shared "who + what" capture core
| Client form question | Operator field (internal) | Action |
|---|---|---|
| Full name | Person (PersonName) | relabel operator displayName → "Full name" |
| Email | Email (PersonEmail) | already match |
| Organization | Organization (OrganizationName) | already match |
| What are you looking for? | Need / opportunity (NeedSummary) | relabel operator displayName → "What are you looking for?" |

Plus **reorder** the operator Capture section to lead with Full name → Email →
Organization → What are you looking for?, BEFORE the triage fields. Fixes the
observed friction where Status rendered ahead of the human fields.

### Leave intentionally different (asymmetry is correct)
- Operator-only triage fields: Signal type, Source (IntakeSource), Priority,
  Status (SignalStatus), Next action, Follow-up date, Owner, Related link,
  Signal summary (Title, auto-derived by the flow on website signals).
- Client-only: consent ("I agree to be contacted about my enquiry.").

### Deferred to the intake-assist work (needs new operator columns)
- "Who is this for?" (intent) — currently folds into SourceText note.
- "How did you hear about us?" — currently folds into SourceText note.
Give each a discrete operator-visible column when we rework field vocabulary
during intake-assist; not bundled here.

### Entity resolution for Person / Organization (raised 2026-06-21, Adam)
Free-text Person/Org will accumulate mistypes and duplicates ("Jon" vs "John").
Today Person/Org are plain text. Target design, cheapest-first:
1. **Pick-from-existing:** Person/Organization become lookups (type-ahead) against
   the People/Org lists — returning clients are selected, not re-keyed.
2. **Free-text only for genuinely new contacts;** a new value becomes pickable next
   time.
3. **Fuzzy match / dedup on save:** near-matches surface "Did you mean…?" instead of
   silently forking a duplicate. Email is the strongest dedup key.
4. **Intake-assist normalizes:** the narrative→signal extractor canonicalizes
   name/email/org before write; match on email to absorb name variants.
NOTE: the V5 dummy record's exact `GAIL-INTERNAL-WALKTHROUGH` PersonName is a
test-cleanup key for `delete-test-records.js` ONLY — not a production data rule.
This is intake-assist scope (needs the People/Org lists wired as lookups); not in
the label/reorder bundle above.

## How to apply (when approved)
1. Edit `config/crm.intake.json` businessFields displayNames (PersonName →
   "Full name"; NeedSummary → "What are you looking for?") and the Capture
   section field order.
2. Re-apply via `Apply-CrmSharePoint.ps1` (gated: approval phrase
   `apply-gail-crm-recovery` + single Y). Bundle with the pending `[uint32]`
   RowLimit page-size fix = one apply, not two.
3. No schema/column change ⇒ Chunk 3 verifier unchanged, no re-run needed.

## Sequencing
Apply AFTER V5 acceptance is recorded — do not mutate the form schema underneath
the in-flight V5 walkthrough. Labels/order only; behavior unchanged.
