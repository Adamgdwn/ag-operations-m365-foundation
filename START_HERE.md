# Start Here

Date generated: 2026-06-24
Status: the only active startup document for this repo.

Read this file first, then open only the current working plan or the specific
reference needed for the task.

Box-up note 2026-06-24 night: docs are aligned around one governed
`M365 Interaction Agent`, with `New Signal` Teams alerting selected as the first
live notification capability. Local build/runbook files are prepared. No live
New Signal channel, Teams connector, flow, or test proof is confirmed yet.

## Current Focus

The Microsoft 365 infrastructure spine is complete. CRM / Relationships,
Bookings / Scheduling, and the Operations Follow-up Backbone are live and
verified.

Current working plan:

- [docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md)

Current setup runbook:

- [docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md](docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md)

Current chunk:

```text
new CRM signal -> CRM - New Signals -> New Signal Teams alert ->
Adam/operator triage -> M365 Interaction Agent proposal ->
approval/evidence if action is needed
```

Priority: one agent with governed M365 capabilities, starting with first-minute
CRM signal notification. Hiring roles, profile libraries, and onboarding packet
work are deferred until growth makes them useful. QUO phone integration is
parked until the Teams alert is proven.

## Fast Startup

1. Run `git status --short`.
2. Read the current working plan linked above.
3. Read the New Signal setup runbook if continuing the notification proof.
4. If you need the full pathway, read [MASTER_EXECUTION_MAP.md](MASTER_EXECUTION_MAP.md).
5. If you need the card backlog, read [docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md).
6. If the task mentions the Windows/Linux direct link, use the `direct-link`
   skill and [docs/LOCAL_AGENTIC_MACHINE_LINK_RUNBOOK.md](docs/LOCAL_AGENTIC_MACHINE_LINK_RUNBOOK.md).

Do not load old stage packets, session turnover files, exports, or inventory
snapshots unless the task specifically asks for history or evidence.

## Current Operating State

- Phase 1 / Stages 0-9: complete.
- CRM recovery: closed; V5 accepted; custom website intake verified for both
  brands; website fallback handled.
- Bookings: live native Microsoft Bookings path feeding CRM.
- Follow-up backbone: live email, calendar, and Planner reminder backbone.
- Held item: Stage 8 packet archive move still waits for Adam's explicit OK.
- Next proof: one CRM `New Signal` creates exactly one internal Teams alert in
  `Guided AI Labs / New Signal`, with a CRM item link.
- Live New Signal status: channel target evidence, Teams connector, live flow,
  and test proof are pending unless the files named in the setup runbook exist.
- Latest handoff: [SESSION_TURNOVER_2026-06-24.md](SESSION_TURNOVER_2026-06-24.md).

## Approval Boundaries

No document in this repo approves tenant writes by itself.

Stop before app registration, app consent, permission changes, external sends,
guest/sharing changes, public forms, deletes, billing/client commitments,
Dynamics, Dataverse, premium Power Platform, Copilot connector setup, custom
actions, or unattended automation unless Adam gives a fresh explicit approval
for that exact scope, evidence target, and rollback path.

Narrow approved exception for the current proof: one internal standard Teams
channel named `New Signal`, one standard Teams Power Automate connection as
Adam, and one create-only SharePoint-to-Teams alert flow. This does not approve
external messaging, QUO, app registration, admin consent, guest/sharing changes,
or broad automation.

## Active References

- Master path: [MASTER_EXECUTION_MAP.md](MASTER_EXECUTION_MAP.md)
- Current plan: [docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md)
- New Signal setup: [docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md](docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md)
- Agent card: [docs/CARD_PLAN_AGENT_CONTROL_PLANE.md](docs/CARD_PLAN_AGENT_CONTROL_PLANE.md)
- Decisions card: [docs/CARD_PLAN_DECISIONS_GOVERNANCE.md](docs/CARD_PLAN_DECISIONS_GOVERNANCE.md)
- Agent readiness: [docs/AGENTIC_M365_READINESS.md](docs/AGENTIC_M365_READINESS.md)
- G0-G4 decisions: [docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md](docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md)
- CRM history/plan: [docs/CRM_EXECUTION_PLAN.md](docs/CRM_EXECUTION_PLAN.md)
- Operator manual: [docs/WORKSPACE_INSTRUCTION_MANUAL.md](docs/WORKSPACE_INSTRUCTION_MANUAL.md)
- Full index: [00_INDEX.md](00_INDEX.md)

## Naming Convention

Stable anchor files may stay undated:

- `START_HERE.md`
- `MASTER_EXECUTION_MAP.md`
- `00_INDEX.md`
- `README.md`

New generated plans, handoffs, review packets, and working docs should use:

```text
YYYY-MM-DD_NAME.md
```

Example: `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`.
