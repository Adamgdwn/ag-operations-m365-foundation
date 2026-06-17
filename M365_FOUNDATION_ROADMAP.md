# Microsoft 365 Foundation Roadmap

Captured on 2026-06-10.

## Purpose

Build Microsoft 365 into the clean operating foundation for AG Operations and Guided AI Labs.

Current operating-site rule: **Guided AI Labs is the daily workplace and source
of truth. AG Operations root SharePoint is the portfolio/router landing site**
for Guided AI Labs and any future companies underneath AG Operations.

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

Status: live gate complete 2026-06-14. Lists, Planner plan/buckets, Teams
channels, and web tabs are provisioned and read-back verified.

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

Status: active 2026-06-14. Graph and SharePoint sharing read-only inventory
captured before and after the core guest/sharing governance write window. Guest
invites are now restricted to admins/Guest Inviters, SharePoint tenant sharing is
authenticated external users only, and default sharing links are specific-people
style. The approved governance batch is recorded in the Guided AI Labs Decision
Register and Agent Action Log. See
[M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
and [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json).
Stage 7 tenant changes made so far: guest invitation policy restricted to
admins/Guest Inviters; SharePoint/OneDrive tenant sharing tightened to
authenticated external users only; default sharing link changed to Direct.
Operating evidence was written to Decision Register item #1 and Agent Action Log
item #1 on 2026-06-14.

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
- `scripts/Invoke-M365Stage7SharePointSharingInventory.ps1`
- `scripts/Start-M365Stage7SharePointSharingInventoryInteractive.ps1`
- `scripts/Invoke-M365Stage7GovernanceWriteWindow.ps1`
- `scripts/Start-M365Stage7GovernanceWriteWindowInteractive.ps1`
- `scripts/Invoke-M365Stage7RecordGovernanceDecision.ps1`
- `scripts/Start-M365Stage7RecordGovernanceDecisionInteractive.ps1`
- `scripts/Invoke-M365Stage7GovernanceReviewPack.ps1`
- `scripts/Invoke-M365Stage7AppGrantRestingStatePlan.ps1`
- `scripts/Invoke-M365Stage7SiteSharingExceptionWindow.ps1`
- `scripts/Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1`
- `scripts/Summarize-M365Stage7SecurityInventory.ps1`
- `scripts/Test-M365Stage7LocalPreflight.ps1`
- `inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md`
- `inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md`
- `inventory/stage-7-security-governance/20260614-191812/stage-7-security-inventory-summary.md`
- `inventory/stage-7-security-governance/20260614-193825/stage-7-security-inventory-summary.md`
- `inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md`
- `inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md`

The first Stage 7 Graph and SharePoint sharing read-only inventory is captured,
the initial guest/sharing policy batch is applied, verified, and logged in the
operating Lists. Root/legacy site sharing cleanup was then applied and
read-back verified for the root, A.G. Operations Ltd, and All Company sites. The
local-only review pack and app-grant resting-state plan are ready. Remaining
policy, consent, role, and system-site exception changes remain explicit
human-approved gates.

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

Status: in progress. Page/navigation skeleton and backing structure are
live-built and read-back verified; the command-center homepage draft was
created and read-back verified on 2026-06-15. Stage 8A Relationship CRM is also
live-built and read-back verified. Stage 8B Relationship CRM operational
hardening is live-applied and read-back verified. Stage 8C Relationship CRM
operator workflow is live-applied and read-back verified. The Guided AI Labs
Operations Cockpit is now the live homepage, and Stage 8D adds a local-only
functional walkthrough packet and capture worksheets for browser/manual proof
before any CRM Teams tabs or additional automation are created. See
[M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md).
The live SharePoint shape should also follow the local Prime Operations-inspired
planning baseline in
[M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md).
Page refinement should follow the UAOS/Graphify/SharePoint boundary captured in
[M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md):
SharePoint is the governed business workspace, UAOS owns mission and approval
mechanics, and Graphify owns knowledge lookup and recommendations.
Local build-shape inputs are now captured in
[config/M365_STAGE_8_WORKSPACE_SHAPE.json](config/M365_STAGE_8_WORKSPACE_SHAPE.json)
and
[inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md).
The dry-run-first live page/navigation operator is
[scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1).
Latest read-back verification:
[inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md).
Backing-structure config and verification:
[config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json](config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json)
and
[inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md](inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md).
Homepage refinement is now consolidated into a draft-first command-center
packet:
[config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json),
[inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md),
and
[inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html](inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html).
The draft apply path creates `Guided-AI-Labs-Command-Center-Draft.aspx` only; it
does not replace the current homepage or change navigation/permissions/sharing.
The companion verifier read the draft page back and confirmed that it has not
become the current homepage.
Stage 8A Relationship CRM Spine is now consolidated into a Lists-first,
future-own-CRM-ready packet:
[M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md),
[config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json),
and
[inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md).
The apply path creates six CRM Lists, `Relationship-CRM.aspx`, CRM views, and a
Client Delivery navigation link only after the approval phrase
`apply-stage-8a-relationship-crm`. It does not create Dynamics, Dataverse,
permissions, sharing, guests, app grants, public Forms, mail sends, deletes, or
unattended automation.
Stage 8B Relationship CRM Operations adds the functional operating layer:
[M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md](M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md),
[config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json](config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json),
and
[inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md](inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md).
It is additive and approval-gated, adding lookup-backed relationships, due
dates, priority/health fields, filtered work queues, and
`Relationship-CRM-Operations.aspx`. Verification passed:
[inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md](inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md).
Stage 8C Relationship CRM Operator Workflow adds the practical working layer:
[M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md](M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md),
[config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json](config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json),
and
[inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md](inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md).
It is additive and approval-gated, adding CRM Action Queue, Qualification,
Meeting Notes, Artifacts, Health Reviews, filtered workflow views, and
`Relationship-CRM-Command-Center.aspx`. Verification passed:
[inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md](inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md).
Stage 8D Functional Workflow Walkthrough adds the local browser/manual proof
packet for the first real operating path:
[M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md](M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md),
[config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json](config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json),
and
[inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md](inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md).
The walkthrough capture worksheet and findings starter live in
[inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv](inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv)
and
[inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv](inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv).
It is local-only and does not connect to Microsoft 365.

### What we are doing

Turn Guided AI Labs' own setup into a repeatable client setup model, with the
internal SharePoint site shaped as the first command-center reference
implementation.

### Why

This becomes part of the consulting offer. Clients need to understand how M365 should be structured before AI can make it better.

### Main outputs

- client infrastructure discovery checklist
- client M365 readiness checklist
- client workspace template
- handoff/ownership model
- "what lives in the client tenant versus Guided AI Labs tenant" rule
- Guided AI Labs command-center pages and navigation created from the Stage 8
  workspace shape config
- Stage 8 client/handoff/governance Lists, document libraries, folders, and
  backing navigation created from the Stage 8 backing-structure config
- Guided AI Labs Command Center homepage refinement packet with six command
  cards, Active Work Snapshot, Client Pathway Snapshot, and Operational
  Readiness dashboard runway
- Stage 8A Relationship CRM packet with Organizations, Contacts, Engagements,
  Stakeholder Map, Touchpoints, Lifecycle Checklist, and a Relationship CRM
  routing page
- Stage 8B Relationship CRM operations packet with lookup fields, filtered
  queues, due dates, priority/health fields, and CRM Operations page
- Stage 8C Relationship CRM operator workflow packet with action queue,
  qualification, meeting notes, artifacts, health reviews, and CRM Command
  Center page
- Stage 8D functional walkthrough packet for proving
  `New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence`

### Done when

Guided AI Labs can explain and repeat:

```text
Here is where your records live.
Here is where your team collaborates.
Here is where your tasks and decisions live.
Here is how future AI safely connects.
Here is what you own when we leave.
```

## Stage 8A - Relationship CRM Spine

Status: live-built and read-back verified 2026-06-15.

### What we are doing

Add a lightweight relationship CRM inside the Guided AI Labs command center,
using Microsoft Lists as the current governed operating layer and preserving a
clean migration path to a future custom CRM.

### Why

Client delivery needs a relationship spine, not only an intake register or
workspace register. Adam and future staff need to see organizations, contacts,
engagement stage, offer package, onboarding, offboarding, touchpoints, and next
actions in one operating surface.

### Main outputs

- `CRM - Organizations`
- `CRM - Contacts`
- `CRM - Engagements`
- `CRM - Stakeholder Map`
- `CRM - Touchpoints`
- `CRM - Lifecycle Checklist`
- `Relationship-CRM.aspx` under the Client Delivery navigation group
- portable CRM migration hooks: `RecordKey`, `FutureCrmId`, `CentralOSLink`,
  and `GraphNodeId`

### Done when

The CRM Lists, fields, views, page, and navigation link are read-back verified,
and a harmless internal workflow can move:

```text
Intake -> organization/contact -> engagement -> touchpoint -> lifecycle checklist
```

No external guest, sharing, app grant, Forms, mail send, Dynamics, Dataverse, or
unattended automation is part of this stage.

## Stage 8B - Relationship CRM Operations

Status: live-applied and read-back verified 2026-06-15.

Stage 8B adds lookup-backed relationships, operational fields, due dates,
priority, health, filtered CRM queues, the CRM Operations page, and navigation.
See [M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md](M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md).

## Stage 8C - Relationship CRM Operator Workflow

Status: live-applied and read-back verified 2026-06-15.

Stage 8C adds the practical working layer for day-to-day CRM operation:
`CRM - Action Queue`, `CRM - Qualification`, `CRM - Meeting Notes`,
`CRM - Artifacts`, `CRM - Health Reviews`, lookup fields back to the CRM spine,
filtered workflow views, `Relationship-CRM-Command-Center.aspx`, and Client
Delivery navigation. See
[M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md](M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md).

No external guest, sharing, app grant, Forms, mail send, Dynamics, Dataverse,
deletion, or unattended automation is part of this stage.

## Stage 8D - Functional Workflow Walkthrough

Status: local-only packet generated and preflighted 2026-06-17.

Stage 8D proves the daily operating path after the Operations Cockpit and CRM
Command Center are live:

```text
New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence
```

It adds a generated walkthrough guide, workflow-step map, stop-gate map,
review-question map, capture worksheet, and findings register starter. It does
not connect to Microsoft 365 and does not perform tenant writes. Any manual
browser records created during the walkthrough must be internal dummy records
approved by Adam.

See
[M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md](M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md).

## Stage 9 - Agentic OS Bridge Readiness

Status: in progress; supervised coordinator/support List-write loops live-proven
2026-06-15, and bridge readiness control posture live-recorded/read-back
verified 2026-06-17.
See
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
- define first governed M365 Coordinator and M365 Support Agent capability lanes
  before creating app registrations or consenting new permissions
- record the first supervised G1/G2 List-write loops before granting standing
  app permissions
- generate the bridge readiness control packet before moving from delegated
  loops to any purpose-built app adapter
- record the bridge readiness posture in Decision Register and Agent Action Log
  before any app, consent, permission, mailbox, external/client, or unattended
  automation work

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

Current Stage 9 bridge control artifacts:

- [config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json](config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json)
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md)
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv)
- Decision Register item `#3` and Agent Action Log item `#5`: Stage 9 bridge
  readiness control posture recorded.

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
10. Stage 8A - Relationship CRM Spine
11. Stage 8B - Relationship CRM Operations
12. Stage 8C - Relationship CRM Operator Workflow
13. Stage 8D - Functional Workflow Walkthrough
14. Stage 9 - Agentic OS Bridge Readiness

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
