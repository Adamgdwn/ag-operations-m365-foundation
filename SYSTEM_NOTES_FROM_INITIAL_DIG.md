# System Notes From Initial Dig

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

Prime Portfolio Canvas had a startup shortcut that launches:

- `C:\Users\adamg\01. Code Projects\Prime Portfolio Canvas 2.0\Start_Workspace_Server_Only.ps1`

That script previously hardcoded a Codex-managed bundled Python path. It was changed to fall back to `python.exe` if the bundled runtime is unavailable.

The app reload logic also had a fallback issue: it would trust an empty primary localStorage workspace over a valid last-known-good backup. That was patched in:

- `C:\Users\adamg\01. Code Projects\Prime Portfolio Canvas 2.0\app.js`
- `C:\Users\adamg\01. Code Projects\Prime Portfolio Canvas 2.0\dist\sharepoint-package\app.js`

## Event Log Signals

Recent logs showed:

- repeated Store app update failures with `0x80073D02`, commonly caused by apps being open during update
- one Codex app hang on 2026-05-24
- repeated Intel graphics/controller warnings
- Secure Boot SBAT update error at boot

These are notes for future cleanup, not immediate evidence of data loss.

