# Cockpit Usability Inventory

Date: 2026-06-18

Status: Chunk 2 local evidence output.

Scope: Guided AI Labs Operations Cockpit page, embedded queues, page links, and
known navigation evidence. This inventory used local evidence only and did not
read from or write to the live tenant during Chunk 2.

## Evidence Used

- `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
- `inventory/gail-sharepoint-portal/gail-operations-portal-20260617-144536.log`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1`
- `docs/START_HERE.md`
- `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/stage-8-backing-navigation-20260614-221014.csv`

## Read Method

The current cockpit was inspected from its generating script and latest local
evidence. The script shows the cockpit page content, card targets, secondary
links, and embedded list-view web parts. The latest evidence confirms the page
was refreshed and set as the homepage on 2026-06-17.

No live SharePoint read was required for this chunk because the acceptance gate
only requires categorizing the current visible surface, and the local evidence
contains the current cockpit shape.

## Page Summary

| Surface | Evidence status | Category | Notes |
|---|---|---|---|
| Guided AI Labs Operations Cockpit | Refreshed and set as homepage | Active | Daily front door for the Guided AI Labs workspace. |
| Start Here / Operations Portal navigation | Added during portal refresh | Active | Points users to the cockpit. |
| Start Here / Login Guide navigation | Added if missing by portal script | Active | Supports onboarding and account selection. |
| Relationship CRM quick navigation | Removed from daily navigation | Superseded | Remains reference material, not a daily operator path. |
| CRM Operations quick navigation | Removed from daily navigation | Superseded | Remains reference material, not a daily operator path. |
| Recent quick navigation | Removed from daily navigation | Superseded | Removed to reduce noise. |

## Top Cockpit Cards

| Visible card | Primary target | Category | Operating-card mapping | Notes |
|---|---|---|---|---|
| CRM | `Relationship-CRM-Command-Center.aspx` | Active | CRM / Relationships | Correct daily CRM door. CRM recovery continues under `docs/CRM_EXECUTION_PLAN.md`. |
| Operations | `Intake.aspx` | Needs cleanup | Support / Intake; Decisions / Governance; Tasks / Actions | Label is broad. It currently points to intake but also signals decisions, agent review, and active delivery. |
| Tools | `Tool Permission Review/Needs Review.aspx` | Admin-only / controlled | Agent Control Plane; Access / Onboarding | Useful governance card, but tool permissions, app grants, and agent setup need role boundaries. |
| Projects In Flight | `Active-Delivery.aspx` | Active | Delivery / Projects; Finance / Closeout | Good delivery entry point, but needs a card plan and closeout/invoice routing. |

## Top Card Signals

| Card | Visible signal | Category | Notes |
|---|---|---|---|
| CRM | Open CRM actions | Active | Backed by `CRM - Action Queue / Open CRM Actions`. |
| CRM | Qualification triage | Active | Backed by `CRM - Qualification / Qualification Triage`. |
| CRM | Meetings and debriefs | Active | CRM-facing purpose is clear, but acceptance remains in CRM chunks. |
| CRM | Health reviews and risk | Active | Belongs to CRM / Relationships. |
| Operations | Attention-now intake | Active | Backed by `Guided AI Labs - Intake Register / Attention Now`. |
| Operations | Agent action review | Needs cleanup | Appears under Operations but also belongs to Agent Control Plane. |
| Operations | Recent decisions | Needs cleanup | Should route clearly to Decisions / Governance. |
| Operations | Active delivery flow | Needs cleanup | Duplicates Projects In Flight / Delivery. |
| Tools | Tool permission review | Admin-only / controlled | Governance-sensitive; not a general operator link without role notes. |
| Tools | App grants governance | Admin-only / controlled | Must remain governance surface, not an agent connection. |
| Tools | Automation backlog | Controlled | Planning surface before automation build or production use. |
| Tools | Agent setup | Future / controlled | Needs readiness and approval context before daily use. |
| Projects In Flight | Delivery control | Active | Delivery / Projects entry point. |
| Projects In Flight | Lifecycle checklist | Active | Supports delivery and handoff readiness. |
| Projects In Flight | Handoff packets | Active | Supports closeout and partner/client handoff. |
| Projects In Flight | Client discovery | Needs cleanup | Discovery is partly intake/support and partly delivery; needs card ownership. |

## Embedded Queues

| Embedded queue | List | View | Category | Notes |
|---|---|---|---|---|
| CRM - Action Queue / Open CRM Actions | CRM - Action Queue | Open CRM Actions | Active | Daily work queue for CRM follow-ups and tasks. |
| CRM - Qualification / Qualification Triage | CRM - Qualification | Qualification Triage | Active | Daily queue for qualifying signals and opportunities. |
| Guided AI Labs - Intake Register / Attention Now | Guided AI Labs - Intake Register | Attention Now | Active | Workspace intake queue; not the preferred clean CRM new-signal form. |
| Agent Action Log / Needs Review | Agent Action Log | Needs Review | Active | Review queue for AI/agent suggestions and assisted actions. |

## Cockpit Page Link Groups

### CRM And Customer Flow

| Visible link | Target | Category | Operating-card mapping | Notes |
|---|---|---|---|---|
| CRM Command Center | `Relationship-CRM-Command-Center.aspx` | Active | CRM / Relationships | Single daily CRM door. |
| Delivery Control | `CRM - Engagements/Delivery Control.aspx` | Active | Delivery / Projects; CRM / Relationships | Crosses CRM and delivery. Needs ownership split in card deep dives. |
| Open Lifecycle Checklist | `CRM - Lifecycle Checklist/Open Checklist.aspx` | Active | Delivery / Projects; Finance / Closeout | Useful delivery/handoff work queue. |
| Client Discovery | `Client-Discovery.aspx` | Active | Support / Intake; Delivery / Projects | Needs a card plan and owner before being called done. |
| Handoff Packets | `Client Handoff Packets` | Active | Finance / Closeout; Knowledge / Records | Backing library exists. Needs closeout runbook. |
| Decision Register | `Decision Register/Recent Decisions.aspx` | Active | Decisions / Governance | Correct governance surface. |

### Operations And Tools

| Visible link | Target | Category | Operating-card mapping | Notes |
|---|---|---|---|---|
| Agent Action Log | `Agent Action Log/Needs Review.aspx` | Active | Agent Control Plane | Correct review surface for AI/agent action evidence. |
| Automation Backlog | `Automation Backlog/Backlog.aspx` | Controlled | Agent Control Plane | Should remain pre-build/pre-approval backlog, not execution authority. |
| Tool Permission Review | `Tool Permission Review/Needs Review.aspx` | Admin-only / controlled | Agent Control Plane; Access / Onboarding | Needs role and approval boundaries. |
| App Grants | `App-Grants.aspx` | Admin-only / controlled | Decisions / Governance; Agent Control Plane | Governance surface only; not a live Funding & Benefits agent connection. |
| Agent Setup | `Agent-Setup.aspx` | Future / controlled | Agent Control Plane | Needs readiness standards before daily operator use. |
| Login Guide | `Login-And-Account-Guide.aspx` | Active | Access / Onboarding | Correct first-day support link. |

## Broader Navigation Evidence

Stage 8 backing evidence shows these navigation surfaces exist and are present:

| Group | Visible link | Category | Notes |
|---|---|---|---|
| Start Here | Operating Model | Active | Useful workspace orientation. |
| Client Delivery | Client Discovery | Active | Also exposed from cockpit page links. |
| Client Delivery | Handoff Packets | Active | Also exposed from cockpit page links. |
| Methods and IP | Templates | Future / needs card plan | Backing folder exists, but Knowledge / Records card still needs runbook. |
| Methods and IP | Playbooks | Future / needs card plan | Backing folder exists, but Knowledge / Records card still needs runbook. |
| Methods and IP | Training Paths | Future / needs card plan | Backing folder exists, but Knowledge / Records card still needs runbook. |
| Methods and IP | Reusable Assets | Future / needs card plan | Backing folder exists, but Knowledge / Records card still needs runbook. |
| AI and Automation | Agent Setup | Future / controlled | Same caution as cockpit link. |
| AI and Automation | Automation Backlog | Controlled | Same caution as cockpit link. |
| AI and Automation | Tool Permission Review | Admin-only / controlled | Same caution as cockpit link. |
| Records and Evidence | Readiness Evidence | Active | Backing library exists. Needs Knowledge / Records runbook. |
| Governance | Access Model | Active | Needs Access / Onboarding card plan. |
| Governance | External Sharing Rules | Admin-only / controlled | Should remain governed, not casual operator work. |
| Governance | App Grants | Admin-only / controlled | Same caution as cockpit link. |
| Governance | Exceptions | Active | Belongs to Decisions / Governance. |
| Archive | Completed Work | Future / controlled | Backing folder exists; needs archive rule. |
| Archive | Historical Evidence | Future / controlled | Backing folder exists; needs archive rule. |

## Categorization Result

The Chunk 2 acceptance gate is met from local evidence:

- every visible top card is categorized;
- every embedded queue is categorized;
- every cockpit page link is categorized;
- known broader navigation links are categorized;
- superseded CRM navigation is identified;
- admin-only/controlled surfaces are separated from normal operating links.

The follow-on cleanup and card-planning work is captured in
`docs/COCKPIT_CARD_GAP_LIST.md`.
