# CRM Verifier (Chunk 3)

Generated: 2026-06-20 22:39:54

Result: FAIL
Failures: 3 | Warnings: 6 | Total checks: 172

Site: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs
Intake list: CRM - New Signals
Checks CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\crm-verify\crm-verify-checks-20260620-223702.csv
Transcript: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\crm-verify\crm-verify-20260620-223702.log

## Failures (must fix before / during Chunk 5 apply)

| Area | Item | Expected | Actual |
|---|---|---|---|
| Column | CRM - New Signals.IntakeSource | Choice | Missing |
| Intake field | IntakeSource | Present and visible | Missing |
| Required field | IntakeSource | Required=True | Missing |

## Warnings (review; not hard blockers)

| Area | Item | Expected | Actual |
|---|---|---|---|
| Required field | SignalType | Required=True | Required=False |
| Required field | Priority | Required=True | Required=False |
| Required field | NeedSummary | Required=True | Required=False |
| Required field | SourceText | Required=True | Required=False |
| Required field | NextAction | Required=True | Required=False |
| Required field | SignalStatus | Required=True | Required=False |

## Manual browser checks still required (Chunk 6 - a script cannot prove these)

- Sign in as a normal operator (not admin) and open Operations Cockpit.
- Click the CRM Command Center card; confirm it opens the command center page.
- Click New Signal; confirm the form is the clean CRM - New Signals form, not the
  legacy Intake Register, and that none of the 9 blocked technical fields appear.
- Save a GAIL-INTERNAL-WALKTHROUGH record and confirm it appears in the Triage Queue.

