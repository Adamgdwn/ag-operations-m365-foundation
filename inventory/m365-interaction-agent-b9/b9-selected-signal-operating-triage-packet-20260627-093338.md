# B9 Selected Signal Operating Triage Packet

Generated: 2026-06-27T09:33:38.2850072-06:00
Mode: local-only
Safety: No Microsoft 365 connection, no live tenant read, no CRM write, no Agent Action Log write, no flow update, no HTTP send, no secret read.

## Purpose

Turn the proven B2/B3/B4 New Signal triage lane into a repeatable operating routine for selected CRM signals, without broad scanning or unattended writes.

## Operating Routine

1. Adam selects exact CRM item ids, a source type, or a narrow time window.
2. Run G0/R0 selected read-only triage for one to three selected items.
3. Review each packet with the operating labels in the review CSV.
4. Tune only visible decision-rule issues; do not expand the action surface.
5. If approved for a selected item, record at most one G1/R1 Suggested Agent Action Log row.

## Run Modes

| Mode | Governance | Tenant touch | Command pattern |
|---|---|---|---|
| localExistingEvidence | G0/R0 | False | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\New-M365B9SelectedSignalOperatingTriagePacket.ps1 -NoPause` |
| selectedReadOnlyTriage | G0/R0 | read-only | `pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -ItemId <crmItemId> -NoPause` |
| selectedSuggestedRow | G1/R1 | writes one Agent Action Log row only after approval prompt | `pwsh -File scripts\Invoke-M365NewSignalTriage.ps1 -ItemId <crmItemId> -Apply -NoPause` |

## Seed Evidence

| Label | CRM item | Source | Packet exists | Prior G1 | Note |
|---|---:|---|---|---|---|
| B1 internal New Signal alert proof | 19 | Direct | True | Agent Action Log #9 | Prior proof item. Use as packet-shape evidence, not as a new operating recommendation. |
| B6 Guided AI Journey intake proof | 21 | Guided AI Journey | True | Agent Action Log #11 | Prior Journey source proof. Use as packet-shape evidence, not as a new operating recommendation. |

## Selection Policy

- Adam selects exact CRM item ids, or a narrow source/time window, before live read-only triage.
- Default batch size is one to three selected items while the operating routine is being tuned.
- No unattended broad scanning of CRM - New Signals.
- Internal proof items may be reviewed as examples, but should not create duplicate Suggested rows.
- A selected real client signal may be read and summarized, but any external reply, commitment, merge, task, reminder, or CRM update remains blocked until separately approved.

## Operating Review Labels

- `useful_triage`
- `noisy_or_premature`
- `missing_field_or_data_issue`
- `source_ingress_issue`
- `future_automation_candidate`
- `do_not_automate`

## Duplicate Policy

Do not write a second Suggested Agent Action Log row for the same CRM signal unless Adam explicitly approves a duplicate/superseding suggestion.

## Evidence Files

- Queue CSV: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b9\b9-selected-signal-queue-20260627-093338.csv`
- Review CSV: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b9\b9-operating-review-20260627-093338.csv`
- Summary JSON: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\m365-interaction-agent-b9\b9-selected-signal-operating-triage-packet-20260627-093338.json`

## Approval Boundary

Selected live read:
- Adam selects CRM item id(s), source, or a narrow time window.
- The run is G0/R0 read-only and writes local evidence only.

Selected Suggested row:
- Adam approves one G1/R1 Suggested Agent Action Log row for a named CRM item.
- The row remains Suggested only; it does not approve or execute the recommendation.
- Duplicate Suggested rows are blocked unless Adam explicitly allows a duplicate/superseding row.

## Stop Conditions

- No live B8b schema or flow update from B9.
- No broad or unattended CRM scan.
- No Agent Action Log write without selected item and approval.
- No CRM field update, task, reminder, calendar item, merge, close, delete, or suppression.
- No external email, Teams chat, SMS, phone call, callback, invite, or client commitment.
- No QUO setup or outbound QUO action.
- No R4 delegated autonomy.

## Acceptance

- B9 local packet exists and names the operating routine, selection policy, review labels, duplicate policy, evidence paths, and stop conditions.
- Queue and review CSV templates exist for selected-signal operation.
- Existing B2/B3/B4 triage evidence is indexed as seed evidence without rerunning tenant reads or writes.
- Future selected-signal runs can stop at G0 with only local evidence.
- Any G1 row remains Suggested, linked to evidence, and not approved or executed.
