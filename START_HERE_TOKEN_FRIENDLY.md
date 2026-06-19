# Start Here - Token-Friendly Project State

Last updated: 2026-06-19

This is the short restart/orientation note for Codex or any agent working in this
workspace. For current workspace usability work, read `docs/START_HERE.md` first.
For the wider M365 foundation, read this file, then open detailed docs only as
needed.

## Project purpose

Build Microsoft 365 into a clean, governed operating substrate for AG Operations
and Guided AI Labs.

Operating-site rule: **Guided AI Labs is the daily workplace and source of
truth. AG Operations SharePoint surfaces are portfolio/router landing sites
only** for Guided AI Labs and any future companies underneath AG Operations.

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
Stage 8A Relationship CRM is live-created/read-back verified.
Stage 8B Relationship CRM operations layer is live-applied/read-back verified.
Stage 8C Relationship CRM operator workflow is live-applied/read-back verified.
Stage 8D local functional workflow walkthrough packet and capture worksheets
are generated/preflighted; the internal production workflow proof is
live-recorded/read-back verified.
Stage 8B read-only verification was re-run on 2026-06-17 and passes after the
old `Client Delivery / CRM Operations` nav check was marked superseded by the
Stage 8C `CRM Command Center` daily door.
AG Operations root and `/sites/AGOperations` SharePoint sites now route to
Guided AI Labs as the single daily workplace.
Owner access for `adamgoodwin@guidedailabs.com` and `admin@agoperations.ca` is
granted/read-back verified across all 10 targeted tenant SharePoint sites;
`contact@agoperations.ca` remains intentionally excluded.
`Login-And-Account-Guide.aspx` is published with a `Login Guide` nav link on the
8 human-facing SharePoint sites, and the local source is
`M365_LOGIN_AND_ACCOUNT_GUIDE.md`.
Stage 9 supervised coordinator/support List-write loops are live-proven, and
the bridge readiness control posture is live-recorded/read-back verified.
Local browser lane hygiene was updated: Chrome Profile 3 is now City of Red Deer.
Workspace usability Chunks 1-4 are complete and pushed. Chunk 2 categorized the current
Operations Cockpit cards, queues, links, superseded surfaces, and
admin-only/controlled governance surfaces from local evidence. Chunk 3 hardened
the card-plan template, created the card-plan index, and applied CRM as the
first example. Chunk 4 created the access/onboarding model, role tiers,
card-by-card access matrix, first-day walkthrough, escalation rules, and
admin-only boundary. Next workspace chunk is Chunk 5 - Card Deep Dives.
```

Completed/design-complete:

- Stage 0: setup/tooling
- Stage 1: current-state inventory
- Stage 2: identity/admin foundation
- Stage 3: SharePoint architecture/sites
- Stage 4: OneDrive/local machine dovetail
- Stage 5: Exchange/communication routing design

## Current stop point - 2026-06-19

Stop point for the next session:

```text
Workspace usability Chunks 1-4 are complete and pushed.
The card-plan standard is created and CRM is the first applied example.
The access/onboarding model now separates operating access from admin authority.
No live tenant read was needed and no tenant write was performed.
Next workspace chunk is Chunk 5 - Card Deep Dives.

Start with:
docs/START_HERE.md
docs/WORKSPACE_EXECUTION_PLAN.md
docs/COCKPIT_USABILITY_INVENTORY.md
docs/COCKPIT_CARD_GAP_LIST.md
docs/CARD_PLAN_TEMPLATE.md
docs/CARD_PLAN_INDEX.md
docs/CARD_PLAN_CRM_RELATIONSHIPS.md
docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md
```

The most recent handoff is
[SESSION_TURNOVER_2026-06-19.md](SESSION_TURNOVER_2026-06-19.md).

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

Historical next action from 2026-06-15: browser-review the draft with Adam
before any homepage promotion operator. The current 2026-06-19 workspace resume
point is Chunk 5 in `docs/WORKSPACE_EXECUTION_PLAN.md`.

Stage 9 supervised agent loops are now live-proven for Adam's requested governed
M365 coordinator/support agent capability:

- Decision Register item `#2`: Stage 9 M365 coordinator and support agent
  capability approved for supervised loops.
- Agent Action Log item `#2`: Stage 9 agent capability model prepared.
- Agent Action Log item `#3`: Stage 9 coordinator suggestion loop.
- Change Leadership Tools Support Register item `#1`: Stage 9 supervised
  support triage test.
- Agent Action Log item `#4`: Stage 9 support triage loop.
- Decision Register item `#3`: Stage 9 bridge readiness control posture
  approved.
- Agent Action Log item `#5`: Stage 9 bridge readiness control recorded.

This is still supervised delegated List-write posture only. The Stage 9 bridge
readiness control packet now defines readiness tracks, adapter contracts, app
posture options, risk controls, and graduation gates before any move to a
purpose-built adapter. The live bridge decision was refreshed after the Stage 8D
internal proof and explicitly does not approve a production UAOS/M365 adapter,
app registration, consent grant, SharePoint Selected permission grant, Exchange
Application RBAC assignment, tenant policy change, external send, guest access,
public Form, sharing change, deletion, or unattended automation.

Local account/session note from 2026-06-15:

- Chrome `Profile 3` was created as `City of Red Deer`.
- Desktop shortcut: `C:\Users\adamg\OneDrive\Desktop\Chrome - City of Red Deer.lnk`.
- Chrome `Default` should remain personal-only; do not mix work/school tenants there.
- Full notes: [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md).

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
  - `M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md`
  - `M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md`
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
- Stage 9 bridge readiness control packet was added locally:
  - `config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json`
  - `scripts/New-M365Stage9BridgeReadinessControlPacket.ps1`
  - `scripts/Test-M365Stage9BridgeReadinessControlPreflight.ps1`
  - generated guide:
    `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md`
  - app posture worksheet:
    `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv`
  - adapter contract:
    `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-adapter-contract.csv`
  - local preflight:
    `inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_PREFLIGHT.md`
  - current posture: Stage 8D internal proof is complete; stay supervised
    delegated until setup-helper resting-state decision, support MFA,
    permission-scope design, rollback worksheet, G0/G1 adapter dry run, and a
    separate production bridge decision are complete.
  - refreshed live evidence:
    `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-bridgereadinesscontrol-20260617-121810.log`
  - refreshed read-back:
    `inventory/stage-9-agentic-os-bridge/stage-9-bridge-readiness-control-readback-20260617-121908.log`
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
- Stage 8 look/feel and CRM walkthrough work is now provenance for the broader
  workspace usability pass. The Chunk 4 access model is documented in
  `docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`; do not invite
  partners/clients or widen access until exact live permission targets,
  card-specific runbooks, and final usability acceptance are reviewed.
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
- Stage 8A Relationship CRM local build layer was added and live-applied:
  - `config/M365_STAGE_8A_RELATIONSHIP_CRM.json`
  - `M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md`
  - `scripts/New-M365Stage8ARelationshipCrmPacket.ps1`
  - `scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1`
  - `scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1`
  - `scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1`
  - `scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1`
  - `scripts/Test-M365Stage8ALocalPreflight.ps1`
  - generated packet:
    `inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md`
  - live apply created the six CRM Lists, fields, views, `Relationship-CRM.aspx`,
    and the `Client Delivery / Relationship CRM` navigation link:
    `inventory/stage-8a-relationship-crm/stage-8a-relationship-crm-build-20260615-130604.log`
  - read-only verification passed:
    `inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md`
- Stage 8B Relationship CRM operations layer was added locally:
  - `config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json`
  - `M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md`
  - `scripts/New-M365Stage8BRelationshipCrmOperationsPacket.ps1`
  - `scripts/Test-M365Stage8BLocalPreflight.ps1`
  - `scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1`
  - `scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1`
  - `scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1`
  - `scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1`
  - generated packet:
    `inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md`
  - live apply completed:
    `inventory/stage-8b-relationship-crm-operations/stage-8b-crm-operationalize-20260615-134054.log`
  - read-only verification passed:
    `inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md`
  - 2026-06-17 note: the Stage 8B `CRM Operations` Quick Launch link is now
    treated as superseded by the Stage 8C `CRM Command Center` daily door; the
    Stage 8B page remains a reference surface and verification still checks its
    page, fields, lookups, and views.
- Stage 8C Relationship CRM operator workflow layer was added and live-applied:
  - `config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json`
  - `M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md`
  - `scripts/New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1`
  - `scripts/Test-M365Stage8CLocalPreflight.ps1`
  - `scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1`
  - `scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1`
  - `scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1`
  - `scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1`
  - generated packet:
    `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md`
  - live apply completed:
    `inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260615-142931.log`
  - read-only verification passed:
    `inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md`
- Stage 8D functional workflow walkthrough layer was added locally:
  - `config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json`
  - `M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md`
  - `scripts/New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1`
  - `scripts/Test-M365Stage8DLocalPreflight.ps1`
  - generated packet:
    `inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md`
  - capture worksheet:
    `inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv`
  - findings starter:
    `inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv`
  - local preflight:
    `inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_LOCAL_PREFLIGHT.md`
  - scope: local-only browser/manual walkthrough plan; no tenant writes,
    permissions, sharing, guests, app grants, public Forms, mail sends, deletes,
    Dynamics/Dataverse, or unattended automation.

Latest local checks:

- Stage 8 local preflight: PASS.
- Stage 8A local preflight: PASS.
- Stage 8A Relationship CRM packet generation: PASS.
- Stage 8A Relationship CRM dry run: PASS.
- Stage 8A Relationship CRM live apply: PASS.
- Stage 8A Relationship CRM read-only verification: PASS.
- Stage 8B Relationship CRM operations packet generation: PASS.
- Stage 8B Relationship CRM operations local preflight: PASS.
- Stage 8B Relationship CRM operations dry run: PASS.
- Stage 8B Relationship CRM operations live apply: PASS.
- Stage 8B Relationship CRM operations read-only verification: PASS
  (2026-06-17 rerun; superseded nav target handled as expected).
- Stage 8C Relationship CRM operator workflow packet generation: PASS.
- Stage 8C Relationship CRM operator workflow local preflight: PASS.
- Stage 8C Relationship CRM operator workflow dry run: PASS.
- Stage 8C Relationship CRM operator workflow live apply: PASS.
- Stage 8C Relationship CRM operator workflow read-only verification: PASS.
- Stage 8D functional workflow walkthrough packet generation: PASS.
- Stage 8D functional workflow walkthrough local preflight: PASS.
- Stage 8D internal production proof dry run/apply/read-back: PASS.
- Homepage refinement dry run: PASS.
- Homepage refinement live draft apply: PASS.
- Homepage refinement read-only verification: PASS.
- Stage 9 local preflight: PASS.
- Stage 9 bridge readiness control packet generation: PASS.
- Stage 9 bridge readiness control preflight: PASS.
- Stage 9 bridge readiness control live dry run/apply/read-back: PASS
  (refreshed after Stage 8D internal proof).
- Stage 9 capability packet regeneration after CRM scope update: PASS.
- Stage 9 capability decision apply: PASS.
- Stage 9 coordinator suggestion dry run/apply: PASS.
- Stage 9 support triage dry run/apply: PASS.
- `git diff --check`: clean except normal LF/CRLF working-copy warnings.
- No homepage promotion, permission change, sharing change, guest invite, app
  grant, public Form, deletion, external send, Dynamics/Dataverse, or unattended
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
- [M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md)
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)
- [config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json](config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json)
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md)
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
- [config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json)
- [scripts/New-M365Stage8ARelationshipCrmPacket.ps1](scripts/New-M365Stage8ARelationshipCrmPacket.ps1)
- [scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1](scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1)
- [scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1](scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1](scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1)
- [scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1](scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1)
- [scripts/Test-M365Stage8ALocalPreflight.ps1](scripts/Test-M365Stage8ALocalPreflight.ps1)
- [inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md)
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
2. Read [SESSION_TURNOVER_2026-06-17.md](SESSION_TURNOVER_2026-06-17.md).
3. Open the live Guided AI Labs Operations Cockpit first:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx
```

4. Open the CRM Command Center from the cockpit:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx
```

5. Stage 8D browser checkpoints found two usability gaps: the cockpit had a CRM
   Command Center card, but the command center did not initially present an
   obvious CRM stage/pipeline path; after that was refreshed, the page still
   felt like a wall of text and the intake link opened the raw SharePoint list
   form. The Stage 8C frictionless CRM refresh was applied and read-back
   verified on 2026-06-17 so the CRM Command Center now shows:

```text
Intake -> Qualification -> Engagement Pipeline -> Decision / Proposal -> Active Delivery -> Handoff Evidence
```

   The intake form now starts with `Quick intake` and `Triage` sections instead
   of source/system fields.

6. Stage 8D internal dummy proof records now exist in production. Use the Stage
   8D guide and the read-back CSV to inspect the path before creating another
   proof chain:

```text
inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-readback-20260617-121052.csv
```

Capture every step outcome and friction point here:

```text
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv
```

Target path:

```text
New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence
```

7. The old command-center draft page and older Relationship CRM / CRM Operations
   pages are reference/review surfaces, not the daily homepage or daily CRM door:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Command-Center-Draft.aspx
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM.aspx
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Operations.aspx
```

8. Do not create the planned Teams tabs until the live proof records are visually
   checked from the Operations Cockpit and CRM Command Center.

9. Review the Stage 9 agent capability packet if changing capability scope:

```text
inventory/stage-9-agentic-os-bridge/agent-capability/STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md
```

9. Review the Stage 9 bridge readiness control packet before any app
   registration, consent, Selected permission grant, Exchange Application RBAC
   change, or production adapter discussion:

```text
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv
```

10. Stage 9 capability decision and first supervised coordinator/support loops
   are already recorded. For any next Stage 9 loop, start dry-run-first:

```powershell
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action CoordinatorSuggestion
.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action SupportTriage
```

11. Apply any next Stage 9 loop only after Adam approves and types the
   action-specific phrase:

```text
record-stage-9-coordinator-suggestion
record-stage-9-support-triage
```

12. Guided AI Labs homepage is now the live Operations Cockpit:
   `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx`.
   It has top cards for CRM, Operations, Tools, and Projects In Flight, plus
   embedded live queues for Open CRM Actions, Qualification Triage, Attention
   Now, and Agent Action Log / Needs Review. The single daily CRM door is the
   CRM Command Center; older Relationship CRM and CRM Operations pages remain
   reference pages only.

13. Stop the Stage 8D walkthrough if it requires external sharing, guest access,
    public Forms, mail sends, app grants, permission changes, deletion, or real
    client data before the workflow is approved.

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
.\scripts\New-M365Stage8ARelationshipCrmPacket.ps1
.\scripts\New-M365Stage8BRelationshipCrmOperationsPacket.ps1
.\scripts\Test-M365Stage8ALocalPreflight.ps1
.\scripts\Test-M365Stage8BLocalPreflight.ps1
.\scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1
.\scripts\Test-M365Stage8DLocalPreflight.ps1
.\scripts\Invoke-M365Stage8DWorkflowProof.ps1
.\scripts\New-M365Stage9BridgeReadinessControlPacket.ps1
.\scripts\Test-M365Stage9BridgeReadinessControlPreflight.ps1
.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1
.\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1
.\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
.\scripts\Set-GuidedAILabsOperationsPortal.ps1
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
.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply
.\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 -Apply
.\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply
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
