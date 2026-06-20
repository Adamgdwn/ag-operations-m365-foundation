# Local Agentic Machine Link Runbook

Date: 2026-06-20

Status: Active local infrastructure.

This runbook documents the direct Ethernet link between the Windows laptop and
the Linux laptop. The purpose is to give agentic builds, local repos, and
machine-specific automation a durable private path that does not depend on
Wi-Fi, cloud sync, or ad hoc file sharing.

## Mission

Maintain a secure, repeatable, self-checking cable link between:

- Windows working machine: `Windows2026`
- Linux build/agent machine: `pop-os`

The link exists so the two machines can safely coordinate local builds,
repository work, artifacts, and agent-assisted development without turning the
Ethernet cable into a general network route.

## Current Contract

| Item | Windows | Linux |
|---|---|---|
| Host | `Windows2026` | `pop-os` |
| Interface | `Ethernet 2` | `enp55s0` |
| Address | `10.77.77.1/30` | `10.77.77.2/30` |
| MAC observed by peer | `00-50-B6-F3-D1-56` | `60-CF-84-5C-2F-CD` |
| Default gateway on direct link | none | none |
| DNS on direct link | none | none |
| Durable automation | Windows scheduled tasks | NetworkManager + systemd timer |
| Secure channel | OpenSSH client alias `linux-direct` | OpenSSH server on `10.77.77.2:22` |

Windows connects to Linux as:

```powershell
ssh linux-direct
```

The Linux SSH user is:

```text
adamgoodwin
```

## Security Posture

The link is intentionally narrow:

- Direct subnet: `10.77.77.0/30`
- Windows side: `10.77.77.1`
- Linux side: `10.77.77.2`
- No default route on either side
- No DNS on the direct link
- Windows Firewall allows traffic only on `Ethernet 2` for `10.77.77.0/30`
- Linux SSH listens only on `10.77.77.2:22`
- Linux SSH password authentication is disabled
- Linux keyboard-interactive authentication is disabled
- Linux root login is disabled
- Linux `AllowUsers` is restricted to `adamgoodwin`
- Windows authenticates with a dedicated local Ed25519 key
- Windows pins the Linux SSH host key

Do not place private SSH keys, tenant secrets, client secrets, or `.env` files in
the shared runbook/docs area. Keep secret material local to the machine that
uses it.

## Live Windows Assets

The live automation and day-to-day tools are in:

```text
C:\Users\adamg\DirectLink
```

Important files:

- `Ensure-DirectLinuxLink.ps1` - reasserts the Windows IP, route, DNS, firewall,
  host alias, and status file.
- `Install-DirectLinuxLink.ps1` - installs Windows scheduled tasks and runs the
  immediate configuration.
- `Get-DirectLinuxLinkStatus.ps1` - reads the Windows-side link state.
- `Connect-DirectLinuxLink.ps1` - configures/uses the `linux-direct` SSH alias.
- `Test-DirectLinuxLink.ps1` - performs the end-to-end Windows/Linux audit.
- `Map-DirectLinuxShares.ps1` - maps `L:` and `X:` to the Linux Samba shares.
- `Watch-DirectLinuxShares.ps1` - hidden user-session watcher that reconnects
  the shared drives after the cable link comes alive.
- `Install-DirectLinuxSharesAutomount.ps1` - installs the hidden watcher and
  Desktop shortcuts for natural Explorer access.
- `Direct Linux Agent Workspace.code-workspace` - VS Code multi-root workspace
  for Windows tooling, Linux code, exchange files, and infrastructure docs.
- `AGENTS.md` - compact terminal-agent context for the direct link.
- `direct-link` skill - installed for Codex and Claude Code on both machines;
  canonical Windows copy is `C:\Users\adamg\.codex\skills\direct-link`.
- `Start-DirectLinkHub.ps1` / `Stop-DirectLinkHub.ps1` - temporary HTTP
  bootstrap hub for recovery only.
- `Use-DirectLinuxLink.ps1` - diagnostic/recovery launcher.
- `RUNBOOK.md` / `MISSION.md` - local quick-reference copies.

Windows status files:

- `C:\Users\adamg\DirectLink\direct-link-status.json`
- `C:\Users\adamg\DirectLink\direct-link.log`
- `C:\Users\adamg\DirectLink\install-direct-link.log`

## Live Linux Assets

Linux keeps its local assets in:

```text
/home/adamgoodwin/direct-windows-link
```

Important files:

- `linux-link-status.json` - Linux-side status snapshot.
- `RUNBOOK.md` - copied runbook.
- `MISSION.md` - mission contract.
- `Install-LinuxDirectLink.sh` - Linux setup/repair script.
- `Harden-LinuxDirectLinkSsh.sh` - optional SSH hardening repair script.

Linux system assets:

- NetworkManager profile: `direct-windows-link`
- Systemd timer: `direct-windows-link.timer`
- Systemd service: `direct-windows-link.service`
- SSH config fragment: `/etc/ssh/sshd_config.d/90-direct-windows-link.conf`

## Automation Model

Windows keeps the direct Ethernet address and firewall scope as persistent local
configuration. When the elevated installer has been used, Windows can also
re-apply its machine-level side through scheduled tasks:

- `DirectLinuxLink-AtStartup`
- `DirectLinuxLink-AtLogon`
- `DirectLinuxLink-OnNetworkConnect`
- `DirectLinuxLink-Periodic`

The periodic machine task runs every five minutes.

The natural shared-drive layer is user-session automation. At sign-in, Windows
starts a hidden watcher from:

```text
C:\Users\adamg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Direct Linux Shares Watcher.lnk
```

The watcher runs:

```text
C:\Users\adamg\DirectLink\Watch-DirectLinuxShares.ps1
```

It checks `10.77.77.2:445` every 15 seconds and quietly repairs:

```text
L: -> \\10.77.77.2\linux-code
X: -> \\10.77.77.2\direct-exchange
```

Watcher logs stay local at:

```text
C:\Users\adamg\DirectLink\direct-shares-watch.log
```

Linux re-applies and reports its side through:

```bash
systemctl list-timers --all direct-windows-link.timer --no-pager
systemctl status direct-windows-link.service --no-pager
```

The Linux timer also runs every five minutes.

## Daily Use

Normal daily use does not require running scripts. Plug in the Ethernet cable,
sign into Windows, and use the mapped drives in Explorer:

```text
L:
X:
```

`L:` is the Linux code workspace. `X:` is the direct exchange/handoff folder.
The Windows Desktop also has shortcuts named `Linux Code` and
`Linux Direct Exchange`.

For the expected VS Code workflow, use the Desktop shortcut named:

```text
Direct Linux Agent Workspace
```

It opens:

```text
C:\Users\adamg\DirectLink\Direct Linux Agent Workspace.code-workspace
```

The workspace includes:

- `DirectLink Windows Tools`
- `Linux Code` (`L:\`)
- `Direct Exchange` (`X:\`)
- `AG Operations Workspace Setup`

New Windows terminal sessions and VS Code terminals can use these persistent
user environment variables:

```text
DIRECT_LINK_HOME=C:\Users\adamg\DirectLink
DIRECT_LINUX_HOST=linux-direct
DIRECT_LINUX_IP=10.77.77.2
DIRECT_LINUX_CODE=L:\
DIRECT_LINUX_EXCHANGE=X:\
DIRECT_LINK_RUNBOOK=C:\Users\adamg\DirectLink\RUNBOOK.md
DIRECT_LINK_AGENT_CONTEXT=C:\Users\adamg\DirectLink\AGENTS.md
```

Codex and Claude Code also have the direct link as an installed skill:

```text
C:\Users\adamg\.codex\skills\direct-link
C:\Users\adamg\.claude\skills\direct-link
/home/adamgoodwin/.codex/skills/direct-link
/home/adamgoodwin/.claude/skills/direct-link
/home/adamgoodwin/code/.codex/skills/direct-link
/home/adamgoodwin/code/.claude/skills/direct-link
```

The skill teaches agents when to use `L:`, `X:`, `ssh linux-direct`, and the
Linux paths without rereading the whole runbook. To push an updated copy from
Windows to all installed targets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\.codex\skills\direct-link\scripts\sync-direct-link-skill.ps1
```

Open an SSH session only when you want an interactive shell:

```powershell
ssh linux-direct
```

Diagnostics are available when needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Test-DirectLinuxLink.ps1
```

Expected diagnostic result:

```json
"healthy": true
```

From Linux, check its local view:

```bash
cat ~/direct-windows-link/linux-link-status.json
ping -c 3 10.77.77.1
```

## Recovery

If Windows loses the link:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Install-DirectLinuxLink.ps1
```

If Linux loses the link and can still reach Windows HTTP bootstrap:

```bash
curl -fsSL http://10.77.77.1:8787/Install-LinuxDirectLink.sh | bash
```

The HTTP hub should normally be stopped. Use it only for bootstrap/recovery:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Start-DirectLinkHub.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Stop-DirectLinkHub.ps1
```

If SSH accepts the service but rejects the key, run this on Linux as
`adamgoodwin`, without `sudo`:

```bash
curl -fsSL http://10.77.77.1:8787/Repair-LinuxDirectLinkUser.sh | bash
```

## Natural Shared Workspace Layer

The operating target is that, after the cable is plugged in, the machines do not
feel like two isolated computers. SSH remains the control plane, but normal work
should happen through a shared workspace.

Target shape:

- Linux owns the code workspace: `/home/adamgoodwin/code`
- Linux owns the exchange folder: `/home/adamgoodwin/DirectLink/Exchange`
- Linux publishes `\\10.77.77.2\linux-code`
- Linux publishes `\\10.77.77.2\direct-exchange`
- Windows maps `L:` to `\\10.77.77.2\linux-code`
- Windows maps `X:` to `\\10.77.77.2\direct-exchange`
- Windows stores the SMB credential in Credential Manager
- Windows maps the drives persistently and starts a hidden Startup watcher
- Windows provides Desktop shortcuts: `Linux Code`, `Linux Direct Exchange`
- Linux Samba binds only to `10.77.77.2` / `enp55s0`
- Linux Samba allows only `10.77.77.1`
- SMB guest access is disabled
- SMB3 is the minimum protocol
- SMB payload encryption is a recommended hardening follow-up; current verified
  protection is physical cable scope + host allow-list + authenticated SMB user

The Linux share layer is active. If it needs to be repaired from Linux:

```bash
bash ~/direct-windows-link/configure-linux-drive-share.sh
```

Linux records the generated Samba credential in:

```text
/home/adamgoodwin/direct-windows-link/linux-samba-credential.txt
```

That file is `0600` on Linux and must not be committed or copied into the
workspace repo.

Windows mapping has been installed from the Linux-generated map script. The
normal repair path is automatic through the hidden watcher. If manual diagnostic
repair is ever needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Map-DirectLinuxShares.ps1
```

The current automatic remount layer is:

```text
C:\Users\adamg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Direct Linux Shares Watcher.lnk
C:\Users\adamg\DirectLink\Watch-DirectLinuxShares.ps1
```

Normal experience:

```text
plug in cable -> link self-heals -> watcher sees SMB -> L: and X: reconnect
```

Use `X:` for artifacts, handoff files, generated packets, and exported logs.
Use `L:` for browsing or working with the Linux code workspace when that is the
intent. Keep source repositories under git and sync intentionally; do not turn
either drive into an ungoverned repo mirror.

## Agentic Operating Rules

Agents may use this link for:

- build coordination;
- local repository synchronization when explicitly requested;
- artifact transfer;
- status and health checks;
- Linux-side command execution through `ssh linux-direct`;
- controlled bootstrap/recovery through the temporary HTTP hub.

Agents must not:

- create a default route over the direct cable;
- enable broad password SSH;
- expose Linux SSH on all interfaces for convenience;
- copy private keys into repos or shared docs;
- treat this link as a replacement for tenant governance, source control, or
  secrets management;
- sync large repo trees without checking scope and destination first.

## Verified Closeout

Final Windows audit on 2026-06-20 returned:

```json
"healthy": true
```

Verified properties:

- Windows could ping Linux.
- Linux could ping Windows.
- Windows could SSH to Linux as `adamgoodwin`.
- SCP round trip preserved the runbook SHA-256 hash.
- Windows direct interface had no gateway and no DNS.
- Linux direct interface had no gateway.
- Linux NetworkManager profile was persistent.
- Linux systemd heartbeat was enabled and active.
- Windows scheduled heartbeat was firing every five minutes.
- Windows had `L:` mapped to `\\10.77.77.2\linux-code`.
- Windows had `X:` mapped to `\\10.77.77.2\direct-exchange`.
- Windows had a hidden Startup watcher for `L:` / `X:` remount repair.
- Desktop shortcuts existed for `Linux Code` and `Linux Direct Exchange`.
- Controlled repair test deleted `X:` and the watcher restored it automatically.
- Bidirectional writes through `X:` were verified.
- `direct-link` skill validated and installed for Codex and Claude Code on
  Windows and Linux.
- Linux-side skill health check returned `"healthy": true`.
- Temporary HTTP bootstrap hub was stopped after SSH became the durable channel.
