# Session Turnover - 2026-06-14

Short handoff after resuming Stage 5. Canonical orientation is [00_INDEX.md](00_INDEX.md);
this file records what changed today and exactly where to resume.

## Restart handover - stop point

Adam is shutting down/restarting after unusual screen/browser behavior during
Stage 6 provisioning/consent attempts.

Fast restart brief:

- [START_HERE.md](START_HERE.md)

Do **not** resume by opening raw Microsoft admin-consent links. Do **not** approve
any page that shows phishing, risky app, unknown publisher, suspicious consent,
or unexpected permission warnings.

No Stage 6 helper process was left running at handover. The clean restart point is:

1. Read [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md).
2. Read Stage 6 section 10.1 in
   [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md).
3. Treat Stage 6 automated Lists provisioning as paused.
4. Before any retry, review `agent-pnp-provisioning` only from
   `https://entra.microsoft.com` or another trusted Microsoft portal.
5. If the app/consent posture is not completely clean, rebuild the provisioning
   app deliberately or create the Lists manually from the schema.

Confirmed tenant change from the Stage 6 attempt:

- `adamgoodwin@guidedailabs.com` was added as secondary site collection admin on:
  - `https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools`
  - `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`

Confirmed not done:

- The four Stage 6 Lists are not created yet.
- Planner and Teams Stage 6 writes have not been run.
- No raw-consent approval should be assumed.

## Current project state

Stages 0-5 are complete at the design level. Stage 5 - Exchange & Communication
Routing completed without needing Exchange tenant writes. Stage 6 - Teams,
Planner, Lists & Operating State is now the current work. Stage 6 has moved from
initial design into a local, gated implementation path for Microsoft Lists; no
Stage 6 tenant writes have been run yet.

No Stage 5 mailbox, alias, forwarding, calendar, or license changes were made.
Live Exchange inventory data was captured under:

```text
inventory/stage-5-exchange-current-state/20260614-093257/
```

## What changed

1. Updated [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1).
   The runner now defaults to Exchange Online device-code authentication:

   ```powershell
   Connect-ExchangeOnline -Device -DisableWAM
   ```

   This avoids the host window-handle error encountered by WAM auth in the Codex
   command channel. The old WAM path remains available with `-UseWam`.

2. Added [scripts/Summarize-M365Stage5ExchangeInventory.ps1](scripts/Summarize-M365Stage5ExchangeInventory.ps1).
   This is a local-only post-processor. After a successful inventory run, it reads
   the JSON files and writes a Markdown current-state summary into the inventory
   run folder.

3. Added [scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1](scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1).
   This launches a visible PowerShell/auth window for Adam-controlled Microsoft
   sign-in/MFA, then runs the summarizer after successful inventory. This is now
   the preferred flow when Codex needs authorization.

4. Updated [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
   and [00_INDEX.md](00_INDEX.md) so the Stage 5 resume path includes the new
   auth posture, visible authorization launcher, and summarizer.

5. Recorded the big-picture authorization pattern: this workspace is being shaped
   for a future Guided AI Labs agentic infrastructure, but credentials, MFA,
   consent, and tenant-impacting approvals remain visible human checkpoints.

6. Completed the read-only Stage 5 Exchange inventory through the visible
   authorization flow and generated:

   ```text
   inventory/stage-5-exchange-current-state/20260614-093257/stage-5-exchange-current-state-summary.md
   ```

7. Patched the inventory/summarizer scripts after the first successful run:
   - future empty result sets now export as `[]` instead of zero-byte JSON;
   - future calendar-processing rows include mailbox identity fields;
   - the summarizer tolerates existing empty files and can use the mailbox fields
     when present.

8. Recorded Adam's approval to keep `contact@guidedailabs.com` and
   `support@changeleadershiptools.com` as licensed user mailboxes for now.

9. Added [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md).
   This draft defines intake lanes, classification, first safe agent workflows,
   Stage 6 List/Planner/Teams targets, and the permission posture for future
   direct agent work.

10. Added [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md).
    This starts Stage 6 design for the intake/support registers, Agent Action Log,
    Decision Register, Planner buckets, Teams channels, and the first manual
    agent-assisted intake loop.

11. Closed remaining Stage 5 routing decisions:
    - no new aliases, distribution groups, shared mailboxes, or public group
      addresses are needed right now;
    - existing M365 group addresses stay internal/collaboration-oriented;
    - `adamgoodwin@guidedailabs.com` remains the real scheduling calendar;
    - `contact@` is an intake/scheduling signal mailbox, not an autonomous booking
      calendar yet;
    - durable state moves from email into SharePoint and Stage 6 Lists/Planner/Teams.

12. Expanded [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
    to include operating experience/look-and-feel, Teams tab expectations,
    default List views, Planner task naming, SharePoint durable-home rules, and
    the constrained agentic business-partner model.

    Follow-up clarification: Stage 6 is not "just documentation and email." It
    should become fully useful M365 operating infrastructure while remaining one
    governed substrate in the broader Guided AI Labs central OS. The future
    Graphify map can act as a cross-system relationship/navigation layer across
    M365, Linux/local workspaces, repositories, products, and other tools.

13. Added [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json).
    This is the machine-readable Stage 6 schema for:
    - Guided AI Labs intake register;
    - Change Leadership Tools support register;
    - Agent Action Log;
    - Decision Register;
    - Planner buckets;
    - Teams/channel/tab layout.
    The schema now includes optional `CentralOSLink` and `GraphNodeId` fields so
    Stage 6 records can later be connected to the central OS / Graphify map
    without weakening their usefulness inside Microsoft 365.

14. Added Stage 6 Lists scripts:
    - [scripts/Invoke-M365Stage6ProvisionLists.ps1](scripts/Invoke-M365Stage6ProvisionLists.ps1)
      - live write, idempotent, typed `yes` gate, creates Lists/columns/views only;
    - [scripts/Invoke-M365Stage6VerifyLists.ps1](scripts/Invoke-M365Stage6VerifyLists.ps1)
      - read-only verification;
    - [scripts/Start-M365Stage6ListsProvisioningInteractive.ps1](scripts/Start-M365Stage6ListsProvisioningInteractive.ps1)
      - visible PowerShell/auth launcher for provisioning or `-VerifyOnly`.
    These scripts were later patched to prefer PowerShell 7, use PnP persistent
    login where possible, and write transcripts under
    `inventory/stage-6-operating-state/`.

15. Stage 6 execution attempt status:
    - initial verification failed because Windows PowerShell could not see
      `PnP.PowerShell`; launcher now prefers `pwsh.exe`;
    - read-back verified the four Lists are still missing;
    - added and ran [scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1](scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1);
      Adam is now secondary site collection admin on Guided AI Labs and Change
      Leadership Tools;
    - provisioning still fails at `New-PnPList` with `Attempted to perform an
      unauthorized operation`;
    - read-only PnP diagnostic can connect but fails on site reads with the same
      unauthorized operation;
    - a raw admin-consent URL for `agent-pnp-provisioning` produced errors
      including a phishing warning. Do not click through that path.

16. Removed the raw-consent launcher and replaced it with
    [scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1](scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1).
    The replacement does not open a browser and does not initiate consent; it
    only prints the safer Entra admin center review checklist.

17. Added [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md)
    as the concise audit record for what happened, what changed, what failed,
    and the safe next options.

## Validation done

- Parser check passed for the updated inventory runner.
- Parser check passed for the visible authorization launcher.
- Parser check passed for the new summarizer.
- Parser check passed for the Stage 6 Lists provisioning script.
- Parser check passed for the Stage 6 Lists verification script.
- Parser check passed for the Stage 6 visible launcher.
- Parser check passed for the Stage 6 site-admin prerequisite script.
- Parser check passed for the Stage 6 PnP permission diagnostic.
- Parser check passed for the Stage 6 PnP consent-review helper.
- Stage 6 JSON schema loads successfully: 4 Lists, 1 planned Planner, 1 planned
  Team shell.
- Runtime smoke test passed for the summarizer against an empty inventory folder,
  with output written to `%TEMP%`.
- Read-only Exchange inventory completed successfully after Adam authorized in
  the visible PowerShell/auth window.

## Auth attempt result

The original inventory run failed with:

```text
A window handle must be configured.
```

After the device-code patch, a visible PowerShell window was launched so Adam
could complete interactive sign-in. That visible flow completed successfully.

## Inventory result

Headline findings from the generated summary:

- 5 mailboxes total: 4 normal user mailboxes plus the hidden Discovery Search
  Mailbox.
- 0 shared mailboxes.
- 0 distribution groups.
- 5 Microsoft 365 groups; all require authenticated senders.
- No mailbox-level forwarding found on the four decision mailboxes.
- No explicit Full Access mailbox delegates found.
- No explicit Send As grants found.
- No Send on Behalf grants found.
- Main decision mailboxes are all currently `UserMailbox`:
  `admin@agoperations.ca`, `adamgoodwin@guidedailabs.com`,
  `contact@guidedailabs.com`, and `support@changeleadershiptools.com`.
- `contact@` and `support@` are approved to remain licensed user mailboxes for
  now.

## Exact next step

Open the Stage 6 working doc, agentic intake model, and schema:

```text
M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md
GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md
config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json
```

Current Stage 6 blocker: the Lists are designed but not provisioned. Do not use
raw admin-consent URLs because a browser/security phishing warning appeared.
Before retrying automated provisioning, inspect `agent-pnp-provisioning` from
Entra admin center or another trusted Microsoft portal and confirm its identity,
publisher/tenant details, and delegated SharePoint permissions.

If the PnP app consent is confirmed safe and refreshed, retry the visible
provisioning window:

```powershell
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1
```

That creates Lists only and requires Adam's Microsoft sign-in plus typed `yes`.
After it completes, run read-back:

```powershell
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly
```

## After the Lists are verified

1. Record the Stage 6 Lists execution and verification results in the Stage 6
   working doc.
2. Decide the second Stage 6 layer: Planner plan/buckets and Teams channels/tabs.
3. Do not create Planner/Teams tenant writes until the Lists are verified.
