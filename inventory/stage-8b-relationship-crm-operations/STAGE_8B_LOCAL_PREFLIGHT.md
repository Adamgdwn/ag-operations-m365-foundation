# Stage 8B Relationship CRM Operations Local Preflight

Generated: 2026-06-15 13:46:20

Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.

Result: PASS

| Status | Check | Detail |
|---|---|---|
| PASS | Stage 8B CRM operations config parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json |
| PASS | Config is Stage 8B | Stage: 8B |
| PASS | Config has target site URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| PASS | Config has lookup fields | Lookups: 8 |
| PASS | Config has six CRM list operation blocks | Lists: 6 |
| PASS | Config has operational views | views defined |
| PASS | Config has approval phrase | apply-stage-8b-crm-operations |
| PASS | File exists: M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md |
| PASS | File exists: config\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\config\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json |
| PASS | File exists: scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1 |
| PASS | File exists: scripts\Test-M365Stage8BLocalPreflight.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Test-M365Stage8BLocalPreflight.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1 |
| PASS | File exists: scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1 |
| PASS | File exists: scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1 |
| PASS | Script parses: scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage8BLocalPreflight.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1 | parse-ok |
| PASS | PowerShell 7 host available | C:\Program Files\PowerShell\7\pwsh.exe |
| PASS | PnP.PowerShell module available | PnP.PowerShell 3.2.0 |
| PASS | PnP command available: Connect-PnPOnline | PnP.PowerShell |
| PASS | PnP command available: Get-PnPList | PnP.PowerShell |
| PASS | PnP command available: Get-PnPField | PnP.PowerShell |
| PASS | PnP command available: Add-PnPField | PnP.PowerShell |
| PASS | PnP command available: Add-PnPFieldFromXml | PnP.PowerShell |
| PASS | PnP command available: Set-PnPField | PnP.PowerShell |
| PASS | PnP command available: Get-PnPView | PnP.PowerShell |
| PASS | PnP command available: Add-PnPView | PnP.PowerShell |
| PASS | PnP command available: Set-PnPView | PnP.PowerShell |
| PASS | PnP command available: Add-PnPPage | PnP.PowerShell |
| PASS | PnP command available: Add-PnPPageSection | PnP.PowerShell |
| PASS | PnP command available: Add-PnPPageTextPart | PnP.PowerShell |
| PASS | PnP command available: Set-PnPPage | PnP.PowerShell |
| PASS | PnP command available: Get-PnPNavigationNode | PnP.PowerShell |
| PASS | PnP command available: Add-PnPNavigationNode | PnP.PowerShell |

Next safe actions:

1. Run .\scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1.
2. Run .\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1 for a dry run.
3. Run .\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 -Apply after approval and type pply-stage-8b-crm-operations.
4. Run .\scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1 for read-only verification.
