# CRM Recovery — Deferred Verification Log

Purpose: a single checklist of every test that was BUILT but not yet RUN,
because running it needs an interactive Microsoft sign-in, the tenant-write
approval phrase, or a human browser pass. Adam works down this list in one
focused session instead of stopping mid-build each time.

How to use:
1. Run the items top to bottom (they are ordered by dependency).
2. For each, do the "Run" step, then check the "Confirm" boxes against the
   evidence the run produces.
3. Mark `Result:` PASS/FAIL and paste the evidence path. If FAIL, note what
   broke; that becomes the next fix.

Standing rules in force:
- Read-only items need only a sign-in (no approval phrase).
- Tenant-write items require Adam to type the approval phrase
  `apply-gail-crm-recovery` AND a single Y confirmation.
- Safety limits: no permission changes, guest invites, external sharing, app
  consent, public forms, mail sends, deletes, unattended automation, or
  Dynamics/Dataverse.

---

## V1 — Chunk 2 baseline export (READ-ONLY, no approval phrase)

Status: BUILT 2026-06-20 (commit f842d7a). Not yet run.

Run:
- Launch `scripts/spo/Start-CrmBaselineExportInteractive.ps1`, complete the
  Microsoft sign-in.

Confirm:
- [ ] Script completes without error and writes `inventory/crm-baseline/CRM_BASELINE_EXPORT.md`.
- [ ] CSVs + JSON snapshot exist alongside it (lists, fields, lookups, views,
      blocked-fields, intake-fields, pages, navigation).
- [ ] The "Observations" table is populated (it is fine for counts to be
      non-zero — this is the BEFORE picture, not a verdict).
- [ ] No write occurred (transcript shows only Get-PnP* reads, no Set/Add/New/Remove).

Result: _pending_
Evidence: _path here_

---

## V2 — Chunk 3 verifier, RED run on current tenant (READ-ONLY, no approval phrase)

Status: _pending build_

Purpose: prove the new verifier actually FAILS on the known-bad operator path
(it must not false-pass the way the Stage 8C verifier did).

Run:
- Launch `scripts/spo/Start-CrmVerifyInteractive.ps1`, complete the sign-in.

Confirm:
- [ ] Script completes and writes `inventory/crm-verify/CRM_VERIFY.md`.
- [ ] Overall Result is FAIL **if** the tenant still has any: blocked technical
      field visible (DefaultTrue/True) on `CRM - New Signals`, nav node or page
      body routing to `Guided AI Labs - Intake Register/NewForm.aspx`, or a
      missing required list/field/view.
- [ ] The summary lists each specific failure with the field/list/url that caused it.
- [ ] A "Manual browser checks still required" section is present (the New button
      experience can only be fully proven by a human in Chunk 6).

Result: _pending_
Evidence: _path here_

---

## V3 — Chunk 4 apply dry-run (NO WRITES; refuses write mode without phrase)

Status: _pending build_

Purpose: prove the apply scripts default to dry-run, print the intended change
plan, and refuse to write without the approval phrase.

Run (no sign-in needed for the refusal check; sign-in needed for full plan):
- `pwsh scripts/spo/Apply-CrmSharePoint.ps1`            (expect: dry-run plan)
- `pwsh scripts/spo/Apply-CrmSharePoint.ps1 -Apply`     (expect: REFUSED, no phrase)
- `pwsh scripts/portal/Apply-CrmPortal.ps1`             (expect: dry-run plan)
- `pwsh scripts/portal/Apply-CrmPortal.ps1 -Apply`      (expect: REFUSED, no phrase)

Confirm:
- [ ] With no args, each prints a clear plan of intended tenant changes and makes NO writes.
- [ ] With `-Apply` but no/wrong approval phrase, each REFUSES and exits without writing.
- [ ] The printed plan matches the three config files (lists/fields/views, intake
      form hiding the blocked fields, navigation cards, admin-only legacy fallback).

Result: _pending_
Evidence: _path here_

---

## V4 — Chunk 5 tenant apply (WRITES; REQUIRES approval phrase + single Y)

Status: _pending (do only after V2 + V3 pass)_

Run:
- Provide approval phrase `apply-gail-crm-recovery`, then run the apply scripts in
  write mode and confirm the single Y prompt.

Confirm:
- [ ] `CRM - New Signals` intake form shows only the clean business fields; all 9
      blocked technical fields are hidden (ShowInNewForm=false AND ShowInEditForm=false).
- [ ] CRM Command Center page + daily cards exist; the New Signal card opens the
      clean intake, NOT the legacy Intake Register.
- [ ] `CRM - Closeout Invoice Queue` list/views applied.
- [ ] Legacy Intake Register link, if present, is labelled admin-only and absent
      from every daily card/nav node.
- [ ] Re-running V2 (the verifier) now returns PASS.

Result: _pending_
Evidence: _path here_

---

## V5 — Chunk 6 human browser/operator acceptance (HUMAN PASS)

Status: _pending (do only after V4 passes)_

Run:
- Sign in with MFA as a normal operator. Open Operations Cockpit → CRM Command
  Center. Create one dummy record prefixed `GAIL-INTERNAL-WALKTHROUGH` and move it
  through triage → qualification → next action → handoff/evidence → closeout/invoice.

Confirm:
- [ ] New Signal path never lands on a technical/admin intake route.
- [ ] Required fields are clear; no hidden/technical fields appear in the daily path.
- [ ] The dummy record is visible in the Triage Queue and the next action is obvious.
- [ ] You can tell what to escalate to Adam (access, billing, commitments, automation, etc.).

Result: _pending_
Evidence: _notes + screenshots path_

---

## Log

- 2026-06-20: Log created. V1 (Chunk 2 baseline) built, awaiting run.
