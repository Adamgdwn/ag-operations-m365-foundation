# Session Turnover - 2026-06-10

## Purpose Of Today's Work

Move from conceptual Microsoft 365 planning into the first real setup stage for AG Operations / Guided AI Labs.

The working boundary was clarified:

```text
We are not building the Agentic OS here.
We are building the Microsoft 365 foundation that the future Agentic OS can safely connect to.
```

The long-term model is:

```text
Agentic OS
  -> governed bridge
  -> Microsoft 365 touchpoint router
  -> correct Microsoft 365 surface
```

Microsoft 365 should become the governed operating substrate:

- identity and access through Entra
- official records through SharePoint
- day-to-day drafts through OneDrive
- communications and calendar signals through Exchange
- collaboration through Teams
- operating state through Planner, Lists, To Do, and Approvals
- governance through Purview, Defender, Admin Centers, audit, and policy
- future bridge through Microsoft Graph and scoped app registrations

## Major Clarifications From Conversation

### Email Is Not The Hub

We explicitly rejected the idea that the future model should route everything through email.

Correct model:

```text
Classify intent first.
Then route to the right M365 touchpoint.
```

Examples:

| Intent | M365 surface |
|---|---|
| Official record | SharePoint |
| Personal draft / active working file | OneDrive |
| Conversation / meeting context | Teams |
| External communication / calendar signal | Exchange |
| Task / status / owner / recurring process | Planner, Lists, To Do |
| Approval | Approvals / Power Automate |
| Identity / permission / consent | Entra |
| Audit / retention / DLP / labels | Purview / Defender / Admin Centers |

### Agentic OS Is External

The Agentic OS is being built elsewhere.

This workspace is about preparing Microsoft 365 so that future system can:

- read from the right places
- write to the right places
- avoid inheriting file chaos
- avoid inheriting permission chaos
- operate through audit, approval, and scoped authority

### Desired Future Experience

Adam wants this to become a product-like guided setup experience, not just raw admin notes.

Future direction:

- desktop launcher
- custom icon
- clear setup dashboard
- visual roadmap
- current stage / next action
- inventory reports
- guided admin checklists
- links to relevant admin centers
- scripts that run only with human-supervised sign-in

This should feel like a real internal operating tool over time.

## Files Created Or Updated Today

### Core Roadmap

[M365_FOUNDATION_ROADMAP.md](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/M365_FOUNDATION_ROADMAP.md>)

Purpose:

- staged roadmap for building the M365 foundation
- explains what each stage does and why
- watcher-friendly structure

Recommended sequence:

1. Setup Control Room
2. Current-State Inventory
3. Identity And Admin Foundation
4. SharePoint Information Architecture
5. OneDrive And Local Machine Dovetail
6. Exchange And Communication Routing
7. Teams, Planner, Lists, And Operating State
8. Security, Governance, And External Sharing
9. Client Workspace Reference Pattern
10. Agentic OS Bridge Readiness

### API Access Start Guide

[2026-06-10_M365_API_ACCESS_REFERENCE.md](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/2026-06-10_M365_API_ACCESS_REFERENCE.md>)

Purpose:

- explains Microsoft Graph as the main API surface
- explains Entra as the identity/consent layer
- distinguishes delegated access from application permissions
- recommends delegated, read-only inventory first

Important principle:

```text
Do not ask Microsoft 365 for maximum access.
Ask for the smallest permission that lets the specific tool do the specific job.
```

### Environment Template

[M365_ENVIRONMENT.template.env](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/M365_ENVIRONMENT.template.env>)

Purpose:

- records tenant/app/admin constants
- does not contain secrets
- currently includes tenant ID, app/client ID, object ID, domains, accounts, and admin portal URLs

Known values captured:

```text
Tenant: A.G. Operations Ltd
Tenant ID: 1ca92af5-21ff-42e3-87ae-3bde9c2cc501
Primary domain: agoperations.ca
Initial domain: AGOperationsLtd.onmicrosoft.com
App name: AG Operations Agentic Partner
Client ID: 2d0c6ba1-1ad9-494e-8583-5442f84c4199
Object ID: 4bcce061-1133-4b95-9ac5-60d09ae846c4
```

No passwords, client secrets, MFA codes, or recovery codes should be stored in this file.

### Touchpoint Routing Map

[m365-agentic-os-touchpoint-routing-map-preview.html](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/m365-agentic-os-touchpoint-routing-map-preview.html>)

[m365-agentic-os-touchpoint-routing-map.png](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/m365-agentic-os-touchpoint-routing-map.png>)

[m365-agentic-os-touchpoint-routing-map.svg](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/m365-agentic-os-touchpoint-routing-map.svg>)

Purpose:

- visual explanation of how the future Agentic OS connects to Microsoft 365
- shows touchpoints rather than a circular hub
- useful for client explanation

Key model:

```text
Agentic OS -> Governed Bridge -> Touchpoint Router -> Correct M365 Surface
```

### Stage 1 Inventory Script

[scripts/Invoke-M365Stage1InventoryRest.ps1](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/scripts/Invoke-M365Stage1InventoryRest.ps1>)

Purpose:

- robust Stage 1 inventory script
- uses Microsoft identity device-code authentication
- calls Microsoft Graph REST directly
- writes JSON inventory files
- avoids the Graph PowerShell `Connect-MgGraph` listener issue encountered today

Important:

- This is the preferred path going forward.
- It uses delegated read scopes.
- It does not create unattended automation.
- It does not store secrets.

### Earlier Graph PowerShell Script

[scripts/Invoke-M365Stage1Inventory.ps1](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/scripts/Invoke-M365Stage1Inventory.ps1>)

Purpose:

- original Microsoft Graph PowerShell SDK attempt

Status:

- kept for reference
- not preferred after the `Connect-MgGraph` listener failure

Recommendation:

```text
Use Invoke-M365Stage1InventoryRest.ps1 instead.
```

### Stage 1 Report

[M365_STAGE_1_CURRENT_STATE_INVENTORY.md](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/M365_STAGE_1_CURRENT_STATE_INVENTORY.md>)

Purpose:

- formal written summary of the current-state inventory
- identifies what exists now
- flags Stage 2 risks and next decisions

### Valid Inventory Folder

```text
inventory/stage-1-current-state/20260610-173554
```

This is the valid inventory run.

Contains:

- `organization.json`
- `domains.json`
- `subscribed-skus.json`
- `users.json`
- `groups.json`
- `directory-roles.json`
- `directory-role-members.json`
- `sites.json`
- `app-registrations.json`
- `enterprise-applications.json`
- `auth-context.json`
- `summary.json`

Note:

- The inventory completed successfully through all real data collection.
- The script originally failed while creating the final `summary` object.
- `summary.json` was generated manually afterward from the saved JSON files.
- The script has since been patched to reduce the chance of that summary failure recurring.

### Failed Inventory Folders

These folders are not valid inventory:

```text
inventory/stage-1-current-state/20260610-172735
inventory/stage-1-current-state/20260610-173346
```

Each contains a `FAILED_RUN_NOTE.md`.

Reasons:

- first failed because `Connect-MgGraph` had a listener/auth issue
- second failed because the REST script initially had a PowerShell 7 error-response parsing bug

Do not use these folders for current-state analysis.

## Tools Installed Today

PowerShell modules were installed under the current Windows user only:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Install-Module MicrosoftTeams -Scope CurrentUser
Install-Module PnP.PowerShell -Scope CurrentUser
```

Meaning:

- available to Adam's Windows user on this machine
- not machine-wide
- not installed for all future apps or agents
- appropriate for human-supervised setup and inventory

PowerShell 7 is installed and available at:

```text
C:\Program Files\PowerShell\7\pwsh.exe
```

## Stage 1 Inventory Findings

Source:

[M365_STAGE_1_CURRENT_STATE_INVENTORY.md](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/M365_STAGE_1_CURRENT_STATE_INVENTORY.md>)

### High-Level Counts

| Area | Count |
|---|---:|
| Organization | A.G. Operations Ltd |
| Domains | 4 |
| Users | 4 |
| Groups | 3 |
| Subscribed SKUs | 1 |
| Directory roles inventoried | 12 |
| Directory role assignments | 14 |
| SharePoint sites | 5 |
| App registrations | 1 |
| Enterprise applications | 169 |

### Domains

| Domain | Note |
|---|---|
| agoperations.ca | default custom domain |
| AGOperationsLtd.onmicrosoft.com | initial Microsoft tenant domain |
| guidedailabs.com | verified |
| changeleadershiptools.com | verified |

### Users

| Account | Role interpretation |
|---|---|
| admin@agoperations.ca | tenant/admin/legal backbone |
| adamgoodwin@guidedailabs.com | Adam's day-to-day Guided AI Labs identity |
| contact@guidedailabs.com | front-door / future assistant-monitored account |
| support@changeleadershiptools.com | Change Leadership Tools support identity |

All four accounts are enabled and licensed.

### Major Risk

```text
contact@guidedailabs.com is currently a Global Administrator.
```

Do not remove this immediately without a break-glass/recovery plan.

### Admin Role Observations

Global Administrators found:

- `admin@agoperations.ca`
- `adamgoodwin@guidedailabs.com`
- `contact@guidedailabs.com`

Other broad roles are assigned mostly to:

```text
adamgoodwin@guidedailabs.com
```

This is understandable during setup, but Stage 2 should rationalize it.

### SharePoint State

Current SharePoint footprint is small and mostly default/system generated.

This is good news because the desired information architecture can still be built cleanly.

Expected future sites are not yet fully built:

- AG Operations
- Guided AI Labs
- Shared Libraries
- Change Leadership Tools
- possible later product/client-specific sites

### App Registration State

One app registration exists:

```text
AG Operations Agentic Partner
```

It is single-tenant:

```text
AzureADMyOrg
```

This is correct for now.

Recommended interpretation:

- setup/helper app for now
- not an unattended production Agentic OS bridge
- future production bridge should probably be a separate app registration

## What Went Wrong Today

### Graph PowerShell Auth Issue

Initial attempt used:

```powershell
Connect-MgGraph
```

Failure:

```text
An error occurred when writing to a listener.
```

Decision:

```text
Do not use Graph PowerShell authentication as the primary inventory path.
Use direct REST device-code auth instead.
```

### REST Script Bug

The first REST script attempt failed because PowerShell 7 exposes REST error responses differently than Windows PowerShell.

Fixed by updating the polling error handler.

### Summary Object Failure

The successful REST inventory run failed only at final summary generation:

```text
Argument types do not match
```

The actual inventory files were already written.

Actions taken:

- generated `summary.json` manually from the saved data
- patched the script summary calculation
- syntax checked the patched script

## Current State At Shutdown

Stage 1 is complete.

Valid current-state report exists:

[M365_STAGE_1_CURRENT_STATE_INVENTORY.md](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/M365_STAGE_1_CURRENT_STATE_INVENTORY.md>)

Valid inventory data exists:

```text
inventory/stage-1-current-state/20260610-173554
```

Preferred future inventory script:

[scripts/Invoke-M365Stage1InventoryRest.ps1](</c:/Users/adamg/01. Code Projects/AG Operations Workspace Setup/scripts/Invoke-M365Stage1InventoryRest.ps1>)

## Recommended Resume Point Tomorrow

Start with:

```text
Stage 2 - Identity And Admin Foundation
```

Primary goal:

```text
Create a clean account/admin role model before changing SharePoint, OneDrive, Exchange, or Teams structure.
```

Stage 2 should produce:

- account role matrix
- admin role strategy
- break-glass/recovery plan
- decision plan for removing Global Administrator from `contact@guidedailabs.com`
- decision plan for reducing daily-user admin sprawl
- service/agent identity naming standard
- license/user/shared mailbox/alias interpretation

Do not begin by removing roles.

First build the safety net.

## Tomorrow's Suggested First 60-90 Minutes

1. Re-read the Stage 1 report.
2. Confirm the four current account roles.
3. Decide whether to create a true break-glass admin account.
4. Define where its credentials/recovery information live.
5. Decide whether `contact@guidedailabs.com` should temporarily remain Global Administrator until that is complete.
6. Build the account role matrix.
7. Only then plan admin role cleanup.

## Productized Tool Direction For Later

Adam wants this to become more usable and visible than a folder full of scripts.

Potential internal tool:

```text
AG Operations M365 Foundation Console
```

Possible features:

- desktop launcher
- custom icon
- dashboard showing current stage
- "Run inventory" button
- "Open latest report" button
- "Open admin center" buttons
- roadmap checklist
- setup status indicators
- report viewer
- decision log
- safe script runner
- visual M365 touchpoint map

Possible launcher approach:

- PowerShell launcher first
- then small local HTML dashboard
- later packaged desktop shortcut
- custom `.ico` file
- eventually a simple Electron/Tauri/.NET wrapper only if justified

Keep this grounded:

```text
First make the process reliable.
Then make it beautiful.
Then make it reusable for clients.
```

## Closing Notes

Today moved the project from planning into verified tenant reality.

The most important strategic finding is that the tenant is still small and clean enough to structure well, but the identity/admin layer needs attention before the file/collaboration architecture is built out.

The most important tactical finding is that direct Graph REST inventory is more reliable in this environment than the Graph PowerShell authentication wrapper.

The next serious work is not SharePoint yet.

The next serious work is:

```text
identity safety first
then records architecture
then local/day-to-day working flow
```

