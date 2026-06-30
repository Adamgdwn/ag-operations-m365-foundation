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

**2026-06-29 agentic IO route:** Freedom may coordinate intent, ask for M365
state, and consume results, but Freedom-origin task completion that touches
Microsoft 365 must route through GAIL OS authority and evidence first. Direct
Freedom-to-M365 writes are not an approved lane. Use
`docs/2026-06-29_M365_AGENTIC_IO_AND_GAIL_OS_BRIDGE_CONTRACT.md` and
`config/M365_AGENTIC_IO_GAIL_OS_BRIDGE_CONTRACT.json` for the current
information-out, information-in, triggered-action, and deliverable-out contract.

**Authority:** All M365 writebacks must flow through the OS Connector registry with
source refs, authority envelopes, and evidence packets. No unregistered write paths.

**Blocker:** BLK-005 — M365 production connector app registration and consent
posture is not open for Phase 4. A tenant-local delegated CLI app exists for
Linux setup/read-only proof, but that does not authorize production GAIL OS
connector writes or broad M365 permission expansion.

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
3. use `docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md` as the
   active execution plan unless the task explicitly asks for historical proof
4. inspect the specific stage doc, config, or script relevant to the task
5. run targeted validation after the change

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
