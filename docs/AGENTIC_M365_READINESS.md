# Agentic Microsoft 365 Readiness

Date: 2026-06-19

Status: Active recommendation map for becoming agentic and AI-centric. Chunk 6
readiness pass complete and ready for final workspace walkthrough use.

This document describes what the Microsoft 365 environment should have before
Guided AI Labs relies on agents, Copilot extensions, connector-grounded search,
or automated actions.

Workspace card: Agent Control Plane.

Current card plan:

- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`

Current Chunk 6 decision list:

- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`

Current live surfaces:

- Tools card on the Operations Cockpit
- Agent Action Log
- Automation Backlog
- Tool Permission Review
- Agent Setup
- App Grants

Completion gate:

Agentic readiness is not complete until AI suggestions, approvals, write-capable
actions, evidence, and rollback notes can be reviewed through these operating
surfaces by a role-appropriate human owner.

Chunk 6 acceptance gate:

Guided AI Labs has a governed documented path from "AI suggests" to "human
approves" to "system acts" with action-log evidence, Decision Register approval
when required, and rollback/pause notes before write-capable or external-impact
work.

## Guiding Model

Microsoft 365 should become the governed operating substrate:

```text
identity -> records -> permissions -> signals -> recommendations -> approvals -> actions -> evidence
```

AI should first produce recommendations and drafts. Write-capable agents should
come later, after approval gates, logs, rollback notes, and permission boundaries
are proven.

## Chunk 6 Readiness Verdict

Current approved posture:

- G0 read-only review, classification, summarization, and gap detection are the
  safe starting point.
- G1 propose-and-log work may create or prepare Agent Action Log suggestions
  only inside the existing supervised pattern.
- G2 internal writes remain supervised, approval-gated, and evidence-backed.
- G3 external/access writes require Decision Register approval, a typed approval
  phrase, and read-back evidence.
- G4 autonomous actions remain blocked.

Current blocked posture:

- no production UAOS/M365 bridge app;
- no app registration, consent grant, or selected permission grant;
- no Exchange Application RBAC support adapter;
- no public/client Forms publishing;
- no external sends, guest invites, sharing changes, permission changes, tenant
  policy changes, deletes, or unattended automation;
- no reuse of broad setup-helper grants as production bridge capability.

No live tenant read or write was performed during Chunk 6. This pass used local
Stage 7 governance evidence, Stage 9 bridge-readiness evidence, the Chunk 5 card
plans, and the access/onboarding model.

## Governed Path

Use this operating path for every AI/agent action:

```text
source record -> G0-G4 classification -> proposed action -> human owner ->
approval check -> execution, if allowed -> evidence link -> rollback/pause note
```

Default lane:

- SharePoint-native pages, Lists, libraries, Planner, Teams, and Exchange remain
  the first operating substrate.
- Copilot agents should start as read-only retrieval and drafting helpers after
  records and access are reviewed.
- Copilot connectors should wait until an external system has a named owner,
  clear ACL mapping, and a Decision Register approval.
- Power Platform, Copilot Studio, custom actions, and custom UAOS integrations
  wait until DLP, licensing, environment ownership, approval gates, and rollback
  paths are decided.

## Recommendations

### 1. Identity And Access

Needed:

- named human accounts with MFA;
- separate admin and break-glass authority;
- clear employee/operator/trusted partner roles;
- service or app identities only after a decision record;
- least-privilege access per card.

Current role model:

- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` defines the workspace role
  tiers, operating-card access matrix, first-day onboarding path, and
  admin-only authority boundary.

Why it matters:

Agents inherit or exercise access. If human roles are blurry, agent permissions
will be blurry.

### 2. SharePoint Information Architecture

Needed:

- Guided AI Labs as the daily workplace and source of truth;
- AG Operations as portfolio/router surface;
- official lists/libraries for records, actions, decisions, evidence, and
  handoffs;
- clean metadata and view names;
- no daily operator path through technical/admin forms.

Why it matters:

Copilot, search, and future agents perform better when the official records are
structured and permissions-aware.

### 3. Records, Retention, And Purview

Needed:

- sensitivity and retention decisions for client, internal, finance, legal,
  governance, and reusable IP content;
- audit and eDiscovery posture;
- DLP boundaries for external sharing, email, and AI interactions;
- review of Microsoft Purview protections for Copilot and agents.

Recommendation:

Do not rush into broad Copilot/agent rollout until oversharing, stale access,
and sensitive record locations have been reviewed.

### 4. Agent Action Log

Needed:

- one durable `Agent Action Log` or equivalent list;
- every suggestion/action records actor, model/tool, scope, confidence, risk,
  approval, output, evidence link, and rollback note;
- separate statuses for suggested, approved, executed, failed, reverted, and
  retired.

Chunk 6 minimum fields:

- action title;
- action date;
- actor or agent surface;
- source link;
- affected card or surface;
- governance level;
- action type;
- status;
- human owner;
- approver when approved;
- result;
- evidence link;
- rollback, pause, rejection, or superseded note.

Recommended status flow:

```text
Suggested -> Needs Review -> Approved -> Executed -> Verified
```

Alternative closure states:

```text
Rejected | Superseded | Failed | Reverted
```

Why it matters:

The organization needs memory of what agents suggested and what humans allowed.

### 5. Decision Register And Approval Gates

Needed:

- decision records before app consent, connector onboarding, write-capable
  automation, external sharing, public forms, or client-impacting actions;
- typed approval phrases for risky chunks;
- clear owner and review date for every approved capability.

Why it matters:

Agentic work should be auditable and reversible, not vibes plus scripts.

Chunk 6 approval pattern:

| Level | Action posture | Required gate | Evidence |
|---|---|---|---|
| G0 | Read only. | Role-appropriate read access. | Optional action-log note when the review changes a decision or blocker. |
| G1 | Propose and log. | Source, owner, affected card, and no restricted action. | Agent Action Log row with status `Suggested`. |
| G2 | Approved internal write. | Named human approval and rollback note. | Agent Action Log plus target List/task/draft/evidence link. |
| G3 | Restricted external or access write. | Decision Register approval and typed approval phrase. | Decision Register, Agent Action Log, and read-back/transcript evidence. |
| G4 | Blocked autonomous action. | Separate Adam decision for a controlled project, if ever. | Decision Register only; do not execute from this readiness pass. |

### 6. Copilot Agents

Recommended path:

1. Start with SharePoint/Teams/OneDrive-grounded agents for internal knowledge
   and employee assistance.
2. Use declarative agents for role-specific guidance and retrieval.
3. Add custom actions only after the action log and approval gates are mature.
4. Use custom engine agents only when Microsoft 365 Copilot agents cannot cover
   the need.

Microsoft's current agent model supports custom instructions, custom knowledge
from Microsoft 365 and external data, and custom actions through APIs.

### 7. Copilot Connectors And Graph Grounding

Recommended path:

1. Keep the MVP grounded in SharePoint, Teams, Exchange, Planner, and Lists.
2. Add Copilot connectors only when external systems need to be searchable or
   reasoned over from Microsoft 365.
3. Prefer permission-preserving connectors with clear ACL mapping.
4. Use federated retrieval only when real-time access is needed and indexing is
   not appropriate.

Why it matters:

Connectors can make external data available to Copilot and Microsoft Search, but
bad ACLs can expose the wrong knowledge to the wrong person.

### 8. Power Platform And Copilot Studio

Needed before adoption:

- environment strategy;
- DLP policies;
- solution ownership;
- licensing decision;
- connector approval process;
- support model for apps/flows/agents.

Recommendation:

Use SharePoint-native workflows first. Add Power Apps, Power Automate, or
Copilot Studio when a card needs a better front door or controlled action
workflow than SharePoint pages/lists can provide.

### 9. Exchange, Teams, Planner, And Tasks

Needed:

- shared mailbox and alias decisions;
- support/intake mailbox MFA and access posture;
- Teams channels mapped to operating cards;
- Planner/List task ownership rules;
- meeting notes and decisions captured back into records.

Why it matters:

Mail, meetings, and tasks are the signal layer. Agents need clean signal routing
before they can triage responsibly.

### 10. Security Operations And Monitoring

Needed:

- admin audit review cadence;
- app consent review cadence;
- external sharing review;
- stale user/guest review;
- label and DLP policy review;
- incident path for bad AI output or unwanted agent action.

Why it matters:

AI increases the value of clean governance and the blast radius of messy access.

## Recommended Build Order

1. Finish full workspace usability map. Done through Chunk 5 card plans.
2. Finish CRM card recovery as the first complete operating-card example.
3. Build card template and acceptance tests for all other cards. Done for
   workspace usability in `docs/CARD_PLAN_INDEX.md`.
4. Establish access matrix and onboarding instructions. Done for workspace
   usability in `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`.
5. Establish the agentic decision list and governed path. Done for Chunk 6 in
   `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`.
6. Harden records, permissions, labels, and audit before broader Copilot use.
7. Prove Agent Action Log and Decision Register workflow during the final
   workspace walkthrough and any future supervised loops.
8. Pilot read-only recommendation agents.
9. Add connector-grounded knowledge where SharePoint is not enough.
10. Add write-capable agents only behind explicit approval gates.

## Microsoft 365 Surfaces To Evaluate

| Surface | Why It Matters For Agentic Work |
|---|---|
| Entra ID | identities, roles, groups, app registrations, service principals, Conditional Access |
| SharePoint | official records, pages, lists, libraries, metadata, permissions, search grounding |
| OneDrive | personal drafts, working files, limited project agents, sync hygiene |
| Teams | collaboration context, meetings, channels, app surfaces, employee entry point |
| Exchange | mail intake, calendar signals, support routing, client communication history |
| Planner / To Do / Lists | task state, queues, follow-ups, operating workflows |
| Purview | sensitivity, retention, audit, eDiscovery, DLP, Copilot/agent governance |
| Defender / Admin Centers | security posture, app review, alerts, risky access |
| Microsoft Graph | controlled API layer and future connector/action surface |
| Copilot Studio | managed agents, topics/actions, governance, adoption telemetry |
| Copilot Connectors | external knowledge grounding for Copilot and Microsoft Search |
| Power Platform | apps, flows, DLP, environments, Dataverse if later justified |

## Open Decisions

Chunk 6 decision queue lives in
`docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`.

Highest-priority open decisions:

- Whether to keep Security Defaults or move to Business Premium / Entra P1
  Conditional Access.
- Resting state for broad setup-helper grants, especially
  `agent-pnp-provisioning`.
- Support MFA before mailbox adapter or support draft loops.
- Permission-scope design and rollback worksheet before selected permissions or
  Exchange Application RBAC.
- Copilot pilot scope: read-only internal retrieval/drafting first, not
  write-capable custom actions.
- Which content is too sensitive for broad Copilot grounding.
- Whether any external source deserves a Copilot connector after ACL mapping.

## Chunk 6 Acceptance Test

Given a proposed AI/agent action, Adam can now answer:

1. Is it G0, G1, G2, G3, or G4?
2. Which card owns the source record?
3. Which human owns the action?
4. What approval is required before anything writes, sends, grants, shares, or
   deletes?
5. Where will evidence be recorded?
6. What is the rollback, pause, rejection, or superseded note?
7. Which stop condition prevents execution today?

Chunk 6 is complete for documentation/readiness purposes. Chunk 7 closeout
evidence for the Agent Control Plane is recorded in
`docs/WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md`.

## Current Official References

- Microsoft 365 Copilot agents overview:
  `https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agents-overview`
- Microsoft 365 Copilot extensibility:
  `https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/`
- Microsoft 365 Copilot connectors overview:
  `https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-copilot-connector`
- Microsoft Purview protections for Microsoft 365 Copilot:
  `https://learn.microsoft.com/en-us/purview/ai-m365-copilot`
- Microsoft Purview AI security and compliance:
  `https://learn.microsoft.com/en-us/purview/ai-microsoft-purview`
- SharePoint readiness for Microsoft 365 Copilot:
  `https://learn.microsoft.com/en-us/sharepoint/get-ready-copilot-sharepoint-advanced-management`
