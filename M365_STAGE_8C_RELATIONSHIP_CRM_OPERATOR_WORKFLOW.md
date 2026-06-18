# Microsoft 365 Stage 8C - Relationship CRM Operator Workflow

> Superseded for active CRM operating guidance.
>
> This document is now historical/provenance for the Stage 8C packet path. Use
> `docs/START_HERE.md`, `docs/CRM_RECOVERY_PLAN.md`,
> `docs/CRM_ACCEPTANCE_TESTS.md`, and `docs/CRM_RUNBOOK.md` for the current
> employee-ready CRM path.

Status: **live-applied and read-back verified** (2026-06-15);
**frictionless command-center and intake refresh live-applied and verified**
(2026-06-17).

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
- `Relationship-CRM-Command-Center.aspx`, with a visible stage path from intake
  through handoff evidence and short action tiles for the daily CRM moves;
- a frictionless intake form layout for `Guided AI Labs - Intake Register`,
  keeping human intake fields up front and source/automation fields read-only;
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

The apply script now refreshes the existing command-center page text when the
page already exists, instead of leaving stale content unchanged. It also applies
the governed intake form layout. It still requires the typed approval phrase.

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

Stage 8D browser review on 2026-06-17 found that the live CRM Command Center
did not yet present an obvious CRM stage/pipeline path. The first production
refresh added the stage path, but Adam's follow-up browser review found a second
real friction point: the page still felt like a wall of text and the intake link
opened a raw SharePoint list form with source mailbox, source message id,
received date, owner, and other system fields in the first human path.

The Stage 8C config, packet generator, apply script, and verifier were updated
again. The approved production refresh applied and read-back verified:

```text
Intake -> Qualification -> Engagement Pipeline -> Decision / Proposal -> Active Delivery -> Handoff Evidence
```

It also applied the frictionless intake form:

```text
Quick intake: Intake summary, Person name, Email, Organization
Triage: Signal type, Priority, What should happen next?, Context / notes, Needs Adam review
System fields: kept on the record, hidden from new intake or read-only after creation
```

Local evidence:

```text
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-command-center-stage-path.csv
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-frictionless-intake-map.csv
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-110134.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-110545.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-112206.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-112546.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-104803.log
```

## Done Criteria

Stage 8C is done when:

- all five operator workflow lists exist;
- all workflow fields and lookup fields exist;
- all filtered operational views exist and have CAML filters/sorts;
- `Relationship-CRM-Command-Center.aspx` exists;
- the command-center page exposes the visible CRM stage path;
- the command-center page exposes short action tiles including `Add intake
  signal`;
- the intake form exposes the frictionless quick-intake sections and keeps
  system/source fields read-only;
- the `Client Delivery / CRM Command Center` navigation link exists;
- read-only verification writes a PASS summary to
  `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md`.
