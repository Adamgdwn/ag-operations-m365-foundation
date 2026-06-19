# Session Turnover - 2026-06-19

Canonical restart file:
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

Current workspace source of truth:
[docs/START_HERE.md](docs/START_HERE.md).

## Stop Point

The workspace usability pass is boxed up after Chunk 3.

Completed today:

- Chunk 3 - Card Template And Acceptance Standard is complete locally.
- The shared card-plan template was hardened for operating-card deep dives.
- CRM / Relationships was created as the first applied card-plan example.
- The remaining operating cards were captured in a card-plan placeholder index.
- No live SharePoint read was needed.
- No tenant write was performed.

Latest workspace execution state:

```text
Chunk 3 complete locally.
Next chunk: Chunk 4 - Access And Onboarding Model.
```

Next session should start from:

```text
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_TEMPLATE.md
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
docs/COCKPIT_USABILITY_INVENTORY.md
docs/COCKPIT_CARD_GAP_LIST.md
```

## What Changed

New Chunk 3 outputs:

```text
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
```

Updated routing and restart docs:

```text
00_INDEX.md
START_HERE_TOKEN_FRIENDLY.md
M365_FOUNDATION_ROADMAP.md
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/CARD_PLAN_TEMPLATE.md
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

Highest priority next work:

- define employee, operator, trusted partner/operator, and admin authority;
- map roles to each operating card;
- separate full operating access from tenant/global admin authority;
- add first-day onboarding instructions and escalation rules.

## Exact Resume Sequence

1. Open [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).
2. Open [docs/START_HERE.md](docs/START_HERE.md).
3. Open [docs/WORKSPACE_EXECUTION_PLAN.md](docs/WORKSPACE_EXECUTION_PLAN.md).
4. Review the Chunk 3 outputs:

   ```text
   docs/CARD_PLAN_TEMPLATE.md
   docs/CARD_PLAN_INDEX.md
   docs/CARD_PLAN_CRM_RELATIONSHIPS.md
   ```

5. Start Chunk 4 only if Adam says to continue the workspace usability pass.
6. For Chunk 4, build the access/onboarding model across employee, operator,
   trusted partner/operator, and admin authority.
7. Do not run tenant-writing commands. Chunk 4 should begin as local
   documentation unless a new approval phrase and explicit scope are added.

## Git Note

Chunk 3 should be committed and pushed on branch
`codex/m365-agent-capability-bridge` before starting Chunk 4.
