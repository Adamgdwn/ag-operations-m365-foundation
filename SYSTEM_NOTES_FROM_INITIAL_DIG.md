# System Notes From Initial Dig

> **Local-machine track — Stage 4 input.** Device findings from the first pass.
> Start at [START_HERE.md](START_HERE.md).

These were found during the first pass on 2026-05-25.

## OneDrive / Known Folder Split

The Windows known folders were pointing at personal OneDrive paths:

- `C:\Users\adamg\OneDrive\Desktop`
- `C:\Users\adamg\OneDrive\Documents`
- `C:\Users\adamg\OneDrive\Pictures`

The active OneDrive environment variable pointed at the Prime Boiler business OneDrive:

- `C:\Users\adamg\OneDrive - Prime Boiler Services Ltd`

Both roots exist. This suggests a split-brain setup rather than a missing-folder issue.

## Startup / Reload Finding

An unrelated local-app finding was captured during the first machine dig. It is not
part of the AG Operations Microsoft 365 environment scope and should not be used as
restart guidance for this workspace.

## Event Log Signals

Recent logs showed:

- repeated Store app update failures with `0x80073D02`, commonly caused by apps being open during update
- one Codex app hang on 2026-05-24
- repeated Intel graphics/controller warnings
- Secure Boot SBAT update error at boot

These are notes for future cleanup, not immediate evidence of data loss.
