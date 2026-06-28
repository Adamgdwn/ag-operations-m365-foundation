# B8 Journey Loop Hardening Packet

Generated: 2026-06-27T09:12:39.0200799-06:00
Mode: local-only
Safety: No Microsoft 365 connection, no HTTP send, no CRM write, no flow update, no secret read.

## Purpose

Make the Guided AI Journey -> M365 -> Journey receipt loop dedupe-friendly, readable by portalEventId, and recoverable when Journey shows crm_failed_or_timed_out.

## Current State

- Source list: `CRM - New Signals`
- Journey ledger: `Journey crm_lifecycle_events`
- HTTP intake flow: `GAIL - Custom site intake to CRM (create-only, HTTP)` (`9582c422-158d-4975-ba7f-81b4d77e497b`)
- Current portal event storage: SourceText metadata block

## Field Plan

| Display name | Internal name | Type | Indexed | Purpose |
|---|---|---|---|---|
| Portal Event ID | `PortalEventId` | Text | True | Primary Journey event dedupe and read-back key. |
| Source Correlation ID | `SourceCorrelationId` | Text | True | Secondary correlation key for Journey/M365 replay and operator support. |

Deferred:
- `ReceiptStatus`: Derive receipt state from the Journey ledger for now. Add CRM-local status only if operators need to work receipts from CRM directly.

## Duplicate And Replay Policy

- Duplicate policy: If one existing CRM item matches the same PortalEventId, do not create a new CRM item. Return the existing CRM item id/url to Journey with crmStatus=existing. If more than one item matches, stop and require Adam review.
- Replay policy: Journey operator retry/replay must reuse the same portalEventId. A replay should either create the missing CRM item or acknowledge the existing one; it must not silently create duplicate work.
- Cleanup policy: No delete by default. Leave historical B7 proof rows as evidence. Backfill first-class fields only after exact item ids and live write scope are approved.

## Flow Update Plan

1. Compose Journey keys: Normalize portalEventId and correlationId before any SharePoint write.
2. Lookup existing CRM signal: When PortalEventId is present, query CRM - New Signals by PortalEventId before Create item.
3. Zero matches: Create one CRM item, populate SourceText plus first-class fields, then send Journey ack with crmStatus=created.
4. One match: Skip Create item and send Journey ack with existing CRM item id/url and crmStatus=existing.
5. More than one match: Do not create or ack as success. Stop for Adam review; optional G1 advisory requires separate approval.

## Live Approval Boundary

Approval phrase for the later live update: `approve-b8-journey-loop-hardening-live-update-20260627`

Scope:
- Add PortalEventId and SourceCorrelationId fields to CRM - New Signals.
- Update the existing HTTP intake flow to populate the approved first-class fields.
- Add pre-create idempotency lookup by PortalEventId.
- Send Journey receipt ack for both created and existing CRM item outcomes.
- Run one no-real-client replay proof using a synthetic/internal Journey event.

Stop conditions:
- No real client replay.
- No delete or merge.
- No external message send.
- No callback URL accepted from payload.
- No browser-side intake or ack secret.
- No QUO setup.
- No R4 delegated autonomy.

## Evidence Checks

| Check | Path | Exists |
|---|---|---|
| b7LiveProof | `inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md` | True |
| b7LeadSourceProof | `inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md` | True |
| flowBodyCaptureLocalOnly | `.local/flow-builder/capture/flow-body-http-intake.json` | True |

## Acceptance

- B8 local packet names exact fields, duplicate policy, replay policy, cleanup policy, evidence paths, stop conditions, and approval phrase.
- After live approval and implementation, a Journey event can be found from PortalEventId without scraping SourceText.
- Replaying the same PortalEventId does not create an unreviewed duplicate CRM item.
- Journey receives a receipt ack for both new-create and existing-item replay outcomes.
- Older synthetic evidence rows are left alone or backfilled only under an exact approval scope.
