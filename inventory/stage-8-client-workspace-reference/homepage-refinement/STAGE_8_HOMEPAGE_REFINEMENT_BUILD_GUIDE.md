# Stage 8 Homepage Refinement Build Guide

Generated: 2026-06-14 23:36:09
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8_HOMEPAGE_REFINEMENT.json`

Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.

## Decision Summary

Homepage title: **Guided AI Labs Command Center**

Purpose: AI-first company command center with operating cockpit access immediately visible.

Label style: Plain operational labels

Routing default: Pages first, with direct List, Planner, library, or evidence links near the top of each page.

Card mode: Text-only first; dashboard counts later after source records are stable.

Operational Readiness placement: Homepage band first; dedicated page later only if real use justifies it.

## Homepage Layout

- Compact AI-first command header
- Six command cards
- Active Work Snapshot
- Client Pathway Snapshot
- Light governance / automation safety signal
- Methods, IP, and evidence shortcuts

## Command Cards

| Card | Status line | Page target | Future sources |
|---|---|---|---|
| New Intake | Open items, new requests, and discovery starts. | Intake (Intake.aspx) | Guided AI Labs - Intake Register; Forms intake kit |
| Active Delivery | Work in motion across clients, builds, and operations. | Active Delivery (Active-Delivery.aspx) | Guided AI Labs - Operating Plan; Delivery Working Documents |
| Decisions Needed | Scope, access, governance, and delivery choices to clear. | Decisions (Decisions.aspx) | Decision Register; Exception Register |
| Client Readiness | Discovery, assessments, workspace models, and next reviews. | Client Discovery (Client-Discovery.aspx) | Client Workspace Register; Readiness Evidence |
| Automation And Agents | Proposed automations, agent setup, and tool permission reviews. | AI And Automation Governance (AI-And-Automation-Governance.aspx) | Automation Backlog; Tool Permission Review; Agent Action Log |
| Handoffs And Evidence | Handoff packets, readiness evidence, and closeout records. | Client Workspace Pattern (Client-Workspace-Pattern.aspx) | Handoff Packet Register; Client Handoff Packets; Readiness Evidence |

## Active Work Snapshot

| Column | Purpose |
|---|---|
| Now Moving | Active delivery, internal build, client discovery, or operating work in motion. |
| Waiting On Adam | Approvals, reviews, access, decisions, or clarifications that need Adam. |
| Blocked / At Risk | Stuck work, unresolved governance, permission gaps, stale handoffs, or risks. |
| Next Best Actions | The few actions that keep momentum without opening a new branch of work. |

## Client Pathway Snapshot

```text
Discover -> Assess -> Design Workspace -> Deliver -> Handoff
```

| Stage | Toolset direction |
|---|---|
| Discover | Intake form, discovery checklist, stakeholder/context capture, initial fit notes. |
| Assess | Readiness worksheet, evidence prompts, governance/access review, risk and opportunity summary. |
| Design Workspace | Workspace model decision, tenant/client ownership map, access model, minimum surface plan. |
| Deliver | Active delivery plan, tasks, decisions, working docs, automation/tool review. |
| Handoff | Handoff packet, training path, ownership notes, review date, archive/export plan. |

## Operational Readiness Dashboard Runway

Operations and readiness are combined. Internal clients and external clients both move through the same operating cockpit.

| Phase | Shape | Source candidates |
|---|---|---|
| Phase 1 | Text-only cards and static bands | SharePoint pages and navigation |
| Phase 2 | Manual snapshot fields | List views, Planner buckets, Decision Register, Handoff Packet Register |
| Phase 3 | Filtered SharePoint/List views embedded on pages | Microsoft Lists views, Planner, document libraries |
| Phase 4 | Power BI or Microsoft Graph-backed dashboard | Cross-list metrics, delivery cycle, readiness score, automation review aging |
| Phase 5 | UAOS/Graphify bridge dashboard | Reviewed summaries, graph handoffs, mission status, evidence references |

Potential future metrics:

- Open intake items
- Active delivery items
- Decisions waiting
- Internal and external client readiness reviews due
- Automations awaiting review
- Handoff packets ready or overdue
- Permission reviews due
- Exceptions expiring

## Live Apply Path

The live operator is intentionally draft-first. It creates a review page only:

`Guided-AI-Labs-Command-Center-Draft.aspx`

It does not replace the current homepage, change navigation, change permissions, invite guests, widen sharing, grant apps, publish public Forms links, or create automation.

Dry run:

```powershell
.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1
```

Visible apply window:

```powershell
.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply
```

Approval phrase:

```text
create-stage-8-command-center-draft
```

Read-only verification after draft creation:

```powershell
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

## Safety Limits

- No replacement of the current homepage
- No page deletion
- No permission changes
- No guest invitations
- No external sharing changes
- No app grants or consent changes
- No public Forms links
- No client-facing automation

## Output Files

- Command cards CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-command-cards.csv
- Active work CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-active-work-snapshot.csv
- Client pathway CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-client-pathway.csv
- Dashboard runway CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-operational-readiness-dashboard-runway.csv
- HTML preview: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-command-center-preview.html

