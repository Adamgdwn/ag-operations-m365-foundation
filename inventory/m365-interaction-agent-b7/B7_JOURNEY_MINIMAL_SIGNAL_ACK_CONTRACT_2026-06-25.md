# B7 Guided AI Journey Minimal Signal And CRM Receipt Ack

Date: 2026-06-25

Status: Live proof complete. Adam approved building/enabling the live M365 ->
Journey callback on 2026-06-25. The callback is now live in the M365 custom HTTP
intake flow and proved with a synthetic internal Journey lifecycle event. No
real client subject was used and no secret was copied to git or DirectLink.
Follow-on source-display proof is also complete: Journey lead-source detail is
now recorded in CRM provenance and shown in the New Signal Teams alert.

Purpose: let Guided AI Journey send a low-friction system signal when Adam
invites a person, acts as an admin for an organization, or saves an
authenticated portal lifecycle event, then let M365 confirm back to the Journey
dashboard after the CRM signal is actually created.

Brand note from Journey side: customer-facing sources, labels, task titles,
sender identity, and journey references should be `Guided AI Journey` /
`Guided AI Labs`. Any `AG Operations` reference in this M365 build is
infrastructure-only unless Adam explicitly says otherwise.

## Intended Loop

```text
Guided AI Journey invite/admin/lifecycle action
-> Journey saves the Supabase transaction first
-> Journey writes a crm_lifecycle_events ledger row with a stable portalEventId
-> Journey backend sends minimal system signal to M365
-> M365 creates CRM - New Signals item
-> New Signal Teams alert fires internally
-> M365 sends CRM receipt ack back to a fixed Journey dashboard endpoint
-> Journey dashboard marks the invite/lead as CRM received
```

## What Is Already True

- `CRM - New Signals` is the source of truth for new opportunities and signals.
- The direct Guided AI Journey Microsoft Form proof created CRM item `#21`.
- CRM item `#21` produced exactly one internal `Guided AI Labs / New Signal`
  Teams post.
- The custom HTTP intake contract exists for Journey website/server-side posts,
  with endpoint URL and secret intentionally kept out of git.
- `scripts/flow-builder/create-http-intake-flow.js` has now been updated
  locally to preserve Journey lifecycle metadata when it is supplied:
  `portalEventId`, `correlationId`, company/engagement/invite ids, source
  action, portal deep link, event timestamp, and ack request.
- The builder can now include a signed M365 -> Journey acknowledgement call
  only when `.local/flow-builder/journey-crm-ack-endpoint.txt` and
  `.local/flow-builder/journey-crm-ack-secret.txt` exist. Those files are
  gitignored and must not be copied into DirectLink.
- `scripts/Set-M365B7JourneyAckConfig.ps1` prepares the confirmed
  endpoint/header and stores the real ack secret locally when supplied.
- Linux/Journey website-side implementation is deployed to production, including
  `crm_lifecycle_events`, `POST /api/crm/lifecycle/ack`, expanded lifecycle
  sender payloads, operations dashboard visibility, and
  `scripts/send-crm-lifecycle-test.ts`.
- Vercel production `CRM_LIFECYCLE_ACK_SECRET` is configured, and the matching
  M365 ack secret is stored locally under `.local/flow-builder`.
- The live M365 custom HTTP intake flow includes the signed
  `Post_CRM_receipt_ack_to_Journey` action.
- The live intake flow derives a readable `Lead source detail` line from
  optional lead-source fields or Journey `sourceAction`. Known action
  `admin_invited_person` renders as `Journey admin invite`.
- The live New Signal Teams alert includes both `Source` and `Lead source`.

Live verification:

- A read-only Power Automate check on 2026-06-26 verified the custom HTTP intake
  flow is `Started`, with evidence in
  `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040717.json`.
- Final synthetic `portalEventId`:
  `db8d3f91-002b-4729-b6ac-556ee5813d3d`.
- M365 created `CRM - New Signals` item `#25`.
- M365 callback run `08584191601836375009766959431CU07` succeeded, including
  `Post_CRM_receipt_ack_to_Journey`.
- Journey ledger read-back returned `crm_received` with `crm_record_id = 25`.
- New Signal Teams alert flow run
  `08584191601489641879076917249CU08` succeeded.
- Lead-source display proof on 2026-06-26 used direct synthetic source event
  `journey-portal-event-1782447883236` with `ackRequested = false`; M365 created
  CRM item `#27` with `Lead source detail: Journey admin invite`, intake flow
  run `08584191590010332113223187806CU18` succeeded, and Teams alert run
  `08584191589676821842406276734CU16` succeeded. Evidence:
  `inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md`.

## Slim Signal Principle

Do not make the potential client carry system data.

The invite/admin trigger is a system event. It should send what Journey already
knows: email, name if known, organization if known, the Journey invite id, and a
correlation id. The client-facing form can remain a separate enrichment step.

Recommended client-facing enrichment, if needed later:

- Prefill name, email, and organization where possible.
- Ask one free-text prompt: "What would make this useful?"
- Ask one intent/path choice only if it improves routing.
- Include one consent checkbox when the client is actively submitting.
- Do not ask for Journey ids, CRM ids, source labels, or other internal
  metadata.

## Journey -> M365 Minimal Payload

The Journey backend should POST to the existing custom HTTP intake endpoint from
`WINDOWS_TO_JOURNEY__custom-intake-form-spec.json`. The endpoint URL and
`x-intake-secret` remain server-side only.

Minimum system invite/lifecycle signal:

```json
{
  "schemaVersion": "journey.crm-signal.v1",
  "source": "Guided AI Journey",
  "signalMode": "portal-lifecycle-event",
  "eventType": "organization_setup_saved",
  "portalEventId": "stable Journey crm_lifecycle_events id",
  "correlationId": "same as portalEventId unless Journey needs a separate send-attempt id",
  "companyId": "Journey company id, if available",
  "engagementId": "Journey engagement id, if available",
  "inviteId": "Journey invitation id, if available",
  "journeyInviteId": "Journey invitation id, if available",
  "journeyOrganizationId": "Journey organization id, if available",
  "journeyLeadId": "Journey dashboard lead/signal id, if available",
  "inviteRole": "person | organization_admin | organization_member | unknown",
  "sourceAction": "admin_invited_person",
  "leadSourceDetail": "optional friendly label; M365 derives one from sourceAction if absent",
  "portalDeepLink": "Journey operator/admin deep link, if safe",
  "eventTimestamp": "ISO-8601 event timestamp",
  "fullName": "optional invitee/admin name",
  "email": "invitee/admin email if known",
  "organization": "optional organization display name",
  "leadContext": "short system-generated context",
  "needSummary": "optional; M365 can derive a basic invite-signal summary",
  "situation": "optional IntentPath choice if Journey already knows it",
  "heardFrom": "Guided AI Journey invite/admin trigger",
  "consent": false,
  "company": "",
  "ackRequested": true,
  "testMode": false
}
```

Accepted aliases in the local M365 builder:

| Meaning | Accepted fields |
|---|---|
| Name | `fullName`, `inviteeName`, `invitedName` |
| Email | `email`, `inviteeEmail`, `invitedEmail` |
| Organization | `organization`, `organizationName`, `journeyOrganizationName`, `portalCompanyName`, `companyDisplayName` |
| Event type | `eventType`, `journeyEventType` |
| Lead id | `journeyLeadId`, `dashboardLeadId` |
| Correlation key | `portalEventId`, `correlationId`, `journeyInviteId`, `inviteId`, `journeyLeadId`, `dashboardLeadId` |

## M365 CRM Mapping

The local HTTP intake builder maps the minimal signal into the existing CRM
shape:

| CRM field | Mapping |
|---|---|
| `Title` | `Guided AI Journey - <best available name/org/email>` |
| `PersonName` | Name, or email fallback |
| `PersonEmail` | Email |
| `OrganizationName` | Organization name |
| `NeedSummary` | `needSummary`, else `leadContext`, else generated invite-signal summary |
| `SourceText` | Human-readable fields plus `Lead source detail`, Journey metadata, and provenance |
| `SignalType` | `Website` |
| `IntakeSource` | `Guided AI Journey` |
| `IntentPath` | `situation`, if supplied |
| `SignalStatus` | `New` |
| `Priority` | `Normal` |
| `NextAction` | `Triage new website signal` |

Journey metadata preserved in `SourceText`:

- `Schema version`
- `Signal mode`
- `Event type`
- `Portal event id`
- `Correlation id`
- `Company id`
- `Engagement id`
- `Invite id`
- `Journey invite id`
- `Journey organization id`
- `Journey lead id`
- `Invite role`
- `Source action`
- `Portal deep link`
- `Event timestamp`
- `Ack requested`

## M365 -> Journey Ack Contract

Linux/Journey confirmed this fixed server-side acknowledgement endpoint:

```text
POST https://www.guidedaijourney.com/api/crm/lifecycle/ack
Header: x-m365-ack-secret: <server-side secret>
Success status: 200
Dashboard pending timeout: 15 minutes
```

M365 should not use a callback URL supplied inside the lead payload. The ack URL
and secret must be configured out of band in local/Power Automate settings.

Planned acknowledgement body:

```json
{
  "schemaVersion": "journey.crm-receipt.v1",
  "eventType": "m365.crm_signal.received",
  "receivedEventType": "organization_setup_saved",
  "source": "Guided AI Journey",
  "portalEventId": "same portalEventId received from Journey",
  "correlationId": "same correlationId received from Journey",
  "companyId": "same companyId received from Journey",
  "engagementId": "same engagementId received from Journey",
  "inviteId": "same inviteId received from Journey",
  "journeyInviteId": "same journeyInviteId received from Journey, if any",
  "journeyOrganizationId": "same journeyOrganizationId received from Journey, if any",
  "journeyLeadId": "same journeyLeadId/dashboardLeadId received from Journey, if any",
  "crmStatus": "created",
  "received": true,
  "crmRecordId": "sharepoint-list-item-id",
  "crmRecordUrl": "https://...",
  "crmItemId": 21,
  "crmItemUrl": "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/Lists/CRM%20%20New%20Signals/DispForm.aspx?ID=21",
  "crmTitle": "Guided AI Journey - ...",
  "signalStatus": "New",
  "priority": "Normal",
  "flowRunId": "optional-flow-run-id",
  "receivedAt": "CRM Created timestamp",
  "processedAt": "M365 ack timestamp",
  "ackGeneratedAt": "M365 ack timestamp",
  "message": "optional safe operator note"
}
```

Recommended Journey dashboard statuses:

```text
invite_sent
crm_send_attempted
crm_send_accepted
crm_receipt_pending
crm_received
crm_failed_or_timed_out
```

Interpretation:

- `crm_send_accepted` means the M365 HTTP endpoint returned success.
- `crm_received` means the M365 callback arrived after a CRM item existed.
- If no callback arrives within 15 minutes, Journey should show
  `crm_failed_or_timed_out` / `needs review` and retain the correlation id for
  retry/debugging.

## No-Real-Subject Test

Use an internal synthetic Journey event, not a real client.

Recommended test values:

```json
{
  "testMode": true,
  "eventType": "organization_setup_saved",
  "portalEventId": "GAIL-B7-PORTAL-EVENT-20260625",
  "correlationId": "GAIL-B7-PORTAL-EVENT-20260625",
  "companyId": "journey-company-internal-walkthrough",
  "engagementId": "journey-engagement-internal-walkthrough",
  "inviteId": "journey-invite-test-20260625",
  "journeyInviteId": "journey-invite-test-20260625",
  "fullName": "GAIL INTERNAL CRM ACK TEST",
  "email": "adam+journey-crm-ack-20260625@guidedailabs.com",
  "organization": "Guided AI Labs Internal Walkthrough",
  "leadContext": "Internal B7 proof that Journey invite signal reaches CRM and receives an acknowledgement."
}
```

Expected proof result:

1. Journey dashboard records `invite_sent`.
2. Journey backend sends the minimal signal and records `crm_send_accepted`.
3. M365 creates one `CRM - New Signals` item with
   `IntakeSource = Guided AI Journey`.
4. `SourceText` contains the correlation id and Journey invite id.
5. The internal New Signal Teams alert appears once.
6. M365 ack flow posts the CRM receipt to Journey.
7. Journey dashboard records `crm_received`.

## M365 Answers To Journey Questions

1. The current local builder can preserve `portalEventId` on the CRM record in
   `SourceText` now. A first-class SharePoint column is recommended later if
   Journey needs strict idempotency/dedupe at the list schema level.
2. The local builder can call a signed portal ack endpoint after `Create_item`
   succeeds, but only when the fixed endpoint and real secret are present in
   `.local/flow-builder`. Adam has approved the live callback build; do not use
   a placeholder secret.
3. M365 can safely return the SharePoint item id and the display-form URL for
   the created `CRM - New Signals` item.
4. For v1, lifecycle events should continue landing in `CRM - New Signals` so
   the proven alert and triage lane stays intact. A dedicated lifecycle list is
   a good later refinement if these events become operational history rather
   than lead/workspace-start signals.
5. Fields to include now: `portalEventId`, `eventType`, `companyId`,
   `engagementId`, `inviteId`, `sourceAction`, optional `leadSourceDetail`,
   `eventTimestamp`, `portalDeepLink`, and a short `leadContext`.

## Next Refinements

1. Keep invite/admin system signals slim: no client-facing questions are needed
   for the CRM receipt loop.
2. Add a first-class SharePoint `portalEventId` column later if strict M365-side
   dedupe becomes necessary.
3. Add a retry/replay operator action in Journey for any future
   `crm_failed_or_timed_out` rows.
4. Preserve the current secret boundary: no ack secret in git, DirectLink,
   screenshots, or evidence files.
