# Microsoft 365 SharePoint Workspace Shape Pattern

Status: live skeleton and backing structure applied and verified from Prime
Operations reference review (2026-06-14).

This document adapts the useful parts of the local reference workspace at:

```text
C:\Users\adamg\01. Code Projects\Prime Operations SharePoint Workspace
```

The goal is to shape the Guided AI Labs / AG Operations SharePoint experience
before the next live build layer, without copying Prime Boiler details or
derailing the Stage 7 closeout.

Related:

- [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md)
- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
- [M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md](M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md)
- [config/M365_STAGE_8_WORKSPACE_SHAPE.json](config/M365_STAGE_8_WORKSPACE_SHAPE.json)
- [config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json](config/M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json)
- [scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1](scripts/Invoke-M365Stage8WorkspaceShapeBuild.ps1)
- [scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1](scripts/Start-M365Stage8WorkspaceShapeBuildInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1](scripts/Invoke-M365Stage8VerifyWorkspaceShape.ps1)
- [scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1](scripts/Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1)
- [scripts/Test-M365Stage8LocalPreflight.ps1](scripts/Test-M365Stage8LocalPreflight.ps1)
- [config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json](config/M365_STAGE_8_HOMEPAGE_REFINEMENT.json)
- [scripts/New-M365Stage8HomepageRefinementPacket.ps1](scripts/New-M365Stage8HomepageRefinementPacket.ps1)
- [scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1](scripts/Invoke-M365Stage8HomepageRefinementBuild.ps1)
- [scripts/Start-M365Stage8HomepageRefinementInteractive.ps1](scripts/Start-M365Stage8HomepageRefinementInteractive.ps1)
- [scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1](scripts/Invoke-M365Stage8VerifyHomepageRefinement.ps1)
- [scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1](scripts/Start-M365Stage8VerifyHomepageRefinementInteractive.ps1)
- [inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md)
- [inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md](inventory/stage-8-client-workspace-reference/homepage-refinement/STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md)

---

## 1. Reference Pattern We Are Keeping

The Prime Operations workspace has the right shape for an owner-led operating
cockpit:

- a compact start-here layer;
- governance and permission rules before broad use;
- site hub/navigation planning before content sprawl;
- intake and project control as the main workflow;
- Microsoft Lists as durable operating records;
- stage logs and implementation evidence;
- runtime/tool build material kept behind a clear boundary.

The important lesson:

```text
Pages route humans.
Lists hold operating state.
Libraries hold files and evidence.
Permissions create safety.
Navigation creates usability.
```

---

## 2. Guided AI Labs Target Experience

The Guided AI Labs site should become an AI-first operating command center, not a
generic document site.

After reviewing the UAOS zip and Prime Operations reference, the homepage
direction is:

```text
AI-first company command center, with operating cockpit access immediately visible.
```

SharePoint should be the governed business workspace and human-facing command
surface. UAOS should own mission envelope, approval gate, validation, relay, and
learning mechanics. Graphify should own graph-backed knowledge lookup,
recommendations, and handoff records.

Primary user:

- Adam, as founder/operator and builder of the client-facing method.

Secondary users:

- trusted partners, collaborators, and early team members;
- eventually selected clients or client tenant users, only through approved
  Stage 8 access patterns.

The workspace should help a capable new partner answer:

```text
Where do I start?
What work is active?
Where do client opportunities enter?
Where are decisions recorded?
Where are methods and reusable IP?
Where do AI/automation/tooling risks get reviewed?
What can I touch, and what is restricted?
```

---

## 3. Recommended Site Navigation Shape

Use left navigation as a stable site map pointing to pages, not raw folders.

Recommended first navigation groups:

| Group | Links |
|---|---|
| Start Here | Home, How To Use This Workspace, Operating Model |
| Operating Cockpit | Intake, Active Delivery, Decisions, Action Log |
| Client Delivery | Client Discovery, Client Workspace Pattern, Handoff Packets |
| Methods and IP | Templates, Playbooks, Training Paths, Reusable Assets |
| AI and Automation | Agent Setup, Automation Backlog, Tool Permission Review |
| Records and Evidence | Decision Register, Agent Action Log, Readiness Evidence |
| Governance | Access Model, External Sharing Rules, App Grants, Exceptions |
| Archive | Completed Work, Historical Evidence |

Navigation rule:

```text
If a normal user lands there, the page should tell them what the area is for,
what to do next, and which List/view/library is the source of truth.
```

---

## 4. Recommended Pages

### Guided AI Labs Home

Role: compact operating cockpit.

Working title:

```text
Guided AI Labs Command Center
```

Recommended sections:

- compact AI-first command header;
- six command cards:
  - New Intake;
  - Active Delivery;
  - Decisions Needed;
  - Client Readiness;
  - Automation And Agents;
  - Handoffs And Evidence;
- current priorities or active work signal;
- compact Active Work Snapshot band;
- compact Client Pathway Snapshot band;
- light governance / automation safety signal;
- methods/IP shortcuts.

Command-card label style: plain operational labels. Avoid clever or
marketing-like verbs in the primary cockpit controls.

Each command card should include one short status line:

| Card | Status line |
|---|---|
| New Intake | Open items, new requests, and discovery starts. |
| Active Delivery | Work in motion across clients, builds, and operations. |
| Decisions Needed | Scope, access, governance, and delivery choices to clear. |
| Client Readiness | Discovery, assessments, workspace models, and next reviews. |
| Automation And Agents | Proposed automations, agent setup, and tool permission reviews. |
| Handoffs And Evidence | Handoff packets, readiness evidence, and closeout records. |

Command cards should default to pages first, with direct List, Planner, library,
or evidence links near the top of each page. Direct-to-record links remain an
operator-mode option if the extra click becomes friction.

Start with text-only cards, but preserve a clear dashboard runway: manual
snapshots first, embedded List/Planner views second, Power BI or Graph-backed
metrics later, and UAOS/Graphify bridge status only after reviewed summaries and
connector boundaries exist. The dashboard direction should combine operations
and readiness: internal clients and external clients both move through the same
operating cockpit. Use the name `Operational Readiness` for this bigger-picture
dashboard/band concept.

Homepage refinement packet:

```powershell
.\scripts\New-M365Stage8HomepageRefinementPacket.ps1
.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1
```

The apply path is draft-first only:

```powershell
.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply
```

Approval phrase:

```text
create-stage-8-command-center-draft
```

Read-only verification after draft creation:

```powershell
.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1
```

This creates `Guided-AI-Labs-Command-Center-Draft.aspx` for review. It does not
replace the current homepage, change navigation, change permissions, invite
guests, widen sharing, grant apps, publish public Forms, delete anything, or
create automation.

Active Work Snapshot columns:

- Now Moving;
- Waiting On Adam;
- Blocked / At Risk;
- Next Best Actions.

Client Pathway Snapshot:

```text
Discover -> Assess -> Design Workspace -> Deliver -> Handoff
```

Each stage should become a functional set of tools, records, templates, and
evidence surfaces over time. The homepage should route to that toolset without
becoming the toolset itself.

Avoid:

- marketing hero treatment;
- raw library links as the main experience;
- too many equal-weight cards.

### How To Use This Workspace

Role: onboarding page for a business partner or trusted collaborator.

Recommended content:

- where intake starts;
- where tasks live;
- where decisions live;
- where client-owned records should live;
- what requires owner approval;
- who to contact before changing structure.

### Intake

Role: front door for opportunities, client discovery, support, feedback, and
internal improvement requests.

Backed by:

- `Guided AI Labs - Intake Register`;
- Forms intake/feedback kit;
- future Power Automate routing when approved.

### Active Delivery

Role: current work in motion.

Backed by:

- Planner plan: `Guided AI Labs - Operating Plan`;
- Active Delivery channel;
- selected views from Intake Register and Agent Action Log.

### Decisions

Role: durable memory for governance, client scope, delivery commitments,
automation boundaries, and exceptions.

Backed by:

- `Decision Register`.

### Client Workspace Pattern

Role: Stage 8 reference page showing how Guided AI Labs structures client work.

Backed by:

- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md);
- future handoff packet templates.

### Methods And IP

Role: reusable delivery knowledge without mixing it into client-owned records.

Recommended library:

- templates, playbooks, training paths, approved prompt/method notes, public-safe
  examples.

### AI And Automation Governance

Role: controlled surface for agents, automations, tool permissions, app grants,
and human approval rules.

This should not expose sensitive prompt, permission, token, or integration
details broadly.

Automation note:

```powershell
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1
```

runs the page/navigation build as a dry run. Applying live changes requires:

```powershell
.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1 -Apply
```

and the typed approval phrase:

```text
apply-stage-8-workspace-shape
```

Live apply evidence:

- `inventory/stage-8-client-workspace-reference/workspace-shape/stage-8-workspace-shape-build-20260614-213203.log`
- `inventory/stage-8-client-workspace-reference/workspace-shape/STAGE_8_WORKSPACE_SHAPE_VERIFY.md`

The latest read-back result is PASS for the 8 created pages and 9 resolvable
navigation links.

The backing-structure operator:

```powershell
.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1 -Apply
```

created the remaining routing pages, 5 Stage 8 Lists, 5 new document libraries,
Archive folders, and the remaining 17 navigation links. It did not change
permissions, invite guests, widen sharing, grant apps, publish Forms links,
delete anything, or overwrite existing pages. Latest read-back result:

```text
inventory/stage-8-client-workspace-reference/workspace-backing-structure/STAGE_8_WORKSPACE_BACKING_VERIFY.md
```

---

## 5. Lists And Libraries

### Existing Stage 6 Lists

| List | Role |
|---|---|
| `Guided AI Labs - Intake Register` | Intake, client discovery, opportunities, triage |
| `Change Leadership Tools - Support Register` | Product/support requests |
| `Agent Action Log` | Human-supervised automation/action evidence |
| `Decision Register` | Durable decision memory |

### Recommended Next Lists

Live-built and verified on 2026-06-14:

| List | Purpose |
|---|---|
| `Client Workspace Register` | Client/partner workspace model, tenant ownership, status |
| `Handoff Packet Register` | Workspace handoff state, owner, review date, links |
| `Tool Permission Review` | App grants, agent scopes, risky permissions, review cadence |
| `Automation Backlog` | Proposed automations before build/use approval |
| `Exception Register` | Approved deviations with owner, expiry, closure path |

### Library Shape

Recommended libraries or library roles:

| Library / role | Purpose | Visibility |
|---|---|---|
| Published Methods | Approved templates, playbooks, training aids | broad internal read |
| Delivery Working Documents | active internal delivery files | members/contributors |
| Restricted Build Evidence | app/agent/automation specs, sensitive evidence | restricted |
| Client Handoff Packets | handoff-ready exports and guides | client/partner-specific |
| Archive | closed/historical material | controlled |

Avoid creating a separate library for every topic. Use pages, metadata, views,
and Lists first; create libraries when permissions, lifecycle, or file volume
justify separation.

---

## 6. Permission Zones

Use simple zones instead of many one-off exceptions.

| Zone | Audience | Typical surfaces |
|---|---|---|
| Internal published | trusted team/partners | Home, How To Use, approved methods |
| Contributors | operating team | intake updates, delivery files, Planner |
| Builders | site/tool/automation builders | restricted build pages and evidence |
| Governance reviewers | owner and selected reviewers | app grants, exceptions, access decisions |
| Client-specific | named client/partner guests | approved client/handoff surfaces only |

Rule:

```text
Company/client-facing pages may describe the experience, but should not expose
the build workspace, tool permissions, prompts, app grants, or integration risks.
```

---

## 7. Build Sequence

Recommended sequence from here:

1. Finish Stage 7 closeout decisions: support MFA, app-grant resting state, and
   root/legacy site sharing cleanup decision.
2. Approve this workspace shape as the Stage 8 design direction.
3. Create or update user-facing pages first: Home, How To Use, Intake, Active
   Delivery, Decisions, Client Workspace Pattern, Methods And IP, Governance.
4. Update left navigation to page-based groups.
5. Add only the next Lists needed for Stage 8: likely Client Workspace Register
   and Handoff Packet Register first.
6. Create restricted governance/build areas before storing sensitive agent,
   automation, prompt, or app-grant detail.
7. Test one real workflow:
   intake -> triage -> Planner task -> decision -> handoff/readiness note.
8. Record the result in the Decision Register and Agent Action Log.

---

## 8. Stage 8 Fit

This shape supports Stage 8 by making Guided AI Labs itself the demo/reference
workspace.

Stage 8 should produce:

- a client workspace decision model;
- a client workspace map;
- a client discovery/checklist flow;
- a handoff packet;
- a clear tenant-ownership rule;
- a training path for a partner or client.

The SharePoint site then becomes both the working system and the teachable
example.

---

## 9. Gates

Do not proceed to live changes without explicit approval for:

- navigation/page rewrites;
- permission changes;
- new external sharing;
- partner/client guest invitation;
- public or anonymous Forms links;
- app grant changes;
- client-facing automation;
- storing sensitive AI/automation details in broadly readable areas.
