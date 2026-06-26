# Session Turnover - 2026-06-25

Canonical restart file:
[START_HERE.md](START_HERE.md).

Current working docs:

- [docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md](docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md)
- [inventory/m365-interaction-agent-b7/B7_JOURNEY_MINIMAL_SIGNAL_ACK_CONTRACT_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_JOURNEY_MINIMAL_SIGNAL_ACK_CONTRACT_2026-06-25.md)
- [inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md)
- [inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md)

## Stop Point

Boxed late on 2026-06-25 after B1-B7 live proof.

Adam resumed the lane and approved building the live Journey callback and
related source-display usability. The repo now has a complete first M365
Interaction Agent signal lane from CRM ingress through Teams alerting, triage
evidence, durable writer decision, Journey source expansion, and Journey CRM
receipt acknowledgement.

## Proven State

- B1: `CRM - New Signals` created -> `Guided AI Labs / New Signal` Teams alert
  is live and proven.
- B2: selected CRM signal triage packet is working.
- B3: similar-record advisory is working and remains advisory-only.
- B4: one Agent Action Log `Suggested` row can be written after approval.
- B5: durable one-writer posture is recorded in M365 as Decision Register `#6`
  and Agent Action Log `#10`.
- B6: Guided AI Journey source proof created CRM item `#21`, triggered the New
  Signal Teams alert, and recorded Agent Action Log `#11` as `Suggested`.
- B7: Journey -> M365 -> Journey CRM receipt loop is live and proved.
- Lead-source display: CRM provenance now records `Lead source detail`, and the
  Teams alert includes a `Lead source` row.
- QUO remains parked.

## Live M365 Elements

- Teams channel: `Guided AI Labs / New Signal`.
- Teams connector: connected as `adamgoodwin@guidedailabs.com`.
- Flow: `GAIL - New Signal Teams alert`.
- Flow id/name: `c54964d6-0042-430d-b542-90214e49224b`.
- Flow state: `Started`.
- Source list: `CRM - New Signals`.
- Source list id: `a64ef810-ad45-407b-b1ea-516533a8611d`.
- HTTP intake flow: `GAIL - Custom site intake to CRM (create-only, HTTP)`.
- HTTP intake flow id/name: `9582c422-158d-4975-ba7f-81b4d77e497b`.
- Journey ack endpoint: configured server-side only; secret remains local or
  production-side and is not in git or DirectLink.

Important: the alert and HTTP intake flows may continue handling real incoming
CRM/Journey signals unless Adam disables them in Power Automate. This closeout
did not disable them.

## Proof Evidence

- B1 CRM proof item: `CRM - New Signals` `#19`.
- B5 decision evidence:
  `inventory/m365-interaction-agent-b5/B5_DURABLE_PERMISSION_DECISION_2026-06-25.md`.
- B6 proof:
  `inventory/m365-interaction-agent-b6/B6_GUIDED_AI_JOURNEY_CLIENT_INTAKE_2026-06-25.md`.
- B7 callback proof:
  - Portal event `db8d3f91-002b-4729-b6ac-556ee5813d3d`.
  - CRM item `#25`.
  - Journey ledger status `crm_received`.
  - Proof packet
    `inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md`.
- Lead-source proof:
  - Portal event `journey-portal-event-1782447883236`.
  - CRM item `#27`.
  - `Lead source detail: Journey admin invite`.
  - Proof packet
    `inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md`.

## DirectLink

No-secret Journey handoff:

- `X:\WINDOWS_TO_JOURNEY__2026-06-26-lead-source-detail-live.md`

Old DirectLink form-spec files were scrubbed to
`<<INTAKE_SECRET_SERVER_SIDE_ONLY>>` placeholders.

## Validation

- JavaScript syntax checks passed for the updated flow builders and helpers.
- JSON evidence parse passed with SharePoint read-back JSON handled as a
  hashtable because SharePoint emits both `Id` and `ID`.
- `git diff --check` passed; only normal LF/CRLF warnings appeared.
- Secret scan across docs, inventory, scripts, and `X:\` returned zero matches
  for the local intake and ack secrets.

## Do Not Run Without Fresh Approval

- Additional synthetic CRM proof item creation.
- Agent Action Log writes.
- Connector creation or repair.
- New flow creation/update outside the current live maintenance scope.
- Permission grants, app registration, admin consent, guest/share changes,
  external sends, QUO setup, deletes, billing/client commitments, or unattended
  automation.

## Next Work

1. Treat B7 as live and complete.
2. Optional refinements:
   - add a first-class SharePoint `portalEventId` column for dedupe/read-back;
   - add Journey operator retry/replay for `crm_failed_or_timed_out`;
   - decide whether to clean or backfill older synthetic pending rows;
   - run the next supervised triage lane on selected CRM item(s).
3. Keep secrets only in `.local` or production server-side environment stores.
