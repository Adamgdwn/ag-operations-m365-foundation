# Session Turnover - 2026-06-12

Short, current handoff. Canonical orientation is [00_INDEX.md](00_INDEX.md); this
file is the dated record of where the project stands at close of day and exactly
where to resume.

## Current project state

The canonical roadmap is still [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md).
As of close of day:

| Stage | Status |
|---|---|
| 0 - Setup Control Room | Done |
| 1 - Current-State Inventory | Done |
| 2 - Identity & Admin Foundation | Done |
| 3 - SharePoint Information Architecture | Done |
| 4 - OneDrive & Local Machine Dovetail | Done |
| 5 - Exchange & Communication Routing | Started; inventory/design phase |
| 6-9 | Planned |

**Current resume point:** Stage 5, read-only Exchange inventory.

No Stage 5 mailbox, alias, forwarding, calendar, or license changes have been made.
The next tenant-facing action is read-only.

## What changed in this closeout

1. Created [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md).
   This is the Stage 5 working document for:
   - mailbox type decisions for `contact@` and `support@`;
   - aliases / shared mailboxes / licensed-user posture;
   - calendar ownership;
   - intake routing;
   - where important email becomes durable SharePoint / future Planner/List state.

2. Added [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1).
   This is a **read-only** Exchange Online inventory runner. It signs in
   interactively, reads Exchange configuration, and writes JSON under:

   ```text
   inventory/stage-5-exchange-current-state/<timestamp>/
   ```

   It attempts to export:
   - mailboxes and mailbox types;
   - aliases/proxy addresses;
   - mailbox forwarding settings;
   - recipients;
   - distribution groups;
   - Microsoft 365 groups;
   - mailbox permissions;
   - Send As / recipient permissions;
   - calendar-processing settings;
   - a small `summary.json`.

3. Updated [00_INDEX.md](00_INDEX.md).
   It now points to Stage 5 as the current work, removes stale Stage 2/Stage 3
   resume language, and gives the exact next command.

4. Updated [NEXT_SESSION_CHECKLIST.md](NEXT_SESSION_CHECKLIST.md).
   It now correctly says the local-machine checklist is historical Stage 4 input,
   not the current step.

5. Updated [M365_ENVIRONMENT.template.env](M365_ENVIRONMENT.template.env).
   Added the Stage 5 inventory output-root default. No secrets were added.

## Validation done

- PowerShell parser check passed for
  [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1).
- Confirmed `ExchangeOnlineManagement 3.10.0` is installed locally.
- Checked active navigation docs for stale "resume at Stage 2" / "SharePoint
  untouched" language.
- Confirmed the new Stage 5 files are ASCII-only.
- Did **not** run the Exchange inventory because it requires interactive M365 sign-in.

## Exact next step

Start from the repo root:

```powershell
pwsh -File .\scripts\Invoke-M365Stage5ExchangeInventory.ps1
```

Sign in as:

```text
adamgoodwin@guidedailabs.com
```

or another account with Exchange visibility. The script is intended to read only.
If some Exchange sections are not visible under the signed-in account's RBAC, the
script should write a `*.error.json` file for that section and continue.

## After the inventory runs

1. Create a written current-state summary from the generated inventory folder.
2. Update [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
   with live findings.
3. Decide these in order:
   - 5.1: whether `contact@guidedailabs.com` remains a licensed user, becomes a
     shared mailbox, or becomes an alias only;
   - 5.2: same decision for `support@changeleadershiptools.com`;
   - 5.3: alias/group/shared-mailbox map;
   - 5.4: calendar ownership;
   - 5.5: intake routing and durable record capture.
4. Do not make Exchange writes until the current-state summary and decisions are
   written down.

## Open decisions / watch-outs

- **`contact@` and `support@` are the main Stage 5 posture decisions.** Both are
  currently interpreted as low-privilege communication identities; the question is
  whether they genuinely need licensed-user capability.
- **Interaction surface != capability surface** remains the governing rule. Public
  mailboxes receive untrusted input and must not hold broad power.
- **Provisioning app resting state remains open.** `agent-pnp-provisioning` still
  has broad delegated SharePoint/Graph consent from Stage 3. Decide at governance
  review whether to disable/revoke until needed again.
- **Business Premium / Entra P1 remains a Stage 7 decision.** Current tenant license
  is Business Standard despite the misleading raw SKU name.
- **Stage 1 summary-script patch is still unverified.** Non-blocking.

## Git / repo status at handoff

At the time these notes were written, the repo was on:

```text
main...origin/main
```

Working changes were the Stage 5 docs/script and index/checklist/env updates from
this closeout. No secret/local env file was touched. These notes are intended to
be committed and pushed with the Stage 5 start-of-work changes as the end-of-day
checkpoint.
