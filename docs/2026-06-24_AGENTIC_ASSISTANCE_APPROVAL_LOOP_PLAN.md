# Agentic Assistance & Approval Loop Plan

Date generated: 2026-06-24

Status: **NEXT selected chunk** (2026-06-24). Local planning first; no tenant
write is approved by this document.

Owner: Adam.

Related card plans:

- `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`
- `docs/CARD_PLAN_DECISIONS_GOVERNANCE.md`
- `docs/AGENTIC_M365_READINESS.md`
- `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`

## Purpose

Turn the existing agent/governance surfaces into a usable operating loop:

```text
agent suggestion -> Agent Action Log -> G0-G4 classification ->
Adam approve/reject -> Decision Register when needed ->
evidence + rollback note -> supervised internal action
```

This is about practical functionality and agentic assistance now. Hiring,
role-library, and new-hire packet work are deferred until growth makes them
useful.

## MVP Scope

Build one real assisted workflow before broadening the system.

Recommended first workflow:

- Source: CRM / Bookings / follow-up records already live.
- Agent help: summarize the record, propose the next operating action, classify
  it G0-G4, and prepare an Agent Action Log entry.
- Human gate: Adam approves, rejects, or sends it back for detail.
- Evidence: Agent Action Log links to the source record, decision if needed,
  result, and rollback/pause note.
- Execution: only supervised G2 internal writes after explicit approval; no
  external send, access change, app consent, delete, public form, or unattended
  automation.

## Chunk A1 - Approval Loop MVP

Objective:

Make a reviewer-facing approval loop that can handle one agent-suggested
operating action end to end.

Inputs:

- Agent Action Log
- Decision Register
- Automation Backlog
- Tool Permission Review
- live CRM / Bookings / follow-up evidence
- G0-G4 model in `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`

Actions:

1. Confirm the live Agent Action Log and Decision Register fields/views are
   enough for the loop, using read-only evidence first.
2. Define the minimum proposal packet: source, affected card, action type,
   governance level, human owner, approval needed, result target, evidence
   target, and rollback/pause note.
3. Choose one safe workflow for the first proof, preferably CRM follow-up
   assistance because CRM, Bookings, and the follow-up backbone are already live.
4. Create or update local config/runbook material for the loop before any tenant
   write.
5. If a live write is needed, define the exact approval phrase, scope, evidence
   target, and rollback path before running it.
6. Record the proof and update this plan, the Agent Control Plane card, and the
   master map.

Acceptance:

- Adam can review one proposed agent action and see whether it is G0, G1, G2,
  G3, or G4.
- Suggested is visibly separate from approved.
- Approved is visibly separate from executed.
- Evidence and rollback/pause notes are present before any supervised write.
- The loop proves useful functionality without creating unattended automation.

Stop Conditions:

Stop before app registration, app consent, Graph/SharePoint/Exchange/Teams/
Planner permission changes, external sends, guest access, sharing changes,
public forms, deletes, billing/client commitments, Dynamics, Dataverse, premium
Power Platform, Copilot connector setup, custom actions, or unattended
automation.
