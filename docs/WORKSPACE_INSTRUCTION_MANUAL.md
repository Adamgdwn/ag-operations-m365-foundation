# Guided AI Labs Workspace Instruction Manual

Date: 2026-06-19

Status: Operator handoff manual for the Guided AI Labs Microsoft 365 workspace.

Scope: daily use, first-day onboarding, operating-card routing, evidence
capture, and escalation. This manual does not approve tenant writes, access
grants, sharing changes, app consent, public Forms, mailbox automation, external
sends, billing decisions, deletes, or unattended automation.

## Who This Is For

Use this manual when onboarding or supporting:

- an employee/operator;
- a trusted partner/operator;
- a card specialist;
- a governance reviewer or controlled builder;
- Adam acting in the daily workspace owner role.

Do not use this manual as approval to give someone admin authority. "Full
access" means full operating access for the assigned role and cards. Tenant
admin authority, break-glass access, app consent, permission changes, and
sharing policy changes stay separate.

## Daily Front Door

Start here:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs
```

Daily homepage:

```text
Guided AI Labs Operations Cockpit
```

Current top cards:

- CRM
- Operations
- Tools
- Projects In Flight

Current embedded queues:

- Open CRM Actions
- Qualification Triage
- Attention Now
- Agent Action Log / Needs Review

Use the cockpit first. Do not start from old Stage 8 build packet docs, raw
SharePoint list forms, admin portals, or historical CRM reference pages unless a
current card plan sends you there.

## First-Day Setup

Before the person starts:

1. Confirm the person's role and access level.
2. Confirm the assigned operating cards.
3. Confirm the person has a Microsoft 365 work account and MFA.
4. Confirm no function mailbox is being used as the human working identity.
5. Confirm the person has the workspace link and Login Guide link.
6. Confirm Adam has approved the access scope and review date.
7. Read back exact live SharePoint groups and permission targets before any
   grant.

First-day walkthrough:

1. Sign in with the assigned account and MFA.
2. Open the Guided AI Labs workspace.
3. Confirm the Operations Cockpit opens.
4. Open the assigned card or queue.
5. Find the relevant card plan or runbook.
6. Use a harmless internal example to identify owner, next action, evidence,
   decision path, and escalation path.
7. Confirm the person can explain what they must not touch.
8. Record any missing access, confusing link, or overbroad access.
9. Set or confirm the access review date.

Do not use a real client commitment, billing decision, guest invite, external
sharing link, app grant, public form, or unattended automation as a first-day
test.

## Access Levels

| Level | Label | Use |
|---|---|---|
| A0 | No access | Inactive, unapproved, or function identities. |
| A1 | Orientation read | Read the cockpit, Login Guide, approved methods, and assigned instructions. |
| A2 | Card contributor | Update assigned card records, tasks, files, and queues. |
| A3 | Full operating access | Work across assigned cards with enough access to complete the workflow. |
| A4 | Controlled governance access | Review sensitive governance, app/tool, automation, and restricted evidence surfaces. |
| A5 | Workspace owner access | Site/group owner or broad workspace repair ability. |
| A6 | Tenant admin authority | Entra, SharePoint admin, app consent, tenant policy, and global configuration. |
| A7 | Break-glass | Emergency recovery only. |

Use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` before any access decision.

## Which Card To Use

| Work type | Start here | Use this when | Escalate when |
|---|---|---|---|
| Orientation | Workspace Home / Login Guide | A person needs to sign in, find the cockpit, or choose a card. | Sign-in, MFA, assigned-card access, or browser profile is wrong. |
| CRM / Relationships | CRM card -> CRM Command Center | Capture a signal, qualify an opportunity, record CRM actions, or find relationship history. | The work requires client commitment, pricing, external send, sharing, or CRM schema change. |
| Delivery / Projects | Projects In Flight | Track active work, delivery control, lifecycle checklist, handoff packets, or closeout prep. | The work needs client access, external sharing, scope decision, or go-live/offramp approval. |
| Decisions / Governance | Decision Register / Exceptions | Record approvals, risks, exceptions, app/sharing posture, or revisit dates. | A decision changes policy, access, app grants, sharing, billing, legal, or accepted risk. |
| Tasks / Actions | Open CRM Actions / Planner / owning list | Update assigned tasks, next actions, blockers, owners, and due dates. | A task has no source record or needs permission, client, billing, or automation authority. |
| Knowledge / Records | Published Methods / Readiness Evidence / Handoff Packets / Archive | Find official methods, reusable IP, handoff evidence, restricted build evidence, or archive locations. | A record is sensitive, stale, duplicated, misplaced, or exposed to the wrong audience. |
| Support / Intake | Operations card / Intake / Attention Now | Triage internal asks, support requests, feedback, or broad intake. | The item is really CRM, external support, public Forms, mailbox automation, or client-facing work. |
| Finance / Closeout | Projects In Flight / Handoff Packets / Closeout queue | Prepare evidence, closeout notes, invoice readiness, and payment-follow-up notes. | Billing, pricing, payment, legal, client acceptance, or accounting authority is needed. |
| Agent Control Plane | Tools / Agent Action Log / Tool Permission Review | Review AI suggestions, automation backlog, tool permissions, app grants, or rollback notes. | The action writes, sends, grants, shares, deletes, affects a client, or needs app consent. |
| Access / Onboarding | Login Guide / Access Model | Plan onboarding, access review, role classification, and escalation. | A grant, revoke, guest invite, role assignment, site owner change, or permission repair is needed. |

## CRM Daily Path

Use this path for relationship and opportunity work:

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

Do not send daily CRM operators to:

```text
Guided AI Labs - Intake Register/NewForm.aspx
```

That route is legacy technical intake, not the clean CRM front door.

## Daily Work Routine

Start of day:

1. Open the Operations Cockpit.
2. Check assigned queues.
3. Pick the owning card for each item.
4. Confirm owner, due date, status, source record, and next action.
5. Escalate anything outside your role before touching it.

During the day:

1. Update the record that owns the work.
2. Link tasks back to the source record.
3. Put evidence in the right library or register.
4. Record decisions in the Decision Register when a real decision is made.
5. Keep AI/agent suggestions in the Agent Action Log until approved.

End of day:

1. Make sure open items have an owner and next action.
2. Close or update stale tasks.
3. Link evidence or note what is missing.
4. Escalate blocked access, decisions, or risks.
5. Record friction from the workspace in the relevant card plan, onboarding
   note, or issue/gap register.

## Evidence Rules

Use the surface that owns the decision or action:

| Evidence type | Record it in |
|---|---|
| CRM workflow state | CRM records, action queue, qualification, artifacts, and health views. |
| Tasks and blockers | Owning list item, CRM Action Queue, Planner, or lifecycle checklist. |
| Decisions and approvals | Decision Register. |
| Temporary exceptions | Exception Register. |
| AI/agent suggestions and assisted actions | Agent Action Log. |
| App/tool permission posture | Tool Permission Review and Decision Register. |
| Handoff state | Handoff Packet Register or Client Handoff Packets. |
| Official methods and reusable IP | Published Methods. |
| Sensitive build or governance evidence | Restricted Build Evidence. |
| Readiness or proof evidence | Readiness Evidence. |
| First-day onboarding result | Access/onboarding notes or the assigned handoff record. |

Evidence must include the source link, owner, status, next action, and escalation
note when blocked.

## Escalation Format

Use this format when asking Adam for help or approval:

```text
Person:
Role:
Card:
Link or record:
Action needed:
Business reason:
Risk if granted:
Risk if blocked:
Needed by:
```

Escalate before proceeding when:

- access is missing, confusing, or broader than expected;
- a client commitment, scope, pricing, invoice, payment, or legal promise is
  unclear;
- work needs a permission change, guest invite, external share, public Form,
  production mail, app consent, connector, Power Platform, Dynamics, Dataverse,
  delete, or unattended automation;
- a record looks sensitive, stale, duplicated, misplaced, or exposed to the
  wrong audience;
- an AI/agent suggestion would write, send, grant, share, delete, affect a
  client, or change billing/delivery state.

## Do Not Touch Without Approval

Stop before any of these:

- Entra roles, admin roles, break-glass accounts, or site owners;
- SharePoint groups, site permissions, sharing policy, or guest invitations;
- anonymous links, broad external links, or public/client-facing Forms;
- app registrations, app consent, Graph scopes, SharePoint Selected
  permissions, Exchange Application RBAC, or connector setup;
- mailbox automation, external sends, production mail, or calendar commitments;
- billing, pricing, payment, legal, accounting, or client acceptance decisions;
- deletes, retention, sensitivity labels, DLP, Dynamics, Dataverse, premium
  Power Platform, or unattended automation;
- treating `contact@...`, `support@...`, or a setup-helper grant as a human or
  production agent identity.

## Agent And AI Review

Current active agent direction:

- One `M365 Interaction Agent` with governed capabilities.
- First proof: `CRM - New Signals` created -> internal Teams channel
  `New Signal`.
- New Signal, Journey, and B10a QUO local readiness are proven/readied in that
  order. B10b live QUO proof still needs exact source-proof approval and no
  outbound SMS/callback is enabled.

Default posture:

- G0: read only.
- G1: propose and log.
- G2: approved internal write only after named human approval and evidence.
- G3: restricted external or access write only after Decision Register approval,
  typed approval phrase, evidence, and rollback owner.
- G4: blocked autonomous action.

Every AI/agent action needs:

- source record;
- human owner;
- governance level;
- approval state;
- evidence link;
- result;
- rollback, pause, rejection, or superseded note when relevant.

Suggested is not approved. Approved is not executed. Completed is not proof
unless evidence links exist.

## Current Carry-Forwards

These do not block daily handoff, but they remain important:

- read back exact live SharePoint groups and permission groups before any new
  access grant;
- finish MFA for `support@changeleadershiptools.com` before support workflows
  depend on that identity;
- continue CRM-specific recovery from `docs/CRM_EXECUTION_PLAN.md` when CRM is
  selected;
- finish and prove the `New Signal` Teams alert before broader agent actions;
- keep broad delegated setup grants, app posture, permission scopes, rollback
  worksheet, and production bridge decisions under governance review;
- define a non-CRM tenant-writing approval phrase before any future write chunk.

## Quick Reference

| Need | Open |
|---|---|
| Current workspace source of truth | `START_HERE.md` |
| Full card plan map | `docs/CARD_PLAN_INDEX.md` |
| Access and onboarding model | `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` |
| Final usability closeout | `docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md` |
| CRM execution chunks | `docs/CRM_EXECUTION_PLAN.md` |
| CRM daily runbook | `docs/CRM_RUNBOOK.md` |
| Current agent plan | `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md` |
| New Signal alert setup | `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md` |
| Agentic readiness | `docs/AGENTIC_M365_READINESS.md` |
| Agentic decision list | `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md` |

The workspace is ready for operating handoff when the person can sign in, open
the cockpit, choose the right card, update only assigned work, find evidence,
and escalate anything outside their role.
