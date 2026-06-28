# Agent Instructions — ag-operations-m365-foundation

## CNS Role

This repository is the M365 Foundation layer of the Guided AI Labs Agentic OS CNS.

**CNS role:** First-class enterprise body — Microsoft 365 as a primary execution motor,
data lane, and enterprise integration surface. Not a secondary integration or plugin.

**In the 3-layer CNS model:**
- GAIL OS classifies and authorizes actions
- M365 Foundation executes approved enterprise actions (List writes, Planner tasks,
  SharePoint updates, Teams messages) and returns evidence
- Stage 9 (agentic bridge readiness) enables GAIL OS Connector registration

**Authority:** All M365 writebacks must flow through the OS Connector registry with
source refs, authority envelopes, and evidence packets. No unregistered write paths.

**Blocker:** BLK-005 — M365 app registration status in Entra is unconfirmed.
Resolve before Phase 4 implementation begins.

**Naming note (2026-06-26):** Several stage docs (e.g.
`M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md`, `M365_GRAPHIFY_UAOS_ALIGNMENT.md`) refer
to the execution layer as **UAOS / User AI Operating System**. UAOS was superseded by the
**Guided AI Labs Operating System (GAIL OS Rev 2) on 2026-06-21**; read "UAOS" in those
docs as GAIL OS. The governed bridge contract, access categories, and approval gates are
unchanged — only the canonical OS repo and name moved. A full rename across the stage docs
is tracked separately.

For cross-repo coordination state, see
`agentic-multi-agent-agent-builder/docs/build-control/`.

---

## Normal Startup

For ordinary scoped work:

1. run `git status --short`
2. read this file and `START_HERE.md`
3. inspect the specific stage doc, config, or script relevant to the task
4. run targeted validation after the change

Do not turn the full stage-doc set into an automatic startup chain for small edits — route
context via `00_INDEX.md` and `MASTER_EXECUTION_MAP.md`.

## Governance Triggers

This repo is governed business-substrate work. The following are risk-triggering and
require a named approval gate before execution: M365 writes to Lists/Planner/SharePoint/
Teams, app registrations, consent grants, Exchange Application RBAC, external sends, guest
access, public Forms, sharing changes, tenant policy changes, and any unattended
automation. See `M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md` §4 (access categories), §6
(identity/app posture), and §8 (stop, rollback, review rules). Default posture:
**read / propose / log first; write only through named approval gates.**

## Secret Handling

Do not print, commit, or index secrets or environment files. `M365_ENVIRONMENT.template.env`
is a template only — never commit a populated `.env`. Tenant IDs, client/app secrets, and
credentials stay out of the repository.
