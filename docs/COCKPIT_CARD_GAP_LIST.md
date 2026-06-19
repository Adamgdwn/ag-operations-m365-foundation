# Cockpit Card Gap List

Date: 2026-06-19

Status: Chunk 7 final usability walkthrough complete; remaining items are live
read-back before grants, card-specific execution, or future tenant-change
candidates.

Source inventory: `docs/COCKPIT_USABILITY_INVENTORY.md`.

## Summary

The Operations Cockpit is usable as a daily front door, but it is still a
compressed navigation surface. Four visible cards currently cover ten target
operating-card areas. Chunk 7 closed the handoff evidence; future work should be
card-specific execution, live access read-back, or carefully scoped cockpit
cleanup.

## Highest Priority Gaps

| Gap | Category | Impact | Next action |
|---|---|---|---|
| Operations card is too broad | Needs cleanup | It mixes intake, decisions, agent review, and delivery signals. | Use `docs/CARD_PLAN_SUPPORT_INTAKE.md`, `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md`, and `docs/CARD_PLAN_TASKS_ACTIONS.md` for future cleanup. |
| Tools card exposes sensitive governance work | Admin-only / controlled | Tool permissions, app grants, and agent setup can imply authority a normal operator should not have. | Use `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`, `docs/AGENTIC_M365_READINESS.md`, and `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`; do not expand use before listed decisions and approval gates. |
| Projects In Flight needs live acceptance | Closed for broad usability; watch during live onboarding | Delivery and closeout surfaces exist, have runbooks, and are covered by Chunk 7 closeout evidence. | Continue only as delivery-specific execution or future dashboard cleanup. |
| Knowledge / Records is present mostly through navigation, not a cockpit card | Future UX watch | Records, methods, evidence, and archive locations exist but may not be obvious from the current top card set. | Add a visible records path only if live onboarding shows confusion. |
| Access / Onboarding is scattered | Active access model created | Login Guide, Access Model, External Sharing Rules, and App Grants are separate surfaces without a single first-day page. | Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`; future live grants require exact permission read-back. |

## Card By Card Gaps

| Operating card | Current state | Gap | Recommended next action |
|---|---|---|---|
| Workspace Home | Cockpit is homepage and visible through Start Here / Operations Portal. | Chunk 7 closeout evidence exists. | Use `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md` for handoff evidence. |
| CRM / Relationships | Strongest current card. CRM Command Center, Open CRM Actions, and Qualification Triage are visible. | CRM recovery still needs its own config/script/operator acceptance chunks. | Continue through `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| Delivery / Projects | Projects In Flight points to Active Delivery and links delivery control, lifecycle checklist, handoff packets, and client discovery. | Broad usability proof is complete. | Continue with delivery-specific execution only when selected. |
| Decisions / Governance | Decision Register and Exceptions exist; App Grants and External Sharing Rules exist. | Approval boundaries are documented and covered by Chunk 7 closeout. | Use `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md` and Chunk 4 access model. |
| Tasks / Actions | Open CRM Actions is visible; Planner/List task surfaces are implied by delivery and operating state docs. | Source-of-truth routing is documented and covered by Chunk 7 closeout. | Read back exact task/list permission targets before new grants. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Client Handoff Packets, and Archive exist. | Possible cockpit visibility gap remains. | Add a visible records path only if live onboarding shows confusion. |
| Support / Intake | Operations card points to Intake and the Attention Now queue is embedded. | Lane separation is covered by Chunk 7; support MFA remains a carry-forward. | Use `docs/CARD_PLAN_SUPPORT_INTAKE.md`; CRM-specific work remains in CRM plan. |
| Finance / Closeout | Handoff Packets and lifecycle/handoff surfaces exist; CRM plan names closeout invoice queue. | Broad usability proof is complete; authority boundary remains. | Keep billing, payment, legal, and client acceptance authority with Adam. |
| Agent Control Plane | Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, and App Grants are visible. | Plan, Chunk 6 readiness decisions, and Chunk 7 closeout evidence exist; broad AI/agent expansion remains blocked until readiness gates mature. | Use `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`, `docs/AGENTIC_M365_READINESS.md`, and `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md` for future agent-control work. |
| Access / Onboarding | Login Guide, Access Model, External Sharing Rules, and App Grants exist. | Access model exists; exact live permission targets still need read-back before any grant. | Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` and Chunk 7 closeout evidence. |

## Cleanup Candidates

| Surface | Cleanup type | Recommendation |
|---|---|---|
| Operations card | Label/workflow clarity | Keep as a general operations doorway only if child paths clearly say Intake, Decisions, Actions, and Agent Review. |
| Tools card | Access clarity | Add or document "controlled governance" intent for app grants, tool permissions, and agent setup. |
| Agent Action Review under Operations | Duplicate mapping | Decide whether it remains a quick queue on the homepage or belongs only under Agent Control Plane. |
| Client Discovery | Ownership split | Decide whether it is Support / Intake, Delivery / Projects, or both with a clear handoff rule. |
| Handoff Packets | Closeout clarity | Tie to Finance / Closeout and Knowledge / Records runbooks. |
| App Grants | Admin-only clarity | Keep as governance surface; do not treat it as a live agent/tool connection. |
| Methods and IP nav | Records clarity | Bring into Knowledge / Records card plan before calling it operator-ready. |
| Archive nav | Governance clarity | Define archive owner, retention posture, and what a normal operator may move. |

## Tenant Change Assessment

No tenant changes are required to complete Chunk 2.

Likely documentation/runbook-only next work:

- Access / Onboarding live permission read-back before any grant.
- Card-specific execution or refinement when Adam selects a card.

Possible future tenant changes, only after explicit approval:

- cockpit label changes;
- additional or renamed card links;
- page text updates that add role labels or owner/runbook links;
- navigation cleanup for duplicated or confusing paths.

## Acceptance Gate

Met. Every visible card, embedded queue, cockpit link, and known navigation link
from current local evidence is categorized as active, needs cleanup,
admin-only/controlled, superseded, or future.
