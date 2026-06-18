# Workspace Execution Plan

Date: 2026-06-18

Status: Active chunk plan for full workspace usability.

Use this document when Adam says to continue the broader workspace build. CRM is
one operating card. This plan makes the whole Guided AI Labs workspace usable
before each card receives a deeper functional pass.

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

Chunk 2 is complete locally. The next workspace chunk is Chunk 3 - Card Template
And Acceptance Standard.

Chunk status:

| Chunk | Status | Notes |
|---|---|---|
| Chunk 1 - Workspace Card Map | Complete locally 2026-06-18 | Card map, active-plan/placeholders, completion requirements, and source-of-truth routing are recorded. |
| Chunk 2 - Cockpit Usability Inventory | Complete locally 2026-06-18 | Cockpit cards, queues, page links, and known navigation links are categorized from local evidence. |
| Chunk 3 - Card Template And Acceptance Standard | Next | Requires validating the template against the card inventory and deciding whether CRM should be the first applied example. |

## Completion Requirements

The workspace usability pass is complete only when all requirements below are
true.

Source-of-truth requirements:

- `docs/START_HERE.md` is broad enough for the whole workspace, not just CRM.
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

Card-deep-dive requirements:

- Each card has a functional checklist before it is called done.
- The CRM card uses `docs/CRM_EXECUTION_PLAN.md`.
- Other cards get their own focused plans as Adam reviews them.

## Chunk 1 - Workspace Card Map

Status: Complete locally 2026-06-18.

Objective:

Turn the workspace from a CRM-focused recovery path into a full operating-card
map.

Inputs:

- `docs/START_HERE.md`
- `START_HERE_TOKEN_FRIENDLY.md`
- `M365_FOUNDATION_ROADMAP.md`
- existing Stage 8 and Stage 9 evidence

Actions:

1. Confirm the list of operating cards. Done.
2. Identify which cards have active plans and which are placeholders. Done.
3. Add completion requirements for the whole workspace. Done.
4. Point CRM-specific work to `docs/CRM_EXECUTION_PLAN.md`. Done.
5. Point AI/agentic recommendations to `docs/AGENTIC_M365_READINESS.md`. Done.

Outputs:

- updated `docs/START_HERE.md`
- updated `docs/WORKSPACE_EXECUTION_PLAN.md`
- updated `docs/AGENTIC_M365_READINESS.md`
- updated `docs/CARD_PLAN_TEMPLATE.md`

Local evidence used:

- `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
- `scripts/Set-GuidedAILabsOperationsPortal.ps1`
- `config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json`
- `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`
- `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
- `START_HERE_TOKEN_FRIENDLY.md`
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

Status: Complete locally 2026-06-18.

Objective:

Read the live or configured Operations Cockpit and list every visible card,
queue, and link.

Inputs:

- current SharePoint cockpit page evidence
- Stage 8 homepage and portal evidence
- `docs/START_HERE.md`

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

Objective:

Create one repeatable template for each card's deep dive.

Inputs:

- `docs/WORKSPACE_EXECUTION_PLAN.md`
- `docs/CRM_EXECUTION_PLAN.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`

Actions:

1. Create a card-plan template with purpose, users, access, data model,
   workflow, runbook, acceptance tests, agentic opportunities, and stop
   conditions.
2. Apply the template to CRM as the example.
3. Leave placeholders for other cards.

Outputs:

- `docs/CARD_PLAN_TEMPLATE.md`
- optional card-specific skeleton docs

Acceptance gate:

- Each future card deep dive can start from the same structure.

Stop conditions:

- The card list changes materially during review.

## Chunk 4 - Access And Onboarding Model

Objective:

Define role-appropriate operating access across cards.

Inputs:

- current Microsoft 365 groups and SharePoint permissions
- `docs/START_HERE.md`
- Stage 2 identity/admin foundation notes

Actions:

1. Define employee, operator, trusted partner/operator, and admin roles.
2. Map each role to card access.
3. Identify tenant/global admin grants that must remain separate.
4. Add first-day onboarding instructions and escalation rules.

Outputs:

- access matrix
- onboarding instructions

Acceptance gate:

- Adam can grant a person the right access without guessing whether "full
  access" means operating access or tenant admin.

Stop conditions:

- Permission groups cannot be read or are ambiguous.

## Chunk 5 - Card Deep Dives

Objective:

Review each card for full function.

Inputs:

- cockpit inventory
- card template
- Adam's review of each card

Actions:

1. Review one card at a time.
2. Define its workflow, lists/libraries/pages, access, runbook, and acceptance
   tests.
3. Separate recovery blockers from future enhancements.
4. Create card-specific execution plans where needed.

Outputs:

- card-specific plans and runbooks
- acceptance tests per card

Acceptance gate:

- Each card can be handed to a capable employee/operator/partner with login,
  links, role access, and instructions.

Stop conditions:

- A card depends on licensing, app consent, permissions, or automation not yet
  approved.

## Chunk 6 - Agentic M365 Readiness Pass

Objective:

Prepare the Microsoft 365 environment for safe agentic and AI-centric operation.

Inputs:

- `docs/AGENTIC_M365_READINESS.md`
- Stage 9 bridge readiness config and evidence
- Microsoft 365 admin, Purview, SharePoint, Graph, and Copilot readiness notes

Actions:

1. Review identity, permissions, data governance, audit, and records posture.
2. Define agent action log and approval patterns.
3. Decide what stays SharePoint-native, what uses Copilot agents, what uses
   Copilot connectors, and what waits for custom integrations.
4. Record licensing, consent, security, and DLP decisions.

Outputs:

- updated agentic readiness recommendations
- decision list for Adam

Acceptance gate:

- The organization has a governed path from "AI suggests" to "human approves" to
  "system acts" with evidence and rollback notes.

Stop conditions:

- Required licensing, Purview capability, app consent, or admin authority is not
  available.

## Chunk 7 - Final Usability Walkthrough

Objective:

Prove the whole workspace can be used by a new capable person.

Inputs:

- active cockpit
- card runbooks
- access matrix
- acceptance tests

Actions:

1. Use a realistic first-day scenario.
2. Open each relevant card from the cockpit.
3. Complete or simulate each primary workflow.
4. Confirm the person can find records, actions, decisions, evidence, and
   escalation rules.
5. Record gaps and future work.

Outputs:

- usability evidence
- remaining gap list
- closeout note

Acceptance gate:

- Adam can hand over login, links, role access, and instructions, and the person
  can operate the workspace without needing build-history coaching.

Stop conditions:

- Any card blocks the first-day workflow.
- Permissions or technical links expose confusing or unsafe admin surfaces.
