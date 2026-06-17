# Microsoft 365 Stage 8B - Relationship CRM Operations Layer

Status: **live-applied and read-back verified** (2026-06-15).

Stage 8B hardens the Stage 8A Relationship CRM from a useful structure into a
day-to-day operating cockpit. It remains Lists-first and future-CRM-ready, but
adds the parts needed for real use: lookup-backed relationships, due dates,
priority, operational health, filtered work queues, indexes, and an operations
page.

## Scope

Stage 8B adds:

- lookup fields between Organizations, Contacts, Engagements, Stakeholders,
  Touchpoints, and Lifecycle Checklist records;
- daily work queue fields such as `NextActionDueDate`, `Priority`,
  `OperationalHealth`, `DecisionDueDate`, and `HandoffStatus`;
- filtered views for overdue work, pipeline, delivery control, follow-ups,
  stakeholder attention, and blockers;
- an operator page: `Relationship-CRM-Operations.aspx`;
- a `Client Delivery / CRM Operations` navigation link for the original Stage
  8B operator surface.

After Stage 8C, `CRM Command Center` is the single daily CRM door. The Stage 8B
operations page remains a reference surface; its old Quick Launch link is now
treated as superseded rather than required.

Stage 8B does not create permissions, invite guests, widen sharing, grant app
consent, publish public forms, send mail, delete items or lists, provision
Dynamics/Dataverse, or run unattended automation.

## Operational Reality

After Stage 8B is applied, the CRM becomes operational for a small team because
it has real queues:

- `CRM - Engagements / Daily CRM Queue`
- `CRM - Engagements / Pipeline by Stage`
- `CRM - Engagements / Delivery Control`
- `CRM - Engagements / Decision Deadlines`
- `CRM - Touchpoints / Follow-ups Due`
- `CRM - Lifecycle Checklist / Checklist Due`
- `CRM - Lifecycle Checklist / Go-Live / Offramp Blockers`
- `CRM - Stakeholder Map / Stakeholder Attention`
- `CRM - Organizations / Relationship Review Queue`
- `CRM - Contacts / Contact Follow-up Queue`

It is still not Dynamics. It does not automate email/calendar capture, enforce
perfect data hygiene, detect duplicates, or forecast revenue by itself. Its
value comes from disciplined use of the queues and from linking records with
SharePoint lookup fields once the parent rows exist.

## Files

- [config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json](config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json)
- [scripts/New-M365Stage8BRelationshipCrmOperationsPacket.ps1](scripts/New-M365Stage8BRelationshipCrmOperationsPacket.ps1)
- [scripts/Test-M365Stage8BLocalPreflight.ps1](scripts/Test-M365Stage8BLocalPreflight.ps1)
- [scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1](scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1)
- [scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1](scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1)
- [scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1](scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1)
- [scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1](scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1)

## Safe Sequence

Generate local packet:

```powershell
.\scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1
```

Run local preflight:

```powershell
.\scripts\Test-M365Stage8BLocalPreflight.ps1
```

Dry run:

```powershell
.\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1
```

Live apply after explicit approval:

```powershell
.\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8b-crm-operations
```

Read-only verification after apply:

```powershell
.\scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1
```

## Done Criteria

## Execution Evidence

Live apply completed on 2026-06-15:

```text
inventory/stage-8b-relationship-crm-operations/stage-8b-crm-operationalize-20260615-134054.log
```

Read-only verification passed:

```text
inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md
```

Verified with zero bad counts:

- operations page;
- lookup fields;
- operational fields;
- filtered operational views;
- navigation link, before Stage 8C superseded the daily CRM door.

## Done Criteria

Stage 8B is done when:

- all lookup fields exist;
- all operational fields exist;
- all operational views exist and have CAML filters/sorts;
- the `Relationship-CRM-Operations.aspx` page exists;
- the `Client Delivery / CRM Operations` navigation link exists or is marked
  superseded by the Stage 8C `CRM Command Center` daily door;
- read-only verification writes a PASS summary to
  `inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md`.
