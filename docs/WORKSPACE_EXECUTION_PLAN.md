# Workspace Execution Plan

Date: 2026-06-24

Status: Closed historical chunk plan for the broad workspace usability pass.
Current active plan: `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`.

Use this document for workspace usability history and acceptance evidence. For
current work, start at root `START_HERE.md` and follow the current active plan.

Box-up note 2026-06-19: Chunks 1-7 are complete and pushed. The broad workspace
usability pass is closed; resume with a named card-specific chunk or controlled
governance/read-back task.

Box-up note 2026-06-24: startup routing has been consolidated to root
`START_HERE.md`. The current active plan is
`docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`.

## Execution Rule

Work one chunk at a time. A chunk is complete only when the listed outputs exist
and the acceptance gate is met.

After each major chunk completion, commit and push the completed chunk snapshot
before starting the next major chunk.

No tenant-writing command may run unless Adam gives the specific approval phrase
for that chunk. CRM recovery writes continue to use:

```text
apply-gail-crm-recovery
```

New approval phrases must be added before any non-CRM tenant-writing chunk.

## Current Chunk

Chunks 1-7 are complete and pushed. There is no active broad workspace
usability chunk. Adam's current selected direction is functionality plus
agentic assistance and approvals: start with
`docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`. Other work, such as access
read-back before a grant, support MFA closeout, or controlled cockpit cleanup,
should be explicit.

Chunk status:

| Chunk | Status | Notes |
|---|---|---|
| Chunk 1 - Workspace Card Map | Complete and pushed 2026-06-18 | Card map, active-plan/placeholders, completion requirements, and source-of-truth routing are recorded. |
| Chunk 2 - Cockpit Usability Inventory | Complete and pushed 2026-06-18 | Cockpit cards, queues, page links, and known navigation links are categorized from local evidence. |
| Chunk 3 - Card Template And Acceptance Standard | Complete and pushed 2026-06-19 | Template hardened, CRM applied example created, and remaining card placeholders recorded in the card-plan index. |
| Chunk 4 - Access And Onboarding Model | Complete and pushed 2026-06-19 | Role definitions, access levels, card access matrix, first-day onboarding, escalation rules, and admin-only authority are documented. |
| Chunk 5 - Card Deep Dives | Complete and pushed 2026-06-19 | Active card plans were created for Workspace Home, Delivery, Decisions, Tasks, Knowledge, Support, Finance, and Agent Control Plane. |
| Chunk 6 - Agentic M365 Readiness Pass | Complete and pushed 2026-06-19 | Agentic readiness verdict, governed path, approval pattern, action-log fields, surface lane decisions, and Adam decision queue are documented. |
| Chunk 7 - Final Usability Walkthrough | Complete and pushed 2026-06-19 | Closeout evidence, remaining gap list, local preflight, and handoff verdict are recorded. |

## Completion Requirements

The workspace usability pass is complete only when all requirements below are
true.

Source-of-truth requirements:

- `START_HERE.md` is broad enough for the whole workspace, not just CRM.
- `docs/WORKSPACE_INSTRUCTION_MANUAL.md` gives an operator daily-use manual
  without build-history coaching.
- Each operating card has one active plan or a clear "to be built" placeholder.
- Superseded Stage 8 packet docs are marked as provenance.

Usability requirements:

- Operations Cockpit is the daily front door.
- Each visible card has a plain purpose, primary workflow, owner, runbook, and
  acceptance test.
- A new employee/operator/partner can identify which card to open for common
  work without reading build history.

Access requirements:

- Employee, operator, trusted partner, and admin authority are separated.
- "Full access" means full operating access for the assigned role, not automatic
  tenant/global admin authority.
- Each card identifies the minimum operating access needed.

Agentic readiness requirements:

- AI and agent work has a governed action log, approval gate, rollback note, and
  human owner.
- Microsoft 365 identity, records, permissions, labels, audit, and connectors are
  prepared before unattended or external-impacting agent work.
- Agentic recommendations are recorded in `docs/AGENTIC_M365_READINESS.md`.
- Agentic approval patterns and Adam decision queue are recorded in
  `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`.

Card-deep-dive requirements:

- Each card has a functional checklist before it is called done.
- The CRM card uses `docs/CARD_PLAN_CRM_RELATIONSHIPS.md` and
  `docs/CRM_EXECUTION_PLAN.md`.
- Other cards use the active plan files recorded in `docs/CARD_PLAN_INDEX.md`.

## Chunk 1 - Workspace Card Map

Status: Complete and pushed 2026-06-18.

Objective:

Turn the workspace from a CRM-focused recovery path into a full operating-card
map.

Inputs:

- `START_HERE.md`
- `M365_FOUNDATION_ROADMAP.md`
- existing Stage 8 and Stage 9 evidence

Actions:

1. Confirm the list of operating cards. Done.
2. Identify which cards have active plans and which are placeholders. Done.
3. Add completion requirements for the whole workspace. Done.
4. Point CRM-specific work to `docs/CRM_EXECUTION_PLAN.md`. Done.
5. Point AI/agentic recommendations to `docs/AGENTIC_M365_READINESS.md`. Done.

Outputs:

- updated `START_HERE.md`
- updated `docs/WORKSPACE_EXECUTION_PLAN.md`
- updated `docs/AGENTIC_M365_READINESS.md`
- updated `docs/CARD_PLAN_TEMPLATE.md`

Local evidence used:

- `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1`
- `config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json`
- `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
- `START_HERE.md`
- `M365_FOUNDATION_ROADMAP.md`

Confirmed current cockpit surface:

- Top cards: CRM, Operations, Tools, Projects In Flight.
- Embedded queues: Open CRM Actions, Qualification Triage, Attention Now, and
  Agent Action Log / Needs Review.
- Current daily CRM door: CRM Command Center.
- Older Relationship CRM and CRM Operations pages are reference surfaces, not
  daily operator doors.

Confirmed target operating-card set:

- Workspace Home
- CRM / Relationships
- Delivery / Projects
- Decisions / Governance
- Tasks / Actions
- Knowledge / Records
- Support / Intake
- Finance / Closeout
- Agent Control Plane
- Access / Onboarding

Active plan routing:

- Whole workspace: `docs/WORKSPACE_EXECUTION_PLAN.md`
- CRM card: `docs/CRM_EXECUTION_PLAN.md`
- Agentic readiness: `docs/AGENTIC_M365_READINESS.md`
- Future card deep dives: copy `docs/CARD_PLAN_TEMPLATE.md`

Acceptance gate:

- Met. Adam can tell whether the next go-ahead is for the whole workspace, the
  CRM card, or agentic readiness.

Stop conditions:

- None hit. The visible cockpit cards were identified from local evidence.

## Chunk 2 - Cockpit Usability Inventory

Status: Complete and pushed 2026-06-18.

Objective:

Read the live or configured Operations Cockpit and list every visible card,
queue, and link.

Inputs:

- current SharePoint cockpit page evidence
- Stage 8 homepage and portal evidence
- `START_HERE.md`

Actions:

1. Export or inspect the current cockpit page and navigation.
2. Compare visible cards to the operating-card map.
3. Record missing, duplicate, confusing, or technical/admin-only links.
4. Identify which cards require tenant changes and which only need docs/runbooks.

Outputs:

- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`

Acceptance gate:

- Met. Every visible card, embedded queue, cockpit page link, and known broader
  navigation link from local evidence is categorized as active, needs cleanup,
  admin-only/controlled, superseded, or future.

Stop conditions:

- None hit. Local evidence was sufficient, so live SharePoint was not read and
  no tenant write was required.

## Chunk 3 - Card Template And Acceptance Standard

Status: Complete and pushed 2026-06-19.

Objective:

Create one repeatable template for each card's deep dive.

Inputs:

- `docs/WORKSPACE_EXECUTION_PLAN.md`
- `docs/CRM_EXECUTION_PLAN.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Actions:

1. Create a card-plan template with purpose, users, access, data model,
   workflow, runbook, acceptance tests, agentic opportunities, and stop
   conditions. Done.
2. Apply the template to CRM as the example. Done.
3. Leave placeholders for other cards. Done.

Outputs:

- `docs/CARD_PLAN_TEMPLATE.md`
- `docs/CARD_PLAN_INDEX.md`
- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`

Acceptance gate:

- Met. Each future card deep dive can start from the same structure, and the
  CRM example shows how to separate operator readiness, access boundaries,
  data model, runbook, acceptance evidence, and stop conditions.

Stop conditions:

- None hit. The card list did not change materially during review.

## Chunk 4 - Access And Onboarding Model

Status: Complete and pushed 2026-06-19.

Objective:

Define role-appropriate operating access across cards.

Inputs:

- current Microsoft 365 groups and SharePoint permissions
- `START_HERE.md`
- Stage 2 identity/admin foundation notes

Actions:

1. Define employee, operator, trusted partner/operator, and admin roles. Done.
2. Map each role to card access. Done.
3. Identify tenant/global admin grants that must remain separate. Done.
4. Add first-day onboarding instructions and escalation rules. Done.

Outputs:

- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- updated `START_HERE.md`
- updated `docs/CARD_PLAN_INDEX.md`
- updated restart/routing docs

Acceptance gate:

- Met. Adam can classify a person, choose an access level, map the role to each
  operating card, identify what remains admin-only, and run a first-day
  walkthrough without guessing whether "full access" means operating access or
  tenant admin.

Stop conditions:

- None hit for this documentation chunk. Exact live SharePoint group and
  permission targets remain a required read-back step before any actual grant.

## Chunk 5 - Card Deep Dives

Status: Complete and pushed 2026-06-19.

Objective:

Review each card for full function.

Inputs:

- cockpit inventory
- card template
- Adam's review of each card

Actions:

1. Review one card at a time. Done for all non-CRM placeholder cards from local
   evidence.
2. Define its workflow, lists/libraries/pages, access, runbook, and acceptance
   tests. Done.
3. Separate recovery blockers from future enhancements. Done.
4. Create card-specific execution plans where needed. Done.

Outputs:

- `docs/CARD_PLAN_WORKSPACE_HOME.md`
- `docs/CARD_PLAN_DELIVERY_PROJECTS.md`
- `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md`
- `docs/CARD_PLAN_TASKS_ACTIONS.md`
- `docs/CARD_PLAN_KNOWLEDGE_RECORDS.md`
- `docs/CARD_PLAN_SUPPORT_INTAKE.md`
- `docs/CARD_PLAN_FINANCE_CLOSEOUT.md`
- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`
- updated `docs/CARD_PLAN_INDEX.md`
- updated `START_HERE.md`
- updated restart/routing docs

Acceptance gate:

- Met for documentation and runbook readiness. Each operating card now has an
  active plan or active model with purpose, workflow, surfaces, owner/cadence,
  access boundaries, data model, runbook, acceptance test, blockers, future
  enhancements, and stop conditions. Final usability proof is recorded in
  `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`.

Stop conditions:

- None hit for this documentation chunk. No live tenant read or write was
  performed. Future live grants, page/navigation changes, app consent, public
  forms, production mail, permission changes, deletes, Dynamics/Dataverse,
  premium Power Platform, or unattended automation remain explicit stop
  conditions.

## Chunk 6 - Agentic M365 Readiness Pass

Status: Complete and pushed 2026-06-19.

Objective:

Prepare the Microsoft 365 environment for safe agentic and AI-centric operation.

Inputs:

- `docs/AGENTIC_M365_READINESS.md`
- Stage 9 bridge readiness config and evidence
- Microsoft 365 admin, Purview, SharePoint, Graph, and Copilot readiness notes

Actions:

1. Review identity, permissions, data governance, audit, and records posture.
   Done from local Stage 7/9 evidence and Chunk 5 card plans.
2. Define agent action log and approval patterns. Done.
3. Decide what stays SharePoint-native, what uses Copilot agents, what uses
   Copilot connectors, and what waits for custom integrations. Done.
4. Record licensing, consent, security, and DLP decisions. Done as decision
   queue and blocked/default posture.

Outputs:

- updated `docs/AGENTIC_M365_READINESS.md`
- new `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`
- updated routing/restart docs

Acceptance gate:

- Met for documentation/readiness purposes. Guided AI Labs has a governed path
  from "AI suggests" to "human approves" to "system acts" through a recorded
  G0-G4 action model, Agent Action Log fields/statuses, approval pattern,
  surface lane decisions, licensing/consent/security/DLP decision queue, and
  explicit stop conditions before any write-capable or external-impacting agent
  work.

Stop conditions:

- No blocker prevented the local documentation pass.
- Required licensing, Purview capability, app consent, admin authority,
  support MFA, permission-scope design, rollback worksheet, public Forms,
  connectors, production bridge app, external sends, sharing, guests, deletes,
  or unattended automation remain stop conditions for future tenant work.

## Chunk 7 - Final Usability Walkthrough

Status: Complete and pushed 2026-06-19.

Objective:

Prove the whole workspace can be used by a new capable person.

Inputs:

- active cockpit
- card runbooks
- access matrix
- acceptance tests

Actions:

1. Use a realistic first-day scenario. Done.
2. Open each relevant card from the cockpit. Done from current cockpit evidence,
   active card plans, and Stage 8D production read-back.
3. Complete or simulate each primary workflow. Done using existing internal
   proof rows and documented runbook simulation; no new tenant write was run.
4. Confirm the person can find records, actions, decisions, evidence, and
   escalation rules. Done.
5. Record gaps and future work. Done.

Outputs:

- `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`
- `docs/WORKSPACE_INSTRUCTION_MANUAL.md`
- `scripts/Test-WorkspaceChunk7Closeout.ps1`
- `inventory/workspace-usability-chunk-7/WORKSPACE_CHUNK_7_CLOSEOUT_PREFLIGHT.md`
- updated routing/restart docs

Acceptance gate:

- Met. Adam can hand over login, links, role access, and instructions, and the
  person can operate the workspace without needing build-history coaching.

Stop conditions:

- No stop condition blocked the local closeout.
- Future live grants still require exact permission read-back.
- Future tenant writes, sharing, app consent, external sends, public Forms,
  deletes, production agents, or cockpit/page changes still require explicit
  approval phrase, scope, evidence, and rollback.
