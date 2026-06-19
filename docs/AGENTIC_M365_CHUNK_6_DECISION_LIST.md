# Agentic M365 Chunk 6 Decision List

Date: 2026-06-19

Status: Chunk 6 output. Local documentation only; no Microsoft 365 tenant read
or write was performed for this pass.

Use this list with `docs/AGENTIC_M365_READINESS.md` and
`docs/CARD_PLAN_AGENT_CONTROL_PLANE.md` before approving Copilot, connector,
Power Platform, custom adapter, or unattended agent work.

## Readiness Verdict

Guided AI Labs is ready for:

- G0 read-only review, classification, summarization, and gap detection.
- G1 suggestions and Agent Action Log rows.
- Supervised G2 internal List/task/draft writes only after named approval,
  evidence, and rollback notes.

Guided AI Labs is not yet ready for:

- unattended write-capable agents;
- production UAOS/M365 adapter apps;
- app registrations or consent grants for production bridge work;
- SharePoint Selected permission grants or Exchange Application RBAC;
- external sends, guest invites, sharing changes, public Forms, permission
  changes, tenant policy changes, deletes, or client commitments.

## Default Decisions

| Area | Chunk 6 default | Why | Blocks |
|---|---|---|---|
| Agent posture | Stay supervised delegated. | Lowest new permission risk while card runbooks and final walkthrough are still pending. | Production bridge, unattended writes, app-based adapters. |
| Action logging | Every meaningful suggestion or assisted action needs an Agent Action Log row. | Creates durable evidence before agent work becomes normal. | Any agent action without source, owner, approval state, evidence, and rollback note. |
| Approval source | Decision Register owns approval for policy, app, permission, connector, external/client, mailbox, or automation posture. | Keeps approval separate from execution. | App consent, connectors, external sends, public Forms, sharing, permissions. |
| App posture | Do not reuse broad setup-helper grants as production bridge power. | Setup power and operating power must remain separate. | Production UAOS/M365 adapter until resting-state decision exists. |
| Copilot rollout | Pilot read-only retrieval and drafting only after records and access are reviewed. | Copilot quality and safety depend on clean records and permissions. | Broad Copilot/agent rollout, write-capable custom actions. |
| Connectors | Use SharePoint, Teams, Exchange, Planner, and Lists first. | Native M365 grounding is enough for the current workspace. | External connectors until ACL mapping and owner decisions are complete. |
| Support mailbox | Keep mailbox adapter work blocked until support MFA is complete. | The support identity is not ready for mailbox-dependent automation. | Support mailbox read/draft/send adapter. |
| Purview/DLP | Use plain-language sensitivity rules now; formal labels/DLP wait on license and policy decisions. | Business Standard limits advanced governance options. | Broad Copilot grounding, external/client data exposure. |
| Rollback | No app-based write permission before adapter-specific pause/revoke worksheet. | A capability that cannot be paused safely is not ready. | Selected permissions, Exchange RBAC, production adapter app. |

## Approval Pattern

| Level | Allowed by default | Required before action | Evidence |
|---|---|---|---|
| G0 Read Only | Yes. | Role-appropriate read access. | Optional action-log note when the review changes a decision or blocker. |
| G1 Propose And Log | Yes for safe internal suggestions. | Source record, owner, affected card, and no restricted action. | Agent Action Log row with status `Suggested`. |
| G2 Approved Internal Write | No. | Named human approval, action log entry, affected record link, and rollback note. | Agent Action Log plus target List/task/draft/evidence link. |
| G3 Restricted External Or Access Write | No. | Decision Register approval, typed approval phrase, evidence target, and rollback owner. | Decision Register, Agent Action Log, and read-back or transcript. |
| G4 Blocked Autonomous Action | Never autonomous. | Adam decision for a separate controlled project, if ever. | Decision Register only; do not execute from this chunk. |

## Required Agent Action Log Fields

Minimum fields for agent/AI readiness:

- action title;
- action date;
- actor or agent surface;
- source link;
- affected card or surface;
- governance level;
- action type;
- status;
- human owner;
- approver when approved;
- result;
- evidence link;
- rollback, pause, rejection, or superseded note.

Recommended statuses:

- `Suggested`
- `Needs Review`
- `Approved`
- `Executed`
- `Verified`
- `Rejected`
- `Superseded`
- `Failed`
- `Reverted`

Transition rules:

- Suggested is not approved.
- Approved is not executed.
- Executed is not verified.
- Failed or reverted actions need a cause and next owner.
- G2/G3 actions need rollback or pause notes before execution.

## Surface Decisions

| Surface | Current lane | Later lane | Stop condition |
|---|---|---|---|
| SharePoint pages, Lists, and libraries | Native M365 source of truth. | Selected permission adapter only after design approval. | Permission, sharing, retention, or deletion change. |
| Planner / Tasks | Supervised delegated first. | App-based task writes only after narrower posture is approved. | Calendar/deadline commitment or broad task-writing automation. |
| Exchange support mailbox | Manual/supervised only. | Exchange Application RBAC after support MFA and design approval. | Any external send, delegate/forwarding change, or mailbox adapter grant. |
| Teams | Manual coordination and read-only context. | Supervised internal posts after channel rules are approved. | Broad announcement, guest impact, or external-sensitive post. |
| Forms and intake routing | Internal/test or documented existing lanes. | Public/client Forms only after Decision Register approval. | Unauthenticated collection, sensitive data, or public link. |
| Entra apps and enterprise apps | Read/review only. | Purpose-built adapter app after production bridge decision. | App registration, app consent, broad delegated grant, or tenant policy change. |
| Copilot agents | Read-only/draft pilot after records/access review. | Custom actions only after action log and approval gates are proven. | Write action, connector, external data, or sensitive grounding question. |
| Copilot connectors | Not needed for MVP. | Add only for external systems with clear ACL mapping. | ACL uncertainty or external source owner not named. |
| Power Platform / Copilot Studio | Defer beyond SharePoint-native MVP. | Use when a card needs a better controlled front door or workflow. | Premium licensing, DLP, environment, or connector approval gap. |
| Custom integrations / UAOS bridge | Blocked for production. | Only after graduation gates are closed or deliberately accepted. | App posture, rollback, G0/G1 dry run, or production bridge decision missing. |

## Adam Decision Queue

| ID | Decision | Recommended default | Required before changing default |
|---|---|---|---|
| A6-01 | Stay supervised delegated or approve a production adapter path? | Stay supervised delegated. | Decision Register item with scope, owner, review date, blocked actions, and rollback path. |
| A6-02 | What is the resting state for broad setup-helper grants? | Time-box while build is active; reject as production bridge power. | App grant resting-state decision plus Tool Permission Review update. |
| A6-03 | Is Business Premium / Entra P1 worth adding now? | Keep Security Defaults until licensing path is chosen. | License decision, Conditional Access plan, script auth impact review. |
| A6-04 | When does support mailbox automation start? | Not before support MFA. | Verified MFA note and support mailbox adapter design. |
| A6-05 | Which Copilot use comes first? | Read-only internal retrieval and drafting. | Records/access review and pilot scope. |
| A6-06 | Which external sources need connectors? | None for MVP. | Source owner, ACL mapping, connector approval, and DLP review. |
| A6-07 | What is too sensitive for broad grounding? | Restricted Build Evidence, admin/security evidence, billing/legal, and client-sensitive records stay controlled. | Sensitivity model and access review. |
| A6-08 | Who can be a governance reviewer or controlled builder? | Adam only until delegated. | Role assignment, access scope, review cadence, first-day walkthrough. |
| A6-09 | What approval phrases exist beyond CRM? | None yet for non-CRM tenant writes. | Phrase, scope, stop conditions, and read-back target added to plan. |
| A6-10 | What rollback worksheet format should be used? | One worksheet per adapter lane. | Owner, revoke/pause path, evidence target, test plan. |
| A6-11 | Are public/client Forms allowed? | No. | Form purpose, audience, data collected, routing, owner, and Decision Register approval. |
| A6-12 | Are write-capable Copilot/custom actions allowed? | No. | Action log workflow proven, G2/G3 approval gates proven, rollback tested. |

## Acceptance Test

Chunk 6 is accepted when Adam can take a proposed AI/agent action and answer:

1. Is it G0, G1, G2, G3, or G4?
2. Which card owns the source record?
3. Which human owns the action?
4. What approval is required before anything writes, sends, grants, shares, or
   deletes?
5. Where will evidence be recorded?
6. What is the rollback, pause, rejection, or superseded note?
7. Which stop condition prevents execution today?

## Stop Conditions

Stop and ask Adam before proceeding if the next action requires live tenant
read-back, tenant write, app registration, app consent, Graph/SharePoint/
Exchange/Teams/Planner permissions, selected permission grants, mailbox
adapter work, external sends, guest access, sharing, public Forms, production
mail, deletes, billing/client commitments, Dynamics, Dataverse, premium Power
Platform, Copilot connector setup, custom actions, or unattended automation.
