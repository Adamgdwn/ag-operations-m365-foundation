# M365 Agentic IO And GAIL OS Bridge Contract

Date: 2026-06-29
Status: Active bridge-planning contract
Scope: Documentation and structured contract only. No Microsoft 365 calls,
tenant writes, app registrations, consent grants, permission changes, source
webhooks, external sends, or unattended automation.
Owner: Adam Goodwin

## Purpose

This packet imports Adam's 2026-06-29 direction into the Microsoft 365
foundation lane:

- Microsoft 365 must remain a highly functional daily workspace for the team.
- Microsoft 365 must also be ready for large agentic push-pull activity:
  information out, information in, triggered actions, and deliverables out.
- Freedom may request information and propose work, but task completion that
  touches Microsoft 365 should route through Guided AI Labs Operating System
  authority, connector registration, and evidence.

The shorthand rule:

```text
Freedom coordinates intent.
GAIL OS authorizes and records authority.
M365 executes approved enterprise IO and returns evidence.
Graphify accelerates relationship context and approved graph-memory learning.
```

This document does not open Phase 4 production connector execution. It makes the
contract crisp enough that future connector work can be fast without becoming a
second writer or a loose permission layer.

## Reviewed Surface

This pass reviewed the active repo-local routing and bridge documents:

- `AGENTS.md`
- `START_HERE.md`
- `docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md`
- `docs/2026-06-28_M365_GAIL_OS_BRIDGE_PLACEMENT_REGISTER.md`
- `docs/2026-06-28_M365_ONE_WRITER_AUDIT.md`
- `docs/2026-06-28 - M365 CNS Source Surface Map.md`
- `docs/AGENTIC_M365_READINESS.md`
- `M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md`
- `config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json`
- `config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json`

Finding:

- The repo already has the right CNS spine: M365 is the enterprise body, GAIL
  OS is the authority/evidence layer, and Freedom is not the M365 writer.
- The active docs need a sharper IO contract for broad agentic use, especially
  for Freedom-origin requests, triggered actions, deliverables, and Graphify's
  refined relationship-memory boundary.

## Two Operating Modes

M365 has two valid operating modes. They must coexist.

| Mode | User | Purpose | Guardrail |
|---|---|---|---|
| Team daily workspace | Adam and the Guided AI Labs team | Regular use of CRM, Planner, Teams, SharePoint, Bookings, Forms, files, decisions, and follow-up records | Human-owned workspace rules remain valid; agents must not make the human UI awkward just to satisfy a connector model |
| Agentic IO substrate | GAIL OS connectors and approved local operators | High-volume information reads, source intake, action proposals, internal writes, evidence return, and deliverable placement | Every write-capable lane needs source refs, authority envelopes, evidence packets, one writer, idempotency, stop paths, and rollback/pause notes |

The daily workspace is not a demo surface. It must stay useful to people. The
agentic substrate is not a shortcut around governance. It must be powerful
because it is bounded, observable, and easy to stop.

## Required Request Route

Freedom-origin M365 work must use this route:

```text
Freedom request or mission proposal
  -> GAIL OS classification and authority decision
  -> registered M365 connector or approved supervised operator
  -> M365 read, write, trigger, or deliverable placement
  -> EvidencePacket returned to GAIL OS
  -> optional relationship-memory candidate to Graphify
  -> status/result available back to Freedom
```

Direct Freedom-to-M365 writes are not an approved lane.

Direct local scripts may still be used for supervised proof or setup, but they
remain repo-local operators with explicit gates. They do not become a production
Freedom bridge, and they do not bypass the future GAIL OS Connector registry.

## Agentic IO Lanes

### IO-1 Information Out

Purpose: pull structured state from M365 into GAIL OS/Freedom/Graphify-aware
reasoning.

Examples:

- read CRM New Signals, organizations, contacts, engagements, lifecycle, and
  touchpoints;
- read Planner tasks and status;
- read SharePoint evidence, decisions, handoffs, and workspace records;
- read Forms, Bookings, Journey, QUO, support, or other source records after
  the exact source gate is open;
- summarize Teams or Exchange only inside approved read surfaces.

Default authority:

- G0/R0 for selected read-only review, classification, summarization, and local
  evidence;
- G3/R3 when the read involves external/client-sensitive source expansion,
  mailbox bodies, connector app posture, or source credentials.

Required evidence:

- `source_ref`;
- selected surface and item/window;
- actor and authority level;
- observed timestamp;
- sanitized payload summary or evidence pointer;
- retention/redaction note when client, mailbox, call, transcript, or phone
  data is involved.

### IO-2 Information In

Purpose: accept structured source events or approved updates into M365.

Examples:

- website/Journey/QUO source events into `CRM - New Signals`;
- approved internal CRM updates;
- approved Decision Register records;
- approved Agent Action Log rows;
- approved support or operations rows.

Default authority:

- G1/R1 for proposals and `Suggested` rows;
- G2/R2 for approved internal records;
- G3/R3 for external/client-sensitive, source webhook, connector, public form,
  mailbox, permission, or callback work.

Required evidence:

- source event id or dedupe key;
- source system;
- target surface;
- normalized field contract;
- idempotency result;
- approval reference when G2 or above;
- rollback or pause note;
- returned M365 item/link when available.

### IO-3 Actions Triggered

Purpose: trigger work from M365 signals without hiding the authority step.

Examples:

- New Signal -> Teams internal alert -> triage/advisory -> proposed action;
- CRM lifecycle change -> Planner follow-up candidate;
- support row -> draft response candidate;
- Decision Register item -> connector posture change candidate;
- source event -> mission proposal for GAIL OS.

Default authority:

- trigger detection may be G0/R0;
- writing a `Suggested` row is G1/R1;
- internal tasks, rows, or notices are G2/R2 after named approval;
- external sends, public forms, guests, sharing, app consent, permissions,
  tenant policy, callbacks, or client commitments are G3/R3 or G4/R5 as
  documented.

Required evidence:

- trigger source;
- classification result;
- proposed action;
- authority gate result;
- action id;
- stop condition;
- result or blocked reason.

### IO-4 Deliverables Out

Purpose: place outputs where humans and later agents can use them.

Examples:

- evidence packets into SharePoint evidence libraries;
- completed summaries into Agent Action Log;
- Planner tasks and status changes;
- Teams internal notices;
- SharePoint files or folders in approved paths;
- mailbox drafts only after mailbox readiness and approval.

Default authority:

- G1/R1 for draft/proposal/evidence-only records when a lane has standing
  approval;
- G2/R2 for internal deliverables after named approval;
- G3/R3 for external/client-facing output, mailbox drafts/sends, sharing, or
  public/client forms;
- G4/R5 blocked for autonomous deletes, broad grants, secrets, break-glass,
  legal/billing commitments, and R4 delegated autonomy.

Required evidence:

- deliverable type;
- destination;
- link or item id;
- approval and actor;
- created/updated timestamp;
- rollback, archive, correction, or supersession path.

## Graphify Boundary In This Repo

The previous shorthand "Graphify read-only" should be read narrowly:

- Graphify does not approve actions.
- Graphify does not execute M365 writes.
- Graphify does not become a raw M365 storage clone.
- Graphify may receive approved relationship-memory candidates or graph facts
  when GAIL OS and the relevant source contract permit that learning lane.

For M365, Graphify should accelerate relationship context and stale-claim
awareness. It should not hold M365 authority, operate M365 connectors, or
replace M365 source-of-truth records.

## One-Writer Rule

Every M365 write surface needs exactly one production agentic writer.

Current transitional proof flows may keep running only within their documented
approval boundary. Before Phase 4 production connector writes go live, each
proof flow must be explicitly registered under the GAIL OS Connector model,
retired, or replaced.

No agent may create an alternate writer because it is convenient.

## Contract Fields For Future Connector Work

Any future GAIL OS/M365 connector packet should define these fields before
implementation:

| Field | Requirement |
|---|---|
| `requesting_layer` | `freedom`, `gail-os`, `operator`, `source-system`, or another named layer |
| `authority_owner` | Usually `gail-os`; never implicit chat context |
| `source_ref` | Stable source system, item/event id, and observed timestamp |
| `target_surface` | M365 surface, list/library/channel/plan/mailbox/form, and operation |
| `authority_level` | G0-G4 and R0-R5 mapping |
| `execution_mode` | `dry-run`, `supervised-live`, or future approved connector mode |
| `idempotency_key` | Required for source intake, task creation, and replay-sensitive actions |
| `evidence_packet` | Result, links, actor, approval, timestamps, and rollback/pause note |
| `stop_triggers` | Permission drift, duplicate writer, missing evidence, stale approval, wrong account, external impact, or source mismatch |
| `disable_path` | How Adam pauses or revokes the lane |

## Readiness Gaps

The repo is architecturally pointed the right way, but these gates remain before
large production agentic IO:

| Gap | Status | Meaning |
|---|---|---|
| BLK-005 production M365 app/consent posture | Blocked/unknown | No production connector writes until app registration, consent, scopes, and revocation path are confirmed |
| GAIL OS production connector registry | Not open in this repo | M365 should prepare contracts, not implement a bypass registry |
| Authority envelope integration | Prep only | Future connector must require authority envelopes before writes |
| Evidence packet return path | Prep only | Every write/read proof needs durable evidence back to GAIL OS |
| One-writer transition for proof flows | Open | Existing Power Automate proof flows must be registered, retired, or replaced before Phase 4 |
| Graphify relationship-memory lane | Design needed | M365 may emit approved relationship candidates, but Graphify cannot become authority or execution |

## Context-Window Friendly Chunks

### MIO-0 - Contract Alignment

Status: Task complete by this packet.

Scope:

- add the active IO/GAIL OS bridge contract;
- add a structured companion config;
- update startup and source-map routing;
- make Freedom-through-GAIL routing explicit.

Validation:

- local docs/config validation only;
- no M365 calls;
- no tenant writes.

### MIO-1 - Machine-Readable IO Surface Review

Next recommended prep chunk.

Scope:

- compare `config/M365_AGENTIC_IO_GAIL_OS_BRIDGE_CONTRACT.json` against current
  Stage 9 and source-surface configs;
- ensure every surface has read boundary, write boundary, authority level,
  evidence target, idempotency expectation, and stop path;
- add a local preflight check if drift appears.

Stop before:

- app registration;
- consent;
- live connector execution;
- source webhooks;
- external sends.

### MIO-2 - GAIL OS Dry-Run Handoff Shape

Scope:

- define sample dry-run request/response records for Freedom -> GAIL OS -> M365
  -> GAIL OS -> Freedom;
- include successful, blocked, duplicate, stale approval, and missing evidence
  cases.

Stop before:

- real M365 reads or writes unless Adam names exact item/window and approval
  target.

### MIO-3 - Selected G0 Pull Proof

Scope:

- choose one exact internal M365 item/window;
- perform selected read-only review through existing supervised pattern;
- emit local evidence that a future GAIL OS connector could consume.

Requires:

- Adam selection of exact item/window;
- visible interaction surface if sign-in/MFA is needed.

### MIO-4 - G1 Proposal/Log Proof Through GAIL OS Shape

Scope:

- prepare or write a `Suggested` row only inside the existing approval pattern;
- show how GAIL OS would own the authority envelope and evidence.

Requires:

- exact selected source item;
- approval boundary for any live Suggested row.

### MIO-5 - G2 Internal Write Pilot

Scope:

- only after earlier dry-run and G1 evidence;
- one named internal List/Planner/SharePoint write;
- evidence return and rollback/pause note.

Requires:

- explicit Adam approval for exact surface, operation, evidence target, and
  rollback path;
- no direct Freedom write path.

## Stop Conditions

Stop before:

- direct Freedom-to-M365 writes;
- production GAIL OS connector writes;
- app registration, app consent, permission changes, Selected grants, Exchange
  Application RBAC, tenant policy changes, or setup-helper grant expansion;
- external sends, callbacks, public/client forms, guest invitations, sharing
  changes, deletes, broad grants, secrets, break-glass, legal/billing/client
  commitments, or R4 delegated autonomy;
- Graphify ingest of M365 facts unless an approved relationship-memory learning
  lane exists for the exact source and field set.

## Closeout

This packet makes the current direction explicit without opening live execution:

- M365 remains the team workspace and enterprise body.
- Agentic IO is expected to be broad and powerful.
- Freedom may coordinate and consume results.
- GAIL OS remains the authority and evidence spine for task completion.
- M365 remains the execution substrate.
- Graphify accelerates relationship context, not authority or execution.
