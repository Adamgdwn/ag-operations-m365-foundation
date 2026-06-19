# Cockpit Card Gap List

Date: 2026-06-18

Status: Chunk 2 local output.

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
| Operations card is too broad | Needs cleanup | It mixes intake, decisions, agent review, and delivery signals. | Split its meaning in the card plan: Support / Intake, Decisions / Governance, and Tasks / Actions. |
| Tools card exposes sensitive governance work | Admin-only / controlled | Tool permissions, app grants, and agent setup can imply authority a normal operator should not have. | Define role labels, approval gates, and human owners before expanding use. |
| Projects In Flight lacks a card runbook | Active but incomplete | Delivery and closeout surfaces exist, but the primary workflow is not yet documented for a new operator. | Create Delivery / Projects card plan from `docs/CARD_PLAN_TEMPLATE.md`. |
| Knowledge / Records is present mostly through navigation, not a cockpit card | Future / needs card plan | Records, methods, evidence, and archive locations exist but are not yet obvious from the cockpit card set. | Create Knowledge / Records card plan and decide whether cockpit needs a visible records path. |
| Access / Onboarding is scattered | Needs cleanup | Login Guide, Access Model, External Sharing Rules, and App Grants are separate surfaces without a single first-day path. | Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`; future live grants require exact permission read-back. |

## Card By Card Gaps

| Operating card | Current state | Gap | Recommended next chunk |
|---|---|---|---|
| Workspace Home | Cockpit is homepage and visible through Start Here / Operations Portal. | Needs a plain operator-facing explanation of which card to open for common work. | Chunk 5 card deep dive or final walkthrough. |
| CRM / Relationships | Strongest current card. CRM Command Center, Open CRM Actions, and Qualification Triage are visible. | CRM recovery still needs its own config/script/operator acceptance chunks. | Continue through `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| Delivery / Projects | Projects In Flight points to Active Delivery and links delivery control, lifecycle checklist, handoff packets, and client discovery. | Needs purpose, owner, runbook, closeout handoff, and acceptance test. | Chunk 5 card deep dive. |
| Decisions / Governance | Decision Register and Exceptions exist; App Grants and External Sharing Rules exist. | Governance links are split across Operations, Tools, and navigation. Approval boundaries need operator/admin separation. | Chunk 5 card deep dive using the Chunk 4 access model. |
| Tasks / Actions | Open CRM Actions is visible; Planner/List task surfaces are implied by delivery and operating state docs. | Source of truth for non-CRM tasks is not obvious from the cockpit. | Chunk 5 card deep dive. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Client Handoff Packets, and Archive exist. | No visible top cockpit card dedicated to records/search/evidence. | Chunk 5 card deep dive. |
| Support / Intake | Operations card points to Intake and the Attention Now queue is embedded. | Intake is broad and must not be confused with the clean CRM New Signal path. | Chunk 5 card deep dive; CRM-specific work remains in CRM plan. |
| Finance / Closeout | Handoff Packets and lifecycle/handoff surfaces exist; CRM plan names closeout invoice queue. | Closeout/invoice workflow is not yet obvious from the cockpit. | CRM recovery and Finance / Closeout card deep dive. |
| Agent Control Plane | Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, and App Grants are visible. | Needs governed operating rules before broad AI/agent use. | Use `docs/AGENTIC_M365_READINESS.md`; later Chunk 6. |
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

- Delivery / Projects card plan.
- Decisions / Governance card plan.
- Knowledge / Records card plan.
- Support / Intake card plan.
- Agent Control Plane operating rules.
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
