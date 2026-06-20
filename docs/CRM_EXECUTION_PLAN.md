# CRM Execution Plan

Date: 2026-06-18

Status: Active chunk plan for completing the CRM recovery.

Use this document when Adam says to start applying the next chunk. `docs/START_HERE.md`
is the orientation front door. `docs/CRM_RECOVERY_PLAN.md` explains why the work
exists. This file defines what to execute.

## Execution Rule

Work one chunk at a time. A chunk is complete only when its acceptance gate is
met and its outputs exist in the repo or tenant evidence.

No tenant-writing command may run unless Adam gives the approval phrase:

```text
apply-gail-crm-recovery
```

## Current Chunk

Chunk 1 - Active Config Split is COMPLETE (2026-06-20).

Chunk 2 - Read-Only Baseline Export: SCRIPT BUILT (2026-06-20), awaiting one
interactive run. `scripts/spo/Export-CrmBaseline.ps1` (worker) and
`scripts/spo/Start-CrmBaselineExportInteractive.ps1` (visible-window launcher)
read the three split configs and snapshot the live tenant CRM state to a
timestamped path under `inventory/crm-baseline/`. Read-only: no
create/update/delete/invite/share/consent/mail; no approval phrase needed. It
records observations only (missing lists, blocked technical fields present/visible
on the intake list, nav nodes or page bodies routing to the legacy Intake Register
NewForm) and leaves PASS/FAIL to Chunk 3.

To run: double-click / launch `scripts/spo/Start-CrmBaselineExportInteractive.ps1`,
complete the Microsoft sign-in, then read `inventory/crm-baseline/CRM_BASELINE_EXPORT.md`.
The acceptance gate ("the script can prove what exists now without writing to the
tenant") is met once that evidence exists.

Chunk 3 - Verifier Replacement: SCRIPT BUILT (2026-06-20), awaiting one
interactive run (deferred-log V2). `scripts/spo/Verify-CrmSharePoint.ps1` +
launcher FAIL on the bad operator path (blocked technical fields visible incl.
DefaultTrue, legacy Intake Register routes in nav/page bodies, missing
lists/fields/lookups/views). Decision helpers unit-tested offline.

Chunk 4 - Apply Stubs + Dry Run: BUILT and DRY-RUN VERIFIED OFFLINE
(2026-06-20, deferred-log V3 = PASS). `scripts/spo/Apply-CrmSharePoint.ps1`
(lists/fields/lookups/views + hides the 9 blocked intake fields) and
`scripts/portal/Apply-CrmPortal.ps1` (cockpit card, command center, daily cards,
admin-only legacy fallback), each with a launcher. Both default to dry-run
(prints the full intended-change plan, no sign-in, no writes) and REFUSE write
mode unless given `-Apply -ApprovalPhrase apply-gail-crm-recovery`. Confirmed:
dry-runs exit 0 with plan; -Apply without the exact phrase exits 2 with no tenant
connection. The actual approved WRITE is Chunk 5 (deferred-log V4).

Building-forward decision (2026-06-20): Adam asked to keep building without
stopping for each interactive run, and to keep a test log. All built-but-unrun
tenant tests are batched in `docs/CRM_DEFERRED_VERIFICATION_LOG.md` (V1-V5) for
one focused sign-in session.

Next buildable without tenant: Chunk 7 - Onboarding Package (docs). Chunks 5
(apply), 6 (human browser pass), and 8 (close, needs evidence) wait on the
deferred-log runs.

## Completion Requirements

The CRM recovery is complete only when all requirements below are true.

Source-of-truth requirements:

- `docs/START_HERE.md` points to this execution plan as the working document.
- Root Stage 8 CRM docs are clearly marked superseded/provenance.
- Active CRM docs do not compete with each other about the next step.

Config requirements:

- `config/crm.sharepoint.json` defines the active CRM sites, lists, fields,
  views, and content-type/form expectations.
- `config/crm.intake.json` defines the clean intake contract, required business
  fields, and technical fields that must not appear in the daily intake path.
- `config/crm.navigation.json` defines Operations Cockpit, CRM Command Center,
  daily cards, and admin-only fallback links.

Script requirements:

- `scripts/spo/Export-CrmBaseline.ps1` can read and export the current tenant
  CRM state without writes.
- `scripts/spo/Verify-CrmSharePoint.ps1` fails when the operator path is
  unclear, links to the legacy intake route, or exposes technical fields.
- `scripts/spo/Apply-CrmSharePoint.ps1` defaults to dry-run and refuses writes
  without the approval phrase.
- `scripts/portal/Apply-CrmPortal.ps1` defaults to dry-run and refuses writes
  without the approval phrase.

Tenant requirements:

- Operations Cockpit links to a CRM Command Center.
- CRM Command Center gives a normal operator a clean New Signal path.
- Daily navigation does not send operators to
  `Guided AI Labs - Intake Register/NewForm.aspx`.
- `CRM - New Signals` supports business-facing intake and triage.
- `CRM - Closeout Invoice Queue` supports final evidence, invoice handoff,
  payment follow-up, and closure tracking.
- Admin fallback links, if any, are labelled admin-only.

Human acceptance requirements:

- A capable employee, operator, or trusted partner can sign in with MFA, open the
  Operations Cockpit, open CRM Command Center, create a New Signal, see it in the
  Triage Queue, and identify the next action.
- One internal dummy record with prefix `GAIL-INTERNAL-WALKTHROUGH` has been
  walked through intake, qualification, next action, handoff/evidence, and
  closeout/invoice watch.
- The person can tell what to escalate to Adam: access problems, client
  commitments, billing ambiguity, data quality problems, automation, sharing,
  app consent, production mail, public forms, deletes, Dynamics, Dataverse, and
  premium Power Platform decisions.

Access requirements:

- Employee/operator/trusted partner access groups or SharePoint permissions are
  named clearly enough for Adam to grant the right access.
- "Full access" means full operating access for the assigned role, including a
  broader trusted partner/operator role when deliberately granted.
- Tenant/global admin authority, break-glass access, billing, security settings,
  app consent, and destructive actions remain separate controlled grants.

Closeout requirements:

- Acceptance evidence is recorded.
- Remaining enhancements are listed as future work, not recovery blockers.
- Generated Stage 8 packet material is archived only after Adam confirms the
  archive move.

## Chunk 0 - Branch And Baseline Check

Objective:

Create a safe working lane and confirm repo state before changing recovery
assets.

Inputs:

- `docs/START_HERE.md`
- `docs/CRM_RECOVERY_PLAN.md`
- current `git status`
- existing Stage 8 CRM configs and scripts

Actions:

1. Check current branch and worktree status.
2. If Adam asks for a branch, create `recovery/gail-crm-front-door`.
3. Record unrelated dirty files and leave them untouched.
4. Confirm active CRM docs exist and root Stage 8 CRM docs are marked
   superseded/provenance.

Outputs:

- known branch/worktree state
- no reverted user work
- no tenant changes

Acceptance gate:

- We can clearly say which files are safe to touch in the next chunk.

Stop conditions:

- Branch creation would overwrite or hide user work.
- The repo state makes active CRM files impossible to identify.

## Chunk 1 - Active Config Split

Objective:

Replace the overloaded Stage 8C config as the day-to-day source with three
focused CRM config files.

Inputs:

- `config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json`
- `docs/CRM_DATA_MODEL.md`
- `docs/CRM_UX_SPEC.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Actions:

1. Read the Stage 8C config and identify site, list, field, view, and navigation
   settings that remain valid.
2. Create `config/crm.sharepoint.json` for sites, lists, fields, views, and
   content types.
3. Create `config/crm.intake.json` for the clean intake form contract, hidden
   technical fields, and required business fields.
4. Create `config/crm.navigation.json` for Operations Cockpit, CRM Command
   Center, daily cards, and admin-only fallback links.
5. Keep old Stage 8 configs as provenance until the new scripts read the new
   config files.

Outputs:

- `config/crm.sharepoint.json`
- `config/crm.intake.json`
- `config/crm.navigation.json`

Acceptance gate:

- The three new config files cover the active CRM lists, intake fields,
  hidden-field rules, and navigation path without requiring an operator to read
  Stage 8 packet docs.

Completion requirement satisfied:

- Config requirements.

Stop conditions:

- The Stage 8C config conflicts with the active data model in a way that cannot
  be resolved locally.
- Required tenant URLs or list names are missing.

## Chunk 2 - Read-Only Baseline Export

Objective:

Create a read-only evidence script that captures the live tenant state before
any recovery write.

Inputs:

- `config/crm.sharepoint.json`
- `config/crm.intake.json`
- `config/crm.navigation.json`
- existing Stage 8 verifier scripts

Actions:

1. Create `scripts/spo/Export-CrmBaseline.ps1`.
2. Connect with PnP.PowerShell interactively.
3. Read sites, lists, fields, views, forms, and page/link state.
4. Export evidence to a timestamped path under `inventory/`.
5. Do not create, update, delete, invite, share, consent, or send mail.

Outputs:

- `scripts/spo/Export-CrmBaseline.ps1`
- timestamped baseline evidence under `inventory/`

Acceptance gate:

- The script can prove what exists now without writing to the tenant.

Completion requirement satisfied:

- Baseline evidence portion of script requirements.

Stop conditions:

- Live tenant cannot be read.
- PnP authentication fails.
- A read requires an admin permission Adam has not granted.

## Chunk 3 - Verifier Replacement

Objective:

Replace the false-pass verifier with a verifier that fails when the browser
operator path is not actually clean.

Inputs:

- baseline evidence from Chunk 2
- `config/crm.sharepoint.json`
- `config/crm.intake.json`
- `config/crm.navigation.json`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Actions:

1. Create `scripts/spo/Verify-CrmSharePoint.ps1`.
2. Verify required lists, fields, views, and page links.
3. Fail if daily cards point to the legacy `Guided AI Labs - Intake Register`
   new-form route.
4. Fail if technical fields are visible in the daily intake path.
5. Emit PASS/FAIL, evidence paths, specific failures, and manual browser checks
   still required.

Outputs:

- `scripts/spo/Verify-CrmSharePoint.ps1`
- verifier evidence output

Acceptance gate:

- The verifier fails for the known bad operator path and can explain why.

Completion requirement satisfied:

- Verification portion of script requirements.

Stop conditions:

- SharePoint field/form visibility cannot be read reliably with available
  permissions or APIs.

## Chunk 4 - Apply Script Stubs And Dry Run

Objective:

Prepare tenant-writing scripts with explicit dry-run behavior before any write
is allowed.

Inputs:

- new config files
- baseline export script
- verifier script
- existing Stage 8A/8B/8C build scripts

Actions:

1. Create `scripts/spo/Apply-CrmSharePoint.ps1`.
2. Create `scripts/portal/Apply-CrmPortal.ps1`.
3. Default both scripts to dry-run.
4. Require the approval phrase for write mode.
5. Print a clear plan of intended tenant changes before execution.

Outputs:

- `scripts/spo/Apply-CrmSharePoint.ps1`
- `scripts/portal/Apply-CrmPortal.ps1`

Acceptance gate:

- Dry-run shows intended changes and refuses write mode without the approval
  phrase.

Completion requirement satisfied:

- Apply-script portion of script requirements.

Stop conditions:

- Any change would affect permissions, external sharing, app consent, production
  mail, public forms, deletes, billing, or Dynamics/Dataverse.

## Chunk 5 - Tenant Apply

Objective:

Apply the SharePoint-native CRM front door and clean intake path after explicit
approval.

Inputs:

- Chunk 4 dry-run output
- approval phrase from Adam
- `config/crm.sharepoint.json`
- `config/crm.intake.json`
- `config/crm.navigation.json`

Actions:

1. Confirm approval phrase.
2. Apply the clean `CRM - New Signals` intake list/view/form configuration.
3. Apply or update the `CRM - Closeout Invoice Queue` list/view configuration.
4. Apply CRM Command Center navigation and daily cards.
5. Leave admin fallback links labelled admin-only.

Outputs:

- updated SharePoint lists/views/pages
- tenant apply log/evidence

Acceptance gate:

- The live tenant has the clean CRM command center path and the verifier can
  read it back.

Completion requirement satisfied:

- Tenant requirements.

Stop conditions:

- Write approval phrase is absent.
- Tenant write fails partially.
- A required change crosses an out-of-scope boundary.

## Chunk 6 - Browser And Operator Acceptance

Objective:

Prove the CRM is usable by a person, not merely by scripts.

Inputs:

- live CRM Command Center
- `docs/CRM_RUNBOOK.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`
- verifier output

Actions:

1. Open Operations Cockpit.
2. Open CRM Command Center.
3. Create one internal dummy record with prefix `GAIL-INTERNAL-WALKTHROUGH`.
4. Move or mark the record through triage, qualification, next action,
   handoff/evidence, and closeout/invoice watch.
5. Capture evidence paths and manual notes.

Outputs:

- internal dummy CRM record
- acceptance evidence
- list of any friction found by the human pass

Acceptance gate:

- A capable employee/operator/partner can follow the runbook without needing
  Stage 8 build history.

Completion requirement satisfied:

- Human acceptance requirements.

Stop conditions:

- Browser path sends the user to a technical/admin intake route.
- Required fields are unclear or hidden fields appear in the daily path.

## Chunk 7 - Onboarding Package

Objective:

Create the first-day operating package for employee and trusted partner access.

Inputs:

- accepted CRM path
- `docs/CRM_RUNBOOK.md`
- `docs/CRM_DECISIONS.md`
- live Microsoft 365 group/sharepoint permission choices

Actions:

1. Define the exact employee/operator/partner access groups.
2. Define what full partner/operator access includes.
3. Define what remains separately controlled admin authority.
4. Add first-day login, bookmark/Teams tab, and runbook instructions.
5. Add escalation instructions for permissions, billing, commitments, and
   automation.

Outputs:

- updated onboarding/runbook docs
- exact access-group notes

Acceptance gate:

- Adam can hand a login and instructions to a capable employee or trusted
  partner and know which access role to grant.

Completion requirement satisfied:

- Access requirements.

Stop conditions:

- Microsoft 365 group or SharePoint permission model is unclear.
- Partner access would require broader tenant-admin rights than intended.

## Chunk 8 - Close Recovery

Objective:

Make the recovered CRM path the obvious active path and preserve old packet
material as history.

Inputs:

- all acceptance evidence
- active docs
- superseded Stage 8 CRM docs
- generated Stage 8 packet material

Actions:

1. Update active docs with final live links and evidence paths.
2. Mark completion status in `docs/CRM_RECOVERY_PLAN.md`.
3. Archive generated Stage 8 packet material only after Adam confirms the
   archive move.
4. Leave root Stage 8 CRM docs clearly labelled as provenance.
5. Record remaining enhancements as future work, not recovery blockers.

Outputs:

- completed recovery note
- archived historical packet material, if approved
- clear future-work list

Acceptance gate:

- The next person entering the repo starts from `docs/START_HERE.md`, follows
  this execution record, and does not treat old Stage 8 packet docs as active
  instructions.

Completion requirement satisfied:

- Source-of-truth requirements.
- Closeout requirements.

Stop conditions:

- Adam has not approved archive moves.
- Acceptance evidence is incomplete.

## Future Work After Recovery

These are not completion blockers:

- Power Apps front door.
- mailbox parsing or unattended automation.
- public intake forms.
- Dynamics/Dataverse.
- full accounting or invoicing automation.
- premium Power Platform dependencies.
