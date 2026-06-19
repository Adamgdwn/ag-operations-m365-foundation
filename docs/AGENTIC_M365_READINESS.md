# Agentic Microsoft 365 Readiness

Date: 2026-06-19

Status: Active recommendation map for becoming agentic and AI-centric.

This document describes what the Microsoft 365 environment should have before
Guided AI Labs relies on agents, Copilot extensions, connector-grounded search,
or automated actions.

Workspace card: Agent Control Plane.

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

## Guiding Model

Microsoft 365 should become the governed operating substrate:

```text
identity -> records -> permissions -> signals -> recommendations -> approvals -> actions -> evidence
```

AI should first produce recommendations and drafts. Write-capable agents should
come later, after approval gates, logs, rollback notes, and permission boundaries
are proven.

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

1. Finish full workspace usability map.
2. Finish CRM card recovery as the first complete operating-card example.
3. Build card template and acceptance tests for all other cards.
4. Establish access matrix and onboarding instructions. Done for workspace
   usability in `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`.
5. Harden records, permissions, labels, and audit.
6. Prove Agent Action Log and Decision Register workflow.
7. Pilot read-only recommendation agents.
8. Add connector-grounded knowledge where SharePoint is not enough.
9. Add write-capable agents only behind explicit approval gates.

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

- Which Microsoft 365 licensing path is worth paying for first.
- Whether Copilot will be used as a daily employee tool, an admin-only tool, or a
  staged pilot.
- Which external data sources deserve connectors.
- Whether agent actions should remain SharePoint/List writes first.
- Which partner/operator roles can use AI features.
- What content is too sensitive for broad Copilot grounding.

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
