# Operating Card Plan Index

Date: 2026-06-19

Status: Chunk 7 final usability walkthrough complete. Closeout evidence is
recorded in `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`.

This index tracks the operating-card deep dives. The current cockpit has four
visible top cards, but the target workspace has ten operating-card areas. Use
the active plan file for each card before granting access, onboarding a person,
or calling that card operator-ready. Use
`docs/WORKSPACE_INSTRUCTION_MANUAL.md` as the practical daily-use manual.

## Card Plan Standard

A card plan is complete only when it defines:

- purpose and operator promise;
- primary workflow and common scenarios;
- pages, lists, libraries, queues, links, and superseded surfaces;
- owner, backup owner, review cadence, and evidence location;
- employee/operator access, trusted partner/operator access, and admin-only
  authority;
- data model, required views, and data quality rules;
- runbook, acceptance test, agentic opportunities, and stop conditions.

## Current Plan Map

| Operating card | Current live surface | Plan file | Status | Next action |
|---|---|---|---|---|
| Workspace Home | Operations Cockpit homepage, Start Here nav, Login Guide | `docs/CARD_PLAN_WORKSPACE_HOME.md` | Active plan with Chunk 7 closeout evidence | Use the closeout doc for handoff; future cockpit cleanup only if live onboarding shows friction. |
| CRM / Relationships | CRM card, CRM Command Center, Open CRM Actions, Qualification Triage | `docs/CARD_PLAN_CRM_RELATIONSHIPS.md` | Active applied example | Continue functional recovery through `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| Delivery / Projects | Projects In Flight card, Active Delivery, Delivery Control, Lifecycle Checklist, Handoff Packets | `docs/CARD_PLAN_DELIVERY_PROJECTS.md` | Active plan with Chunk 7 closeout evidence | Continue only as delivery-specific execution or future dashboard cleanup. |
| Decisions / Governance | Operations card signals, Decisions page, Decision Register, App Grants, Exception Register | `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md` | Active plan with Chunk 7 closeout evidence | Keep admin authority separated; real decisions remain approval-gated. |
| Tasks / Actions | Operations card signals, CRM Action Queue, Planner/List task surfaces | `docs/CARD_PLAN_TASKS_ACTIONS.md` | Active plan with Chunk 7 closeout evidence | Use source-of-truth routing; read back permission groups before new operator grants. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Archive, Methods and IP nav | `docs/CARD_PLAN_KNOWLEDGE_RECORDS.md` | Active plan with Chunk 7 closeout evidence | Add a clearer cockpit route only if live onboarding shows records are too hidden. |
| Support / Intake | Operations card, Intake page, Guided AI Labs Intake Register, Change Leadership Tools Support Register | `docs/CARD_PLAN_SUPPORT_INTAKE.md` | Active plan with Chunk 7 closeout evidence | Resolve support MFA before support mailbox operations depend on that identity. |
| Finance / Closeout | Projects In Flight, Handoff Packets, CRM Closeout Invoice Queue | `docs/CARD_PLAN_FINANCE_CLOSEOUT.md` | Active plan with Chunk 7 closeout evidence | Keep billing, payment, legal, and client acceptance authority with Adam. |
| Agent Control Plane | Tools card, Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, App Grants | `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md` | Active plan with Chunk 6 readiness map and Chunk 7 closeout evidence | Use with `docs/AGENTIC_M365_READINESS.md` and `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`; do not expand AI/agent capability before the listed decisions and stop gates. |
| Access / Onboarding | Login Guide, Access Model, External Sharing Rules, App Grants | `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` | Active access model with Chunk 7 closeout evidence | Read back exact live SharePoint groups and permission groups before any grant. |

## Chunk 5 Card Notes

### Workspace Home

Current plan:

- `docs/CARD_PLAN_WORKSPACE_HOME.md`

First acceptance question:

- Can a new person choose the right card for common work without reading build
  history?

### CRM / Relationships

Current plan:

- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`
- `docs/CRM_EXECUTION_PLAN.md`

First acceptance question:

- Can the clean CRM path create a safe internal New Signal and show it in the
  expected triage/next-action flow?

### Delivery / Projects

Current plan:

- `docs/CARD_PLAN_DELIVERY_PROJECTS.md`

First acceptance question:

- Can an assigned operator move a safe internal delivery item through status,
  lifecycle, evidence, handoff, and closeout prep without admin authority?

### Decisions / Governance

Current plan:

- `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md`

First acceptance question:

- Can an operator record or find the right decision while knowing which choices
  require Adam or admin authority?

### Tasks / Actions

Current plan:

- `docs/CARD_PLAN_TASKS_ACTIONS.md`

First acceptance question:

- Can an operator choose the correct task source of truth and avoid orphan tasks
  across Planner, Lists, Teams, and agent suggestions?

### Knowledge / Records

Current plan:

- `docs/CARD_PLAN_KNOWLEDGE_RECORDS.md`

First acceptance question:

- Can an operator find official methods, evidence, restricted build material,
  handoff packets, and archive paths without guessing?

### Support / Intake

Current plan:

- `docs/CARD_PLAN_SUPPORT_INTAKE.md`

First acceptance question:

- Can an operator route broad intake, product support, CRM opportunities, and
  escalation items into the correct lane?

### Finance / Closeout

Current plan:

- `docs/CARD_PLAN_FINANCE_CLOSEOUT.md`

First acceptance question:

- Can an operator prepare closeout evidence and invoice-readiness notes while
  Adam retains billing, payment, legal, and client-commitment authority?

### Agent Control Plane

Current plan:

- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`
- `docs/AGENTIC_M365_READINESS.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`

First acceptance question:

- Can a reviewer classify an AI/agent action as G0-G4 and identify required
  approval, evidence, and rollback before any write-capable action?

Chunk 6 readiness result:

- Complete for documentation/readiness purposes. The current approved posture is
  G0/G1 first, supervised approval-gated G2 only, G3 only with Decision Register
  approval and typed approval phrase, and G4 blocked autonomously.

### Access / Onboarding

Current plan:

- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`

First acceptance question:

- Which exact live SharePoint groups and permission groups should be used for
  the first employee/operator or trusted partner grant after read-back?

## Chunk 5 Acceptance

Chunk 5 is complete when:

- all ten target operating cards have an active plan or active model;
- every non-CRM placeholder card has a workflow, runbook, access boundary,
  acceptance test, and stop conditions;
- recovery blockers are separated from future enhancements;
- no tenant-writing command has run;
- final usability proof is recorded in
  `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`.

## Chunk 7 Closeout

Chunk 7 is complete when:

- first-day handoff evidence is recorded;
- all ten operating-card areas are covered by the walkthrough result;
- remaining gaps are classified as future cleanup, card-specific execution,
  access read-back, or explicit governance stop gates;
- no tenant-writing command has run;
- the local closeout preflight passes.

Current closeout:

- `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`
- `inventory/workspace-usability-chunk-7/WORKSPACE_CHUNK_7_CLOSEOUT_PREFLIGHT.md`
