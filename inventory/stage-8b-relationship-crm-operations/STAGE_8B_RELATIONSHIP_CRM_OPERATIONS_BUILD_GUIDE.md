# Stage 8B Relationship CRM Operations Build Guide

Generated: 2026-06-17 09:14:42
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json`

Scope: local-only packet. This does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Title | Guided AI Labs |
| URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Purpose | Operational hardening for the Stage 8A Relationship CRM: lookup-backed relationships, daily queues, due dates, risk views, and an operations cockpit. |

## Apply

Dry run:

```powershell
.\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1
```

Live apply in a visible approval window:

```powershell
.\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8b-crm-operations
```

Read-only verification:

```powershell
.\scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1
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

## Lookup Fields

| List | Field | Target |
|---|---|---|
| CRM - Contacts | Organization (OrganizationLookup) | CRM - Organizations / Title |
| CRM - Engagements | Organization (OrganizationLookup) | CRM - Organizations / Title |
| CRM - Engagements | Primary Contact (PrimaryContactLookup) | CRM - Contacts / Title |
| CRM - Stakeholder Map | Engagement (EngagementLookup) | CRM - Engagements / Title |
| CRM - Stakeholder Map | Contact (ContactLookup) | CRM - Contacts / Title |
| CRM - Touchpoints | Engagement (EngagementLookup) | CRM - Engagements / Title |
| CRM - Touchpoints | Contact (ContactLookup) | CRM - Contacts / Title |
| CRM - Lifecycle Checklist | Engagement (EngagementLookup) | CRM - Engagements / Title |

## Operational Views

| List | View | Row limit |
|---|---|---|
| CRM - Organizations | Relationship Review Queue | 100 |
| CRM - Organizations | Strategic Relationships | 100 |
| CRM - Contacts | Contact Follow-up Queue | 100 |
| CRM - Contacts | Key People | 100 |
| CRM - Engagements | Daily CRM Queue | 100 |
| CRM - Engagements | Pipeline by Stage | 100 |
| CRM - Engagements | Delivery Control | 100 |
| CRM - Engagements | Decision Deadlines | 100 |
| CRM - Stakeholder Map | Stakeholder Attention | 100 |
| CRM - Touchpoints | Follow-ups Due | 100 |
| CRM - Touchpoints | Relationship History | 100 |
| CRM - Lifecycle Checklist | Go-Live / Offramp Blockers | 100 |
| CRM - Lifecycle Checklist | Checklist Due | 100 |

## Workflow Proof

- Create Organization and Contact records, then set lookup fields when records exist.
- Create one Engagement with Organization and Primary Contact lookups, stage, package, owner, priority, health, due date, and next action.
- Capture each meaningful call/email/meeting as a Touchpoint with follow-up due date when needed.
- Use Daily CRM Queue every working day; use Follow-ups Due and Checklist Due as the work queue.
- Use Stakeholder Attention and Go-Live / Offramp Blockers before client meetings and handoffs.

## Output Files

- Operational field map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8b-relationship-crm-operations\stage-8b-crm-operational-field-map.csv`
- Lookup field map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8b-relationship-crm-operations\stage-8b-crm-lookup-field-map.csv`
- Operational view map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8b-relationship-crm-operations\stage-8b-crm-operational-view-map.csv`
- Page map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8b-relationship-crm-operations\stage-8b-crm-operational-page-map.csv`
- Navigation map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8b-relationship-crm-operations\stage-8b-crm-operational-navigation-map.csv`
