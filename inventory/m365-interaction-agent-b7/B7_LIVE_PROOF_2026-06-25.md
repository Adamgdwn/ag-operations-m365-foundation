# B7 Live Proof - Guided AI Journey CRM Receipt Ack

Date: 2026-06-25 MDT / 2026-06-26 UTC

Status: PASS. The Guided AI Journey -> M365 -> Guided AI Journey CRM receipt
loop is live and proved with a synthetic internal event. No real client subject
was used and no secret was copied to git or DirectLink.

## Live Proof Event

- `portalEventId`: `db8d3f91-002b-4729-b6ac-556ee5813d3d`
- Journey synthetic command: `npm run crm:lifecycle-test`
- Journey send result: accepted by M365, HTTP `202`
- M365 CRM item: `CRM - New Signals` item `#25`
- CRM title: `Guided AI Journey - GAIL Internal CRM Ack Test`
- Journey final status: `crm_received`
- Journey ack status code: `200`
- Teams alert flow: latest New Signal alert run succeeded and posted to the
  `New Signal` channel.

## Evidence

- CRM read-back:
  `inventory/m365-interaction-agent-b7/b7-crm-readback-db8d3f91-002b-4729-b6ac-556ee5813d3d-20260626-040542.json`
- M365 HTTP intake + callback run:
  `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040557.json`
- Journey ledger read-back:
  `inventory/m365-interaction-agent-b7/b7-journey-ledger-db8d3f91-002b-4729-b6ac-556ee5813d3d-20260626-040612.json`
- Teams alert flow run:
  `inventory/forms-build/flow-runs-c54964d6-0042-430d-b542-90214e49224b-20260626-040647.json`
- Final HTTP intake flow state:
  `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040717.json`

## Live Changes Made

- Configured Vercel production `CRM_LIFECYCLE_ACK_SECRET`.
- Redeployed Guided AI Journey production and confirmed
  `https://www.guidedaijourney.com/api/crm/lifecycle/ack` authorizes signed
  requests.
- Stored the matching ack secret locally under `.local/flow-builder`.
- Updated the live M365 custom HTTP intake flow with the signed
  `Post_CRM_receipt_ack_to_Journey` action.
- Updated the M365 request schema to accept `null` for optional Journey fields.
- Updated the M365 ack payload to send `null`, not empty strings, for absent
  optional IDs.

## Boundary

- No real client was invited or messaged.
- No callback URL from an inbound payload is used.
- No secret value was written to git, DirectLink, or evidence files.
- The live path remains create-only into `CRM - New Signals`; the callback only
  confirms receipt back to Journey after the CRM item exists.
