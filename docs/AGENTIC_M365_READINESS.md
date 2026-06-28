# Agentic Microsoft 365 Readiness

Date: 2026-06-19

Status: Active recommendation map for becoming agentic and AI-centric. Chunk 6
readiness pass complete. Active revision on 2026-06-24: build one governed
`M365 Interaction Agent` with capability contracts, not a stack of separate
supervised helpers. 2026-06-27 update: B1-B9 G0 are live-proven; B8a local
Journey hardening, B8b live Journey replay/idempotency proof, B9a local
selected-signal operating readiness, B9b selected internal read-only triage, and
B10a local QUO inbound source readiness are complete. 2026-06-28 update: Chunk
20G GAIL OS bridge/one-writer framing is merged, and the remaining structured
chunk is B10b QUO implementation-ready placeholder/design pack. Live QUO proof
moves to B10c or a later source-expansion stage after exact approval. Future B9
normal-client reads and G1 Suggested rows remain selected/approved per item.

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

Current active implementation note:

- The active plan is
  `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`.
- The first live notification capability is documented in
  `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md` and is now proven.
- Current build chunks live in
  `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`.
- B8a local Journey hardening packet lives at
  `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.md`.
- B8b live Journey loop hardening proof lives at
  `inventory/m365-interaction-agent-b8/B8B_LIVE_PROOF_2026-06-27.md`.
- B9a local selected-signal operating packet lives at
  `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.md`.
- B9b selected G0 triage proof lives at
  `inventory/m365-interaction-agent-b9/B9B_SELECTED_G0_TRIAGE_PROOF_2026-06-27.md`.
- B10a local QUO inbound source proof packet lives at
  `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`.
- `agent-pnp-provisioning` and delegated setup scripts remain setup/proof
  tooling only; they are not the production agent identity.
- QUO phone integration has a local B10a readiness packet, but no live QUO
  connector, webhook, CRM write, Teams post, or outbound action is approved.

Microsoft 365 should become the governed operating substrate:

```text
identity -> records -> permissions -> signals -> recommendations -> approvals -> actions -> evidence
```

Visible interaction principle:

If a governed action needs Adam to type an approval phrase, choose an account,
complete MFA, select a source item, confirm a source proof, or operate a live
admin/source surface, the agent is responsible for opening or naming the exact
visible interaction surface first. Approval gates should not be hidden in a
background terminal or implied from chat context. For the M365 Interaction Agent
B8/B9/B10 lane, use `scripts/Start-M365InteractionAgentApprovalWindow.ps1` to
show scope and stop conditions in a visible PowerShell window and record local
approval evidence before any live tenant/source work begins.

In the broader Guided AI Labs operating-system vision, M365 is the enterprise
body and execution substrate. Freedom coordinates executive cognition, Guided
AI Labs Operating System holds governance/autonomic management, and Graphify
holds relationship/context intelligence. This readiness plan keeps the M365
lane structured enough for those layers to consume later without granting them
production authority from this repo.

Authority vocabulary maps as follows:

| Org level | Local gate | Current readiness meaning |
|---|---|---|
| R0 Observe | G0 | Read-only review, classification, summarization, and gap detection. |
| R1 Propose | G1 | Supervised suggestions and Agent Action Log rows. |
| R2 Internal Act | G2 | Approved internal M365 writes with rollback evidence. |
| R3 Restricted | G3 | External, access, connector, callback, or sensitive work with Decision Register approval and typed phrase. |
| R4 Delegated Autonomous | Not enabled | Future separate project only; not approved by current agentic readiness work. |
| R5 Human Only | G4 blocked/escalate | Adam-only authority for commitments, legal/billing, admin/access, deletes/merges, external sends, and any R4 delegation. |

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

Narrow 2026-06-24 exception for the selected proof:

- one internal standard Teams channel named `New Signal`;
- one standard Teams Power Automate connection as Adam;
- one create-only alert flow from `CRM - New Signals` to the Teams channel.

This exception does not approve app registration, admin consent, external
messaging, guest/sharing changes, QUO, or broad unattended automation.

Later B1-B9 G0 work proved the Journey source, receipt, replay/idempotency lane,
and selected internal read-only operating triage, but it does not approve future
B9 normal-client reads, B9 Suggested rows, B10b QUO setup/proof, outbound
phone/SMS behavior, or any new live write.

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

| Level | Org map | Action posture | Required gate | Evidence |
|---|---|---|---|---|
| G0 | R0 Observe | Read only. | Role-appropriate read access. | Optional action-log note when the review changes a decision or blocker. |
| G1 | R1 Propose | Propose and log. | Source, owner, affected card, and no restricted action. | Agent Action Log row with status `Suggested`. |
| G2 | R2 Internal Act | Approved internal write. | Named human approval and rollback note. | Agent Action Log plus target List/task/draft/evidence link. |
| G3 | R3 Restricted | Restricted external or access write. | Decision Register approval and typed approval phrase. | Decision Register, Agent Action Log, and read-back/transcript evidence. |
| G4 | R5 Human Only / no R4 delegation | Blocked autonomous action. | Separate Adam decision for a controlled project, if ever. | Decision Register only; do not execute from this readiness pass. |

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
8. Complete B8a local Journey receipt/replay hardening packet. Done.
9. Complete B8b live Journey hardening after exact schema/flow/replay approval.
   Done.
10. Complete B9a local selected-signal operating packet. Done.
11. Run B9b selected-signal operating triage under G0 after item selection.
    Done for internal CRM item `#32`; no G1 row was written.
12. Complete B10a local QUO inbound source proof readiness packet. Done.
13. Close B10b QUO implementation-ready placeholder/design pack without QUO API
    work. Pending Adam go-ahead.
14. Run B10c/later QUO inbound-only live proof only after exact
    number/event/ingress, secret, retention, duplicate, disable, and
    outbound-block approval.
15. Pilot read-only recommendation agents.
16. Add connector-grounded knowledge where SharePoint is not enough.
17. Add write-capable agents only behind explicit approval gates.

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
- Whether any future selected B9 item may receive a separate G1 Suggested row,
  or whether another normal-client B9 read should run against exact item id(s).
- Which QUO number(s), event classes, ingress pattern, payload retention,
  duplicate rule, disable path, and outbound block are approved for B10b.

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
