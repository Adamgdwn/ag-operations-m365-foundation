# B7 Lead Source Detail Proof

Date: 2026-06-25 MDT / 2026-06-26 UTC

Status: PASS. The live M365 intake and Teams alert flows now identify the
specific lead source detail for Guided AI Journey signals.

## Change

- The HTTP intake flow derives `Lead source detail` from optional lead-source
  payload fields, or from Journey `sourceAction` when those are absent.
- Known Journey action `admin_invited_person` renders as `Journey admin invite`.
- The CRM record keeps broad source in `IntakeSource` and stores the specific
  source line in `SourceText`.
- The New Signal Teams alert now includes a `Lead source` row, read from the CRM
  `SourceText` line.

## Live Proof

- Synthetic source proof portal event:
  `journey-portal-event-1782447883236`.
- CRM item created: `CRM - New Signals` item `#27`.
- CRM source:
  - `IntakeSource = Guided AI Journey`
  - `Lead source detail: Journey admin invite`
  - `Source action: admin_invited_person`
- Intake flow run:
  `08584191590010332113223187806CU18`, status `Succeeded`.
- Teams alert flow run:
  `08584191589676821842406276734CU16`, action
  `Post_to_New_Signal_channel`, status `Succeeded`.

## Evidence

- CRM read-back:
  `inventory/m365-interaction-agent-b7/b7-crm-readback-journey-portal-event-1782447883236-20260626-042719.json`
- Intake flow run:
  `inventory/forms-build/flow-runs-9582c422-158d-4975-ba7f-81b4d77e497b-20260626-042516.json`
- Teams flow run:
  `inventory/forms-build/flow-runs-c54964d6-0042-430d-b542-90214e49224b-20260626-042625.json`

## Boundary

This proof used a direct M365 source test with `ackRequested = false`, because
it was testing CRM and Teams source propagation rather than a Journey ledger
receipt callback. The earlier B7 live proof remains the callback proof. No real
client subject was used and no secret value was written to git, evidence, or
DirectLink.
