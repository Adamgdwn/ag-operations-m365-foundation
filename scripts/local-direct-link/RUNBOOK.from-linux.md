# Direct Link Compact Runbook

Date: 2026-06-20

Status: Active, mounted, skill-enabled.

## Final Shape

This is a private Windows/Linux cable link for VS Code, terminal agents, local
builds, shared artifacts, and cross-machine coordination.

Normal use:

```text
plug in Ethernet -> link self-heals -> agents use the skill, SSH, L:, and X:
```

## Stable Contract

- Windows host: `Windows2026`
- Windows direct adapter: `Ethernet 2`
- Windows direct IP: `10.77.77.1/30`
- Linux host: `pop-os`
- Linux direct adapter: `enp55s0`
- Linux direct IP: `10.77.77.2/30`
- Linux SSH user: `adamgoodwin`
- SSH alias from Windows: `linux-direct`
- Direct subnet: `10.77.77.0/30`
- Gateway on this link: none
- DNS on this link: none

## Shared Workspace

Windows:

- `L:` -> `\\10.77.77.2\linux-code`
- `X:` -> `\\10.77.77.2\direct-exchange`

Linux:

- `/home/adamgoodwin/code`
- `/home/adamgoodwin/DirectLink/Exchange`

Use `L:` / `/home/adamgoodwin/code` for Linux-side repositories. Use `X:` /
`/home/adamgoodwin/DirectLink/Exchange` for handoffs, reports, generated
packets, and temporary exchange artifacts.

## Agent Skill

The `direct-link` skill is installed for Codex and Claude Code on both machines.

Installed targets:

- `C:\Users\adamg\.codex\skills\direct-link`
- `C:\Users\adamg\.claude\skills\direct-link`
- `/home/adamgoodwin/.codex/skills/direct-link`
- `/home/adamgoodwin/.claude/skills/direct-link`
- `/home/adamgoodwin/code/.codex/skills/direct-link`
- `/home/adamgoodwin/code/.claude/skills/direct-link`

From Windows, sync an updated skill to all targets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\sync-direct-link-skill.ps1
```

## Health Checks

From Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\status-windows.ps1
```

From Linux:

```bash
bash ~/.codex/skills/direct-link/scripts/status-linux.sh
```

Expected result includes:

```json
"healthy": true
```

## Guardrails

- Do not add a default route, gateway, or DNS to the direct link.
- Do not broaden SSH or SMB beyond the direct cable path.
- Do not copy private keys, credentials, `.env` files, tenant secrets, or client
  secrets into shared paths unless explicitly requested.
- Keep the temporary HTTP bootstrap hub stopped except during recovery.
