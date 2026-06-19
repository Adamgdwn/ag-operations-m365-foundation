# Agent Control Plane Card Plan

Date: 2026-06-19

Status: Active card plan with Chunk 6 readiness pass complete. This plan
complements `docs/AGENTIC_M365_READINESS.md` and
`docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`; it does not approve app
registrations, consent, unattended automation, or production bridge work.

## Card Plan Header

Name: Agent Control Plane

Owner: Adam until a controlled builder/governance reviewer is delegated.

Primary users:

- Adam
- governance reviewer / controlled builder
- trusted partner/operator assigned to supervised agent review
- employee/operator for read/propose/log-only review when assigned

Primary workflow:

Review AI/agent suggestions, action logs, automation backlog, app/tool
permission posture, approval gates, and rollback notes before any system acts.

Current live surface:

- Tools card
- Agent Action Log
- Automation Backlog
- Tool Permission Review
- Agent Setup
- App Grants
- Decision Register

Completion gate:

A role-appropriate reviewer can classify an agent action as read-only,
draft/proposed, approved internal write, restricted write, or blocked; identify
the required evidence; and stop before any app, permission, external/client, or
unattended automation change.

Related docs:

- `docs/AGENTIC_M365_READINESS.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`
- `config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json`
- `config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json`
- `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md`

## Purpose

The Agent Control Plane keeps AI useful without letting suggestions quietly turn
into unreviewed action.

## Operator Promise

After receiving controlled access and this runbook, a reviewer can inspect agent
suggestions, confirm approval state, record or reject proposed actions, and know
which actions are blocked until Adam approves a separate governance path.

## Governance Levels

Use these levels from the Stage 9 capability model:

- G0: read only.
- G1: propose and log.
- G2: approved internal write.
- G3: restricted external or access write.
- G4: blocked autonomous action.

Default posture:

- G0/G1 first.
- G2 only after named approval and evidence.
- G3 requires Decision Register approval and explicit approval phrase.
- G4 is not allowed autonomously.

## Daily Workflow

1. Start from Operations Cockpit.
2. Open Tools or Agent Action Log / Needs Review.
3. Review suggested, approved, completed, rejected, and superseded actions.
4. Check Automation Backlog and Tool Permission Review for proposed capability
   work.
5. Link decisions, source records, evidence, approval, and rollback notes.
6. Stop before app consent, permissions, external sends, sharing, public forms,
   deletes, production bridge work, or unattended automation.

## Common Scenarios

| Scenario | Start surface | Expected output | Escalate when |
|---|---|---|---|
| Review suggestion | Agent Action Log / Needs Review | Suggested action is approved, rejected, or sent back for detail | Action lacks source, owner, risk, or rollback note. |
| Automation idea | Automation Backlog | Backlog item has owner, lane, readiness, and decision need | It requires app/permission/connector change. |
| Tool permission review | Tool Permission Review | Review item has scope, risk, and decision link | Consent, Graph scope, or broad delegated grant is involved. |
| App grant posture | App Grants | Decision needed or app stays blocked | Any app registration, consent, or selected permission is requested. |
| Agent write request | Agent Action Log + Decision Register | Approval state and evidence are explicit | Write affects client, external party, access, mailbox, billing, or records. |

## Surfaces

Pages:

- Agent Setup
- App Grants
- AI And Automation Governance, when used as reference
- Decisions

Lists:

- Agent Action Log
- Automation Backlog
- Tool Permission Review
- Decision Register
- Exception Register

Libraries:

- Restricted Build Evidence
- Readiness Evidence

Current cockpit link or queue:

- Tools card
- Agent Action Log / Needs Review queue

Reference-only or superseded surfaces:

- Stage 9 packet docs unless cited by current readiness/control docs
- one-off script transcripts without corresponding action log or decision

Admin-only or controlled surfaces:

- Entra app registrations
- enterprise app consent
- Graph/SharePoint/Exchange/Teams/Planner permissions
- app secrets/certificates
- external sends
- guest access and sharing
- public Forms and connectors
- deletes and production automation

## Ownership And Cadence

Human owner:

- Adam.

Backup owner:

- Adam until a controlled builder/governance reviewer is assigned.

Review cadence:

- Daily when agent suggestions are active.
- Weekly for Automation Backlog and Tool Permission Review.
- Before every G2/G3 write-capable test.
- Monthly for app posture and broad delegated setup grants.

Evidence location:

- Agent Action Log for every suggestion/action.
- Decision Register for approvals and capability posture.
- Tool Permission Review for app/tool scope.
- Restricted Build Evidence for sensitive build evidence.

## Access Model

Employee/operator access:

- A1/A2 for read, propose, and log-only review when assigned.

Trusted partner/operator full access:

- A3 for supervised review and draft workflows only when assigned.

Governance reviewer / controlled builder:

- A4 for Tool Permission Review, Automation Backlog, App Grants posture,
  Restricted Build Evidence, and readiness evidence.

Admin-only authority:

- app registrations, app consent, broad Graph permissions, write-capable agents,
  unattended automation, connector setup, rollback/pause controls, and tenant
  policy changes.

Blocked access escalation:

- Escalate with action log link, requested governance level, affected surface,
  approval needed, evidence, and rollback note.

## Data Model

Required fields:

- action title
- action date
- agent surface or tool
- source link
- action type
- status
- human approver when approved
- result
- evidence link
- rollback or superseded note for write-capable actions

Useful fields:

- governance level
- affected card
- risk
- approval phrase
- related decision
- related tool review
- related automation backlog item

Fields hidden from daily operators:

- app IDs/secrets
- permission payloads
- tenant policy internals
- sensitive security evidence

Required views:

- Agent Action Log / Needs Review
- Approved / Completed
- Rejected / Superseded
- By Surface
- Automation Backlog
- Tool Permission Review / Needs Review

Record and file ownership:

- Agent Action Log owns the action trail.
- Decision Register owns approval.
- Tool Permission Review owns app/tool scope.
- Restricted Build Evidence owns sensitive proof.

Data quality rules:

- No write-capable action without source, owner, approval state, evidence, and
  rollback note.
- Suggested is not approved.
- Approved is not executed.
- Completed is not proof unless evidence links exist.
- Setup-helper grants are not production bridge capability.

## Runbook

Start of day:

- Open Agent Action Log / Needs Review.
- Check for suggested or approved actions needing closure.

Primary workflow:

- Classify action level G0-G4.
- Confirm source, owner, risk, approval, evidence, and rollback.
- Approve/reject only within role authority.
- Record required decisions before capability changes.

End of day:

- No suggested action sits without owner or next step.
- Approved actions have evidence or are still waiting.
- Completed actions have result and rollback/superseded note when needed.

Escalation:

- Escalate app consent, permissions, public forms, mailbox automation,
  production mail, external/client impact, deletes, guest/sharing, billing,
  Dynamics, Dataverse, premium Power Platform, and unattended automation.

## Acceptance Standard

Agent Control Plane is complete when AI/agent work has visible status, human
owner, approval gate, evidence, and rollback path before any system-impacting
action occurs.

## Agentic Opportunities

Read-only suggestions:

- Identify stale action-log items, missing approval, missing evidence, app/tool
  reviews needing closure, and backlog items missing readiness gates.

Draft generation:

- Draft action-log entries, tool review notes, automation backlog summaries,
  decision drafts, and rollback checklists.

Write-capable actions:

- G1 suggested log rows may be allowed by prior model, but this Chunk 5 plan
  does not run them.
- G2/G3 writes require separate approval and evidence.
- G4 remains blocked.

Required approval gate:

- Decision Register entry before app registrations, consent, permissions,
  connector onboarding, external sends, public forms, guest/sharing, or
  production bridge posture.
- Typed approval phrase for any future tenant-writing chunk.

Required evidence:

- Agent Action Log entry for every AI/agent suggestion or assisted action.
- Decision Register entry for policy, scope, app, permission, external/client,
  mailbox, or automation posture.
- Rollback/pause note for every write-capable action.

## Completion Requirements

This card is complete only when:

- the Tools card is treated as controlled governance, not casual operator space;
- G0-G4 action classes are clear;
- action log, decision, tool review, and automation backlog roles are clear;
- app/permission/connector writes remain blocked without approval;
- current Stage 9 blockers are carried forward;
- acceptance evidence is recorded.

Current blockers before final workspace acceptance:

- Broad delegated setup grants need a resting-state decision.
- Support MFA remains open before support mailbox adapter work.
- Permission-scope design, rollback worksheet, G0/G1 adapter dry run, and a
  separate production bridge decision remain open.
- Browser/live-user acceptance evidence remains for Chunk 7.

Future enhancements:

- Add explicit non-CRM approval phrases for agent/control-plane write chunks.
- Build a rollback worksheet for each candidate adapter lane.
- Add dashboard views for open action-log approvals and automation backlog
  readiness.

## Acceptance Test

Given a role-appropriate reviewer:

1. Sign in with MFA.
2. Open Operations Cockpit.
3. Open Tools or Agent Action Log / Needs Review.
4. Classify a safe internal suggested action as G0, G1, G2, G3, or G4.
5. Identify source, owner, approval state, required evidence, and rollback need.
6. Decide whether the action can be rejected, kept suggested, or escalated.
7. Find related Decision Register, Tool Permission Review, and Automation
   Backlog surfaces.
8. Confirm no app consent, permission, external send, public form, delete, or
   unattended automation is approved by opening the card.

Evidence to record:

- test date;
- role used;
- action-log item or safe simulated action;
- classification;
- blockers versus future enhancements.

## Stop Conditions

Stop and ask Adam before proceeding if:

- the work requires app registration, app consent, Graph/SharePoint/Exchange/
  Teams/Planner permissions, selected permission grants, mailbox adapters,
  production mail, external sends, guest access, sharing, public forms, deletes,
  billing, client commitments, Dynamics, Dataverse, premium Power Platform, or
  unattended automation;
- an agent suggestion lacks source, owner, approval state, evidence, or rollback
  path;
- a setup-helper grant is being treated as production agent capability.
