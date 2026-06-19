# 00 — Start Here

**AG Operations / Guided AI Labs — Microsoft 365 Foundation**

Last updated: 2026-06-19

This is the single entry point for the workspace. Open this first. It tells you
what the project is, where it currently stands, which document is canonical, and
what decision is waiting next.

For current workspace usability work, read [docs/START_HERE.md](docs/START_HERE.md)
first. It is the active source of truth for the Guided AI Labs operating
workspace, with CRM treated as one operating card inside the broader card map.
The current cockpit inventory and gap list are in
[docs/COCKPIT_USABILITY_INVENTORY.md](docs/COCKPIT_USABILITY_INVENTORY.md)
and [docs/COCKPIT_CARD_GAP_LIST.md](docs/COCKPIT_CARD_GAP_LIST.md).
For fast agent/session restart across the wider M365 foundation, read
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

---

## What this project is

We are building **Microsoft 365 into a clean, governed operating substrate** for
AG Operations and Guided AI Labs — so that a future Agentic OS (built elsewhere)
can safely connect through scoped, audited access.

We are **not** building the Agentic OS here. We are building the foundation it
plugs into.

```text
Agentic OS  ->  governed bridge  ->  M365 touchpoint router  ->  correct M365 surface
```

Working principle: **classify intent first, then route to the right M365 surface**
(SharePoint for records, OneDrive for drafts, Teams for collaboration, Exchange
for comms, Planner/Lists for state, Entra for identity, Purview/Defender for
governance). Email is **not** the hub.

Important nuance: Microsoft 365 is not being treated as "just documentation and
email," and it is not being asked to become the entire central operating system.
It should be fully useful operational infrastructure in its own right: records,
tasks, decisions, conversations, approvals, and audit. The future Guided AI Labs
central OS and Graphify map can then integrate across M365, local/Linux
workspaces, repositories, products, and other systems.

---

## Where we are right now

The canonical execution plan is the **10-stage roadmap**:
[M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md).

| Stage | Name | Status |
|---|---|---|
| 0 | Setup Control Room | ✅ Done — env template, PS modules installed (current-user), inventory scripts |
| 1 | Current-State Inventory | ✅ Done — valid run `20260610-173554`, written report |
| 2 | Identity & Admin Foundation | ✅ Done 2026-06-11 — safety net (break-glass ×2), `contact@` admin stripped, re-inventory confirms target role matrix |
| 3 | SharePoint Information Architecture | ✅ Done 2026-06-12 — all 5 sites built (AG Operations, Guided AI Labs, Change Leadership Tools, Shared Libraries, Guided AI Journey) with Hybrid libraries + folders + 5 metadata columns, external sharing OFF; re-inventory PASS |
| 4 | OneDrive & Local Machine Dovetail | ✅ Done 2026-06-12 — operator identity `adamgoodwin@guidedailabs.com` connected to OneDrive (`Business2`); 3-lane Chrome model (Personal / Prime Boiler / **AI Labs** = operator) with imported SharePoint+admin bookmarks, verified loading the Stage-3 sites; known folders left on Personal (genuinely personal content), business drafts routed to `OneDrive - A.G. Operations Ltd`; 855 MB dead Chrome profile data deleted. Working doc: [M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md](M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md) |
| 5 | Exchange & Communication Routing | ✅ Design complete 2026-06-14 — inventory complete; `contact@` / `support@` stay licensed; no Exchange writes required now; aliases/groups/calendar/intake routing documented |
| **6** | **Teams, Planner, Lists & Operating State** | **✅ Live gate complete — Lists, Planner, Teams channels, and tabs provisioned/verified; onboarding readiness packet prepared** |
| **7** | **Security, Governance & External Sharing** | **Core guest/sharing governance applied, verified, and logged; app-grant resting state + support MFA remain closeout items** |
| **8** | **Client Workspace Reference Pattern** | **Current — workspace skeleton/backing live-verified; Operations Cockpit and CRM Command Center live; workspace usability Chunks 1-5 complete/pushed; next is Chunk 6 agentic readiness pass** |
| **9** | **Agentic OS Bridge Readiness** | **In progress — supervised coordinator/support List-write loops live-proven; future app posture still gated** |

**Live tenant changes so far:** Stage 2 identity safety net and role cleanup,
Stage 3 SharePoint site provisioning, Stage 4 local OneDrive/browser cleanup,
Stage 6 Lists/Planner/Teams provisioning, and Stage 7 guest/share-link governance
tightening. Each tenant write was gated, read-back-verified, and the Stage 7
governance batch is logged in the operating Lists. Stage 5 Exchange design
completed on 2026-06-14; no mailbox, alias, forwarding, calendar, or license
changes were needed. This remains a human-supervised setup, not
unattended automation.

**Authorization pattern:** when a tenant action needs Adam's credentials, MFA, or
approval, launch a visible interactive window and let Adam authorize there. Codex
can continue local analysis and documentation around that step, but hidden shells
should not sit waiting for private credentials.

---

## Document map

### Canonical plan (read these to know what to do)

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) — **canonical** staged
  execution order (Stages 0–9). This is the source of truth for *what happens next*.
- [M365_LOGIN_AND_ACCOUNT_GUIDE.md](M365_LOGIN_AND_ACCOUNT_GUIDE.md) — quick
  chart for which account to use, MFA/auth-code handling, Chrome profile lanes,
  and the recovery path when Microsoft account routing gets messy.
- [guided-ai-labs-m365-foundation-build-brief.md](guided-ai-labs-m365-foundation-build-brief.md)
  — comprehensive reference/design spec behind the roadmap (the "why" and the
  detailed target architecture). Defers to the roadmap for sequencing.

### Completed foundation stages

- [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
  — Stage 5 Exchange mailbox, alias, calendar, support/front-door routing, and
  durable-record capture decisions. **Design complete 2026-06-14; no tenant writes
  required now.** Live read-only inventory is captured under
  `inventory/stage-5-exchange-current-state/20260614-093257/`.
- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
  — draft bridge between Stage 5, Stage 6, and Stage 9: how `contact@` /
  `support@` become structured intake, tasks, records, central OS/Graphify
  references, and eventually a governed agentic workflow.

### Completed work — Stage 6 Teams, Planner, Lists & Operating State

- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
  — current working design for the Microsoft Lists, Planner buckets, Teams
  channels, first safe agent-assisted intake loop, and Stage 6 operating
  experience/look-and-feel.
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
  — alignment note after reviewing the Graphify Workspace Cockpit source package:
  M365 is the governed business substrate, Graphify is the decision intelligence
  layer, and UAOS owns future mission execution/adapters.
- [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
  — machine-readable Stage 6 schema for the first four Lists, intended views,
  Planner buckets, and Teams/channel/tab layout.
- [config/M365_FORMS_INTAKE_FEEDBACK_KIT.json](config/M365_FORMS_INTAKE_FEEDBACK_KIT.json)
  — machine-readable Forms intake/feedback kit for discovery intake, support,
  session feedback, and team retrospectives, with target List routing.
- [scripts/Invoke-M365Stage6ProvisionLists.ps1](scripts/Invoke-M365Stage6ProvisionLists.ps1)
  — **live write** (gated/idempotent): creates the four Stage 6 Microsoft Lists,
  columns, and first useful views from the schema. It does not create Teams,
  Planner, mailbox rules, sharing changes, guests, or automation.
- [scripts/Invoke-M365Stage6VerifyLists.ps1](scripts/Invoke-M365Stage6VerifyLists.ps1)
  — **read-only** Stage 6 verification for the Lists, fields, and views.
- [scripts/Start-M365Stage6ListsProvisioningInteractive.ps1](scripts/Start-M365Stage6ListsProvisioningInteractive.ps1)
  — launches the Stage 6 Lists provisioning or verification in a visible
  PowerShell/auth window so Adam can complete Microsoft sign-in/MFA and, for the
  live write, type the confirmation.
- [scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1](scripts/Invoke-M365Stage6EnsureSiteAdmins.ps1)
  — **live write already run 2026-06-14**: added `adamgoodwin@guidedailabs.com`
  as secondary site collection admin on the Guided AI Labs and Change Leadership
  Tools sites.
- [scripts/Test-M365Stage6PnPPermissions.ps1](scripts/Test-M365Stage6PnPPermissions.ps1)
  — **read-only** diagnostic for Stage 6 PnP/site permissions.
- [scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1](scripts/Show-M365Stage6PnPConsentReviewChecklist.ps1)
  — prints the safer Entra admin center consent-review checklist for
  `agent-pnp-provisioning`. It does not open a browser or raw consent URL.
- [inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md](inventory/stage-6-operating-state/STAGE_6_PROVISIONING_AUDIT.md)
  — concise audit of the Stage 6 provisioning attempts, confirmed changes,
  unauthorized-operation blocker, and consent-warning response.
- [inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md](inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md)
  — manual build guide for governed Microsoft Forms intake/support/feedback
  collection routed into the existing Stage 6 Lists.
- [inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md](inventory/stage-6-operating-state/onboarding-readiness/STAGE_6_ONBOARDING_READINESS_RUNBOOK.md)
  — Stage 6 readiness ladder, partner onboarding checklist, client-readiness
  checklist, training path, and scorecard for judging whether the operating
  cockpit is ready to use with a partner or first client.
- [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1)
  — **read-only** Exchange Online inventory: mailboxes, aliases, forwarding,
  delegates, Send As, groups, recipients, and calendar-processing posture. Run this
  before deciding any Stage 5 writes. Defaults to device-code authentication;
  add `-UseWam` only in a host where Exchange WAM auth works correctly.
- [scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1](scripts/Start-M365Stage5ExchangeInventoryInteractive.ps1)
  — launches the read-only Stage 5 inventory in a visible PowerShell/auth window
  so Adam can complete Microsoft sign-in or MFA, then runs the local summarizer.
- [scripts/Summarize-M365Stage5ExchangeInventory.ps1](scripts/Summarize-M365Stage5ExchangeInventory.ps1)
  — local post-processor that turns a completed Stage 5 inventory JSON folder into
  a Markdown current-state summary for decisions.

### Current work — Stage 7 Security, Governance & External Sharing

- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
  — Stage 7 working design for MFA/sign-in posture, admin-role review, app
  consent, guest access, external sharing, labels/retention, device sync, audit
  cadence, and agentic approval gates. Graph and SharePoint sharing inventory was
  captured before changes in `inventory/stage-7-security-governance/20260614-191812/`
  and verified after changes in `inventory/stage-7-security-governance/20260614-193825/`.
  The approved governance write was recorded in Decision Register item #1 and
  Agent Action Log item #1. The local-only review pack is
  `inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md`.
- [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json)
  — machine-readable Stage 7 baseline, read-only inventory scopes, and exit
  criteria.
- [scripts/Invoke-M365Stage7SecurityInventory.ps1](scripts/Invoke-M365Stage7SecurityInventory.ps1)
  — **read-only** Graph inventory for security/governance posture. It records
  partial-permission gaps as `*.error.json` instead of changing the tenant.
- [scripts/Start-M365Stage7SecurityInventoryInteractive.ps1](scripts/Start-M365Stage7SecurityInventoryInteractive.ps1)
  — launches the Stage 7 Graph read-only inventory in a visible PowerShell/auth
  window, using browser/WAM auth by default.
- [scripts/Invoke-M365Stage7SharePointSharingInventory.ps1](scripts/Invoke-M365Stage7SharePointSharingInventory.ps1)
  — **read-only** PnP inventory for SharePoint tenant/site sharing posture.
- [scripts/Start-M365Stage7SharePointSharingInventoryInteractive.ps1](scripts/Start-M365Stage7SharePointSharingInventoryInteractive.ps1)
  — launches the focused SharePoint sharing read-back in a visible auth window.
- [scripts/Invoke-M365Stage7GovernanceWriteWindow.ps1](scripts/Invoke-M365Stage7GovernanceWriteWindow.ps1)
  — dry-run-first, typed-approval operator for Stage 7 tenant policy changes.
- [scripts/Start-M365Stage7GovernanceWriteWindowInteractive.ps1](scripts/Start-M365Stage7GovernanceWriteWindowInteractive.ps1)
  — launches the Stage 7 governance write window in a visible auth window.
- [scripts/Invoke-M365Stage7RecordGovernanceDecision.ps1](scripts/Invoke-M365Stage7RecordGovernanceDecision.ps1)
  — writes the approved Stage 7 governance decision into Decision Register and
  Agent Action Log only.
- [scripts/Start-M365Stage7RecordGovernanceDecisionInteractive.ps1](scripts/Start-M365Stage7RecordGovernanceDecisionInteractive.ps1)
  — visible launcher for the Stage 7 governance decision record.
- [scripts/Invoke-M365Stage7GovernanceReviewPack.ps1](scripts/Invoke-M365Stage7GovernanceReviewPack.ps1)
  — local-only review generator for app grants, MFA gaps, and site sharing
  exceptions from saved inventory.
- [scripts/Invoke-M365Stage7AppGrantRestingStatePlan.ps1](scripts/Invoke-M365Stage7AppGrantRestingStatePlan.ps1)
  — local-only generator for the broad delegated app grant resting-state plan.
- [scripts/Invoke-M365Stage7SiteSharingExceptionWindow.ps1](scripts/Invoke-M365Stage7SiteSharingExceptionWindow.ps1)
  — dry-run-first, typed-approval operator for disabling root/legacy site
  sharing exceptions.
- [scripts/Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1](scripts/Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1)
  — visible launcher for the Stage 7 site sharing exception window.
- [scripts/Summarize-M365Stage7SecurityInventory.ps1](scripts/Summarize-M365Stage7SecurityInventory.ps1)
  — local post-processor for a completed Stage 7 inventory folder.
- [scripts/Test-M365Stage7LocalPreflight.ps1](scripts/Test-M365Stage7LocalPreflight.ps1)
  — local-only Stage 7 validation. Latest run passed and does not connect to
  Microsoft 365.
- [inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md](inventory/stage-7-security-governance/STAGE_7_LOCAL_PREFLIGHT.md)
  — latest Stage 7 local preflight report. The optional SharePoint Online
  Management Shell module is not installed, so `-IncludeSharePointAdmin` is a
  later optional enhancement.
- [inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md](inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md)
  — local-only review pack for app grant, MFA, and site sharing exception
  closeout.
- [inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md](inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md)
  — local-only app grant resting-state plan; no app grants revoked.
- [inventory/stage-7-security-governance/stage-7-site-sharing-exception-window-20260614-210942.log](inventory/stage-7-security-governance/stage-7-site-sharing-exception-window-20260614-210942.log)
  — approval-gated site sharing cleanup apply log; root, A.G. Operations Ltd,
  and All Company were disabled for external sharing.
- [inventory/stage-7-security-governance/20260614-193825/stage-7-sharepoint-sharing-20260614-211128.log](inventory/stage-7-security-governance/20260614-193825/stage-7-sharepoint-sharing-20260614-211128.log)
  — read-only SharePoint sharing verification after the cleanup apply.
- [inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md](inventory/stage-7-security-governance/STAGE_7_CLOSEOUT_ACTION_PLAN.md)
  — remaining Stage 7 closeout sequence for support MFA, app grants, and
  root/legacy site sharing.

### Current work — Workspace Usability, Stage 8/9 Reference Pattern & Bridge Readiness

- [M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md)
  — planning baseline adapted from the local Prime Operations SharePoint
  Workspace reference: page/navigation shape, Lists/libraries, permission zones,
  and build sequence for a Guided AI Labs operating command center.
- [config/M365_STAGE_8_WORKSPACE_SHAPE.json](config/M365_STAGE_8_WORKSPACE_SHAPE.json)
  — machine-readable Stage 8 page, navigation, List, library, and approval-gate
  shape for the Guided AI Labs command center.
- [config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json](config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json)
  — machine-readable Stage 8 backing pages, Lists, libraries, folders, and
  navigation targets for the Guided AI Labs command center.
- [scripts/New-M365Stage8WorkspaceShapePacket.ps1](scripts/New-M365Stage8WorkspaceShapePacket.ps1)
  — local-only generator for the Stage 8 workspace shape build guide and CSV
  maps.
- [scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1](scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1)
  — dry-run-first, typed-approval operator for creating the Guided AI Labs
  command-center page skeleton and resolvable SharePoint quick-launch links.
- [scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1)
  — visible launcher for the Stage 8 workspace shape build.
- [scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1)
  — read-only verifier for expected Stage 8 pages and resolvable quick-launch
  links.
- [scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1)
  — visible launcher for the Stage 8 page/navigation verification.
- [scripts/Test-M365Stage8LocalPreflight.ps1](scripts/Test-M365Stage8LocalPreflight.ps1)
  — local-only Stage 8 validation for config, scripts, generated packet, and
  PnP page/navigation command availability.
- [inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md)
  — generated Stage 8 page/navigation/List/library build guide; no tenant
  writes.
- [inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md)
  — read-back verification for the live Stage 8 page/navigation skeleton; latest
  result is PASS.
- [scripts/New-M365Stage8WorkspaceBackingPacket.ps1](scripts/New-M365Stage8WorkspaceBackingPacket.ps1)
  — local-only generator for the Stage 8 backing-structure build guide and CSV
  maps.
- [scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1](scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1)
  — dry-run-first, typed-approval operator for creating Stage 8 backing pages,
  Lists, libraries, folders, and remaining quick-launch links.
- [scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1)
  — read-only verifier for Stage 8 backing pages, Lists, fields, views,
  libraries, folders, and navigation targets.
- [inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md](inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md)
  — read-back verification for the live Stage 8 backing structure; latest result
  is PASS.
- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
  — planned client workspace reference pattern: client-vs-GAL tenant ownership,
  discovery inputs, workspace components, handoff packet, and safety gates.
- [M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md)
  — Stage 8 boundary note aligning SharePoint page refinement with the UAOS
  cockpit repo, Graphify Workspace Cockpit, and the Prime Operations reference.
- [config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json)
  — machine-readable Guided AI Labs Command Center homepage refinement: six
  command cards, Active Work Snapshot, Client Pathway Snapshot, Operational
  Readiness dashboard runway, and draft-first live gate.
- [scripts/New-M365Stage8HomepageRefinementPacket.ps1](scripts/New-M365Stage8HomepageRefinementPacket.ps1)
  — local-only homepage refinement packet and static preview generator.
- [scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1](scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1)
  — dry-run-first, typed-approval operator that can create the command-center
  draft review page without replacing the current homepage.
- [scripts/Start-M365Stage8HomepageRefinementInteractive.ps1](scripts/Start-M365Stage8HomepageRefinementInteractive.ps1)
  — visible launcher for the homepage refinement draft builder.
- [scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1](scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1)
  — read-only verifier for the command-center draft page and current-homepage
  safety check.
- [scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1](scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1)
  — visible launcher for the homepage refinement verifier.
- [inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md)
  — generated build guide for the homepage refinement layer.
- [scripts/Set-GuidedAILabsOperationsPortal.ps1](scripts/Set-GuidedAILabsOperationsPortal.ps1)
  — live cleanup operator that created the Guided AI Labs Operations Cockpit,
  set it as the site homepage, removed duplicate daily CRM nav links, embedded
  the four live attention queues, and left `App Grants` as governance rather
  than a live agent connection.
- [docs/COCKPIT_USABILITY_INVENTORY.md](docs/COCKPIT_USABILITY_INVENTORY.md)
  — Chunk 2 local evidence output categorizing the current cockpit cards,
  queues, page links, known navigation, superseded surfaces, and controlled
  governance/admin surfaces.
- [docs/COCKPIT_CARD_GAP_LIST.md](docs/COCKPIT_CARD_GAP_LIST.md)
  — Chunk 2 gap list for broad labels, controlled Tools/App Grants surfaces,
  missing card runbooks, Knowledge/Records visibility, and Access/Onboarding.
- [docs/CARD_PLAN_TEMPLATE.md](docs/CARD_PLAN_TEMPLATE.md)
  — Chunk 3 reusable card-plan structure for operating-card deep dives.
- [docs/CARD_PLAN_INDEX.md](docs/CARD_PLAN_INDEX.md)
  — Chunk 5 card-plan index with active plan routing for all ten operating
  cards.
- [docs/CARD_PLAN_WORKSPACE_HOME.md](docs/CARD_PLAN_WORKSPACE_HOME.md)
  — Chunk 5 Workspace Home front-door plan.
- [docs/CARD_PLAN_CRM_RELATIONSHIPS.md](docs/CARD_PLAN_CRM_RELATIONSHIPS.md)
  — Chunk 3 first applied card-plan example for CRM / Relationships.
- [docs/CARD_PLAN_DELIVERY_PROJECTS.md](docs/CARD_PLAN_DELIVERY_PROJECTS.md)
  — Chunk 5 Delivery / Projects plan.
- [docs/CARD_PLAN_DECISIONS_GOVERNANCE.md](docs/CARD_PLAN_DECISIONS_GOVERNANCE.md)
  — Chunk 5 Decisions / Governance plan.
- [docs/CARD_PLAN_TASKS_ACTIONS.md](docs/CARD_PLAN_TASKS_ACTIONS.md)
  — Chunk 5 Tasks / Actions plan.
- [docs/CARD_PLAN_KNOWLEDGE_RECORDS.md](docs/CARD_PLAN_KNOWLEDGE_RECORDS.md)
  — Chunk 5 Knowledge / Records plan.
- [docs/CARD_PLAN_SUPPORT_INTAKE.md](docs/CARD_PLAN_SUPPORT_INTAKE.md)
  — Chunk 5 Support / Intake plan.
- [docs/CARD_PLAN_FINANCE_CLOSEOUT.md](docs/CARD_PLAN_FINANCE_CLOSEOUT.md)
  — Chunk 5 Finance / Closeout plan.
- [docs/CARD_PLAN_AGENT_CONTROL_PLANE.md](docs/CARD_PLAN_AGENT_CONTROL_PLANE.md)
  — Chunk 5 Agent Control Plane plan.
- [docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md](docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md)
  — Chunk 4 role tiers, operating-card access matrix, first-day onboarding
  walkthrough, escalation rules, and admin-only authority boundary.
- [inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260615-161438.md](inventory/gail-sharepoint-portal/GAIL_OPERATIONS_PORTAL_20260615-161438.md)
  — read-back evidence for the Guided AI Labs homepage cockpit; extra CRM nav
  count is 0 and homepage is `Guided-AI-Labs-Operations-Cockpit.aspx`.
- [M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md)
  — Stage 8A relationship CRM model: Organizations, Contacts, Engagements,
  Stakeholder Map, Touchpoints, Lifecycle Checklist, offer-package path,
  onboarding/offboarding, and future custom CRM migration hooks.
- [config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json)
  — machine-readable Stage 8A CRM Lists, fields, views, Relationship CRM page,
  navigation target, workflows, Teams-tabs-later map, and approval gate.
- [scripts/New-M365Stage8ARelationshipCrmPacket.ps1](scripts/New-M365Stage8ARelationshipCrmPacket.ps1)
  — local-only generator for the Stage 8A CRM build guide and CSV maps.
- [scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1](scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1)
  — dry-run-first, typed-approval operator for creating the Stage 8A CRM Lists,
  fields, views, Relationship CRM page, and Client Delivery navigation link.
- [scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1](scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1)
  — visible launcher for the Stage 8A CRM build.
- [scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1](scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1)
  — read-only verifier for the Stage 8A CRM Lists, fields, views, page, and
  navigation link.
- [scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1](scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1)
  — visible launcher for the Stage 8A CRM verifier.
- [scripts/Test-M365Stage8ALocalPreflight.ps1](scripts/Test-M365Stage8ALocalPreflight.ps1)
  — local-only Stage 8A validation for config, scripts, generated packet, and
  PnP command availability.
- [M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md](M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.md)
  — Stage 8B operational hardening layer for lookup-backed CRM relationships,
  daily queues, due dates, risk/health fields, filtered views, and an operations
  cockpit page.
- [config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json](config/M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json)
  — machine-readable Stage 8B CRM operations config.
- [scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1](scripts/Invoke-M365Stage8BRelationshipCrmOperationalize.ps1)
  — dry-run-first, typed-approval operator for Stage 8B CRM operational fields,
  lookup columns, filtered views, operations page, and navigation.
- [scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1](scripts/Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1)
  — visible launcher for the Stage 8B CRM operations apply.
- [scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1](scripts/Invoke-M365Stage8BVerifyRelationshipCrmOperations.ps1)
  — read-only verifier for Stage 8B CRM operational readiness.
- [scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1](scripts/Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1)
  — visible launcher for the Stage 8B verifier.
- [inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md](inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md)
  — generated Stage 8B local build guide.
- [inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md](inventory/stage-8b-relationship-crm-operations/STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_VERIFY.md)
  — Stage 8B live read-back verification summary; result PASS.
- [M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md](M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md)
  — Stage 8C operator workflow layer for CRM action queue, qualification,
  meeting notes, artifacts, health reviews, and command-center page; 2026-06-17
  production refresh adds a visible command-center CRM stage path and simplified
  intake form.
- [config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json](config/M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json)
  — machine-readable Stage 8C CRM operator workflow config.
- [scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1](scripts/Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1)
  — dry-run-first, typed-approval operator for Stage 8C CRM workflow lists,
  lookup columns, filtered views, command-center page refresh, and navigation.
- [scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1](scripts/Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1)
  — visible launcher for the Stage 8C CRM workflow apply.
- [scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1](scripts/Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1)
  — read-only verifier for Stage 8C CRM operator workflow readiness.
- [scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1](scripts/Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1)
  — visible launcher for the Stage 8C verifier.
- [inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md](inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md)
  — generated Stage 8C local build guide.
- [inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-command-center-stage-path.csv](inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-command-center-stage-path.csv)
  — generated command-center stage path: intake, qualification, engagement
  pipeline, decision/proposal, active delivery, and handoff evidence.
- [inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-frictionless-intake-map.csv](inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-frictionless-intake-map.csv)
  — generated map for the simplified intake form labels, quick sections, and
  read-only source/system fields.
- [inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md](inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md)
  — Stage 8C live read-back verification summary; result PASS.
- [M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md](M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md)
  — Stage 8D walkthrough/proof layer for proving the daily path from intake to
  handoff evidence; internal production proof records are live-recorded and
  read-back verified.
- [config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json](config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json)
  — machine-readable Stage 8D browser/manual walkthrough config.
- [scripts/New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1](scripts/New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1)
  — local-only generator for the Stage 8D walkthrough guide, CSV maps,
  capture template, and findings starter.
- [scripts/Test-M365Stage8DLocalPreflight.ps1](scripts/Test-M365Stage8DLocalPreflight.ps1)
  — local-only Stage 8D validation for config, scripts, and generated packet.
- [scripts/Invoke-M365Stage8DWorkflowProof.ps1](scripts/Invoke-M365Stage8DWorkflowProof.ps1)
  — approval-gated production operator that creates/updates one clearly
  labelled internal dummy workflow chain across intake, CRM, actions, lifecycle,
  artifact evidence, and Agent Action Log.
- [inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md](inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md)
  — generated Stage 8D walkthrough guide; no tenant writes.
- [inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv](inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv)
  — browser/manual run capture worksheet with one row per workflow step.
- [inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv](inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv)
  — starter register for navigation, list/view, ownership, evidence, automation,
  policy, and training/page-copy findings.
- [inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-readback-20260617-121052.csv](inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-proof-readback-20260617-121052.csv)
  — read-back evidence for the Stage 8D internal production workflow proof;
  steps 8d-01 through 8d-07 pass.
- [inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_LOCAL_PREFLIGHT.md](inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_LOCAL_PREFLIGHT.md)
  — Stage 8D local preflight summary; result PASS.
- [inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md)
  — generated Stage 8A CRM build guide; no tenant writes.
- [inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md)
  — Stage 8A CRM live read-back verification summary; result PASS.
- [M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md](M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md)
  — M365/Graphify/UAOS bridge readiness: adapter surface map,
  read/propose/write categories, app posture, action logging, stop/rollback
  rules, low-risk bridge-loop exit criteria, and current bridge control packet.
- [config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json](config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json)
  — machine-readable Stage 9 readiness control model for adapter contracts, app
  posture choices, risk controls, and graduation gates.
- [scripts/New-M365Stage9BridgeReadinessControlPacket.ps1](scripts/New-M365Stage9BridgeReadinessControlPacket.ps1)
  — local-only generator for the Stage 9 bridge readiness guide and worksheets.
- [scripts/Test-M365Stage9BridgeReadinessControlPreflight.ps1](scripts/Test-M365Stage9BridgeReadinessControlPreflight.ps1)
  — local-only validation for the Stage 9 bridge readiness control packet.
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md)
  — generated Stage 9 bridge control guide plus live posture evidence
  references; generator itself performs no tenant writes.
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-adapter-contract.csv](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-adapter-contract.csv)
  — read/write boundary contract for each candidate M365 bridge surface.
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv)
  — decision worksheet for staying delegated, using Selected permissions,
  Exchange Application RBAC, a later mixed adapter, or rejecting setup-helper
  reuse.
- [inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_PREFLIGHT.md](inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_PREFLIGHT.md)
  — Stage 9 bridge readiness preflight summary; result PASS.
- [inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-bridgereadinesscontrol-20260617-084614.log](inventory/stage-9-agentic-os-bridge/stage-9-agent-capability-loop-bridgereadinesscontrol-20260617-084614.log)
  — live Stage 9 bridge readiness control apply transcript; Decision Register
  item `#3` and Agent Action Log item `#5`.
- [inventory/stage-9-agentic-os-bridge/stage-9-bridge-readiness-control-readback-20260617-084643.log](inventory/stage-9-agentic-os-bridge/stage-9-bridge-readiness-control-readback-20260617-084643.log)
  — read-back verification transcript for Decision Register `#3` and Agent
  Action Log `#5`.

- [M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md) —
  Stage 2 account role matrix, target identity model, break-glass plan, role
  reduction sequence, decision log, and execution log. **Complete 2026-06-11.**
- [M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md](M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md)
  — Stage 3 SharePoint information architecture and provisioning log.
  **Complete 2026-06-12.**
- [M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md](M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md)
  — Stage 4 OneDrive/local/browser lane model. **Complete 2026-06-12.**

- [IDENTITY_NAMING_STANDARD.md](IDENTITY_NAMING_STANDARD.md) — the legend: every
  identity type, what it means, its naming pattern, and how much power it may hold.
- [scripts/Invoke-M365Stage2Verify.ps1](scripts/Invoke-M365Stage2Verify.ps1) —
  **read-only** Level-1 verification: signs you in (device-code, your MFA) and
  prints the live role matrix + Stage 2 plan checks. Changes nothing. Run this
  first to watch the visible-execution loop before any write.
- [scripts/Invoke-M365Stage2CreateBreakglass.ps1](scripts/Invoke-M365Stage2CreateBreakglass.ps1)
  — **live write** (idempotent): creates `breakglass-01/02` and assigns Global
  Administrator. Ran 2026-06-11; re-runs safely skip existing accounts.

### Current state (read these to know what exists)

- [M365_STAGE_1_CURRENT_STATE_INVENTORY.md](M365_STAGE_1_CURRENT_STATE_INVENTORY.md)
  — written summary of the tenant as it exists today.
- [inventory/stage-1-current-state/20260610-173554/](inventory/stage-1-current-state/20260610-173554/)
  — the **valid** raw inventory data. (The `20260610-172735` and `-173346`
  folders are failed runs — ignore them; each has a `FAILED_RUN_NOTE.md`.)

### Tooling & licensing

- [TOOLING_AND_LICENSING.md](TOOLING_AND_LICENSING.md) — are our tools optimum, and
  which free licenses save time/tokens. **Headline: apply to Microsoft for Startups
  Founders Hub as Guided AI Labs → possible free Business Premium + Azure credits;
  turn on free Security Defaults MFA now; stay API-first (Graph).**

### Reference & access

- [M365_API_ACCESS_START_HERE.md](M365_API_ACCESS_START_HERE.md) — Microsoft
  Graph / Entra access model; delegated read-only first.
- [M365_ENVIRONMENT.template.env](M365_ENVIRONMENT.template.env) — tenant/app
  constants (no secrets). Copy to `M365_ENVIRONMENT.local.env` for any private
  values; that filename is git-ignored.
- [scripts/Invoke-M365Stage1InventoryRest.ps1](scripts/Invoke-M365Stage1InventoryRest.ps1)
  — **preferred** inventory script (Graph REST + device-code auth).
- [scripts/Invoke-M365Stage1Inventory.ps1](scripts/Invoke-M365Stage1Inventory.ps1)
  — older Graph PowerShell SDK attempt; kept for reference, not preferred.

### Local-machine track (Stage 4 inputs — see reconciliation below)

- [README.md](README.md) — original local folder/lane structure (2026-05-25).
- [M365_SHAREPOINT_ONENOTE_SPLIT.md](M365_SHAREPOINT_ONENOTE_SPLIT.md) — context-
  separation philosophy (identity / cloud home / working surface / local cache).
- [NEXT_SESSION_CHECKLIST.md](NEXT_SESSION_CHECKLIST.md) — local cleanup checklist
  (OneDrive/Chrome/OneNote/sync). **Stage 4 is complete; this remains historical
  input/reference, not the current step.**
- [SYSTEM_NOTES_FROM_INITIAL_DIG.md](SYSTEM_NOTES_FROM_INITIAL_DIG.md) — machine
  findings from the first pass.
- [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md)
  — desktop Office license/identity conflict notes, now including the 2026-06-15
  browser-profile/WAM inventory and the new Chrome `City of Red Deer` lane.

### Session history

- [SESSION_TURNOVER_2026-06-19.md](SESSION_TURNOVER_2026-06-19.md) — **most recent**
  handoff: workspace usability Chunks 1-5 are complete and pushed; card template,
  CRM card-plan example, access/onboarding model, and the Chunk 5 card plans are
  in place; next step is Chunk 6, Agentic M365 Readiness Pass.
- [SESSION_TURNOVER_2026-06-18.md](SESSION_TURNOVER_2026-06-18.md)
  — workspace usability Chunk 2 is complete and pushed; cockpit cards, queues,
  links, and navigation are categorized from local evidence.
- [SESSION_TURNOVER_2026-06-17.md](SESSION_TURNOVER_2026-06-17.md) — Stage 8D
  walkthrough capture packet and Stage 9 bridge readiness control packet are
  local-generated/preflighted, and the Stage 9 bridge posture is
  live-recorded/read-back verified.
- [SESSION_TURNOVER_2026-06-15.md](SESSION_TURNOVER_2026-06-15.md) —
  handoff: Stage 8 workspace skeleton/backing structure are live-built and
  verified; command-center homepage refinement is locally prepared; next live
  step is draft-only page creation plus read-only verification.
- [SESSION_TURNOVER_2026-06-14.md](SESSION_TURNOVER_2026-06-14.md) — Stage 5/6/7
  transition history, including Exchange inventory, Stage 6 provisioning audit,
  and early Stage 6 authorization issues. Now historical because Stages 6-8 have
  advanced.
- [SESSION_TURNOVER_2026-06-12.md](SESSION_TURNOVER_2026-06-12.md) — Stage 5
  started, Exchange routing doc + read-only inventory runner added.
- [SESSION_TURNOVER_2026-06-11.md](SESSION_TURNOVER_2026-06-11.md) — dated
  handoff after audit + consolidation + git/GitHub setup; now historical because
  Stages 2-4 have since completed.
- [SESSION_TURNOVER_2026-06-10.md](SESSION_TURNOVER_2026-06-10.md) — handoff from
  the 2026-06-10 session (Stage 1 inventory).

---

## The two tracks, reconciled

This workspace grew in two waves:

- **Local-machine track** (May 25–27): keep one laptop usable across Personal,
  AG Operations, Prime Boiler, City of Red Deer without blending accounts, files,
  notebooks, or browser sessions.
- **Tenant-foundation track** (June 10 →): build M365 as the governed substrate
  for AG Operations / Guided AI Labs and the future Agentic OS.

**Decision (2026-06-11): they are one project, sequenced through the roadmap.**
The local-machine track is the practical, device-side half of **Stage 4 — OneDrive
& Local Machine Dovetail**. Its documents stay as Stage 4 inputs and are not the
current step. The roadmap is canonical for ordering.

---

## Open decisions / blockers

Carry these forward; resolve at the noted stage.

1. ~~**License identity.**~~ **RESOLVED 2026-06-11.** The raw SKU
   `O365_BUSINESS_PREMIUM` (GUID `f245ecc8-75af-4f8e-b61f-27d8114de5f3`) maps to
   **Microsoft 365 Business Standard** per Microsoft's published licensing
   reference — a legacy-naming trap; the *actual* Business Premium SKU is `SPB`,
   which the tenant does NOT have. Implication: no Intune / Defender for Business /
   Entra ID P1, so **Business Premium is a genuine Stage 7 upgrade decision**, not
   a maybe. (4 of 25 seats consumed.)
2. **Stage 1 summary-script patch is unverified.** `summary.json` for the valid
   run was hand-built after the script crashed at summary generation; the patch
   was syntax-checked but not confirmed by a clean re-run.
3. ~~**Break-glass admin plan (Stage 2).**~~ **DONE 2026-06-11:** create **two**
   emergency-access accounts (`breakglass-01/02@…onmicrosoft.com`), cloud-only GA,
   credentials offline. Plan in
   [M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md) §4.
   Execution complete and verified.
4. ~~**`contact@guidedailabs.com` is a Global Administrator (Stage 2).**~~
   **DONE 2026-06-11:** stripped Global Admin + Global Reader + AI Admin; keep it a
   low-privilege mailbox; future agentic capability comes via a scoped app
   registration at Stage 9 (interaction surface ≠ capability surface).
   Mailbox type remains a Stage 5 decision.
5. **`adamgoodwin@…` keeps Global Admin (Stage 2, accepted risk).** Adam chose to
   keep his daily identity as primary admin; managed by MFA + consent discipline,
   revisit just-in-time elevation at Stage 7 if Business Premium/Entra P1–P2 lands.

### Governance review backlog (raised 2026-06-12 — Adam to review)

6. **Provisioning app resting state.** `agent-pnp-provisioning` holds delegated
   `AllSites.FullControl` + `Group.ReadWrite.All`, consented and now **idle** after
   Stage 3. Decide: disable / revoke consent until the next provisioning stage
   (recommended) vs. leave consented. A broad-write app sitting idle is exactly what
   the naming standard's "capability ≠ interaction" principle cautions against.
7. **Untested rollback.** Stage 3 reversibility ("delete the site") is asserted but
   was never validated. Low stakes on empty sites; note before relying on it.
8. **Tooling-app naming gap.** The `agent-` prefix was used for a human-triggered
   *tooling* app; consider adding a `tool-`/`setup-` prefix to the naming standard.
9. **All writes run as the daily-driver GA** (`adamgoodwin@`) — compounds the accepted
   Stage 2 risk. Revisit with JIT/PIM at Stage 7 if Entra P1/P2 lands.
10. ~~**Stage 5 mailbox posture.**~~ **RESOLVED 2026-06-14:** read-only Exchange
    inventory is complete; `contact@` and `support@` remain licensed user
    mailboxes for now to preserve direct sign-in, calendar, and future scoped
    automation options.
11. **Guided AI Labs agentic intake model.** Draft model exists; next step is Stage
    6 operating-state design for intake/support Lists, Planner tasks, Teams
    channels, and an Agent Action Log.

---

## Working across laptops (git)

This workspace is a **private** GitHub repo:
`https://github.com/Adamgdwn/ag-operations-m365-foundation` (kept private because
it contains tenant identity and admin-role data — never make it public).

On a new laptop, clone once:

```powershell
gh repo clone Adamgdwn/ag-operations-m365-foundation
```

Then, every session, to avoid the two laptops diverging:

```text
git pull    # at the START of a session, before changing anything
git push    # at the END, after committing your work
```

Secrets stay out of git automatically: `*.local.env` and token caches are listed
in `.gitignore`. Keep real secrets only in `M365_ENVIRONMENT.local.env` (ignored),
never in the committed `M365_ENVIRONMENT.template.env`.

## How to resume next session

1. Read this index.
2. Open [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md).
3. Open [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)
   as the design context for why these operating surfaces exist.
4. Review [config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json](config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json)
   as the exact List/Planner/Teams schema behind the Stage 6 design.
5. Lists are already provisioned and verified. Use read-back with:
   `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify`.
6. Planner/Teams is provisioned and verified. Use read-back after any manual
   change with:
   `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify`.
7. Use the onboarding readiness packet before adding a partner or shaping first
   client onboarding:
   `inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md`.
8. Stage 7 local preflight is ready:
   `.\scripts\Test-M365Stage7LocalPreflight.ps1`.
9. Stage 7 read-only live inventory is ready when Adam can sign in:
   `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1`.
10. Use [M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md)
   and the generated inventory summary only as Stage 5 reference.
11. Then run the first supervised agent loop from
   `inventory\stage-6-operating-state\first-run-packet\`.
