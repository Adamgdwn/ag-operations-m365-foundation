# Session Turnover - 2026-06-15

Canonical restart file:
[START_HERE.md](START_HERE.md).

This handoff captures the stop point after Stage 8 workspace-shape, backing
structure, and command-center homepage planning/build prep.

Operating-site rule confirmed with Adam: **Guided AI Labs is the daily workplace
and source of truth. AG Operations SharePoint surfaces are only router/portfolio
landing sites** for Guided AI Labs and any future companies underneath AG
Operations.

It also includes a late local-machine update: Chrome `Profile 3` was created for
the City of Red Deer Microsoft 365 lane, and the desktop account-conflict note was
updated with the browser/WAM inventory.

## Stop Point

Stage 8 is very close to the next live review step.

Live Microsoft 365 state already completed and verified:

- Stage 6 Lists, Planner, Teams channels, and Teams tabs are provisioned and
  verified.
- Stage 7 core guest/sharing governance is applied, verified, and logged.
- Stage 8 page/navigation skeleton is applied and verified.
- Stage 8 backing pages, Lists, libraries, folders, and remaining navigation are
  applied and verified.
- AG Operations root SharePoint is now a single-door landing page that routes to
  Guided AI Labs:
  `inventory/access-repair/ROOT_SHAREPOINT_SINGLE_DOOR_20260615-150954.md`.
- The `/sites/AGOperations` SharePoint site is also now a single-door landing
  page that routes to Guided AI Labs:
  `inventory/access-repair/ROOT_SHAREPOINT_SINGLE_DOOR_20260615-151219.md`.
- Owner access for `adamgoodwin@guidedailabs.com` and `admin@agoperations.ca`
  is granted/read-back verified across all 10 targeted SharePoint sites:
  `inventory/access-repair/SHAREPOINT_OWNER_ACCESS_ALL_SITES_20260615-152220.md`.
  `contact@agoperations.ca` remains intentionally excluded for now.
- The Login And Account Guide is published as `Login-And-Account-Guide.aspx`
  with a `Login Guide` navigation link on the 8 human-facing SharePoint sites:
  `inventory/access-repair/LOGIN_ACCOUNT_GUIDE_PUBLISH_20260615-153224.md`.
  Local source: `M365_LOGIN_AND_ACCOUNT_GUIDE.md`.

Completed next step on 2026-06-15:

```powershell
.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply
```

Approval phrase:

```text
create-stage-8-command-center-draft
```

This created only:

```text
Guided-AI-Labs-Command-Center-Draft.aspx
```

It does not replace the current homepage, change navigation, permissions,
sharing, guests, app grants, public Forms, deletion, or automation.

The read-only verifier was then run:

```powershell
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

Result: PASS. Browser-review the draft page with Adam before any homepage
promotion operator is created or run.

Verification summary:

```text
inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_VERIFY.md
```

## What Changed

1. Consolidated the Stage 8 homepage direction into the
   `Guided AI Labs Command Center` pattern:
   - compact AI-first command header;
   - six plain-language command cards;
   - Active Work Snapshot;
   - Client Pathway Snapshot;
   - Operational Readiness homepage band / dashboard runway.

2. Added the machine-readable homepage refinement config:

   ```text
   config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json
   ```

3. Added the local homepage refinement packet generator:

   ```text
   scripts/New-M365Stage8HomepageRefinementPacket.ps1
   ```

   Generated outputs:

   ```text
   inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md
   inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html
   inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-homepage-command-cards.csv
   inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-homepage-active-work-snapshot.csv
   inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-homepage-client-pathway.csv
   inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-operational-readiness-dashboard-runway.csv
   ```

4. Added the draft-first homepage builder:

   ```text
   scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1
   scripts/Start-M365Stage8HomepageRefinementInteractive.ps1
   ```

   The builder is dry-run by default. With `-Apply`, it requires the typed
   approval phrase and creates the command-center draft page only.

5. Added the read-only homepage verifier:

   ```text
   scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1
   scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
   ```

   The verifier checks that the draft page exists, has expected command-center
   markers, and has not become the current homepage.

6. Updated Stage 8 local preflight:

   ```text
   scripts/Test-M365Stage8LocalPreflight.ps1
   inventory/stage-8-client-workspace-reference/STAGE_8_LOCAL_PREFLIGHT.md
   ```

   Latest result: PASS.

7. Updated orientation docs:
   - [START_HERE.md](START_HERE.md)
   - [00_INDEX.md](00_INDEX.md)
   - [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
   - [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
   - [M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md)
   - [M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md)

## Design Decisions Captured

Homepage title:

```text
Guided AI Labs Command Center
```

Command cards:

- New Intake
- Active Delivery
- Decisions Needed
- Client Readiness
- Automation And Agents
- Handoffs And Evidence

Snapshot bands:

- Active Work Snapshot:
  Now Moving, Waiting On Adam, Blocked / At Risk, Next Best Actions.
- Client Pathway Snapshot:
  Discover -> Assess -> Design Workspace -> Deliver -> Handoff.

Dashboard concept:

```text
Operational Readiness
```

Use it as a homepage band first. Dedicated dashboard/page comes later only after
real operating records justify it.

Boundary:

- SharePoint/M365 is the governed business workspace and human-facing operating
  surface.
- UAOS owns request/mission/approval/validation/relay/learning mechanics.
- Graphify owns workspace knowledge lookup, relationship map, recommendations,
  and handoff records.
- Prime Operations is a useful structure reference, not the visual target.

## Validation Done

Local-only validation:

```powershell
.\scripts\New-M365Stage8HomepageRefinementPacket.ps1
.\scripts\Test-M365Stage8LocalPreflight.ps1
.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1 -NoPause
git diff --check
```

Results:

- Homepage packet regenerated successfully.
- Stage 8 local preflight: PASS.
- Homepage refinement dry run: PASS.
- `git diff --check`: clean except normal LF/CRLF working-copy warnings.

No live Microsoft 365 changes were made during the final local handoff prep.

## Remaining Governance Notes

Still not complete:

- `support@changeleadershiptools.com` still needs an Authenticator/MFA method.
- Broad delegated app grants need a resting-state decision, especially
  `agent-pnp-provisioning` with `AllSites.FullControl` and `Group.ReadWrite.All`.
- The Viva Engage system site remains the only external-sharing exception; do
  not delete it. Review only if there is no external community workflow.
- No real partner/client guest invite, external link, public/client-facing Form,
  or client-facing automation should be issued until the Stage 8 workflow/access
  pattern is reviewed.

## Stage 8A Relationship CRM Spine

Adam approved the Lists-first, future-own-CRM-ready CRM plan. Stage 8A artifacts
were added:

```text
M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md
config/M365_STAGE_8A_RELATIONSHIP_CRM.json
scripts/New-M365Stage8ARelationshipCrmPacket.ps1
scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1
scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1
scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1
scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1
scripts/Test-M365Stage8ALocalPreflight.ps1
inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md
```

Live apply completed on 2026-06-15:

```powershell
.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply
```

Approval phrase:

```text
apply-stage-8a-relationship-crm
```

Apply evidence:

```text
inventory/stage-8a-relationship-crm/stage-8a-relationship-crm-build-20260615-130604.log
```

It created only the six CRM Lists, fields, views, the `Relationship-CRM.aspx`
page, and a Client Delivery navigation link. It did not create Dynamics,
Dataverse, permissions, guests, sharing, app grants, public Forms, mail sends,
deletes, or unattended automation.

Read-only verification completed and passed:

```text
inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md
```

Do not create the planned Teams tabs until the Relationship CRM page is
browser-reviewed with Adam.

## Stage 8B Relationship CRM Operations

Adam asked to make the CRM operational rather than merely structurally present.
Stage 8B artifacts were added locally:

```text
M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md
config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json
scripts/New-M365Stage8BRelationshipCrmOperationsPacket.ps1
scripts/Test-M365Stage8BLocalPreflight.ps1
scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1
scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1
scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1
scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1
inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md
inventory/stage-8b-relationship-crm-operations/STAGE_8B_LOCAL_PREFLIGHT.md
```

Local checks passed:

```text
Stage 8B packet generation: PASS
Stage 8B local preflight: PASS
Stage 8B dry run: PASS
```

Live apply completed:

```text
inventory/stage-8b-relationship-crm-operations/stage-8b-crm-operationalize-20260615-134054.log
```

Approval phrase:

```text
apply-stage-8b-crm-operations
```

Read-only verification completed and passed:

```text
inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md
```

## Stage 8C Relationship CRM Operator Workflow

Adam asked to carry on building the CRM into something operational. Stage 8C
artifacts were added locally:

```text
M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md
config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json
scripts/New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1
scripts/Test-M365Stage8CLocalPreflight.ps1
scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1
scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1
scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1
scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1
inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md
inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_LOCAL_PREFLIGHT.md
```

Local checks passed:

```text
Stage 8C packet generation: PASS
Stage 8C local preflight: PASS
Stage 8C dry run: PASS
```

Live apply completed:

```text
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260615-142931.log
```

Approval phrase:

```text
apply-stage-8c-crm-workflow
```

Read-only verification completed and passed:

```text
inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md
```

Stage 8C created `CRM - Action Queue`, `CRM - Qualification`, `CRM - Meeting
Notes`, `CRM - Artifacts`, `CRM - Health Reviews`,
`Relationship-CRM-Command-Center.aspx`, and `Client Delivery / CRM Command
Center`.

## Guided AI Labs Operations Cockpit Cleanup

Adam reported that the Guided AI Labs SharePoint homepage was confusing: stock
News/Quick links were still visible, Stage 8 build-plan cards were surfacing,
and three CRM entry points made the daily path unclear.

Live cleanup completed on 2026-06-15:

```text
scripts/Set-GuidedAILabsOperationsPortal.ps1
inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260615-161438.md
```

Read-back verified:

- Guided AI Labs homepage is now the dashboard-style operations cockpit:
  `SitePages/Guided-AI-Labs-Operations-Cockpit.aspx`.
- Daily cockpit URL:
  `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx`
- The cockpit has four top work cards: CRM, Operations, Tools, and Projects
  In Flight.
- The cockpit embeds four live SharePoint list views: `Open CRM Actions`,
  `Qualification Triage`, `Attention Now`, and `Agent Action Log / Needs
  Review`.
- The old `Relationship CRM` and `CRM Operations` nav links were removed from
  daily navigation; those pages remain as reference pages.
- `CRM Command Center` remains the single daily CRM entry point.
- `Recent` was removed from Quick Launch to reduce CRM list clutter.
- `App Grants` is a governance surface only. It is not currently a live direct
  connection to a Guided AI Labs Funding & Benefits agent.
- Adam confirmed the cockpit direction was better and asked to box up the work
  for the night.

## Stage 9 Agent Capability Prep

Adam asked to proceed toward an M365 coordinator and support agent with
read-write capability inside governance boundaries. Local-only Stage 9 artifacts
were added:

```text
config/M365_STAGE_9_AGENT_CAPABILITY_MODEL.json
scripts/New-M365Stage9AgentCapabilityPacket.ps1
scripts/Invoke-M365Stage9AgentCapabilityLoop.ps1
scripts/Start-M365Stage9AgentCapabilityLoopInteractive.ps1
scripts/Test-M365Stage9LocalPreflight.ps1
inventory/stage-9-agentic-os-bridge/agent-capability/STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md
inventory/stage-9-agentic-os-bridge/STAGE_9_LOCAL_PREFLIGHT.md
```

Current posture: supervised delegated List-write loops are live-proven. No new
app registrations, consent grants, mailbox sends, guests, sharing, permissions,
tenant policy, public Forms, deletion, or unattended automation were created.

Completed Stage 9 live actions on 2026-06-15:

- Decision Register item `#2`: Stage 9 M365 coordinator and support agent
  capability approved for supervised loops.
- Agent Action Log item `#2`: Stage 9 agent capability model prepared.
- Agent Action Log item `#3`: Stage 9 coordinator suggestion loop.
- Change Leadership Tools Support Register item `#1`: Stage 9 supervised
  support triage test.
- Agent Action Log item `#4`: Stage 9 support triage loop.

Evidence:

- `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-recorddecision-20260615-110540.log`
- `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-coordinatorsuggestion-20260615-110719.log`
- `inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-supporttriage-20260615-110951.log`

## Exact Resume Sequence

1. Open [START_HERE.md](START_HERE.md).
2. If resuming tomorrow, open the live Guided AI Labs Operations Cockpit first.
3. Review the CRM Command Center from the cockpit. The older Relationship
   CRM and CRM Operations pages are reference pages, not daily entry points.
4. Do not create Teams tabs until the portal and CRM Command Center are
   confirmed usable.
5. Do not repeat the Stage 9 capability decision write unless scope changes.
6. After homepage and CRM review, run the first real functional workflow walkthrough:

   ```text
   New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence
   ```

## Git Note

Adam asked to box up, commit, and push this working set on 2026-06-15. The
intended commit scope is the M365/SharePoint workstream: Stage 8A/B/C CRM,
SharePoint access repair, login/account guide publishing, Guided AI Labs
Operations Cockpit, and Stage 9 agent capability bridge artifacts.
