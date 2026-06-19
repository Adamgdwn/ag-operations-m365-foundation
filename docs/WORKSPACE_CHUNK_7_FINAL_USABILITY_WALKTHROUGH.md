# Workspace Chunk 7 Final Usability Walkthrough

Date: 2026-06-19

Status: Chunk 7 closeout evidence for the workspace usability pass.

Scope: documentation, local evidence review, and existing production read-back
evidence. This closeout does not connect to Microsoft 365, change tenant
settings, grant access, share externally, send mail, approve app consent, or run
unattended automation.

## Acceptance Verdict

Chunk 7 is accepted for workspace handoff.

Adam can hand a capable employee, operator, or trusted partner:

- the Microsoft 365 login and MFA instructions;
- the Guided AI Labs workspace and cockpit links;
- a role classification and access level from the access model;
- the relevant card plan or runbook;
- escalation rules for access, client commitments, billing, records,
  governance, and AI/agent action.

The person can operate from the current workspace source of truth without
reading build-history docs. Remaining items are now future improvements,
card-specific execution, live access read-back before grants, or explicitly
approval-gated tenant changes.

## Evidence Base

This walkthrough uses these current artifacts:

- `docs/START_HERE.md`
- `docs/WORKSPACE_EXECUTION_PLAN.md`
- `docs/CARD_PLAN_INDEX.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`
- all active card plans in `docs/CARD_PLAN_*.md`
- `docs/AGENTIC_M365_READINESS.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`
- `inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260617-144536.md`
- `inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md`
- `inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-readback-20260617-121052.csv`
- `inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_LOCAL_PREFLIGHT.md`

The Stage 8D production read-back proves the CRM-to-delivery spine with seven
passing internal proof rows:

- open daily cockpit proof logged in Agent Action Log;
- internal intake signal;
- qualification row;
- CRM engagement spine;
- CRM action queue item;
- lifecycle checklist item;
- handoff evidence artifact.

No new live browser write was performed for Chunk 7. The first live onboarding
of another human should still capture friction as normal operating evidence, but
it is not a blocker to closing the workspace usability pass.

## First-Day Scenario

Role used for the walkthrough:

- capable trusted partner/operator or senior employee/operator;
- A1 orientation access plus A2/A3 operating access for assigned cards;
- A4 controlled governance review only when deliberately assigned;
- no tenant admin authority, no app consent, no broad permission repair, no
  guest invite authority, and no billing/legal/client commitment authority.

Safe scenario:

1. Sign in with assigned work account and MFA.
2. Open the Guided AI Labs workspace homepage.
3. Use the Operations Cockpit as the daily front door.
4. Pick the right card for CRM, support/intake, delivery, governance, tasks,
   records, closeout, agent review, and access help.
5. Use a harmless internal example or existing read-back proof to identify the
   source record, next action, decision/evidence path, owner, and escalation.
6. Stop before any tenant write, permission change, guest/sharing action,
   public form, external send, app consent, production mail, delete, billing
   decision, client commitment, or unattended automation.

## Walkthrough Results

| Operating card | Route from cockpit | Primary proof | Outcome | Remaining work |
|---|---|---|---|---|
| Workspace Home | Guided AI Labs workspace homepage / Operations Cockpit | Current cockpit evidence and Workspace Home card plan | Pass | Future cockpit text/link cleanup only if a live operator finds friction. |
| CRM / Relationships | CRM card -> CRM Command Center -> CRM queues | Stage 8D production read-back rows for intake, qualification, engagement, action, lifecycle, and artifact | Pass | Continue CRM-specific recovery chunks when CRM is selected. |
| Delivery / Projects | Projects In Flight -> Active Delivery / Lifecycle Checklist / Handoff Packets | Lifecycle checklist and handoff evidence read-back rows plus Delivery card plan | Pass | Future delivery dashboard or handoff view only if volume warrants it. |
| Decisions / Governance | Operations/Decisions -> Decision Register / Exceptions / App Grants governance | Decisions card plan, access model, and agentic decision list | Pass | No false decision row was created during the proof; real decisions remain Adam-owned or approval-gated. |
| Tasks / Actions | Open CRM Actions, Attention Now, Planner/List task surfaces | CRM action queue proof row plus task source-of-truth rules | Pass | Exact Planner/list permission groups require read-back before granting another operator. |
| Knowledge / Records | Records and Evidence nav, Handoff Packets, Readiness Evidence, Restricted Build Evidence, Archive | Knowledge card plan and Stage 8D artifact/handoff proof | Pass with future UX watch | Add a visible cockpit route only if first live onboarding shows records are too hidden. |
| Support / Intake | Operations card -> Intake / Attention Now / support register routes | Intake proof row and Support / Intake card plan | Pass with identity blocker carried forward | `support@changeleadershiptools.com` MFA remains required before support mailbox operations depend on that identity. |
| Finance / Closeout | Projects In Flight -> Handoff Packets / closeout and invoice queue routes | Handoff evidence proof plus Finance / Closeout card plan | Pass with authority boundary | Adam retains billing, pricing, payment, legal, and client acceptance authority. |
| Agent Control Plane | Tools card / Agent Action Log Needs Review / Tool Permission Review / Automation Backlog | Agent Control Plane card plan, Chunk 6 readiness verdict, and G0-G4 approval pattern | Pass for supervised review | App registrations, consent, connectors, external sends, and unattended agents remain blocked until approved. |
| Access / Onboarding | Login Guide / Access Model / External Sharing Rules / App Grants | Access model, first-day walkthrough instructions, and escalation rules | Pass for handoff model | Exact live SharePoint group and permission targets must be read back before any grant. |

## Remaining Gaps

| ID | Gap | Type | Owner | Closeout disposition |
|---|---|---|---|---|
| G7-01 | Exact live SharePoint groups and permission groups must be read back before future grants. | Access safety | Adam/admin | Stop-gated future read-back; not a Chunk 7 blocker. |
| G7-02 | `support@changeleadershiptools.com` still needs MFA before support workflows depend on it. | Identity/support readiness | Adam/admin | Carry forward to support/security closeout. |
| G7-03 | Operations card is broad and mixes intake, decisions, agent review, and delivery signals. | UX cleanup | Adam/delegated workspace owner | Future cockpit copy/link cleanup if a live operator is confused. |
| G7-04 | Tools card exposes controlled governance surfaces and must not imply normal operator authority. | Governance clarity | Adam/governance reviewer | Covered by card plan; future page labels may improve clarity. |
| G7-05 | Knowledge / Records is present through navigation more than a top cockpit card. | UX watch | Adam/delegated workspace owner | Future visible route only if first onboarding needs it. |
| G7-06 | CRM recovery has its own remaining execution chunks. | Card-specific execution | Adam | Continue from `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| G7-07 | Broad delegated setup grants, app posture, permission scopes, and rollback worksheet remain open. | Agent/control readiness | Adam/governance reviewer | Carry forward under Chunk 6 decision queue and Stage 9 readiness controls. |
| G7-08 | No non-CRM tenant-writing approval phrase is defined. | Governance safety | Adam | Future write chunks must define phrase, scope, evidence, and rollback first. |

## Stop Conditions Carried Forward

Stop and ask Adam before proceeding if work requires:

- live access grants or revokes;
- exact permission changes, site owner changes, or SharePoint group changes;
- guest invitations or external sharing;
- app registrations, app consent, connector setup, Graph scopes, SharePoint
  Selected permissions, or Exchange Application RBAC;
- public Forms, mailbox automation, production mail, or external sends;
- billing, pricing, payment, legal, accounting, or client acceptance decisions;
- deletes, retention changes, sensitivity labels, DLP, Dynamics, Dataverse,
  premium Power Platform, or unattended automation;
- treating a function mailbox or setup-helper grant as a human or production
  agent identity.

## Sanity Checks

Functional sanity checks for this closeout:

1. Required active docs exist.
2. Every target operating card has an active plan or active model.
3. Every active card plan has an acceptance test and stop conditions.
4. Stage 8D production read-back has seven passing proof rows.
5. New Chunk 7 closeout sections exist for evidence, scenario, walkthrough
   results, gaps, stop conditions, and acceptance.
6. Routing docs no longer present Chunk 7 as pending next work.
7. No tenant write command is run.

Automated local check:

- `scripts/Test-WorkspaceChunk7Closeout.ps1`

Generated local report:

- `inventory/workspace-usability-chunk-7/WORKSPACE_CHUNK_7_CLOSEOUT_PREFLIGHT.md`

## Closeout Note

The workspace usability pass is now complete for operating handoff. The current
front door is the Operations Cockpit, the current routing source is
`docs/START_HERE.md`, the current card map is `docs/CARD_PLAN_INDEX.md`, and
the current role/access model is `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`.

Next work should be selected as a card-specific or controlled-governance chunk,
not another broad usability chunk. Good next candidates are CRM execution,
access read-back before a real onboarding grant, support MFA closeout, or a
future cockpit-label cleanup with an explicit tenant-write approval phrase.
