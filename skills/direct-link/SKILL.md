---
name: direct-link
description: "Use the private Windows/Linux Ethernet link for local agentic development. Trigger when the user mentions the direct link, linux-direct, the Linux laptop, Windows/Linux machine coordination, shared L: or X: drives, VS Code agent workspace, cross-machine file handoff, SSH to pop-os, or installing/syncing this skill for Codex or Claude Code on either machine."
---

# Direct Link

## Purpose

Use the durable private Ethernet link between the Windows working machine and
the Linux build/agent machine without rediscovering the topology.

Primary interface: VS Code and terminal agents. Explorer drives are convenience
surfaces; normal use should not require setup commands.

## Operating Rules

- Prefer existing surfaces before repair work.
- Do not add a default route, gateway, DNS server, or broad firewall exception
  to the direct cable link.
- Do not copy private keys, credentials, `.env` files, tenant secrets, or client
  secrets into shared paths unless the user explicitly asks for that exact file
  transfer.
- Treat this as a high-trust local operator environment, but keep the link
  narrow: direct cable, known hosts, known users, scoped paths.
- Ask before syncing large repo trees or replacing directories.
- Use `X:` / `/home/adamgoodwin/DirectLink/Exchange` for handoffs and generated
  reports.
- Use `L:` / `/home/adamgoodwin/code` for Linux-side repo work.
- Use `ssh linux-direct` from Windows when a command should execute on Linux.

## Path Map

On Windows:

- Linux code: `L:\`
- Direct exchange: `X:\`
- SSH alias: `linux-direct`
- DirectLink tools: `C:\Users\adamg\DirectLink`
- Agent context: `C:\Users\adamg\DirectLink\AGENTS.md`
- VS Code workspace:
  `C:\Users\adamg\DirectLink\Direct Linux Agent Workspace.code-workspace`

On Linux:

- Linux code: `/home/adamgoodwin/code`
- Direct exchange: `/home/adamgoodwin/DirectLink/Exchange`
- DirectLink tools: `/home/adamgoodwin/direct-windows-link`
- SSH user: `adamgoodwin`
- Linux host: `pop-os`

Read `references/direct-link-map.md` when you need the full contract, health
commands, or skill install locations.

## Workflow

1. Decide where the work belongs.
   - Windows-side orchestration, docs, and VS Code workspace tasks stay on
     Windows.
   - Linux-side builds, Linux-only tools, or Linux repo commands run through
     `ssh linux-direct` or operate under `L:\`.
   - Cross-agent handoffs use `X:\`.

2. Verify only when useful.
   - If a command fails, drives are missing, or the user asks for status, run
     `scripts/status-windows.ps1` from Windows or `scripts/status-linux.sh` from
     Linux.
   - Expected result is that ping, SSH, and shared workspace are healthy.

3. Repair only with intent.
   - Do not run installers as a first step.
   - Prefer the existing hidden watcher on Windows and Linux NetworkManager /
     systemd heartbeat.
   - If the user asks to repair the link, read `references/direct-link-map.md`
     before changing network configuration.

4. Push this skill deliberately.
   - From Windows, run `scripts/sync-direct-link-skill.ps1` to mirror this skill
     to Windows Claude Code plus Linux Codex and Claude Code over `L:\`.
   - Keep one canonical skill folder per machine/tool:
     `~/.codex/skills/direct-link` and `~/.claude/skills/direct-link`.

## Agent Notes

- Prefer terminal environment variables when present:
  `DIRECT_LINUX_HOST`, `DIRECT_LINUX_CODE`, `DIRECT_LINUX_EXCHANGE`,
  `DIRECT_LINK_HOME`, `DIRECT_LINK_AGENT_CONTEXT`.
- For Claude Code, this skill can also be invoked directly as `/direct-link`.
- For Codex, this skill should trigger automatically on direct-link tasks.
