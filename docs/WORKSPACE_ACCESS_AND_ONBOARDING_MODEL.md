# Workspace Access And Onboarding Model

Date: 2026-06-19

Status: Chunk 4 output for the workspace usability pass.

This document defines role-appropriate operating access across the Guided AI
Labs workspace. It is the source of truth for the phrase "full access" in the
workspace usability pass.

## Core Rule

"Full access" means full operating access for the assigned role and card scope.
It does not mean tenant/global admin authority, break-glass access, app consent,
security settings, billing authority, destructive authority, or permission
administration.

Operating access lets a person do assigned work. Admin authority changes the
tenant, security posture, sharing posture, app posture, or underlying access
model. Keep those separate even when the same human currently holds both.

## Scope And Boundary

This Chunk 4 output is documentation-only. It does not read from or write to the
live Microsoft 365 tenant.

No access grant is approved by this document. Before any live access change,
Adam must decide the person, role, card scope, duration, exact groups or
permissions, and approval phrase for the write window.

Current evidence used:

- `M365_STAGE_2_IDENTITY_FOUNDATION.md`
- `IDENTITY_NAMING_STANDARD.md`
- `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md`
- `inventory/stage-7-security-governance/20260614-193825/stage-7-security-inventory-summary.md`
- `inventory/access-repair/SHAREPOINT_OWNER_ACCESS_ALL_SITES_20260615-152220.md`
- `inventory/access-repair/M365_GROUP_OWNER_REPAIR_20260615-152034.md`
- `M365_LOGIN_AND_ACCOUNT_GUIDE.md`
- `inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`
- `docs/START_HERE.md`
- `docs/COCKPIT_USABILITY_INVENTORY.md`
- `docs/CARD_PLAN_INDEX.md`
- `docs/CARD_PLAN_CRM_RELATIONSHIPS.md`

## Current Verified Posture

Current identity and access facts from saved evidence:

- The Guided AI Labs Microsoft 365 group exists as a private group:
  `GuidedAILabs@agoperations.ca`.
- Owner-level SharePoint access was granted and read-back verified for
  `adamgoodwin@guidedailabs.com` and `admin@agoperations.ca` across the targeted
  SharePoint sites.
- Current Global Administrators are `adamgoodwin@guidedailabs.com`,
  `admin@agoperations.ca`, `breakglass-01@AGOperationsLtd.onmicrosoft.com`, and
  `breakglass-02@AGOperationsLtd.onmicrosoft.com`.
- `contact@guidedailabs.com` and
  `support@changeleadershiptools.com` hold no admin roles in the Stage 7
  read-back.
- Security Defaults are enabled.
- Business Standard is present; Business Premium / Entra P1 was not detected in
  the Stage 7 read-back.
- Guest users were not present in the Stage 7 read-back.
- Guest invitations are restricted to admins and Guest Inviters.
- SharePoint tenant sharing is `ExternalUserSharingOnly`, default sharing links
  are `Direct`, and core operating sites have external sharing disabled.
- Broad delegated setup grants were flagged and remain a separate governance
  review item.
- `support@changeleadershiptools.com` still needs an Authenticator/MFA method
  before support operations depend on that identity.

## Role Definitions

| Role | Meaning | Typical access | Explicitly not included |
|---|---|---|---|
| Workspace owner / Adam | Human owner, final approval point, and current daily operator. | Full operating access across cards; decision authority for scope, billing, sharing, app grants, and agent posture. | This role does not turn every helper into an admin; Adam's daily Global Admin posture is an accepted solo-operator risk, not the default role pattern. |
| Employee / operator | Licensed internal user doing assigned Guided AI Labs work. | MFA, Guided AI Labs workspace access, Teams/SharePoint/List/Planner access for assigned cards, contribute rights where needed. | Tenant admin roles, app consent, security settings, broad sharing, guest invites, billing authority, deletes, or unrelated records. |
| Trusted partner / operator | Deliberately approved partner or senior collaborator with broader operating access across assigned work. | Full operating access across the assigned cards, including CRM/delivery/support/records needed to work without friction. | Tenant/global admin, break-glass, app consent, security settings, billing authority, public Forms, guest/sharing policy, broad automation grants, unrelated company records. |
| Card specialist | Employee or trusted partner scoped to one card or workflow. | Contribute access to that card's pages, lists, libraries, queues, and evidence locations. | Cross-card access unless assigned; admin authority; permission changes. |
| Governance reviewer / controlled builder | Person reviewing automation, app grants, evidence, methods, access, or exceptions. | Read or contribute access to controlled governance records, Restricted Build Evidence, Tool Permission Review, Automation Backlog, Exception Register, and Decision Register as assigned. | Standing tenant admin or app consent unless separately approved for a specific write window. |
| Admin authority | Deliberate tenant administration using approved admin accounts. | Entra roles, SharePoint admin, tenant policy, site owner/admin repair, app consent, security settings, guest/sharing controls. | Daily operating work unless the same human intentionally switches back to the daily role. |
| Break-glass authority | Emergency-only recovery accounts. | Global Administrator only for lockout or emergency recovery. | Daily work, setup convenience, routine troubleshooting, agent work, browsing, email, or partner support. |
| Function/front-door identity | Mailbox or role address such as `contact@...` or `support@...`. | Receive or route signals when approved. | Human operating role, admin roles, app capability surface, or unattended automation power by itself. |
| Agent/service identity | Future app registration or scoped service identity. | Least-privilege capability after Decision Register approval, app review, evidence, and rollback path. | Human login, broad setup helper reuse, unreviewed app consent, or combining intake mailbox power with capability power. |

## Access Levels

| Level | Label | What it allows | Used for |
|---|---|---|---|
| A0 | No access | No workspace access. | Function accounts, inactive people, unapproved guests. |
| A1 | Orientation read | Read Login Guide, Operations Cockpit, approved methods, and assigned instructions. | First-day orientation, narrow reviewers. |
| A2 | Card contributor | Read and update assigned card records, tasks, files, and queues. | Employee/operator, card specialist. |
| A3 | Full operating access | Work across assigned cards with create/update rights and enough records access to complete the workflow. | Trusted partner/operator or senior employee/operator. |
| A4 | Controlled governance access | Review or contribute to sensitive governance/build surfaces. | Governance reviewer, controlled builder. |
| A5 | Workspace owner access | Site/group owner or broad workspace repair ability. | Adam and admin-controlled repair path. |
| A6 | Tenant admin authority | Entra, SharePoint admin, app consent, tenant policy, and global configuration. | Admin accounts only, deliberate write windows. |
| A7 | Break-glass | Emergency tenant recovery. | Break-glass accounts only. |

## Operating Card Access Matrix

This matrix defines the minimum role decision before Adam grants access.

| Operating card | Employee/operator | Trusted partner/operator | Governance/builder access | Admin-only authority |
|---|---|---|---|---|
| Workspace Home | A1 read plus links to assigned cards. | A1 or A3 across assigned cards. | May update orientation/runbook content only when assigned. | Homepage, navigation, site ownership, and broad permission changes. |
| CRM / Relationships | A2 for assigned CRM work: new signals, triage, qualification, action queue, meeting notes, artifacts, handoff links. | A3 for full CRM and related delivery operating access when deliberately granted. | May review CRM data model, UX, acceptance evidence, or hidden-field rules when assigned. | Permission changes, external sharing, app consent, mailbox automation, public Forms, Dynamics, Dataverse, deletes. |
| Delivery / Projects | A2 for assigned delivery records, lifecycle checklist, delivery files, and handoff drafts. | A3 for active delivery, handoff packets, and closeout prep within scope. | May review lifecycle, evidence, and handoff standards. | Client guest invites, external sharing, client tenant commitments, site/library permissions. |
| Decisions / Governance | A2 to record routine decisions, blockers, and escalation notes within authority. | A3 to record and maintain decisions within assigned work. | A4 to review exceptions, app grants, sharing rules, and governance evidence. | Tenant policy, app consent, admin roles, security settings, accepted-risk decisions. |
| Tasks / Actions | A2 for assigned Planner/List tasks, due dates, blockers, and status updates. | A3 for cross-card work queues in assigned scope. | May review task source-of-truth rules. | Planner/Team ownership, permission repair, automation that writes tasks. |
| Knowledge / Records | A1 read for approved methods; A2 contribute to assigned evidence and working files. | A3 for assigned methods, evidence, and handoff records. | A4 for Restricted Build Evidence, reusable IP publication, archive rules, and sensitive evidence review. | Retention, broad library permissions, record deletion, publishing sensitive methods/IP. |
| Support / Intake | A2 for triage, internal support asks, feedback, and intake records within scope. | A3 for assigned support/intake lanes. | May review routing, forms, and support model. | Public/client Forms, guest access, mailbox automation, external sends, support identity changes. |
| Finance / Closeout | A2 to prepare closeout evidence, handoff state, and invoice-readiness notes. | A3 to help prepare closeout and payment-follow-up evidence within scope. | May review closeout standards and evidence. | Billing authority, payment decisions, legal commitments, accounting records, external client commitments. |
| Agent Control Plane | A1/A2 for read, propose, and log-only agent/action review. | A3 for supervised review and draft workflows only when assigned. | A4 for Tool Permission Review, Automation Backlog, App Grants posture, Restricted Build Evidence. | App registrations, app consent, broad Graph permissions, write-capable agents, unattended automation, rollback/pause controls. |
| Access / Onboarding | A1 read of Login Guide and role instructions. | A1 read plus assigned onboarding checklist. | A4 to review access requests and exceptions when assigned. | Grants, revokes, guest invites, role assignments, site owner changes, break-glass, admin accounts. |

## Admin-Only Authority

The following remain controlled admin actions even when a person has full
operating access:

- assign or remove Entra roles;
- use break-glass accounts;
- add or remove site collection admins, SharePoint owners, or Microsoft 365
  group owners;
- invite guests or widen external sharing;
- create anonymous, public, or broad external links;
- approve app consent or app registrations;
- grant Microsoft Graph, SharePoint, Exchange, Teams, Planner, or Power Platform
  permissions;
- change Security Defaults, Conditional Access, tenant policy, audit, labels, or
  retention;
- change mailbox routing, mailbox automation, public Forms, external sends, or
  calendar commitments;
- create or run write-capable agents, unattended automation, connector actions,
  or client-impacting integrations;
- delete records, libraries, lists, sites, users, groups, apps, or evidence;
- approve billing, payment, pricing, legal, or client scope commitments.

## Standard Grant Path

Use this sequence before adding a person or expanding access.

1. Identify the person and account type: internal employee, trusted partner,
   external guest, client collaborator, function mailbox, or service/app identity.
2. Confirm the business reason, card scope, expected duration, owner, and backup
   owner.
3. Choose the access level from A0-A7.
4. Confirm MFA is ready before active work starts.
5. For internal users, decide whether membership in the private Guided AI Labs
   Microsoft 365 group is appropriate.
6. For external collaborators, stop for a Decision Register entry before any
   guest invite or sharing change.
7. Read back the live target groups/site permissions before making the grant.
   Do not guess exact SharePoint group names from memory.
8. Grant only the minimum role needed for the assigned cards.
9. Record the grant decision, owner, review date, and evidence location.
10. Give the person the onboarding packet and run the first-day walkthrough.

No tenant write is authorized until Adam explicitly approves the grant window
and the specific write path.

## First-Day Onboarding Instructions

Before the first day:

- Confirm the role: employee/operator, trusted partner/operator, card
  specialist, governance reviewer, or admin.
- Confirm the person has the correct Microsoft 365 account, MFA, and browser
  profile instructions.
- Confirm assigned cards and access level.
- Confirm no function/front-door account is being used as the human working
  identity.
- Confirm the person has the current links:
  - Guided AI Labs workspace:
    `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
  - Operations Cockpit / homepage:
    `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
  - Login Guide:
    `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Login-And-Account-Guide.aspx`
  - CRM Command Center when CRM access is assigned:
    `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx`

First-day walkthrough:

1. Sign in with the assigned account and MFA.
2. Open the Guided AI Labs workspace.
3. Confirm the person can reach the Operations Cockpit.
4. Confirm the person can open only the assigned cards and expected support
   surfaces.
5. Open the card runbook or card plan for the assigned work.
6. Create or update one harmless internal test item in the assigned workflow.
7. Find the related next action, decision, evidence, and escalation path.
8. Confirm the person can explain what they must not touch.
9. Record friction, missing access, confusing links, and any overbroad access.
10. Set the access review date.

Do not use a real client commitment, billing decision, guest invite, external
sharing link, app grant, public form, or unattended automation as the first-day
test.

## Escalation Rules

Escalate to Adam before proceeding when:

- access is missing, confusing, or broader than expected;
- work requires a new group, site, library, list, page, or permission grant;
- a client commitment, delivery scope, pricing, invoice, payment follow-up, or
  legal promise is unclear;
- a record appears sensitive, duplicated, misplaced, stale, or exposed to the
  wrong audience;
- work requires guest access, external sharing, public Forms, mailbox
  automation, production mail, calendar commitments, app consent, connector
  setup, Power Platform, Dynamics, Dataverse, or unattended automation;
- an AI/agent suggestion would affect a client, external party, permission,
  app, mailbox, record, billing state, or delivery commitment;
- a person needs admin authority, site owner authority, or break-glass access.

Escalation note format:

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

## Review Cadence

| Access type | Review cadence | Owner |
|---|---|---|
| Employee/operator | At onboarding, first week, role change, and quarterly while active. | Adam or delegated workspace owner. |
| Trusted partner/operator | Before grant, after first dry run, monthly while active, and at engagement close. | Adam. |
| Guest/client collaborator | Before invite, at named review date, and at engagement close. | Adam. |
| Governance reviewer/builder | Before grant, before app/agent changes, and monthly while active. | Adam. |
| Admin authority | Before every write window and during security review. | Adam/admin. |
| Break-glass | Offline credential review only; no routine sign-in. | Adam. |
| Agent/service identity | Before consent, after first dry run, before production, and at every review date. | Adam plus governance reviewer if assigned. |

## Evidence To Record

Record evidence in the surface that matches the decision:

- Decision Register: role model, partner/client access, app consent, sharing,
  billing/scope, and accepted-risk decisions.
- Exception Register: temporary exceptions, expiry dates, and closure path.
- Tool Permission Review: app grants, delegated permissions, agent scopes, and
  broad setup helper posture.
- Agent Action Log: AI/agent suggestions, approvals, executed actions, failures,
  rollback, and retirement.
- Handoff Packet Register: client/partner access and handoff state.
- CRM records and action queues: CRM-specific workflow state.
- Access/onboarding notes: first-day walkthrough result, friction, and access
  review date.

## Acceptance Test

Chunk 4 is accepted when Adam can answer these without guessing:

1. Is this person an employee/operator, trusted partner/operator, card
   specialist, governance reviewer, admin, function identity, guest, or
   service/app identity?
2. Which operating cards are assigned?
3. What access level applies?
4. Does "full access" mean full operating access or admin authority?
5. Which actions remain admin-only?
6. What must be recorded before access is granted?
7. What first-day walkthrough proves the role works?
8. What stop condition sends the decision back to Adam?

## Open Decisions

These do not block Chunk 4, but they must be resolved before live access changes
or broader onboarding:

- Exact live SharePoint groups and permission groups for future operators must
  be read back before any grant.
- The first trusted partner must be classified as internal member, external
  guest, or client-tenant collaborator before invitation or access.
- `support@changeleadershiptools.com` needs Authenticator/MFA before support
  workflows depend on it.
- Broad delegated setup grants still need their resting-state decision.
- Role-specific backup owners remain delegated later for most cards; current
  card plans use Adam until a backup owner is explicitly assigned.
- No non-CRM tenant-writing approval phrase is currently defined for access
  grants or onboarding changes.

## Stop Conditions

Stop and ask Adam before proceeding if:

- the live group or permission target cannot be read back;
- granting access would require tenant/global admin authority;
- the person would need external guest access or site sharing;
- the role would expose Restricted Build Evidence, billing records, client
  records, app grants, or agent setup details beyond the assigned scope;
- the work requires app consent, public Forms, mailbox automation, production
  mail, deletion, Dynamics, Dataverse, premium Power Platform, or unattended
  automation;
- a function mailbox is being treated as a human operating identity;
- any grant would make "full access" ambiguous again.
