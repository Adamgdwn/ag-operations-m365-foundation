# Session Turnover - 2026-06-19

Canonical restart file:
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

Current workspace source of truth:
[docs/START_HERE.md](docs/START_HERE.md).

## Stop Point

The workspace usability pass is boxed up after Chunk 4.

Completed today:

- Chunk 3 - Card Template And Acceptance Standard is complete and pushed.
- The shared card-plan template was hardened for operating-card deep dives.
- CRM / Relationships was created as the first applied card-plan example.
- The remaining operating cards were captured in a card-plan placeholder index.
- Chunk 4 - Access And Onboarding Model is complete and pushed.
- `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` now defines role tiers,
  access levels, the ten-card access matrix, first-day onboarding, escalation
  rules, review cadence, and admin-only authority.
- No live SharePoint read was needed.
- No tenant write was performed.

Latest workspace execution state:

```text
Chunks 1-4 complete and pushed.
Next chunk: Chunk 5 - Card Deep Dives.
```

Next session should start from:

```text
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_TEMPLATE.md
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
docs/COCKPIT_USABILITY_INVENTORY.md
docs/COCKPIT_CARD_GAP_LIST.md
```

## What Changed

New Chunk 3 and Chunk 4 outputs:

```text
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
```

Updated routing and restart docs:

```text
00_INDEX.md
START_HERE_TOKEN_FRIENDLY.md
M365_FOUNDATION_ROADMAP.md
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_TEMPLATE.md
docs/CARD_PLAN_INDEX.md
```

The card-plan template now requires:

- operator promise;
- common scenarios;
- surfaces and superseded/admin-only surfaces;
- owner, backup owner, cadence, and evidence location;
- employee/operator, trusted partner/operator, and admin-only access boundaries;
- data model, views, record ownership, and data quality rules;
- runbook, acceptance evidence, agentic opportunities, and stop conditions.

## Current Findings

The CRM example confirms that future card plans should not just list pages and
lists. Each card needs:

- a clear operator promise;
- role-appropriate access boundaries;
- owner and review cadence;
- evidence location;
- acceptance evidence;
- stop conditions for permissions, sharing, consent, mail, deletes, public
  forms, Dynamics, Dataverse, premium Power Platform, and unattended automation.

The access/onboarding model now confirms:

- "full access" means full operating access for the assigned role and card
  scope, not tenant/global admin authority;
- employee/operator, trusted partner/operator, governance reviewer, admin,
  break-glass, function identity, and service/agent identity are separate roles;
- exact live SharePoint group and permission targets must be read back before
  any actual access grant;
- partner/client guest invites, external sharing, app consent, public Forms,
  mailbox automation, and unattended automation remain separate approval gates.

Highest priority next work:

- start Chunk 5 - Card Deep Dives;
- review one operating card at a time;
- create card-specific plans/runbooks from `docs/CARD_PLAN_TEMPLATE.md`;
- use `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md` for each card's access
  section;
- keep CRM-specific recovery under `docs/CRM_EXECUTION_PLAN.md`.

## Exact Resume Sequence

1. Open [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).
2. Open [docs/START_HERE.md](docs/START_HERE.md).
3. Open [docs/WORKSPACE_EXECUTION_PLAN.md](docs/WORKSPACE_EXECUTION_PLAN.md).
4. Review the Chunk 3 and Chunk 4 outputs:

   ```text
   docs/CARD_PLAN_TEMPLATE.md
   docs/CARD_PLAN_INDEX.md
   docs/CARD_PLAN_CRM_RELATIONSHIPS.md
   docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
   ```

5. Start Chunk 5 only if Adam says to continue the workspace usability pass.
6. For Chunk 5, choose the next card to deep dive and create or update its
   card-specific plan and runbook.
7. Do not run tenant-writing commands. Card deep dives should begin as local
   documentation unless a new approval phrase and explicit scope are added.

## Git Note

Chunks 1-4 were committed and pushed on branch
`codex/m365-agent-capability-bridge`.
