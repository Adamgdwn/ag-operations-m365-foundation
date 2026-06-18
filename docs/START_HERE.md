# Workspace Start Here

Date: 2026-06-18

Status: Active workspace usability source of truth.

Read this file before using older Stage 8 or CRM packet docs. The current target
is not merely "the CRM exists." The target is a usable Guided AI Labs operating
workspace where a capable employee, operator, or trusted partner can sign in,
open the Operations Cockpit, understand the cards, and do useful work without
knowing the build history.

## North Star

Guided AI Labs should be able to onboard a capable person by giving them:

- their Microsoft 365 login and MFA instructions;
- the Guided AI Labs operating links;
- role-appropriate access to the operating surfaces;
- the relevant card runbook;
- escalation rules for permissions, client commitments, billing, automation, and
  AI/agent actions.

"Full access" means full operating access for the assigned role. A trusted
partner can receive a broader partner/operator role with full operating access
across the relevant cards, while tenant/global admin authority and break-glass
access stay as separate controlled grants.

## Active Workspace Docs

- `docs/WORKSPACE_EXECUTION_PLAN.md` - executable chunks for the full usability pass.
- `docs/COCKPIT_USABILITY_INVENTORY.md` - current cockpit cards, queues, links,
  navigation, and categories.
- `docs/COCKPIT_CARD_GAP_LIST.md` - cleanup, card-plan, and access/runbook gaps
  found in Chunk 2.
- `docs/AGENTIC_M365_READINESS.md` - recommendations for becoming agentic and AI-centric.
- `docs/CARD_PLAN_TEMPLATE.md` - repeatable structure for each card deep dive.
- `docs/CRM_EXECUTION_PLAN.md` - executable chunks for the CRM card.
- `docs/CRM_RECOVERY_PLAN.md` - CRM strategic brief, constraints, and recovery context.
- `docs/CRM_RUNBOOK.md` - CRM daily employee instructions.
- `docs/CRM_ACCEPTANCE_TESTS.md` - CRM completion checks.
- `docs/CRM_UX_SPEC.md` - CRM business-facing interface target.
- `docs/CRM_DATA_MODEL.md` - CRM lists, fields, and record responsibilities.
- `docs/CRM_DECISIONS.md` - CRM decision log.
- `docs/CRM_ENVIRONMENT_READINESS.md` - local tooling and auth readiness.

## Operating Cards

The Operations Cockpit should become a set of usable operating cards, not a
technical map. CRM is one card in the set.

Local evidence from `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
and `scripts/Set-GuidedAILabsOperationsPortal.ps1` shows the current live
cockpit has four top cards:

- CRM
- Operations
- Tools
- Projects In Flight

It also embeds four live queues:

- CRM - Action Queue / Open CRM Actions
- CRM - Qualification / Qualification Triage
- Guided AI Labs - Intake Register / Attention Now
- Agent Action Log / Needs Review

The target operating-card map below is broader than the current visual card
labels. It is the structure we will use for completion, access, onboarding, and
card-by-card deep dives.

Chunk 2 categorized the current cockpit surface in
`docs/COCKPIT_USABILITY_INVENTORY.md`. The next workspace chunk is Chunk 3 -
Card Template And Acceptance Standard.

| Operating card | Current live surface | Primary workflow | Plan status | Completion requirement |
|---|---|---|---|---|
| Workspace Home | Operations Cockpit homepage, Start Here nav, Login Guide | Open the front door, choose the right card, see live queues. | Active: `docs/WORKSPACE_EXECUTION_PLAN.md` | A capable person can reach the cockpit and choose the right next surface without repo history. |
| CRM / Relationships | CRM card, CRM Command Center, Open CRM Actions, Qualification Triage | Capture signals, qualify, propose, hand off delivery, close out. | Active: `docs/CRM_EXECUTION_PLAN.md` | CRM runbook and acceptance tests pass with role-appropriate access. |
| Delivery / Projects | Projects In Flight card, Active Delivery page, Delivery Control, Lifecycle Checklist, Handoff Packets | Run active engagements and internal work from assignment through handoff. | Placeholder | Card plan, owner, runbook, queue, evidence location, and acceptance test are built. |
| Decisions / Governance | Operations card, Decisions page, Decision Register, App Grants, Exception Register | Record approvals, scope decisions, risks, exceptions, and review dates. | Placeholder | Decision workflow, approval gate, exception handling, and escalation rules are usable. |
| Tasks / Actions | Operations card, Open CRM Actions queue, Planner/List task surfaces | Track assigned work, due dates, blockers, and completion state. | Placeholder | Task source of truth is clear across cards and does not split daily work invisibly. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Archive, Methods and IP nav | Find official records, reusable IP, source material, and evidence. | Placeholder | Record locations, permissions, retention posture, and search grounding are clear. |
| Support / Intake | Operations card, Intake page, Guided AI Labs - Intake Register, Change Leadership Tools Support Register | Capture and triage support requests, internal asks, and client signals. | Placeholder | Support/intake front doors, triage ownership, and handoff rules are defined. |
| Finance / Closeout | Projects In Flight card, Handoff Packets, CRM Closeout Invoice Queue | Prepare final evidence, closeout notes, invoice readiness, and payment follow-up. | Placeholder | Closeout ownership, evidence, invoice handoff, and blocked-payment escalation are defined. |
| Agent Control Plane | Tools card, Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, App Grants | Review AI suggestions, approvals, tool scopes, action logs, and rollback notes. | Active readiness map: `docs/AGENTIC_M365_READINESS.md` | Agent actions have a human owner, approval gate, evidence record, and rollback note. |
| Access / Onboarding | Login Guide, Access Model page, External Sharing Rules, App Grants | Grant role-appropriate access and give first-day operating instructions. | Placeholder | Employee, operator, trusted partner, and admin authority are separated and documented. |

## Current Live CRM Path

CRM remains the first card under active recovery:

```text
Operations Cockpit
-> CRM Command Center
-> New Signal
-> CRM - New Signals
-> Triage Queue
-> Qualification
-> Proposal / Decision
-> Delivery
-> Closeout / Invoice
```

Do not send daily CRM operators to
`Guided AI Labs - Intake Register/NewForm.aspx`. That route is legacy technical
intake and is not the clean CRM front door.

## Workspace Completion Definition

The broader usability pass is complete when a capable employee, operator, or
trusted partner can:

1. Sign in with MFA and reach the Guided AI Labs Operations Cockpit.
2. Understand what each operating card is for.
3. Open the right card without using repo docs or admin links.
4. Complete each card's primary workflow using business-facing fields and views.
5. Find official records, handoffs, decisions, evidence, and next actions.
6. Know what not to touch: permissions, external sharing, app consent, mailbox
   automation, public forms, deletes, Dynamics, Dataverse, premium Power
   Platform dependencies, and unattended agent actions.
7. Escalate blocked access, client commitments, billing ambiguity, data quality
   problems, AI/agent decisions, and governance exceptions to Adam.

## Superseded Material

Root Stage 8 CRM docs are provenance unless they explicitly say otherwise. They
may explain how the tenant reached the current state, but they are not the
employee operating manual and should not be used as the next execution plan.

## When Adam Says Go Ahead

For the full workspace usability pass, work from
`docs/WORKSPACE_EXECUTION_PLAN.md`.

For a CRM-specific chunk, work from `docs/CRM_EXECUTION_PLAN.md`.

For agentic and AI-centric Microsoft 365 recommendations, work from
`docs/AGENTIC_M365_READINESS.md`.
