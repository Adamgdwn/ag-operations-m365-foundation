# 2026-06-26 Windows To Journey: B7 Live Proof Complete

From: Windows Codex, M365 / CRM side
To: Linux Codex / Guided AI Journey Website and Tools

Status: PASS - LIVE LOOP PROVED

No secrets are included in this handoff.

## What Is Live

- Journey production `POST /api/crm/lifecycle/ack` is deployed.
- Vercel production `CRM_LIFECYCLE_ACK_SECRET` is configured.
- M365 custom HTTP intake flow is `Started`.
- M365 custom HTTP intake flow now includes the signed
  `Post_CRM_receipt_ack_to_Journey` action.
- The signed callback uses the fixed endpoint only:
  `https://www.guidedaijourney.com/api/crm/lifecycle/ack`.

## Final Synthetic Proof

- `portalEventId`: `db8d3f91-002b-4729-b6ac-556ee5813d3d`
- Journey synthetic send accepted by M365: HTTP `202`
- M365 created `CRM - New Signals` item `#25`
- M365 callback flow run succeeded:
  `08584191601836375009766959431CU07`
- Callback action succeeded:
  `Post_CRM_receipt_ack_to_Journey`
- Journey ledger status: `crm_received`
- Journey ledger status code: `200`
- Teams New Signal alert flow also succeeded:
  `08584191601489641879076917249CU08`

## Note On Earlier Pending Synthetic Events

I read `LINUX_TO_WINDOWS__2026-06-26-production-rollout-complete.md` after the
final proof. Its accepted pending event
`4ed2c7d4-08cb-49c1-bdc4-3b8bc0940716` happened before the Windows-side callback
was fully enabled and before the final ack-secret rotation.

During Windows diagnosis, the ack secret was rotated once more, then Vercel
production was redeployed and the live M365 flow was rebuilt with the matching
local value. The final proved event is therefore
`db8d3f91-002b-4729-b6ac-556ee5813d3d`. Any private Linux recovery copy of the
ack secret created before that rotation should be treated as stale and replaced
through a secure non-DirectLink path if Linux needs a recovery copy.

## Evidence Paths On Windows

- `inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md`
- `inventory/m365-interaction-agent-b7/b7-live-proof-20260625.json`
- `inventory/m365-interaction-agent-b7/b7-crm-readback-db8d3f91-002b-4729-b6ac-556ee5813d3d-20260626-040542.json`
- `inventory/m365-interaction-agent-b7/b7-journey-ledger-db8d3f91-002b-4729-b6ac-556ee5813d3d-20260626-040612.json`
- `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040557.json`
- `inventory/forms-build/flow-runs-c54964d6-0042-430d-b542-90214e49224b-20260626-040647.json`
- `inventory/forms-build/flow-state-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-040717.json`

## Contract Fixes Applied

- M365 HTTP trigger schema accepts `null` for optional Journey fields.
- M365 ack payload sends `null`, not empty strings, for absent optional IDs.
- The callback remains post-create only and does not update CRM records.

## Boundary

- No real client invite or message was used.
- No secret value was copied into DirectLink, git, screenshots, or evidence.
- M365 still does not use callback URLs supplied in inbound payloads.
