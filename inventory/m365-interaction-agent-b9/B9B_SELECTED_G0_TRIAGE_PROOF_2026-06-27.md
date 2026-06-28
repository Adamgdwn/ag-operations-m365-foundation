# B9b Selected G0 Triage Proof

Date: 2026-06-27

Status: Complete for selected read-only operation.

## Scope

B9b exercised the existing B2/B3/B4 triage lane against one selected internal
CRM signal and stopped at G0/R0.

Selected signal:

- CRM item: `CRM - New Signals` `#32`
- Title: `Guided AI Journey - GAIL Internal B8 Replay Proof`
- Basis: internal, no-real-client B8 replay proof item from the immediately
  prior Journey loop hardening chunk.

Visible B9b selection windows were opened first. No local selection capture file
landed before the operator instruction to carry on was executed conservatively
against the known internal proof item. Future B9b real-client or normal
operating runs should capture exact item id(s) in the visible B9b selection
window before reading tenant data.

## Result

Command:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Invoke-M365NewSignalTriage.ps1 -ItemId 32 -NoPause
```

Observed result:

- Connected as `adamgoodwin@guidedailabs.com`.
- Read selected `CRM - New Signals` item `#32`.
- Produced G0 local triage evidence.
- Found 8 possible related internal/proof records across 18 read-only candidate
  records.
- Kept the similar-record result advisory-only.
- Stopped before Agent Action Log write; the suggestion block is dry-run only.
- No CRM update, task, reminder, message, merge, delete, permission change,
  external send, QUO action, or R4 delegation occurred.

## Evidence

- Triage packet:
  `inventory/new-signal-triage/new-signal-triage-20260627-182259.md`
- Triage JSON:
  `inventory/new-signal-triage/new-signal-triage-20260627-182259.json`
- Transcript:
  `inventory/new-signal-triage/new-signal-triage-20260627-182259.log`
- Similar-record evidence:
  `inventory/new-signal-triage/new-signal-match-20260627-182259.json`
- Operating review row:
  `inventory/m365-interaction-agent-b9/b9-selected-signal-review-20260627-182259.csv`

## Operating Notes

- The G0 packet correctly keeps the next governance level at `G0`.
- The missing-info section flags owner and follow-up due date.
- The related-record advisory is noisy but useful for this internal proof
  corpus: it highlights accumulated synthetic Journey proof rows that may need
  a later no-delete cleanup/backfill decision, not automatic dedupe.
- The dry-run Suggested row preview is useful but not approved. A G1 Suggested
  row for item `#32` or any other selected signal remains a separate approval.

## Boundary

B9b proves the selected read-only operating routine only. It does not approve
future broad scans, real-client reads without explicit selection, CRM field
writes, Agent Action Log writes, tasks, reminders, external replies, QUO setup,
or delegated autonomy.
