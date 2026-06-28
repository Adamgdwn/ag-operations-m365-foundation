# B10 QUO Inbound Source Proof Packet

Generated: 2026-06-27T09:49:29.7389323-06:00
Mode: local-only
Safety: No QUO connection, no Microsoft 365 connection, no CRM write, no Teams post, no flow update, no HTTP send, no .local secret read, no outbound phone/SMS action.

## Purpose

Bring QUO forward as the first Phone / Voice / Text sensory portal into the existing CRM -> Teams -> triage lane, while keeping all outbound phone/SMS behavior blocked.

## Current State

- QUO live hookup: none approved
- CRM source list: `CRM - New Signals`
- Teams alert flow: `GAIL - New Signal Teams alert` (Started)
- Triage lane: B2/B3/B4 New Signal triage and Suggested row workflow
- Outbound status: Blocked for B10 MVP

## Source Principles

- QUO is a sensory portal, not a separate CRM and not a separate phone bot.
- CRM - New Signals remains the source of truth for new work.
- Teams remains the internal attention surface.
- The M365 Interaction Agent produces evidence and supervised suggestions only.
- Freedom, Guided AI Labs Operating System, and Graphify can consume stable source ids later, but B10 does not couple directly to them.

## Ingress Options

| Option | Governance | Fit |
|---|---|---|
| manualBridge | G0/G1 for local evidence, G2 if a CRM row is created manually | Lowest risk and useful as a fallback, but it does not prove automated source ingress. |
| noCodeWebhookBridge | G3/R3 | Fast proof if Adam accepts a temporary third-party automation/secrets surface. |
| purposeBuiltIngressAdapter | G3/R3 | Best production shape when the webhook contract and secret/revoke path are known. |

Recommended proof path:

Use B10a local readiness first. For B10b live proof, prefer one selected no-real-client QUO event through a signed ingress path. Use manual bridge only as a fallback evidence step if webhook details are not ready.

## Event Mapping

| Event class | Creates CRM signal | Signal type | Priority | Required fields |
|---|---|---|---|---|
| missed_call | True | Phone | High | sourceEventId; quoNumber; fromPhone; eventTimestamp |
| voicemail | True | Voicemail | High | sourceEventId; quoNumber; fromPhone; eventTimestamp; voicemailLink |
| inbound_sms | True | SMS | High | sourceEventId; quoNumber; fromPhone; eventTimestamp; messagePreview |
| completed_call_summary | selected-only | Call Summary | Normal | sourceEventId; quoNumber; fromPhone; eventTimestamp; callLink |
| contact_created_or_updated | False | Contact Update | Normal | sourceEventId; quoContactId; eventTimestamp |

## Normalized CRM Shape

- `IntakeSource`: `QUO`
- `SignalStatus`: `New`
- Title pattern: `QUO <SignalType> - <caller or phone> - <timestamp>`
- SourceText metadata:
  - QUO source event id
  - QUO event class
  - QUO business number
  - Caller phone and known contact name when available
  - Conversation/call/voicemail link when available
  - Event timestamp
  - Payload digest and redaction note
  - Outbound blocked note

## Duplicate, Payload, And Disable Rules

- Duplicate policy: Primary key is QUO sourceEventId. Fallback key is conversationId or callId plus normalized fromPhone and eventTimestamp bucket. One existing match returns/maps to the existing CRM item; zero matches creates one CRM item; more than one match stops for Adam review.
- Raw payload policy: Raw QUO payloads stay out of git and inventory by default. Store raw payload evidence only under .local/quo-ingress when approved. Commit only sanitized summaries, digests, mappings, and proof packets.
- Retention default: Keep sanitized proof summaries in inventory. Keep raw local payloads only long enough to validate the proof, then redact or remove according to the B10 live approval.
- Disable path: Every live bridge must have a named owner, exact webhook/flow/adapter location, and one-command or UI pause path before proof.

## Evidence Files

- Event mapping CSV: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b10\b10-quo-event-mapping-20260627-094929.csv`
- Decision worksheet CSV: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b10\b10-quo-live-decision-worksheet-20260627-094929.csv`
- Proof checklist CSV: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b10\b10-quo-proof-checklist-20260627-094929.csv`
- Summary JSON: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b10\b10-quo-inbound-source-proof-packet-20260627-094929.json`

## Live Approval Boundary

Approval phrase for the later live proof: `approve-b10-quo-inbound-source-proof-20260627`

Scope:
- Name the QUO business intake number(s) allowed for the proof.
- Name the event class allowed for the first no-real-client proof.
- Choose ingress option: manual bridge, no-code webhook bridge, or purpose-built ingress adapter.
- Approve secret/signature verification storage and revoke path.
- Approve raw payload evidence location and retention/redaction rule.
- Approve duplicate/idempotency rule for the selected event class.
- Approve disable/pause path and named owner.
- Run one no-real-client or internal QUO event through CRM - New Signals, Teams alert, and G0 triage evidence.

Stop conditions:
- No automatic SMS reply.
- No automatic callback.
- No outbound QUO API send.
- No real customer call/SMS proof before synthetic or internal proof passes.
- No webhook/API secret in git, docs, inventory, browser code, or DirectLink handoff.
- No third-party automation without named owner and disable path.
- No CRM merge, delete, suppression, task, reminder, or external message.
- No QUO path that bypasses CRM - New Signals.
- No R4 delegated autonomy.

## Evidence Checks

| Check | Path | Exists | Note |
|---|---|---|---|
| b8aJourneyHardeningPacket | `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.md` | True |  |
| b9aSelectedSignalOperatingPacket | `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.md` | True |  |
| futureRawPayloadLocalOnlyDirectory | `.local/quo-ingress/` | False | Expected to be absent until a live proof is approved. Raw payloads are intentionally untracked. |

## Acceptance

- B10a local packet exists and names event classes, ingress options, normalized CRM shape, duplicate rule, raw payload policy, disable path, evidence targets, stop conditions, and the future approval phrase.
- Event mapping, live decision worksheet, and proof checklist CSVs exist.
- Future B10b proof can be scoped to one no-real-client or internal event before any real customer traffic is used.
- No QUO connector, webhook, API call, CRM write, Teams post, external send, or secret read occurs during B10a.
- Outbound SMS/callback remains blocked until a later explicit G3/R3 decision.
