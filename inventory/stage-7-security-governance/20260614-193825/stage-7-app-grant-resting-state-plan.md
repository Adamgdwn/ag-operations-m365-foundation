# Stage 7 App Grant Resting-State Plan

Generated: 2026-06-14 21:12:08
Inventory folder: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-7-security-governance\20260614-193825`

Scope: local-only plan from saved Stage 7 inventory. This file does not connect to Microsoft 365, revoke grants, disable apps, or change tenant policy.

## Recommendation

Keep broad setup/admin grants only while they are actively helping finish the governed build. Before partner/client onboarding, record which grants are still needed, which are accepted as product dependencies, and which should be retired.

The practical near-term posture is:

- `agent-pnp-provisioning`: time-boxed active setup helper while Stage 8 SharePoint build work is still active.
- `Microsoft Graph Command Line Tools`: supervised admin tool for inventory and explicit write windows only.
- Microsoft first-party SharePoint extensibility grants: review dependency before touching.
- Thunderbird / Calendly: keep only if there is a named mailbox or scheduling workflow.

## Decision Table

| App | Resource | Consent | Matched scopes | Proposed resting state | Owner action | Review date | Automation stance |
|---|---|---|---|---|---|---|---|
| agent-pnp-provisioning | Microsoft Graph | AllPrincipals | Group.ReadWrite.All, Tasks.ReadWrite, offline_access | Time-boxed active setup helper | Keep active only while Stage 8 build automation is underway; then revoke delegated grants or disable the service principal. | After Stage 8 page/navigation and client workspace pattern are built | No automatic revoke without Adam approval |
| agent-pnp-provisioning | Office 365 SharePoint Online | AllPrincipals | AllSites.FullControl | Time-boxed active setup helper | Keep active only while Stage 8 build automation is underway; then revoke delegated grants or disable the service principal. | After Stage 8 page/navigation and client workspace pattern are built | No automatic revoke without Adam approval |
| Calendly | Microsoft Graph | AllPrincipals | offline_access, Calendars.ReadWrite, Calendars.ReadWrite.Shared | Accepted if actively used | Accept if scheduling workflow is active; document owner and review cadence for calendar read/write access. | Quarterly or before changing scheduling workflow | No revoke unless scheduling workflow is retired |
| Microsoft Graph Command Line Tools | Microsoft Graph | AllPrincipals | offline_access, User.ReadWrite.All, RoleManagement.ReadWrite.Directory, Policy.ReadWrite.Authorization | Supervised admin tool, not unattended automation | Keep for supervised admin inventory/write windows; remove or reduce admin-write scopes when the setup phase closes. | After Stage 7 closeout and before first client/partner onboarding | No automatic revoke without Adam approval |
| SharePoint Online Web Client Extensibility | Graph Connector Service | AllPrincipals | Sites.FullControl.All, ExternalConnection.ReadWrite.All | Accepted pending dependency verification | Treat as Microsoft first-party; verify dependency before any revoke. | Before changing SharePoint/Forms/Graph connector functionality | Do not revoke through this project without a separate Microsoft-first-party dependency review |
| SharePoint Online Web Client Extensibility | Microsoft Forms | AllPrincipals | Forms.ReadWrite | Accepted pending dependency verification | Treat as Microsoft first-party; verify dependency before any revoke. | Before changing SharePoint/Forms/Graph connector functionality | Do not revoke through this project without a separate Microsoft-first-party dependency review |
| SharePoint Online Web Client Extensibility | Microsoft Graph | AllPrincipals | Files.ReadWrite.All, Tasks.ReadWrite | Accepted pending dependency verification | Treat as Microsoft first-party; verify dependency before any revoke. | Before changing SharePoint/Forms/Graph connector functionality | Do not revoke through this project without a separate Microsoft-first-party dependency review |
| SharePoint Online Web Client Extensibility | Office 365 SharePoint Online | AllPrincipals | Files.ReadWrite.All, TermStore.ReadWrite.All, Sites.ReadWrite.All, Sites.FullControl.All | Accepted pending dependency verification | Treat as Microsoft first-party; verify dependency before any revoke. | Before changing SharePoint/Forms/Graph connector functionality | Do not revoke through this project without a separate Microsoft-first-party dependency review |
| Thunderbird | Microsoft Graph | AllPrincipals | EWS.AccessAsUser.All, offline_access, IMAP.AccessAsUser.All, POP.AccessAsUser.All, SMTP.Send | Owner decision required | Confirm whether Thunderbird is still needed for a named mailbox workflow; otherwise retire legacy mail protocol access. | Before partner/client onboarding | No revoke until mailbox use is confirmed |
| Thunderbird | Microsoft Graph | Principal | EWS.AccessAsUser.All, offline_access, IMAP.AccessAsUser.All, POP.AccessAsUser.All, SMTP.Send | Owner decision required | Confirm whether Thunderbird is still needed for a named mailbox workflow; otherwise retire legacy mail protocol access. | Before partner/client onboarding | No revoke until mailbox use is confirmed |

## Stage 7 Closeout Decision

Recommended decision record:

```text
Broad setup/admin grants remain active only for supervised Stage 8 build work.
Before any partner or client guest onboarding, the grant table must be reviewed
again. Any grant without a named workflow owner, active dependency, or build
need should be revoked, reduced, or disabled through a separate approval-gated
operator.
```

## Explicit Non-Actions

- Do not revoke Microsoft first-party SharePoint extensibility grants from this plan alone.
- Do not revoke Graph PowerShell scopes while an approved admin inventory/write window is in progress.
- Do not leave `agent-pnp-provisioning` broad setup scopes unreviewed after Stage 8.
- Do not create a future UAOS/M365 production bridge by reusing the setup helper app.

