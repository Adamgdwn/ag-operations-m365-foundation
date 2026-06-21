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
- [x] Script completes without error and writes `inventory/crm-baseline/CRM_BASELINE_EXPORT.md`.
- [x] CSVs + JSON snapshot exist alongside it (lists, fields, lookups, views,
      blocked-fields, intake-fields, pages, navigation).
- [x] The "Observations" table is populated (it is fine for counts to be
      non-zero — this is the BEFORE picture, not a verdict).
- [x] No write occurred (transcript shows only Get-PnP* reads, no Set/Add/New/Remove).

Result: PASS (run 2026-06-20 22:26). Exit 0. Headline counts: Lists missing 0 |
Blocked-visible 0 | Nav-legacy 0. Ran headless via a valid cached M365 token (the
interactive pop-up stalled on PnP 3.2.0's slow first-load; the cached token made
the read run cleanly without a browser sign-in).
Evidence: `inventory/crm-baseline/CRM_BASELINE_EXPORT.md` (+ run log
`inventory/crm-baseline/_v1_run.log`, transcript `crm-baseline-20260620-222649.log`).

---

## V2 — Chunk 3 verifier, RED run on current tenant (READ-ONLY, no approval phrase)

Status: BUILT + RUN 2026-06-20.

Purpose: prove the new verifier actually FAILS on the known-bad operator path
(it must not false-pass the way the Stage 8C verifier did).

Run:
- Launch `scripts/spo/Start-CrmVerifyInteractive.ps1`, complete the sign-in.

Confirm:
- [x] Script completes and writes `inventory/crm-verify/CRM_VERIFY.md`.
- [x] Overall Result is FAIL **if** the tenant still has any: blocked technical
      field visible (DefaultTrue/True) on `CRM - New Signals`, nav node or page
      body routing to `Guided AI Labs - Intake Register/NewForm.aspx`, or a
      missing required list/field/view. (FAILs on the missing `IntakeSource`
      field, which V4/Chunk 5 creates — correct.)
- [x] The summary lists each specific failure with the field/list/url that caused it.
- [x] A "Manual browser checks still required" section is present (the New button
      experience can only be fully proven by a human in Chunk 6).

Result: PASS (the verifier correctly returns FAIL on the not-yet-applied tenant —
that is V2's success criterion). Run 2026-06-20 22:39, exit 1 (= FAIL signal).

VERIFIER BUG FOUND + FIXED during this run: the first run reported 9 failures, but
6 were phantom — `@($list.lookupFields)` / `@($list.views)` on the three
`durable-lookup-target` lists (Organizations, Contacts, Engagements, which define
no lookups/views of their own) produced a one-element array containing `$null`,
so the loop ran once with a blank identity, `Get-PnPField` returned every field,
and it logged a bogus Fail. Guarded all three loops in
`scripts/spo/Verify-CrmSharePoint.ps1` to skip null/empty elements (skip-only-when-
empty, so it can never mask a real check). Re-run is clean: **3 failures, all the
expected missing `IntakeSource`** (Column / Intake field / Required field), plus 6
required-field WARNINGS (SignalType, Priority, NeedSummary, SourceText, NextAction,
SignalStatus currently Required=False) that the V4 apply will set. After V4 the
verifier must return PASS.
Evidence: `inventory/crm-verify/CRM_VERIFY.md` (post-fix 3-fail run), run logs
`inventory/crm-verify/_v2_run.log` (initial 9-fail) + `_v2_rerun.log` (3-fail),
checks CSV `crm-verify-checks-20260620-223702.csv`.

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
- [x] With no args, each prints a clear plan of intended tenant changes and makes NO writes.
- [x] With `-Apply` but no/wrong approval phrase, each REFUSES and exits without writing.
- [x] The printed plan matches the three config files (lists/fields/views, intake
      form hiding the blocked fields, navigation cards, admin-only legacy fallback).

Result: PASS (verified OFFLINE 2026-06-20 — these checks need no sign-in; the
dry-run and refusal paths exit before any tenant connection). Confirmed:
SPO dry-run exit 0 with full plan; SPO -Apply (no phrase) exit 2 REFUSED;
SPO -Apply wrong phrase exit 2 REFUSED; Portal dry-run exit 0 with plan incl.
"MUST NOT route to legacy"; Portal -Apply (no phrase) exit 2 REFUSED.
Evidence: re-runnable via `pwsh scripts/spo/Apply-CrmSharePoint.ps1 -NoPause`
(and `-Apply` variants); plan files land under `inventory/crm-apply/`.

NOTE: the WRITE path itself (lists/fields/views actually created, blocked fields
actually hidden) is exercised only under approval in V4 — that part is still
deferred.

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

## V6 — Exact CRM access-group read-back (DECISION input, before any grant)

Status: BUILT package depends on it; not yet read back.

Purpose: the CRM Onboarding Package records the role->level decision (A2 employee
/ A3 trusted partner) but deliberately does NOT guess live group names. Before
granting anyone CRM access, read back the live SharePoint/Microsoft 365 groups.

Run:
- During the V1 baseline sign-in (or any read-only PnP session), capture the
  live group/permission names for the GuidedAILabs site.

Confirm:
- [x] Exact M365 group for internal members confirmed: site group **`Guided AI Labs
      Members`** (Id 5), backed by M365 group
      `GuidedAILabs@AGOperationsLtd.onmicrosoft.com`.
- [x] Exact SharePoint permission group name for CRM contributors (A2) recorded:
      **`Guided AI Labs Members`** (grant a contributor level — `Contribute` or
      `Edit`; both exist as role definitions).
- [x] Exact SharePoint permission group/role for full operating access (A3)
      recorded: **`Guided AI Labs Owners`** (Id 3) / `Full Control`. (`Guided AI
      Labs Visitors`, Id 4, is empty.)
- [ ] Filled into `docs/CRM_ONBOARDING_PACKAGE.md` "Exact access-group notes"
      (pending — names captured here; copy in next time that doc is opened).

Result: PASS (read-only, run 2026-06-20 22:39, exit 0). Available permission levels:
Contribute, Design, Edit, Full Control, Limited Access, Read. Site collection
admins: Adam Goodwin (admin@agoperations.ca and adamgoodwin@guidedailabs.com) +
the Owners group. Note: the M365 group's exact friendly address should still be
confirmed in the Entra/M365 admin portal before any external grant.
Evidence: `inventory/crm-access/CRM_ACCESS_GROUPS.md` (+ `_v6_run.log`).

---

## V7 — Path B build: two brand Forms + create-only intake flow (PORTAL BUILD; scoped unlock)

Status: AUTHORIZED design (commit pending); built in a gated portal session.
Depends on V4 (the `IntakeSource` field must exist on `CRM - New Signals`).
Spec: `docs/CRM_PUBLIC_INTAKE_PATH_B.md`.

Scoped unlock in force for this item ONLY: public Forms links + unattended
automation are permitted for exactly the two named intake forms and the single
create-only flow. Everything else in the safety list stays in force.

Run (Microsoft 365 portals, not PnP):
- Create the **Guided AI Labs** and **Guided AI Journey** anonymous Forms with the
  content in the spec (name, email, org, need, how-heard, consent).
- Build the create-only Power Automate flow(s): Forms response -> Get details ->
  Create item in `CRM - New Signals` with the spec's field mapping. Standard
  connectors only.

Confirm:
- [ ] Both forms accept an anonymous submission.
- [ ] The flow creates a `CRM - New Signals` item with `SignalType=Website`,
      `SignalStatus=New`, `Priority=Normal`, and `Source` = the correct brand.
- [ ] Capture provenance lands in the hidden fields (`SourceMessageId`,
      `ReceivedDate`, `IntakeStatus=Auto-captured`, `SourceMailbox`=form name).
- [ ] The flow has NO mail send / auto-reply / update / delete / external action.
- [ ] No premium connector, Dynamics, or Dataverse is used.

Result: _pending_
Evidence: _flow name + run history link_

---

## V8 — Path B end-to-end + verifier still PASS (HUMAN PASS)

Status: _pending (do only after V7)_

Run:
- Submit one dummy response on EACH brand form, prefixed `GAIL-INTERNAL-WALKTHROUGH`.
- Submit at least one of those via the LIVE website CTA (Join B), not only the
  direct form link, to prove the website→form→flow→CRM chain end to end.
- Re-run the Chunk 3 verifier (V2).

Confirm:
- [ ] Each dummy submission appears in the New Signal Queue with the correct
      `Source` brand and is triageable like any manual signal.
- [ ] No technical/automation field appears on the `CRM - New Signals` form
      despite the flow having written to the hidden ones.
- [ ] The Chunk 3 verifier still returns PASS (no blocked field became visible;
      no daily route points at the legacy Intake Register).
- [ ] Delete/close the two dummy records after the test.

Result: _pending_
Evidence: _path/notes_

---

## Log

- 2026-06-20: Log created. V1 (Chunk 2 baseline) built, awaiting run.
- 2026-06-20: V2 (Chunk 3 verifier) built, awaiting sign-in run. Decision helpers
  (form-flag visibility incl. DefaultTrue, legacy-route detection) unit-tested
  offline and pass.
- 2026-06-20: V3 (Chunk 4 dry-run + refusal gate) BUILT and VERIFIED OFFLINE —
  PASS. Only the approved write path (V4) remains deferred.
- 2026-06-20: Chunk 7 onboarding package built (extended CRM_RUNBOOK.md +
  new CRM_ONBOARDING_PACKAGE.md, both referencing the existing access model, no
  duplication). V6 (exact CRM group-name read-back) added as a pre-grant input.
- 2026-06-20: Path B authorized (public brand intake). Added operator-visible
  `Source` (`IntakeSource`) field to `config/crm.intake.json` +
  `config/crm.sharepoint.json` (created by the Chunk 5 apply). Wrote
  `docs/CRM_PUBLIC_INTAKE_PATH_B.md` spec, logged the decision + scoped
  governance unlock in CRM_DECISIONS.md. Added V7 (Forms+flow portal build) and
  V8 (end-to-end + verifier-still-PASS). Build deferred to the gated session.
- 2026-06-20: READ-ONLY session run (V1 + V2 + V6) — all PASS. Interactive
  pop-ups stalled on PnP 3.2.0 first-load; a valid cached M365 token let the three
  read-only scripts run headless (no browser sign-in, no writes). V1 baseline clean
  (0/0/0). V2 verifier correctly FAILs; FOUND + FIXED a phantom-failure bug in
  `Verify-CrmSharePoint.ps1` (null-element iteration on durable-lookup-target
  lists) — failures 9→3, the 3 remaining are the expected missing `IntakeSource`.
  Added `scripts/spo/Read-CrmAccessGroups.ps1` (new read-only V6 tool) and captured
  live access groups: members = `Guided AI Labs Members`, owners = `Guided AI Labs
  Owners`. Next gated step is V4 (Chunk 5 apply, needs phrase
  `apply-gail-crm-recovery`), after which V2 must re-run to PASS.
