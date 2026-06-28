# Session Turnover - 2026-06-25

Canonical restart file:
[START_HERE.md](START_HERE.md).

Current working docs:

- [docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md](docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md)
- [inventory/m365-interaction-agent-b7/B7_JOURNEY_MINIMAL_SIGNAL_ACK_CONTRACT_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_JOURNEY_MINIMAL_SIGNAL_ACK_CONTRACT_2026-06-25.md)
- [inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_LIVE_PROOF_2026-06-25.md)
- [inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md](inventory/m365-interaction-agent-b7/B7_LEAD_SOURCE_PROOF_2026-06-25.md)

## Stop Point

Boxed late on 2026-06-25 after B1-B7 live proof; updated 2026-06-27 after B8b
Journey loop hardening proof and B9b selected internal G0 triage proof.

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
- B8a: Journey loop hardening local design is executed. The packet proposes
  first-class `PortalEventId` and `SourceCorrelationId`, defers CRM-local
  `ReceiptStatus`, defines duplicate/replay handling, and prepared the B8b live
  approval boundary that was later consumed for the 2026-06-27 proof.
- B8b: Journey loop hardening is live and proved. Indexed `PortalEventId` and
  `SourceCorrelationId` fields now exist on `CRM - New Signals`; the live HTTP
  intake flow performs pre-create idempotency; a synthetic/internal Journey
  replay kept one CRM item for one `portalEventId`.
- B9a: selected-signal operating triage local readiness is executed. The packet
  indexes prior B1/B6 triage evidence, creates queue/review templates, and keeps
  future tenant activity behind selected G0 read-only runs or per-item G1
  approval.
- B9b: selected read-only operating triage is proved for internal no-real-client
  CRM item `#32`. The run produced local G0 triage/advisory evidence and stopped
  before any Agent Action Log write.
- B10a: QUO inbound source proof local readiness is executed. The packet
  defines event mapping, ingress options, normalized CRM shape, duplicate and
  raw payload policies, disable path, live decision worksheet, proof checklist,
  and the future live approval boundary without touching QUO or Microsoft 365.
  B10b is now scoped as an implementation-ready placeholder/design closeout; live
  QUO proof moves to B10c or a later source-expansion stage.

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
- B8a local hardening packet:
  - Packet
    `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.md`.
  - Summary JSON
    `inventory/m365-interaction-agent-b8/b8-journey-loop-hardening-packet-20260627-091238.json`.
  - Config
    `config/M365_INTERACTION_AGENT_B8_JOURNEY_LOOP_HARDENING.json`.
  - Packet generator
    `scripts/New-M365B8JourneyLoopHardeningPacket.ps1`.
- B8b live hardening proof:
  - Proof packet
    `inventory/m365-interaction-agent-b8/B8B_LIVE_PROOF_2026-06-27.md`.
  - Schema proof
    `inventory/m365-interaction-agent-b8/b8-schema-proof-20260627-174034.md`.
  - Replay proof
    `inventory/m365-interaction-agent-b8/b8-replay-proof-0dd7d7e8-3aba-43cc-9024-8250fbd7a4ca-20260627-235409.md`.
  - Portal event
    `0dd7d7e8-3aba-43cc-9024-8250fbd7a4ca`.
  - CRM item `#32`.
- B9a local operating triage packet:
  - Packet
    `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.md`.
  - Summary JSON
    `inventory/m365-interaction-agent-b9/b9-selected-signal-operating-triage-packet-20260627-093338.json`.
  - Queue template
    `inventory/m365-interaction-agent-b9/b9-selected-signal-queue-20260627-093338.csv`.
  - Review template
    `inventory/m365-interaction-agent-b9/b9-operating-review-20260627-093338.csv`.
  - Config
    `config/M365_INTERACTION_AGENT_B9_SELECTED_SIGNAL_OPERATING_TRIAGE.json`.
  - Packet generator
    `scripts/New-M365B9SelectedSignalOperatingTriagePacket.ps1`.
- B9b selected G0 triage proof:
  - Proof packet
    `inventory/m365-interaction-agent-b9/B9B_SELECTED_G0_TRIAGE_PROOF_2026-06-27.md`.
  - Selected CRM item `#32`.
  - Triage packet
    `inventory/new-signal-triage/new-signal-triage-20260627-182259.md`.
  - Triage JSON
    `inventory/new-signal-triage/new-signal-triage-20260627-182259.json`.
  - Similar-record evidence
    `inventory/new-signal-triage/new-signal-match-20260627-182259.json`.
  - Review CSV
    `inventory/m365-interaction-agent-b9/b9-selected-signal-review-20260627-182259.csv`.
- B10a local QUO inbound source proof packet:
  - Packet
    `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.md`.
  - Summary JSON
    `inventory/m365-interaction-agent-b10/b10-quo-inbound-source-proof-packet-20260627-094929.json`.
  - Event mapping
    `inventory/m365-interaction-agent-b10/b10-quo-event-mapping-20260627-094929.csv`.
  - Live decision worksheet
    `inventory/m365-interaction-agent-b10/b10-quo-live-decision-worksheet-20260627-094929.csv`.
  - Proof checklist
    `inventory/m365-interaction-agent-b10/b10-quo-proof-checklist-20260627-094929.csv`.
  - Config
    `config/M365_INTERACTION_AGENT_B10_QUO_INBOUND_SOURCE_PROOF.json`.
  - Packet generator
    `scripts/New-M365B10QuoInboundSourceProofPacket.ps1`.

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
2. B8a local hardening packet and B8b live replay/idempotency proof are
   complete. Any further B8 cleanup, backfill, replay, schema change, or flow
   update needs a fresh approval boundary and visible interaction surface.
3. B9a local readiness and B9b selected internal G0 proof are complete. Future
   B9 normal-client reads still require exact selected item id(s), and any G1
   Suggested row remains a separate per-item approval.
4. B10a local readiness is complete. B10b placeholder/design closeout is next;
   B10c/later live QUO proof remains gated:
   - name approved QUO business intake number(s);
   - name the first no-real-client or internal event class;
   - choose ingress option and approve secret/signature storage plus revoke path;
   - approve raw payload evidence location and retention/redaction rule;
   - approve duplicate/idempotency rule and owner/disable path;
   - confirm outbound SMS, callback, and QUO API send remain blocked.
5. Keep secrets only in `.local` or production server-side environment stores.
