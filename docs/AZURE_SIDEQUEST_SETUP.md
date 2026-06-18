# Azure Side Quest Setup

Date: 2026-06-17

Status: tooling installed and login established. No Azure resources, resource groups, role assignments, app registrations, app consent grants, tenant policies, budgets, alerts, storage accounts, key vaults, or paid services were created.

## Purpose

Keep Azure setup separate from the Guided AI Labs CRM recovery so the CRM build can resume cleanly.

This side quest is only for preparing the local machine and confirming the starting Azure posture.

## Local Tooling Added

Free tools installed:

- Azure CLI 2.87.0
- Bicep CLI 0.44.1
- Azure Developer CLI (`azd`) 1.25.6
- Az.Accounts PowerShell module 5.5.0
- Az.Resources PowerShell module 10.0.0

Installed command paths in the current shell:

- Azure CLI: `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd`
- Bicep: `C:\Users\adamg\.azure\bin\bicep.exe`
- Azure Developer CLI: `C:\Users\adamg\AppData\Local\Programs\Azure Dev CLI\azd.exe`

Note: a fresh terminal should pick up `az` and `azd` from PATH. This existing shell needed full paths because the installs happened mid-session.

## Login State

Azure CLI login succeeded.

- User: `adamgoodwin@guidedailabs.com`
- Tenant ID: `1ca92af5-21ff-42e3-87ae-3bde9c2cc501`
- Subscription: `Azure subscription 1`
- Subscription ID: `400cfbf4-2447-4931-b9f3-659ce8d387e2`
- Subscription state: `Enabled`

Azure Developer CLI login also succeeded for `adamgoodwin@guidedailabs.com`.

## Read-Only Baseline

Confirmed signed-in Entra user:

- Display name: `Adam Goodwin`
- UPN: `adamgoodwin@guidedailabs.com`
- Object ID: `8344f12a-4ee9-4bb5-954a-056ec0a09008`

Subscription RBAC check:

- `az role assignment list --assignee adamgoodwin@guidedailabs.com --include-inherited --all` returned no role assignments.
- `az group list` failed with `AuthorizationFailed`.

Practical meaning: the user can authenticate to the tenant/subscription, but does not currently have enough Azure RBAC on the subscription to read or create resource groups. Azure setup cannot safely proceed past tooling and login until subscription access is fixed.

## Local CLI Adjustment

Set Azure CLI dynamic extension install to `no`:

```powershell
az config set extension.use_dynamic_install=no
```

Reason: a read-only command attempted to prompt for an extension install in a noninteractive shell. Future commands should fail clearly instead of blocking on prompts. Needed extensions can be installed deliberately.

## Cost Boundary

No billable Azure resources were created.

Potentially billable next steps include creating:

- Resource groups
- Storage accounts
- Key vaults
- App services
- Function apps
- Log Analytics workspaces
- Azure OpenAI or AI services
- Automation accounts
- Virtual networks
- Managed identities attached to deployed workloads

Before any of those are created, decide the Azure landing zone shape, budget controls, naming convention, and owner account.

## Permission Concern To Resolve

To actually set up Azure resources, the working account needs one of these paths:

- Adam is granted `Owner` on subscription `400cfbf4-2447-4931-b9f3-659ce8d387e2`.
- Adam is granted `Contributor` plus a separate human/admin handles role assignments.
- An admin/owner account is used for the initial Azure setup, then Adam receives a least-privilege operating role.

For automation that creates managed identities, assigns roles, or configures access, the setup account may also need `User Access Administrator` or `Owner`.

## Clean Resume Point For CRM

Resume CRM from:

```text
docs/CRM_RECOVERY_PLAN.md
```

CRM tenant writes still require:

```text
apply-gail-crm-recovery
```

This Azure side quest did not change the CRM SharePoint build, the CRM config, or any CRM tenant content.

## Recommended Next Azure Step

1. Decide which account should own the Azure subscription setup.
2. Grant that account subscription-level `Owner` or equivalent setup permissions.
3. Re-run a read-only baseline:

```powershell
az account show
az role assignment list --assignee adamgoodwin@guidedailabs.com --include-inherited --all
az group list
```

4. Create a tiny no-cost/low-cost Azure landing plan before any resources are deployed.
