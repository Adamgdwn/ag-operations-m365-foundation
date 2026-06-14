# Stage 6 Manual Microsoft Lists Build Guide

Generated from `.\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json` on 2026-06-14.

Use this guide only when the automated PnP provisioning path is blocked or intentionally deferred. The read-only verifier should still be run afterward so the tenant state is checked against the canonical schema.

Safety:

- Do not approve raw Microsoft admin-consent URLs.
- Do not approve any page showing phishing, risky-app, unknown-publisher, suspicious-consent, or unexpected permission warnings.
- Manual list creation through the target SharePoint sites is the safer fallback while the `agent-pnp-provisioning` app is under review.

After the Lists are created, run:

```powershell
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly
```

## Manual Creation Summary

| Done | Site | List | Site contents |
|---|---|---|---|
| [ ] | Guided AI Labs | Guided AI Labs - Intake Register | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx |
| [ ] | Change Leadership Tools | Change Leadership Tools - Support Register | https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools/_layouts/15/viewlsts.aspx |
| [ ] | Guided AI Labs | Agent Action Log | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx |
| [ ] | Guided AI Labs | Decision Register | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx |

Creation pattern for each List:

1. Open the site contents link.
2. Choose New > List > Blank list.
3. Use the exact List name below.
4. Create each column with the displayed name and field type below.
5. Apply choices/defaults where shown.
6. Create the listed views and set the default view when marked.
7. Run the read-only verifier.

## Guided AI Labs - Intake Register

- Site: Guided AI Labs
- Site URL: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs
- Site contents: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx
- Description: One row per meaningful Guided AI Labs inquiry, discovery signal, partnership lead, or agent-surfaced opportunity.
- Show in site navigation: True

### Columns

| Done | Display name | SharePoint UI type | Required | Notes |
|---|---|---|---|---|
| [ ] | SourceMailbox | Choice | Yes | Choices: contact@, adam@, support@, admin@, other<br>Default: contact@ |
| [ ] | SourceMessageId | Single line of text | No |  |
| [ ] | ReceivedDate | Date and time | Yes |  |
| [ ] | RequesterName | Single line of text | No |  |
| [ ] | RequesterEmail | Single line of text | No |  |
| [ ] | Organization | Single line of text | No |  |
| [ ] | IntakeClass | Choice | Yes | Choices: new-inquiry, client-readiness, scheduling, decision-or-commitment, knowledge-candidate, noise-or-spam<br>Default: new-inquiry |
| [ ] | Priority | Choice | Yes | Choices: Low, Normal, High, Urgent<br>Default: Normal |
| [ ] | Status | Choice | Yes | Choices: New, Triage, Waiting on Adam, Waiting on External, In Progress, Done, Archived<br>Default: New<br>Internal name: IntakeStatus |
| [ ] | Owner | Person | Yes | Internal name: ItemOwner |
| [ ] | NextAction | Multiple lines of text | No |  |
| [ ] | DurableHome | Hyperlink | No |  |
| [ ] | PlannerTaskUrl | Hyperlink | No |  |
| [ ] | CentralOSLink | Hyperlink | No |  |
| [ ] | GraphNodeId | Single line of text | No |  |
| [ ] | HumanApprovalRequired | Yes/No | Yes | Default: 1 |
| [ ] | AgentConfidence | Number | No |  |
| [ ] | AgentNotes | Multiple lines of text | No |  |

### Views

| Done | View | Default | Columns |
|---|---|---|---|
| [ ] | Attention Now | Yes | LinkTitle, Priority, IntakeStatus, IntakeClass, RequesterName, Organization, ReceivedDate, ItemOwner, NextAction, HumanApprovalRequired |
| [ ] | Waiting External | No | LinkTitle, IntakeStatus, RequesterName, Organization, ReceivedDate, NextAction |
| [ ] | Agent Suggested | No | LinkTitle, HumanApprovalRequired, AgentConfidence, AgentNotes, ReceivedDate, ItemOwner |
| [ ] | Done / Archived | No | LinkTitle, IntakeStatus, RequesterName, Organization, ReceivedDate |

## Change Leadership Tools - Support Register

- Site: Change Leadership Tools
- Site URL: https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools
- Site contents: https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools/_layouts/15/viewlsts.aspx
- Description: One row per Change Leadership Tools support issue, bug report, product question, or feedback item.
- Show in site navigation: True

### Columns

| Done | Display name | SharePoint UI type | Required | Notes |
|---|---|---|---|---|
| [ ] | SourceMailbox | Choice | Yes | Choices: support@, contact@, adam@, admin@, other<br>Default: support@ |
| [ ] | SourceMessageId | Single line of text | No |  |
| [ ] | ReceivedDate | Date and time | Yes |  |
| [ ] | RequesterName | Single line of text | No |  |
| [ ] | RequesterEmail | Single line of text | No |  |
| [ ] | Organization | Single line of text | No |  |
| [ ] | ProductArea | Choice | No | Choices: Site, Download, Account, Document/tool, Payment, Other |
| [ ] | IssueType | Choice | Yes | Choices: Question, Bug, Access issue, Feedback, Refund/billing, Other<br>Default: Question |
| [ ] | Severity | Choice | Yes | Choices: Low, Normal, High, Blocking<br>Default: Normal |
| [ ] | Priority | Choice | Yes | Choices: Low, Normal, High, Urgent<br>Default: Normal |
| [ ] | Status | Choice | Yes | Choices: New, Triage, Waiting on Adam, Waiting on External, In Progress, Done, Archived<br>Default: New<br>Internal name: SupportStatus |
| [ ] | Owner | Person | Yes | Internal name: ItemOwner |
| [ ] | NextAction | Multiple lines of text | No |  |
| [ ] | ResolutionSummary | Multiple lines of text | No |  |
| [ ] | KnowledgeCandidate | Yes/No | Yes | Default: 0 |
| [ ] | DurableHome | Hyperlink | No |  |
| [ ] | PlannerTaskUrl | Hyperlink | No |  |
| [ ] | CentralOSLink | Hyperlink | No |  |
| [ ] | GraphNodeId | Single line of text | No |  |
| [ ] | HumanApprovalRequired | Yes/No | Yes | Default: 1 |
| [ ] | AgentNotes | Multiple lines of text | No |  |

### Views

| Done | View | Default | Columns |
|---|---|---|---|
| [ ] | Active Support | Yes | LinkTitle, Severity, SupportStatus, IssueType, ProductArea, RequesterName, ReceivedDate, ItemOwner, NextAction |
| [ ] | Knowledge Candidates | No | LinkTitle, KnowledgeCandidate, IssueType, ResolutionSummary, ReceivedDate |
| [ ] | Blocking / High | No | LinkTitle, Severity, SupportStatus, RequesterName, NextAction, ReceivedDate |
| [ ] | Resolved | No | LinkTitle, SupportStatus, IssueType, ResolutionSummary, ReceivedDate |

## Agent Action Log

- Site: Guided AI Labs
- Site URL: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs
- Site contents: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx
- Description: Human-readable log of agent suggestions, approvals, and completed actions.
- Show in site navigation: True

### Columns

| Done | Display name | SharePoint UI type | Required | Notes |
|---|---|---|---|---|
| [ ] | ActionDate | Date and time | Yes |  |
| [ ] | AgentSurface | Choice | Yes | Choices: Codex, future bridge, Power Automate, n8n, manual<br>Default: Codex |
| [ ] | Source | Hyperlink | No | Internal name: ActionSource |
| [ ] | ActionType | Choice | Yes | Choices: Read, summarize, draft, create-record, create-task, update-record, recommend<br>Default: recommend |
| [ ] | Status | Choice | Yes | Choices: Suggested, Approved, Completed, Rejected, Superseded<br>Default: Suggested<br>Internal name: ActionStatus |
| [ ] | HumanApprover | Person | No |  |
| [ ] | Result | Multiple lines of text | No |  |
| [ ] | CentralOSLink | Hyperlink | No |  |
| [ ] | GraphNodeId | Single line of text | No |  |

### Views

| Done | View | Default | Columns |
|---|---|---|---|
| [ ] | Needs Review | Yes | LinkTitle, ActionDate, AgentSurface, ActionType, ActionStatus, HumanApprover, Result |
| [ ] | Approved / Completed | No | LinkTitle, ActionDate, AgentSurface, ActionType, ActionStatus, Result |
| [ ] | Rejected / Superseded | No | LinkTitle, ActionDate, AgentSurface, ActionType, ActionStatus, Result |
| [ ] | By Surface | No | LinkTitle, AgentSurface, ActionDate, ActionType, ActionStatus |

## Decision Register

- Site: Guided AI Labs
- Site URL: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs
- Site contents: https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/_layouts/15/viewlsts.aspx
- Description: Commitments, approvals, scope decisions, unresolved questions, and revisit points.
- Show in site navigation: True

### Columns

| Done | Display name | SharePoint UI type | Required | Notes |
|---|---|---|---|---|
| [ ] | DecisionDate | Date and time | Yes |  |
| [ ] | DecisionOwner | Person | Yes |  |
| [ ] | Area | Choice | Yes | Choices: Client, Product, Operations, Agent, Governance, Admin<br>Default: Operations<br>Internal name: DecisionArea |
| [ ] | Decision | Multiple lines of text | Yes |  |
| [ ] | Rationale | Multiple lines of text | No |  |
| [ ] | RevisitDate | Date and time | No |  |
| [ ] | SourceLink | Hyperlink | No |  |
| [ ] | CentralOSLink | Hyperlink | No |  |
| [ ] | GraphNodeId | Single line of text | No |  |

### Views

| Done | View | Default | Columns |
|---|---|---|---|
| [ ] | Recent Decisions | Yes | LinkTitle, DecisionDate, DecisionOwner, DecisionArea, Decision, RevisitDate |
| [ ] | Revisit Soon | No | LinkTitle, RevisitDate, DecisionArea, DecisionOwner, Decision |
| [ ] | Agent / Governance | No | LinkTitle, DecisionDate, DecisionArea, Decision, Rationale, SourceLink |
| [ ] | Client / Delivery | No | LinkTitle, DecisionDate, DecisionArea, DecisionOwner, Decision, SourceLink |

## Verification Handoff

The manual path is complete only when the verifier can read each target site and reports all expected Lists, fields, and views as present. If PnP verification still cannot read the site, keep the tenant write automation paused and review the `agent-pnp-provisioning` app in Entra admin center.

