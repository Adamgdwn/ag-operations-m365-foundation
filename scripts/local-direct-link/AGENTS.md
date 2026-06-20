# Direct Linux Link Agent Context

This Windows machine has a dedicated Ethernet cable link to the Linux build and
agent laptop. The expected daily interface is VS Code plus terminal agents; the
mapped drives are stable transport surfaces, not the main mental model.

## Stable Endpoints

- Windows: `10.77.77.1/30`
- Linux: `10.77.77.2/30`
- SSH alias: `linux-direct`
- SSH user: `adamgoodwin`
- Linux host: `pop-os`
- Shared skill: `direct-link`

## Shared Paths

- Linux code from Windows: `L:\`
- Direct exchange folder from Windows: `X:\`
- Linux code on Linux: `/home/adamgoodwin/code`
- Direct exchange on Linux: `/home/adamgoodwin/DirectLink/Exchange`

## Agent Defaults

- Load or follow the `direct-link` skill when a task involves this cable,
  cross-machine coordination, Linux-side work from Windows, or handoff files.
- Prefer `L:\` for inspecting or editing Linux-side repositories from Windows.
- Prefer `X:\` for handoff files, generated reports, exports, and temporary
  exchange artifacts.
- Prefer `ssh linux-direct` for Linux-side commands that should execute on the
  Linux host.
- Do not add a default route, DNS server, or internet gateway to the direct
  cable link.
- Do not copy private keys, credentials, `.env` files, or tenant secrets into
  `L:\`, `X:\`, or shared docs unless the user explicitly asks for that exact
  transfer.
- For large repo synchronization, check scope and destination before copying.

## Installed Skill Locations

- Windows Codex: `C:\Users\adamg\.codex\skills\direct-link`
- Windows Claude Code: `C:\Users\adamg\.claude\skills\direct-link`
- Linux Codex: `/home/adamgoodwin/.codex/skills/direct-link`
- Linux Claude Code: `/home/adamgoodwin/.claude/skills/direct-link`
- Linux project Codex: `/home/adamgoodwin/code/.codex/skills/direct-link`
- Linux project Claude Code: `/home/adamgoodwin/code/.claude/skills/direct-link`

To sync updates from Windows to all targets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\sync-direct-link-skill.ps1
```

## Terminal Variables

New Windows terminals should have:

- `DIRECT_LINK_HOME=C:\Users\adamg\DirectLink`
- `DIRECT_LINUX_HOST=linux-direct`
- `DIRECT_LINUX_IP=10.77.77.2`
- `DIRECT_LINUX_CODE=L:\`
- `DIRECT_LINUX_EXCHANGE=X:\`
- `DIRECT_LINK_RUNBOOK=C:\Users\adamg\DirectLink\RUNBOOK.md`
- `DIRECT_LINK_AGENT_CONTEXT=C:\Users\adamg\DirectLink\AGENTS.md`

## Health Check

Normal use should not require a manual command. If an agent needs to verify the
link, the Windows audit is:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Test-DirectLinuxLink.ps1
```

Expected result includes:

```json
"healthy": true
```
