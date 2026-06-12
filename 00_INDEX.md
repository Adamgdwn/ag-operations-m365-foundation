# 00 — Start Here

**AG Operations / Guided AI Labs — Microsoft 365 Foundation**

Last updated: 2026-06-12

This is the single entry point for the workspace. Open this first. It tells you
what the project is, where it currently stands, which document is canonical, and
what decision is waiting next.

---

## What this project is

We are building **Microsoft 365 into a clean, governed operating substrate** for
AG Operations and Guided AI Labs — so that a future Agentic OS (built elsewhere)
can safely connect through scoped, audited access.

We are **not** building the Agentic OS here. We are building the foundation it
plugs into.

```text
Agentic OS  ->  governed bridge  ->  M365 touchpoint router  ->  correct M365 surface
```

Working principle: **classify intent first, then route to the right M365 surface**
(SharePoint for records, OneDrive for drafts, Teams for collaboration, Exchange
for comms, Planner/Lists for state, Entra for identity, Purview/Defender for
governance). Email is **not** the hub.

---

## Where we are right now

The canonical execution plan is the **10-stage roadmap**:
[M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md).

| Stage | Name | Status |
|---|---|---|
| 0 | Setup Control Room | ✅ Done — env template, PS modules installed (current-user), inventory scripts |
| 1 | Current-State Inventory | ✅ Done — valid run `20260610-173554`, written report |
| 2 | Identity & Admin Foundation | ✅ Done 2026-06-11 — safety net (break-glass ×2), `contact@` admin stripped, re-inventory confirms target role matrix |
| 3 | SharePoint Information Architecture | ✅ Done 2026-06-12 — all 5 sites built (AG Operations, Guided AI Labs, Change Leadership Tools, Shared Libraries, Guided AI Journey) with Hybrid libraries + folders + 5 metadata columns, external sharing OFF; re-inventory PASS |
| 4 | OneDrive & Local Machine Dovetail | ✅ Done 2026-06-12 — operator identity `adamgoodwin@guidedailabs.com` connected to OneDrive (`Business2`); 3-lane Chrome model (Personal / Prime Boiler / **AI Labs** = operator) with imported SharePoint+admin bookmarks, verified loading the Stage-3 sites; known folders left on Personal (genuinely personal content), business drafts routed to `OneDrive - A.G. Operations Ltd`; 855 MB dead Chrome profile data deleted. Working doc: [M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md](M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md) |
| **5** | **Exchange & Communication Routing** | **◀ Current — inventory/design started; working doc + read-only Exchange inventory runner added** |
| 6 | Teams, Planner, Lists & Operating State | ⬜ Planned |
| 7 | Security, Governance & External Sharing | ⬜ Planned |
| 8 | Client Workspace Reference Pattern | ⬜ Planned |
| 9 | Agentic OS Bridge Readiness | ⬜ Planned |

**Live tenant changes so far:** Stage 2 identity safety net and role cleanup,
Stage 3 SharePoint site provisioning, and Stage 4 local OneDrive/browser cleanup.
Each tenant write was gated and read-back-verified. Stage 5 starts with **read-only**
Exchange inventory before any mailbox, alias, forwarding, calendar, or license
change. This remains a human-supervised setup, not unattended automation.

---

## Document map

### Canonical plan (read these to know what to do)

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) — **canonical** staged
  execution order (Stages 0–9). This is the source of truth for *what happens next*.
- [guided-ai-labs-m365-foundation-build-brief.md](guided-ai-labs-m365-foundation-build-brief.md)
  — comprehensive reference/design spec behind the roadmap (the "why" and the
  detailed target architecture). Defers to the roadmap for sequencing.

### Current work — Stage 5 Exchange & Communication Routing

- [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
  — **current working document** for mailbox types, aliases, calendar ownership,
  support/front-door routing, and durable record capture.
- [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1)
  — **read-only** Exchange Online inventory: mailboxes, aliases, forwarding,
  delegates, Send As, groups, recipients, and calendar-processing posture. Run this
  before deciding any Stage 5 writes.

### Completed foundation stages

- [M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md) —
  Stage 2 account role matrix, target identity model, break-glass plan, role
  reduction sequence, decision log, and execution log. **Complete 2026-06-11.**
- [M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md](M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md)
  — Stage 3 SharePoint information architecture and provisioning log.
  **Complete 2026-06-12.**
- [M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md](M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md)
  — Stage 4 OneDrive/local/browser lane model. **Complete 2026-06-12.**

- [IDENTITY_NAMING_STANDARD.md](IDENTITY_NAMING_STANDARD.md) — the legend: every
  identity type, what it means, its naming pattern, and how much power it may hold.
- [scripts/Invoke-M365Stage2Verify.ps1](scripts/Invoke-M365Stage2Verify.ps1) —
  **read-only** Level-1 verification: signs you in (device-code, your MFA) and
  prints the live role matrix + Stage 2 plan checks. Changes nothing. Run this
  first to watch the visible-execution loop before any write.
- [scripts/Invoke-M365Stage2CreateBreakglass.ps1](scripts/Invoke-M365Stage2CreateBreakglass.ps1)
  — **live write** (idempotent): creates `breakglass-01/02` and assigns Global
  Administrator. Ran 2026-06-11; re-runs safely skip existing accounts.

### Current state (read these to know what exists)

- [M365_STAGE_1_CURRENT_STATE_INVENTORY.md](M365_STAGE_1_CURRENT_STATE_INVENTORY.md)
  — written summary of the tenant as it exists today.
- [inventory/stage-1-current-state/20260610-173554/](inventory/stage-1-current-state/20260610-173554/)
  — the **valid** raw inventory data. (The `20260610-172735` and `-173346`
  folders are failed runs — ignore them; each has a `FAILED_RUN_NOTE.md`.)

### Tooling & licensing

- [TOOLING_AND_LICENSING.md](TOOLING_AND_LICENSING.md) — are our tools optimum, and
  which free licenses save time/tokens. **Headline: apply to Microsoft for Startups
  Founders Hub as Guided AI Labs → possible free Business Premium + Azure credits;
  turn on free Security Defaults MFA now; stay API-first (Graph).**

### Reference & access

- [M365_API_ACCESS_START_HERE.md](M365_API_ACCESS_START_HERE.md) — Microsoft
  Graph / Entra access model; delegated read-only first.
- [M365_ENVIRONMENT.template.env](M365_ENVIRONMENT.template.env) — tenant/app
  constants (no secrets). Copy to `M365_ENVIRONMENT.local.env` for any private
  values; that filename is git-ignored.
- [scripts/Invoke-M365Stage1InventoryRest.ps1](scripts/Invoke-M365Stage1InventoryRest.ps1)
  — **preferred** inventory script (Graph REST + device-code auth).
- [scripts/Invoke-M365Stage1Inventory.ps1](scripts/Invoke-M365Stage1Inventory.ps1)
  — older Graph PowerShell SDK attempt; kept for reference, not preferred.

### Local-machine track (Stage 4 inputs — see reconciliation below)

- [README.md](README.md) — original local folder/lane structure (2026-05-25).
- [M365_SHAREPOINT_ONENOTE_SPLIT.md](M365_SHAREPOINT_ONENOTE_SPLIT.md) — context-
  separation philosophy (identity / cloud home / working surface / local cache).
- [NEXT_SESSION_CHECKLIST.md](NEXT_SESSION_CHECKLIST.md) — local cleanup checklist
  (OneDrive/Chrome/OneNote/sync). **Stage 4 is complete; this remains historical
  input/reference, not the current step.**
- [SYSTEM_NOTES_FROM_INITIAL_DIG.md](SYSTEM_NOTES_FROM_INITIAL_DIG.md) — machine
  findings from the first pass.
- [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md)
  — desktop Office license/identity conflict notes.

### Session history

- [SESSION_TURNOVER_2026-06-12.md](SESSION_TURNOVER_2026-06-12.md) — **most recent**
  handoff: Stage 5 started, Exchange routing doc + read-only inventory runner added;
  resume by running the Stage 5 Exchange inventory.
- [SESSION_TURNOVER_2026-06-11.md](SESSION_TURNOVER_2026-06-11.md) — dated
  handoff after audit + consolidation + git/GitHub setup; now historical because
  Stages 2-4 have since completed.
- [SESSION_TURNOVER_2026-06-10.md](SESSION_TURNOVER_2026-06-10.md) — handoff from
  the 2026-06-10 session (Stage 1 inventory).

---

## The two tracks, reconciled

This workspace grew in two waves:

- **Local-machine track** (May 25–27): keep one laptop usable across Personal,
  AG Operations, Prime Boiler, City of Red Deer without blending accounts, files,
  notebooks, or browser sessions.
- **Tenant-foundation track** (June 10 →): build M365 as the governed substrate
  for AG Operations / Guided AI Labs and the future Agentic OS.

**Decision (2026-06-11): they are one project, sequenced through the roadmap.**
The local-machine track is the practical, device-side half of **Stage 4 — OneDrive
& Local Machine Dovetail**. Its documents stay as Stage 4 inputs and are not the
current step. The roadmap is canonical for ordering.

---

## Open decisions / blockers

Carry these forward; resolve at the noted stage.

1. ~~**License identity.**~~ **RESOLVED 2026-06-11.** The raw SKU
   `O365_BUSINESS_PREMIUM` (GUID `f245ecc8-75af-4f8e-b61f-27d8114de5f3`) maps to
   **Microsoft 365 Business Standard** per Microsoft's published licensing
   reference — a legacy-naming trap; the *actual* Business Premium SKU is `SPB`,
   which the tenant does NOT have. Implication: no Intune / Defender for Business /
   Entra ID P1, so **Business Premium is a genuine Stage 7 upgrade decision**, not
   a maybe. (4 of 25 seats consumed.)
2. **Stage 1 summary-script patch is unverified.** `summary.json` for the valid
   run was hand-built after the script crashed at summary generation; the patch
   was syntax-checked but not confirmed by a clean re-run.
3. ~~**Break-glass admin plan (Stage 2).**~~ **DONE 2026-06-11:** create **two**
   emergency-access accounts (`breakglass-01/02@…onmicrosoft.com`), cloud-only GA,
   credentials offline. Plan in
   [M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md) §4.
   Execution complete and verified.
4. ~~**`contact@guidedailabs.com` is a Global Administrator (Stage 2).**~~
   **DONE 2026-06-11:** stripped Global Admin + Global Reader + AI Admin; keep it a
   low-privilege mailbox; future agentic capability comes via a scoped app
   registration at Stage 9 (interaction surface ≠ capability surface).
   Mailbox type remains a Stage 5 decision.
5. **`adamgoodwin@…` keeps Global Admin (Stage 2, accepted risk).** Adam chose to
   keep his daily identity as primary admin; managed by MFA + consent discipline,
   revisit just-in-time elevation at Stage 7 if Business Premium/Entra P1–P2 lands.

### Governance review backlog (raised 2026-06-12 — Adam to review)

6. **Provisioning app resting state.** `agent-pnp-provisioning` holds delegated
   `AllSites.FullControl` + `Group.ReadWrite.All`, consented and now **idle** after
   Stage 3. Decide: disable / revoke consent until the next provisioning stage
   (recommended) vs. leave consented. A broad-write app sitting idle is exactly what
   the naming standard's "capability ≠ interaction" principle cautions against.
7. **Untested rollback.** Stage 3 reversibility ("delete the site") is asserted but
   was never validated. Low stakes on empty sites; note before relying on it.
8. **Tooling-app naming gap.** The `agent-` prefix was used for a human-triggered
   *tooling* app; consider adding a `tool-`/`setup-` prefix to the naming standard.
9. **All writes run as the daily-driver GA** (`adamgoodwin@`) — compounds the accepted
   Stage 2 risk. Revisit with JIT/PIM at Stage 7 if Entra P1/P2 lands.
10. **Stage 5 mailbox posture.** Decide whether `contact@` and `support@` remain
    licensed users, become shared mailboxes, or act as aliases only after the
    read-only Exchange inventory runs.

---

## Working across laptops (git)

This workspace is a **private** GitHub repo:
`https://github.com/Adamgdwn/ag-operations-m365-foundation` (kept private because
it contains tenant identity and admin-role data — never make it public).

On a new laptop, clone once:

```powershell
gh repo clone Adamgdwn/ag-operations-m365-foundation
```

Then, every session, to avoid the two laptops diverging:

```text
git pull    # at the START of a session, before changing anything
git push    # at the END, after committing your work
```

Secrets stay out of git automatically: `*.local.env` and token caches are listed
in `.gitignore`. Keep real secrets only in `M365_ENVIRONMENT.local.env` (ignored),
never in the committed `M365_ENVIRONMENT.template.env`.

## How to resume next session

1. Read this index.
2. Open
   [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md).
3. Run the **read-only** Stage 5 Exchange inventory:

```powershell
pwsh -File .\scripts\Invoke-M365Stage5ExchangeInventory.ps1
```

4. Summarize the generated inventory before deciding any mailbox, alias,
   forwarding, calendar, or license change.
