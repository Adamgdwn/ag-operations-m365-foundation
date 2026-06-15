# Stage 8 Workspace Shape Build Guide

Generated: 2026-06-14 22:13:39
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8_WORKSPACE_SHAPE.json`

Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Title | Guided AI Labs |
| URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Purpose | AI-first operating command center and teachable client workspace reference pattern. |

## Operating Principle

```text
Pages route humans; Lists hold operating state; libraries hold files and evidence; permissions create safety; navigation creates usability.
```

## Build Order

1. Finish Stage 7 closeout gates: support MFA, app-grant resting-state decision, and root/legacy site sharing decision.
2. Approve the Stage 8 workspace shape before live page/navigation changes.
3. Create or update pages before changing navigation.
4. Add page-based navigation groups after target pages exist.
5. Add only the first-wave Lists needed for client workspace and handoff flow.
6. Create restricted governance/build areas before storing sensitive AI, automation, prompt, app-grant, or integration details.
7. Test one real workflow: intake -> triage -> Planner task -> decision -> handoff/readiness note.

## Automation

Local-only packet regeneration:

```powershell
.\scripts\New-M365Stage8WorkspaceShapePacket.ps1
```

Dry-run the live SharePoint page/navigation build in a visible window:

```powershell
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1
```

Apply after approval in the visible window:

```powershell
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8-workspace-shape
```

The apply operator creates missing modern pages and adds resolvable Quick Launch navigation links. It does not change permissions, invite guests, enable sharing, revoke app grants, publish public Forms, delete pages, overwrite existing pages, or create client-facing automation.

Read-only verification after apply:

```powershell
.\scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1
```

## Target Pages

| Page | File | Navigation group | Role | Source of truth |
|---|---|---|---|---|
| Guided AI Labs Home | Guided-AI-Labs-Home.aspx | Start Here | Compact operating cockpit. | Guided AI Labs - Intake Register; Decision Register; Agent Action Log; Guided AI Labs - Operating Plan |
| How To Use This Workspace | How-To-Use-This-Workspace.aspx | Start Here | Onboarding page for a business partner or trusted collaborator. | Decision Register; M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md |
| Intake | Intake.aspx | Operating Cockpit | Front door for opportunities, client discovery, support, feedback, and improvement requests. | Guided AI Labs - Intake Register; M365_FORMS_INTAKE_FEEDBACK_KIT.json |
| Active Delivery | Active-Delivery.aspx | Operating Cockpit | Current work in motion. | Guided AI Labs - Operating Plan; Guided AI Labs - Intake Register; Agent Action Log |
| Decisions | Decisions.aspx | Operating Cockpit | Durable memory for governance, client scope, delivery commitments, automation boundaries, and exceptions. | Decision Register |
| Client Workspace Pattern | Client-Workspace-Pattern.aspx | Client Delivery | Stage 8 reference page for how Guided AI Labs structures client work. | M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md; Client Workspace Register; Handoff Packet Register |
| Methods And IP | Methods-And-IP.aspx | Methods and IP | Reusable delivery knowledge without mixing it into client-owned records. | Published Methods; Templates and Standards |
| AI And Automation Governance | AI-And-Automation-Governance.aspx | AI and Automation | Controlled surface for agents, automations, tool permissions, app grants, and human approval rules. | Tool Permission Review; Automation Backlog; Exception Register; Agent Action Log |

## Navigation Groups

| Group | Links |
|---|---|
| Start Here | Home; How To Use This Workspace; Operating Model |
| Operating Cockpit | Intake; Active Delivery; Decisions; Action Log |
| Client Delivery | Client Discovery; Client Workspace Pattern; Handoff Packets |
| Methods and IP | Templates; Playbooks; Training Paths; Reusable Assets |
| AI and Automation | Agent Setup; Automation Backlog; Tool Permission Review |
| Records and Evidence | Decision Register; Agent Action Log; Readiness Evidence |
| Governance | Access Model; External Sharing Rules; App Grants; Exceptions |
| Archive | Completed Work; Historical Evidence |

## Next Lists

| List | Purpose | Stage |
|---|---|---|
| Client Workspace Register | Client/partner workspace model, tenant ownership, status, access posture, and handoff state. | Stage 8 first wave |
| Handoff Packet Register | Workspace handoff owner, links, training state, closeout/export path, and next review date. | Stage 8 first wave |
| Tool Permission Review | App grants, agent scopes, risky permissions, workflow owner, and review cadence. | Stage 8 second wave after governance permissions are confirmed |
| Automation Backlog | Proposed automations before build/use approval. | Stage 8 second wave |
| Exception Register | Approved deviations with owner, expiry, review date, and closure path. | Stage 8 second wave |

## Library Roles

| Library / role | Purpose | Visibility |
|---|---|---|
| Published Methods | Approved templates, playbooks, training aids, and public-safe examples. | Broad internal read, controlled edit |
| Delivery Working Documents | Active internal delivery files and supporting material. | Members/contributors |
| Restricted Build Evidence | App, agent, automation specs, sensitive evidence, prompt/integration risk notes. | Restricted builders/governance reviewers |
| Client Handoff Packets | Handoff-ready exports, guides, ownership notes, and review packets. | Client/partner-specific |
| Archive | Closed and historical material. | Controlled |

## Live Change Gates

- Navigation/page rewrites
- Permission changes
- New external sharing
- Partner/client guest invitation
- Public or anonymous Forms links
- App grant changes
- Client-facing automation
- Storing sensitive AI/automation details in broadly readable areas

## Output Files

- Page map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-page-map.csv`
- Navigation map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-navigation-map.csv`
- Next list map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-next-list-map.csv`
- Library role map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-library-role-map.csv`

