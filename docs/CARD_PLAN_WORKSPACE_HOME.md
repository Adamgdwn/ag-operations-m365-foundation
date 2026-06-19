# Workspace Home Card Plan

Date: 2026-06-19

Status: Active card plan. Chunk 7 closeout evidence is recorded in
`docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`.

## Card Plan Header

Name: Workspace Home

Owner: Adam until a workspace operations owner is delegated.

Primary users:

- employee/operator
- trusted partner/operator
- governance reviewer
- Adam

Primary workflow:

Open the Guided AI Labs Operations Cockpit, choose the correct operating card,
review the visible queues, and move into the assigned work surface without
needing build history.

Current live surface:

- Guided AI Labs Operations Cockpit homepage
- Start Here / Operations Portal navigation
- Login Guide
- embedded queues for CRM actions, qualification, intake, and agent review

Completion gate:

A role-appropriate person can sign in with MFA, reach the cockpit, explain which
card to open for common work, and identify escalation paths without using repo
docs, admin pages, or old Stage 8 packet material.

Related docs:

- `docs/START_HERE.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `M365_LOGIN_AND_ACCOUNT_GUIDE.md`

## Purpose

Workspace Home is the front door. It should orient the operator to the current
work, not explain how the tenant was built.

## Operator Promise

After receiving a login, MFA instructions, assigned role, and relevant card
runbook, a capable person can open the Guided AI Labs workspace, choose the
right card for CRM, intake, delivery, governance, tools, or handoff work, and
know when a request must go back to Adam.

## Daily Workflow

1. Sign in with the assigned account and MFA.
2. Open the Guided AI Labs workspace homepage.
3. Review the four top cards and visible queues.
4. Choose the assigned card for the work at hand.
5. Open the relevant runbook or card plan when unsure.
6. Escalate anything involving permissions, sharing, app grants, billing,
   external commitments, public forms, production mail, deletes, or unattended
   automation.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| First-day orientation | Login Guide -> Operations Cockpit | User can name assigned cards and forbidden admin actions | Sign-in, MFA, or assigned card access fails. |
| CRM follow-up | CRM card or Open CRM Actions queue | Operator opens CRM Command Center or queue | CRM path opens legacy technical intake or missing access. |
| Intake triage | Operations card or Attention Now queue | Operator opens intake/support plan and identifies lane | Item is really CRM, support, client commitment, or external send. |
| Delivery work | Projects In Flight card | Operator opens Active Delivery and lifecycle surfaces | Delivery requires client access, sharing, or scope decision. |
| Agent review | Agent Action Log / Needs Review or Tools card | Operator opens Agent Control Plane plan | Action would write, send, grant, delete, or affect a client. |

## Surfaces

Pages:

- Guided AI Labs Operations Cockpit
- Login And Account Guide
- CRM Command Center
- Intake
- Active Delivery
- Decisions

Lists and queues:

- `CRM - Action Queue / Open CRM Actions`
- `CRM - Qualification / Qualification Triage`
- `Guided AI Labs - Intake Register / Attention Now`
- `Agent Action Log / Needs Review`

Reference-only or superseded surfaces:

- older Relationship CRM and CRM Operations pages unless a current card plan
  points to them as reference
- Stage 8 build packet docs for daily users

Admin-only or controlled surfaces:

- Tool Permission Review
- App Grants
- Agent Setup
- External Sharing Rules
- Access Model owner/admin changes

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until another workspace operator is explicitly assigned.

Review cadence:

- Daily when the workspace is being used.
- Weekly during onboarding or card rollout.
- Before adding any new top-level card, queue, or public-facing path.

Evidence location:

- Card plans in `docs/`.
- Access decisions in the Decision Register when live access changes.
- Friction from walkthroughs in the final usability evidence.

## Access Model

Employee/operator access:

- A1 orientation read plus A2 contributor access only to assigned cards.

Trusted partner/operator full access:

- A3 across assigned cards when deliberately approved.

Admin-only authority:

- Homepage/navigation changes, site ownership, broad permissions, app consent,
  sharing posture, and public/client-facing page changes.

Blocked access escalation:

- Use the escalation format in `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`.

## Data Model

Required information on the home path:

- card name
- card purpose
- primary link
- owner or escalation point
- visible queue/source
- runbook link

Data quality rules:

- Daily card links should point to business-facing pages and views.
- Old build surfaces must remain reference-only.
- Admin-only links need controlled-role context before broad use.

## Runbook

Start of day:

- Open the Operations Cockpit.
- Check assigned queues before opening build or admin material.

Primary workflow:

- Choose CRM for relationships and opportunities.
- Choose Operations/Support for intake, support, and broad requests.
- Choose Projects In Flight for delivery, lifecycle, handoff, and closeout prep.
- Choose Tools only for assigned agent/governance review.
- Use card plans when the visible label is broader than the task.

End of day:

- Confirm open work has an owner, next action, and due date.
- Record unresolved confusion as a usability finding.

Escalation:

- Escalate missing access, overbroad access, unclear card routing, old technical
  links in the daily path, or any admin-only action.

## Acceptance Standard

Workspace Home is complete when the first five minutes of a new operator's day
are obvious: sign in, open cockpit, choose card, open queue, know what not to
touch, and know where to ask for help.

## Agentic Opportunities

Read-only suggestions:

- Summarize visible queue counts and stale items.
- Suggest the right card for a described task.

Draft generation:

- Draft first-day checklists and daily queue summaries.

Write-capable actions:

- Future only. Page/navigation updates require approval and read-back.

Required approval gate:

- Decision Register entry before homepage/navigation changes that alter role
  access, external/client paths, or agent/tool surfaces.

Required evidence:

- Agent Action Log entry for AI-assisted suggestions.
- Decision Register entry for page, navigation, role, or policy changes.
- Rollback note for write-capable page/navigation changes.

## Completion Requirements

This card is complete only when:

- the cockpit is reachable as the homepage;
- a role-appropriate person can choose the correct card for common work;
- old CRM/reference pages are not the daily path;
- admin-only surfaces are visibly controlled by runbook/context;
- assigned card plans are linked from the workspace routing docs;
- first-day acceptance evidence is recorded.

Chunk 7 closeout carry-forwards:

- Any desired cockpit text/link changes would be a future tenant-writing chunk.

Future enhancements:

- Add page-level card-plan links if Adam wants the cockpit itself to carry the
  runbook routing.
- Add a visible Knowledge / Records route if live onboarding shows records are
  too hidden.

## Acceptance Test

Given a capable employee, operator, or trusted partner with the right role:

1. Sign in with MFA.
2. Open the Guided AI Labs workspace homepage.
3. Name the card to use for CRM, support/intake, delivery, governance, records,
   agent review, access help, and closeout.
4. Open one assigned card and one assigned queue.
5. Identify owner, next action, evidence location, and escalation path.
6. Confirm no daily route depends on old Stage 8 build docs or admin-only
   settings pages.

Evidence to record:

- test date;
- role used;
- assigned cards;
- friction points;
- remaining blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- the home path requires a permission, sharing, page, navigation, guest,
  external link, app, public form, production mail, delete, or automation
  change;
- a daily card exposes admin authority to the wrong role;
- a new operator cannot distinguish operating access from admin authority.
