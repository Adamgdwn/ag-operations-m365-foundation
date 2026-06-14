# Microsoft 365 Foundation Roadmap

Captured on 2026-06-10.

## Purpose

Build Microsoft 365 into the clean operating foundation for AG Operations and Guided AI Labs.

This roadmap is for the human-supervised setup phase. It does not create unattended automation or the future Agentic OS. It prepares Microsoft 365 so a future Agentic OS can safely connect through governed access.

## North Star

Microsoft 365 should become the trusted operating substrate:

- Entra for identity, access, roles, and future app consent
- SharePoint for official records and reusable knowledge
- OneDrive for personal working drafts and controlled local sync
- Exchange for mail, calendar, intake, scheduling, and communication history
- Teams for collaboration, meetings, and client/team context
- Planner, Lists, To Do, and Approvals for operational state
- Purview, Defender, and admin centers for governance, audit, security, and policy
- Microsoft Graph and related admin modules as the controlled setup/API layer

The structure is not:

```text
everything routes through email
```

The structure is:

```text
intent gets classified
then routed to the right M365 surface
```

## Stage 0 - Setup Control Room

### What we are doing

Create the local setup files and tooling needed to help inspect and configure the tenant.

### Why

Before changing the tenant, we need a repeatable way to know which tenant, domains, accounts, and app registration we are working with.

### Main tools

- `M365_ENVIRONMENT.template.env`
- Microsoft Graph PowerShell
- Exchange Online PowerShell
- Teams PowerShell
- PnP PowerShell
- Entra admin center

### Done when

- tenant ID is recorded
- app/client ID is recorded
- core account names are recorded
- no secrets are stored in the environment file
- local admin modules are installed for the current Windows user

## Stage 1 - Current-State Inventory

### What we are doing

Read the tenant as it exists today.

### Why

We do not want to design from assumptions. The inventory tells us what users, domains, groups, licenses, admin roles, sites, teams, mailboxes, and apps already exist.

### Main tools

- Microsoft Graph PowerShell
- Microsoft 365 admin center
- Entra admin center
- Exchange admin center
- SharePoint admin center
- Teams admin center

### What we inventory

- verified domains
- users and licenses
- admin roles
- groups
- app registrations and enterprise applications
- SharePoint sites
- Teams
- mailboxes, aliases, and shared mailbox candidates
- current OneDrive/sync assumptions
- existing local machine account connections

### Done when

We have a written current-state inventory and can say:

```text
this is what exists now
this is what is safe
this is what is messy
this is what needs a decision
```

## Stage 2 - Identity And Admin Foundation

### What we are doing

Clarify which accounts are for humans, administration, front-door/contact, support, and future agent/service access.

### Why

Identity is the foundation for every later decision. If account roles are blurry, SharePoint, email, Teams, and automation permissions will all become blurry too.

### Main decisions

- which account is the controlled admin account
- which account is Adam's daily working identity
- whether `contact@guidedailabs.com` should keep admin access temporarily
- whether to create a break-glass admin account
- which accounts are licensed users versus shared mailboxes or aliases
- which accounts could eventually be agent-monitored

### Main tools

- Entra admin center
- Microsoft 365 admin center
- Microsoft Graph PowerShell

### Done when

Every account has a role:

```text
admin
daily human
front door
support
shared mailbox
alias
guest
future service/agent identity
```

And we have a safe path for reducing unnecessary admin access.

## Stage 3 - SharePoint Information Architecture

### What we are doing

Design and build the official company record structure.

### Why

SharePoint is the filing cabinet, knowledge base, client record layer, and reusable method library. If this is clean, future search, Copilot, and Agentic OS retrieval become far more useful.

### Starting site candidates

- AG Operations
- Guided AI Labs
- Shared Libraries
- Change Leadership Tools

Additional sites, such as Guided AI Journey or product-specific sites, should be created when they have enough real use to justify separate structure.

### Main design choices

- site versus library versus folder
- naming conventions
- owner/member/visitor groups
- external sharing level per site
- archive structure
- templates and reusable methods
- client workspace pattern

### Main tools

- SharePoint admin center
- Microsoft 365 admin center
- PnP PowerShell
- Teams, where a site is collaboration-backed

### Done when

We can answer:

```text
Where does this official record live?
Who owns it?
Who can see it?
Can it be shared externally?
Is it reusable IP, client-owned work, product material, or admin record?
```

## Stage 4 - OneDrive And Local Machine Dovetail

> **Absorbs the local-machine track (2026-06-11).** The earlier device-side work
> — laptop folder lanes, Chrome profiles per identity, OneNote/OneDrive/SharePoint
> sync hygiene, and the desktop Office license conflict — is the practical half of
> this stage. Treat these as Stage 4 inputs:
> [README.md](README.md),
> [M365_SHAREPOINT_ONENOTE_SPLIT.md](M365_SHAREPOINT_ONENOTE_SPLIT.md),
> [NEXT_SESSION_CHECKLIST.md](NEXT_SESSION_CHECKLIST.md),
> [SYSTEM_NOTES_FROM_INITIAL_DIG.md](SYSTEM_NOTES_FROM_INITIAL_DIG.md),
> [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md).
> They are not the current step — Stage 2 comes first.

### What we are doing

Define how OneDrive, local folders, synced SharePoint libraries, Office desktop apps, and browser profiles work together.

### Why

This is where daily friction either disappears or multiplies. The goal is not to sync everything. The goal is to make active work easy without creating local file chaos.

### Core rule

```text
SharePoint = official record
OneDrive = personal working drafts
Local machine = active work/cache/access layer
```

### Main choices

- which OneDrive account is connected locally
- which SharePoint libraries are synced
- which sites remain browser-only
- how Desktop/Documents/Pictures known folders are handled
- how Office desktop sign-in behaves
- how Chrome profiles map to M365 identities
- how OneNote notebooks are opened/closed per context

### Main tools

- Windows Settings
- OneDrive client
- Office desktop account settings
- Chrome profiles
- SharePoint browser UI
- OneNote

### Done when

Adam can work day to day without guessing:

```text
Am I in the right account?
Is this draft or official?
Is this local, OneDrive, SharePoint, or client-owned?
Should this be synced or browser-only?
```

## Stage 5 - Exchange And Communication Routing

### What we are doing

Clarify mailboxes, aliases, calendars, shared mailboxes, support addresses, and front-door routing.

### Why

Email is not the hub, but it is a major signal source. Intake, scheduling, support, commitments, and external communication need clear ownership.

### Current key addresses

- `admin@agoperations.ca`
- `adamgoodwin@guidedailabs.com`
- `contact@guidedailabs.com`
- `support@changeleadershiptools.com`

### Main choices

- licensed user versus shared mailbox
- aliases versus separate accounts
- who owns each calendar
- whether front-door/contact accounts are agent-monitored later
- support workflow for Change Leadership Tools
- whether forwarding, groups, or shared mailboxes are needed

### Main tools

- Exchange admin center
- Microsoft 365 admin center
- Exchange Online PowerShell
- Outlook

### Done when

Every address has a purpose:

```text
admin/legal
daily human
front-door/contact
support
sales/inquiry
product-specific
alias only
shared mailbox
```

## Stage 6 - Teams, Planner, Lists, And Operating State

### What we are doing

Set up collaboration and workflow surfaces after the record and identity model are clear.

### Why

Teams is for collaboration, not filing. Planner and Lists are for work state, not
random notes. Forms are controlled front doors for intake and feedback. This
stage prevents Teams sprawl and keeps operational state visible.

### Starting Teams candidates

- AG Operations - Admin
- Guided AI Labs - Operating Team
- Guided AI Labs - Client Delivery
- Change Leadership Tools - Support

### Operating surfaces

- Planner for tasks and recurring work
- Lists for registers and trackers
- Forms for structured intake, support, session feedback, and retrospectives
- Approvals for controlled decisions
- Teams channels for active collaboration
- SharePoint libraries behind Teams for official files

### Main tools

- Teams admin center
- Teams app
- Planner
- Microsoft Lists
- Power Automate approvals

### Done when

We can answer:

```text
Where do conversations happen?
Where do form responses go?
Where do tasks live?
Where do decisions get recorded?
Where do official files go after collaboration?
```

## Stage 7 - Security, Governance, And External Sharing

Status: started locally 2026-06-14. See
[M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
and [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json).
No Stage 7 tenant changes have been made.

### What we are doing

Set tenant-wide and site-level safety boundaries.

### Why

Future AI access only works if Microsoft 365 already has clean permissions, labels, sharing rules, and audit posture.

### Main areas

- MFA and admin role review
- guest access
- external sharing by site
- sensitivity labels, if licensed/available
- retention and archive approach
- device/security policy direction
- audit and sign-in review
- license upgrade decision, likely Business Premium for key accounts
  - **Check FREE path first:** Microsoft for Startups Founders Hub may grant
    Guided AI Labs **Business Premium at no cost** (+ Azure credits). Applying as
    the AI-product entity could unlock Entra ID P1 / Conditional Access / Intune /
    Defender for free — see [TOOLING_AND_LICENSING.md](TOOLING_AND_LICENSING.md).

### Main tools

- Entra admin center
- Microsoft 365 admin center
- Purview
- Defender
- SharePoint admin center
- Teams admin center

### Local artifacts

- `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md`
- `config/M365_STAGE_7_GOVERNANCE_BASELINE.json`
- `scripts/Invoke-M365Stage7SecurityInventory.ps1`
- `scripts/Start-M365Stage7SecurityInventoryInteractive.ps1`
- `scripts/Summarize-M365Stage7SecurityInventory.ps1`
- `scripts/Test-M365Stage7LocalPreflight.ps1`
- `inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md`

The first Stage 7 implementation path is read-only inventory. Policy, guest,
sharing, consent, and role changes remain explicit human-approved gates.

### Done when

We have written rules for:

```text
who can access what
what can be shared externally
which data is sensitive
what requires approval
what must be audited
what should not sync locally
```

## Stage 8 - Client Workspace Reference Pattern

Status: planned. See
[M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md).

### What we are doing

Turn Guided AI Labs' own setup into a repeatable client setup model.

### Why

This becomes part of the consulting offer. Clients need to understand how M365 should be structured before AI can make it better.

### Main outputs

- client infrastructure discovery checklist
- client M365 readiness checklist
- client workspace template
- handoff/ownership model
- "what lives in the client tenant versus Guided AI Labs tenant" rule

### Done when

Guided AI Labs can explain and repeat:

```text
Here is where your records live.
Here is where your team collaborates.
Here is where your tasks and decisions live.
Here is how future AI safely connects.
Here is what you own when we leave.
```

## Stage 9 - Agentic OS Bridge Readiness

Status: planned. See
[M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md).

### What we are doing

Prepare for the future bridge without building unattended automation yet.

### Why

The Agentic OS will be built elsewhere, but Microsoft 365 needs to be ready for governed access.

### Main preparation

- document app registrations
- use delegated permissions first
- avoid broad write permissions
- separate setup helper app from future production bridge app
- define read/write/approval categories
- define audit and rollback expectations

### Main tools

- Entra app registrations
- Enterprise applications
- Microsoft Graph (API-first — the token-cheapest, most auditable interface)
- a Webwright-style code-driven browser for the few portal-only tasks with no Graph
  API (low-privilege/read only) — see [TOOLING_AND_LICENSING.md](TOOLING_AND_LICENSING.md)
- Power Automate
- n8n later
- future Agentic OS bridge

### Done when

We can say:

```text
The future Agentic OS knows where to read,
where to write,
what it may not touch,
what requires approval,
and how actions are logged.
```

## Recommended Working Order

Use this order for the actual build:

1. Stage 0 - Setup Control Room
2. Stage 1 - Current-State Inventory
3. Stage 2 - Identity And Admin Foundation
4. Stage 3 - SharePoint Information Architecture
5. Stage 4 - OneDrive And Local Machine Dovetail
6. Stage 5 - Exchange And Communication Routing
7. Stage 6 - Teams, Planner, Lists, And Operating State
8. Stage 7 - Security, Governance, And External Sharing
9. Stage 8 - Client Workspace Reference Pattern
10. Stage 9 - Agentic OS Bridge Readiness

## The Big Practical Sequence

In plain language:

```text
First know what exists.
Then make identity safe.
Then build the official records home.
Then make local day-to-day work smooth.
Then clean up email and collaboration.
Then add task/process state.
Then harden governance.
Then turn it into a client-ready pattern.
Then prepare the future AI bridge.
```
