# Stage 7 Local Preflight

Generated: 2026-06-14 19:09:40

Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.

Result: PASS

| Status | Check | Detail |
|---|---|---|
| PASS | Baseline parses as JSON | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_7_GOVERNANCE_BASELINE.json |
| PASS | Baseline is Stage 7 | Stage: 7 |
| PASS | Baseline has governance areas | Areas: 10 |
| PASS | Baseline has exit criteria | Criteria: 8 |
| PASS | Baseline has read-only scopes | User.Read, Organization.Read.All, Directory.Read.All, Group.Read.All, Application.Read.All, Policy.Read.All, AuditLog.Read.All, UserAuthenticationMethod.Read.All |
| PASS | File exists: M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md |
| PASS | File exists: config\M365_STAGE_7_GOVERNANCE_BASELINE.json | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\config\M365_STAGE_7_GOVERNANCE_BASELINE.json |
| PASS | File exists: scripts\Invoke-M365Stage7SecurityInventory.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Invoke-M365Stage7SecurityInventory.ps1 |
| PASS | File exists: scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 |
| PASS | File exists: scripts\Summarize-M365Stage7SecurityInventory.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Summarize-M365Stage7SecurityInventory.ps1 |
| PASS | File exists: scripts\Test-M365Stage7LocalPreflight.ps1 | C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\scripts\Test-M365Stage7LocalPreflight.ps1 |
| PASS | Script parses: scripts\Invoke-M365Stage7SecurityInventory.ps1 | parse-ok |
| PASS | Script parses: scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 | parse-ok |
| PASS | Script parses: scripts\Summarize-M365Stage7SecurityInventory.ps1 | parse-ok |
| PASS | Script parses: scripts\Test-M365Stage7LocalPreflight.ps1 | parse-ok |
| PASS | PowerShell 7 host available | C:\Program Files\PowerShell\7\pwsh.exe |
| PASS | Microsoft.Graph.Identity.SignIns module available | Microsoft.Graph.Identity.SignIns 2.37.0 |
| WARN | SharePoint Online Management Shell module available | optional module not found; -IncludeSharePointAdmin will skip/fail gracefully |

Next safe actions:

1. Run `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1` for read-only Graph inventory when Adam is ready to sign in.
2. Run `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin` only after the SharePoint Online module is installed and a second admin prompt is acceptable.
3. Summarize a completed inventory with `.\scripts\Summarize-M365Stage7SecurityInventory.ps1`.
4. Use `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md` to record the Security Defaults / Conditional Access and external sharing decisions.

