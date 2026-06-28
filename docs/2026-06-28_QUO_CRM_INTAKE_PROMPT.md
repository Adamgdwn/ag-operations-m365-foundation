# QUO CRM Intake Prompt And Placement

Date: 2026-06-28

Status: Design-only B10c.0a placement note. No live QUO configuration, webhook,
CRM write, Teams post, call read, SMS read, voicemail read, or outbound QUO
action is authorized by this document.

Owner: Adam.

Related:

- Active build plan:
  `docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md`
- QUO source contract:
  `docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`
- CRM SharePoint-native interface:
  `docs/CRM_SHAREPOINT_NATIVE_INTERFACE.md`

## Purpose

This note gives QUO/Sona a clear intake prompt and places the resulting call
summary into the existing M365 Interaction Agent lane:

```text
QUO/Sona call handling
-> QUO event or post-call summary
-> approved B10c.1+ ingress
-> CRM - New Signals, IntakeSource = QUO
-> existing New Signal Teams alert
-> G0 triage/advisory evidence
-> optional G1 Suggested row after approval
```

QUO should be treated as a Phone / Voice / Text sensory portal. It should not
become a separate CRM, a direct SharePoint writer, or an autonomous outbound
agent.

## Where To Integrate In QUO

Use this prompt in the QUO call-flow builder shown by Adam:

1. `Incoming call` routes into `Business hours`.
2. During business hours, callers ring users first.
3. If the call is missed, the `Sona` node handles intake.
4. After hours, the `Sona` node handles intake directly.
5. The existing `Voicemail` fallback remains below Sona for failures, caller
   refusal, or cases where the assistant cannot complete the handoff.

Paste the prompt in both Sona instruction surfaces:

- During hours: `Ring users` -> `If call is missed` -> `Sona`.
- After hours: `Business hours` -> `After hours` -> `Sona`.

If QUO separates assistant behavior from post-call summary formatting, put the
main prompt in the Sona behavior/instructions field and put the "Post-call CRM
handoff format" block in the call summary, note, webhook, or automation summary
field. If QUO only gives one prompt field, paste the whole prompt.

Do not configure direct SharePoint, Teams, callback, SMS reply, or email-send
actions from Sona. The later B10c.1+ proof should connect QUO output to the
M365 Interaction Agent ingress layer first, then into `CRM - New Signals`.

## Where To Integrate In SharePoint

Add the operator surface inside the CRM Command Center, not as a separate QUO
app page:

```text
Operations Cockpit
-> CRM Command Center
-> QUO Intake
-> CRM - New Signals filtered where IntakeSource = QUO
```

Recommended SharePoint page element:

- card or quick link label: `QUO Intake`;
- target list: `CRM - New Signals`;
- filter: `IntakeSource = QUO`;
- default sort: newest first;
- default queue: `SignalStatus = New` or the current triage-ready status;
- visible columns: Title, Priority, SignalType, PersonName, OrganizationName,
  NeedSummary, NextAction, Follow-up date, RelatedLink, Owner, SignalStatus.

This page should show sanitized CRM intake records and links to approved QUO
evidence only. It should not expose raw transcripts, full SMS bodies, full
phone numbers in public evidence, webhook secrets, API keys, or QUO admin
configuration.

## Sona Intake Prompt

```text
You are Sona, the phone intake assistant for Guided AI Labs and A.G. Operations.
You answer when Adam or the team cannot take the call directly, or when the call
arrives after hours.

Your job is to collect a concise, accurate intake note for a human operator. Be
warm, calm, brief, and practical. Do not pretend to be Adam. Do not diagnose,
give legal, financial, medical, or security advice, commit to pricing, scope,
timelines, contracts, refunds, appointments, or delivery, and do not say that
work has started. Do not send texts, emails, callbacks, or external messages.

Opening:
"Thanks for calling Guided AI Labs and A.G. Operations. I can take a note so
Adam or the right person can follow up. What can I help pass along?"

Collect naturally:
- caller name;
- organization, if any;
- callback number and whether calling or texting that number is okay;
- email address, if they want email follow-up;
- what they need or what happened;
- whether this is new work, an existing client matter, support, scheduling,
  partnership, billing, or something else;
- urgency, deadline, and preferred next step;
- any relevant website, project, product, invoice, or prior conversation
  reference.

If the caller is upset or the matter is urgent, acknowledge the urgency, gather
facts, and mark the handoff high priority. Do not attempt to resolve the issue.

If the caller asks for emergency action, legal advice, medical advice,
financial advice, security-incident handling, safety decisions, access changes,
billing commitments, or any irreversible operational action, say you can record
the request for urgent human review but cannot make commitments or provide
advice.

Before ending, confirm the caller's preferred contact method and summarize the
request in one sentence.

Close:
"Thanks, I have the note. I will pass this to the team for human review."

After the call, produce a structured CRM handoff summary using these exact
labels. Use "Unknown" when the caller did not provide a value.

CRMTitle:
SignalType:
Priority:
PersonName:
OrganizationName:
Phone:
Email:
ConsentToCallTextEmail:
NeedSummary:
ContextNotes:
UrgencyOrDeadline:
SuggestedNextAction:
ExistingRelationshipHint:
DedupeHint:
OutboundBlocked: true
```

## CRM Handoff Mapping

| Sona handoff label | CRM field / handling |
|---|---|
| `CRMTitle` | `Title`; suggested format: `QUO Phone - <person or organization> - <date/time>`. |
| `SignalType` | `SignalType`; usually Phone, Voicemail, SMS, Support, Scheduling, Partnership, Billing, or another approved existing value. |
| `Priority` | `Priority`; High for urgent, missed-call, voicemail, support, legal/billing deadline, or upset caller; Normal otherwise. |
| `PersonName` | `PersonName`. |
| `OrganizationName` | `OrganizationName`. |
| `Phone` | Source metadata; redact in committed evidence unless approved. |
| `Email` | Email field when available. |
| `ConsentToCallTextEmail` | Include in `SourceText` or `NeedSummary` until a dedicated CRM field exists. |
| `NeedSummary` | `NeedSummary`; short human-readable summary. |
| `ContextNotes` | `SourceText` or the approved context field; keep concise. |
| `UrgencyOrDeadline` | `NextAction`, `Follow-up date`, or `Priority` depending on the live field set. |
| `SuggestedNextAction` | `NextAction`; must remain a human triage note, not an automatic outbound instruction. |
| `ExistingRelationshipHint` | Relationship/context hint for G0 review and later Graphify matching. |
| `DedupeHint` | Future ingress dedupe support; not a public-facing field. |
| `OutboundBlocked` | Must remain `true` through B10c.1+. |

The future source bridge should also set:

- `IntakeSource = QUO`;
- `SignalStatus = New`;
- `RelatedLink = <approved QUO call/conversation/voicemail link>`, when allowed;
- `SourceText = sanitized QUO metadata block`, including event class, event id,
  conversation id, business number label, redacted caller/sender, timestamp,
  payload digest, related link reference, and outbound-block note.

## B10c.1+ Implementation Notes

B10c.1+ should start disabled or staged, then prove one no-real-client/internal
event only after Adam approves the exact number, event class, ingress pattern,
secret storage, raw payload retention, dedupe rule, owner, visible disable path,
and outbound block.

The preferred first proof is:

```text
one internal missed call or after-hours Sona intake
-> structured CRM handoff summary
-> one CRM - New Signals item with IntakeSource = QUO
-> one existing New Signal Teams alert
-> one local evidence packet
-> zero outbound QUO/client action
```

If QUO provides a webhook, action, or automation target, point it to the future
approved ingress adapter or manual bridge, not directly to SharePoint.
