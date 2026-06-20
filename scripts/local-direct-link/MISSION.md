# Direct Windows-Linux Agent Link Mission

Goal: maintain a durable, private, agent-ready Ethernet connection between the
Windows working laptop and the Linux build/agent laptop.

The final operating shape is not "run a script when needed." It is:

```text
plug in Ethernet -> link self-heals -> VS Code / terminal agents use the link naturally
```

## Address Plan

- Windows Ethernet adapter: `10.77.77.1/30`
- Linux Ethernet adapter: `10.77.77.2/30`
- Direct subnet: `10.77.77.0/30`
- Gateway on this link: none
- DNS on this link: none

This link must not become the default internet route on either machine.

## Primary Surfaces

- VS Code workspace:
  `C:\Users\adamg\DirectLink\Direct Linux Agent Workspace.code-workspace`
- SSH alias from Windows: `linux-direct`
- Linux code from Windows: `L:\`
- Direct exchange from Windows: `X:\`
- Linux code on Linux: `/home/adamgoodwin/code`
- Direct exchange on Linux: `/home/adamgoodwin/DirectLink/Exchange`

## Shared Agent Skill

The portable `direct-link` skill is installed for Codex and Claude Code on both
machines.

Canonical Windows skill:

```text
C:\Users\adamg\.codex\skills\direct-link
```

Versioned repo copy:

```text
C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\skills\direct-link
```

Installed targets:

- `C:\Users\adamg\.codex\skills\direct-link`
- `C:\Users\adamg\.claude\skills\direct-link`
- `/home/adamgoodwin/.codex/skills/direct-link`
- `/home/adamgoodwin/.claude/skills/direct-link`
- `/home/adamgoodwin/code/.codex/skills/direct-link`
- `/home/adamgoodwin/code/.claude/skills/direct-link`

Update all targets from Windows with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\sync-direct-link-skill.ps1
```

## Security Model

- The cable subnet is private and intentionally tiny.
- Windows allows traffic on this link only through scoped firewall rules for
  `Ethernet 2` and `10.77.77.0/30`.
- Linux SSH listens on `10.77.77.2:22`.
- Windows authenticates to Linux with the dedicated key:
  `C:\Users\adamg\.ssh\direct_linux_ed25519`
- Linux SSH password authentication, keyboard-interactive authentication, and
  root login remain disabled for this link.
- SMB is bound to the direct interface and allows only the Windows direct
  address.

This is a high-trust local operator environment, but it is still deliberately
scoped to the cable and the two known machines.

## Success Criteria

- Windows can ping `10.77.77.2`.
- Linux can ping `10.77.77.1`.
- Windows can SSH to Linux over the cable using `ssh linux-direct`.
- `L:` and `X:` are mounted and repaired automatically in the Windows session.
- VS Code and terminal agents can use the direct link without manual setup.
- Codex and Claude Code can load the `direct-link` skill on both machines.
- No default route, gateway, or DNS exists on the direct Ethernet link.
- Health/status files describe the link state on both sides.
