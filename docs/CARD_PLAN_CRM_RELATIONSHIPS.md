# CRM / Relationships Card Plan

Date: 2026-06-19

Status: Active applied card-plan example. CRM recovery is closed in
`docs/CRM_EXECUTION_PLAN.md`. The current post-recovery add-on is the
`New Signal` Teams alert proof for the M365 Interaction Agent.

This is the first applied example of `docs/CARD_PLAN_TEMPLATE.md`. It validates
the template against the strongest current operating card and shows how future
card deep dives should separate operating usability from build history.

## Card Plan Header

Name: CRM / Relationships

Status: Active; CRM recovery closed, with alert proof pending.

Owner: Adam until a role-specific CRM owner is assigned.

Primary users:

- Guided AI Labs employee/operator
- trusted partner/operator with assigned CRM and delivery operating access
- Adam for approval, escalation, and controlled authority

Primary workflow:

Capture signals, qualify opportunities, record next actions, support proposal or
decision work, hand off delivery evidence, and watch closeout/invoice state.

Current live surface:

- Operations Cockpit CRM card
- CRM Command Center
- Open CRM Actions queue
- Qualification Triage queue

Plan status:

- Card plan: active applied example.
- Functional CRM recovery: closed in `docs/CRM_EXECUTION_PLAN.md`.
- New Signal Teams alert proof: pending in
  `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`.
- Acceptance tests: active in `docs/CRM_ACCEPTANCE_TESTS.md`.

Completion gate:

CRM is complete only when a role-appropriate person can sign in with MFA, open
the Operations Cockpit, open the CRM Command Center, create a New Signal in the
clean CRM path, see it in triage, identify next action and owner, and find the
proposal, evidence, handoff, closeout, and escalation paths without reading
Stage 8 build history.

Related docs:

- `docs/CRM_EXECUTION_PLAN.md`
- `docs/CRM_RECOVERY_PLAN.md`
- `docs/CRM_RUNBOOK.md`
- `docs/CRM_ACCEPTANCE_TESTS.md`
- `docs/CRM_UX_SPEC.md`
- `docs/CRM_DATA_MODEL.md`
- `docs/CRM_DECISIONS.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/COCKPIT_CARD_GAP_LIST.md`

## Purpose

The CRM / Relationships card helps a capable operator turn relationship signals
into governed work: intake, triage, qualification, proposal or decision, active
delivery, evidence, and closeout. It should feel like a business-development
and delivery operating surface, not a SharePoint administration map.

## Operator Promise

After receiving a Guided AI Labs login, MFA instructions, CRM operating access,
and the CRM runbook, a capable operator can open the CRM from the Operations
Cockpit, record a new relationship signal, assign or update the next action,
and know when to escalate access, client commitments, billing ambiguity,
automation, or governance decisions to Adam.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open CRM Command Center.
3. Review Triage Queue, Follow Up Today, Proposal / Decision Blockers, Active
   Delivery, and Closeout / Invoice Watch.
4. Capture new relationship signals in `CRM - New Signals`.
5. When the `New Signal` Teams alert proof is live, use the internal channel as
   the first-minute attention surface, then return to CRM for triage.
6. Update qualification, action, engagement, artifact, health, and closeout
   records as work moves.
7. Link evidence, proposal, decision, handoff, or closeout files in SharePoint
   or OneDrive.
8. Escalate anything outside role authority.

Do not use `Guided AI Labs - Intake Register/NewForm.aspx` for daily CRM work.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| New relationship signal arrives | CRM Command Center -> New Signal | Saved `CRM - New Signals` item visible in Triage Queue | Required access is missing, real client commitment is unclear, or the path opens legacy technical intake. |
| Follow-up is due today | CRM Command Center -> Follow Up Today or Open CRM Actions | Next action, owner, due date, and status are updated | The follow-up changes scope, promise, pricing, sharing, or automation posture. |
| Opportunity needs qualification | Triage Queue -> Qualification | Fit, decision, next action, and pursuit status are recorded | The operator cannot judge fit or needs Adam's approval. |
| Proposal or decision is blocked | Proposal / Decision Blockers | Blocker, owner, next step, and evidence link are visible | Scope, pricing, legal, or client-impacting commitment is ambiguous. |
| Work moves to delivery | Active Delivery or Delivery Control | Engagement, lifecycle, handoff, and evidence locations are linked | Delivery requires new external sharing, guest access, app consent, or permission changes. |
| Work is ready for closeout | Closeout / Invoice Watch | Final evidence, invoice handoff, payment follow-up, and closeout status are visible | Invoice status, payment follow-up, or final acceptance is unclear. |

## Surfaces

Pages:

- Operations Cockpit homepage
- `Relationship-CRM-Command-Center.aspx`
- Active Delivery page
- Client Discovery page

Lists:

- `CRM - New Signals`
- `CRM - Qualification`
- `CRM - Action Queue`
- `CRM - Meeting Notes`
- `CRM - Artifacts`
- `CRM - Health Reviews`
- `CRM - Closeout Invoice Queue`
- `CRM - Organizations`
- `CRM - Contacts`
- `CRM - Engagements`
- `CRM - Lifecycle Checklist`

Libraries:

- Client Handoff Packets
- Delivery Working Documents
- Readiness Evidence
- Restricted Build Evidence, when evidence is sensitive or build-related

Teams or channels:

- Guided AI Labs Team
- `New Signal`, pending alert proof
- Intake
- Client Discovery
- Active Delivery
- Agent Setup, only when CRM work touches AI/agent review

Mailboxes or aliases:

- `contact@guidedailabs.com` as a front-door signal source, subject to the
  current manual routing posture.
- `support@changeleadershiptools.com` remains a separate support/intake lane and
  still has a known MFA closeout item outside this CRM card plan.

Current cockpit link or queue:

- CRM card -> CRM Command Center
- `CRM - Action Queue / Open CRM Actions`
- `CRM - Qualification / Qualification Triage`

Reference-only or superseded surfaces:

- `Relationship-CRM.aspx`
- `Relationship-CRM-Operations.aspx`
- old Stage 8A/8B/8C/8D packet docs, unless a current `docs/CRM_*` file points
  to them as provenance

Admin-only or controlled surfaces:

- App Grants
- Tool Permission Review
- Agent Setup
- Automation Backlog
- External Sharing Rules
- permission, sharing, app consent, mailbox automation, public forms, deletes,
  Dynamics, Dataverse, and premium Power Platform decisions

## Ownership And Cadence

Human owner:

- Adam until delegated.

Backup owner:

- Adam until a CRM backup owner is explicitly delegated.

Review cadence:

- Daily for triage and follow-ups when CRM is actively used.
- Weekly for proposal/decision blockers, active delivery, health review, and
  closeout/invoice watch.

Evidence location:

- CRM records in the CRM lists.
- Proposal, delivery, handoff, and evidence files in SharePoint or OneDrive.
- Governance decisions in Decision Register.
- AI/agent suggestions and assisted actions in Agent Action Log.

## Access Model

Employee/operator access:

- Read and contribute to the CRM command center, CRM lists, and related delivery
  evidence needed for assigned work.
- Use business-facing views and forms only.
- Escalate before changing permissions, sharing, app grants, automation,
  production mail, public forms, deletes, or billing-sensitive records.

Trusted partner/operator full access:

- Full CRM and delivery operating access for the assigned role when deliberately
  granted.
- May work triage, qualification, action queues, delivery handoffs, and closeout
  records within scope.
- Does not include tenant/global admin authority, break-glass access, billing
  authority, security settings, app consent, destructive actions, or unrelated
  company records unless separately approved.

Admin-only authority:

- Tenant/global admin roles.
- Break-glass accounts.
- SharePoint owner/admin changes.
- App consent and app registrations.
- External sharing policy and guest invitations.
- Mailbox automation, public forms, deletion, Dynamics, Dataverse, and premium
  Power Platform dependencies.

Blocked access escalation:

- Escalate to Adam with the card, record, link, action needed, and business
  reason.

## Data Model

Required fields:

- `Title`
- `PersonName`
- `PersonEmail`
- `OrganizationName`
- `SignalType`
- `SignalStatus`
- `Priority`
- `NeedSummary`
- `NextAction`
- `FollowUpDueDate`

Useful fields:

- `SourceText`
- `RelatedLink`
- owner or assigned person field when present
- status and closeout fields on downstream CRM lists

Fields hidden from daily operators:

- `SourceMailbox`
- `SourceMessageId`
- `ReceivedDate`
- `IntakeStatus`
- `ItemOwner`
- `DurableHome`
- `PlannerTaskUrl`
- `CentralOSLink`
- `GraphNodeId`
- `AgentConfidence`

Required views:

- Triage Queue
- Follow Up Today
- Open CRM Actions
- Qualification Triage
- Proposal / Decision Blockers
- Active Delivery
- Closeout / Invoice Watch

Record and file ownership:

- CRM list items hold workflow state and next actions.
- SharePoint or OneDrive links hold files, proposals, scopes, evidence, and
  handoff packets.
- The CRM does not become the invoice ledger, accounting system, proposal
  generator, or central file system.

Data quality rules:

- Every active signal has a status, next action, owner, and due date.
- Files are linked, not pasted as unfindable notes.
- Client commitments, pricing, billing, external sharing, and AI/automation
  choices are escalated or recorded in the correct governance surface.

## Runbook

Start of day:

- Sign in with Guided AI Labs account and MFA.
- Open Operations Cockpit.
- Open CRM Command Center.
- Review Triage Queue, Follow Up Today, Proposal / Decision Blockers, Active
  Delivery, and Closeout / Invoice Watch.

Primary workflow:

- Capture new signals in `CRM - New Signals`.
- Triage each signal into qualify now, follow up later, nurture, close as not a
  fit, or escalate to Adam.
- Use qualification, meeting notes, actions, artifacts, engagements, health
  reviews, and closeout records to keep work moving.
- Link evidence and handoff files.

End of day:

- All new signals have a status.
- Urgent follow-ups have owners and due dates.
- Proposal or decision blockers are visible.
- Delivery handoffs have file links.
- Invoice or closeout items are not buried in notes.

Escalation:

- Escalate missing access, unclear client commitments, billing ambiguity, bad or
  duplicated data, external sharing, guest access, app consent, public forms,
  deletes, production mail automation, Dynamics, Dataverse, premium Power
  Platform, and unattended automation.

## Acceptance Standard

This card is not complete because the CRM lists and pages exist. It is complete
only when the browser path and runbook let a role-appropriate person complete a
safe internal CRM workflow and produce readable evidence without Stage 8 build
history.

## Agentic Opportunities

Read-only suggestions:

- Identify stale follow-ups, missing owners, missing due dates, duplicate
  relationship records, and closeout records needing attention.
- Summarize meeting notes and linked evidence for human review.

Draft generation:

- Draft follow-up notes, qualification summaries, proposal questions, handoff
  checklists, and closeout summaries for human approval.

Write-capable actions:

- First notification proof: create-only CRM signal -> internal Teams alert,
  with no CRM update and no external notification.
- Future write actions include creating next-action records, updating statuses,
  routing items to queues, or attaching evidence links after explicit approval
  gates are proven.

Required approval gate:

- Human approval before any CRM write-capable action.
- Decision Register entry before app consent, connector onboarding, external or
  client-impacting automation, permission changes, production mail automation,
  public forms, or unattended actions.

Required evidence:

- Agent Action Log entry for AI/agent suggestions and assisted actions.
- Decision Register entry when scope, policy, app consent, permissions, or
  external/client impact changes.
- Rollback note for write-capable actions.

## Completion Requirements

This card is complete only when:

- the CRM card is reachable from Operations Cockpit;
- CRM Command Center is the daily CRM door;
- daily CRM work uses `CRM - New Signals`, not legacy technical intake;
- visible CRM labels are business-facing;
- the primary workflow can be completed with role-appropriate access;
- owner, backup owner, review cadence, and evidence location are known;
- records, next actions, decisions, evidence, handoffs, and closeout state land
  in known places;
- trusted partner/operator full access is defined if needed;
- tenant/global admin authority remains separately controlled;
- acceptance evidence is recorded;
- future enhancements are separated from recovery blockers.

Current known blockers before completion:

- The `New Signal` Teams alert proof is not yet complete.
- Exact future employee/operator/trusted-partner access groups remain a
  read-back item before new grants.

## Acceptance Test

Given a capable employee, operator, or trusted partner with the right role:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open CRM Command Center.
4. Create a safe internal test record with prefix `GAIL-INTERNAL-WALKTHROUGH` in
   `CRM - New Signals`.
5. Confirm the saved signal appears in Triage Queue.
6. Identify next action, owner, due date, evidence, and escalation path.
7. Find proposal, delivery, handoff, and closeout/invoice places.
8. Confirm no daily path requires admin links, build history, technical forms,
   or `Guided AI Labs - Intake Register/NewForm.aspx`.

Evidence to record:

- test date;
- role used;
- test record title;
- verifier evidence or screenshots where available;
- friction points;
- remaining blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- the work requires permission, sharing, app consent, billing, public forms,
  production mail, deletes, Dynamics, Dataverse, premium Power Platform, or
  unattended automation;
- required live tenant state cannot be read;
- CRM exposes sensitive records to the wrong role;
- the clean CRM path still routes to legacy technical intake;
- the card cannot be made usable without changing the broader workspace
  information architecture.

## Template Validation Notes

The template fits the CRM card. The CRM example adds three standards that should
carry to the remaining card plans:

- every card needs an operator promise, not just a surface list;
- every card needs owner, cadence, and evidence location before completion;
- every card needs role access boundaries that separate full operating access
  from admin authority.
