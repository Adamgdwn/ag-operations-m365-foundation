# Stage 7 Security/Governance Inventory Summary

Generated: 2026-06-14 21:11:37
Inventory folder: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\stage-7-security-governance\20260614-193825`

Scope: read-only inventory summary. This file does not change Microsoft 365.

## Snapshot

| Area | Value |
|---|---|
| Users | 6 |
| Guest users | 0 |
| Directory role assignments | 13 |
| Global Administrators | 4 |
| App delegated permission grants | 15 |
| Broad delegated grants flagged | 5 |
| Conditional Access policies read | 0 |
| Security Defaults | enabled |
| Guest invite setting | adminsAndGuestInviters |
| Risky user consent allowed |  |
| Business Standard detected | True |
| Business Premium detected | False |
| SharePoint site sharing read | yes |
| SharePoint tenant sharing | ExternalUserSharingOnly |
| SharePoint default sharing link | Direct |
| Inventory read gaps | 1 |

## Findings

- Business Standard appears present without Business Premium; Security Defaults is the practical free baseline unless Entra P1 is added.
- Security Defaults are enabled. Confirm setup scripts can use a compatible auth pattern because Security Defaults can block device-code flow.
- Guest invitation posture is not fully open; confirm it matches the partner onboarding process.
- Broad delegated app grants were detected. Review whether each is active setup capability, idle capability, or future bridge capability.
- No guest users were found in this read-back.
- One or more read-only inventory calls wrote an error file. Review the read gaps before closing Stage 7.

## Global Administrators

| Display name | User principal name |
|---|---|
| Adam Goodwin | adamgoodwin@guidedailabs.com |
| Adam Goodwin | admin@agoperations.ca |
| Break Glass 01 (Emergency Admin) | breakglass-01@AGOperationsLtd.onmicrosoft.com |
| Break Glass 02 (Emergency Admin) | breakglass-02@AGOperationsLtd.onmicrosoft.com |

## Broad Delegated Grants

| Matched scope | App | Consent type | Client ID | Principal ID |
|---|---|---|---|---|
| AllSites.FullControl | agent-pnp-provisioning | AllPrincipals | f840cbb4-dd15-44f2-8ce6-fed5dcf5d7f4 |  |
| Group.ReadWrite.All | agent-pnp-provisioning | AllPrincipals | f840cbb4-dd15-44f2-8ce6-fed5dcf5d7f4 |  |
| RoleManagement.ReadWrite.Directory | Microsoft Graph Command Line Tools | AllPrincipals | 9272b2ff-b069-43b4-95c3-39bbaf5d6532 |  |
| Sites.FullControl.All | SharePoint Online Web Client Extensibility | AllPrincipals | 1b17f028-aadc-4332-9ef9-09cb33782bf0 |  |
| Sites.FullControl.All | SharePoint Online Web Client Extensibility | AllPrincipals | 1b17f028-aadc-4332-9ef9-09cb33782bf0 |  |

## Inventory Read Gaps

| Area | Error |
|---|---|
| recent-signins | Response status code does not indicate success: Forbidden (Forbidden). |

## SharePoint Site Sharing

Tenant sharing capability: **ExternalUserSharingOnly**
Default sharing link type: **Direct**

| Site | Template | Sharing capability | Conditional access | Non-owner sharing disabled |
|---|---|---|---|---|
| https://agoperationsltd-my.sharepoint.com/ | SPSMSITEHOST#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/ | SitePagePublishing#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/search | SRCHCEN#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/A.G.OperationsLtd | GROUP#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/AGOperations | SITEPAGEPUBLISHING#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/allcompany | GROUP#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools | GROUP#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273 | GROUP#0 | ExternalUserSharingOnly | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/GuidedAIJourney | SITEPAGEPUBLISHING#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/GuidedAILabs | GROUP#0 | Disabled | 0 |  |
| https://agoperationsltd.sharepoint.com/sites/SharedLibraries | SITEPAGEPUBLISHING#0 | Disabled | 0 |  |

## User Authentication Method Summary

| User | Method count | Method types |
|---|---:|---|
| adamgoodwin@guidedailabs.com | 2 | #microsoft.graph.passwordAuthenticationMethod; #microsoft.graph.microsoftAuthenticatorAuthenticationMethod |
| admin@agoperations.ca | 2 | #microsoft.graph.passwordAuthenticationMethod; #microsoft.graph.microsoftAuthenticatorAuthenticationMethod |
| breakglass-01@AGOperationsLtd.onmicrosoft.com | 2 | #microsoft.graph.passwordAuthenticationMethod; #microsoft.graph.microsoftAuthenticatorAuthenticationMethod |
| breakglass-02@AGOperationsLtd.onmicrosoft.com | 2 | #microsoft.graph.passwordAuthenticationMethod; #microsoft.graph.microsoftAuthenticatorAuthenticationMethod |
| contact@guidedailabs.com | 2 | #microsoft.graph.passwordAuthenticationMethod; #microsoft.graph.microsoftAuthenticatorAuthenticationMethod |
| support@changeleadershiptools.com | 1 | #microsoft.graph.passwordAuthenticationMethod |

## Recommended Next Decisions

1. Decide whether to stay on Security Defaults for now or move to Business Premium / Entra P1 Conditional Access.
2. Decide the resting state for `agent-pnp-provisioning` and any other broad setup app.
3. Decide the guest invitation rule before adding a business partner.
4. Confirm the external sharing exception path before Stage 8 client workspace templates.
5. Record any accepted risks in the Decision Register before real partner/client onboarding.

