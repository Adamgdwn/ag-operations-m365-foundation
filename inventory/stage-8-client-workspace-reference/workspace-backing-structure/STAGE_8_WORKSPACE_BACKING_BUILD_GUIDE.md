# Stage 8 Workspace Backing Structure Build Guide

Generated: 2026-06-14 22:10:08
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json`

Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Title | Guided AI Labs |
| URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Purpose | Backing Lists, libraries, folders, and routing pages for the Stage 8 workspace shape. |

## Live Apply

Dry-run in a visible window:

```powershell
.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1
```

Apply after approval in the visible window:

```powershell
.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8-backing-structure
```

Read-only verification after apply:

```powershell
.\scripts\Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1
```

## Safety Limits

- No permission changes
- No guest invitations
- No external sharing changes
- No app grants or consent changes
- No public Forms links
- No page/list/library deletion
- No overwrite of existing pages

## Routing Pages

| Page | File | Navigation group | Role |
|---|---|---|---|
| Operating Model | Operating-Model.aspx | Start Here | Plain-language operating map for how intake, tasks, decisions, records, and AI-assisted work move through the company. |
| Client Discovery | Client-Discovery.aspx | Client Delivery | Front door for client readiness, workspace ownership, handoff planning, and tenant-of-record decisions. |
| Agent Setup | Agent-Setup.aspx | AI and Automation | Controlled setup notes for agents and assisted workflows before they are promoted into client or operating use. |
| Access Model | Access-Model.aspx | Governance | Simple access zones and approval rules for internal, partner, builder, reviewer, and client-specific surfaces. |
| External Sharing Rules | External-Sharing-Rules.aspx | Governance | Stage 7 sharing posture translated into day-to-day operating rules. |
| App Grants | App-Grants.aspx | Governance | Review surface for app grants, delegated permissions, risk notes, and owner-approved resting state. |

## Lists

| List | Columns | Views |
|---|---|---|
| Client Workspace Register | Workspace Model; Ownership Posture; Status; Primary Owner; Tenant Of Record; Access Posture; External Access Approved; Handoff State; Review Date; Workspace Map URL; Notes | Active Workspaces; Handoff Needed; Access Review |
| Handoff Packet Register | Client Or Workspace; Packet Status; Handoff Owner; Training State; Workspace Map URL; Packet Library URL; Closeout Export Path; Next Review Date; Notes | Active Handoffs; Ready For Review; Archived Packets |
| Tool Permission Review | Permission Area; Current Grant; Risk Level; Owner; Review Status; Review Date; Decision Register Link; Notes | Needs Review; High Risk |
| Automation Backlog | Workflow Area; Proposed Value; Risk Level; Approval Status; Owner; Source Surface; Target System; Human Approval Required; Review Date; Notes | Backlog; Needs Approval |
| Exception Register | Exception Area; Status; Approved By; Expiry Date; Review Date; Decision Register Link; Closure Path; Notes | Open Exceptions; Expiring Soon |

## Libraries

| Library | Folders |
|---|---|
| Published Methods | Templates; Playbooks; Training Paths; Reusable Assets |
| Delivery Working Documents | Active Delivery; Client Discovery; Working Notes |
| Restricted Build Evidence | Agent Setup; App Grants; Tool Permission Review; Integration Evidence |
| Client Handoff Packets | Drafts; Ready For Review; Issued |
| Readiness Evidence | Assessments; Scorecards; Reviews |
| Archive | Completed Work; Historical Evidence |

## Navigation Targets

| Group | Link | Kind | Target |
|---|---|---|---|
| Start Here | Operating Model | Page | Operating Model |
| Client Delivery | Client Discovery | Page | Client Discovery |
| Client Delivery | Handoff Packets | Library | Client Handoff Packets |
| Methods and IP | Templates | LibraryFolder | Published Methods/Templates |
| Methods and IP | Playbooks | LibraryFolder | Published Methods/Playbooks |
| Methods and IP | Training Paths | LibraryFolder | Published Methods/Training Paths |
| Methods and IP | Reusable Assets | LibraryFolder | Published Methods/Reusable Assets |
| AI and Automation | Agent Setup | Page | Agent Setup |
| AI and Automation | Automation Backlog | List | Automation Backlog |
| AI and Automation | Tool Permission Review | List | Tool Permission Review |
| Records and Evidence | Readiness Evidence | Library | Readiness Evidence |
| Governance | Access Model | Page | Access Model |
| Governance | External Sharing Rules | Page | External Sharing Rules |
| Governance | App Grants | Page | App Grants |
| Governance | Exceptions | List | Exception Register |
| Archive | Completed Work | LibraryFolder | Archive/Completed Work |
| Archive | Historical Evidence | LibraryFolder | Archive/Historical Evidence |

## Output Files

- Page map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-page-map.csv`
- List map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-list-map.csv`
- Library map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-library-map.csv`
- Navigation map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-navigation-map.csv`

