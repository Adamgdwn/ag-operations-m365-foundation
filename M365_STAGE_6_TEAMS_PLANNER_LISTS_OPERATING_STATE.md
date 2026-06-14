# Microsoft 365 Stage 6 - Teams, Planner, Lists & Operating State

Status: **Stage 6 Lists provisioned and verified; Planner/Teams operator and onboarding readiness packet prepared**
(2026-06-14). This is the
Stage 6 working document per [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md).
It follows completed Stages 2-4 and the Stage 5 Exchange inventory/posture
decisions.

Stage 6 turns clean identities, SharePoint homes, and Exchange intake into
visible, usable operating state. This is where the Guided AI Labs agentic intake
model starts to become useful day to day, even before the larger central OS is
connected.

Related:

- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
- [M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md](M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md)

---

## 1. Design goal

Create the minimum Microsoft-native operating surfaces needed to answer:

```text
What came in?
What kind of thing is it?
Who owns it?
What is the next action?
Where is the durable record?
What did the agent suggest or do?
What needs Adam's approval?
```

Teams is for coordination. Planner is for tasks. Lists are for structured state.
Forms are structured front doors for intake and feedback. SharePoint is the
durable record home. Exchange is the signal layer.

Stage 6 also defines the working experience. Adam should be able to open Teams and
see the live operating picture without spelunking through email, file trees, or
admin centers. The agent should have clear places to propose work, log work, and
ask for approval.

This is not "just documentation and email." Stage 6 should be fully functional as
Microsoft-native business infrastructure:

- Lists hold current operational state.
- Forms collect structured intake, support, feedback, and retrospective signals.
- Planner holds real tasks and follow-up.
- Teams holds active collaboration.
- SharePoint holds durable records.
- Exchange provides signals and communication history.
- Agent logs and decision records make AI-assisted work reviewable.

The future central operating system can then read, write, navigate, and reason
across these surfaces without needing Microsoft 365 itself to become the entire
brain.

---

## 2. Operating experience and look/feel

The target feel is a quiet operations console: plain language, low clutter, clear
ownership, and fast scanning. No decorative structure, no redundant dashboards,
and no channel/list sprawl.

Primary entry point:

```text
Microsoft Teams -> Guided AI Labs - Operating Team -> Intake channel
```

Expected first-screen rhythm:

| Area | What Adam should see | Why it matters |
|---|---|---|
| Teams channel tabs | Intake Register, Operating Plan, Agent Action Log, Decision Register | One click from conversation to state |
| Intake Register default view | New/Triage/Waiting on Adam items, sorted by received date and priority | The front door becomes visible work |
| Planner board | Only action-bearing work, grouped by bucket | Tasks stay meaningful instead of becoming email mirrors |
| Forms kit | Discovery intake, support request, session feedback, team retrospective | Clean front doors for information that should not start as loose email |
| Agent Action Log | Suggested or completed agent moves | The agent is legible and auditable |
| Decision Register | Commitments and approvals | Durable decisions do not disappear into chat |

Visual/interaction conventions:

| Convention | Standard |
|---|---|
| Names | Use business language: `Intake Register`, `Support Register`, `Agent Action Log`, `Decision Register` |
| Statuses | Keep states few and operational: New, Triage, Waiting on Adam, Waiting on External, In Progress, Done, Archived |
| Priorities | Low, Normal, High, Urgent |
| Views | Default views should answer "what needs attention now?" before showing archival history |
| Tabs | Pin Lists/Planner/SharePoint surfaces into Teams channels instead of making users hunt |
| Agent copy | Agent notes should be short, explicit, and written for review, not performance |
| Approval posture | Anything external, contractual, calendar-committing, permission-changing, or irreversible requires Adam approval |

The first version should feel more like a reliable business partner sitting beside
the work than an automation system running away from it. The agent's first job is
to reduce ambiguity: summarize, classify, propose, link, and log.

---

## 3. Agentic partner operating model

The agent is treated as a working partner with constrained agency:

| Role | Agent can do first | Agent cannot do first |
|---|---|---|
| Triage partner | Classify selected messages, draft intake rows, suggest priority/status | Auto-send external replies |
| Operations partner | Draft Planner tasks and next actions | Commit Adam to deadlines or meetings |
| Knowledge partner | Flag reusable methods, FAQs, and decision candidates | Publish or overwrite canonical material |
| Governance partner | Log suggestions/actions and mark approval required | Grant access, invite guests, or change tenant policy |

Every agent-visible work item should have:

```text
Source -> classification -> proposed next action -> human approval flag -> durable home -> action log entry
```

This is the bridge pattern for the larger Guided AI Labs infrastructure: the
agent does not need broad tenant power to become useful. It needs trustworthy
work surfaces, scoped permissions, and a visible review loop.

### 3.1 Central OS and Graphify relationship

Microsoft 365 is one governed operating substrate in the larger system. The
central OS and Graphify map should eventually act as the integrating layer across
M365, local/Linux workspaces, repositories, product systems, client work, and
other external tools.

After reviewing the Graphify Workspace Cockpit package on 2026-06-14, the
boundary is clearer:

| Layer | Responsibility |
|---|---|
| Microsoft 365 | Governed business substrate: records, collaboration, mail, tasks, permissions, audit |
| Graphify Workspace Cockpit | Knowledge and decision intelligence: Ask, Map, Decisions, Recommendations, Work Queue |
| User AI Operating System | Mission execution: policy-gated adapters, cross-system orchestration, evidence and rollback |

Stage 6 should therefore make Microsoft 365 clean, useful, and linkable without
trying to become the long-term central cockpit. Graphify/UAOS will become the
central spine; M365 will remain the trusted business substrate and future UAOS
spoke.

Stage 6 should therefore create real operating value now while preserving clean
integration hooks for later:

| Layer | Role |
|---|---|
| Microsoft 365 | Governed work surfaces: identity, files, lists, tasks, Teams, mail, audit |
| Graphify map | Cross-system knowledge/navigation graph and relationship map |
| Agentic central OS | Orchestration, reasoning, task routing, memory, and multi-surface coordination |
| Codex/workspace docs | Setup control room, design record, scripts, and handoff trail |

Design implications:

- M365 items should have stable links and optional external graph/node references.
- Agent logs should capture enough context for the central OS to reconstruct what
  happened.
- Durable records should remain in SharePoint/M365 when they are business records.
- Graphify can map relationships across records, people, decisions, tasks,
  projects, and repos without becoming the only place the operational truth lives.
- The first version must still be useful manually; central OS integration should
  enhance it, not rescue an unusable setup.

---

## 4. Stage 6 build targets

Initial design targets:

| Surface | Name | Site/team | Purpose |
|---|---|---|---|
| List | `Guided AI Labs - Intake Register` | Guided AI Labs | Consulting, client, partnership, and readiness intake |
| List | `Change Leadership Tools - Support Register` | Change Leadership Tools | Product support triage and issue history |
| List | `Agent Action Log` | Guided AI Labs | Human-readable log of agent suggestions/actions |
| List | `Decision Register` | Guided AI Labs or Shared Libraries | Commitments, approvals, scope decisions, unresolved questions |
| Form | `Guided AI Labs - Discovery Intake` | Guided AI Labs | Client/partner discovery front door that feeds Intake Register |
| Form | `Change Leadership Tools - Support Request` | Change Leadership Tools | Support front door that feeds Support Register |
| Form | `Guided AI Labs - Session Feedback` | Guided AI Labs | Workshop/session feedback that feeds Intake Register and improvement tasks |
| Form | `Guided AI Labs - Team Retrospective` | Guided AI Labs | Internal/partner learning signal that feeds decisions/tasks |
| Planner | `Guided AI Labs - Operating Plan` | Guided AI Labs | Tasks created from intake, delivery, setup, and follow-up |
| Team | `Guided AI Labs - Operating Team` | Guided AI Labs | Internal coordination around intake, delivery, and agent setup |

Defer unless volume justifies it:

| Surface | Reason to defer |
|---|---|
| Separate Change Leadership Tools Planner plan | Support List may be enough at low volume |
| Separate agent-owned calendar | Adam remains real calendar owner until scheduling volume demands it |
| Production Graph app registration | Stage 7/9 governance should come first |

---

## 5. Proposed Lists

### 5.1 Guided AI Labs - Intake Register

Purpose: one row per meaningful inquiry, client discovery signal, partnership
lead, or future agent-surfaced opportunity.

Columns:

| Column | Type | Required | Notes |
|---|---|---|---|
| `Title` | single line text | yes | Short human-readable label |
| `SourceMailbox` | choice | yes | `contact@`, `adam@`, `support@`, `admin@`, other |
| `SourceMessageId` | single line text | no | Exchange/Graph identifier when available |
| `ReceivedDate` | date/time | yes | Original signal date |
| `RequesterName` | single line text | no | Sender/contact name |
| `RequesterEmail` | single line text | no | Sender email |
| `Organization` | single line text | no | Client/company |
| `IntakeClass` | choice | yes | `new-inquiry`, `client-readiness`, `scheduling`, `decision-or-commitment`, `knowledge-candidate`, `noise-or-spam` |
| `Priority` | choice | yes | Low, Normal, High, Urgent |
| `Status` | choice | yes | New, Triage, Waiting on Adam, Waiting on External, In Progress, Done, Archived |
| `Owner` | person | yes | Adam at first |
| `NextAction` | multiple lines text | no | Next concrete action |
| `DurableHome` | hyperlink | no | SharePoint record location |
| `PlannerTaskUrl` | hyperlink | no | Link to task when created |
| `CentralOSLink` | hyperlink | no | Future central OS/Graphify record link |
| `GraphNodeId` | single line text | no | Stable external graph node/reference ID |
| `HumanApprovalRequired` | yes/no | yes | True for send, schedule, permission, or commitment |
| `AgentConfidence` | number | no | Optional score |
| `AgentNotes` | multiple lines text | no | Rationale, summary, caveats |

Recommended default views:

| View | Filter | Sort |
|---|---|---|
| Attention Now | Status is New, Triage, Waiting on Adam, or In Progress | Priority, ReceivedDate descending |
| Waiting External | Status is Waiting on External | ReceivedDate descending |
| Agent Suggested | HumanApprovalRequired is Yes or AgentNotes is not blank | ReceivedDate descending |
| Done / Archived | Status is Done or Archived | ReceivedDate descending |

Recommended Teams tab label: `Intake Register`.

### 5.2 Change Leadership Tools - Support Register

Purpose: one row per support issue, bug report, product question, or user feedback
item.

Columns should mirror the intake register where practical, with additional support
fields:

| Column | Type | Required | Notes |
|---|---|---|---|
| `ProductArea` | choice | no | Site, download, account, document/tool, payment, other |
| `IssueType` | choice | yes | Question, bug, access issue, feedback, refund/billing, other |
| `Severity` | choice | yes | Low, Normal, High, Blocking |
| `ResolutionSummary` | multiple lines text | no | How it was resolved |
| `KnowledgeCandidate` | yes/no | yes | Whether it should become reusable FAQ/support content |
| `CentralOSLink` | hyperlink | no | Future central OS/Graphify record link |
| `GraphNodeId` | single line text | no | Stable external graph node/reference ID |

Recommended default views:

| View | Filter | Sort |
|---|---|---|
| Active Support | Status is New, Triage, Waiting on Adam, Waiting on External, or In Progress | Severity, ReceivedDate descending |
| Knowledge Candidates | KnowledgeCandidate is Yes | ReceivedDate descending |
| Blocking / High | Severity is Blocking or High | ReceivedDate descending |
| Resolved | Status is Done or Archived | ReceivedDate descending |

Recommended Teams tab label: `Support Register` if this is surfaced in a channel
later. For now it can live primarily in the Change Leadership Tools site.

### 5.3 Agent Action Log

Purpose: make agent work visible and reviewable.

Columns:

| Column | Type | Required | Notes |
|---|---|---|---|
| `Title` | single line text | yes | Short action label |
| `ActionDate` | date/time | yes | When suggested/performed |
| `AgentSurface` | choice | yes | Codex, future bridge, Power Automate, n8n, manual |
| `Source` | hyperlink/text | no | Message, list item, file, task, or conversation |
| `ActionType` | choice | yes | Read, summarize, draft, create-record, create-task, update-record, recommend |
| `Status` | choice | yes | Suggested, Approved, Completed, Rejected, Superseded |
| `HumanApprover` | person | no | Adam at first |
| `Result` | multiple lines text | no | Outcome or reason |
| `CentralOSLink` | hyperlink | no | Future central OS/Graphify action link |
| `GraphNodeId` | single line text | no | Stable external graph node/reference ID |

Recommended default views:

| View | Filter | Sort |
|---|---|---|
| Needs Review | Status is Suggested | ActionDate descending |
| Approved / Completed | Status is Approved or Completed | ActionDate descending |
| Rejected / Superseded | Status is Rejected or Superseded | ActionDate descending |
| By Surface | Group by AgentSurface | ActionDate descending |

Recommended Teams tab label: `Agent Log`.

### 5.4 Decision Register

Purpose: preserve decisions that should not be buried in email or chat.

Columns:

| Column | Type | Required | Notes |
|---|---|---|---|
| `Title` | single line text | yes | Decision title |
| `DecisionDate` | date/time | yes | Date decided |
| `DecisionOwner` | person | yes | Adam at first |
| `Area` | choice | yes | Client, product, operations, agent, governance, admin |
| `Decision` | multiple lines text | yes | What was decided |
| `Rationale` | multiple lines text | no | Why |
| `RevisitDate` | date/time | no | Review point |
| `SourceLink` | hyperlink | no | Email, doc, meeting note, task |
| `CentralOSLink` | hyperlink | no | Future central OS/Graphify decision link |
| `GraphNodeId` | single line text | no | Stable external graph node/reference ID |

Recommended default views:

| View | Filter | Sort |
|---|---|---|
| Recent Decisions | none | DecisionDate descending |
| Revisit Soon | RevisitDate is not blank | RevisitDate ascending |
| Agent / Governance | Area is agent or governance | DecisionDate descending |
| Client / Delivery | Area is client | DecisionDate descending |

Recommended Teams tab label: `Decisions`.

---

### 5.5 Microsoft Forms intake and feedback kit

Purpose: give Guided AI Labs and Change Leadership Tools clean, reusable front
doors for information that is better collected as structured responses than as
loose email.

Forms should not become the operating record. A form response is a signal. The
copied Microsoft List row is the operating state.

Initial Forms:

| Form | Audience | Target | Primary use |
|---|---|---|---|
| `Guided AI Labs - Discovery Intake` | Prospects, partners, business owners | `Guided AI Labs - Intake Register` | Discovery, readiness, consulting, partnership signals |
| `Change Leadership Tools - Support Request` | Product users/buyers | `Change Leadership Tools - Support Register` | Questions, bugs, access issues, feedback, billing/refund issues |
| `Guided AI Labs - Session Feedback` | Workshop/discovery/delivery participants | `Guided AI Labs - Intake Register` | Delivery improvement, follow-up requests, reusable method candidates |
| `Guided AI Labs - Team Retrospective` | Internal team and future partners | `Decision Register` | Decision candidates, risks, improvements, operating lessons |

Power Automate routing pattern:

```text
Forms response -> get response details -> create List item -> optional Planner task -> optional Teams notice -> update List item with task link
```

Rules:

| Rule | Standard |
|---|---|
| External links | Treat public Forms links as external sharing; approve under Stage 7 before distribution |
| Phishing protection | Keep Microsoft Forms phishing protection enabled |
| Response storage | Copy into Lists; do not rely on manually opened Excel workbooks as the operating record |
| Planner task creation | Create tasks only for action-bearing responses, urgent items, low scores, follow-up requests, or owner-accepted improvements |
| Teams notifications | Notify channels only for meaningful items; do not make every form response a channel post |
| Client data | Do not collect sensitive client material until Stage 7 sharing/security decisions are complete |

Implementation artifacts:

| Artifact | Purpose |
|---|---|
| `config/M365_FORMS_INTAKE_FEEDBACK_KIT.json` | Machine-readable Forms, question, flow, and governance schema |
| `scripts/New-M365FormsIntakeFeedbackKit.ps1` | Generates the local Forms build guide and CSV mapping tables |
| `inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md` | Manual build guide for Forms and Power Automate routing |
| `inventory/stage-6-operating-state/forms-intake-feedback/forms-question-map.csv` | Flat question-to-List mapping |
| `inventory/stage-6-operating-state/forms-intake-feedback/forms-flow-build-checklist.csv` | Flat Power Automate checklist by form |

Important platform constraint:

Microsoft Forms is not currently treated like Lists/Planner/Teams in this build.
We should assume form creation and detailed response extraction are manual or
Power Automate-centered unless a supported production API path is confirmed.
That is acceptable: the robust pattern is to create Forms deliberately, then
automate response handling into Lists where the rest of the operating state
already exists.

---

## 6. Planner design

Plan:

```text
Guided AI Labs - Operating Plan
```

Buckets:

- Intake Triage
- Client Discovery
- Active Delivery
- Content / IP
- Agent Setup
- Waiting / Follow-up
- Admin / Governance

Task rule:

Create a Planner task only when there is a next action. Do not create tasks for
every email or every List item.

Planner task naming convention:

```text
[Lane] concise action - organization/person
```

Examples:

- `[Intake] Draft discovery reply - Acme`
- `[Support] Investigate download issue - Jane Smith`
- `[Agent] Review contact@ triage run`

Planner details should include links back to the relevant List item, message, and
durable SharePoint home when available.

---

## 7. Teams design

Team:

```text
Guided AI Labs - Operating Team
```

Channels:

| Channel | Purpose |
|---|---|
| General | Low-volume operating announcements |
| Intake | Discussion around new inquiries and triage |
| Client Discovery | Readiness/discovery work before active delivery |
| Active Delivery | Current client work coordination |
| Agent Setup | Agentic intake, bridge, workflow, and tooling decisions |
| Methods & IP | Reusable methods, templates, and productized knowledge |

Recommended tab layout:

| Channel | Tabs to pin first |
|---|---|
| General | Operating Plan, Decisions |
| Intake | Intake Register, Operating Plan, Agent Log |
| Client Discovery | Intake Register filtered to discovery/readiness, Operating Plan |
| Active Delivery | Operating Plan, Client_Delivery library |
| Agent Setup | Agent Log, Decisions, Automation_Workflows library |
| Methods & IP | Templates_Methods library, Decisions filtered to Methods/IP |

Optional later team:

```text
Change Leadership Tools - Support
```

Create it only if support activity grows beyond what the List and Guided AI Labs
operating team can comfortably manage.

Teams is for discussion and coordination. It should not become the durable filing
cabinet; SharePoint remains the record home.

---

## 8. SharePoint relationship

Stage 6 should make SharePoint easier to use, not duplicate it.

| Operating thing | Durable SharePoint home |
|---|---|
| Guided AI Labs intake row | Guided AI Labs `Operating` or Guided AI Journey engagement home |
| Support row | Change Leadership Tools `Support` library |
| Agent setup decision | Guided AI Labs `Operating/05_Automation_Workflows` or Shared Libraries `Standards_Methods` |
| Reusable method/IP | Guided AI Labs `Templates_Methods` or Shared Libraries `Standards_Methods` |
| Client delivery task | Guided AI Labs `Client_Delivery` until Stage 8 client pattern is built |

The durable home should not be mandatory on day one; it becomes mandatory when an
item becomes active work, a client commitment, reusable IP, or a decision.

---

## 9. First agent-assisted workflow

Start with a low-risk loop:

1. Agent reads or is shown selected `contact@` items.
2. Agent classifies the item.
3. Agent drafts:
   - intake List row;
   - suggested acknowledgement;
   - Planner task only if action is required.
4. Adam approves edits/sends/creates.
5. Agent action is logged.

No autonomous external send, meeting booking, deletion, permissions change, guest
invite, or tenant configuration change in this first loop.

---

## 10. Build sequence

| Step | Action | Tenant write? | Status |
|---|---|---|---|
| 6.1 | Review this Stage 6 design | no | in progress |
| 6.2 | Decide exact List names/columns | no | design drafted |
| 6.3 | Decide whether to create the Guided AI Labs operating Team now | no | recommended |
| 6.4 | Create the intake/support/action/decision Lists | yes | complete |
| 6.5 | Create Forms intake/feedback kit and Power Automate build guide | no | local artifacts prepared |
| 6.6 | Create Planner plan and buckets | yes | pending approval |
| 6.7 | Create Team/channels if approved | yes | pending approval |
| 6.8 | Run read-back inventory/verification | read-only | Lists passed; Planner/Teams pending |
| 6.9 | Start first manual agent-assisted intake loop | mostly no | pending |

Implementation artifacts:

| Artifact | Purpose |
|---|---|
| `config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json` | Machine-readable Stage 6 Lists/Planner/Teams schema |
| `scripts/Invoke-M365Stage6ProvisionLists.ps1` | Interactive, idempotent creation of the four Microsoft Lists |
| `scripts/Invoke-M365Stage6VerifyLists.ps1` | Read-only verification of the Stage 6 Lists and columns |
| `scripts/Start-M365Stage6ListsProvisioningInteractive.ps1` | Visible PowerShell launcher for Adam sign-in and typed confirmation |
| `scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1` | Live prerequisite: add Adam as secondary site collection admin on Stage 6 target sites |
| `scripts/Test-M365Stage6PnPPermissions.ps1` | Read-only PnP permission diagnostic |
| `scripts/Test-M365Stage6PnPTokenClaims.ps1` | Read-only decoded token metadata diagnostic; does not print bearer tokens |
| `scripts/Clear-M365Stage6PnPPersistedLogin.ps1` | Clears the local persisted PnP login entry so the correct user can sign in |
| `scripts/Invoke-M365Stage6ListOperator.ps1` | Efficient Lists operator for local update, login repair, verify, or provision-and-verify |
| `scripts/Start-M365Stage6ListOperatorInteractive.ps1` | Visible launcher for the efficient Lists operator |
| `scripts/Invoke-M365Stage6VerifyPlannerTeams.ps1` | Read-only Graph verification of the Stage 6 Planner plan, buckets, Team, channels, and tabs |
| `scripts/Invoke-M365Stage6ProvisionPlannerTeams.ps1` | Interactive, idempotent Graph provisioning of the Planner plan, buckets, existing-group Team, channels, and best-effort web tabs |
| `scripts/Invoke-M365Stage6PlannerTeamsOperator.ps1` | Efficient Planner/Teams operator for verify or provision-and-verify |
| `scripts/Start-M365Stage6PlannerTeamsOperatorInteractive.ps1` | Visible launcher for the efficient Planner/Teams operator; defaults to device-code auth |
| `config/M365_FORMS_INTAKE_FEEDBACK_KIT.json` | Machine-readable Microsoft Forms intake/feedback schema and routing model |
| `scripts/New-M365FormsIntakeFeedbackKit.ps1` | Generates the Forms build guide and CSV mapping/checklist files |
| `inventory/stage-6-operating-state/forms-intake-feedback/` | Generated Forms build guide, question map, and Power Automate checklist |
| `scripts/New-M365Stage6ManualListBuildGuide.ps1` | Generates a SharePoint UI fallback checklist from the canonical schema |
| `inventory/stage-6-operating-state/STAGE_6_MANUAL_LIST_BUILD_GUIDE.md` | Manual creation guide for the four Stage 6 Lists when PnP is blocked |
| `scripts/New-M365Stage6PlannerTeamsBuildGuide.ps1` | Generates a Planner/Teams setup checklist from the canonical schema |
| `inventory/stage-6-operating-state/STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md` | Manual setup guide for the Stage 6 Planner plan, buckets, Team, channels, and tabs |
| `scripts/Test-M365Stage6LocalPreflight.ps1` | Local-only validation of schema, scripts, generated guides, and required modules |
| `inventory/stage-6-operating-state/STAGE_6_LOCAL_PREFLIGHT.md` | Latest local-only preflight report; no Microsoft 365 connection or tenant writes |
| `scripts/New-M365Stage6FirstRunPacket.ps1` | Generates starter CSVs and a first agent-loop runbook for after Lists exist |
| `inventory/stage-6-operating-state/first-run-packet/` | First-run starter rows for Intake, Support, Agent Action Log, and Decision Register |
| `scripts/New-M365Stage6OnboardingReadinessPacket.ps1` | Generates partner/client onboarding readiness checklists and scorecard |
| `inventory/stage-6-operating-state/onboarding-readiness/` | Runbook, partner checklist, training path, client-readiness checklist, and operating readiness scorecard |
| `scripts/Update-M365Stage6LocalArtifacts.ps1` | Regenerates all Stage 6 local guides, first-run packet, and local preflight in one command |

### 10.1 Execution status - 2026-06-14

Stage 6 Lists are provisioned and read-back verified.

What succeeded:

- Adam was added as a secondary site collection administrator on:
  - `https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools`
  - `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
- Stage 6 scripts now prefer PowerShell 7 (`pwsh.exe`) because that is where
  `PnP.PowerShell` is installed.
- PnP persistent login is enabled for repeat runs where Microsoft permits token
  reuse.
- Provisioning and verification runs now write transcripts under
  `inventory/stage-6-operating-state/`.
- Local-only Stage 6 preflight passes and does not connect to Microsoft 365.
- Schema-driven manual guides now exist for Lists, Planner/Teams, and the first
  human-approved agent loop.
- `stage-6-provision-lists-20260614-134436.log` created all four Lists.
- `stage-6-verify-lists-20260614-135144.log` passed verification for all Lists,
  fields, and views.
- Planner/Teams automation has been added with the same operator pattern:
  read-only verify, typed-confirm live provisioning, then read-only verify.
- A local onboarding readiness packet has been added so Stage 6 can be judged as
  an operating cockpit, a partner onboarding surface, and a client-readiness
  bridge instead of only a set of M365 objects.
- The local preflight now validates the onboarding readiness packet.
- A non-interactive Graph WAM attempt failed from the embedded shell because no
  parent window handle was available. The visible Planner/Teams launcher now
  defaults to device-code auth to avoid that loop.
- First visible Planner/Teams `ProvisionAndVerify` run was launched at
  2026-06-14 14:12. Graph device-code auth timed out after 120 seconds of
  inactivity before connecting, so no Planner/Teams live writes occurred.
- The Planner/Teams operator now pauses before device-code auth and asks Adam to
  press Enter when ready. This avoids burning the short Microsoft sign-in timer
  while the window is unattended.
- A safer visible Planner/Teams `ProvisionAndVerify` window was relaunched at
  2026-06-14 14:18 and is intended to sit before auth until Adam presses Enter.
  No new Planner/Teams provision log exists yet.
- Another visible Planner/Teams `ProvisionAndVerify` run started at
  2026-06-14 15:55 and timed out during Graph device-code authentication before
  connecting. No Planner/Teams provision log was created.
- The Planner/Teams operator now preserves the Graph connection across
  preflight, provisioning, and post-verification phases after a successful sign-in
  so the live path should require fewer repeated authentication prompts.
- A later run at 2026-06-14 17:30 proved that `Read-Host` was not a reliable
  pause in spawned visible windows from this agent shell; it skipped ahead and
  produced `stage-6-verify-planner-teams-20260614-173056.log`, another
  device-code timeout before Graph connection.
- The visible M365 launchers now start through `cmd.exe`, pause before
  PowerShell begins, and then launch the Graph/PnP script only after Adam presses
  a key in the visible window. A fixed Planner/Teams `ProvisionAndVerify` window
  is parked before auth; no new Planner/Teams provision log exists yet.

What was blocked:

- PnP originally connected with the wrong delegated user:
  `admin@agoperations.ca`.
- Read-only diagnostics failed until the persisted login cache was cleared and
  device login was completed as `adamgoodwin@guidedailabs.com`.
- A raw Microsoft admin-consent URL for `agent-pnp-provisioning` produced errors
  including a phishing warning. That path remains **not approved** and should not
  be clicked through.

Interpretation:

The issue was wrong delegated user context, not missing app scopes. Stage 6 PnP
scripts now support `-UseDeviceLogin` and assert the expected signed-in user
before site operations.

Safe next options:

1. Use `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify`
   for a read-only Planner/Teams check.
2. Use `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify`
   for the efficient live Planner/Teams gate. The visible window requires
   device-code sign-in and typed `planner-teams` confirmation.
3. Use `inventory/stage-6-operating-state/first-run-packet/` for the first
   human-approved agent loop after the collaboration surfaces are ready.
4. Use `inventory/stage-6-operating-state/onboarding-readiness/` before adding a
   business partner or shaping first client onboarding.

Desired operating mode:

Stage 6 should mature toward an agent-assisted implementation cockpit:

```text
Codex runs preflight -> Adam approves meaningful visible gates -> Codex implements
-> Codex verifies -> transcript/audit is recorded
```

Adam should not have to repeatedly babysit shell prompts. Routine sign-in should
reuse persisted Microsoft/PnP login where permitted, and prompts should be
reserved for real consent, MFA, destructive risk, broad permissions, or look/feel
approval. Any browser/security warning stops the run.

---

## 11. Open decisions

| # | Decision | Recommendation |
|---|---|---|
| 6.1 | Create all four Lists now or start with intake + action log only? | Start with all four if easy; they are lightweight and give the agent structure |
| 6.2 | Create Guided AI Labs operating Team now? | Yes, if Adam wants Teams as the coordination surface; otherwise defer and use Lists first |
| 6.3 | Create separate Change Leadership Tools support Team now? | No, defer until support volume demands it |
| 6.4 | Is Planner needed immediately? | Yes for action-bearing work, but do not mirror every List item |
| 6.5 | First agent loop source | `contact@guidedailabs.com`, human-approved drafts only |
| 6.6 | Should Stage 6 include look and feel? | Yes: views, tabs, naming, and approval experience are part of the operating substrate |

---

## 12. Recommended next move

Proceed in two layers:

1. Create the four Lists first. This gives the agent and Adam structured state
   without changing mail flow, permissions, or external collaboration.
2. After read-back passes, add Teams tabs/channels and Planner buckets around the
   proven Lists so the experience becomes the daily working surface.

This keeps the big picture intact: Microsoft 365 becomes the governed operating
substrate, and Guided AI Labs' broader agentic infrastructure gets clean,
auditable surfaces to work against.
