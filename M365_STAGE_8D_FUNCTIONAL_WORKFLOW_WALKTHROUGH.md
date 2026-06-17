# Microsoft 365 Stage 8D - Functional Workflow Walkthrough

Status: **internal production workflow proof live-recorded and read-back
verified** (2026-06-17).

Stage 8D is the first practical workflow proof after the Guided AI Labs
Operations Cockpit and CRM Command Center were live-created and read-back
verified. It does not provision another system layer. It gives Adam and Codex a
safe browser/manual walkthrough plus an approval-gated internal production proof
for proving that the daily operating path is usable before widening access or
designing more automation.

Related:

- [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md)
- [M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md)
- [M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md](M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md)
- [M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md](M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md)
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)
- [config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json](config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json)

---

## 1. Goal

Prove the first real operating path:

```text
New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence
```

The proof should answer:

```text
Can Adam open the cockpit and know what to do next?
Can one harmless internal signal move through the CRM without losing context?
Can every action, decision, and evidence pointer land in the right surface?
Where does the system still feel confusing or too manual?
```

---

## 2. Scope

Stage 8D started as a local planning layer:

- a machine-readable walkthrough config;
- a generated browser/manual walkthrough guide;
- CSV maps for workflow steps, stop gates, and review questions;
- a walkthrough capture template and findings register starter;
- a local preflight script.

The packet generator and local preflight do not connect to Microsoft 365 and do
not create or update tenant content.

The follow-on production proof operator
`scripts/Invoke-M365Stage8DWorkflowProof.ps1` writes only clearly labelled
internal dummy records after the typed approval phrase
`record-stage-8d-internal-workflow-proof`.

---

## 3. Safety Limits

Stage 8D does not create:

- permission changes;
- guests;
- sharing links;
- app grants or consent;
- public Forms;
- mail sends;
- deletes;
- unattended automation;
- Dynamics or Dataverse resources.

Stop the walkthrough if the next step would require real client data, external
access, public sharing, or a commitment outside Guided AI Labs.

---

## 4. Working Surfaces

Primary browser path:

```text
Guided AI Labs Operations Cockpit
-> CRM Command Center
-> Intake / Qualification / CRM records / Action Queue
-> Decision Register and Agent Action Log when needed
-> Handoff evidence surfaces
```

Daily URLs:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx
```

Older Relationship CRM and CRM Operations pages remain reference pages, not
daily entry points.

---

## 5. Live Walkthrough And Proof Finding

The first browser checkpoint found a real usability gap: the Operations Cockpit
has a CRM Command Center card, but opening it did not present a recognizable CRM
stage or pipeline workflow. The underlying Stage 8B/8C lists and views existed,
including qualification, pipeline, delivery control, actions, artifacts, and
handoff evidence, but the daily command surface did not behave like the front
door to a CRM.

The second browser checkpoint found the next usability gap: the stage path was
functional, but still presented as a wall of text. The intake link opened the raw
SharePoint list item form, exposing source mailbox, source message id, received
date, and other system fields before the human intake questions.

The Stage 8C production refresh was then applied and read-back verified so the
CRM Command Center is an action hub and the intake form exposes a cleaner first
pass:

```text
Intake -> Qualification -> Engagement Pipeline -> Decision / Proposal -> Active Delivery -> Handoff Evidence
```

```text
Quick intake: Intake summary, Person name, Email, Organization
Triage: Signal type, Priority, What should happen next?, Context / notes, Needs Adam review
```

Capture evidence:

```text
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-command-center-stage-path.csv
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-frictionless-intake-map.csv
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-110134.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-110545.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-112206.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-112546.log
```

On 2026-06-17, Adam approved moving the next steps straight to production. The
Stage 8D internal proof operator created and then idempotently refreshed one
internal dummy workflow chain:

```text
RecordKey: GAIL-INTERNAL-WALKTHROUGH-PROD-20260617
Intake item: #1
Organization: #1
Contact: #1
Engagement: #1
Qualification: #1
Stakeholder role: #1
Touchpoint: #1
Action queue item: #1
Lifecycle checklist item: #1
Artifact/evidence item: #1
Agent Action Log item: #6
```

Production proof evidence:

```text
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-20260617-120746.log
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-20260617-121052.log
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-readback-20260617-121052.csv
```

The proof did not create permission changes, guests, sharing links, app grants,
public Forms, mail sends, deletions, Dynamics/Dataverse resources, or unattended
automation. No Decision Register item was created because the internal proof did
not require a real scope/governance/commercial decision.

---

## 6. Local Commands

Generate the walkthrough packet:

```powershell
.\scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1
```

Run local preflight:

```powershell
.\scripts\Test-M365Stage8DLocalPreflight.ps1
```

Dry-run the internal production proof:

```powershell
.\scripts\Invoke-M365Stage8DWorkflowProof.ps1 -NoPause
```

Apply the internal production proof after approval:

```powershell
.\scripts\Invoke-M365Stage8DWorkflowProof.ps1 -Apply -ApprovalPhrase record-stage-8d-internal-workflow-proof -NoPause
```

Generated guide:

```text
inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md
```

Capture files:

```text
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv
```

---

## 7. Done Criteria

Stage 8D is done when:

- the local packet and preflight pass;
- one internal example can move from intake signal to handoff/evidence pointer;
- the capture template has one outcome per walkthrough step;
- all confusion points are captured in the findings register as changes, not
  worked around silently;
- no external sharing, guest access, public Forms, mail sends, app grants,
  permission changes, deletes, or unattended automation were required.

As of 2026-06-17, the production back-end proof satisfies the record/evidence
criteria. Adam's visual browser review remains the subjective polish check
before turning these surfaces into Teams tabs or broader staff/client-facing
operations.
