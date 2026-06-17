# Stage 8D Functional Workflow Walkthrough Guide

Generated: 2026-06-17 08:23:34
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json`

Scope: local-only walkthrough packet. This guide does not connect to Microsoft 365 and performs no tenant writes.

## Site

| Field | Value |
|---|---|
| Site | Guided AI Labs |
| Site URL | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs |
| Operations Cockpit | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx |
| CRM Command Center | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx |

## Sample Scenario

Name: Internal Guided AI Labs readiness walkthrough

Record prefix: `GAIL-INTERNAL-WALKTHROUGH`

Use one internal, non-client, non-external example to prove the operating path from intake signal through CRM engagement, decision, delivery action, and handoff evidence.

Allowed data:

- Internal Guided AI Labs test organization/contact names
- Non-sensitive dummy discovery notes
- Links to existing internal pages or placeholder evidence
- Clear labels that records are internal walkthrough artifacts

Avoid data:

- Real client personal data
- External commitments
- Secrets or credentials
- Public sharing links
- Guest identities

## Safety Limits

- No tenant writes are performed by the Stage 8D packet generator or preflight
- No permissions, sharing, guests, app grants, public Forms, mail sends, deletes, or unattended automation
- Manual walkthrough writes, if Adam approves them in browser, must stay internal and reversible
- Stop if the Operations Cockpit or CRM Command Center is confusing, missing, or shows the wrong daily path
- Stop if any step requires client/external data before the workflow is approved

## Walkthrough Steps

| ID | Phase | Source | Target | Acceptance |
|---|---|---|---|---|
| 8d-01 | Open daily cockpit | Guided AI Labs Operations Cockpit | Guided AI Labs Operations Cockpit | Adam can identify the CRM Command Center as the single daily CRM door without using the older reference pages. |
| 8d-02 | Create intake signal | Guided AI Labs - Intake Register | Guided AI Labs - Intake Register / Attention Now | The signal appears in the intake queue and has a clear next action. |
| 8d-03 | Qualify signal | CRM - Qualification / Qualification Triage | CRM - Qualification | The row appears in Qualification Triage until qualified, disqualified, nurture, or converted. |
| 8d-04 | Create CRM spine records | Relationship CRM reference lists | CRM - Organizations, Contacts, Engagements, Stakeholder Map, Touchpoints | The engagement carries entry package, target package, engagement stage, execution stage, owner, next action, and migration hooks. |
| 8d-05 | Record decision and action | Decision Register and CRM - Action Queue | Decision Register, CRM - Action Queue, Agent Action Log | The action appears in Open CRM Actions and any decision has an explicit rationale. |
| 8d-06 | Move to active delivery | Active Delivery page and Planner/List operating surfaces | CRM - Action Queue, Lifecycle Checklist, Handoff Packet Register | A future staff member can see what must happen next without asking where the record lives. |
| 8d-07 | Capture handoff evidence | CRM - Artifacts / Handoff Evidence and Client Handoff Packets | CRM - Artifacts, Handoff Packet Register, Readiness Evidence | The operating path ends with a durable evidence pointer and no external exposure. |

### 8d-01 - Open daily cockpit

Action: Open the live homepage and confirm the CRM, Operations, Tools, Projects In Flight cards and embedded attention queues are understandable.

Expected record: Browser review note only

Evidence target: Stage 8D walkthrough notes

### 8d-02 - Create intake signal

Action: Create or identify one internal test intake row labelled with the walkthrough record prefix.

Expected record: Internal intake signal with owner, status, next action, and durable note

Evidence target: Intake row link or browser note

### 8d-03 - Qualify signal

Action: Create a qualification row linked to the internal scenario and choose a recommended package.

Expected record: Qualification row with status, fit score, urgency, recommended package, owner, and next action due date

Evidence target: Qualification row link or browser note

### 8d-04 - Create CRM spine records

Action: Create the minimum internal organization/contact/engagement/touchpoint records required to represent the scenario.

Expected record: Organization, contact, engagement, stakeholder role, and first touchpoint records with RecordKey/CentralOSLink/GraphNodeId left blank or clearly placeholder

Evidence target: CRM record links or browser notes

### 8d-05 - Record decision and action

Action: If the scenario requires an internal operating decision, record it; then create one action queue item and one agent/evidence log note.

Expected record: Decision row only if there is a real internal decision; action queue row with due date and owner; Agent Action Log evidence

Evidence target: Decision/action/log links or browser notes

### 8d-06 - Move to active delivery

Action: Confirm the scenario can move from qualified/onboarding into active delivery without losing owner, status, blockers, or evidence.

Expected record: Lifecycle checklist item or delivery action with owner, blocker state, and evidence requirement

Evidence target: Checklist/action/handoff packet link or browser note

### 8d-07 - Capture handoff evidence

Action: Record a harmless placeholder evidence artifact and confirm it shows in the handoff/evidence queues.

Expected record: Artifact or handoff packet row labelled internal walkthrough, with no public/client sharing

Evidence target: Artifact/handoff/evidence link or browser note

## Stop Gates

| Gate | Trigger | Response |
|---|---|---|
| Daily path unclear | Adam cannot tell which page/list should be used next from the cockpit or CRM Command Center. | Stop and refine navigation/page copy before creating Teams tabs or automation. |
| Record ownership unclear | A record could belong in client tenant, Guided AI Labs tenant, OneDrive draft space, or SharePoint official record space and the owner is unclear. | Stop and record the ownership decision before continuing. |
| External action needed | The walkthrough appears to require guest access, external sharing, a public Form, or an email send. | Stop. Treat it as a Stage 7/9 approval-gated decision, not a Stage 8D walkthrough action. |
| Evidence cannot be found | A decision, action, handoff, or artifact cannot be linked back to the source signal. | Stop and add the missing evidence link before adding more records. |

## Review Questions

1. Can Adam open the cockpit and know what to do first?
2. Does the CRM Command Center make actions, qualification, meetings, artifacts, and health visible without extra explanation?
3. Can one internal example move from intake to handoff evidence without touching external sharing or email?
4. Are the old Relationship CRM and CRM Operations pages clearly reference pages rather than daily doors?
5. What is the first place where the system still feels confusing, duplicative, or too manual?

## Run Capture

Use the capture template during the browser walkthrough. Each step should end with one outcome, one evidence pointer or note, and one follow-up if anything felt unclear.

| Field | Purpose |
|---|---|
| RunDate | Date/time the browser walkthrough was performed. |
| BrowserProfile | Browser/profile used for the walkthrough, for example the work tenant profile. |
| RecordPrefix | Internal dummy record prefix used during the run. |
| StepId | Workflow step being captured. |
| Outcome | Pass, needs refinement, blocked, or skipped. |
| RecordOrEvidenceLink | Internal SharePoint/List/page link or a short browser note. |
| FrictionPoint | What felt confusing, duplicative, missing, or too manual. |
| FollowUp | Specific improvement, decision, or stop-gate action. |

Finding categories:

- Navigation or daily door
- List field or view
- Record ownership
- Evidence link
- Automation candidate
- Policy or approval gate
- Training or page copy

## Output Files

- Workflow step map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8d-functional-workflow-walkthrough\stage-8d-workflow-step-map.csv`
- Stop gate map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8d-functional-workflow-walkthrough\stage-8d-stop-gate-map.csv`
- Review question map: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8d-functional-workflow-walkthrough\stage-8d-review-question-map.csv`
- Walkthrough capture template: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8d-functional-workflow-walkthrough\stage-8d-walkthrough-capture-template.csv`
- Findings register starter: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-8d-functional-workflow-walkthrough\stage-8d-findings-register-starter.csv`
