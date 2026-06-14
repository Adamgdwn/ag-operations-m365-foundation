# Stage 6 Local Preflight

Generated: 2026-06-14 16:57:20

Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.

Result: PASS

| Status | Check | Detail |
|---|---|---|
| PASS | Schema parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json |
| PASS | Schema has four Stage 6 Lists | Found 4 |
| PASS | Schema has Planner buckets | Intake Triage, Client Discovery, Active Delivery, Content / IP, Agent Setup, Waiting / Follow-up, Admin / Governance |
| PASS | Schema has Teams channels | General, Intake, Client Discovery, Active Delivery, Agent Setup, Methods & IP |
| PASS | List titles are unique | No duplicates |
| PASS | Every List has a title | Missing: 0 |
| PASS | Forms kit schema parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_FORMS_INTAKE_FEEDBACK_KIT.json |
| PASS | Forms kit has form definitions | Found 4 |
| PASS | Forms kit has flow pattern | Found 7 steps |
| PASS | Script parses: scripts\Invoke-M365Stage6ProvisionLists.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage6VerifyLists.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Show-M365Stage6PnPConsentReviewChecklist.ps1 | parse-ok |
| PASS | Script parses: scripts\Clear-M365Stage6PnPPersistedLogin.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage6PnPPermissions.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage6PnPTokenClaims.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage6ListOperator.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage6ListOperatorInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage6ProvisionPlannerTeams.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage6PlannerTeamsOperator.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\New-M365Stage6ManualListBuildGuide.ps1 | parse-ok |
| PASS | Script parses: scripts\New-M365Stage6PlannerTeamsBuildGuide.ps1 | parse-ok |
| PASS | Script parses: scripts\New-M365FormsIntakeFeedbackKit.ps1 | parse-ok |
| PASS | Script parses: scripts\New-M365Stage6FirstRunPacket.ps1 | parse-ok |
| PASS | Script parses: scripts\New-M365Stage6OnboardingReadinessPacket.ps1 | parse-ok |
| PASS | Script parses: scripts\Update-M365Stage6LocalArtifacts.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage6LocalPreflight.ps1 | parse-ok |
| PASS | Generated guide exists: inventory\stage-6-operating-state\STAGE_6_MANUAL_LIST_BUILD_GUIDE.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\STAGE_6_MANUAL_LIST_BUILD_GUIDE.md |
| PASS | Generated guide exists: inventory\stage-6-operating-state\STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md |
| PASS | Generated guide exists: inventory\stage-6-operating-state\forms-intake-feedback\M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\forms-intake-feedback\M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md |
| PASS | Generated guide exists: inventory\stage-6-operating-state\forms-intake-feedback\forms-question-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\forms-intake-feedback\forms-question-map.csv |
| PASS | Generated guide exists: inventory\stage-6-operating-state\forms-intake-feedback\forms-flow-build-checklist.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\forms-intake-feedback\forms-flow-build-checklist.csv |
| PASS | Generated guide exists: inventory\stage-6-operating-state\first-run-packet\STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\first-run-packet\STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md |
| PASS | Generated guide exists: inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md |
| PASS | Generated guide exists: inventory\stage-6-operating-state\onboarding-readiness\partner-onboarding-checklist.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\onboarding-readiness\partner-onboarding-checklist.csv |
| PASS | Generated guide exists: inventory\stage-6-operating-state\onboarding-readiness\client-readiness-discovery-checklist.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\onboarding-readiness\client-readiness-discovery-checklist.csv |
| PASS | Generated guide exists: inventory\stage-6-operating-state\onboarding-readiness\operating-readiness-scorecard.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-6-operating-state\onboarding-readiness\operating-readiness-scorecard.csv |
| PASS | PowerShell 7 host available | C:\Program Files\PowerShell\7\pwsh.exe |
| PASS | PnP.PowerShell module available | PnP.PowerShell 3.2.0 |
| PASS | Microsoft.Graph.Authentication module available | Microsoft.Graph.Authentication 2.37.0 |
| PASS | Microsoft.Graph.Teams module available | Microsoft.Graph.Teams 2.37.0 |
| PASS | Microsoft.Graph.Planner module available | Microsoft.Graph.Planner 2.37.0 |

Next safe actions:

1. Prefer `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify` for routine List read-back.
2. If PnP reuses the wrong account, run `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action RepairLogin`, then rerun with `-UseDeviceLogin`.
3. Prefer `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify` for Planner/Teams read-back.
4. Use `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify` only when ready for the live Planner/Teams gate.
5. Use `inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md` before adding a partner or shaping first client onboarding.
6. Use `inventory\stage-6-operating-state\forms-intake-feedback\M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md` before creating Forms or Power Automate flows.

