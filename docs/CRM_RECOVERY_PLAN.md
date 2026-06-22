# Guided AI Labs CRM Recovery Plan

Date: 2026-06-17 (last updated 2026-06-22)

Status: **CLOSED (2026-06-22) — recovery complete, CRM operating path LIVE.** The
SharePoint-native CRM front door (Chunk 5 / V4) is applied with the verifier at
**0 failures / 0 warnings PASS**; the intake front door was streamlined to 2 required
fields (Title + NeedSummary) on 2026-06-22 to resolve the V5 "cumbersome" finding;
the Path B public brand intake (V7/V8) is live and e2e-verified for both brands. V5
(Chunk 6 human acceptance) is **operator-accepted** — Adam confirmed the front door +
streamlined capture in-browser and directed closeout; the full per-stage lifecycle
walk was waived as a non-blocker (it is script-proven by the 0/0/184 verifier and the
live Path B / Bookings end-to-end runs into the same list and queues). Chunk 8 doc
closeout is done. **One residual remains, held by design:** the Stage 8 packet archive
move — see "Recovery Closeout Status" — which executes only on Adam's explicit OK and
is not a recovery blocker.

Latest tenant result (2026-06-20 / 2026-06-21):

- SharePoint apply (V4) transcript: `inventory/crm-apply/crm-apply-sharepoint-20260620-225108.log`
- Verification summary: `inventory/crm-verify/CRM_VERIFY.md`
- Verification result: `PASS` (0 failures / 0 warnings, post-apply)
- CRM Command Center: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx`
- Clean intake list: `CRM - New Signals` (now includes the operator-visible `Source`/`IntakeSource` field)
- Closeout/invoice list: `CRM - Closeout Invoice Queue`
- Public brand intake (Path B, V7/V8): Guided AI Labs + Guided AI Journey anonymous
  Forms -> create-only Power Automate flows -> `CRM - New Signals`, live and e2e-verified
  both brands. Labs flow `0d717c08-2558-4ff8-a88f-26d723712b6d`; Journey flow
  `2a2cd963-1469-48a5-95a5-04e696ff3543`. Optional intent question ("Who is this for?")
  added and captured. Test records cleaned; list has 0 residue.
- Live deferred-test record of every applied/verified item: `docs/CRM_DEFERRED_VERIFICATION_LOG.md`.

Earlier Stage 8C provenance (2026-06-17): apply
`inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-174308.log`;
verify `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md`.

The Path B public-intake unlock is the only deliberate, SCOPED exception to the
no-public-forms / no-unattended-automation rule, and it is scoped to exactly the
two named forms + their create-only flows (see `docs/CRM_DECISIONS.md`). Otherwise
no permissions, guest access, external sharing, app consent, mail sends, deletes,
Dynamics, Dataverse, premium Power Platform dependencies, or unattended automation
were added.

## Side Quest Boundary

Azure setup has been split out into `docs/AZURE_SIDEQUEST_SETUP.md`.

Azure side-quest status:

- Azure CLI, Bicep, Azure Developer CLI, and lightweight Az PowerShell modules are installed.
- Azure CLI and Azure Developer CLI are logged in as `adamgoodwin@guidedailabs.com`.
- No Azure resources or billable services were created.
- Azure resource setup is blocked until the working account has subscription-level Azure RBAC. Current readback shows `AuthorizationFailed` when reading resource groups.

Return to this CRM plan after the Azure side quest. Future CRM tenant writes still require:

```text
apply-gail-crm-recovery
```

## Objective

Recover the Guided AI Labs CRM into a clean SharePoint-hosted operator system:

- SharePoint pages are the daily command center and shell.
- SharePoint lists and list views are the working business interface.
- OneDrive/SharePoint links hold proposals, evidence, invoice files, and handoff materials.
- The first no-purchase intake surface is a clean CRM-specific SharePoint list, `CRM - New Signals`, not the older technical `Guided AI Labs - Intake Register`.
- Power Apps, premium Power Automate, Dataverse, Dynamics, AI Builder, app consent, mailbox automation, and paid connectors are not part of this recovery pass.

The first recovery build should stop the current loop where script-side checks pass while the browser still shows technical fields to the user.

Completion is not defined by scripts passing. Completion is defined by a capable
employee, operator, or trusted partner being able to show up, sign in, follow the
runbook, and operate the CRM without knowing the Stage 8 build history.

Employee-ready means:

- the employee has a Microsoft 365 login and MFA;
- the employee has role-appropriate access to Guided AI Labs CRM and delivery
  surfaces;
- the employee can use the Operations Cockpit and CRM Command Center as the
  daily front door;
- the employee can capture, triage, qualify, hand off, close out, and invoice
  watch using business-facing fields and views;
- the employee knows when to escalate instead of changing permissions, sharing,
  app consent, production mail, public forms, deletes, Dynamics, Dataverse, or
  premium Power Platform features.

Important access language: "full access" means full operating access for the
assigned role. A trusted partner may intentionally receive a broader
partner/operator role with full CRM and delivery operating access. Tenant/global
admin authority, security settings, billing, app consent, destructive actions,
and break-glass access remain separate controlled grants.

## Chosen Front Door

Use a SharePoint-native CRM command center and a clean CRM-specific intake list.

Target operator path:

```text
Operations Cockpit -> CRM Command Center -> New Signal -> CRM - New Signals -> Triage Queue -> Qualification -> Proposal/Decision -> Delivery -> Closeout/Invoice
```

No-purchase implementation rule:

```text
SharePoint pages + SharePoint lists/views + OneDrive/SharePoint file links only
```

The old `Guided AI Labs - Intake Register/NewForm.aspx` is not the daily CRM route. The clean `CRM - New Signals` list is allowed to use SharePoint's native form because it contains only business intake fields.

## Current Inventory

Active root docs:

- `START_HERE_TOKEN_FRIENDLY.md`
- `M365_FOUNDATION_ROADMAP.md`
- `M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md`
- `M365_STAGE_8E_FRICTIONLESS_CRM_BUSINESS_FLOW.md`
- `M365_CRM_SHAREPOINT_MODEL_HANDOFF.md`

Active CRM config candidates:

- `config/M365_STAGE_8A_RELATIONSHIP_CRM.json`
- `config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json`
- `config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json`
- `config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json`

Active CRM scripts:

- `scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1`
- `scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1`
- Stage 8A and 8B CRM scripts remain reference/provenance until consolidated.

Generated or archive material:

- `inventory/stage-8c-relationship-crm-operator-workflow/`
- `inventory/stage-8d-functional-workflow-walkthrough/`
- `inventory/gail-sharepoint-portal/`
- `exports/m365-crm-sharepoint-handoff-20260617-153428.zip`
- `exports/m365-crm-sharepoint-handoff-20260617-153428/`

Known live SharePoint assumptions from current evidence:

- Site: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
- Operations page: `SitePages/Guided-AI-Labs-Operations-Cockpit.aspx`
- CRM page: `SitePages/Relationship-CRM-Command-Center.aspx`
- Legacy technical intake list: `Guided AI Labs - Intake Register`
- No-purchase CRM intake list: `CRM - New Signals`
- CRM workflow lists include `CRM - Action Queue`, `CRM - Qualification`, `CRM - Meeting Notes`, `CRM - Artifacts`, and `CRM - Health Reviews`.

Known failure evidence:

- Earlier evidence showed the active command center generator created an intake action card from `Get-ListNewFormUrl`, which resolved to the old technical Intake Register `NewForm.aspx`.
- `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-intake-experience-20260617-152413.csv` shows hidden fields with `ShowInNewForm=DefaultTrue` and `ShowInEditForm=DefaultTrue`.
- `scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1` currently lets hidden fields pass when content types are enabled, even when form flags are default-visible.

## Obvious Concerns

1. The current verifier is misleading. It must fail hidden system fields when `ShowInNewForm` or `ShowInEditForm` is `DefaultTrue` or `True`.
2. The CRM Command Center currently routes the first intake action to the raw SharePoint form. That guarantees the operator can still land in the wrong UX.
3. The repo has many overlapping Stage 8 configs, scripts, generated packets, CSVs, and logs. The active source of truth is not obvious.
4. Power Apps availability and deployment path are deliberately out of scope for the first no-purchase recovery pass.
5. Embedded SharePoint list views can still expose a `+ New` route into raw list forms. Verification must check daily links and visible page actions, not only navigation nodes.
6. The existing proof record shows that workflow data can be written, but it does not prove a non-technical browser operator path.
7. The repo currently has uncommitted changes and generated exports from the previous recovery attempt. Cleanup should be separated from tenant changes.

## Source Of Truth Target

Create this lean active structure:

```text
docs/
  START_HERE.md
  CRM_RECOVERY_PLAN.md
  CRM_UX_SPEC.md
  CRM_DATA_MODEL.md
  CRM_DECISIONS.md
  CRM_RUNBOOK.md
  CRM_ACCEPTANCE_TESTS.md
config/
  crm.sharepoint.json
  crm.intake.json
  crm.navigation.json
scripts/
  spo/
    Apply-CrmSharePoint.ps1
    Verify-CrmSharePoint.ps1
    Export-CrmBaseline.ps1
  portal/
    Apply-CrmPortal.ps1
  utils/
    Connect-GailSharePoint.ps1
power-platform/
  README.md
tests/
  ux/
    intake-form.spec.md
  fixtures/
    internal-test-signal.md
inventory/
  current/
    CRM_BASELINE_READBACK.md
  archive/
    2026-06-17-stage-8-packet/
legacy/
  README.md
```

## File Actions

Active as of 2026-06-18:

- `docs/START_HERE.md`
- `docs/CRM_RECOVERY_PLAN.md`
- `docs/CRM_UX_SPEC.md`
- `docs/CRM_DATA_MODEL.md`
- `docs/CRM_DECISIONS.md`
- `docs/CRM_RUNBOOK.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Keep as active implementation/provenance for now:

- `docs/CRM_RECOVERY_PLAN.md`
- `M365_STAGE_8E_FRICTIONLESS_CRM_BUSINESS_FLOW.md` is now superseded for active UX direction by `docs/CRM_UX_SPEC.md`; keep only as provenance until archived
- `M365_CRM_SHAREPOINT_MODEL_HANDOFF.md` is now superseded by the active CRM docs; keep only as provenance until archived
- `config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json` until split into the three CRM config files
- `scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1` until replaced by `scripts/spo/Verify-CrmSharePoint.ps1`
- `scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1` until replaced by `scripts/spo/Apply-CrmSharePoint.ps1` and `scripts/portal/Apply-CrmPortal.ps1`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1` until replaced by `scripts/portal/Apply-CrmPortal.ps1`

Created on 2026-06-18:

- `docs/START_HERE.md`
- `docs/CRM_UX_SPEC.md`
- `docs/CRM_DATA_MODEL.md`
- `docs/CRM_DECISIONS.md`
- `docs/CRM_RUNBOOK.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Created on 2026-06-20 (Chunk 1 - Active Config Split):

- `config/crm.sharepoint.json`
- `config/crm.intake.json`
- `config/crm.navigation.json`

Still to create:

- `scripts/spo/Export-CrmBaseline.ps1`
- `scripts/spo/Verify-CrmSharePoint.ps1`
- `scripts/spo/Apply-CrmSharePoint.ps1`
- `scripts/portal/Apply-CrmPortal.ps1`
- `power-platform/README.md` only to document what is out of scope until licensing is approved
- `tests/ux/intake-form.spec.md`
- `tests/fixtures/internal-test-signal.md`

Archive or demote:

- Root Stage 8 CRM docs into `inventory/archive/2026-06-17-stage-8-packet/`
- Stage 8C/8D generated inventory into `inventory/archive/2026-06-17-stage-8-packet/`
- Handoff export folder into `inventory/archive/2026-06-17-stage-8-packet/exports/`
- Old Stage 8A/8B/8C packet generators into `legacy/` after consolidated scripts exist

Do not delete in the first cleanup pass. Move only after the active replacement files exist and parse.

## Tenant Changes Applied

Tenant-writing changes were applied after the approval phrase:

```text
apply-gail-crm-recovery
```

Applied writes:

1. Update `Relationship-CRM-Command-Center.aspx` so cards are:
   - New Signal
   - Triage Queue
   - Follow Up Today
   - Proposal / Decision Blockers
   - Active Delivery
   - Closeout / Invoice Watch
2. Replace the current `Add intake signal` raw technical Intake Register link with the clean `CRM - New Signals` business intake route.
3. Keep `Guided AI Labs - Intake Register/NewForm.aspx` out of the daily CRM operator path.
4. Create or verify the clean CRM intake list and fields:
   - `Title`
   - `PersonName`
   - `PersonEmail`
   - `OrganizationName`
   - `SignalType`
   - `SignalStatus`
   - `Priority`
   - `NeedSummary`
   - `SourceText`
   - `NextAction`
   - `FollowUpDueDate`
   - `RelatedLink`
5. Create `CRM - Closeout Invoice Queue` with closeout, invoice handoff, payment follow-up, and final evidence fields.
6. Refresh SharePoint views so the command center has working queues for capture, triage, actions, delivery, closeout, and invoice handoff.

No recovery write included permissions, guest users, sharing links, app registrations, admin consent, mail sends, public forms, deletes, Dynamics, Dataverse, premium Power Platform dependencies, or unattended mailbox automation.

## Verifier Fix

Replace the hidden-field logic so this fails:

```text
FormatterContainsField=False; Required=False; ShowInNewForm=DefaultTrue; ShowInEditForm=DefaultTrue
```

Hidden system field PASS requires:

```text
FormatterContainsField=False
Required=False
ShowInNewForm=False
ShowInEditForm=False
```

For the no-purchase SharePoint-native path, verification must separately prove:

- No daily operator card or navigation link opens `Guided AI Labs - Intake Register/NewForm.aspx`.
- The actual New Signal surface is `CRM - New Signals`.
- `CRM - New Signals` does not contain source mailbox, source message ID, Graph, Planner, Central OS, or agent-confidence fields.

The verifier should emit:

- PASS/FAIL summary
- field visibility readback
- command-center link proof
- operator-path proof or manual checklist
- evidence artifact paths
- specific failure reasons

## Build Sequence

1. Create recovery branch `recovery/gail-crm-front-door`.
2. Freeze generated evidence by moving Stage 8 packet material into `inventory/archive/2026-06-17-stage-8-packet/`.
3. Add lean docs and config files. Status: core active CRM docs created on 2026-06-18; config split still pending.
4. Add read-only baseline export script.
5. Correct verifier logic and make current evidence fail until the operator path is proven.
6. Split active SharePoint/list config from intake/form config and navigation config.
7. Build CRM Command Center page from the SharePoint-native config.
8. Build the clean `CRM - New Signals` and `CRM - Closeout Invoice Queue` SharePoint lists/views.
9. Apply tenant changes only after `apply-gail-crm-recovery` approval.
10. Run verifier and browser/operator acceptance checks.
11. Walk one internal dummy record with prefix `GAIL-INTERNAL-WALKTHROUGH`.

## Path To Completion

The executable path now lives in `docs/CRM_EXECUTION_PLAN.md`.

Use that file when Adam says to start the next chunk. This recovery plan remains
the strategic brief: objective, constraints, hard stops, and definition of done.

Chunk summary:

1. Branch and baseline check.
2. Active config split.
3. Read-only baseline export.
4. Verifier replacement.
5. Apply script stubs and dry run.
6. Tenant apply after explicit approval phrase.
7. Browser and operator acceptance.
8. Onboarding package.
9. Close recovery and archive historical packet material with approval.

Completion requirements are defined in `docs/CRM_EXECUTION_PLAN.md` and checked
again through `docs/CRM_ACCEPTANCE_TESTS.md`.

## Recovery Closeout Status (Chunk 8)

**CLOSED 2026-06-22.** The recovery is APPLIED, the intake loop is LIVE, and Adam
(acceptance authority) accepted the operating path and directed closeout ("this is
fine for now, carry on with Chunk 8"). All Chunk 8 source-of-truth + closeout doc
actions are done. The single remaining item — the Stage 8 packet archive move — is
held by design for Adam's explicit OK and is explicitly **not** a recovery blocker.

Done and verified:

- Chunk 1 — config split (`config/crm.sharepoint.json` / `crm.intake.json` / `crm.navigation.json`).
- Chunk 2 — read-only baseline export (V1 PASS).
- Chunk 3 — verifier replacement (V2: correctly FAILs the bad path; phantom-failure bug fixed).
- Chunk 4 — apply stubs + dry-run/refusal gate (V3 PASS).
- Chunk 5 — tenant apply (V4 PASS: `IntakeSource` created, blocked fields confirmed
  absent, verifier re-run 0/0 PASS).
- Chunk 7 — onboarding package + V6 access-group read-back.
- Path B — public brand intake (V7 build + V8 end-to-end), both brands, live and
  e2e-verified; intent question added; test records cleaned (0 residue).
- Housekeeping (2026-06-21) — `Set-PnPView` RowLimit `[int]`->`[uint32]` cast fixed
  in `scripts/spo/Apply-CrmSharePoint.ps1`; deferred-verification log reconciled to
  the shipped in-band `SourceText` provenance design.

Chunk 6 / V5 — human MFA operator acceptance: **ACCEPTED (operator) 2026-06-22.**
Adam confirmed in-browser (MFA) that Operations Cockpit → CRM Command Center → New
Signal reaches the clean `CRM - New Signals` form and saves an item, and that the
streamlined 2-field capture is live. The full per-stage lifecycle walk (triage →
qualification → next action → handoff/evidence → closeout/invoice) was waived as a
non-blocker — those stages are SharePoint views/status changes already proven by the
Chunk-3 verifier (0/0/184 PASS) and exercised by the live Path B / Bookings end-to-end
runs that write into the same list and queues. If the exhaustive manual walk is ever
wanted on record, `docs/CRM_V5_WALKTHROUGH_KIT.md` remains valid. Portal page-authoring
was confirmed not outstanding (both pages present, route clean — see deferred-log
2026-06-22 entry).

Held pending Adam's explicit OK (do NOT do automatically — Chunk 8 stop condition,
NOT a recovery blocker):

- Archive of generated Stage 8 packet material into
  `inventory/archive/2026-06-17-stage-8-packet/` (and the handoff export folder).
  The "Archive or demote" list above is the move plan; execute only on Adam's explicit
  confirmation. Until then the root Stage 8 CRM docs stay in place, already clearly
  labelled as superseded/provenance, so they do not compete with the active path.

## Acceptance Tests

Canonical acceptance checklist: `docs/CRM_ACCEPTANCE_TESTS.md`.

Browser/operator acceptance:

- Open Operations Cockpit.
- Click CRM title/card.
- Open CRM Command Center.
- Click New Signal.
- Enter or paste one internal signal.
- Save it.
- See it in Triage Queue.
- Confirm next action is clear.

Hidden-field acceptance:

- Operator path does not show `SourceMailbox`, `SourceMessageId`, `ReceivedDate`, `IntakeStatus`, `ItemOwner`, `DurableHome`, `PlannerTaskUrl`, `CentralOSLink`, `GraphNodeId`, or `AgentConfidence`.

Navigation acceptance:

- Daily cards do not link to `Guided AI Labs - Intake Register/NewForm.aspx`.
- Admin fallback links, if present, are labelled admin-only.

Data acceptance:

- Saved signal lands in `CRM - New Signals`.
- Record includes the human intake fields and normal created/modified metadata.

Workflow acceptance:

- Dummy record moves through intake, qualification, CRM action, and handoff/evidence pointer.

## Out Of Scope For Recovery

- SPFx, React, custom hosted app build.
- Power Apps or paid Power Platform front door.
- Premium Power Automate connectors or AI Builder extraction.
- Dynamics or Dataverse provisioning.
- Full accounting/invoicing system.
- Production mailbox automation.
- Public forms or external/client-facing intake.
- Permissions, guest access, sharing-policy changes, app consent, or mail sends.
- Deleting live tenant content.

## Hard Stops

Stop and ask Adam before proceeding if:

- Live tenant cannot be read.
- A change would affect permissions, external sharing, app consent, production mail, or deletes.
- A needed form/app cannot be deployed or linked from SharePoint without manual tenant/admin steps.
- Conflicting active configs cannot be safely consolidated.
