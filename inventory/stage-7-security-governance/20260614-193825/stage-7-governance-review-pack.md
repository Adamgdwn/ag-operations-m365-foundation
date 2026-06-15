# Stage 7 Governance Review Pack

Generated: 2026-06-14 21:12:07
Inventory folder: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-7-security-governance\20260614-193825`

Scope: local-only review of saved Stage 7 inventory. This file does not change Microsoft 365.

## Executive Recommendation

Stage 7 core guardrails are in place. Before onboarding a business partner or client, close three cleanup items: set a resting state for broad delegated app grants, add MFA to the support mailbox identity, and disable or explicitly accept root/legacy SharePoint sharing exceptions.

## Approval Gates

| Gate | Recommended owner action | Automation stance |
|---|---|---|
| Broad app grants | Decide which setup grants remain active, time-boxed, or revoked | Approval required before any revoke/disable action |
| Support mailbox MFA | Register a strong method for `support@changeleadershiptools.com` | Manual/user-driven registration |
| Root/legacy site sharing | Disable exceptions unless a named workflow needs them | Approval required before site sharing changes |

## Broad Delegated App Grants

| Severity | App | Resource | Consent | Matched scopes | Recommendation |
|---|---|---|---|---|---|
| Critical | agent-pnp-provisioning | Office 365 SharePoint Online | AllPrincipals | AllSites.FullControl | Keep only while active build automation needs it; after Stage 8 setup, revoke broad delegated grants or disable the app registration/service principal. |
| Critical | Microsoft Graph Command Line Tools | Microsoft Graph | AllPrincipals | Directory.Read.All, Sites.Read.All, Files.Read.All, offline_access, User.ReadWrite.All, RoleManagement.ReadWrite.Directory, AuditLog.Read.All, Application.Read.All, UserAuthenticationMethod.Read.All, Policy.ReadWrite.Authorization | Keep only during admin inventory/write windows; remove admin-write delegated scopes when Stage 7 cleanup closes. |
| Critical | SharePoint Online Web Client Extensibility | Graph Connector Service | AllPrincipals | Sites.FullControl.All, ExternalConnection.ReadWrite.All | Treat carefully as a Microsoft first-party service principal; verify the exact feature dependency before revoking any SharePoint/connector grants. |
| Critical | SharePoint Online Web Client Extensibility | Office 365 SharePoint Online | AllPrincipals | Files.ReadWrite.All, TermStore.ReadWrite.All, Sites.ReadWrite.All, Sites.FullControl.All | Treat carefully as a Microsoft first-party service principal; verify the exact feature dependency before revoking any SharePoint/connector grants. |
| High | agent-pnp-provisioning | Microsoft Graph | AllPrincipals | Group.ReadWrite.All, Tasks.ReadWrite, offline_access | Keep only while active build automation needs it; after Stage 8 setup, revoke broad delegated grants or disable the app registration/service principal. |
| High | Calendly | Microsoft Graph | AllPrincipals | offline_access, Calendars.ReadWrite, Calendars.ReadWrite.Shared | Accept only if scheduling workflow is active; document owner and review date for calendar read/write access. |
| High | SharePoint Online Web Client Extensibility | Microsoft Forms | AllPrincipals | Forms.ReadWrite | Treat carefully as a Microsoft first-party service principal; verify the exact feature dependency before revoking any SharePoint/connector grants. |
| High | SharePoint Online Web Client Extensibility | Microsoft Graph | AllPrincipals | Files.Read.All, Files.ReadWrite.All, Tasks.ReadWrite, Sites.Read.All | Treat carefully as a Microsoft first-party service principal; verify the exact feature dependency before revoking any SharePoint/connector grants. |
| High | Thunderbird | Microsoft Graph | AllPrincipals | EWS.AccessAsUser.All, offline_access, IMAP.AccessAsUser.All, POP.AccessAsUser.All, SMTP.Send | Confirm mailbox use; prefer modern Outlook/Graph patterns and avoid standing POP/IMAP/EWS/SMTP access unless there is a named mailbox workflow. |
| High | Thunderbird | Microsoft Graph | Principal | EWS.AccessAsUser.All, offline_access, IMAP.AccessAsUser.All, POP.AccessAsUser.All, SMTP.Send | Confirm mailbox use; prefer modern Outlook/Graph patterns and avoid standing POP/IMAP/EWS/SMTP access unless there is a named mailbox workflow. |

## SharePoint Sharing Exceptions

| Site | Sharing | Template | Recommendation |
|---|---|---|---|
| [Group for Answers in Viva Engage – DO NOT DELETE 1521570944958464](https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273) | ExternalUserSharingOnly | GROUP#0 | System-created Viva Engage site; avoid deleting, but disable external sharing if no external community workflow exists. |

## MFA Gaps

| User | Method count | Methods | Recommendation |
|---|---:|---|---|
| support@changeleadershiptools.com | 1 | #microsoft.graph.passwordAuthenticationMethod | Register Microsoft Authenticator or equivalent strong method before this identity is used for business workflows. |

## Suggested Closeout Sequence

1. Register MFA for `support@changeleadershiptools.com`.
2. Record a time-boxed resting-state decision for `agent-pnp-provisioning` and Microsoft Graph PowerShell admin scopes.
3. Approve a site-sharing cleanup batch for root/legacy exceptions, or record accepted exceptions with workflow owner and review date.
4. Start Stage 8 client workspace pattern only after those exceptions are either closed or explicitly accepted.

