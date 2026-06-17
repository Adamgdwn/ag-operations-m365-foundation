# Microsoft 365 Stage 8D - Functional Workflow Walkthrough

Status: **local-only packet added** (2026-06-17).

Stage 8D is the first practical workflow proof after the Guided AI Labs
Operations Cockpit and CRM Command Center were live-created and read-back
verified. It does not provision another system layer. It gives Adam and Codex a
safe browser/manual walkthrough for proving that the daily operating path is
usable before creating Teams tabs, widening access, or designing more automation.

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

Stage 8D creates only local planning artifacts:

- a machine-readable walkthrough config;
- a generated browser/manual walkthrough guide;
- CSV maps for workflow steps, stop gates, and review questions;
- a walkthrough capture template and findings register starter;
- a local preflight script.

The Stage 8D scripts do not connect to Microsoft 365 and do not create or update
tenant content.

Manual browser writes during the walkthrough are optional and require Adam's
approval in the browser. If performed, they must use internal dummy records only.

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

## 5. Local Commands

Generate the walkthrough packet:

```powershell
.\scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1
```

Run local preflight:

```powershell
.\scripts\Test-M365Stage8DLocalPreflight.ps1
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

## 6. Done Criteria

Stage 8D is done when:

- the local packet and preflight pass;
- Adam has browser-reviewed the Operations Cockpit and CRM Command Center;
- one internal example can move from intake signal to handoff/evidence pointer;
- the capture template has one outcome per walkthrough step;
- all confusion points are captured in the findings register as changes, not
  worked around silently;
- no external sharing, guest access, public Forms, mail sends, app grants,
  permission changes, deletes, or unattended automation were required.
