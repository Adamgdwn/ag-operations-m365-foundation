# Stage 8C Relationship CRM Operator Workflow Local Preflight

Generated: 2026-06-15 14:38:20

Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.

Result: PASS

| Status | Check | Detail |
|---|---|---|
| PASS | Stage 8C CRM operator workflow config parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json |
| PASS | Config is Stage 8C | Stage: 8C |
| PASS | Config has target site URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| PASS | Config has five operator workflow lists | Lists: 5 |
| PASS | Config has workflow lookup fields | Lookups: 14 |
| PASS | Config has filtered workflow views | Views: 19 |
| PASS | Config has approval phrase | apply-stage-8c-crm-workflow |
| PASS | File exists: M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md |
| PASS | File exists: config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json |
| PASS | File exists: scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1 |
| PASS | File exists: scripts\Test-M365Stage8CLocalPreflight.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Test-M365Stage8CLocalPreflight.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1 |
| PASS | File exists: scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 |
| PASS | File exists: scripts\Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1 |
| PASS | File exists: scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1 |
| PASS | Script parses: scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage8CLocalPreflight.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1 | parse-ok |
| PASS | PowerShell 7 host available | C:\Program Files\PowerShell\7\pwsh.exe |
| PASS | PnP.PowerShell module available | PnP.PowerShell 3.2.0 |
| PASS | PnP command available: Connect-PnPOnline | PnP.PowerShell |
| PASS | PnP command available: Get-PnPList | PnP.PowerShell |
| PASS | PnP command available: New-PnPList | PnP.PowerShell |
| PASS | PnP command available: Set-PnPList | PnP.PowerShell |
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

1. Run `.\scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1`.
2. Run `.\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1` for a dry run.
3. Run `.\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply` after approval and type `apply-stage-8c-crm-workflow`.
4. Run `.\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1` for read-only verification.
