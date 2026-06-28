# B8b Live Proof - Journey Loop Hardening

Date: 2026-06-27 MDT / 2026-06-27 UTC

Status: PASS. The Guided AI Journey -> M365 -> Journey receipt/replay loop is
now hardened with first-class CRM correlation fields, pre-create idempotency,
and a no-real-client replay proof.

## Live Proof Event

- `portalEventId`: `0dd7d7e8-3aba-43cc-9024-8250fbd7a4ca`
- Journey ledger source: synthetic internal Journey lifecycle event created by
  the Journey repo `crm:lifecycle-test` script.
- M365 CRM item: `CRM - New Signals` item `#32`.
- CRM title: `Guided AI Journey - GAIL Internal B8 Replay Proof`.
- First POST: accepted by M365, HTTP `202`; created CRM item `#32`.
- Replay POST: accepted by M365, HTTP `202`; CRM count stayed at one.
- Created receipt action: `Post_created_CRM_receipt_ack_to_Journey`, succeeded.
- Existing-item replay receipt action:
  `Post_existing_CRM_receipt_ack_to_Journey`, succeeded.
- Final HTTP intake flow state: `Started`.

## Live Changes Made

- Added `PortalEventId` text field to `CRM - New Signals`; indexed and
  read-back verified.
- Added `SourceCorrelationId` text field to `CRM - New Signals`; indexed and
  read-back verified.
- Updated flow `9582c422-158d-4975-ba7f-81b4d77e497b`
  (`GAIL - Custom site intake to CRM (create-only, HTTP)`) so it:
  - writes `PortalEventId` and `SourceCorrelationId` on created CRM items;
  - looks up existing CRM items by `PortalEventId` before create;
  - creates exactly one item when no match exists;
  - skips create and sends an existing-item receipt when one match exists;
  - stops for review when more than one match exists.

## Receiver Compatibility

The M365 replay branch returns the existing CRM item id/url and an
existing-item message. The Journey receiver currently accepts the B7 receipt
shape, so the live M365 payload keeps the receiver-compatible `crmStatus`
value while proving the distinct existing-item branch through action names,
message, run evidence, and unchanged CRM count.

Future Journey-side hardening can add an explicit `crmStatus = existing` enum
without changing the M365 dedupe path.

## Evidence

- Schema proof:
  `inventory/m365-interaction-agent-b8/b8-schema-proof-20260627-174034.md`
- Replay proof:
  `inventory/m365-interaction-agent-b8/b8-replay-proof-0dd7d7e8-3aba-43cc-9024-8250fbd7a4ca-20260627-235409.md`
- Created-run action evidence:
  `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260627-235741.json`
- Existing replay-run action evidence:
  `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260627-235719.json`
- Final flow state:
  `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260627-235808.json`
- Local approval capture:
  `.local/interaction-agent-approvals/b8b-approval-20260627-173147.json`
  (not committed; no typed phrase stored).

## Boundary

- No real client replay was used.
- No delete, merge, CRM suppression, external message, permission change, app
  registration, consent grant, QUO setup, or R4 delegated autonomy was
  performed.
- No callback URL from an inbound payload was accepted.
- No tenant secret or acknowledgement secret was written to git, DirectLink,
  docs, or inventory.
