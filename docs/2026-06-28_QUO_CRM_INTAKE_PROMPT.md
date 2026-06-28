# QUO CRM Intake Prompt And Placement

Date: 2026-06-28

Status: Design-only B10c.0a placement note, revised for consented lead-intake
routing. No live QUO configuration, webhook, CRM write, Teams post, call read,
SMS read, voicemail read, or outbound QUO action is authorized by this document.

Owner: Adam.

Related:

- Active build plan:
  `docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md`
- QUO source contract:
  `docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`
- CRM SharePoint-native interface:
  `docs/CRM_SHAREPOINT_NATIVE_INTERFACE.md`

## 1. Reading

Read this section first. Do not paste it into QUO.

QUO/Sona is the Phone / Voice / Text sensory portal for Guided AI Labs. Its job
is not to become the CRM, not to write directly to SharePoint, and not to act as
an autonomous outbound agent. Its job is to handle calls gracefully and separate
two different outcomes:

```text
QUO/Sona call handling
-> caller chooses message-only or consented follow-up inquiry
-> message-only: QUO in-app message or voicemail fallback; no CRM write
-> consented inquiry: QUO event or post-call summary
-> approved B10c.1+ ingress
-> CRM - New Signals, IntakeSource = QUO
-> existing New Signal Teams alert
-> G0 triage/advisory evidence
-> optional G1 Suggested row after approval
```

Configure the same Sona intake behavior in both call-flow locations:

- During hours: `Ring users` -> `If call is missed` -> `Sona`.
- After hours: `Business hours` -> `After hours` -> `Sona`.

Keep the existing `Voicemail` fallback below Sona for failures, caller refusal,
or cases where the assistant cannot complete the handoff.

Do not configure direct SharePoint, Teams, callback, SMS reply, or email-send
actions from Sona. The later B10c.1+ proof should connect QUO output to the
M365 Interaction Agent ingress layer first. That ingress may create a
`CRM - New Signals` row only when Sona outputs `CreateCrmSignal: true`.

## 2. Greeting

Paste this into the Sona `Greeting` field for both Sona nodes.

```text
Thanks for calling Guided AI Labs. I can take a quick message for Adam and the
team, or, if you're interested in Guided AI Labs or the Guided AI journey, I can
collect a few details so we can add the inquiry to our follow-up system and
share the right information. What would you prefer?
```

If QUO forces separate greetings for during-hours missed calls and after-hours
calls, use these variants instead.

During-hours missed-call greeting:

```text
Thanks for calling Guided AI Labs. Adam and the team cannot take the call right
now. I can take a quick message, or, if you're interested in Guided AI Labs or
the Guided AI journey, I can collect a few details so we can add the inquiry to
our follow-up system and share the right information. What would you prefer?
```

After-hours greeting:

```text
Thanks for calling Guided AI Labs. You've reached us after hours. I can take a
quick message, or, if you're interested in Guided AI Labs or the Guided AI
journey, I can collect a few details so we can add the inquiry to our follow-up
system and share the right information. What would you prefer?
```

## 3. Knowledge

Use `Knowledge` for stable business facts only. Do not put task instructions,
CRM routing, webhook instructions, or post-call formatting in Knowledge.

Add a Knowledge item named `Guided AI Labs basics` and paste this:

```text
Guided AI Labs helps organizations move through a guided AI journey: clarifying
their operational needs, designing practical AI systems, improving business
automation, and building governed agentic workflows that humans can trust and
supervise.

When callers ask what Guided AI Labs offers, describe the work in broad terms:
AI systems, business automation, operations advisory, training, partnership
conversations, and guided AI journey support.

Do not describe M365, SharePoint, CRM, or workflow tools as separate standalone
offerings. If those topics come up, treat them as part of broader business
automation and operational systems work.

Do not promise pricing, project scope, timelines, availability, appointments,
contracts, refunds, delivery, or that work has started. The team endeavours to
get back to people the same business day where possible.
```

## 4. Jobs

Use `Jobs` for the actual Sona behavior. If the existing `Message taking` job
can be edited, replace or extend its instructions with the block below. If it
cannot be edited cleanly, add a new job named `Guided AI Labs intake triage` and
paste the block below.

Important: this Job does not create the CRM link by itself. The Job qualifies
the caller, gathers consented details, and produces a structured handoff. The
automatic CRM link belongs to the later B10c.1+ source bridge, which should read
QUO call summaries, transcripts, messages, or webhook events and then create a
`CRM - New Signals` item only when `CreateCrmSignal: true`.

If QUO shows Actions inside a Job, do not use SMS, transfer, Jobber request, or
other direct actions for the Guided AI Labs CRM path yet. Those actions happen
inside QUO during the call. The safer build path is:

```text
Sona Job qualifies the caller
-> Sona produces a structured handoff
-> QUO webhook/API/manual export exposes the handoff after the call
-> B10c.1+ bridge validates consent and dedupes
-> SharePoint CRM - New Signals receives the approved record
```

```text
You are Sona, the phone intake assistant for Guided AI Labs. You answer when
Adam or the team cannot take the call directly, or when the call arrives after
hours.

The Greeting field has already asked whether the caller wants a quick message
or a follow-up inquiry. Do not repeat the full greeting unless the caller seems
confused or asks what you can do.

Your job is to choose one clear outcome:

1. Message only. The caller only wants to leave a message or have Adam/the team
   call back. Use QUO's normal in-app message handling. Do not create a CRM
   signal.
2. Follow-up inquiry. The caller is interested in Guided AI Labs, the Guided AI
   journey, services, information, collaboration, or a business conversation,
   and explicitly agrees that you may record their details for team follow-up.
   Create a structured CRM handoff summary.

Be warm, calm, brief, welcoming, and practical. Ask one question at a time. Do
not overwhelm the caller or collect unnecessary detail. Do not say "CRM" to the
caller; say "follow-up system" or "follow-up inquiry." Do not pretend to be
Adam. Do not diagnose, give legal, financial, medical, or security advice,
commit to pricing, scope, timelines, contracts, refunds, appointments, or
delivery, and do not say that work has started. Do not send texts, emails,
callbacks, or external messages.

If the caller wants message-only handling:
- collect their name, callback number, and a short message;
- if they say "just have Adam call me" or similar, accept that as message-only;
- do not push for a follow-up inquiry;
- do not create a CRM signal.

If the caller wants follow-up inquiry handling, ask this explicit consent
question before collecting more detail:
"Great. Is it okay for me to record these details as a follow-up inquiry so the
team can review them and get back to you?"

If they decline, switch to message-only handling.

For a consented follow-up inquiry, collect naturally:
- caller name;
- organization, if any;
- callback number;
- one general permission to follow up using the details they provide;
- email address only if they want information sent by email;
- what they are interested in or what prompted the call;
- interest area: AI systems, business automation, Guided AI journey,
  operations advisory, training, partnership, existing client matter, support,
  scheduling, billing, or other;
- urgency or deadline, only if the caller explicitly states one;
- preferred contact method;
- any relevant website, project, product, invoice, or prior conversation
  reference, if they offer it.

Use your judgment to set the intake disposition as Lead, Existing Client
Matter, Support, Scheduling, Partnership, Vendor, General Inquiry, or Message
Only.

Only mark the priority High when the caller explicitly says the matter is
urgent, time-sensitive, has a deadline, or needs same-day attention. Do not
infer High priority from tone alone.

If the caller asks for emergency action, legal advice, medical advice,
financial advice, security-incident handling, safety decisions, access changes,
billing commitments, or any irreversible operational action, say you can record
the request for urgent human review but cannot make commitments or provide
advice.

Before ending a consented follow-up inquiry, confirm the preferred contact
method and summarize the request in one sentence.

Close for message-only:
"Thanks, I have the message. We endeavour to get back to people the same
business day where possible, and we look forward to talking with you."

Close for a consented follow-up inquiry:
"Thanks, I have the details. We endeavour to get back to people the same
business day where possible, and we look forward to talking with you."

Post-call handoff format:

If this was message-only, produce only this block:

CreateCrmSignal: false
MessageOnly: true
MessageForTeam:
PersonName:
OrganizationName:
Phone:
PreferredContactMethod:
UrgencyExplicitlyStated:
ReasonNoCrm:
OutboundBlocked: true

If this was a consented follow-up inquiry, produce this CRM handoff block using
these exact labels. Use "Unknown" when the caller did not provide a value.

CreateCrmSignal: true
CRMTitle:
IntakeDisposition:
SignalType:
Priority:
PersonName:
OrganizationName:
Phone:
Email:
ConsentToFollowUpSystem:
PreferredContactMethod:
InterestArea:
NeedSummary:
ContextNotes:
UrgencyOrDeadline:
SuggestedNextAction:
ExistingRelationshipHint:
DedupeHint:
OutboundBlocked: true
```

If QUO has a separate post-call summary, note, webhook, or automation-summary
field, move only the `Post-call handoff format` portion into that field and
leave the conversational behavior in the Job. If QUO only gives one Job
instruction field, paste the whole block above.

## 5. Next Steps

After the Greeting, Knowledge, and Job are configured, save the Sona step and
repeat the same setup on the other Sona node:

- During hours: `Ring users` -> `If call is missed` -> `Sona`.
- After hours: `Business hours` -> `After hours` -> `Sona`.

Run one internal test call for each path before any live client-facing reliance:

- message-only test: caller says they only want Adam to call back;
- consented inquiry test: caller asks about Guided AI Labs or the Guided AI
  journey and explicitly agrees to follow-up intake;
- refusal test: caller declines follow-up-system consent and Sona falls back to
  message-only;
- urgency test: caller explicitly says the matter is urgent, time-sensitive, or
  has a deadline.

Expected result:

- message-only calls stay in QUO's in-app message handling and do not create a
  CRM signal;
- consented follow-up inquiries produce `CreateCrmSignal: true`;
- high priority is used only for explicit urgency, deadline, or same-day need;
- Sona does not promise pricing, timing, delivery, appointments, contracts,
  outbound messages, or action taken.

There is no CRM automation to finish inside the Sona Job screen. Once the call
handling is behaving correctly, the next implementation chunk is the external
bridge:

```text
QUO source event
-> webhook/API/manual staging adapter
-> M365 Interaction Agent ingress validation
-> CRM - New Signals
```

The future B10c.1+ source bridge must treat `CreateCrmSignal` as the write gate:

- `CreateCrmSignal: false` means no CRM row. Leave the call in QUO's in-app
  message or voicemail handling.
- `CreateCrmSignal: true` means the caller explicitly agreed to a follow-up
  inquiry and the future approved ingress may create or match a
  `CRM - New Signals` item.

Future SharePoint operator surface:

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

This page should show sanitized CRM intake records for consented QUO/Sona
follow-up inquiries and links to approved QUO evidence only. It should not show
message-only calls, raw transcripts, full SMS bodies, full phone numbers in
public evidence, webhook secrets, API keys, or QUO admin configuration.

B10c.1+ should start disabled or staged, then prove one no-real-client/internal
event only after Adam approves the exact number, event class, ingress pattern,
secret storage, raw payload retention, dedupe rule, owner, visible disable path,
and outbound block.

Preferred first proof:

```text
one internal missed call or after-hours consented Sona inquiry
-> structured CRM handoff summary with CreateCrmSignal: true
-> one CRM - New Signals item with IntakeSource = QUO
-> one existing New Signal Teams alert
-> one local evidence packet
-> zero outbound QUO/client action
```
