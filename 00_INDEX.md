# 00 — Start Here

**AG Operations / Guided AI Labs — Microsoft 365 Foundation**

Last updated: 2026-06-14

This is the single entry point for the workspace. Open this first. It tells you
what the project is, where it currently stands, which document is canonical, and
what decision is waiting next.

For fast agent/session restart, read
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md) first. It is the
compact current-state brief and safety stop for the Stage 6/7 transition.

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

Important nuance: Microsoft 365 is not being treated as "just documentation and
email," and it is not being asked to become the entire central operating system.
It should be fully useful operational infrastructure in its own right: records,
tasks, decisions, conversations, approvals, and audit. The future Guided AI Labs
central OS and Graphify map can then integrate across M365, local/Linux
workspaces, repositories, products, and other systems.

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
| 5 | Exchange & Communication Routing | ✅ Design complete 2026-06-14 — inventory complete; `contact@` / `support@` stay licensed; no Exchange writes required now; aliases/groups/calendar/intake routing documented |
| **6** | **Teams, Planner, Lists & Operating State** | **Current live gate — Lists provisioned/verified; Planner/Teams live gate and onboarding readiness packet prepared** |
| **7** | **Security, Governance & External Sharing** | **◀ Started locally — baseline, read-only inventory runner, summarizer, and local preflight prepared; no tenant changes** |
| 8 | Client Workspace Reference Pattern | ⬜ Planned |
| 9 | Agentic OS Bridge Readiness | ⬜ Planned |

**Live tenant changes so far:** Stage 2 identity safety net and role cleanup,
Stage 3 SharePoint site provisioning, and Stage 4 local OneDrive/browser cleanup.
Each tenant write was gated and read-back-verified. Stage 5 Exchange design
completed on 2026-06-14; no mailbox, alias, forwarding, calendar, or license
changes were needed. This remains a human-supervised setup, not unattended
automation.

**Authorization pattern:** when a tenant action needs Adam's credentials, MFA, or
approval, launch a visible interactive window and let Adam authorize there. Codex
can continue local analysis and documentation around that step, but hidden shells
should not sit waiting for private credentials.

---

## Document map

### Canonical plan (read these to know what to do)

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) — **canonical** staged
  execution order (Stages 0–9). This is the source of truth for *what happens next*.
- [guided-ai-labs-m365-foundation-build-brief.md](guided-ai-labs-m365-foundation-build-brief.md)
  — comprehensive reference/design spec behind the roadmap (the "why" and the
  detailed target architecture). Defers to the roadmap for sequencing.

### Completed foundation stages

- [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
  — Stage 5 Exchange mailbox, alias, calendar, support/front-door routing, and
  durable-record capture decisions. **Design complete 2026-06-14; no tenant writes
  required now.** Live read-only inventory is captured under
  `inventory/stage-5-exchange-current-state/20260614-093257/`.
- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
  — draft bridge between Stage 5, Stage 6, and Stage 9: how `contact@` /
  `support@` become structured intake, tasks, records, central OS/Graphify
  references, and eventually a governed agentic workflow.

### Current work — Stage 6 Teams, Planner, Lists & Operating State

- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
  — current working design for the Microsoft Lists, Planner buckets, Teams
  channels, first safe agent-assisted intake loop, and Stage 6 operating
  experience/look-and-feel.
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
  — alignment note after reviewing the Graphify Workspace Cockpit source package:
  M365 is the governed business substrate, Graphify is the decision intelligence
  layer, and UAOS owns future mission execution/adapters.
- [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
  — machine-readable Stage 6 schema for the first four Lists, intended views,
  Planner buckets, and Teams/channel/tab layout.
- [scripts/Invoke-M365Stage6ProvisionLists.ps1](scripts/Invoke-M365Stage6ProvisionLists.ps1)
  — **live write** (gated/idempotent): creates the four Stage 6 Microsoft Lists,
  columns, and first useful views from the schema. It does not create Teams,
  Planner, mailbox rules, sharing changes, guests, or automation.
- [scripts/Invoke-M365Stage6VerifyLists.ps1](scripts/Invoke-M365Stage6VerifyLists.ps1)
  — **read-only** Stage 6 verification for the Lists, fields, and views.
- [scripts/Start-M365Stage6ListsProvisioningInteractive.ps1](scripts/Start-M365Stage6ListsProvisioningInteractive.ps1)
  — launches the Stage 6 Lists provisioning or verification in a visible
  PowerShell/auth window so Adam can complete Microsoft sign-in/MFA and, for the
  live write, type the confirmation.
- [scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1](scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1)
  — **live write already run 2026-06-14**: added `adamgoodwin@guidedailabs.com`
  as secondary site collection admin on the Guided AI Labs and Change Leadership
  Tools sites.
- [scripts/Test-M365Stage6PnPPermissions.ps1](scripts/Test-M365Stage6PnPPermissions.ps1)
  — **read-only** diagnostic for Stage 6 PnP/site permissions.
- [scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1](scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1)
  — prints the safer Entra admin center consent-review checklist for
  `agent-pnp-provisioning`. It does not open a browser or raw consent URL.
- [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md)
  — concise audit of the Stage 6 provisioning attempts, confirmed changes,
  unauthorized-operation blocker, and consent-warning response.
- [inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md](inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md)
  — Stage 6 readiness ladder, partner onboarding checklist, client-readiness
  checklist, training path, and scorecard for judging whether the operating
  cockpit is ready to use with a partner or first client.
- [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1)
  — **read-only** Exchange Online inventory: mailboxes, aliases, forwarding,
  delegates, Send As, groups, recipients, and calendar-processing posture. Run this
  before deciding any Stage 5 writes. Defaults to device-code authentication;
  add `-UseWam` only in a host where Exchange WAM auth works correctly.
- [scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1](scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1)
  — launches the read-only Stage 5 inventory in a visible PowerShell/auth window
  so Adam can complete Microsoft sign-in or MFA, then runs the local summarizer.
- [scripts/Summarize-M365Stage5ExchangeInventory.ps1](scripts/Summarize-M365Stage5ExchangeInventory.ps1)
  — local post-processor that turns a completed Stage 5 inventory JSON folder into
  a Markdown current-state summary for decisions.

### Current work — Stage 7 Security, Governance & External Sharing

- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
  — Stage 7 working design for MFA/sign-in posture, admin-role review, app
  consent, guest access, external sharing, labels/retention, device sync, audit
  cadence, and agentic approval gates.
- [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json)
  — machine-readable Stage 7 baseline, read-only inventory scopes, and exit
  criteria.
- [scripts/Invoke-M365Stage7SecurityInventory.ps1](scripts/Invoke-M365Stage7SecurityInventory.ps1)
  — **read-only** Graph inventory for security/governance posture. It records
  partial-permission gaps as `*.error.json` instead of changing the tenant.
- [scripts/Start-M365Stage7SecurityInventoryInteractive.ps1](scripts/Start-M365Stage7SecurityInventoryInteractive.ps1)
  — launches the Stage 7 read-only inventory in a visible PowerShell/auth window.
- [scripts/Summarize-M365Stage7SecurityInventory.ps1](scripts/Summarize-M365Stage7SecurityInventory.ps1)
  — local post-processor for a completed Stage 7 inventory folder.
- [scripts/Test-M365Stage7LocalPreflight.ps1](scripts/Test-M365Stage7LocalPreflight.ps1)
  — local-only Stage 7 validation. Latest run passed and does not connect to
  Microsoft 365.
- [inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md](inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md)
  — latest Stage 7 local preflight report. The optional SharePoint Online
  Management Shell module is not installed, so `-IncludeSharePointAdmin` is a
  later optional enhancement.

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

- [SESSION_TURNOVER_2026-06-14.md](SESSION_TURNOVER_2026-06-14.md) — **most recent**
  handoff: Stage 5 inventory auth path improved, visible launcher + summarizer
  added, read-only Exchange inventory completed.
- [SESSION_TURNOVER_2026-06-12.md](SESSION_TURNOVER_2026-06-12.md) — Stage 5
  started, Exchange routing doc + read-only inventory runner added.
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
10. ~~**Stage 5 mailbox posture.**~~ **RESOLVED 2026-06-14:** read-only Exchange
    inventory is complete; `contact@` and `support@` remain licensed user
    mailboxes for now to preserve direct sign-in, calendar, and future scoped
    automation options.
11. **Guided AI Labs agentic intake model.** Draft model exists; next step is Stage
    6 operating-state design for intake/support Lists, Planner tasks, Teams
    channels, and an Agent Action Log.

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
2. Open [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md).
3. Open [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
   as the design context for why these operating surfaces exist.
4. Review [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
   as the exact List/Planner/Teams schema behind the Stage 6 design.
5. Lists are already provisioned and verified. Use read-back with:
   `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify`.
6. Current live gate: Planner/Teams. Use:
   `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify`.
   The visible window requires Microsoft device-code sign-in and typed
   `planner-teams` confirmation.
7. Use the onboarding readiness packet before adding a partner or shaping first
   client onboarding:
   `inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`.
8. Stage 7 local preflight is ready:
   `.\scripts\Test-M365Stage7LocalPreflight.ps1`.
9. Stage 7 read-only live inventory is ready when Adam can sign in:
   `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1`.
10. Use [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
   and the generated inventory summary only as Stage 5 reference.
11. Then run the first supervised agent loop from
   `inventory\stage-6-operating-state\first-run-packet\`.
