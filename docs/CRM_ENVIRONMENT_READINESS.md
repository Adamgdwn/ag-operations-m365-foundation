# CRM Environment Readiness

Date: 2026-06-17

This file records the local machine/tooling state for the Guided AI Labs CRM recovery work. It is a local readiness artifact only; no SharePoint tenant-writing recovery scripts were run during this pass.

## Hardware and OS

- OS: Microsoft Windows 11 Home, 64-bit
- Machine: Dell Inc. Inspiron 7506 2n1
- CPU: 11th Gen Intel Core i7-1165G7, 8 logical processors
- RAM: 16 GB
- Disk: C drive has about 841 GB free; D drive has about 124 GB free
- Shell: PowerShell 7.6.2
- Execution policy: RemoteSigned for CurrentUser and LocalMachine

This is enough for the recovery path. The limiting factors are tenant permissions/licensing, not local hardware.

## Already Available

- Git 2.54.0
- GitHub CLI 2.92.0, authenticated as `Adamgdwn`
- Node.js 24.16.0 and npm 11.13.0
- Python 3.12.10
- Microsoft Edge and Google Chrome
- PnP.PowerShell 3.2.0
- Microsoft Graph PowerShell Authentication 2.37.0
- ExchangeOnlineManagement 3.10.0

## Added During Readiness Pass

Free tools installed because they are directly useful for the CRM recovery:

- .NET SDK 10.0.301
- Microsoft Power Platform CLI (`pac`) 2.8.1
- Microsoft.PowerApps.Administration.PowerShell 2.0.217
- Microsoft.PowerApps.PowerShell 1.0.45
- ImportExcel 7.8.10
- Playwright test runner 1.61.0

Free Azure side-quest tools installed after the CRM readiness pass:

- Azure CLI 2.87.0
- Bicep CLI 0.44.1
- Azure Developer CLI (`azd`) 1.25.6
- Az.Accounts PowerShell module 5.5.0
- Az.Resources PowerShell module 10.0.0

Notes:

- `pac` is installed at `%USERPROFILE%\.dotnet\tools\pac.exe`.
- New terminal sessions should find `pac` automatically from the user PATH. Existing shells may need `%USERPROFILE%\.dotnet\tools` added to the process PATH.
- Playwright browsers were not downloaded. The machine already has Edge and Chrome, so acceptance tests can target installed browser channels first.
- CLI for Microsoft 365 (`m365`) was tested and then removed because the current npm install resolved a transitive dependency to `lodash@4.18.0`, which npm marks as a bad release. Use PnP.PowerShell for SharePoint operations unless a cleaner `m365` install path is confirmed.
- Azure CLI is installed at `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd`.
- Azure Developer CLI is installed at `C:\Users\adamg\AppData\Local\Programs\Azure Dev CLI\azd.exe`.
- Bicep is installed at `C:\Users\adamg\.azure\bin\bicep.exe`.
- A fresh terminal should pick up the new Azure CLI and Azure Developer CLI PATH entries. The current shell may still need the full paths above.

## Current Auth State

- `m365`: not installed after removal due npm dependency concern
- `pac auth list`: no profiles found
- GitHub CLI: logged in
- Azure CLI: logged in as `adamgoodwin@guidedailabs.com` to tenant `1ca92af5-21ff-42e3-87ae-3bde9c2cc501`
- Azure Developer CLI: logged in as `adamgoodwin@guidedailabs.com`

Microsoft tenant-writing scripts remain gated by the approval phrase `apply-gail-crm-recovery`.

Azure baseline concern:

- Azure subscription `Azure subscription 1` exists and is enabled.
- Subscription ID: `400cfbf4-2447-4931-b9f3-659ce8d387e2`.
- `az group list` failed with `AuthorizationFailed` for `adamgoodwin@guidedailabs.com`.
- `az role assignment list --assignee adamgoodwin@guidedailabs.com --include-inherited --all` returned no assignments.

Practical meaning: Azure login works, but the signed-in user does not currently have enough Azure RBAC to read or create resource groups.

## Paid or Licensing Concerns

These items may cost money or require tenant-level entitlements:

- Power Apps Premium is currently listed by Microsoft at `$20.00 user/month, paid yearly`.
- Power Automate Premium is currently listed by Microsoft at `$15.00 user/month, paid yearly`.
- Power Automate Process, Hosted Process, AI Builder, premium connectors, Dataverse capacity, external portals/pages, unattended automation, and mailbox/Graph automation can introduce additional licensing or admin-consent requirements.

Recovery implication:

- Keep the MVP on SharePoint lists plus standard connectors where possible.
- Use a Power Apps intake form only if the tenant already allows it for SharePoint-backed apps.
- Treat email upload/parsing as a second-step enhancement unless standard connector rights are confirmed.

## Local Concerns

- The repository is already dirty from earlier Stage 8 work. Do not clean, reset, or delete generated evidence without explicit direction.
- The current recovery work should proceed on a dedicated branch before broad restructuring.
- The previous verifier gave a false pass. Fixing verification logic should happen before any new tenant writes.
- PAC has no auth profiles, and SharePoint/Graph readback commands will require a deliberate interactive login through PnP.PowerShell or Graph.
- Azure setup is blocked at the resource layer until Adam or the setup account has subscription-level `Owner`, or `Contributor` plus a separate owner/admin path for role assignments.

## Recommended Next Local Step

Create a recovery branch, then implement local-only changes first:

1. Fix the Stage 8C verifier so hidden fields with `ShowInNewForm=DefaultTrue` or `ShowInEditForm=DefaultTrue` fail.
2. Add a clean CRM source-of-truth config for navigation and operator flow.
3. Add browser/operator acceptance checks that prove the CRM title/front-door path opens the intended CRM experience and no daily operator card routes to raw `NewForm.aspx`.
4. Run read-only SharePoint baseline export after deliberate authentication.
5. Run tenant-writing recovery only after the explicit approval phrase.
