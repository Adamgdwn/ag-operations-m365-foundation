# Stage 6 Provisioning Audit - 2026-06-14

## Summary

Stage 6 Lists are provisioned and read-back verified. Planner/Teams automation
has been scaffolded in the same operator style. The first visible run timed out
at Graph device-code authentication before live writes. A local onboarding
readiness packet now captures the partner/client readiness work that should
surround the Microsoft 365 objects.

The original automation blocker is resolved. PnP was authorized correctly, but
the persisted delegated login was using `admin@agoperations.ca` instead of
`adamgoodwin@guidedailabs.com`.

## Confirmed

- PowerShell 7 is the correct host for Stage 6 PnP scripts on this machine.
- `PnP.PowerShell` 3.2.0 is installed under the PowerShell 7 module path.
- `adamgoodwin@guidedailabs.com` was added as secondary site collection admin on:
  - `https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools`
  - `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
- The four Stage 6 Lists were created by
  `stage-6-provision-lists-20260614-134436.log`.
- The four Stage 6 Lists were verified by
  `stage-6-verify-lists-20260614-135144.log`.
- The Planner/Teams operator scripts parse and are included in local preflight:
  - `scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1`
  - `scripts\Invoke-M365Stage6ProvisionPlannerTeams.ps1`
  - `scripts\Invoke-M365Stage6PlannerTeamsOperator.ps1`
  - `scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1`
- Local-only Stage 6 preflight passes after adding the Planner/Teams operator.
- Local-only Stage 6 preflight passes after adding the onboarding readiness
  packet.
- Onboarding readiness artifacts exist under
  `inventory/stage-6-operating-state/onboarding-readiness/`.

## Failed Runs - Historical

Provisioning attempts failed at `New-PnPList` with:

```text
Attempted to perform an unauthorized operation.
```

The read-only PnP permission diagnostic can connect to the sites but fails on
`Get-PnPWeb` with the same unauthorized operation.

Latest read-only diagnostic:

- `stage-6-pnp-permissions-20260614-131420.log`
- Result: connected to both target sites using PnP `ConnectionType: O365`.
- Failure: `Get-PnPWeb` still returns `Attempted to perform an unauthorized
  operation` for both `ChangeLeadershipTools` and `GuidedAILabs`.
- Interpretation: the app identity may look clean in Entra, but the current
  delegated consent/scope posture is still not sufficient for SharePoint site
  operations.

Follow-up after admin consent review:

- `stage-6-pnp-permissions-20260614-131944.log`
- `stage-6-pnp-permissions-20260614-132010.log` with `-ForceFreshLogin`
- Result: both runs still connect to the sites but fail at read-only
  `Get-PnPWeb` with `Attempted to perform an unauthorized operation`.
- Interpretation: this is not only a stale token issue. Automated PnP tenant
  writes should remain paused.

Root-cause refinement:

- `stage-6-pnp-token-claims-20260614-133641.log` shows the SharePoint token has
  the expected delegated scopes:
  `AllSites.FullControl Group.ReadWrite.All User.Read`.
- The same token is for `upn: admin@agoperations.ca`, not
  `adamgoodwin@guidedailabs.com`.
- Because this is delegated authentication, PnP acts as the signed-in user. The
  app scopes are present, but the wrong user is being reused from the persisted
  login cache.
- `Test-M365Stage6PnPPermissions.ps1` now has an expected-user guard and
  `-UseDeviceLogin` option to force/signpost the correct account.

Resolution:

- `stage-6-pnp-permissions-20260614-133909.log` was completed with
  `-UseDeviceLogin`.
- Token/user context: `adamgoodwin@guidedailabs.com`.
- Result: read-only `Get-PnPWeb` succeeded on both `ChangeLeadershipTools` and
  `GuidedAILabs`.
- The original blocker was wrong delegated user context from persisted PnP login,
  not missing app scopes.

Read-only list verification after resolution:

- `stage-6-verify-lists-20260614-134300.log`
- Auth: `-UseDeviceLogin`
- Token/user context: `adamgoodwin@guidedailabs.com`
- Result: both target sites are readable.
- Expected pre-provisioning state confirmed: all four Stage 6 Lists were missing.

Provisioning and final verification:

- `stage-6-provision-lists-20260614-134436.log`
- Auth: `-UseDeviceLogin`
- Token/user context: `adamgoodwin@guidedailabs.com`
- Result: all four Stage 6 Lists were created with expected fields and views.
- `stage-6-verify-lists-20260614-135144.log`
- Result: PASS - all Stage 6 Lists, fields, and views match the schema.

Planner/Teams operator preparation:

- A first non-interactive Graph attempt failed from the embedded shell because
  Windows WAM interactive auth had no parent window handle.
- The Planner/Teams visible launcher now defaults to device-code auth and uses
  `-WindowStyle Normal`.
- The Planner/Teams operator now waits for Adam to press Enter before requesting
  the Microsoft device code, so the short auth timer does not burn down while
  the window is unattended.
- A safer visible `ProvisionAndVerify` run was relaunched at 2026-06-14 14:18
  and should be parked before Graph auth until Adam presses Enter. No new
  Planner/Teams provision log exists yet.
- `stage-6-verify-planner-teams-20260614-141248.log` was started by the visible
  `ProvisionAndVerify` run and stopped before Graph connection because
  device-code auth timed out after 120 seconds of inactivity.
- `stage-6-verify-planner-teams-20260614-155523.log` also stopped before Graph
  connection because device-code auth timed out after 120 seconds. No
  Planner/Teams provision log was created.
- The Planner/Teams operator was then optimized to preserve the Graph connection
  across preflight, provisioning, and post-verification phases after successful
  sign-in, reducing avoidable repeated auth prompts in the live path.
- `stage-6-verify-planner-teams-20260614-173056.log` showed the PowerShell
  `Read-Host` pause was still skipped in a spawned visible window, so Graph
  device-code auth again timed out before connection. No Planner/Teams provision
  log was created.
- The visible M365 launchers were repaired to open `cmd.exe`, pause before
  PowerShell starts, and only then run the Graph/PnP script. A fixed
  `ProvisionAndVerify` Planner/Teams window is now parked before auth.
- No Planner/Teams provision log exists yet, so no Planner/Teams tenant write is
  recorded from this run.
- The live write gate remains the typed phrase `planner-teams`.

## Root Cause

The blocker was not the local PowerShell host, the Stage 6 schema, Adam's site
collection admin role, or missing app scopes.

Root cause: persisted PnP login reused the wrong delegated user. Because the
automation uses delegated permissions, SharePoint operations are performed as the
signed-in user. The repair was to clear persisted PnP login state, use device
login, and add an expected-user guard to Stage 6 scripts.

## Consent Warning

A raw Microsoft admin-consent URL for `agent-pnp-provisioning` produced multiple
errors including a phishing warning. That path is not approved.

Do not approve consent from raw links or any page showing phishing, risky app,
unknown publisher, or suspicious consent warnings.

Use the Microsoft Entra admin center directly for any future review:

```text
https://entra.microsoft.com
```

Checklist helper:

```powershell
.\scripts\Show-M365Stage6PnPConsentReviewChecklist.ps1
```

## Safe Next Options

1. Use `STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md` for Planner/Teams setup only after
   Lists exist and read-back verification is clean.
2. Run `scripts\Test-M365Stage6LocalPreflight.ps1` anytime to validate the local
   Stage 6 package without connecting to Microsoft 365.
3. Use `first-run-packet/STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md`
   and its starter CSVs for the first human-approved agent loop.
4. Run `scripts\Update-M365Stage6LocalArtifacts.ps1` to regenerate all local
   Stage 6 guides and preflight outputs in one no-tenant-write pass.
5. Keep using `-UseDeviceLogin` and the expected-user guard for future Stage 6
   PnP operations.
6. Prefer `scripts\Start-M365Stage6ListOperatorInteractive.ps1` for future List
   operations so preflight, repair, provisioning, and verification stay in one
   efficient operator flow.
7. Prefer `scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify`
   for Planner/Teams read-back.
8. Use `scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify`
   for the live Planner/Teams gate. It creates or confirms the Planner plan,
   buckets, Team-backing for the existing Guided AI Labs group, channels, and
   best-effort website tabs; it does not create guests, external sharing,
   mailbox rules, sends, calendar commitments, tenant policies, or membership
   changes.
9. Use `inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`
   before adding a partner or using this as a first client onboarding pattern.

## Desired Future Posture

The target experience remains:

```text
Codex prepares and runs preflight -> Adam approves only meaningful visible gates
-> Codex provisions/updates -> read-back verification -> transcripted audit
```

Routine runs should use persisted Microsoft/PnP login where permitted. Broad app
consent should be reviewed explicitly and disabled/revoked when not actively
needed.
