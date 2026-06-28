# QUO Inbound Source Contract

Date: 2026-06-28

Status: B10b complete. Design-only implementation contract. B10c.0 later added
local QUO API key readiness, but did not open source ingestion. No QUO webhook,
CRM write, Teams post, real phone/SMS/voicemail traffic, or outbound QUO action
has been enabled by this contract.

Owner: Adam.

Related active plan:
`docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md`

Machine-readable companion:
`config/M365_INTERACTION_AGENT_B10B_QUO_SOURCE_CONTRACT.json`

B10c.0 key readiness:
`docs/2026-06-28_QUO_API_KEY_READINESS.md`

Historical B10a readiness packet:
`inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`

## Purpose

This contract boxes QUO as a future Phone / Voice / Text sensory portal for the
M365 Interaction Agent.

QUO must feed the existing lane:

```text
QUO event -> verified ingress -> CRM - New Signals -> New Signal Teams alert
-> G0 triage/advisory evidence -> optional G1 Suggested row
```

QUO is not a separate CRM, not a separate phone bot, and not an autonomous
outbound channel. The first live source proof remains B10c.1 or later and
requires a fresh exact approval boundary. B10c.0 only imported Adam's QUO API
key into ignored local encrypted storage and ran a no-network dry-run readiness
check.

## Authority Boundary

| Surface | B10b Status |
|---|---|
| QUO portal/API/webhook | Not touched. |
| QUO credentials/secrets | B10b did not touch credentials. B10c.0 stored the API key locally under `.local/quo-ingress/` without committing or documenting the value. |
| Microsoft 365 / CRM | Not read or written by this chunk. |
| Teams | Not posted to by this chunk. |
| Real phone/SMS/voicemail traffic | Not used. |
| Outbound SMS/callback/reply/QUO API send | Blocked. |
| Local docs/config | Allowed. |

Authority level: G0/R0 design and local evidence only.

## Source Principles

- `CRM - New Signals` remains the source of truth for new work.
- `IntakeSource = QUO` is the source label for future QUO-originated signals.
- One accepted source event should create or map to exactly one CRM signal.
- Existing New Signal Teams alerting and triage should be reused.
- Any raw payload, transcript, recording, or full message retention needs
  explicit B10c/later approval.
- Outbound behavior stays blocked until a separate G3/R3 decision.
- Freedom, GAIL OS, and Graphify should eventually receive stable ids and
  relationship hints, but this repo does not become the production GAIL OS
  connector in B10.

## Event Taxonomy

| Event class | CRM signal by default | Signal type | Priority | Required future source fields | Notes |
|---|---|---|---|---|---|
| `missed_call` | Yes | Phone | High | `sourceEventId`, `businessNumber`, `callerOrSenderNumber`, `eventOccurredAt` | Default fast-attention event. |
| `voicemail` | Yes | Voicemail | High | `sourceEventId`, `businessNumber`, `callerOrSenderNumber`, `eventOccurredAt`, recording or transcript reference if available | Store only a short summary until retention is approved. |
| `inbound_sms` | Yes | SMS | High | `sourceEventId`, `businessNumber`, `callerOrSenderNumber`, `eventOccurredAt`, message preview | Store a short preview; raw message retention is gated. |
| `completed_call_summary` | Selected only | Call Summary | Normal | `sourceEventId`, `sourceConversationId`, `businessNumber`, `callerOrSenderNumber`, `eventOccurredAt`, summary or link | Create a signal only when the call creates new work. |
| `contact_update` | No | Contact Update | Normal | `sourceEventId`, QUO contact id or equivalent, `eventOccurredAt` | Relationship enrichment only until Graphify/CRM rules exist. |

Unsupported or unknown QUO event classes must stop at evidence-only review until
Adam approves how they should map.

## Normalized Source Event

Future ingress should normalize any accepted QUO payload to this shape before it
touches CRM:

| Field | Required | Rule |
|---|---|---|
| `sourceSystem` | Yes | Always `QUO`. |
| `sourceEventId` | Yes | Stable QUO event id or verified generated id from the ingress layer. |
| `sourceConversationId` | Preferred | QUO conversation, call, thread, or future equivalent when available. |
| `sourceEventType` | Yes | One taxonomy value from this contract. |
| `eventOccurredAt` | Yes | Timestamp from QUO/source event. |
| `receivedAt` | Yes | Timestamp when approved ingress received or manually captured the event. |
| `businessNumber` | Yes for phone/SMS/voicemail/call | Approved QUO business number or internal test number. |
| `callerOrSenderNumber` | Yes for phone/SMS/voicemail/call | Caller/sender number; normalize for matching and redact in public evidence. |
| `callerOrSenderName` | Optional | Known display/contact name when available. |
| `messageOrSummary` | Optional | Short preview/summary only; full raw text is gated. |
| `recordingOrTranscriptLink` | Optional | Link only when retention/access is approved. |
| `rawPayloadEvidenceRef` | Optional | Local-only raw payload evidence ref, if B10c/later approves retention. |
| `payloadDigest` | Yes for live proof | Hash/digest of the raw or sanitized source event, not a secret. |
| `dedupeKey` | Yes | Built by the rule below. |
| `outboundBlocked` | Yes | Always `true` for B10/B10c. |
| `authorityLevel` | Yes | `G0/R0` for design/local, `G3/R3` for live source ingress. |

Do not place real secrets, bearer tokens, webhook signatures, or full raw QUO
payloads in this normalized event.

## Dedupe And Idempotency

Primary dedupe key:

```text
QUO:<sourceEventType>:<sourceEventId>
```

Fallback dedupe key when a source event id is unavailable:

```text
QUO:<sourceEventType>:<sourceConversationId or call/thread id>:<normalized caller/sender>:<eventOccurredAt UTC 15-minute bucket>
```

Replay behavior:

- zero matching CRM signals means a future approved live ingress may create one
  `CRM - New Signals` item;
- one matching CRM signal means the event maps to that item and does not create
  a duplicate;
- more than one matching CRM signal stops for Adam review;
- a second delivery of the same source event must not create another CRM item;
- a changed payload with the same dedupe key should be logged as a possible
  update/conflict, not silently treated as a new signal.

## CRM Mapping

Target list: `CRM - New Signals`.

| CRM field | Future value/rule |
|---|---|
| `Title` | `QUO <SignalType> - <caller/name placeholder> - <event date/time>` |
| `NeedSummary` | Short human-readable event summary, never a raw secret-bearing payload. |
| `SignalType` | Phone, Voicemail, SMS, Call Summary, or another approved existing value. |
| `IntakeSource` | `QUO`. If `QUO` is not yet a live choice, B10c must decide whether to add it or use an approved interim value. |
| `Priority` | High for missed call, voicemail, inbound SMS by default; Normal for selected call summaries/contact updates unless Adam changes this. |
| `SignalStatus` | New. |
| `PersonName` | Caller/sender/contact display name when available and approved. |
| `OrganizationName` | Only when known from approved source data or later CRM/Graphify matching. |
| `SourceText` | Sanitized metadata block: event class, event id, conversation id, business number label, redacted caller/sender, timestamp, digest, link refs, outbound blocked note. |
| `RelatedLink` | QUO conversation/call/voicemail link only when approved. |
| `NextAction` | Human triage note; no outbound reply instruction unless separately approved. |

Contact update events do not create work by default. They can be retained as
future relationship evidence only after the relationship-enrichment rules exist.

## Evidence And Privacy

| Data class | B10b handling | B10c/later requirement |
|---|---|---|
| Raw QUO payload | Not present. | Store only in approved local/private evidence path; never git. |
| Full SMS body | Not present. | Retention/redaction approval required. |
| Voicemail transcript | Not present. | Retention/redaction approval required. |
| Recording link | Placeholder only. | Access and retention approval required. |
| Phone numbers | Fake placeholders only. | Redact in committed evidence unless Adam approves exact display. |
| Payload digest | Shape only. | Compute for replay/idempotency evidence when live proof is approved. |
| CRM item ids | None created in B10b. | Record only after an approved B10c proof. |

Default raw payload location for later approval: `.local/quo-ingress/`.

That path is intentionally local-only and should remain untracked. Committed
evidence should contain sanitized summaries, digests, ids, and proof outcomes,
not raw payloads.

## Approval, Disable, And Revoke Surface

B10c.1 or later live proof must capture all of this before touching QUO beyond
the already completed local key storage and optional read-only key probe:

| Required approval item | What Adam must see or choose |
|---|---|
| Business number(s) | Exact QUO number(s) or internal test number(s). |
| First event class | One of `missed_call`, `voicemail`, `inbound_sms`, or `completed_call_summary`. |
| Ingress pattern | Manual bridge, no-code bridge, or purpose-built adapter. |
| Secret/signature storage | Exact storage location and revoke/delete path. |
| Raw payload policy | Evidence location, retention period, and redaction rule. |
| Dedupe rule | Source event id primary rule and fallback window. |
| Owner | Named human owner for the bridge. |
| Disable path | Exact UI or command path to pause the bridge. |
| Outbound block | Explicit confirmation that SMS, callback, reply, and QUO API send remain blocked. |

Preferred visible approval surface:
`scripts/Start-M365InteractionAgentApprovalWindow.ps1`.

## Synthetic Fixture Shapes

These are not real QUO payloads. They are fake normalized examples for future
local tests and documentation only.

Missed call:

```json
{
  "sourceSystem": "QUO",
  "sourceEventId": "quo_evt_fake_missed_call_001",
  "sourceConversationId": "quo_conv_fake_001",
  "sourceEventType": "missed_call",
  "eventOccurredAt": "2026-06-28T15:00:00Z",
  "receivedAt": "2026-06-28T15:00:15Z",
  "businessNumber": "+1-555-0100",
  "callerOrSenderNumber": "+1-555-0199",
  "callerOrSenderName": "Example Caller",
  "messageOrSummary": "Fake missed call fixture. No real QUO payload.",
  "recordingOrTranscriptLink": null,
  "rawPayloadEvidenceRef": null,
  "payloadDigest": "sha256:fake-digest-not-from-real-payload",
  "dedupeKey": "QUO:missed_call:quo_evt_fake_missed_call_001",
  "outboundBlocked": true,
  "authorityLevel": "G0/R0"
}
```

Inbound SMS:

```json
{
  "sourceSystem": "QUO",
  "sourceEventId": "quo_evt_fake_inbound_sms_001",
  "sourceConversationId": "quo_conv_fake_002",
  "sourceEventType": "inbound_sms",
  "eventOccurredAt": "2026-06-28T15:05:00Z",
  "receivedAt": "2026-06-28T15:05:10Z",
  "businessNumber": "+1-555-0100",
  "callerOrSenderNumber": "+1-555-0188",
  "callerOrSenderName": "Example Sender",
  "messageOrSummary": "Fake SMS preview. No real client text.",
  "recordingOrTranscriptLink": null,
  "rawPayloadEvidenceRef": null,
  "payloadDigest": "sha256:fake-digest-not-from-real-payload",
  "dedupeKey": "QUO:inbound_sms:quo_evt_fake_inbound_sms_001",
  "outboundBlocked": true,
  "authorityLevel": "G0/R0"
}
```

Contact update:

```json
{
  "sourceSystem": "QUO",
  "sourceEventId": "quo_evt_fake_contact_update_001",
  "sourceConversationId": null,
  "sourceEventType": "contact_update",
  "eventOccurredAt": "2026-06-28T15:10:00Z",
  "receivedAt": "2026-06-28T15:10:08Z",
  "businessNumber": null,
  "callerOrSenderNumber": "+1-555-0177",
  "callerOrSenderName": "Example Contact",
  "messageOrSummary": "Fake contact update fixture. Relationship evidence only.",
  "recordingOrTranscriptLink": null,
  "rawPayloadEvidenceRef": null,
  "payloadDigest": "sha256:fake-digest-not-from-real-payload",
  "dedupeKey": "QUO:contact_update:quo_evt_fake_contact_update_001",
  "outboundBlocked": true,
  "authorityLevel": "G0/R0"
}
```

Fixture rules:

- use fictional `555-01xx` phone numbers only;
- do not copy any real QUO JSON into docs, config, inventory, chat, or git;
- do not include real caller names, client names, transcripts, recordings, or
  message bodies;
- do not use these examples as live webhook payloads.

## B10c.1 Approval Checklist

B10c.1 live source proof can start only after Adam approves every item below:

- exact QUO business intake number(s) or internal test number(s);
- exact first event class;
- exact ingress pattern;
- exact secret/signature storage location and revoke path;
- exact raw payload evidence location and retention/redaction rule;
- dedupe/idempotency rule for the selected event class;
- named owner and visible disable/pause path;
- no-real-client/internal test scope;
- confirmation that outbound SMS, callback, reply, and QUO API send remain
  blocked;
- confirmation that the event must route through `CRM - New Signals`.

## B10c.1 Acceptance Target

When separately approved later:

```text
one approved no-real-client/internal QUO event
-> normalized source event
-> one CRM - New Signals item or one duplicate match
-> one New Signal Teams alert if a new CRM item is created
-> one local triage/evidence packet
-> visible disable/revoke evidence
-> zero outbound QUO/client action
```

## B10b Acceptance

- Event taxonomy is defined.
- Normalized source event contract is defined.
- CRM mapping into `CRM - New Signals` is defined.
- Duplicate/idempotency behavior is defined.
- Raw payload retention, redaction, and evidence expectations are defined.
- Visible approval, disable, revoke, and owner paths are defined.
- Synthetic fixtures use fake data only.
- B10c remains gated.
- No live QUO or M365 action occurred during B10b.
