# Start Here - Token-Friendly Project State

Last updated: 2026-06-14

This is the short restart/orientation note for Codex or any agent working in this
workspace. Read this first, then open detailed docs only as needed.

## Project purpose

Build Microsoft 365 into a clean, governed operating substrate for AG Operations
and Guided AI Labs.

M365 is not the whole future Agentic OS. It is one fully functional operating
layer: identity, records, tasks, decisions, collaboration, email signals, and
audit. The future central OS / Graphify map can integrate across M365, local and
Linux workspaces, repos, products, and other tools.

## Canonical order

Use [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) for the full staged
plan.

Current stage:

```text
Stage 6/7 transition - Stage 6 live gate pending; Stage 7 local governance prep started
```

Completed/design-complete:

- Stage 0: setup/tooling
- Stage 1: current-state inventory
- Stage 2: identity/admin foundation
- Stage 3: SharePoint architecture/sites
- Stage 4: OneDrive/local machine dovetail
- Stage 5: Exchange/communication routing design

## Current stop point

Stage 6 Lists are provisioned and read-back verified. Planner/Teams automation
is scaffolded as the next efficient operator flow, but the live Planner/Teams
gate has not completed yet. Stage 7 has started locally with a security,
governance, and external-sharing baseline plus read-only inventory tooling. No
Stage 7 tenant changes have been made.

Confirmed tenant change from Stage 6 attempt:

- `adamgoodwin@guidedailabs.com` is now secondary site collection admin on:
  - `https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools`
  - `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`

Done:

- The four Stage 6 Lists are created and verified:
  - `Guided AI Labs - Intake Register`
  - `Change Leadership Tools - Support Register`
  - `Agent Action Log`
  - `Decision Register`
- Local onboarding readiness artifacts were generated:
  - `inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`
  - `partner-onboarding-checklist.csv`
  - `partner-training-path.csv`
  - `client-readiness-discovery-checklist.csv`
  - `operating-readiness-scorecard.csv`
- Microsoft Forms intake/feedback kit was added locally:
  - `config/M365_FORMS_INTAKE_FEEDBACK_KIT.json`
  - `scripts/New-M365FormsIntakeFeedbackKit.ps1`
  - `inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md`
  - `forms-question-map.csv`
  - `forms-flow-build-checklist.csv`
- Stage 7 local baseline and inventory tooling were added:
  - `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md`
  - `config/M365_STAGE_7_GOVERNANCE_BASELINE.json`
  - `scripts/Invoke-M365Stage7SecurityInventory.ps1`
  - `scripts/Start-M365Stage7SecurityInventoryInteractive.ps1`
  - `scripts/Summarize-M365Stage7SecurityInventory.ps1`
  - `scripts/Test-M365Stage7LocalPreflight.ps1`
  - `inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md`
- Stage 8 and Stage 9 planning docs were added:
  - `M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md`
  - `M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md`

Not done:

- Planner Stage 6 writes have not run.
- Teams Stage 6 writes have not run.
- Stage 7 live read-only tenant inventory has not run.
- No Stage 7 security, sharing, guest, policy, consent, or role changes have run.
- First Planner/Teams operator run was launched at 2026-06-14 14:12 but Graph
  device-code auth timed out after 120 seconds of inactivity before connecting.
  No Planner/Teams tenant writes occurred.
- A visible Planner/Teams `ProvisionAndVerify` window was relaunched at
  2026-06-14 15:55. Graph device-code auth timed out after 120 seconds before
  connecting. No Planner/Teams tenant writes are recorded yet.
- The Planner/Teams operator was optimized after that run so a successful Graph
  sign-in can be preserved across preflight, provisioning, and post-verification
  in one process instead of forcing avoidable re-auth between phases.
- A later visible run at 2026-06-14 17:30 showed the PowerShell `Read-Host`
  pause could still be skipped by spawned windows, causing another device-code
  timeout. The visible M365 launchers were repaired to open `cmd.exe`, pause
  before PowerShell starts, and only then begin Graph/PnP auth.
- A fixed Planner/Teams `ProvisionAndVerify` window is parked before auth. Press
  any key in that window only when ready to complete Microsoft sign-in and the
  `planner-teams` live write gate.

## Stage 6 blocker

Resolved: PnP originally authenticated as the wrong delegated user:

```text
admin@agoperations.ca
```

Automation now uses device login plus an expected-user guard for:

```text
adamgoodwin@guidedailabs.com
```

Read-only verification passed after provisioning.

Important safety rule:

```text
Do not use raw Microsoft admin-consent URLs.
Do not approve any page showing phishing, risky-app, unknown-publisher,
suspicious-consent, or unexpected permission warnings.
```

Read before retrying:

- [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md) section 10.1

## Stage 6 design assets

- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
- [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
- [inventory/stage-6-operating-state/STAGE_6_MANUAL_LIST_BUILD_GUIDE.md](inventory/stage-6-operating-state/STAGE_6_MANUAL_LIST_BUILD_GUIDE.md)
- [inventory/stage-6-operating-state/STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md](inventory/stage-6-operating-state/STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md)
- [inventory/stage-6-operating-state/STAGE_6_LOCAL_PREFLIGHT.md](inventory/stage-6-operating-state/STAGE_6_LOCAL_PREFLIGHT.md)
- [inventory/stage-6-operating-state/first-run-packet/STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md](inventory/stage-6-operating-state/first-run-packet/STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md)
- [inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md](inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md)

## Stage 7 design assets

- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
- [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json)
- [inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md](inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md)

## Stage 8/9 planning assets

- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)

The schema defines:

- Guided AI Labs intake register
- Change Leadership Tools support register
- Agent Action Log
- Decision Register
- Forms intake/feedback kit: discovery intake, support request, session feedback,
  and team retrospective routed into the existing Lists
- Planner buckets
- Teams/channel/tab layout
- future integration hooks: `CentralOSLink`, `GraphNodeId`

## Safe next session path

1. Read this file.
2. Read [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md).
3. Decide how to resolve the PnP provisioning blocker:
   - already resolved by using `-UseDeviceLogin` and the Adam account guard.
4. Use read-only verification before any further tenant writes:

```powershell
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly
.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify
.\scripts\Test-M365Stage7LocalPreflight.ps1
```

## Useful scripts

Read-only / diagnostic:

```powershell
.\scripts\Test-M365Stage6PnPPermissions.ps1
.\scripts\Test-M365Stage6PnPPermissions.ps1 -UseDeviceLogin
.\scripts\Test-M365Stage6PnPTokenClaims.ps1
.\scripts\Clear-M365Stage6PnPPersistedLogin.ps1
.\scripts\Show-M365Stage6PnPConsentReviewChecklist.ps1
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action RepairLogin
.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify
.\scripts\New-M365Stage6ManualListBuildGuide.ps1
.\scripts\New-M365Stage6PlannerTeamsBuildGuide.ps1
.\scripts\New-M365FormsIntakeFeedbackKit.ps1
.\scripts\New-M365Stage6FirstRunPacket.ps1
.\scripts\New-M365Stage6OnboardingReadinessPacket.ps1
.\scripts\Update-M365Stage6LocalArtifacts.ps1
.\scripts\Test-M365Stage6LocalPreflight.ps1
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly
.\scripts\Test-M365Stage7LocalPreflight.ps1
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1
.\scripts\Summarize-M365Stage7SecurityInventory.ps1
```

Live writes, use only after review:

```powershell
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action ProvisionAndVerify
.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -EnsureSiteAdmins
```

Stage 7 live read-only inventory:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1
```

Optional SharePoint admin read-back after installing the SharePoint Online module:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin
```

Authorization preference:

- Use visible interactive windows for Microsoft sign-in/MFA/approval.
- Prefer persisted login for routine runs where safe.
- Use the Planner/Teams operator's default device-code path on this workstation;
  embedded-shell WAM browser auth can fail without a window handle. Start it
  when Adam is present because Microsoft Graph device-code auth can time out
  quickly when left unattended. The operator now waits for Enter before starting
  the short-lived device-code flow and preserves the Graph session across the
  phases once sign-in succeeds.
- Human approval is required for consent, broad permissions, external sharing,
  destructive actions, guest access, mail sends, calendar commitments, and tenant
  policy changes.

## Detailed index

Use [00_INDEX.md](00_INDEX.md) for the longer project map.
