# Cockpit Card Gap List

Date: 2026-06-19

Status: Chunk 5 card plans added; remaining items are acceptance, live read-back,
or future tenant-change candidates.

Source inventory: `docs/COCKPIT_USABILITY_INVENTORY.md`.

## Summary

The Operations Cockpit is usable as a daily front door, but it is still a
compressed navigation surface. Four visible cards currently cover ten target
operating-card areas. The next usability work is not to add more technical
links; it is to make each card's purpose, owner, runbook, access model, and
acceptance test obvious.

## Highest Priority Gaps

| Gap | Category | Impact | Next action |
|---|---|---|---|
| Operations card is too broad | Needs cleanup | It mixes intake, decisions, agent review, and delivery signals. | Use `docs/CARD_PLAN_SUPPORT_INTAKE.md`, `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md`, and `docs/CARD_PLAN_TASKS_ACTIONS.md` during walkthrough. |
| Tools card exposes sensitive governance work | Admin-only / controlled | Tool permissions, app grants, and agent setup can imply authority a normal operator should not have. | Use `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`; do not expand use before readiness and approval gates. |
| Projects In Flight needs live acceptance | Active plan created | Delivery and closeout surfaces exist and now have runbooks, but browser/live-user proof is still pending. | Use `docs/CARD_PLAN_DELIVERY_PROJECTS.md` and `docs/CARD_PLAN_FINANCE_CLOSEOUT.md` in Chunk 7. |
| Knowledge / Records is present mostly through navigation, not a cockpit card | Active plan created; possible future UX cleanup | Records, methods, evidence, and archive locations exist but may not be obvious from the current top card set. | Use `docs/CARD_PLAN_KNOWLEDGE_RECORDS.md`; decide after walkthrough whether a visible records path is needed. |
| Access / Onboarding is scattered | Active access model created | Login Guide, Access Model, External Sharing Rules, and App Grants are separate surfaces without a single first-day page. | Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`; future live grants require exact permission read-back. |

## Card By Card Gaps

| Operating card | Current state | Gap | Recommended next chunk |
|---|---|---|---|
| Workspace Home | Cockpit is homepage and visible through Start Here / Operations Portal. | Plan exists; first-day browser proof is pending. | Use `docs/CARD_PLAN_WORKSPACE_HOME.md` during Chunk 7. |
| CRM / Relationships | Strongest current card. CRM Command Center, Open CRM Actions, and Qualification Triage are visible. | CRM recovery still needs its own config/script/operator acceptance chunks. | Continue through `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| Delivery / Projects | Projects In Flight points to Active Delivery and links delivery control, lifecycle checklist, handoff packets, and client discovery. | Plan exists; browser/live-user proof is pending. | Use `docs/CARD_PLAN_DELIVERY_PROJECTS.md` during Chunk 7. |
| Decisions / Governance | Decision Register and Exceptions exist; App Grants and External Sharing Rules exist. | Plan exists; approval boundaries still need to be proven in walkthrough. | Use `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md` and Chunk 4 access model. |
| Tasks / Actions | Open CRM Actions is visible; Planner/List task surfaces are implied by delivery and operating state docs. | Plan exists; source-of-truth routing needs walkthrough proof. | Use `docs/CARD_PLAN_TASKS_ACTIONS.md` during Chunk 7. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Client Handoff Packets, and Archive exist. | Plan exists; possible cockpit visibility gap remains. | Use `docs/CARD_PLAN_KNOWLEDGE_RECORDS.md` during Chunk 7. |
| Support / Intake | Operations card points to Intake and the Attention Now queue is embedded. | Plan exists; lane separation from clean CRM New Signal needs walkthrough proof. | Use `docs/CARD_PLAN_SUPPORT_INTAKE.md`; CRM-specific work remains in CRM plan. |
| Finance / Closeout | Handoff Packets and lifecycle/handoff surfaces exist; CRM plan names closeout invoice queue. | Plan exists; handoff/invoice readiness needs walkthrough proof. | Use `docs/CARD_PLAN_FINANCE_CLOSEOUT.md` during Chunk 7. |
| Agent Control Plane | Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, and App Grants are visible. | Plan exists; broad AI/agent expansion remains blocked until readiness gates mature. | Use `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md` and `docs/AGENTIC_M365_READINESS.md`; later Chunk 6. |
| Access / Onboarding | Login Guide, Access Model, External Sharing Rules, and App Grants exist. | Access model exists; exact live permission targets still need read-back before any grant. | Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` during Chunk 5 and final walkthrough. |

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

- Chunk 6 agentic readiness pass using the new Agent Control Plane plan.
- Chunk 7 final usability walkthrough using each active card plan.
- Access / Onboarding live permission read-back before any grant.

Possible future tenant changes, only after explicit approval:

- cockpit label changes;
- additional or renamed card links;
- page text updates that add role labels or owner/runbook links;
- navigation cleanup for duplicated or confusing paths.

## Acceptance Gate

Met. Every visible card, embedded queue, cockpit link, and known navigation link
from current local evidence is categorized as active, needs cleanup,
admin-only/controlled, superseded, or future.
