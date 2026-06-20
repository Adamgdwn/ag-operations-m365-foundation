# Stage 7 Closeout Action Plan

Status: ✅ CLOSED 2026-06-20. All gates resolved (support MFA registered, Viva
Engage system-site sharing disabled, broad app grants accepted as residual risk);
closeout decisions recorded in the Decision Register + Agent Action Log. This
completes Phase 1 (the infrastructure spine). Retained for the audit trail.

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

## Decisions (2026-06-20)

Adam made the final Stage 7 closeout decisions:

- **Broad app grants (`agent-pnp-provisioning`): LEAVE CONSENTED AS-IS.** Accepted
  residual risk — consistent with keeping Global Admin on the daily identity. The
  app retains delegated `AllSites.FullControl` + `Group.ReadWrite.All`. Managed by
  MFA + consent discipline; revisit if/when JIT/PIM (Entra P1/P2) lands. This is a
  deliberate accept, not an oversight.
- **Viva Engage system site sharing: DISABLE.** No external Viva Engage community
  workflow exists, so close the exception to match the rest of the tenant. Gated
  tenant write (see runbook).
- **Stage 9 bridge: DECLARE READY, DEFER THE ADAPTER.** Production app/adapter
  intentionally deferred to a later deliberate decision; no new tenant power
  granted now.

## Remaining Gates

| Gate | Status | Outcome |
|---|---|---|
| Support mailbox MFA | ✅ Done 2026-06-20 | Adam registered a strong method for `support@changeleadershiptools.com` |
| Broad app grants | ✅ Closed 2026-06-20 | Left consented as-is (accepted residual risk); review by 2026-12-20; recorded in registers |
| Root/legacy site sharing | ✅ Applied + verified | Root, A.G. Operations Ltd, All Company disabled for external sharing |
| Viva Engage system site sharing | ✅ Done 2026-06-20 | Disabled via the site-sharing exception window (`-IncludeVivaEngageSystemSite -Apply`) |
| Closeout records | ✅ Done 2026-06-20 | Stage 7 + Stage 9 closeout written to Decision Register + Agent Action Log (single-Y apply) |

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
