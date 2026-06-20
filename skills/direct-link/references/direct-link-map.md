# Direct Link Map

## Mission

Maintain a private direct Ethernet path between the Windows working machine and
the Linux build/agent machine for VS Code, terminal agents, repo work, and
artifact handoff.

## Network

- Subnet: `10.77.77.0/30`
- Windows: `10.77.77.1/30`
- Linux: `10.77.77.2/30`
- Windows interface: `Ethernet 2`
- Linux interface: `enp55s0`
- Gateway: none
- DNS: none
- Internet routing over this link: not allowed

## Identity

- Windows host: `Windows2026`
- Linux host: `pop-os`
- Linux user: `adamgoodwin`
- SSH alias from Windows: `linux-direct`
- SSH target: `10.77.77.2:22`

## Shared Workspace

Windows view:

- `L:\` -> `\\10.77.77.2\linux-code`
- `X:\` -> `\\10.77.77.2\direct-exchange`

Linux view:

- `/home/adamgoodwin/code`
- `/home/adamgoodwin/DirectLink/Exchange`

Use `L:\` or `/home/adamgoodwin/code` for Linux-side repository work. Use `X:\`
or `/home/adamgoodwin/DirectLink/Exchange` for handoffs, generated packets,
reports, logs, and temporary exchange artifacts.

## Windows Assets

- Live tools: `C:\Users\adamg\DirectLink`
- Runbook: `C:\Users\adamg\DirectLink\RUNBOOK.md`
- Agent context: `C:\Users\adamg\DirectLink\AGENTS.md`
- VS Code workspace:
  `C:\Users\adamg\DirectLink\Direct Linux Agent Workspace.code-workspace`
- Hidden share watcher:
  `C:\Users\adamg\DirectLink\Watch-DirectLinuxShares.ps1`
- Watcher log:
  `C:\Users\adamg\DirectLink\direct-shares-watch.log`

Persistent user environment variables:

- `DIRECT_LINK_HOME=C:\Users\adamg\DirectLink`
- `DIRECT_LINUX_HOST=linux-direct`
- `DIRECT_LINUX_IP=10.77.77.2`
- `DIRECT_LINUX_CODE=L:\`
- `DIRECT_LINUX_EXCHANGE=X:\`
- `DIRECT_LINK_RUNBOOK=C:\Users\adamg\DirectLink\RUNBOOK.md`
- `DIRECT_LINK_AGENT_CONTEXT=C:\Users\adamg\DirectLink\AGENTS.md`

## Linux Assets

- Live tools: `/home/adamgoodwin/direct-windows-link`
- NetworkManager profile: `direct-windows-link`
- systemd timer: `direct-windows-link.timer`
- systemd service: `direct-windows-link.service`
- SSH config fragment:
  `/etc/ssh/sshd_config.d/90-direct-windows-link.conf`

## Skill Install Locations

Windows:

- Codex: `C:\Users\adamg\.codex\skills\direct-link`
- Claude Code: `C:\Users\adamg\.claude\skills\direct-link`

Linux:

- Codex: `/home/adamgoodwin/.codex/skills/direct-link`
- Claude Code: `/home/adamgoodwin/.claude/skills/direct-link`

The same skill folder should be present in all four locations.

## Health Checks

From Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\status-windows.ps1
```

From Linux:

```bash
bash ~/.codex/skills/direct-link/scripts/status-linux.sh
```

Expected health:

- Windows can ping `10.77.77.2`.
- Linux can ping `10.77.77.1`.
- Windows can SSH with `ssh linux-direct`.
- `L:` and `X:` are mounted on Windows.
- No default route or DNS is created on the direct cable.

## Repair Boundaries

Do not change routing or firewall posture unless the user is explicitly asking
for network repair. When repairing:

- Preserve no gateway and no DNS on the direct link.
- Preserve scoped Windows Firewall rules for `Ethernet 2` and `10.77.77.0/30`.
- Preserve Linux SSH listening on `10.77.77.2`.
- Preserve disabled SSH password and keyboard-interactive authentication.
- Keep the temporary HTTP bootstrap hub stopped except during bootstrap/recovery.
