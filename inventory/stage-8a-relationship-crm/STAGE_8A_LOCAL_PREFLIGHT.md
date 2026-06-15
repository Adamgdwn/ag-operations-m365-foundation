# Stage 8A Local Preflight

Generated: 2026-06-15 13:03:04

Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.

Result: PASS

| Status | Check | Detail |
|---|---|---|
| PASS | Stage 8A CRM config parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8A_RELATIONSHIP_CRM.json |
| PASS | Config is Stage 8A | Stage: 8A |
| PASS | Config has target site URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| PASS | Config has six CRM Lists | Lists: 6 |
| PASS | Config has Relationship CRM page | Relationship-CRM.aspx |
| PASS | Config has approval phrase | apply-stage-8a-relationship-crm |
| PASS | Config has safety limits | Limits: 9 |
| PASS | File exists: M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md |
| PASS | File exists: config\M365_STAGE_8A_RELATIONSHIP_CRM.json | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\config\M365_STAGE_8A_RELATIONSHIP_CRM.json |
| PASS | File exists: scripts\New-M365Stage8ARelationshipCrmPacket.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\New-M365Stage8ARelationshipCrmPacket.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1 |
| PASS | File exists: scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8AVerifyRelationshipCrm.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8AVerifyRelationshipCrm.ps1 |
| PASS | File exists: scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1 |
| PASS | File exists: scripts\Test-M365Stage8ALocalPreflight.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Test-M365Stage8ALocalPreflight.ps1 |
| PASS | File exists: inventory\stage-8a-relationship-crm\STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-page-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-page-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-list-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-list-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-field-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-field-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-view-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-view-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-navigation-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-navigation-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-workflow-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-workflow-map.csv |
| PASS | File exists: inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-teams-tab-later-map.csv | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-teams-tab-later-map.csv |
| PASS | Script parses: scripts\New-M365Stage8ARelationshipCrmPacket.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8AVerifyRelationshipCrm.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage8ALocalPreflight.ps1 | parse-ok |
| PASS | PowerShell 7 host available | C:\Program Files\PowerShell\7\pwsh.exe |
| PASS | PnP.PowerShell module available | PnP.PowerShell 3.2.0 |
| PASS | PnP command available: Add-PnPPage | PnP.PowerShell |
| PASS | PnP command available: Add-PnPPageTextPart | PnP.PowerShell |
| PASS | PnP command available: Add-PnPPageSection | PnP.PowerShell |
| PASS | PnP command available: Set-PnPPage | PnP.PowerShell |
| PASS | PnP command available: Get-PnPPage | PnP.PowerShell |
| PASS | PnP command available: Add-PnPNavigationNode | PnP.PowerShell |
| PASS | PnP command available: Get-PnPNavigationNode | PnP.PowerShell |
| PASS | PnP command available: New-PnPList | PnP.PowerShell |
| PASS | PnP command available: Set-PnPList | PnP.PowerShell |
| PASS | PnP command available: Get-PnPList | PnP.PowerShell |
| PASS | PnP command available: Add-PnPField | PnP.PowerShell |
| PASS | PnP command available: Set-PnPField | PnP.PowerShell |
| PASS | PnP command available: Get-PnPField | PnP.PowerShell |
| PASS | PnP command available: Add-PnPView | PnP.PowerShell |
| PASS | PnP command available: Get-PnPView | PnP.PowerShell |

Next safe actions:

1. Run `.\scripts\New-M365Stage8ARelationshipCrmPacket.ps1` to regenerate the local CRM packet after config changes.
2. Run `.\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1` for a local dry-run.
3. Run `.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply` only after approving live CRM Lists/page/navigation creation; type `apply-stage-8a-relationship-crm` in the visible window.
4. Run `.\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1` for read-only CRM read-back after live apply.
5. Defer Teams tabs until SharePoint CRM verification passes.
6. Do not create permissions, sharing, guests, app grants, public Forms, sends, deletes, Dynamics/Dataverse, or unattended automation as part of Stage 8A.
