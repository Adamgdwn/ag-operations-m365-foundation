# Microsoft 365 Stage 8 - Client Workspace Reference Pattern

Status: **in progress - backing structure and Stage 8A CRM live-built and
verified** (2026-06-15).

Stage 8 turns the Guided AI Labs / AG Operations foundation into a repeatable
client workspace pattern. This is where the internal build becomes something Adam
can confidently explain, teach, and adapt for a business partner or client.

Related:

- [M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md)
- [config/M365_STAGE_8_WORKSPACE_SHAPE.json](config/M365_STAGE_8_WORKSPACE_SHAPE.json)
- [config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json](config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json)
- [scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1](scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1)
- [scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1)
- [scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1)
- [scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1](scripts/Invoke-M365Stage8WorkspaceBackingBuild.ps1)
- [scripts/Start-M365Stage8WorkspaceBackingBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceBackingBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceBacking.ps1)
- [scripts/Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1)
- [config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json)
- [M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md)
- [config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json)
- [scripts/New-M365Stage8HomepageRefinementPacket.ps1](scripts/New-M365Stage8HomepageRefinementPacket.ps1)
- [scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1](scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1)
- [scripts/Start-M365Stage8HomepageRefinementInteractive.ps1](scripts/Start-M365Stage8HomepageRefinementInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1](scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1)
- [scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1](scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1)
- [scripts/New-M365Stage8ARelationshipCrmPacket.ps1](scripts/New-M365Stage8ARelationshipCrmPacket.ps1)
- [scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1](scripts/Invoke-M365Stage8ARelationshipCrmBuild.ps1)
- [scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1](scripts/Start-M365Stage8ARelationshipCrmBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1](scripts/Invoke-M365Stage8AVerifyRelationshipCrm.ps1)
- [scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1](scripts/Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1)
- [scripts/Test-M365Stage8ALocalPreflight.ps1](scripts/Test-M365Stage8ALocalPreflight.ps1)
- [scripts/Test-M365Stage8LocalPreflight.ps1](scripts/Test-M365Stage8LocalPreflight.ps1)
- [inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md)
- [inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md)
- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md)
- [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md)

---

## 1. Goal

Define a client-ready Microsoft 365 workspace pattern that can answer:

```text
where client-owned records live
where Guided AI Labs working notes live
where collaboration happens
how decisions and tasks are tracked
who owns access after the engagement ends
what future AI can safely read or write
```

Stage 8 is not a one-off client folder. It is the reference pattern for how
Guided AI Labs teaches and delivers clean Microsoft 365 operating infrastructure.

The internal SharePoint shape should follow the command-center pattern captured
in [M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md](M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md):
pages route humans, Lists hold operating state, libraries hold files/evidence,
permissions create safety, and navigation creates usability.

The page refinement layer should also follow
[M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md):
SharePoint is the governed business workspace and client-delivery surface,
UAOS owns request/mission/approval/validation/learning mechanics, and Graphify
owns knowledge lookup, recommendations, and handoff records.

Homepage command-card decision:

```text
New Intake
Active Delivery
Decisions Needed
Client Readiness
Automation And Agents
Handoffs And Evidence
```

Use these as compact operating-state doors, not broad marketing tiles.

Homepage refinement build packet:

- [config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json)
- [inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md)
- [inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html](inventory/stage-8-client-workspace-reference/homepage-refinement/stage-8-command-center-preview.html)

The apply operator is draft-first only. It can create
`Guided-AI-Labs-Command-Center-Draft.aspx` after the approval phrase
`create-stage-8-command-center-draft`. It does not replace the current homepage
or change navigation, permissions, sharing, guests, app grants, public Forms,
deletion, or automation.

After the draft page is created, verify it with:

```powershell
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

The verifier is read-only. It checks that the draft page exists, has the
expected command-center title/markers, and that the draft has not become the
current homepage.

Stage 8A Relationship CRM build packet:

- [M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md](M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md)
- [config/M365_STAGE_8A_RELATIONSHIP_CRM.json](config/M365_STAGE_8A_RELATIONSHIP_CRM.json)
- [inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md)

Stage 8A was live-applied and read-back verified on 2026-06-15. It created six
CRM Lists, the Relationship CRM page, CRM views, and one Client Delivery
navigation link after the approval phrase `apply-stage-8a-relationship-crm`. It
did not create Dynamics, Dataverse, permissions, guests, sharing, app grants,
public Forms, mail sends, deletes, or unattended automation.

Verification summary:

- [inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md](inventory/stage-8a-relationship-crm/STAGE_8A_RELATIONSHIP_CRM_VERIFY.md)

---

## 2. Operating Principle

The core rule:

```text
Client-owned work should default to the client tenant unless there is a clear
business reason for Guided AI Labs to host it.
```

Guided AI Labs may hold discovery notes, delivery working material, templates,
methods, and internal operating records. Client-owned durable records should
usually live where the client can govern them after the engagement closes.

Stage 8 turns this into a repeatable decision instead of a judgment call made in
the middle of a project.

Local automation now supports a dry-run-first SharePoint page/navigation build:

```powershell
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1
```

The live apply path requires the visible-window approval phrase:

```text
apply-stage-8-workspace-shape
```

The operator creates missing modern pages and adds resolvable navigation links.
It does not change permissions, invite guests, widen sharing, revoke app grants,
publish public Forms, delete pages, overwrite existing pages, or create
client-facing automation.

Live apply evidence:

- apply log:
  `inventory/stage-8-client-workspace-reference/workspace-shape/stage-8-workspace-shape-build-20260614-213203.log`
- read-back verification:
  `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`
- latest result: PASS

The live skeleton currently includes 14 modern pages, the Stage 6 operating
Lists, 5 Stage 8 backing Lists, 5 new Stage 8 document libraries, the existing
Archive library with Stage 8 archive folders, and all planned quick-launch links.

Stage 8 backing structure was applied with the approval phrase:

```text
apply-stage-8-backing-structure
```

Live apply and verification evidence:

- apply log:
  `inventory/stage-8-client-workspace-reference/workspace-backing-structure/stage-8-workspace-backing-build-20260614-220231.log`
- read-back verification:
  `inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md`
- latest result: PASS

---

## 3. Workspace Models

| Model | When to use | Ownership posture |
|---|---|---|
| Client tenant first | Client has Microsoft 365 and will own durable records | Client owns records, GAL advises/builds |
| GAL-hosted light workspace | Early discovery, small client, no client M365 readiness yet | GAL hosts temporarily with exit/handoff plan |
| Hybrid delivery workspace | Client records stay client-side; GAL keeps methods/internal delivery state | Split by ownership and sensitivity |
| Internal partner workspace | Business partner joins GAL operations before client delivery | GAL-owned, Stage 7 guest/partner rules apply |

Default recommendation:

```text
Use client tenant first for client-owned records. Use GAL tenant for Guided AI
Labs delivery operations, reusable methods, and internal decisions.
```

---

## 4. Reference Workspace Components

| Component | Purpose | Owner |
|---|---|---|
| Relationship CRM | Organizations, contacts, engagements, touchpoints, onboarding/offboarding, and next actions | GAL |
| Client discovery form | Structured intake/readiness information | GAL or client, depending on collection path |
| Client readiness checklist | Current-state review of identity, files, comms, collaboration, and AI readiness | GAL |
| Client workspace map | Simple visual/index of where records, tasks, decisions, and conversations live | Client/GAL jointly |
| Client delivery library | Durable project documents and deliverables | Usually client |
| Delivery task plan | Action-bearing work and follow-up | Usually GAL during delivery |
| Decision register | Scope, access, approvals, risks, and commitments | Client/GAL jointly, copied where needed |
| Handoff packet | Ownership, links, admin notes, training path, and next review date | Client |

The Stage 6 Forms kit and Lists become reusable templates, not mandatory client
infrastructure. The pattern should adapt to client maturity.

---

## 5. Client Discovery Inputs

Before building or recommending a client workspace, capture:

| Area | Questions |
|---|---|
| Identity | Who owns the tenant, admin roles, MFA, guest access, and recovery? |
| Records | Where do official documents live today? What must remain client-owned? |
| Collaboration | Where do teams currently talk, meet, and make decisions? |
| Email/intake | Which addresses are true business front doors? |
| Tasks | How does work become assigned, tracked, and closed? |
| External sharing | Who needs access, for how long, and to what? |
| AI readiness | What can AI read, propose, write, or never touch? |
| Handoff | What should the client be able to run without GAL? |

This discovery should be form-backed where practical, then summarized into a
human-readable workspace recommendation.

---

## 6. Build Pattern

Recommended sequence:

1. Confirm Stage 7 governance gates are satisfied.
2. Decide tenant ownership: client tenant, GAL tenant, or hybrid.
3. Create the client workspace map before creating sprawl.
4. Create only the minimum working surfaces:
   - records home;
   - collaboration home;
   - task/decision surface;
   - intake/feedback surface if useful.
5. Add permissions by named people/groups, not broad links.
6. Test with one real workflow.
7. Produce the handoff packet before calling the workspace done.

No client workspace should be considered complete unless the client can explain
where to find records, decisions, tasks, and ownership information.

---

## 7. Safety And Governance Gates

Human approval is required before:

- inviting a client or partner guest;
- enabling or widening external sharing;
- publishing public or unauthenticated Forms links;
- copying client records into the GAL tenant;
- granting agent/app access to client data;
- creating a client-facing automation;
- changing a client tenant setting;
- making a representation that a workspace is compliant or secure.

Stage 8 should inherit the Stage 7 rule:

```text
External access is a named business exception, not a default convenience.
```

---

## 8. Client Handoff Packet

Each completed client workspace should have a handoff packet containing:

| Section | Contents |
|---|---|
| Workspace map | Links to records, collaboration, tasks, decisions, and forms |
| Ownership | Who owns tenant/admin/access/records after handoff |
| Permissions | Named guests, groups, sharing links, review date |
| Operating rhythm | Intake, triage, task, decision, and review cadence |
| AI boundary | What AI may read/propose/write, and what requires approval |
| Training | Short walkthrough and role-specific notes |
| Closeout | Archive/export plan, offboarding steps, and next review |

The handoff packet is part of the product. Without it, the setup is not finished.

---

## 9. Stage Exit Criteria

Stage 8 is done when:

- client workspace ownership models are documented;
- client discovery/checklist flow is defined;
- workspace reference components are documented;
- tenant-versus-client ownership rule is recorded;
- handoff packet structure is ready;
- at least one internal/demo workspace pattern is walked through end to end;
- Stage 9 can define M365/UAOS bridge readiness without guessing workspace
  boundaries.

---

## 10. Source Notes

This stage is based on the completed internal foundation and should be validated
against live Microsoft documentation before any client tenant change is made.
Portal actions, guest invitations, sharing settings, and tenant policies remain
explicit human-approved gates.
