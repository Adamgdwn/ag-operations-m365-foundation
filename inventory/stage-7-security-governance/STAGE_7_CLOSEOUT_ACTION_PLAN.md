# Stage 7 Closeout Action Plan

Status: active closeout plan (2026-06-14).

This plan keeps the remaining Stage 7 work efficient without turning it into
unattended high-trust automation.

## Current Position

Core Stage 7 governance is already applied, verified, and logged:

- guest invitations are restricted to admins and Guest Inviters;
- SharePoint/OneDrive tenant sharing is authenticated external users only;
- default sharing links are Direct / specific-people style;
- core operating sites are disabled for external sharing;
- Decision Register item #1 and Agent Action Log item #1 record the approved
  governance write window.

## Remaining Gates

| Gate | Status | Next action |
|---|---|---|
| Support mailbox MFA | Manual | Adam registers Authenticator or another strong method for `support@changeleadershiptools.com` |
| Broad app grants | Local plan ready | Use `stage-7-app-grant-resting-state-plan.md` to record a time-boxed active/resting-state decision |
| Root/legacy site sharing | Applied and read-back verified | Root, A.G. Operations Ltd, and All Company are now disabled for external sharing |
| Viva Engage system site sharing | Review only | Do not delete; accept or disable after confirming whether an external community workflow exists |

## Efficient Sequence

1. Generate the app grant resting-state plan:

```powershell
.\scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1
```

2. Register MFA for the support mailbox identity:

```text
https://mysignins.microsoft.com/security-info
```

Sign in as:

```text
support@changeleadershiptools.com
```

3. Root/legacy site sharing cleanup has been applied. The command used was:

```powershell
.\scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1 -Apply
```

Typed approval phrase used:

```text
apply-stage-7-site-sharing-cleanup
```

4. Read-only SharePoint sharing inventory was re-run:

```powershell
.\scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1
.\scripts\Summarize-M365Stage7SecurityInventory.ps1
```

5. Record final Stage 7 closeout in the Decision Register and Agent Action Log
   after support MFA and app-grant resting-state decisions are closed or
   explicitly accepted.

## Guardrails

- No app grant is revoked by the current app-grant plan.
- Site sharing cleanup was applied only after the apply window ran and the typed
  approval phrase was entered.
- No guest invitations, external links, public Forms links, mail sends, or client
  workspace access changes happen in this closeout plan.

## Recommended Stage 7 Exit Decision

```text
Stage 7 is considered ready for Stage 8 once support MFA is registered,
broad setup/admin app grants are explicitly time-boxed or accepted with a review
date, and the remaining Viva Engage system site sharing exception is accepted or
disabled after dependency review.
```
