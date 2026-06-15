# Start Here - Token-Friendly Project State

Last updated: 2026-06-15

This is the short restart/orientation note for Codex or any agent working in this
workspace. Read this first, then open detailed docs only as needed.

## Project purpose

Build Microsoft 365 into a clean, governed operating substrate for AG Operations
and Guided AI Labs.

M365 is not the whole future Agentic OS. It is one fully functional operating
layer: identity, records, tasks, decisions, collaboration, email signals, and
audit. The future central OS / Graphify map can integrate across M365, local and
Linux workspaces, repos, products, and other tools.

## Canonical order

Use [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) for the full staged
plan.

Current stage:

```text
Stage 8 command-center homepage draft is live-created/read-back verified.
Stage 9 supervised coordinator/support List-write loops are live-proven.
```

Completed/design-complete:

- Stage 0: setup/tooling
- Stage 1: current-state inventory
- Stage 2: identity/admin foundation
- Stage 3: SharePoint architecture/sites
- Stage 4: OneDrive/local machine dovetail
- Stage 5: Exchange/communication routing design

## Current stop point - 2026-06-15

Stop point for the next session:

```text
Stage 8 live SharePoint skeleton and backing structure are built and verified.
The Guided AI Labs Command Center draft page is live-created and read-back
verified. Browser review with Adam is next before any homepage promotion
operator is created or run. Stage 9 capability decision, coordinator suggestion,
and support triage supervised List-write loops are also recorded in M365.
```

Completed live action on 2026-06-15:

```powershell
.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply
```

Approval phrase:

```text
create-stage-8-command-center-draft
```

Then run the read-only verifier:

```powershell
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

This created/verified only:

```text
Guided-AI-Labs-Command-Center-Draft.aspx
```

It does **not** replace the real homepage, change navigation, permissions,
sharing, guests, app grants, public Forms, deletion, or automation.

Next action: browser-review the draft with Adam. Only then decide whether to
build a separate promotion operator to make it the real homepage.

Stage 9 supervised agent loops are now live-proven for Adam's requested governed
M365 coordinator/support agent capability:

- Decision Register item `#2`: Stage 9 M365 coordinator and support agent
  capability approved for supervised loops.
- Agent Action Log item `#2`: Stage 9 agent capability model prepared.
- Agent Action Log item `#3`: Stage 9 coordinator suggestion loop.
- Change Leadership Tools Support Register item `#1`: Stage 9 supervised
  support triage test.
- Agent Action Log item `#4`: Stage 9 support triage loop.

This is still supervised delegated List-write posture only. No app
registrations, consent grants, mail sends, guests, sharing, permissions, tenant
policy changes, public Forms, deletion, or unattended automation were created.

## Current foundation state

Stage 6 Lists, Planner, Teams channels, and Teams web tabs are provisioned and
read-back verified. Stage 7 core governance is also applied and read-back
verified: guest invites are restricted to admins/Guest Inviters, SharePoint
tenant sharing is authenticated external users only, default sharing links are
specific-people/Direct style, and the approved governance batch is recorded in
the Guided AI Labs Decision Register and Agent Action Log.

Confirmed tenant change from Stage 6 attempt:

- `adamgoodwin@guidedailabs.com` is now secondary site collection admin on:
  - `https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools`
  - `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`

Done:

- The four Stage 6 Lists are created and verified:
  - `Guided AI Labs - Intake Register`
  - `Change Leadership Tools - Support Register`
  - `Agent Action Log`
  - `Decision Register`
- Stage 6 Planner/Teams live gate is complete:
  - Planner plan: `Guided AI Labs - Operating Plan`
  - buckets: Intake Triage, Client Discovery, Active Delivery, Content / IP,
    Agent Setup, Waiting / Follow-up, Admin / Governance
  - Team: existing `Guided AI Labs` group team-enabled
  - channels: General, Intake, Client Discovery, Active Delivery, Agent Setup,
    Methods and IP
  - web tabs: Planner/List/library/decision tabs verified
  - read-back log:
    `inventory/stage-6-operating-state/stage-6-verify-planner-teams-20260614-190613.log`
- Local onboarding readiness artifacts were generated:
  - `inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`
  - `partner-onboarding-checklist.csv`
  - `partner-training-path.csv`
  - `client-readiness-discovery-checklist.csv`
  - `operating-readiness-scorecard.csv`
- Microsoft Forms intake/feedback kit was added locally:
  - `config/M365_FORMS_INTAKE_FEEDBACK_KIT.json`
  - `scripts/New-M365FormsIntakeFeedbackKit.ps1`
  - `inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md`
  - `forms-question-map.csv`
  - `forms-flow-build-checklist.csv`
- Stage 7 local baseline and inventory tooling were added:
  - `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md`
  - `config/M365_STAGE_7_GOVERNANCE_BASELINE.json`
  - `scripts/Invoke-M365Stage7SecurityInventory.ps1`
  - `scripts/Start-M365Stage7SecurityInventoryInteractive.ps1`
  - `scripts/Invoke-M365Stage7SharePointSharingInventory.ps1`
  - `scripts/Start-M365Stage7SharePointSharingInventoryInteractive.ps1`
  - `scripts/Invoke-M365Stage7GovernanceWriteWindow.ps1`
  - `scripts/Start-M365Stage7GovernanceWriteWindowInteractive.ps1`
  - `scripts/Invoke-M365Stage7RecordGovernanceDecision.ps1`
  - `scripts/Start-M365Stage7RecordGovernanceDecisionInteractive.ps1`
  - `scripts/Invoke-M365Stage7GovernanceReviewPack.ps1`
  - `scripts/Invoke-M365Stage7AppGrantRestingStatePlan.ps1`
  - `scripts/Invoke-M365Stage7SiteSharingExceptionWindow.ps1`
  - `scripts/Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1`
  - `scripts/Summarize-M365Stage7SecurityInventory.ps1`
  - `scripts/Test-M365Stage7LocalPreflight.ps1`
  - `inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md`
  - `inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md`
- Stage 7 live governance evidence is captured:
  - pre-change inventory: `inventory/stage-7-security-governance/20260614-191812/`
  - post-change verification: `inventory/stage-7-security-governance/20260614-193825/`
  - governance write log: `inventory/stage-7-security-governance/stage-7-governance-write-window-20260614-193729.log`
  - Decision Register / Agent Action Log write log:
    `inventory/stage-7-security-governance/stage-7-record-governance-decision-20260614-200637.log`
  - governance review pack:
    `inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md`
  - app grant resting-state plan:
    `inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md`
  - site sharing cleanup dry run:
    `inventory/stage-7-security-governance/stage-7-site-sharing-exception-window-20260614-203111.log`
  - site sharing cleanup apply:
    `inventory/stage-7-security-governance/stage-7-site-sharing-exception-window-20260614-210942.log`
  - post-cleanup SharePoint sharing read-back:
    `inventory/stage-7-security-governance/20260614-193825/stage-7-sharepoint-sharing-20260614-211128.log`
  - Decision Register item #1: `Stage 7 governance baseline tightened and verified`
  - Agent Action Log item #1: `Stage 7 governance write window applied and verified`
- Stage 8 and Stage 9 planning docs were added:
  - `M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md`
  - `M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md`
  - `M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md`
  - `M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md`
- Stage 9 coordinator/support agent capability model was added and first
  supervised loops were live-proven:
  - `config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json`
  - `scripts/New-M365Stage9AgentCapabilityPacket.ps1`
  - `scripts/Invoke-M365Stage9AgentCapabilityLoop.ps1`
  - `scripts/Start-M365Stage9AgentCapabilityLoopInteractive.ps1`
  - `scripts/Test-M365Stage9LocalPreflight.ps1`
  - generated packet:
    `inventory/stage-9-agentic-os-bridge/agent-capability/STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md`
  - live evidence:
    `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-recorddecision-20260615-110540.log`
  - live evidence:
    `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-coordinatorsuggestion-20260615-110719.log`
  - live evidence:
    `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-supporttriage-20260615-110951.log`
  - current posture: supervised delegated List-write loops are proven; no new
    app registrations, consent, mailbox sends, guests, sharing, permissions,
    tenant policy, public Forms, deletion, or unattended automation.
- Stage 8 workspace-shape build packet and live operator were added:
  - `config/M365_STAGE_8_WORKSPACE_SHAPE.json`
  - `scripts/New-M365Stage8WorkspaceShapePacket.ps1`
  - `scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1`
  - `scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1`
  - `scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1`
  - `scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1`
  - `scripts/Test-M365Stage8LocalPreflight.ps1`
  - `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md`
  - `stage-8-page-map.csv`
  - `stage-8-navigation-map.csv`
  - `stage-8-next-list-map.csv`
  - `stage-8-library-role-map.csv`
- Stage 8 page/navigation skeleton was applied and read-back verified:
  - apply log:
    `inventory/stage-8-client-workspace-reference/workspace-shape/stage-8-workspace-shape-build-20260614-213203.log`
  - verification summary:
    `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`
  - verification transcript:
    `inventory/stage-8-client-workspace-reference/workspace-shape/stage-8-workspace-shape-verify-20260614-213610.log`
  - result: PASS
  - created pages: Guided AI Labs Home, How To Use This Workspace, Intake,
    Active Delivery, Decisions, Client Workspace Pattern, Methods And IP,
    AI And Automation Governance.
  - present navigation links: Home, How To Use This Workspace, Intake, Active
    Delivery, Decisions, Action Log, Client Workspace Pattern, Decision
    Register, Agent Action Log.
- Stage 8 backing structure was applied and read-back verified:
  - config:
    `config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json`
  - build guide:
    `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md`
  - apply log:
    `inventory/stage-8-client-workspace-reference/workspace-backing-structure/stage-8-workspace-backing-build-20260614-220231.log`
  - verification summary:
    `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
  - result: PASS
  - created routing pages: Operating Model, Client Discovery, Agent Setup,
    Access Model, External Sharing Rules, App Grants.
  - created Lists: Client Workspace Register, Handoff Packet Register, Tool
    Permission Review, Automation Backlog, Exception Register.
  - created libraries: Published Methods, Delivery Working Documents,
    Restricted Build Evidence, Client Handoff Packets, Readiness Evidence.
    Archive already existed; Completed Work and Historical Evidence folders were
    added.
  - added the remaining 17 planned navigation links.

Not done:

- `support@changeleadershiptools.com` still needs an Authenticator/MFA method.
- Broad delegated grants need a resting-state decision, especially
  `agent-pnp-provisioning` with `AllSites.FullControl` and `Group.ReadWrite.All`.
- Root/legacy SharePoint site cleanup has been applied and read-back verified for
  root, A.G. Operations Ltd, and All Company. The only remaining sharing
  exception is the Viva Engage system site, which should not be deleted and
  should be reviewed only if no external community workflow exists.
- No real partner/client guest invite, external link, or client-facing public
  Form should be issued until the Stage 8 workspace/access decision is approved.
- Stage 8 look/feel page refinement, homepage composition, and a first
  end-to-end workflow walkthrough are still next. Do not invite partners/clients
  or widen access until that workflow and Stage 7 access decisions are reviewed.
- Stage 8 page refinement should follow the UAOS/Graphify/SharePoint boundary:
  SharePoint is the governed business workspace and human-facing operating
  surface; UAOS owns mission envelope, approvals, validation, relay, and
  learning; Graphify owns workspace knowledge lookup and recommendations.
- Stage 8 homepage refinement decisions were consolidated into a buildable
  command-center packet:
  - `config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json`
  - `scripts/New-M365Stage8HomepageRefinementPacket.ps1`
  - `scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1`
  - `scripts/Start-M365Stage8HomepageRefinementInteractive.ps1`
  - `scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1`
  - `scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1`
  - `inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md`
  - `inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html`
  - dry-run log:
    `inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-homepage-refinement-build-20260614-233625.log`
  - latest local preflight includes this layer and passes:
    `inventory/stage-8-client-workspace-reference/STAGE_8_LOCAL_PREFLIGHT.md`
  - live apply was completed on 2026-06-15 and created
    `Guided-AI-Labs-Command-Center-Draft.aspx` after the approval phrase
    `create-stage-8-command-center-draft`; it did not replace the current
    homepage, change navigation, permissions, sharing, guests, app grants,
    public Forms, deletion, or automation.
  - read-only verification passed:
    `inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_VERIFY.md`.

Latest local checks:

- Stage 8 local preflight: PASS.
- Homepage refinement dry run: PASS.
- Homepage refinement live draft apply: PASS.
- Homepage refinement read-only verification: PASS.
- Stage 9 local preflight: PASS.
- Stage 9 capability decision apply: PASS.
- Stage 9 coordinator suggestion dry run/apply: PASS.
- Stage 9 support triage dry run/apply: PASS.
- `git diff --check`: clean except normal LF/CRLF working-copy warnings.
- No homepage promotion, navigation change, permission change, sharing change,
  guest invite, app grant, public Form, deletion, external send, or unattended
  automation has been made.

## Stage 6 blocker

Resolved: PnP originally authenticated as the wrong delegated user:

```text
admin@agoperations.ca
```

Automation now uses device login plus an expected-user guard for:

```text
adamgoodwin@guidedailabs.com
```

Read-only verification passed after provisioning.

Important safety rule:

```text
Do not use raw Microsoft admin-consent URLs.
Do not approve any page showing phishing, risky-app, unknown-publisher,
suspicious-consent, or unexpected permission warnings.
```

Read before retrying:

- [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md) section 10.1

## Stage 6 design assets

- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
- [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
- [inventory/stage-6-operating-state/STAGE_6_MANUAL_LIST_BUILD_GUIDE.md](inventory/stage-6-operating-state/STAGE_6_MANUAL_LIST_BUILD_GUIDE.md)
- [inventory/stage-6-operating-state/STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md](inventory/stage-6-operating-state/STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md)
- [inventory/stage-6-operating-state/STAGE_6_LOCAL_PREFLIGHT.md](inventory/stage-6-operating-state/STAGE_6_LOCAL_PREFLIGHT.md)
- [inventory/stage-6-operating-state/first-run-packet/STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md](inventory/stage-6-operating-state/first-run-packet/STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md)
- [inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md](inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md)

## Stage 7 design assets

- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
- [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json)
- [inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md](inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md)
- [inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md](inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md)
- [inventory/stage-7-security-governance/20260614-193825/stage-7-security-inventory-summary.md](inventory/stage-7-security-governance/20260614-193825/stage-7-security-inventory-summary.md)
- [inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md](inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md)
- [inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md](inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md)

## Stage 8/9 planning assets

- [M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md)
- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)
- [config/M365_STAGE_8_WORKSPACE_SHAPE.json](config/M365_STAGE_8_WORKSPACE_SHAPE.json)
- [config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json](config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json)
- [scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1](scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1)
- [scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1)
- [scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1)
- [scripts/New-M365Stage8WorkspaceBackingPacket.ps1](scripts/New-M365Stage8WorkspaceBackingPacket.ps1)
- [scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1](scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1)
- [scripts/Start-M365Stage8WorkspaceBackingBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceBackingBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1)
- [scripts/Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1)
- [config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json)
- [scripts/New-M365Stage8HomepageRefinementPacket.ps1](scripts/New-M365Stage8HomepageRefinementPacket.ps1)
- [scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1](scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1)
- [scripts/Start-M365Stage8HomepageRefinementInteractive.ps1](scripts/Start-M365Stage8HomepageRefinementInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1](scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1)
- [scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1](scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1)
- [inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md)
- [scripts/Test-M365Stage8LocalPreflight.ps1](scripts/Test-M365Stage8LocalPreflight.ps1)
- [inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md)
- [inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md)
- [inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md](inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md)

The schema defines:

- Guided AI Labs intake register
- Change Leadership Tools support register
- Agent Action Log
- Decision Register
- Forms intake/feedback kit: discovery intake, support request, session feedback,
  and team retrospective routed into the existing Lists
- Planner buckets
- Teams/channel/tab layout
- future integration hooks: `CentralOSLink`, `GraphNodeId`

## Safe next session path

1. Read this file.
2. Read [SESSION_TURNOVER_2026-06-15.md](SESSION_TURNOVER_2026-06-15.md).
3. Browser-review the draft command-center page:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Command-Center-Draft.aspx
```

4. Decide whether to build a separate homepage promotion operator. Do not
   promote manually from the command-center build script.

5. Review the Stage 9 agent capability packet if changing capability scope:

```text
inventory/stage-9-agentic-os-bridge/agent-capability/STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md
```

6. Stage 9 capability decision and first supervised coordinator/support loops
   are already recorded. For any next Stage 9 loop, start dry-run-first:

```powershell
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action CoordinatorSuggestion
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action SupportTriage
```

7. Apply any next Stage 9 loop only after Adam approves and types the
   action-specific phrase:

```text
record-stage-9-coordinator-suggestion
record-stage-9-support-triage
```

8. After the command-center page is browser-approved, run the first functional
   workflow walkthrough:
   `New Intake -> triage -> decision -> active delivery -> handoff evidence`.

## Useful scripts

Read-only / diagnostic:

```powershell
.\scripts\Test-M365Stage6PnPPermissions.ps1
.\scripts\Test-M365Stage6PnPPermissions.ps1 -UseDeviceLogin
.\scripts\Test-M365Stage6PnPTokenClaims.ps1
.\scripts\Clear-M365Stage6PnPPersistedLogin.ps1
.\scripts\Show-M365Stage6PnPConsentReviewChecklist.ps1
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action RepairLogin
.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify
.\scripts\New-M365Stage6ManualListBuildGuide.ps1
.\scripts\New-M365Stage6PlannerTeamsBuildGuide.ps1
.\scripts\New-M365FormsIntakeFeedbackKit.ps1
.\scripts\New-M365Stage6FirstRunPacket.ps1
.\scripts\New-M365Stage6OnboardingReadinessPacket.ps1
.\scripts\Update-M365Stage6LocalArtifacts.ps1
.\scripts\Test-M365Stage6LocalPreflight.ps1
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly
.\scripts\Test-M365Stage7LocalPreflight.ps1
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1
.\scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1
.\scripts\Summarize-M365Stage7SecurityInventory.ps1
.\scripts\Invoke-M365Stage7GovernanceReviewPack.ps1
.\scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1
.\scripts\New-M365Stage8WorkspaceShapePacket.ps1
.\scripts\New-M365Stage8WorkspaceBackingPacket.ps1
.\scripts\New-M365Stage8HomepageRefinementPacket.ps1
.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

Live writes, use only after review:

```powershell
.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action ProvisionAndVerify
.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1
.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -EnsureSiteAdmins
.\scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1 -Apply
.\scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1 -Apply
.\scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1 -Apply
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1 -Apply
.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1 -Apply
.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply
```

Stage 7 live read-only inventory:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1
.\scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1
```

Optional SharePoint admin read-back after installing the SharePoint Online module:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin
```

Authorization preference:

- Use visible interactive windows for Microsoft sign-in/MFA/approval.
- Prefer persisted login for routine runs where safe.
- Use the Planner/Teams operator's default device-code path on this workstation;
  embedded-shell WAM browser auth can fail without a window handle. Start it
  when Adam is present because Microsoft Graph device-code auth can time out
  quickly when left unattended. The operator now waits for Enter before starting
  the short-lived device-code flow and preserves the Graph session across the
  phases once sign-in succeeds.
- Human approval is required for consent, broad permissions, external sharing,
  destructive actions, guest access, mail sends, calendar commitments, and tenant
  policy changes.

## Detailed index

Use [00_INDEX.md](00_INDEX.md) for the longer project map.
