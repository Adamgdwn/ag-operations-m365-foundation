# Stage 8C Relationship CRM Operator Workflow Build Guide

Generated: 2026-06-15 14:28:20
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json`

Scope: local-only packet. This does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Title | Guided AI Labs |
| URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Purpose | Turns the Stage 8A/8B CRM structure into a working operator system with action queue, qualification, meeting notes, artifacts, health reviews, and a CRM command center. |

## Apply

Dry run:

```powershell
.\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1
```

Live apply in a visible approval window:

```powershell
.\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8c-crm-workflow
```

Read-only verification:

```powershell
.\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1
```

## Safety Limits

- No permission changes
- No guest invitations
- No external sharing changes
- No app grants or consent changes
- No public Forms links
- No mail sends
- No item or list deletions
- No unattended automation
- No Dynamics or Dataverse provisioning

## Operator Workflow Lists

| List | Purpose |
|---|---|
| CRM - Action Queue | Single CRM task queue for follow-ups, proposals, decisions, handoffs, delivery actions, and relationship work. |
| CRM - Qualification | Qualification and fit review records for incoming signals, prospects, and expansion opportunities. |
| CRM - Meeting Notes | Structured meeting prep, notes, debriefs, commitments, decisions, and next actions. |
| CRM - Artifacts | Evidence, proposals, scope documents, work products, handoff packets, and related CRM links. |
| CRM - Health Reviews | Periodic account and engagement health snapshots for risk, renewal, expansion, and relationship management. |

## Workflow Views

| List | View | Row limit |
|---|---|---|
| CRM - Action Queue | Open CRM Actions | 100 |
| CRM - Action Queue | Due / Overdue Actions | 100 |
| CRM - Action Queue | Decision / Go-Live Blockers | 100 |
| CRM - Action Queue | Completed Actions | 100 |
| CRM - Qualification | Qualification Triage | 100 |
| CRM - Qualification | Qualified / Proposal Recommended | 100 |
| CRM - Qualification | Nurture / Disqualified | 100 |
| CRM - Meeting Notes | Upcoming Meetings | 100 |
| CRM - Meeting Notes | Meeting Prep Needed | 100 |
| CRM - Meeting Notes | Meeting Debrief Needed | 100 |
| CRM - Meeting Notes | Meeting History | 100 |
| CRM - Artifacts | Active Artifacts | 100 |
| CRM - Artifacts | Proposal / Scope Artifacts | 100 |
| CRM - Artifacts | Handoff Evidence | 100 |
| CRM - Artifacts | Review Due | 100 |
| CRM - Health Reviews | Health Review Queue | 100 |
| CRM - Health Reviews | At Risk Health Reviews | 100 |
| CRM - Health Reviews | Expansion Signals | 100 |
| CRM - Health Reviews | Health Review History | 100 |

## Workflow Proof

- New signals are triaged in CRM - Qualification before becoming a committed engagement.
- Every promised action lives in CRM - Action Queue with an owner, status, priority, and due date.
- Meetings get prep and debrief records so commitments are not trapped in memory.
- Artifacts track proposals, scopes, evidence, and handoff materials without widening sharing.
- Health Reviews provide an explicit risk, renewal, and expansion rhythm for active relationships.

## Output Files

- List map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-list-map.csv`
- Field map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-field-map.csv`
- Lookup map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-lookup-map.csv`
- View map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-view-map.csv`
- Page map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-page-map.csv`
- Navigation map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8c-relationship-crm-operator-workflow\stage-8c-crm-workflow-navigation-map.csv`
