# Microsoft 365 Stage 8A - Relationship CRM Spine

> Superseded for active CRM operating guidance.
>
> This document is now historical/provenance for the Stage 8A build. Use
> `docs/START_HERE.md`, `docs/CRM_RECOVERY_PLAN.md`, `docs/CRM_DATA_MODEL.md`,
> and `docs/CRM_RUNBOOK.md` for the current employee-ready CRM path.

Status: **live-built and read-back verified** (2026-06-15).

Stage 8A adds a Lists-first relationship CRM spine inside the Guided AI Labs
command center. It is intentionally not Dynamics, Dataverse, or the eventual
custom CRM. It is the governed operating layer that lets Adam and future staff
track organizations, people, engagements, onboarding, offboarding, touchpoints,
and next actions while the future custom CRM is still being designed.

Related:

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
- [M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md)
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)
- [config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json)

---

## 1. Goal

Build a practical relationship cockpit that answers:

```text
Who are we talking to?
What organization or partner are they connected to?
What engagement are they in right now?
What package did they enter through?
What package are they aiming for?
Where should they offramp?
What is the next action?
What onboarding or offboarding evidence is still missing?
```

The CRM is a relationship and engagement spine, not just a sales tracker.

---

## 2. Operating Principle

The first CRM lives in Microsoft Lists because it is:

- available inside the current Microsoft 365 Business Standard foundation;
- readable and writable through the existing governed M365 patterns;
- easy for Adam and future staff to use through SharePoint and Teams;
- simple to export or migrate into a future custom CRM.

The design keeps migration hooks on every List:

```text
RecordKey
FutureCrmId
CentralOSLink
GraphNodeId
```

These fields let M365 act as a governed operating layer now and a staging or
sync surface later.

---

## 3. CRM Surfaces

Stage 8A creates six Guided AI Labs Lists:

| List | Purpose |
|---|---|
| `CRM - Organizations` | Companies, partners, clients, prospects, schools, municipalities, nonprofits, internal entities, vendors, and other relationship containers. |
| `CRM - Contacts` | Individual stakeholders and people. |
| `CRM - Engagements` | Central work/relationship record. This is the main CRM object. |
| `CRM - Stakeholder Map` | Contact-to-engagement roles, influence, engagement level, and decision role. |
| `CRM - Touchpoints` | Calls, emails, meetings, notes, follow-ups, and relationship history. |
| `CRM - Lifecycle Checklist` | Onboarding, delivery, handoff, offboarding, and closeout checklist items. |

Primary UI:

```text
SharePoint Relationship CRM page -> direct List/view links -> Teams tabs later
```

Teams tabs are deferred until the SharePoint page and Lists are live-verified.

---

## 4. Engagement Path

The engagement record carries the business path:

```text
EntryPackage
CurrentPackage
TargetPackage
PlannedOfframpPackage
EngagementStage
ExecutionStage
SuccessCriteria
OffboardingRequirements
```

Offer-package choices:

- Relationship Nurture
- Readiness Snapshot
- Operating Blueprint
- Workspace Build
- Guided Implementation
- Operating Support
- AI OS Integration
- Handoff / Alumni

Engagement stages:

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

Execution stages:

- Not Started
- Mobilizing
- Building
- Validating
- Training
- Closeout
- Complete
- Blocked

---

## 5. Workflow Rules

First workflow:

```text
Intake Register row
-> Organization
-> Contact
-> Engagement
-> Touchpoint
-> Lifecycle Checklist
-> Planner task if action-bearing
-> Agent Action Log evidence
-> Decision Register only if scope/governance/commercial decision is made
```

Onboarding:

```text
EngagementStage = Onboarding
EntryPackage selected
TargetPackage selected
Lifecycle Checklist creates onboarding items
Owner and due dates assigned
Evidence links added
Engagement moves to Active Delivery only when blockers are cleared
```

Offboarding:

```text
PlannedOfframpPackage confirmed
OffboardingRequirements completed
Handoff Packet Register linked if applicable
Access/review decision recorded if needed
EngagementStage moves to Offboarding
Then Alumni / Archived after evidence and next-review date are recorded
```

---

## 6. Agent Posture

The M365 Coordinator may:

- read CRM Lists at `G0`;
- suggest Agent Action Log rows at `G1`;
- create or update internal CRM rows only at `G2` after approval.

Still gated or blocked:

- external sends;
- guest access;
- sharing or permission changes;
- app grants;
- public Forms;
- client-impacting commitments;
- unattended automation.

The CRM build layer does not create app registrations, Dynamics, Dataverse,
Power Automate flows, guests, sharing links, or mail sends.

---

## 7. Build And Verification

Live execution completed on 2026-06-15:

- apply log:
  `inventory/stage-8a-relationship-crm/stage-8a-relationship-crm-build-20260615-130604.log`
- verification summary:
  `inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md`
- result: PASS

Created and verified:

- six CRM Lists;
- required fields and views;
- `Relationship-CRM.aspx`;
- `Client Delivery / Relationship CRM` navigation link.

Teams tabs remain deferred until browser review confirms the SharePoint CRM page
is usable.

Local packet:

```powershell
.\scripts\New-M365Stage8ARelationshipCrmPacket.ps1
.\scripts\Test-M365Stage8ALocalPreflight.ps1
```

Dry-run build:

```powershell
.\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1
```

Apply only after review:

```powershell
.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8a-relationship-crm
```

Read-only verification:

```powershell
.\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1
```

Stage 8A is done when all six CRM Lists, the Relationship CRM page, required
views, and navigation link are read-back verified, and a harmless internal
workflow can move from intake to engagement to onboarding/offboarding evidence.
