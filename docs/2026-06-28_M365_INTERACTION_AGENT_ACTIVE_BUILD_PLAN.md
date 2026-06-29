# M365 Interaction Agent Active Build Plan

Date: 2026-06-28

Status: Active successor plan. Supersedes
`docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md` for current
planning and startup context. B10b is complete as of 2026-06-28. B10c.0 QUO
API key readiness is complete locally as of 2026-06-28. B10c.0a QUO CRM intake
prompt and placement is complete as design-only guidance as of 2026-06-28, with
message-only calls kept out of CRM and consented follow-up inquiries routed to
future `CRM - New Signals` intake. D1 documentation currentness review is
complete as of 2026-06-28.

Owner: Adam.

This file is intentionally compact, but it is now detailed enough to execute
from. The older chunk file remains the historical B1-B10b proof ledger and
should only be opened when auditing prior decisions, exact acceptance criteria,
or historical proof detail.

## How To Read This

Default startup path:

1. `START_HERE.md`
2. `SESSION_TURNOVER_2026-06-28.md`
3. This active build plan
4. The one evidence/config file named by the current task

Do not load old stage packets, exports, inventory folders, or the superseded
chunk ledger unless the task specifically asks for proof history or a previous
acceptance boundary.

This plan is not standing approval for live tenant/source work. Any live read,
write, connector, webhook, app registration, consent grant, secret access,
external send, source expansion, or production bridge work still needs a fresh
approval boundary.

## Fixed Vision

The current build is one governed `M365 Interaction Agent`, not a helper-bot
stack.

M365 is the Guided AI Labs enterprise body: records, collaboration,
communications, tasks, files, and governed execution surfaces. Freedom remains
the executive/coordinator layer, GAIL OS remains the governance and autonomic
management layer, and Graphify remains the relationship/context graph.

This repo owns the Microsoft 365 execution and evidence lane. It should leave
stable source ids, event ids, relationship hints, approval labels, evidence
packets, and disable paths for those higher layers to consume later. It should
not become the GAIL OS production connector yet.

Authority map:

| Organization level | Local gate | Meaning here |
|---|---|---|
| R0 Observe | G0 | Read, classify, summarize, detect gaps, write local evidence. |
| R1 Propose | G1 | Prepare or write supervised `Suggested` rows only. |
| R2 Internal Act | G2 | Approved internal M365 writes with evidence and rollback/pause note. |
| R3 Restricted | G3 | Connector, access, callback, external, or sensitive work after exact approval. |
| R4 Delegated Autonomous | Not enabled | Future separate decision; not enabled by this plan. |
| R5 Human Only | G4 blocked | Adam-only commitments, legal/billing, admin/access, deletes/merges, external sends, and any R4 delegation. |

## Current State

B1-B9 G0 are live-proven for the first signal lane:

```text
Journey/site signal -> CRM - New Signals -> New Signal Teams alert
-> selected triage/advisory -> optional Suggested row -> evidence
```

Completed proof/readiness:

- B1 New Signal Teams alert proof.
- B2/B3 selected signal triage and similar-record advisory.
- B4 one approved `Suggested` Agent Action Log row.
- B5 durable one-writer posture.
- B6 Guided AI Journey source proof.
- B7 Journey CRM receipt acknowledgement and lead-source display.
- B8 Journey replay/idempotency hardening.
- B9 selected internal G0 operating triage.
- B10a local QUO inbound source readiness packet.
- B10b QUO implementation-ready source contract and synthetic fixture design.
- B10c.0 QUO API key local import and dry-run readiness evidence; no live QUO
  API read was performed.
- B10c.0a QUO/Sona CRM intake prompt and SharePoint placement guidance,
  including the `CreateCrmSignal` gate that keeps message-only calls in QUO and
  routes consented follow-up inquiries to future CRM intake; no live QUO or CRM
  configuration was changed.
- Chunk 20G GAIL OS bridge placement and one-writer framing.
- D0 documentation cleanup and token-friendly successor plan, this file.
- D1 documentation currentness review, startup/index rerouting, and June 28
  turnover creation.
- D2 night box-up, including external `01 Work Tracking` ledger refresh.

Live/transitional surfaces that may continue operating:

- `GAIL - New Signal Teams alert` posts internal Teams alerts for new CRM
  signals.
- `GAIL - Custom site intake to CRM (create-only, HTTP)` can create approved
  website/Journey CRM rows.

These flows are Adam-approved transitional proof infrastructure. They are not
autonomous GAIL OS Connector execution and do not open Phase 4.

Cross-repo/direct-link context as of 2026-06-28:

- Linux M365 CLI authentication is working through a tenant-local delegated app
  for setup/read-only proof. This does not resolve the production Phase 4 app
  registration/consent gate.
- GAIL OS CTP-2 local dry-run proof is complete, including M365 bridge dry-run
  evidence and authority escalation probes.
- A personal-credit Azure pilot now hosts healthy GAIL OS and Graphify Container
  Apps, and Graphify persistence is mounted on Azure Files.
- Upstream Chunk 5.5 added `docs/2026-06-28 - M365 CNS Source Surface Map.md`
  as Phase 5 CNS/GAIL OS connector-planning context. Read it alongside, not
  over top of, the transitional Power Automate proof-flow state in this plan.
- These facts are useful for later packaging and Phase 4 prep, but no M365
  production connector write path is open.

## Current Build Chunks

| Chunk | Scope | Status | What Opens It |
|---|---|---|---|
| D0 | Documentation cleanup and token-friendly plan split | Complete | Adam requested cleanup before next build work |
| D1 | Documentation currentness review and pause point | Complete | Startup/index/turnover/docs-status refreshed; no docs deleted |
| D2 | Night box-up and work-tracking ledger refresh | Complete | Startup handoff and external `01 Work Tracking` latest/log refreshed before commit/push |
| B10b | QUO implementation-ready placeholder/design pack | Complete | Source contract: `docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`; config: `config/M365_INTERACTION_AGENT_B10B_QUO_SOURCE_CONTRACT.json` |
| B10c.0 | QUO API key local readiness | Complete local-only | Key imported to ignored `.local/quo-ingress/`; readiness doc: `docs/2026-06-28_QUO_API_KEY_READINESS.md`; config: `config/M365_INTERACTION_AGENT_B10C_QUO_API_KEY_READINESS.json`; dry-run evidence created with no API call |
| B10c.0a | QUO CRM intake prompt and placement | Complete design-only | Prompt/placement doc: `docs/2026-06-28_QUO_CRM_INTAKE_PROMPT.md`; Sona distinguishes message-only from consented follow-up inquiry; future ingress writes `CRM - New Signals` with `IntakeSource = QUO` only when `CreateCrmSignal: true` |
| B10c.1+ | Low-volume QUO live source proof | Later | Exact QUO number/event/ingress/secret/retention/disable/outbound-block approval |
| B11 | Normal operating cadence for selected signals | Next recommended operating chunk | Adam selects whether to practice real G0 review before more source expansion |
| Phase 4 | GAIL OS Connector registry and M365 production write path | Blocked | Production connector app/consent posture resolved, GAIL OS API approved for the connector environment, explicit Phase 4 authorization |

The current structured phase closed when B10b finished, and B10c.0 has now
captured the key readiness layer without opening ingestion. B10c.0a adds the
Sona prompt and SharePoint/CRM intake placement without touching QUO or M365.
The next default move is still B11 operating cadence, unless Adam explicitly
pulls B10c.1+ forward for low-volume QUO live proof under a fresh exact approval
boundary.

## Execution Rhythm

Every chunk should move through the same small control loop:

1. Frame the exact authority boundary.
2. Execute only the approved local/docs/live scope.
3. Test the artifacts and any live proof explicitly allowed for that chunk.
4. Lock down the plan, evidence, stop conditions, and next gate.
5. Review `git status` and `git diff --check`.
6. Commit and push only after the scope is clean and Adam has asked to publish.

No chunk is complete until its status is updated in this file and any companion
docs that another agent would naturally open. Historical/generated proof files
should not be rewritten just to make old wording match the current plan.

Recommended verification commands for documentation chunks:

```powershell
git status --short --branch
git diff --check
rg -n "[ \t]+$" START_HERE.md MASTER_EXECUTION_MAP.md 00_INDEX.md docs
```

For any chunk that creates or modifies Markdown, also run a lightweight fence
balance check against the changed files before commit.

## B10b Definition

B10b is documentation/design only. It must make QUO implementation-ready without
requiring Adam to figure out the QUO API yet.

Authority: G0/R0 design, mapping, and local evidence only.

Status: Complete on 2026-06-28. No QUO credential, portal, API, webhook, phone
number, or live event was needed or used.

Primary goal: make the future QUO source boring to implement later by defining
the contract, mapping, duplicates, evidence, and disable/revoke expectations now.

Allowed in B10b:

- define QUO event taxonomy;
- define the normalized source event contract;
- map future QUO events into `CRM - New Signals`;
- define duplicate/idempotency rules;
- define raw payload retention, redaction, and evidence expectations;
- define visible approval, disable, revoke, and owner paths;
- define synthetic/no-real-client fixture expectations;
- update docs/config to mark the live proof as B10c.1/later.

Not allowed in B10b:

- connect to QUO;
- inspect, request, store, or infer QUO secrets;
- create webhooks or connectors;
- call QUO APIs;
- write CRM rows;
- post Teams messages;
- process real phone/SMS/voicemail traffic;
- send outbound SMS, callbacks, replies, or QUO API messages.

Completed B10b outputs:

- a concise QUO source contract/design doc:
  `docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`;
- a machine-readable companion config:
  `config/M365_INTERACTION_AGENT_B10B_QUO_SOURCE_CONTRACT.json`;
- a future B10c approval checklist;
- a synthetic fixture shape that does not contain real QUO payloads;
- updated current-state references pointing to B10b as complete;
- a clear statement that B10c remains gated.

Recommended B10b work packets:

| Packet | Name | Output | Acceptance |
|---|---|---|---|
| B10b.1 | Event taxonomy | QUO event class table | Missed call, voicemail, inbound SMS, completed call summary, and contact update are modeled. |
| B10b.2 | Normalized source contract | Field contract and required/optional rules | Minimum normalized fields below are present, with source ids and timestamps clearly defined. |
| B10b.3 | CRM mapping | `CRM - New Signals` mapping table | Every modeled QUO event has an `IntakeSource = QUO` path or an explicit "do not create" reason. |
| B10b.4 | Dedupe/idempotency | `dedupeKey` rule and replay behavior | Replayed events do not create a second New Signal unless the dedupe key differs by design. |
| B10b.5 | Evidence and privacy | Retention/redaction matrix | Raw payload, transcript, recording link, and phone number handling are defined before live proof. |
| B10b.6 | Control surface | owner, disable, revoke, and approval checklist | A human can see where to pause the source before any connector exists. |
| B10b.7 | Synthetic fixtures | fixture spec or sample-only shapes | Samples are clearly fake and contain no real phone numbers, clients, secrets, or QUO payloads. |
| B10b.8 | Routing updates | active plan and relevant index/status docs | B10b can be marked complete without opening the old chunk ledger by default. |

Minimum QUO event classes to model:

- missed call;
- voicemail;
- inbound SMS;
- completed call summary;
- contact update.

Minimum normalized fields:

- `sourceSystem = QUO`;
- `sourceEventId`;
- `sourceConversationId` or future equivalent;
- `sourceEventType`;
- `eventOccurredAt`;
- `receivedAt`;
- `businessNumber`;
- `callerOrSenderNumber`;
- `callerOrSenderName`;
- `messageOrSummary`;
- `recordingOrTranscriptLink`, if available later;
- `rawPayloadEvidenceRef`, if retained later;
- `dedupeKey`;
- `outboundBlocked = true`.

CRM target posture:

- target list: `CRM - New Signals`;
- target `IntakeSource`: `QUO`;
- one future QUO source event should create or map to exactly one CRM signal;
- Teams alerting and triage should reuse the existing New Signal lane;
- no QUO path may bypass `CRM - New Signals`.

B10b validation checklist:

- contract file exists and identifies itself as design-only;
- no real QUO secret, endpoint, bearer token, webhook signing secret, or phone
  number is present;
- all sample phone numbers are fake placeholders;
- `outboundBlocked = true` is explicit in the normalized contract;
- B10c approval checklist is complete enough for Adam to approve later without
  reverse-engineering this conversation;
- current docs say B10b is complete and B10c remains gated;
- `git diff --check` passes;
- Markdown fences are balanced in changed Markdown files.

B10b lockdown note:

When B10b completes, the repo should be safer than before: QUO is represented as
a future source with a clear shape, but there is still no live QUO integration
and no new write authority.

B10b result: complete. The repo now has a human-readable source contract and a
machine-readable config contract, both design-only, both fake-fixture-only, and
both keeping B10c behind fresh approval.

## B10c.0a QUO CRM Intake Prompt

B10c.0a status: complete design-only. The repo now has a clear Sona intake
prompt and placement note for the QUO call flow Adam showed:

```text
Incoming call -> Business hours
During hours -> Ring users -> if missed -> Sona -> fallback voicemail
After hours -> Sona -> fallback voicemail
```

Prompt/placement doc:
`docs/2026-06-28_QUO_CRM_INTAKE_PROMPT.md`.

Authority: G0/R0 design and local documentation only.

Placement rule:

- paste the Sona prompt into both QUO `Sona` nodes: missed-call handling during
  business hours and direct after-hours handling;
- keep voicemail as fallback;
- make Sona ask the caller to choose between a quick message and a consented
  follow-up inquiry;
- leave quick-message calls in QUO's in-app message handling, including
  "please have Adam call me" calls;
- do not connect Sona directly to SharePoint, Teams, SMS reply, callback, email
  send, or any other outbound automation;
- later B10c.1+ ingress should transform only `CreateCrmSignal: true` Sona
  handoffs into one `CRM - New Signals` item with `IntakeSource = QUO`, then
  reuse the existing New Signal Teams alert lane.

SharePoint operator placement:

```text
Operations Cockpit
-> CRM Command Center
-> QUO Intake
-> CRM - New Signals filtered where IntakeSource = QUO
```

B10c.0a did not configure QUO, call QUO APIs, read call/SMS/voicemail traffic,
write CRM, post Teams, create webhooks, or send outbound QUO actions.

## B10c Gate

B10c.0 status: complete local-only. The QUO API key was imported from Adam's
local text file into `.local/quo-ingress/quo-api-key.secret` using Windows DPAPI
CurrentUser encryption. The companion metadata lives under `.local` and does
not contain the key. The dry-run readiness probe wrote local evidence under
`inventory/m365-interaction-agent-b10/` and performed no QUO API call.

B10c.0 artifacts:

- key import helper: `scripts/quo/Set-QuoLocalApiKey.ps1`;
- read-only readiness probe: `scripts/quo/Test-QuoApiKeyReadiness.ps1`;
- readiness doc: `docs/2026-06-28_QUO_API_KEY_READINESS.md`;
- readiness config:
  `config/M365_INTERACTION_AGENT_B10C_QUO_API_KEY_READINESS.json`;
- dry-run evidence:
  `inventory/m365-interaction-agent-b10/b10c-quo-api-key-readiness-*.json`.

B10c.0 did not create webhooks, read phone traffic, write CRM, post Teams,
store raw QUO payloads, or send outbound QUO actions.

B10c.1+ can only start after Adam approves all of the following:

- exact QUO business intake number(s);
- exact first event class;
- ingress pattern;
- secret/signature storage and revoke path;
- raw payload evidence location and retention/redaction rule;
- duplicate/idempotency rule;
- owner and disable path;
- no-real-client/internal test scope;
- confirmation that outbound SMS, callback, reply, and QUO API send remain
  blocked.

Authority: G3 restricted source proof. B10c.1+ is not opened by completing
B10b or by storing the API key in B10c.0. It needs a fresh visible approval
capture and exact live-source boundary.

Expected B10c.1+ inputs, after approval:

- B10b source contract;
- B10c.0 key readiness doc and probe script;
- exact approved QUO business number or internal test number;
- exact first event class to prove;
- approved ingress surface;
- approved secret/signature storage and revoke path;
- approved raw payload evidence location and retention rule;
- owner/disable path that Adam can see.

B10c.1+ acceptance, when approved later:

```text
one approved no-real-client/internal consented QUO/Sona inquiry
-> CreateCrmSignal: true
-> one CRM - New Signals item or one duplicate match
-> one New Signal Teams alert when a new CRM item is created
-> one local triage/evidence packet
-> zero outbound QUO/client action
```

Recommended B10c.1+ work packets, only after explicit approval:

| Packet | Name | Output | Acceptance |
|---|---|---|---|
| B10c.1 | Visible approval capture | approval evidence packet | Adam can see exactly which QUO number/event/ingress is being touched. |
| B10c.2 | Disabled-first ingress | configured but paused/staged source path | Source can be disabled before and after the proof. |
| B10c.3 | Internal event proof | one internal/no-real-client QUO event | The event is captured without external client impact. |
| B10c.4 | CRM mapping proof | one New Signal item or duplicate match | The CRM result follows the B10b contract. |
| B10c.5 | Teams alert proof | one internal New Signal alert, if new CRM item created | Existing alert lane is reused. |
| B10c.6 | Replay/duplicate proof | one replay or duplicate test | Idempotency behavior matches B10b. |
| B10c.7 | Disable/revoke proof | pause/revoke evidence | Adam has a visible stop path. |
| B10c.8 | Evidence closeout | local proof packet and doc updates | B10c is either complete, paused, or rolled back with a clear reason. |

B10c.1+ validation checklist:

- approved source boundary is captured before touching QUO;
- no real client traffic is used;
- no outbound QUO/SMS/callback/reply/API send occurs;
- only the approved event class is processed;
- CRM and Teams behavior matches the existing New Signal lane;
- evidence includes timestamps, source ids, dedupe key, owner, and disable path;
- any temporary connector or flow is disabled, documented, or intentionally
  left operating inside the approved boundary.

## B11 Direction

B11 is optional and should be chosen after B10b. It turns the proven lane into a
small operating cadence before broader automation:

- select one or more real low-risk CRM signals for G0 review only;
- produce triage/advisory evidence;
- optionally prepare G1 `Suggested` rows after per-item approval;
- verify owner, next action, duplicate hints, source quality, and stale follow-up
  handling;
- record what the agent is useful for before adding more write power.

This is probably the right bridge between source expansion and real operations:
more practice with low-risk signals before any production connector posture.

Authority: default G0/R0, with optional G1 per-item approval for `Suggested`
rows. B11 does not add a new external source by itself.

Recommended B11 work packets:

| Packet | Name | Output | Acceptance |
|---|---|---|---|
| B11.1 | Signal selection | approved small batch | Adam chooses the CRM signals or a visible window is opened for him to choose them. |
| B11.2 | G0 triage | local triage notes/evidence | Owner, source quality, next action, duplicate hints, and stale follow-up risk are assessed. |
| B11.3 | Similar-record review | relationship/context hints | The agent finds useful relationship clues without writing live changes. |
| B11.4 | Optional G1 suggestions | `Suggested` rows only after approval | No direct action is taken; suggested rows are clearly supervised. |
| B11.5 | Cadence report | short operating-readiness note | The repo records what worked, what was noisy, and what should be automated later. |

B11 acceptance:

```text
Adam-approved low-risk signal batch
-> G0 triage/advisory evidence
-> optional per-item G1 Suggested rows
-> no external send
-> clear recommendation for the next operating cadence
```

B11 validation checklist:

- no unapproved signal or client record is included;
- any live reads stay inside the approved surface;
- any writes are limited to explicitly approved `Suggested` rows;
- evidence is usable by a later operating agent without reading old chat;
- the active plan is updated with either "continue cadence" or "move to next
  source/Phase 4 prep" recommendation.

B11 lockdown note:

B11 is where the agent should earn trust by being useful on mundane operations.
The goal is not more automation; the goal is better judgment about what should
be automated next.

## Phase 4 Boundary

Phase 4 is not open.

Phase 4 is the production GAIL OS Connector posture. It should remain separate
from transitional Power Automate proof work and from B10/B11 operating practice.

Production bridge implementation requires:

- BLK-005 resolved: M365 production connector app registration and consent
  posture confirmed;
- GAIL OS HTTP API live in the approved production connector environment;
- GAIL OS Connector registry available;
- one writer per M365 write surface;
- signed authority envelope pattern tested;
- evidence packet return path tested;
- explicit Phase 4 authorization from Adam.

Existing Power Automate proof flows must be registered, retired, or replaced
before any Phase 4 connector writes go live.

Allowed Phase 4 prep while blocked:

- refine connector registry requirements in docs;
- refine authority envelope fields in docs;
- define evidence packet return expectations;
- list transitional Power Automate flows that will need registration,
  retirement, or replacement;
- identify M365 write surfaces that require one-writer enforcement.

Not allowed before Phase 4 opens:

- create production GAIL OS connector writes;
- grant new app permissions or consent;
- enable unattended M365 write automation;
- bypass the existing New Signal lane;
- treat Power Automate proof flows as autonomous GAIL OS execution.

Phase 4 opening checklist, for later:

| Gate | Required State |
|---|---|
| BLK-005 | App registration and consent posture resolved. |
| GAIL OS API | Stable HTTP API exists and is reachable from the approved environment. |
| Connector registry | Source/system/action registry exists with owner and disable metadata. |
| Authority envelope | R/G level, actor, source, target, justification, and evidence ids are required. |
| One writer | Each M365 write surface has exactly one production writer. |
| Evidence return | Every write returns or records an evidence packet. |
| Explicit authorization | Adam approves Phase 4 in a visible approval surface. |

## Current Source Map

Use these files by default:

- Startup: `START_HERE.md`
- Master pathway: `MASTER_EXECUTION_MAP.md`
- Active build plan: this file
- Documentation status:
  `docs/2026-06-28_DOCUMENTATION_STATUS_REVIEW.md`
- Current turnover:
  `SESSION_TURNOVER_2026-06-28.md`
- External work tracking:
  `C:\Users\adamg\01. Code Projects\01 Work Tracking\AG Operations Workspace Setup\latest.md`
- QUO source contract:
  `docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`
- QUO source contract config:
  `config/M365_INTERACTION_AGENT_B10B_QUO_SOURCE_CONTRACT.json`
- QUO API key readiness:
  `docs/2026-06-28_QUO_API_KEY_READINESS.md`
- QUO API key readiness config:
  `config/M365_INTERACTION_AGENT_B10C_QUO_API_KEY_READINESS.json`
- QUO CRM intake prompt and placement:
  `docs/2026-06-28_QUO_CRM_INTAKE_PROMPT.md`
- Product/governance plan:
  `docs/2026-06-24_AGENTIC_ASSISTANCE_APPROVAL_LOOP_PLAN.md`
- New Signal setup/proof reference:
  `docs/2026-06-24_NEW_SIGNAL_TEAMS_ALERT_SETUP.md`
- GAIL OS bridge placement:
  `docs/2026-06-28_M365_GAIL_OS_BRIDGE_PLACEMENT_REGISTER.md`
- One-writer audit:
  `docs/2026-06-28_M365_ONE_WRITER_AUDIT.md`
- M365 CNS source surface map:
  `docs/2026-06-28 - M365 CNS Source Surface Map.md`
- Historical chunk ledger:
  `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`

Use inventory files only when proving or auditing a specific completed chunk.

## Stop Conditions

Stop before any work that requires app registration, app consent, permission
changes, external sends, guest/sharing changes, public forms, deletes,
billing/client commitments, Dynamics, Dataverse, premium Power Platform, Copilot
connector setup, custom actions, QUO setup, source webhooks, source secrets, or
unattended automation.

B10c.0 is the narrow exception already completed for QUO source secret handling:
local encrypted storage and dry-run readiness only. It does not authorize live
QUO reads beyond an explicitly invoked read-only probe, webhook setup, source
ingestion, CRM writes, Teams posts, or outbound QUO actions.

If Adam must approve, sign in, complete MFA, choose a source item, or run a
manual source proof, open or name the exact visible window/browser/admin surface
first. For M365 Interaction Agent approval captures, use
`scripts/Start-M365InteractionAgentApprovalWindow.ps1`.
