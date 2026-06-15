# Stage 9 Agent Capability Build Guide

Generated: 2026-06-15 11:42:10

Scope: local-only capability packet. This packet does not connect to Microsoft 365, grant permissions, create apps, send mail, invite guests, change sharing, or alter tenant policy.

## Goal

Get Guided AI Labs to a governed M365 coordinator and support agent posture where read/write capability exists only inside named lanes, evidence is recorded, and restricted actions remain approval-gated.

## Principles

- Purpose-built access, not inherited setup power.
- Read/propose/log first; write only through named governance lanes.
- External sends, guest invites, sharing changes, app consent, tenant policy, destructive deletes, and calendar commitments require human approval.
- Every meaningful action must land in Agent Action Log and, when policy or scope changes, Decision Register.

## Governance Levels

| Level | Name | Approval | Description |
|---|---|---|---|
| G0 | Read Only | Not required before action | Inventory, classify, summarize, and detect gaps. No M365 writes. |
| G1 | Propose And Log | Not required before action | Create draft recommendations and Suggested Agent Action Log rows only. |
| G2 | Approved Internal Write | Required | Create or update internal operating records after a named approval gate. |
| G3 | Restricted External Or Access Write | Required | External messages, public/client forms, guest access, sharing, permissions, app grants, and tenant policy changes. |
| G4 | Blocked Autonomous Action | Required | Secrets, break-glass accounts, destructive tenant actions, broad grants, anonymous sharing, and unattended client-impacting commitments. |

## Agent Capability Map

| Agent | Initial mode | Target mode | Primary write level | Blocked actions |
|---|---|---|---|---|
| M365 Coordinator | Codex/local supervised delegated session | Purpose-built Entra app or UAOS adapter after Stage 9 approval | G1, G2 | send external email; invite guests; change sharing or permissions; grant app consent; change tenant policy; delete records; publish client-facing forms; make calendar commitments |
| M365 Support Agent | Codex/local supervised delegated session | Scoped mailbox/list adapter after support MFA and Stage 9 approval | G1, G2 | send external email without Adam approval; change support mailbox forwarding or delegates; invite guests; change sharing or permissions; grant app consent; delete support records; collect sensitive client data through public forms |

## M365 Coordinator

Internal operating coordinator for Guided AI Labs

Read surfaces:

- Guided AI Labs - Intake Register
- Guided AI Labs - Operating Plan
- Decision Register
- Agent Action Log
- Client Workspace Register
- Handoff Packet Register
- Tool Permission Review
- Automation Backlog
- Exception Register
- Readiness Evidence
- CRM - Organizations
- CRM - Contacts
- CRM - Engagements
- CRM - Stakeholder Map
- CRM - Touchpoints
- CRM - Lifecycle Checklist

| Write surface | Governance level | Allowed writes |
|---|---|---|
| Agent Action Log | G1 | suggested actions; dry-run evidence; verification notes |
| Guided AI Labs - Intake Register | G2 | create/update internal intake rows; set next action; link durable home |
| Decision Register | G2 | record approved operating/governance decisions |
| Automation Backlog | G2 | record proposed automation; update readiness/status |
| Tool Permission Review | G2 | record permission review candidates; record approved review outcomes |
| Stage 8A Relationship CRM Lists | G2 | create/update internal organization/contact/engagement rows; record touchpoints; update lifecycle checklist items after approval |
| Guided AI Labs - Operating Plan | G2 | create/update supervised Planner tasks after approval |

## M365 Support Agent

Support intake and resolution assistant for Change Leadership Tools

Read surfaces:

- Change Leadership Tools - Support Register
- Agent Action Log
- Decision Register
- support mailbox metadata and approved message bodies
- support knowledge candidates

| Write surface | Governance level | Allowed writes |
|---|---|---|
| Agent Action Log | G1 | suggested support actions; draft-response evidence; triage notes |
| Change Leadership Tools - Support Register | G2 | create/update support rows; set severity/status; record resolution summary; flag knowledge candidate |
| support mailbox drafts | G2 | create draft replies only after approval |
| Guided AI Labs - Operating Plan | G2 | create/update supervised support follow-up tasks after approval |

## Permission Lanes

| Lane | Recommended first | Avoid as resting state | Fit | Description |
|---|---|---|---|---|
| Supervised Delegated | True | True | Planner writes; first records writes; manual review runs | Use Adam-approved interactive Graph/PnP sessions and typed approval gates for first write loops. |
| SharePoint Selected Permissions | False | False | selected Guided AI Labs Lists; selected Change Leadership Tools Support Register; selected evidence libraries | Use Selected scopes plus explicit site/list grants for durable app-based List and SharePoint access. |
| Exchange Application RBAC | False | False | support@changeleadershiptools.com mailbox access | Use Exchange Online Application RBAC to scope mailbox access for app-based support processing. |
| Broad Setup Grants | False | True | time-boxed provisioning only | Existing setup-helper grants such as AllSites.FullControl and Group.ReadWrite.All. |

## First Live Loop Candidates

| ID | Agent | Name | Level | Writes | Approval phrase | Exit criteria |
|---|---|---|---|---|---|---|
| stage9-loop-001 | M365 Coordinator | Read intake state and create a suggested Agent Action Log row | G1 | Agent Action Log | record-stage-9-coordinator-suggestion | A suggested row exists, links to source context, and no restricted action occurred. |
| stage9-loop-002 | M365 Support Agent | Create a supervised support triage row and draft response evidence | G2 | Change Leadership Tools - Support Register; Agent Action Log | record-stage-9-support-triage | A support row and log row exist; no external email was sent. |

## Rollout Sequence

| Step | Name | Done when |
|---|---|---|
| 1 | Finish Stage 8 command-center draft review | Draft page is created, read-back verified, and browser-reviewed. |
| 2 | Record Stage 9 capability decision | Decision Register records coordinator/support scope and blocked actions. |
| 3 | Run G1 coordinator loop | Coordinator creates only a Suggested Agent Action Log row. |
| 4 | Run G2 support triage loop | Support row and log row are created after approval; no external send occurs. |
| 5 | Choose app posture | Adam chooses delegated-only, Selected permissions, Exchange App RBAC, or a mixed adapter path. |
| 6 | Create separate app registrations if needed | Apps are created through a separate approval-gated operator and do not reuse agent-pnp-provisioning. |

## Source Notes

- Microsoft Graph permissions reference: https://learn.microsoft.com/en-us/graph/permissions-reference (checked 2026-06-15)
- Overview of Selected permissions in OneDrive and SharePoint: https://learn.microsoft.com/en-us/graph/permissions-selected-overview (checked 2026-06-15)
- Role Based Access Control for Applications in Exchange Online: https://learn.microsoft.com/en-us/exchange/permissions-exo/application-rbac (checked 2026-06-15)
- Microsoft Graph Planner task permissions: https://learn.microsoft.com/en-us/graph/api/planneruser-list-tasks?view=graph-rest-1.0 (checked 2026-06-15)
- Microsoft Graph user sendMail: https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0 (checked 2026-06-15)

## Safe Next Actions

1. Finish the Stage 8 command-center draft apply, read-only verification, and browser review.
2. Record the Stage 9 capability decision in Decision Register and Agent Action Log.
3. Run the first G1 coordinator loop: suggested Agent Action Log row only.
4. Run the first G2 support loop only after support MFA is complete and Adam approves the write.
5. Defer app registrations, consent, Exchange RBAC, and Selected permission grants to separate approval-gated operators.

Dry-run-first operator:

```powershell
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action RecordDecision
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action CoordinatorSuggestion
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action SupportTriage
```

Apply mode requires the matching typed approval phrase and writes only to approved operating Lists.
