# Microsoft Forms Intake And Feedback Build Guide

Generated from .\config\M365_FORMS_INTAKE_FEEDBACK_KIT.json on 2026-06-14.

Purpose: make Microsoft Forms a first-class intake and feedback front door while keeping Microsoft Lists as the operating state.

This guide is local-only. It does not create forms, flows, external links, guests, or tenant policy changes.

## Governance

Initial sharing: Internal-only until Stage 7 external Forms collection is explicitly approved.

External sharing decision: Allow unauthenticated external response links only for named public/client-facing forms after Stage 7 review.

Phishing protection: Keep Microsoft Forms phishing protection enabled.

Response storage: Use Power Automate to copy responses into Microsoft Lists. Do not rely on manually opened Excel workbooks as the operating record.

Approval gate: Any form that collects client data, partner data, testimonials, sensitive business information, or public responses requires Adam approval before link distribution.

Useful Microsoft references:

- https://learn.microsoft.com/en-us/microsoft-forms/administrator-settings-microsoft-forms
- https://learn.microsoft.com/en-us/power-automate/forms/overview
- https://learn.microsoft.com/en-us/connectors/microsoftforms/

## Recommended Build Order

1. Confirm Stage 7 governance posture for external Forms collection.
2. Create the internal/test version of each form in Microsoft Forms.
3. Create the Power Automate flow for one form at a time.
4. Submit one test response and verify the target List item.
5. Add Planner task and Teams notification steps only after the List write works.
6. Publish external/client links only after Adam approves the form, flow, and sharing setting.
7. Record the production link and approval decision in the Decision Register.

## Forms

### Guided AI Labs - Discovery Intake

Form id: `gal-discovery-intake`

| Field | Value |
|---|---|
| Audience | Prospective clients, partners, and business owners |
| Owner | adamgoodwin@guidedailabs.com |
| Stage | Stage 6 now; external link gated by Stage 7 |
| Target List | Guided AI Labs - Intake Register |
| Target site | /sites/GuidedAILabs |
| Sharing | External response link after Stage 7 approval; otherwise internal test only |
| Response setting | Collect name/email when authenticated; ask for name/email explicitly when public |
| Planner rule | Create a Planner task only when urgency is high, requested timeline is within 30 days, or Adam marks follow-up required. |
| Teams notification | Post a short notice to the Intake channel when a response is copied into the Intake Register. |

Questions:

| Done | Question | Type | Required | Choices | Maps to |
|---|---|---|---|---|---|
| [ ] | Your name | text | True |  | RequesterName |
| [ ] | Email address | text | True |  | RequesterEmail |
| [ ] | Organization | text | False |  | Organization |
| [ ] | What are you trying to improve or build? | longText | True |  | AgentNotes |
| [ ] | Which kind of signal is this? | choice | True | new-inquiry; client-readiness; scheduling; decision-or-commitment; knowledge-candidate | IntakeClass |
| [ ] | Priority | choice | True | Low; Normal; High; Urgent | Priority |
| [ ] | What would make this successful? | longText | False |  | NextAction |
| [ ] | May we contact you about this request? | choice | True | Yes; No | HumanApprovalRequired |

List defaults:

| Column | Default |
|---|---|
| SourceMailbox | other |
| IntakeClass | client-readiness |
| Priority | Normal |
| Status | New |
| Owner | adamgoodwin@guidedailabs.com |
| HumanApprovalRequired | Yes |

Power Automate checklist:

| Done | Step | Action | Notes |
|---|---:|---|---|
| [ ] | 1 | Microsoft Forms - When a new response is submitted | Select this form as the trigger. |
| [ ] | 2 | Microsoft Forms - Get response details | Use the response id from the trigger. |
| [ ] | 3 | SharePoint - Create item in target Microsoft List | Map questions and defaults into the target List. |
| [ ] | 4 | Condition - if severity/urgency/follow-up requires action | Create a Planner task only when urgency is high, requested timeline is within 30 days, or Adam marks follow-up required. |
| [ ] | 5 | Planner - Create task only when the condition is true | Create a Planner task only when urgency is high, requested timeline is within 30 days, or Adam marks follow-up required. Only create a task when the condition is true. |
| [ ] | 6 | Microsoft Teams - Post message only for meaningful notifications | Post a short notice to the Intake channel when a response is copied into the Intake Register. |
| [ ] | 7 | SharePoint - Update created List item with PlannerTaskUrl when a task was created | Store PlannerTaskUrl after task creation when available. |

### Change Leadership Tools - Support Request

Form id: `clt-support-request`

| Field | Value |
|---|---|
| Audience | Change Leadership Tools users and buyers |
| Owner | adamgoodwin@guidedailabs.com |
| Stage | Stage 6 now; external link gated by Stage 7 |
| Target List | Change Leadership Tools - Support Register |
| Target site | /sites/ChangeLeadershipTools |
| Sharing | External response link after Stage 7 approval; otherwise internal test only |
| Response setting | Ask for name/email explicitly so support can respond even when the form is public. |
| Planner rule | Create a Planner task for Blocking/High severity or unresolved access/payment issues. |
| Teams notification | Post a short notice to the Intake channel or future Support channel when severity is High or Blocking. |

Questions:

| Done | Question | Type | Required | Choices | Maps to |
|---|---|---|---|---|---|
| [ ] | Your name | text | True |  | RequesterName |
| [ ] | Email address | text | True |  | RequesterEmail |
| [ ] | Organization | text | False |  | Organization |
| [ ] | Product area | choice | True | Site; Download; Account; Document/tool; Payment; Other | ProductArea |
| [ ] | Issue type | choice | True | Question; Bug; Access issue; Feedback; Refund/billing; Other | IssueType |
| [ ] | Severity | choice | True | Low; Normal; High; Blocking | Severity |
| [ ] | What happened? | longText | True |  | AgentNotes |
| [ ] | What outcome are you looking for? | longText | False |  | NextAction |

List defaults:

| Column | Default |
|---|---|
| SourceMailbox | other |
| Priority | Normal |
| Status | New |
| Owner | adamgoodwin@guidedailabs.com |
| KnowledgeCandidate | No |
| HumanApprovalRequired | Yes |

Power Automate checklist:

| Done | Step | Action | Notes |
|---|---:|---|---|
| [ ] | 1 | Microsoft Forms - When a new response is submitted | Select this form as the trigger. |
| [ ] | 2 | Microsoft Forms - Get response details | Use the response id from the trigger. |
| [ ] | 3 | SharePoint - Create item in target Microsoft List | Map questions and defaults into the target List. |
| [ ] | 4 | Condition - if severity/urgency/follow-up requires action | Create a Planner task for Blocking/High severity or unresolved access/payment issues. |
| [ ] | 5 | Planner - Create task only when the condition is true | Create a Planner task for Blocking/High severity or unresolved access/payment issues. Only create a task when the condition is true. |
| [ ] | 6 | Microsoft Teams - Post message only for meaningful notifications | Post a short notice to the Intake channel or future Support channel when severity is High or Blocking. |
| [ ] | 7 | SharePoint - Update created List item with PlannerTaskUrl when a task was created | Store PlannerTaskUrl after task creation when available. |

### Guided AI Labs - Session Feedback

Form id: `gal-session-feedback`

| Field | Value |
|---|---|
| Audience | Workshop, discovery, and delivery participants |
| Owner | adamgoodwin@guidedailabs.com |
| Stage | Stage 6 now; client use gated by Stage 7 |
| Target List | Guided AI Labs - Intake Register |
| Target site | /sites/GuidedAILabs |
| Sharing | Specific client/team link after approval; avoid broad public links for delivery feedback. |
| Response setting | Use authenticated links for internal/team feedback and named links for client delivery where practical. |
| Planner rule | Create a Planner task only for low scores, explicit follow-up requests, or reusable-method candidates. |
| Teams notification | Post a short notice to Methods & IP or Intake only when follow-up is required. |

Questions:

| Done | Question | Type | Required | Choices | Maps to |
|---|---|---|---|---|---|
| [ ] | Your name | text | False |  | RequesterName |
| [ ] | Email address | text | False |  | RequesterEmail |
| [ ] | Organization | text | False |  | Organization |
| [ ] | Session or workshop name | text | True |  | Title |
| [ ] | How useful was this session? | rating | True |  | AgentConfidence |
| [ ] | What was most useful? | longText | False |  | AgentNotes |
| [ ] | What should we improve? | longText | False |  | NextAction |
| [ ] | Would you like follow-up? | choice | True | Yes; No | HumanApprovalRequired |

List defaults:

| Column | Default |
|---|---|
| SourceMailbox | other |
| IntakeClass | knowledge-candidate |
| Priority | Normal |
| Status | New |
| Owner | adamgoodwin@guidedailabs.com |
| HumanApprovalRequired | No |

Power Automate checklist:

| Done | Step | Action | Notes |
|---|---:|---|---|
| [ ] | 1 | Microsoft Forms - When a new response is submitted | Select this form as the trigger. |
| [ ] | 2 | Microsoft Forms - Get response details | Use the response id from the trigger. |
| [ ] | 3 | SharePoint - Create item in target Microsoft List | Map questions and defaults into the target List. |
| [ ] | 4 | Condition - if severity/urgency/follow-up requires action | Create a Planner task only for low scores, explicit follow-up requests, or reusable-method candidates. |
| [ ] | 5 | Planner - Create task only when the condition is true | Create a Planner task only for low scores, explicit follow-up requests, or reusable-method candidates. Only create a task when the condition is true. |
| [ ] | 6 | Microsoft Teams - Post message only for meaningful notifications | Post a short notice to Methods & IP or Intake only when follow-up is required. |
| [ ] | 7 | SharePoint - Update created List item with PlannerTaskUrl when a task was created | Store PlannerTaskUrl after task creation when available. |

### Guided AI Labs - Team Retrospective

Form id: `gal-team-retro`

| Field | Value |
|---|---|
| Audience | Internal team and future business partners |
| Owner | adamgoodwin@guidedailabs.com |
| Stage | Stage 6 internal now; partner use after Stage 7 guest/sharing decision |
| Target List | Decision Register |
| Target site | /sites/GuidedAILabs |
| Sharing | Internal only until partner onboarding governance is approved. |
| Response setting | Authenticated internal responses preferred. |
| Planner rule | Create Planner tasks only for committed improvements with an owner. |
| Teams notification | Post decision candidates to the Agent Setup or Methods & IP channel for Adam review. |

Questions:

| Done | Question | Type | Required | Choices | Maps to |
|---|---|---|---|---|---|
| [ ] | What worked well? | longText | True |  | Rationale |
| [ ] | What should change? | longText | True |  | Decision |
| [ ] | Is this a decision, task, or idea? | choice | True | decision candidate; task; idea; risk | Rationale |
| [ ] | Who should own the next step? | text | False |  | Rationale |
| [ ] | When should we revisit this? | date | False |  | RevisitDate |

List defaults:

| Column | Default |
|---|---|
| DecisionOwner | adamgoodwin@guidedailabs.com |
| Area | Operations |

Power Automate checklist:

| Done | Step | Action | Notes |
|---|---:|---|---|
| [ ] | 1 | Microsoft Forms - When a new response is submitted | Select this form as the trigger. |
| [ ] | 2 | Microsoft Forms - Get response details | Use the response id from the trigger. |
| [ ] | 3 | SharePoint - Create item in target Microsoft List | Map questions and defaults into the target List. |
| [ ] | 4 | Condition - if severity/urgency/follow-up requires action | Create Planner tasks only for committed improvements with an owner. |
| [ ] | 5 | Planner - Create task only when the condition is true | Create Planner tasks only for committed improvements with an owner. Only create a task when the condition is true. |
| [ ] | 6 | Microsoft Teams - Post message only for meaningful notifications | Post decision candidates to the Agent Setup or Methods & IP channel for Adam review. |
| [ ] | 7 | SharePoint - Update created List item with PlannerTaskUrl when a task was created | Store PlannerTaskUrl after task creation when available. |

## Generated Companion Files

| File | Purpose |
|---|---|
| orms-question-map.csv | Flat question-to-List mapping for build/review |
| orms-flow-build-checklist.csv | Flat Power Automate action checklist by form |

## Safety Notes

- Microsoft Forms links can become public collection surfaces. Treat public links as external sharing.
- Do not collect sensitive client material until Stage 7 sharing/security decisions are complete.
- Keep phishing protection enabled.
- Store operational response data in Lists, not only in the Forms response workbook.
- Prefer one form, one flow, one verified List write before expanding the pattern.
