# Session Turnover - 2026-06-19

Canonical restart file:
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

Current workspace source of truth:
[docs/START_HERE.md](docs/START_HERE.md).

## Stop Point

The workspace usability pass is boxed up after Chunk 6.

Completed today:

- Chunk 3 - Card Template And Acceptance Standard is complete and pushed.
- Chunk 4 - Access And Onboarding Model is complete and pushed.
- Chunk 5 - Card Deep Dives is complete and pushed.
- Chunk 6 - Agentic M365 Readiness Pass is complete and pushed.
- CRM / Relationships remains the applied example and CRM-specific recovery
  still runs through `docs/CRM_EXECUTION_PLAN.md`.
- Active card deep-dive plans now exist for Workspace Home, Delivery /
  Projects, Decisions / Governance, Tasks / Actions, Knowledge / Records,
  Support / Intake, Finance / Closeout, and Agent Control Plane.
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` remains the active access and
  onboarding model.
- `docs/AGENTIC_M365_READINESS.md` and
  `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md` now record the agentic readiness
  verdict, approval pattern, action-log requirements, surface lane decisions,
  and Adam decision queue.
- No live Microsoft 365 read was needed for Chunk 6.
- No tenant write was performed for Chunk 6.

Latest workspace execution state:

```text
Chunks 1-6 complete and pushed.
Next chunk: Chunk 7 - Final Usability Walkthrough.
```

Next session should start from:

```text
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_WORKSPACE_HOME.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
docs/CARD_PLAN_DELIVERY_PROJECTS.md
docs/CARD_PLAN_DECISIONS_GOVERNANCE.md
docs/CARD_PLAN_TASKS_ACTIONS.md
docs/CARD_PLAN_KNOWLEDGE_RECORDS.md
docs/CARD_PLAN_SUPPORT_INTAKE.md
docs/CARD_PLAN_FINANCE_CLOSEOUT.md
docs/CARD_PLAN_AGENT_CONTROL_PLANE.md
docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
docs/AGENTIC_M365_READINESS.md
docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md
```

## What Changed

New Chunk 5/6 outputs:

```text
docs/CARD_PLAN_WORKSPACE_HOME.md
docs/CARD_PLAN_DELIVERY_PROJECTS.md
docs/CARD_PLAN_DECISIONS_GOVERNANCE.md
docs/CARD_PLAN_TASKS_ACTIONS.md
docs/CARD_PLAN_KNOWLEDGE_RECORDS.md
docs/CARD_PLAN_SUPPORT_INTAKE.md
docs/CARD_PLAN_FINANCE_CLOSEOUT.md
docs/CARD_PLAN_AGENT_CONTROL_PLANE.md
docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md
```

Updated routing and restart docs:

```text
00_INDEX.md
START_HERE_TOKEN_FRIENDLY.md
M365_FOUNDATION_ROADMAP.md
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_INDEX.md
docs/COCKPIT_CARD_GAP_LIST.md
docs/AGENTIC_M365_READINESS.md
docs/CARD_PLAN_AGENT_CONTROL_PLANE.md
```

Each Chunk 5 card plan includes:

- purpose and operator promise;
- primary workflow and common scenarios;
- pages, lists, libraries, queues, and controlled surfaces;
- owner, backup owner, cadence, and evidence location;
- employee/operator, trusted partner/operator, governance reviewer, and
  admin-only access boundaries;
- data model, required views, record ownership, and data quality rules;
- runbook, acceptance test, agentic opportunities, current blockers, future
  enhancements, and stop conditions.

## Current Findings

Chunk 6 confirms that the workspace has a governed path from "AI suggests" to
"human approves" to "system acts" for documentation/readiness purposes. It is
not yet browser-proven end to end for a new operator.

Important carry-forwards:

- Browser/live-user acceptance evidence remains for Chunk 7 final usability
  walkthrough.
- CRM recovery remains under `docs/CRM_EXECUTION_PLAN.md`.
- Agent Control Plane acceptance should use `docs/CARD_PLAN_AGENT_CONTROL_PLANE.md`,
  `docs/AGENTIC_M365_READINESS.md`, and
  `docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md`.
- Current agentic posture is G0/G1 first, supervised approval-gated G2 only, G3
  only with Decision Register approval and typed approval phrase, and G4 blocked
  autonomously.
- Exact live SharePoint groups and permission groups must be read back before
  any access grant.
- Partner/client guest invites, external sharing, app consent, public Forms,
  mailbox automation, production mail, deletes, Dynamics, Dataverse, premium
  Power Platform, and unattended automation remain stop conditions.

## Exact Resume Sequence

1. Open [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).
2. Open [docs/START_HERE.md](docs/START_HERE.md).
3. Open [docs/WORKSPACE_EXECUTION_PLAN.md](docs/WORKSPACE_EXECUTION_PLAN.md).
4. Review the Chunk 7 walkthrough inputs:

   ```text
   docs/CARD_PLAN_INDEX.md
   docs/CARD_PLAN_AGENT_CONTROL_PLANE.md
   docs/AGENTIC_M365_READINESS.md
   docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md
   docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
   ```

5. Start Chunk 7 only if Adam says to continue the workspace usability pass.
6. Do not run tenant-writing commands. Chunk 7 should begin as a browser/live
   usability walkthrough and evidence capture unless a new approval phrase and
   explicit scope are added.

## Git Note

Chunks 1-6 were committed and pushed on branch
`codex/m365-agent-capability-bridge`.
