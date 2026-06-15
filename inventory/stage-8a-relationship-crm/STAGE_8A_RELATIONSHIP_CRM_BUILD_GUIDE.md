# Stage 8A Relationship CRM Build Guide

Generated: 2026-06-15 13:02:56
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8A_RELATIONSHIP_CRM.json`

Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Title | Guided AI Labs |
| URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Purpose | Lists-first, future-own-CRM-ready relationship cockpit for organizations, contacts, engagements, touchpoints, onboarding, and offboarding. |

## Live Apply

Dry-run:

```powershell
.\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1
```

Apply after approval in a visible window:

```powershell
.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8a-relationship-crm
```

Read-only verification after apply:

```powershell
.\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1
```

## Safety Limits

- No permission changes
- No guest invitations
- No external sharing changes
- No app grants or consent changes
- No public Forms links
- No mail sends
- No deletions
- No unattended automation
- No Dynamics or Dataverse provisioning

## CRM Lists

| List | Purpose | Views |
|---|---|---|
| CRM - Organizations | One row per company, partner, client, prospect, school, municipality, nonprofit, or internal operating entity. | Active Organizations; Prospects / Signals; Partners / Clients; Archived |
| CRM - Contacts | One row per person or stakeholder, linked by portable keys to organization and engagement records. | Active Contacts; Waiting on Adam; By Organization; Do Not Contact / Archived |
| CRM - Engagements | Central relationship/work record; one row per meaningful engagement, offer path, onboarding, delivery, support, or offramp. | Active Engagements; New / Discovery; Waiting on Adam; At Risk; Offboarding / Alumni |
| CRM - Stakeholder Map | Connects contacts to engagements with role, influence, engagement level, and decision responsibility. | Active Stakeholders; Decision Makers; Needs Attention |
| CRM - Touchpoints | Calls, emails, meetings, notes, follow-ups, and relationship history. | Recent Touchpoints; Follow Up Required; By Engagement |
| CRM - Lifecycle Checklist | Onboarding, delivery, offboarding, handoff, and closeout checklist items. | Open Checklist; Onboarding Checklist; Offboarding Checklist; Blocked / Waiting; Completed |

## Page

| Page | File | Navigation group | Role |
|---|---|---|---|
| Relationship CRM | Relationship-CRM.aspx | Client Delivery | Operator-facing CRM cockpit for relationship stage, current engagement, onboarding/offboarding, and next touchpoint visibility. |

## Offer Packages

- Relationship Nurture
- Readiness Snapshot
- Operating Blueprint
- Workspace Build
- Guided Implementation
- Operating Support
- AI OS Integration
- Handoff / Alumni

## Engagement Stages

- Signal
- Discovery
- Qualified Fit
- Proposal / Scope
- Onboarding
- Active Delivery
- Sustainment
- Expansion / Renewal
- Offboarding
- Alumni / Archived
- Paused / Lost

## Workflows

| Workflow | Steps |
|---|---|
| Convert Intake Into CRM | Intake Register row -> Organization -> Contact -> Engagement -> Touchpoint -> Lifecycle Checklist -> Planner task if action-bearing -> Agent Action Log evidence -> Decision Register only for scope/governance/commercial decisions |
| Onboarding | Set EngagementStage to Onboarding -> Select EntryPackage and TargetPackage -> Create Lifecycle Checklist items -> Assign owner and due dates -> Add evidence links -> Move to Active Delivery only when blockers clear |
| Offboarding | Confirm PlannedOfframpPackage -> Complete OffboardingRequirements -> Link Handoff Packet Register if applicable -> Record access/review decision if needed -> Move EngagementStage to Offboarding -> Archive as Alumni / Archived after evidence and next-review date |

## Teams Tabs Later

Do not create these until SharePoint CRM verification passes.

| Channel | Tab | Target |
|---|---|---|
| Client Discovery | Relationship CRM | Relationship CRM page |
| Client Discovery | CRM - Engagements | CRM - Engagements list |
| Active Delivery | Active Engagements | CRM - Engagements / Active Engagements view |
| Active Delivery | Lifecycle Checklist | CRM - Lifecycle Checklist list |

## Agent Permission Notes

- M365 Coordinator may read CRM Lists at G0.
- M365 Coordinator may suggest Agent Action Log rows at G1.
- M365 Coordinator may create/update internal CRM rows only at G2 after approval.
- External sends, guest access, sharing, permission changes, app grants, public Forms, and client-impacting commitments remain G3/G4 approval-gated or blocked.

## Output Files

- Page map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-page-map.csv`
- List map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-list-map.csv`
- Field map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-field-map.csv`
- View map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-view-map.csv`
- Navigation map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-navigation-map.csv`
- Workflow map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-workflow-map.csv`
- Teams tabs later map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-teams-tab-later-map.csv`
