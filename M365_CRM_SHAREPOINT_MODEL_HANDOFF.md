# M365 CRM SharePoint Model Handoff

> Superseded for active CRM recovery direction.
>
> This handoff captured the problem state that led to recovery. The active path
> is now `START_HERE.md`, `docs/CRM_RECOVERY_PLAN.md`,
> `docs/CRM_UX_SPEC.md`, `docs/CRM_RUNBOOK.md`, and
> `docs/CRM_ACCEPTANCE_TESTS.md`.

Generated: 2026-06-17

## User Problem

The current Guided AI Labs CRM/intake experience is not usable for a non-technical business-development operator.

The immediate blocker is the SharePoint new item form for:

`https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/Lists/Guided%20AI%20Labs%20%20Intake%20Register/NewForm.aspx`

Despite multiple script-side attempts and verifier passes, the browser still shows technical/system fields near the top of the form:

- `SourceMailbox`
- `SourceMessageId`
- `ReceivedDate`
- other system/source/automation fields further down

The user expects an intake flow where a business-development person can create an opportunity/client signal with minimal friction, ideally by uploading or pasting an email and letting the system extract metadata. The user should not be asked for source mailbox, source message id, or other implementation metadata.

## Desired Operator Experience

Design around this mental model:

1. Capture the signal.
2. Identify who it is from.
3. Understand what they need.
4. Decide whether it is worth pursuing.
5. Create the next action.
6. Move through discovery, proposal, close/win/loss, delivery handoff, closeout, and invoice tracking.

The human-facing first-pass intake should ask only things like:

- Short summary
- Person name
- Email
- Organization
- Signal type
- Priority
- Context or notes
- What should happen next?
- Needs Adam review?

Source mailbox/message id/received date should be captured by automation or inferred from uploaded/pasted email, not manually typed by the operator.

## Current Repo Context

Primary active walkthrough:

- `M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md`

Business-flow design added during this work:

- `M365_STAGE_8E_FRICTIONLESS_CRM_BUSINESS_FLOW.md`

Stage 8C CRM workflow config:

- `config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json`

Important scripts:

- `scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1`
- `scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1`
- `scripts/New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1`

## What Was Tried

1. The Stage 8C config was updated so form sections use SharePoint internal field names instead of friendly display labels.
2. `SourceMailbox`, `SourceMessageId`, `ReceivedDate`, `IntakeStatus`, `ItemOwner`, `DurableHome`, `PlannerTaskUrl`, `CentralOSLink`, `GraphNodeId`, and `AgentConfidence` were made non-required.
3. A content-type `ClientFormCustomFormatter` was applied to the `Item` content type.
4. The verifier initially passed because it checked formatter JSON and required flags, not browser-visible form behavior.
5. A later check found `ContentTypesEnabled=False` on the list, so the content-type formatter may not have been used by `NewForm.aspx`.
6. Content types were enabled live via CSOM and the verifier was updated to check `ContentTypesEnabled=True`.
7. Latest verifier passed, but the user's browser screenshot still shows the raw technical fields. Therefore, the current script-side verification is insufficient.

## Important Latest Evidence

Latest claimed PASS verifier:

- `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md`
- `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-152413.log`
- `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-intake-experience-20260617-152413.csv`

Important failed/misleading verifier:

- `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-152016.log`
- `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-intake-experience-20260617-152016.csv`

Operations Cockpit card link change evidence:

- `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
- `inventory/gail-sharepoint-portal/gail-operations-portal-20260617-144536.log`

Findings register:

- `inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv`

## Key Concern For Next Model

Do not trust only PnP/CSOM readback or content-type formatter JSON. The browser still renders the raw NewForm fields. A valid plan should explain why SharePoint `NewForm.aspx` continues to display `SourceMailbox` and `SourceMessageId` after these settings, or recommend bypassing the default SharePoint list form entirely.

Likely options to evaluate:

- Replace the default list NewForm entry path with a custom SharePoint page or Power Apps form.
- Use Microsoft Forms or a SharePoint page with a simple embedded form as the intake front door.
- Use a document/email upload library as the first step, with a Power Automate/manual extraction lane into the intake list.
- Hide technical columns from the default content type field links, not just formatter JSON, if preserving NewForm is required.
- Stop exposing the raw list form to the operator and treat the list as a backend register.

## Non-Negotiable UX Requirement

The operator should not see or fill in `SourceMailbox`, `SourceMessageId`, or implementation/audit metadata during initial CRM intake.

The CRM system should feel like a business-development workflow, not a database administration form.
