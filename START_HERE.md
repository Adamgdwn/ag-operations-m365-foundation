# Start Here

Date generated: 2026-06-24
Status: the only active startup document for this repo.

Read this file first, then open only the current working plan or the specific
reference needed for the task.

Update 2026-06-25: docs are aligned around one governed `M365 Interaction
Agent`, with `New Signal` Teams alerting proven as the first live notification
capability. B1-B4 are live-tested through one synthetic CRM signal, one Teams
alert, one triage/similar-record packet, and one `Suggested` Agent Action Log
row.

Pause note 2026-06-25: Adam paused the build because two agents are currently
writing to M365 accounts and competing. Do not run additional live M365 write
tests, connector setup, flow creation, `-Apply`, or `-Approve` actions from this
repo until Adam resumes this agent lane and the competing-writer boundary is
clear.

## Current Focus

The Microsoft 365 infrastructure spine is complete. CRM / Relationships,
Bookings / Scheduling, and the Operations Follow-up Backbone are live and
verified.

Current working plan:

- [docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md)

Current setup runbook:

- [docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md](docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md)

Current next-build packet:

- [docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md](docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md)

Current chunk:

```text
new CRM signal -> CRM - New Signals -> New Signal Teams alert ->
Adam/operator triage -> M365 Interaction Agent proposal ->
approval/evidence if action is needed
```

Priority when resumed: one agent with governed M365 capabilities, starting
with first-minute CRM signal notification. Hiring roles, profile libraries, and
onboarding packet work are deferred until growth makes them useful. QUO phone
integration remains parked until a later source-expansion decision.

## Fast Startup

1. Run `git status --short`.
2. Read the latest handoff:
   [SESSION_TURNOVER_2026-06-25.md](SESSION_TURNOVER_2026-06-25.md).
3. Read the current working plan linked above.
4. Read the New Signal setup runbook if continuing the notification proof.
5. Read the next-build packet if planning beyond the first alert proof.
6. Confirm Adam has paused or separated the other M365-writing agent before
   running any live write from this repo.
7. If you need the full pathway, read [MASTER_EXECUTION_MAP.md](MASTER_EXECUTION_MAP.md).
8. If you need the card backlog, read [docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md).
9. If the task mentions the Windows/Linux direct link, use the `direct-link`
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
- New Signal proof: CRM item `#19` created exactly one internal Teams alert in
  `Guided AI Labs / New Signal`, with a CRM item link.
- Live New Signal status: channel target evidence, Teams connector, live flow,
  Power Automate run, Teams web proof, B2/B3 triage, and B4 `Suggested` row are
  complete for the synthetic proof lane.
- B1 proof harness: `scripts/Invoke-M365NewSignalAlertProof.ps1` records local
  proof evidence and gates the one synthetic CRM create behind a typed approval.
- B2/B3 triage packet: `scripts/Invoke-M365NewSignalTriage.ps1` reads one
  signal, flags possible related CRM records, and writes local G0 evidence.
- B4 Suggested row: Agent Action Log row `#9` was created for CRM item `#19`
  with status `Suggested`; no CRM update, task, reminder, message, merge,
  permission, or external action was approved or performed.
- Pause state: no additional live build/test writes should be run while two
  agents may be competing for M365 write authority. Read-only review is fine.
- Existing live alert flow: `GAIL - New Signal Teams alert` is `Started` and
  may continue posting internal Teams alerts when real `CRM - New Signals`
  items are created. This closeout did not disable it.
- Next build gate after pause: B5 durable permission decision for the real
  `m365-interaction-agent` posture, including a competing-writer audit, then
  B6 source expansion.
- Latest handoff: [SESSION_TURNOVER_2026-06-25.md](SESSION_TURNOVER_2026-06-25.md).

## Approval Boundaries

No document in this repo approves tenant writes by itself.

Stop before app registration, app consent, permission changes, external sends,
guest/sharing changes, public forms, deletes, billing/client commitments,
Dynamics, Dataverse, premium Power Platform, Copilot connector setup, custom
actions, or unattended automation unless Adam gives a fresh explicit approval
for that exact scope, evidence target, and rollback path.

Narrow approved exception already used for the proof: one internal standard
Teams channel named `New Signal`, one standard Teams Power Automate connection
as Adam, and one create-only SharePoint-to-Teams alert flow. This does not
approve more proof items, external messaging, QUO, app registration, admin
consent, guest/sharing changes, or broad automation.

Pause override: while the competing-agent issue is unresolved, do not rely on
that narrow exception to run more writes. Adam must explicitly resume this lane
and confirm the other M365-writing agent is paused, separated, or intentionally
coordinated.

## Active References

- Master path: [MASTER_EXECUTION_MAP.md](MASTER_EXECUTION_MAP.md)
- Current plan: [docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md](docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md)
- New Signal setup: [docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md](docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md)
- Next build chunks: [docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md](docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md)
- Agent card: [docs/CARD_PLAN_AGENT_CONTROL_PLANE.md](docs/CARD_PLAN_AGENT_CONTROL_PLANE.md)
- Decisions card: [docs/CARD_PLAN_DECISIONS_GOVERNANCE.md](docs/CARD_PLAN_DECISIONS_GOVERNANCE.md)
- Agent readiness: [docs/AGENTIC_M365_READINESS.md](docs/AGENTIC_M365_READINESS.md)
- G0-G4 decisions: [docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md](docs/AGENTIC_M365_CHUNK_6_DECISION_LIST.md)
- CRM history/plan: [docs/CRM_EXECUTION_PLAN.md](docs/CRM_EXECUTION_PLAN.md)
- Operator manual: [docs/WORKSPACE_INSTRUCTION_MANUAL.md](docs/WORKSPACE_INSTRUCTION_MANUAL.md)
- Full index: [00_INDEX.md](00_INDEX.md)
- Latest handoff: [SESSION_TURNOVER_2026-06-25.md](SESSION_TURNOVER_2026-06-25.md)

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
