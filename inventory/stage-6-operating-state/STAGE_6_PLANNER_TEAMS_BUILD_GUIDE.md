# Stage 6 Planner And Teams Build Guide

Generated from `.\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json` on 2026-06-14.

Use this after the four Stage 6 Lists exist and read-back verification is clean. Planner and Teams are useful only when the underlying operating state is already in place.

Safety:

- Do not create guests, external sharing links, mailbox rules, tenant policies, or automation from this guide.
- Keep this first Team internal to Adam/Guided AI Labs operating work.
- Create Planner tasks only for real next actions; do not mirror every email or List item.
- Any external send, calendar commitment, permission change, or irreversible operation still requires Adam approval.

Recommended sequence:

1. Confirm Stage 6 Lists exist and pass read-only verification.
2. Create or confirm the Planner plan and buckets.
3. Create or confirm the operating Team and channels.
4. Add tabs only after each target List/library/plan is available.
5. Record any deviations in the Decision Register.

## Planner

- Plan name: Guided AI Labs - Operating Plan
- Scope: Guided AI Labs internal operating work
- Rule: action-bearing work only

| Done | Bucket | Intended use |
|---|---|---|
| [ ] | Intake Triage | New inquiries and triage actions from the Intake Register |
| [ ] | Client Discovery | Discovery, readiness, and early client shaping work |
| [ ] | Active Delivery | Current client delivery tasks with a clear next action |
| [ ] | Content / IP | Reusable methods, templates, and productized knowledge work |
| [ ] | Agent Setup | Agentic intake, bridge, workflow, and tooling setup |
| [ ] | Waiting / Follow-up | External waits, Adam review waits, and follow-up reminders |
| [ ] | Admin / Governance | Tenant setup, decisions, permissions review, and governance tasks |

Planner task naming convention:

```text
[Lane] concise action - organization/person
```

Starter tasks to create only if they are still true:

| Done | Bucket | Task title | Notes |
|---|---|---|---|
| [ ] | Agent Setup | [Agent] Verify Stage 6 Lists read-back - Adam | Link to the verifier transcript after it passes |
| [ ] | Intake Triage | [Intake] Run first human-approved contact@ triage - Adam | Use selected messages only; no autonomous sends |
| [ ] | Admin / Governance | [Governance] Review agent-pnp-provisioning app posture - Adam | Use Entra admin center only; stop on any warning |

## Teams

- Team name: Guided AI Labs - Operating Team
- Membership: internal only for the first version
- Durable records remain in SharePoint; Teams is for discussion and coordination

| Done | Channel | Tabs to pin first | Purpose |
|---|---|---|---|
| [ ] | General | Operating Plan, Decisions | Low-volume operating announcements and top-level coordination |
| [ ] | Intake | Intake Register, Operating Plan, Agent Log | Daily front-door triage and discussion around new inquiries |
| [ ] | Client Discovery | Intake Register, Operating Plan | Readiness and discovery work before active delivery |
| [ ] | Active Delivery | Operating Plan, Client_Delivery | Current delivery coordination without making Teams the file cabinet |
| [ ] | Agent Setup | Agent Log, Decisions, Automation_Workflows | Agentic intake, bridge, workflow, and tooling decisions |
| [ ] | Methods and IP | Templates_Methods, Decisions | Reusable methods, templates, and productized knowledge |

Tab creation notes:

- `Intake Register`, `Agent Log`, and `Decisions` should point to the verified Microsoft Lists.
- `Operating Plan` should point to the Planner plan above.
- `Client_Delivery`, `Automation_Workflows`, and `Templates_Methods` should point to existing SharePoint libraries only if those libraries already exist and are clean.
- Skip a tab rather than creating a confusing placeholder.

## Verification Handoff

After manual setup, capture screenshots or notes for any difference between the schema and the live Teams/Planner layout. If automation is later added, use this guide as the expected baseline.

