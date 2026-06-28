# Start Here

Date generated: 2026-06-24
Status: the only active startup document for this repo.

Read this file first, then open only the current working plan or the specific
reference needed for the task.

Update 2026-06-27: docs are aligned around one governed `M365 Interaction
Agent`. B1-B8 are live-proven: New Signal Teams alerting, triage evidence,
similar-record advisory, one `Suggested` Agent Action Log row, one-writer
decision, Guided AI Journey source proof, Journey CRM receipt acknowledgement,
lead-source display in Teams, and Journey replay/idempotency hardening.

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

Current completed lane:

```text
Journey/site signal -> CRM - New Signals -> New Signal Teams alert ->
Adam/operator triage -> M365 Interaction Agent proposal/evidence ->
Journey CRM receipt ack where requested
```

Vision alignment: treat M365 as the Guided AI Labs enterprise body and governed
execution substrate. Freedom remains the executive/coordinator layer, Guided AI
Labs Operating System remains the governance/autonomic layer, and Graphify
remains the relationship/context-graph layer. The local `G0-G4` gates map to
the organization-level `R0-R5` authority ladder; no current B8/B9/B10 work
enables R4 delegated autonomy.

Priority when resumed: one agent with governed M365 capabilities. B8 Journey
receipt/replay hardening is now live-proven. The remaining chunks in this
structured phase are B9 selected-signal operating triage and B10 QUO inbound
source proof. B9a local selected-signal operating readiness is executed; the
next B9 tenant touch is selected read-only triage after Adam chooses exact item
ids, source, or window. B10a local QUO inbound source readiness is executed;
B10b live source proof waits for exact number, event, ingress, secret,
retention, disable, and outbound-block approvals. Hiring roles, profile
libraries, and onboarding packet work are deferred until growth makes them
useful.

## Fast Startup

1. Run `git status --short`.
2. Read the latest handoff:
   [SESSION_TURNOVER_2026-06-25.md](SESSION_TURNOVER_2026-06-25.md).
3. Read the current working plan linked above.
4. Read the New Signal setup runbook if continuing the notification proof.
5. Read the next-build packet if planning beyond the first alert proof.
6. Confirm the target write surface and approval boundary before running any
   additional live write from this repo.
7. If Adam must type an approval phrase, select an account, complete MFA, choose
   a source item, or perform any other live interaction, open a clearly named
   visible window first. Do not expect Adam to infer which terminal, browser, or
   admin surface needs attention.
8. If you need the full pathway, read [MASTER_EXECUTION_MAP.md](MASTER_EXECUTION_MAP.md).
9. If you need the card backlog, read [docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md).
10. If the task mentions the Windows/Linux direct link, use the `direct-link`
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
- B5 one-writer posture: Decision Register `#6` and Agent Action Log `#10`.
- B6 Guided AI Journey source proof: CRM item `#21`, Teams alert, and Agent
  Action Log `#11`.
- B7 Journey CRM receipt proof: portal event
  `db8d3f91-002b-4729-b6ac-556ee5813d3d` created CRM item `#25`; M365 callback
  succeeded; Journey read back `crm_received`.
- Lead-source display proof: source event `journey-portal-event-1782447883236`
  created CRM item `#27` with `Lead source detail: Journey admin invite`; Teams
  alert flow posted successfully.
- B8a local Journey loop hardening packet:
  `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.md`.
  It proposes `PortalEventId` and `SourceCorrelationId`, defers
  `ReceiptStatus`, defines duplicate/replay handling, and prepares the future
  B8 live approval boundary without touching M365.
- B8b live Journey loop hardening proof:
  `inventory/m365-interaction-agent-b8/B8B_LIVE_PROOF_2026-06-27.md`.
  It added indexed `PortalEventId` and `SourceCorrelationId` fields, updated
  the live HTTP intake flow for pre-create idempotency, and proved one
  synthetic/internal Journey replay without creating a duplicate CRM item.
- B9a local selected-signal operating triage packet:
  `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.md`.
  It indexes prior B1/B6 packet evidence, creates queue and review CSV
  templates, defines operating labels, and keeps future tenant activity behind
  selected G0 read-only runs or per-item G1 approval.
- B10a local QUO inbound source proof packet:
  `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`.
  It defines QUO event mappings, ingress options, normalized CRM shape, duplicate
  policy, raw payload policy, live decision worksheet, proof checklist, and the
  future B10b approval boundary without touching QUO or Microsoft 365.
- B1 proof harness: `scripts/Invoke-M365NewSignalAlertProof.ps1` records local
  proof evidence and gates the one synthetic CRM create behind a typed approval.
- B2/B3 triage packet: `scripts/Invoke-M365NewSignalTriage.ps1` reads one
  signal, flags possible related CRM records, and writes local G0 evidence.
- B4 Suggested row: Agent Action Log row `#9` was created for CRM item `#19`
  with status `Suggested`; no CRM update, task, reminder, message, merge,
  permission, or external action was approved or performed.
- Existing live alert flow: `GAIL - New Signal Teams alert` is `Started` and
  may continue posting internal Teams alerts when real `CRM - New Signals`
  items are created. This closeout did not disable it.
- Existing live HTTP intake flow: `GAIL - Custom site intake to CRM
  (create-only, HTTP)` is `Started` and can create CRM rows from approved
  server-side website/Journey posts.
- Next build gate: refinement only unless Adam approves another live read/write
  scope. Current sequence is B9b selected read-only CRM triage after item
  selection, then B10b live QUO inbound proof only after exact
  number/event/ingress/secret/retention/disable and outbound-block approval.
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

Future live-write rule: do not rely on earlier proof approvals as blanket
approval for new work. Adam must explicitly approve the next live write scope,
target surface, evidence target, and rollback path.

Operator interaction rule: when approval, sign-in, MFA, source selection, or a
manual source proof is needed, the agent must launch or point to the exact
visible interaction surface before waiting on Adam. For M365 Interaction Agent
approval phrases, use
`scripts/Start-M365InteractionAgentApprovalWindow.ps1` so the window title,
scope, stop conditions, and local approval evidence are explicit.

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
