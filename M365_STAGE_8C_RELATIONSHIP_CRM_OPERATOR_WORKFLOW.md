# Microsoft 365 Stage 8C - Relationship CRM Operator Workflow

Status: **live-applied and read-back verified** (2026-06-15).

Stage 8C takes the verified Stage 8A/8B CRM and adds the operator-facing
workflow pieces needed for real daily use. Stage 8A created the CRM spine.
Stage 8B added lookup-backed relationships and operational queues. Stage 8C
adds the working surfaces: actions, qualification, meeting notes, artifacts,
health reviews, and a command-center page.

## Scope

Stage 8C adds:

- `CRM - Action Queue`
- `CRM - Qualification`
- `CRM - Meeting Notes`
- `CRM - Artifacts`
- `CRM - Health Reviews`
- lookup fields from those lists back to organizations, contacts, engagements,
  and touchpoints;
- filtered views for open actions, overdue work, qualification triage, meeting
  prep/debrief, proposal/scope evidence, handoff evidence, health reviews, risk,
  and expansion signals;
- `Relationship-CRM-Command-Center.aspx`;
- `Client Delivery / CRM Command Center` navigation.

Stage 8C does not create permissions, invite guests, widen sharing, grant app
consent, publish public Forms, send mail, delete items or lists, provision
Dynamics/Dataverse, or run unattended automation.

## Files

- [config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json](config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json)
- [scripts/New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1](scripts/New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1)
- [scripts/Test-M365Stage8CLocalPreflight.ps1](scripts/Test-M365Stage8CLocalPreflight.ps1)
- [scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1](scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1)
- [scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1](scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1)
- [scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1](scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1)
- [scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1](scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1)

## Safe Sequence

Generate local packet:

```powershell
.\scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1
```

Run local preflight:

```powershell
.\scripts\Test-M365Stage8CLocalPreflight.ps1
```

Dry run:

```powershell
.\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1
```

Live apply after explicit approval:

```powershell
.\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8c-crm-workflow
```

Read-only verification after apply:

```powershell
.\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1
```

## Execution Evidence

Live apply completed on 2026-06-15:

```text
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260615-142931.log
```

Read-only verification passed:

```text
inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md
```

Verified with zero bad counts:

- lists;
- workflow fields;
- lookup fields;
- filtered views;
- command-center page;
- navigation link.

## Done Criteria

Stage 8C is done when:

- all five operator workflow lists exist;
- all workflow fields and lookup fields exist;
- all filtered operational views exist and have CAML filters/sorts;
- `Relationship-CRM-Command-Center.aspx` exists;
- the `Client Delivery / CRM Command Center` navigation link exists;
- read-only verification writes a PASS summary to
  `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md`.
