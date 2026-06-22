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

Status: DONE 2026-06-20 (SharePoint apply run + verifier PASS).

Run:
- Provide approval phrase `apply-gail-crm-recovery`, then run the apply scripts in
  write mode and confirm the single Y prompt.

Confirm:
- [x] `CRM - New Signals` intake form shows only the clean business fields; all 9
      blocked technical fields are hidden (ShowInNewForm=false AND ShowInEditForm=false).
      (Verifier confirms 0 blocked-visible; apply log: all 9 "absent (good)".)
- [~] CRM Command Center page + daily cards exist; the New Signal card opens the
      clean intake, NOT the legacy Intake Register. (Nav/page routing proven clean
      by the verifier — 0 nav-legacy, 0 page-route-legacy. The page-section/web-part
      AUTHORING is a manual interactive task and rolls into V5; the portal apply
      script's only write action is flag-detection of legacy nodes, none exist.)
- [x] `CRM - Closeout Invoice Queue` list/views applied. (Apply log: list exists,
      4 views updated.)
- [x] Legacy Intake Register link, if present, is labelled admin-only and absent
      from every daily card/nav node. (Verifier: 0 legacy routes anywhere.)
- [x] Re-running V2 (the verifier) now returns PASS.

Result: PASS (SharePoint apply, run 2026-06-20 22:51, write mode, exit 0, single
keypress approval; phrase `apply-gail-crm-recovery` supplied via machine-bypass on
the command line). Created the missing `IntakeSource` (Source) Choice column; set
Required=True on the 8 business fields (Title, SignalType, IntakeSource, Priority,
NeedSummary, SourceText, NextAction, SignalStatus) and Required=False on the 6
optional fields; confirmed all 9 blocked technical fields absent from the intake
form; ensured the 7 workflow lists' columns/lookups/views (all idempotent — every
pre-existing field/lookup [skip]ped, no deletes). Verifier re-run immediately after:
**Failures 0 | Warnings 0 = PASS** (was 3 failures / 6 warnings before).

KNOWN MINOR DEFECT — FIXED 2026-06-21 (not yet re-applied): every `Set-PnPView`
call logged `RowLimit '100' — System.Int32 cannot be converted to type
System.UInt32. Value will be ignored.` The views updated fine but their page-size
(100) was NOT applied. Cause: `[int]$View.rowLimit` in `Add-CrmView`. Fixed both
cast sites (create + update paths) to `[uint32]` in
`scripts/spo/Apply-CrmSharePoint.ps1`; script re-parses clean. Cosmetic (default
page size still applies); the corrected page-size lands the next time the apply is
re-run. Does not affect verifier PASS.

Evidence: `inventory/crm-apply/crm-apply-sharepoint-20260620-225108.log` (write
transcript), `inventory/crm-verify/CRM_VERIFY.md` (post-apply 0/0 PASS),
`inventory/crm-apply/crm-apply-sharepoint-plan-apply-20260620-225108.txt` (plan).

PORTAL HALF: `scripts/portal/Apply-CrmPortal.ps1` (Command Center page sections /
web-part authoring) NOT run as a blind write by design — it is flag-only for nav and
defers page authoring to the human pass. Folded into V5. Optionally run it once for a
transcript that records "no legacy nav nodes found".

---

## V5 — Chunk 6 human browser/operator acceptance (HUMAN PASS)

Status: **ACCEPTED BY OPERATOR (2026-06-22)** — Adam, the acceptance authority,
confirmed the operating front door and directed closeout ("this is fine for now,
carry on with Chunk 8"). This is a deliberate operator acceptance of the live
operating path, **not** a claim that the full scripted lifecycle walk was
exhaustively performed. What was actually observed + what was waived is recorded
below, verbatim and honestly. Kit: `docs/CRM_V5_WALKTHROUGH_KIT.md`.

What the operator actually confirmed in-browser (MFA, normal operator):
- [x] Click path reaches the clean `CRM - New Signals` form (Operations Cockpit →
      CRM Command Center → New Signal), NOT the legacy Intake Register.
- [x] A new signal item can be created and saved.
- [x] The **streamlined 2-field capture** (Title + NeedSummary only) is the live
      front door — directly fixing the "cumbersome" finding that paused the pass.

Waived as a non-blocker (operator's call, recorded so the record is honest):
- [ ] Full lifecycle walk of one dummy through triage → qualify → next action →
      handoff → closeout was **not** exhaustively performed in this session. Each of
      those stages is a SharePoint view/status change already proven by the Chunk-3
      verifier (0 failures / 0 warnings / 184 checks) and by the live Path B / Bookings
      end-to-end runs that write real items into the same list and queues. Adam
      accepts this script-proven coverage in lieu of a manual per-stage walk for now.
- [ ] A separate formal per-stage PASS/FAIL block was not filled. Superseded by the
      operator acceptance above. If Adam later wants the exhaustive walk on record,
      the kit is still valid — re-open it, walk Steps 4–6, and append the verdict here.

**Open finding (operator usability) — RESOLVED 2026-06-22 (option b taken):** the
daily intake felt **cumbersome**. Adam chose to streamline the front door before
finishing the walk. The required set was cut from **8 fields to 2** (Title +
NeedSummary); the four defaulted Choice fields and the two remaining Note fields
(SourceText, NextAction) are now OPTIONAL (defaults still auto-apply; SourceText /
NextAction fill at triage). Pushed live via the Chunk-5 apply (write mode, 2026-06-22)
and the Chunk-3 verifier re-ran **0 failures / 0 warnings = PASS**. The remaining V5
work is now the pure human walk on the lighter form (kit Step 2 updated). Quick-add /
Power Apps front door remains CRM "Future Work".

**Cleanup owed on resume:** a dummy signal may remain in `CRM - New Signals`. If
saved with Person = `GAIL-INTERNAL-WALKTHROUGH`, clear via
`scripts/flow-builder/delete-test-records.js` (scoped, cannot hit a real signal).

Run:
- Sign in with MFA as a normal operator. Open Operations Cockpit → CRM Command
  Center. Create one dummy record prefixed `GAIL-INTERNAL-WALKTHROUGH` and move it
  through triage → qualification → next action → handoff/evidence → closeout/invoice.

Confirm:
- [ ] New Signal path never lands on a technical/admin intake route.
- [ ] Required fields are clear; no hidden/technical fields appear in the daily path.
- [ ] The dummy record is visible in the Triage Queue and the next action is obvious.
- [ ] You can tell what to escalate to Adam (access, billing, commitments, automation, etc.).

Result: **ACCEPTED (operator) 2026-06-22 / Adam Goodwin (MFA).** Front door + streamlined
capture confirmed live; full per-stage lifecycle walk waived as a non-blocker (script-proven).
Evidence: `inventory/crm-verify/CRM_VERIFY.md` (0/0/184 PASS),
`inventory/crm-apply/_v5_streamline_apply.log`, `inventory/crm-verify/_v5_streamline_verify.log`,
`config/crm.intake.json` (`streamlineDecisionNote`), `docs/CRM_V5_WALKTHROUGH_KIT.md`.

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

Status: DONE 2026-06-21 (both brand flows built, Started, healthy).
Depends on V4 (the `IntakeSource` field must exist on `CRM - New Signals`). Done.
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

DESIGN CHANGE (provenance) — see Log 2026-06-21: the recovered `CRM - New Signals`
list has NO hidden technical fields (Stage 8C removed them; live schema = the 13
clean business columns only), so the spec's "stamp provenance into hidden fields"
is impossible as written. Reconciled by writing provenance IN-BAND into the
visible `SourceText` note (Source brand, intake form name, Forms response id,
submit timestamp, "Auto-captured" marker, and "Who is this for" intent) plus the
native `Created` timestamp for received-time. Brand still lands in the
operator-visible `Source` (`IntakeSource`) choice. Schema untouched => Chunk 3
verifier result unchanged.

Confirm:
- [x] Both forms accept an anonymous submission.
- [x] The flow creates a `CRM - New Signals` item with `SignalType=Website`,
      `SignalStatus=New`, `Priority=Normal`, and `Source` = the correct brand.
- [x] Capture provenance lands in-band in the visible `SourceText` note (Source
      brand, intake form name, Forms response id, submit timestamp, "Auto-captured"
      marker, intent) + native `Created` — NOT hidden fields (none exist; design
      change above).
- [x] The flow has NO mail send / auto-reply / update / delete / external action.
      (Create-only; the only later PATCH was to the flow definition itself to add
      intent capture, not to any CRM item.)
- [x] No premium connector, Dynamics, or Dataverse is used. (Standard SharePoint +
      Microsoft Forms connectors only.)

Result: PASS (2026-06-21). Labs flow `0d717c08-2558-4ff8-a88f-26d723712b6d`;
Journey flow `2a2cd963-1469-48a5-95a5-04e696ff3543`. Both Started, trigger
`CreateFormWebhook` subscribed, both connections bound (SP `4c53f079...`, Forms
`7511a220...`), suspension None. Built via `scripts/flow-builder/create-flow.js`.
Evidence: flow IDs above + V8 e2e run below.

---

## V8 — Path B end-to-end + verifier still PASS (HUMAN PASS)

Status: DONE 2026-06-21 (both brands, end-to-end PASS; test records deleted).

Run:
- Submit one dummy response on EACH brand form, prefixed `GAIL-INTERNAL-WALKTHROUGH`.
- Submit at least one of those via the LIVE website CTA (Join B), not only the
  direct form link, to prove the website→form→flow→CRM chain end to end.
- Re-run the Chunk 3 verifier (V2).

Confirm:
- [x] Each dummy submission appears in the New Signal Queue with the correct
      `Source` brand and is triageable like any manual signal. (Both brands;
      SignalType=Website, SignalStatus=New, Priority=Normal, business fields +
      intent populated.)
- [x] No technical/automation field appears on the `CRM - New Signals` form —
      zero technical columns exist on the list, so none can appear; provenance is
      in-band in `SourceText`, not in hidden fields.
- [x] The Chunk 3 verifier still returns PASS — no field was added or altered by
      the flow (in-band provenance only), so the post-V4 0/0 PASS is unchanged.
- [x] Delete/close the dummy records after the test. (Done 2026-06-21 via
      `scripts/flow-builder/delete-test-records.js`, filtered to
      `PersonName == GAIL-INTERNAL-WALKTHROUGH`; verified 0 residue.)

Result: PASS (2026-06-21, both brands). e2e harness `scripts/flow-builder/e2e-test.js`
submitted a real response through each PUBLIC Forms URL from a fresh
unauthenticated browser (true visitor path); both produced clean `CRM - New Signals`
records, ALL CHECKS PASS (incl. `intentCaptured` after the intent field was added).
Linux notified via `X:\WINDOWS_TO_LINUX__crm-intake-flow-live.json` +
`...crm-intake-intent-field-live.json`.
Evidence: e2e harness output + Log entries 2026-06-21 below. CRM intake (V7/V8 +
intent field) is fully CLOSED; `CRM - New Signals` contains no test residue.

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
- 2026-06-20: V4 (Chunk 5 SharePoint apply) RUN in write mode — PASS. Single
  keypress approval in the visible window; phrase supplied via machine-bypass. Created
  `IntakeSource`, set all Required flags, confirmed blocked fields absent, idempotent on
  the 7 workflow lists. Verifier re-run = **0 failures / 0 warnings (PASS)** — the
  recovery's core success criterion is met. Found one minor non-blocker: `Set-PnPView`
  RowLimit needs a `[uint32]` cast (page-size 100 silently ignored; views otherwise fine).
  Portal page-authoring (Apply-CrmPortal.ps1) deferred to V5 by design. Next: V5 (human
  operator walkthrough) and the Path B build (V7/V8), which depends on `IntakeSource` (now live).
- 2026-06-21: **V7 FLOW + V8 END-TO-END = DONE / PASS (both brands).** Built the
  create-only Power Automate flows via the reverse-engineered Power Platform mgmt API
  (`scripts/flow-builder/create-flow.js`): Forms "new response" -> Get response details ->
  SharePoint Create item in `CRM - New Signals`. Both flows Started, healthy (trigger
  `CreateFormWebhook` subscribed, both connections bound, suspension None). Labs flow
  `0d717c08-2558-4ff8-a88f-26d723712b6d`; Journey flow `2a2cd963-1469-48a5-95a5-04e696ff3543`.
  Interactive steps were only Adam's two connection consents (SharePoint + Microsoft Forms)
  in his own browser; everything else fully agentic.
  **Design change (provenance):** the recovered `CRM - New Signals` list has NO hidden
  technical fields (Stage 8C removed them; live schema = the 13 clean business columns only),
  so the Path B spec's "stamp provenance into hidden technical fields" is not possible as
  written. Reconciled by writing provenance IN-BAND into the visible `SourceText` note
  (Source brand, intake form name, Forms response id, submit timestamp, "Auto-captured"
  marker) plus relying on the native `Created` timestamp for received-time. Brand still lands
  in the operator-visible `Source` (`IntakeSource`) choice. This keeps the list schema
  untouched, so the Chunk 3 verifier result is unchanged (no fields added/altered).
  **V8:** `scripts/flow-builder/e2e-test.js` submitted a real response through each PUBLIC
  Forms URL from a fresh unauthenticated browser (true visitor path); both produced clean
  `CRM - New Signals` records — Source correct, SignalType=Website, SignalStatus=New,
  Priority=Normal, business fields populated, provenance footer present, zero technical
  columns exposed. ALL CHECKS PASS. Two test records `GAIL-INTERNAL-WALKTHROUGH` (Ids 1, 2)
  left for Adam to triage/delete (automation deletes remain out of scope). Sent Linux
  `X:\WINDOWS_TO_LINUX__crm-intake-flow-live.json` (confirmation + CTA test protocol).
  Open: Adam's yes/no on Linux's requested intent/path Choice question (For me / For my team /
  For my organization / Governance or policy) — does not change form URLs or the website embed.
- 2026-06-21: **Intent/path question APPROVED + ADDED (both brands).** Adam said yes.
  Added Choice question "Who is this for?" (For me / For my team / For my organization /
  Governance or policy; optional, placed before consent) to both live forms via
  `scripts/forms-builder/add-intent-question.js` (idempotent; form URLs unchanged). Both
  flows UPDATED in place (PATCH, same flow IDs, still Started) via `create-flow.js` — now an
  update-or-create using the recorded flowName — so the answer is captured into each signal's
  SourceText ("Who is this for: <value>"). Re-ran V8 e2e for both brands post-change: intent
  answer lands in the CRM, ALL CHECKS PASS (now incl. `intentCaptured`). Four
  `GAIL-INTERNAL-WALKTHROUGH` test records (Ids 1–4) accumulated across runs — Adam to delete.
  Linux notified via `X:\WINDOWS_TO_LINUX__crm-intake-intent-field-live.json` (no website change).
- 2026-06-21: **Test records cleaned up — `CRM - New Signals` is clean.** Adam explicitly
  authorized a scoped delete of the e2e test data (one-time exception; automation deletes
  otherwise remain out of scope). `scripts/flow-builder/delete-test-records.js` filtered to
  items whose `PersonName` is exactly `GAIL-INTERNAL-WALKTHROUGH` (cannot match a real
  signal), listed the 4 (Ids 1–4, both brands), then deleted via SharePoint REST with a form
  digest. Verified: 0 `GAIL-INTERNAL-WALKTHROUGH` records remain. Path B website→CRM loop is
  now LIVE, e2e-verified for both brands, and the list contains no test residue. **CRM intake
  (V7/V8 + intent field) is fully CLOSED.** Remaining Path B tail unchanged: V5 portal/page
  pass + Chunk 8 close.
- 2026-06-21 (doc/housekeeping pass): reconciled this log to reality — V7 and V8
  checkboxes ticked and rewritten to match the shipped IN-BAND `SourceText`
  provenance design (the old "hidden fields" wording was never buildable: the
  recovered list has no hidden technical columns). Fixed the V4 RowLimit defect:
  `[int]` -> `[uint32]` at both `Add-CrmView` cast sites in
  `scripts/spo/Apply-CrmSharePoint.ps1` (re-parses clean; corrected page-size lands
  on the next apply re-run). No tenant write performed. Remaining open item is
  unchanged: **V5** (human MFA operator walkthrough) + the portal page-authoring
  pass, which is the one acceptance gate Chunk 8 still depends on.
- 2026-06-22 (V5 prep + scope): confirmed no page-authoring is actually outstanding
  — both pages (`Guided-AI-Labs-Operations-Cockpit.aspx`,
  `Relationship-CRM-Command-Center.aspx`) already exist and route cleanly (baseline
  pages CSV; verifier 0/0/184 PASS). V5 reduces to the pure human MFA walk. Built
  `docs/CRM_V5_WALKTHROUGH_KIT.md` (click path + concrete dummy-record values +
  hidden-field/lifecycle checks + inline verdict template + scoped-delete cleanup).
- 2026-06-22 (V5 FRONT-DOOR STREAMLINED — usability finding resolved, option b):
  Adam chose to streamline before finishing the walk. Required intake fields cut
  8 -> 2 (Title + NeedSummary only) in `config/crm.intake.json` (requiredBusinessFields
  + per-field flags + notRequiredFields; version bumped, decision recorded in the new
  `streamlineDecisionNote`; `requiredVsCardPlanNote` resolved). The 4 defaulted Choice
  fields (SignalType/IntakeSource/Priority/SignalStatus) + SourceText + NextAction are
  now OPTIONAL — column defaults still auto-apply, so type/source/priority/status data
  quality is preserved; SourceText/NextAction move to triage. Re-ran the Chunk-5 apply
  in WRITE mode (`Apply-CrmSharePoint.ps1 -Apply` via persisted login, no fresh sign-in
  needed): `[OK] Required=True: Title, NeedSummary` + 14x `Required=False`; blocked
  fields still hidden; all views updated cleanly (the pending `[uint32]` RowLimit fix
  landed — no more Int32 cast error). Chunk-3 verifier re-run = **0 failures / 0
  warnings = PASS** (shrinking the required set removes the only checks that could
  fire). Evidence: `inventory/crm-apply/_v5_streamline_apply.log`,
  `inventory/crm-verify/_v5_streamline_verify.log`, `inventory/crm-verify/CRM_VERIFY.md`.
  V5 kit Step 2 updated to the 2-required form. Remaining: the human MFA walk + verdict.
- 2026-06-22 (V5 STARTED, then PAUSED): Adam opened the path, reached the clean
  `CRM - New Signals` form, and created a new item — then paused (intake felt
  **cumbersome**; tired). Boxed up for a later session per Adam's call. Recorded the
  usability finding as a real Chunk-6 observation (not dismissed as fatigue). Resume
  state lives in the kit's top "PAUSED — RESUME HERE" block: (1) clean any dummy
  record, (2) decide accept-and-finish vs streamline-front-door-first, (3) complete
  the lifecycle walk + verdict. No tenant write performed by the agent this session.
- 2026-06-22 (V5 ACCEPTED + CHUNK 8 CLOSED): pre-walk cleanup check via
  `delete-test-records.js --dry` found **0** `GAIL-INTERNAL-WALKTHROUGH` records — the
  list is clean (the paused dummy was never saved / saved under other values). Adam then
  directed closeout: "This is fine for now. Carry on with Chunk 8." Recorded V5 as
  **operator-accepted** (front door + streamlined capture confirmed; full per-stage walk
  waived as a non-blocker — script-proven by the 0/0/184 verifier and the live Path B /
  Bookings end-to-end runs that write into the same list+queues). Chunk 8 doc closeout
  done: `CRM_RECOVERY_PLAN.md` Status → CLOSED, `CRM_EXECUTION_PLAN.md` Chunk 8 → complete,
  decision row added to `CRM_DECISIONS.md`. Root Stage 8 CRM docs were already marked
  provenance; future work already listed. **Still HELD (NOT done — needs Adam's own
  explicit OK):** the Stage 8 packet archive move into
  `inventory/archive/2026-06-17-stage-8-packet/`. No tenant write this session.
