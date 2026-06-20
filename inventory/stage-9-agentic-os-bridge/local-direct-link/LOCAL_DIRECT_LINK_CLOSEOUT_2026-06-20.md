# Local Direct Link Closeout

Date: 2026-06-20

Status: Active and mounted.

## What Was Built

Created a durable local Windows/Linux machine bridge for agentic builds and
shared local work.

Core link:

- Windows host: `Windows2026`
- Windows interface: `Ethernet 2`
- Windows IP: `10.77.77.1/30`
- Linux host: `pop-os`
- Linux interface: `enp55s0`
- Linux IP: `10.77.77.2/30`
- SSH alias from Windows: `linux-direct`
- SSH user: `adamgoodwin`

Natural shared workspace:

- `L:` -> `\\10.77.77.2\linux-code` -> `/home/adamgoodwin/code`
- `X:` -> `\\10.77.77.2\direct-exchange` -> `/home/adamgoodwin/DirectLink/Exchange`
- VS Code workspace:
  `C:\Users\adamg\DirectLink\Direct Linux Agent Workspace.code-workspace`
- Agent context:
  `C:\Users\adamg\DirectLink\AGENTS.md`
- Agent skill:
  `skills/direct-link`
- Hidden Windows Startup watcher:
  `C:\Users\adamg\DirectLink\Watch-DirectLinuxShares.ps1`
- Desktop shortcuts:
  `Direct Linux Agent Workspace`, `Linux Code`, `Linux Direct Exchange`

## Verified

- Windows can ping Linux.
- Linux can ping Windows.
- Windows can SSH to Linux through `ssh linux-direct`.
- Windows Credential Manager stores the SMB credential for `10.77.77.2` as user
  `directlink`.
- `L:` and `X:` are mounted on Windows.
- Bidirectional write through `X:` was tested.
- No daily command is required after Windows sign-in; the watcher detects the
  SMB endpoint and repairs `L:` / `X:` automatically.
- Controlled repair test deleted `X:` and the watcher restored it automatically.
- New Windows terminals receive `DIRECT_LINUX_HOST`, `DIRECT_LINUX_CODE`,
  `DIRECT_LINUX_EXCHANGE`, and related direct-link environment variables.
- VS Code can open the direct link as a multi-root agent workspace.
- Codex and Claude Code can load the `direct-link` skill on Windows and Linux.
- The skill was validated and synced to Windows Codex, Windows Claude Code,
  Linux personal Codex, Linux personal Claude Code, and Linux project-scoped
  Codex/Claude Code skill folders.
- Final runbooks and agent context files were synced to the Linux live folder:
  `/home/adamgoodwin/direct-windows-link`.
- Windows has no default gateway or DNS on the direct Ethernet link.
- Linux has no default route on the direct Ethernet link.
- Windows scheduled link heartbeat remains active.
- Linux NetworkManager/systemd heartbeat remains active.

## Evidence

- `LOCAL_DIRECT_LINK_AUDIT_20260620-160307.json` - secure link healthy before
  Windows share mapping completed.
- `LOCAL_DIRECT_LINK_AUDIT_20260620-160834-MOUNTED.json` - final mounted state
  with `L:` and `X:` active.
- `LOCAL_DIRECT_LINK_AUDIT_20260620-162027-NOCODE-WATCHER.json` - final
  no-daily-command state after watcher installation and repair verification.
- `LOCAL_DIRECT_LINK_AUDIT_20260620-172026-SKILL-DOCS-FINAL.json` - final
  skill-enabled and documentation-synced state before shutdown.

## Canonical Docs

- `docs/LOCAL_AGENTIC_MACHINE_LINK_RUNBOOK.md`
- `config/LOCAL_AGENTIC_MACHINE_LINK_CONTRACT.json`
- `scripts/local-direct-link/`
- `skills/direct-link/`

## Operational Note

The normal experience is: plug in Ethernet, then use the VS Code workspace,
terminal agent environment variables, `L:`, `X:`, or the Desktop shortcuts. The
temporary HTTP bootstrap hub should remain stopped during normal operation. Use
SSH and the mapped drives for daily work. Start the hub only for recovery or
bootstrap.
