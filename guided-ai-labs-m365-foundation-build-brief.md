# Guided AI Labs Microsoft 365 Foundation Build Brief

**Prepared for:** Adam Goodwin / AG Operations Ltd. / Guided AI Labs  
**Prepared on:** 2026-06-10  
**Purpose:** Provide a Codex-ready implementation brief for designing and configuring the Microsoft 365 foundation for AG Operations, Guided AI Labs, related product brands, future collaborators, and future AI-native operating-system integration.

> **Canonical sequencing note (2026-06-11):** This brief is the comprehensive
> *reference and design spec*. The **canonical execution order** lives in
> [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md) (Stages 0–9). When this
> brief's Phase numbers and the roadmap's Stage numbers disagree, **the roadmap
> wins** for *what happens next*; this brief wins for *target architecture detail*.
> Start at [00_INDEX.md](00_INDEX.md).
>
> Phase ↔ Stage map:
>
> | Brief Phase (§15) | Roadmap Stage |
> |---|---|
> | Phase 0 — Confirm Current State | Stage 1 — Current-State Inventory |
> | Phase 1 — Tenant & Identity Foundation | Stage 2 — Identity & Admin Foundation |
> | Phase 2 — SharePoint Site Architecture | Stage 3 — SharePoint Information Architecture |
> | Phase 3 — Exchange & Teams Structure | Stages 5 & 6 — Exchange routing; Teams/Planner/Lists |
> | Phase 4 — Device & Access Model | Stage 4 — OneDrive & Local Machine Dovetail (+ Stage 7 security) |
> | Phase 5 — Client Workspace Reference | Stage 8 — Client Workspace Reference Pattern |
> | Phase 6 — Automation Readiness | Stage 9 — Agentic OS Bridge Readiness |
>
> (The roadmap adds an explicit **Stage 0 — Setup Control Room** and splits the
> brief's Phase 3 into separate Exchange and Teams stages.)

---

## 1. Executive Intent

Build Microsoft 365 as the operational backbone for a single-person consulting company designed to operate like a much larger AI-centric firm.

The setup must support:

- AG Operations as the parent/admin/legal tenant structure.
- Guided AI Labs as the main consulting and client-facing AI governance/automation company.
- Product and offer surfaces such as Guided AI Journey, Change Leadership Tools, OldSkoolAI, EasyDraftDocs, Freedom, and future tools.
- Agent-monitored inboxes and future assistant identities.
- Contractors, collaborators, and client-facing collaboration.
- Windows, Linux, and Android access.
- Future integration with a hub brain / agentic operating system.

The immediate goal is not to build the hub brain or automate everything. The immediate goal is to configure Microsoft 365 correctly so it becomes a stable source layer for future work.

---

## 2. Current Confirmed State

### 2.1 Tenant

The Microsoft 365 tenant is operating under:

```text
A.G. Operations Ltd
```

### 2.2 Verified Domains

The following domains are verified in Microsoft 365 and DNS is managed through Cloudflare:

```text
agoperations.ca
guidedailabs.com
changeleadershiptools.com
```

Microsoft `onmicrosoft.com` addresses have been replaced for practical use.

### 2.3 Current Licensed Accounts

Known current users:

| Account | Current role / likely role | License |
|---|---|---|
| admin@agoperations.ca | Tenant/admin/legal backbone | Microsoft 365 Business Standard |
| adamgoodwin@guidedailabs.com | Adam's main Guided AI Labs identity | Microsoft 365 Business Standard |
| contact@guidedailabs.com | Guided AI Labs front-door assistant account | Microsoft 365 Business Standard |
| support@changeleadershiptools.com | Product support identity for Change Leadership Tools | Microsoft 365 Business Standard |

### 2.4 Current Admin Access

Known accounts with admin access:

| Account | Note |
|---|---|
| admin@agoperations.ca | Intended tenant/admin/legal backbone. |
| adamgoodwin@guidedailabs.com | Adam's main day-to-day account; currently also admin. |
| contact@guidedailabs.com | Future assistant/front-door account; currently also admin. |

Security note:

- `contact@guidedailabs.com` should likely not retain admin access long term because it is expected to become agent-monitored and front-door connected.
- Do not remove this access immediately without first creating a proper backup/break-glass admin plan.
- MFA is reported as enabled on the admin-enabled accounts.

---

## 3. Company And Product Architecture

The company structure should be treated as a pyramid:

```text
AG Operations Ltd
  Parent / legal / admin / tenant backbone

Guided AI Labs
  Main operating company and AI consulting brand

Product and offer layer
  Guided AI Journey
  Change Leadership Tools
  OldSkoolAI
  EasyDraftDocs
  Freedom
  Future tools and offers

Technical backends
  Supabase
  Vercel
  GitHub
  Cloudflare
  n8n
  Product-specific databases and APIs
```

Microsoft 365 is the operational backbone, not every product backend.

System-of-record split:

| Domain | Source of truth |
|---|---|
| Employee identity and access | Microsoft Entra / Microsoft 365 |
| Email and calendar | Exchange Online / Outlook |
| Company and client documents | SharePoint |
| Personal working drafts | OneDrive |
| Collaboration | Teams |
| Product users and app data | Supabase or product database |
| Code and technical docs | GitHub |
| DNS and domain records | Cloudflare |
| Website and app deployment | Vercel or product-specific hosting |
| Automation | Power Automate, n8n, Microsoft Graph, or hybrid |

---

## 4. Core Microsoft 365 Admin Areas

The build must account for the following Microsoft infrastructure areas.

| Layer | Admin area | Purpose | Immediate relevance |
|---|---|---|---|
| Tenant, billing, users | Microsoft 365 admin center | Users, licenses, domains, subscriptions, setup | Primary control panel |
| Identity and access | Microsoft Entra admin center | Users, groups, roles, MFA, app registrations, future SSO/API access | Critical |
| Email and calendars | Exchange admin center | Mailboxes, aliases, shared mailboxes, mail flow, calendars, groups | Critical |
| Files and sites | SharePoint admin center | Sites, sharing, storage, external access, document libraries | Critical |
| Personal file access | OneDrive settings through SharePoint | Sync, sharing, personal storage policies | Important |
| Collaboration | Teams admin center | Teams, channels, guest access, meetings, collaboration policies | Important |
| Automation | Power Platform admin center | Power Automate, environments, connectors, Dataverse governance | Important |
| API and agents | Microsoft Graph and Entra app registrations | Programmatic access to mail, files, calendars, users, Teams, SharePoint | Later, but design-aware |
| Device/security | Intune / Defender | Device management, endpoint security, app protection | Likely future Business Premium need |
| Analytics | Power BI / Fabric admin | Dashboards, reporting, semantic models | Later |

---

## 5. Licensing Direction

Current licenses are Microsoft 365 Business Standard.

Business Standard is acceptable for initial setup, but the target security posture likely points toward Microsoft 365 Business Premium for key accounts because the organization will handle client information, agent-monitored accounts, external collaboration, and future API/automation access.

Likely future licensing review:

| License / add-on | Need timing | Reason |
|---|---|---|
| Microsoft 365 Business Premium | Soon / likely | Better identity, device, and security controls. |
| Microsoft 365 Copilot | Later / selective | More useful after SharePoint and company knowledge are clean. |
| Power Automate Premium | Later | Needed for some premium connectors, HTTP/API workflows, and advanced automation. |
| Power BI Pro | Later | Useful for reporting and dashboards, not part of first setup. |
| Teams Phone | Not now | Only needed if phone/VoIP is moved into Microsoft. |
| Defender/Intune add-ons | Later or via Business Premium | Security and device control. |

Codex/task agent instruction:

- Verify current Microsoft licensing details against official Microsoft documentation before recommending purchases or changes.
- Do not assume Business Standard includes security or automation features that may require Business Premium, Entra ID P1/P2, Intune, Defender, or premium Power Platform licensing.

---

## 6. Identity And Account Model

### 6.1 Identity Authority

Microsoft Entra / Microsoft 365 should be the authority for:

- employees
- contractors
- collaborators
- internal team access
- future Microsoft SSO
- Microsoft admin and service access

Supabase should not become the master employee identity system.

Supabase may store app-level authorization/profile data when a product or portal needs it.

### 6.2 Current Account Roles

Recommended role interpretation:

| Account | Intended role |
|---|---|
| admin@agoperations.ca | Tenant/admin/legal backbone account |
| adamgoodwin@guidedailabs.com | Adam's main daily human/operator account |
| contact@guidedailabs.com | Guided AI Labs front-door assistant account |
| support@changeleadershiptools.com | Change Leadership Tools support/product help identity |

### 6.3 Admin Access Recommendation

Current admin access should be reviewed after the foundation is stable.

Recommended end-state:

- Keep `admin@agoperations.ca` as a controlled admin account.
- Use `adamgoodwin@guidedailabs.com` primarily as the daily working identity.
- Remove admin access from `contact@guidedailabs.com` before it becomes deeply agent-monitored or publicly connected.
- Create a true backup/break-glass admin account before reducing admin roles.

Do not implement this change without Adam's explicit approval.

### 6.4 Future Guest Model

The architecture should allow:

- external guest accounts for contractors
- external guest accounts for collaborators
- controlled client access where appropriate
- a polished client interface that avoids exposing raw internal structures

---

## 7. SharePoint And OneDrive Architecture

### 7.1 Core Rule

SharePoint is the official company documentation structure.

OneDrive is personal working space.

Local devices are access and working layers, not independent sources of truth.

### 7.2 SharePoint Purpose

SharePoint should hold:

- official company records
- official client records
- product and offer documentation
- delivery artifacts
- templates
- policies
- decisions
- support documentation
- reusable operating assets

### 7.3 OneDrive Purpose

OneDrive may hold:

- private drafts
- temporary personal working documents
- notes not yet promoted to official record
- files Adam is actively preparing before filing into SharePoint

OneDrive should not become the company filing cabinet.

### 7.4 Workspace Navigation Model

Use company/brand first, then functional structure underneath.

Adam's preferred mental model:

```text
Neighborhood first, then address.
```

Potential top-level SharePoint sites or workspaces:

```text
AG Operations
Guided AI Labs
Guided AI Journey
Change Leadership Tools
OldSkoolAI
EasyDraftDocs
Freedom
Shared Libraries
```

Potential function folders/document libraries inside each relevant workspace:

```text
00_Admin
01_Strategy
02_Finance
03_Legal
04_Marketing
05_Sales
06_Delivery_or_Product
07_Support
08_Assets
09_Archive
```

### 7.5 Critical Refinement

Do not duplicate every function everywhere if the function belongs centrally.

Rules:

- AG Operations holds parent-level legal, finance, ownership, insurance, banking, tax, tenant governance, and sensitive admin records.
- Guided AI Labs holds main consulting, client delivery, AI governance, marketing, and AI-native operating model work.
- Product workspaces hold product-specific material only.
- Shared templates, brand assets, governance artifacts, operating standards, and reusable methods should live centrally where possible.

---

## 8. Recommended Initial SharePoint Sites

Codex should treat this as a proposed design, not a command to create sites without approval.

### 8.1 AG Operations

Purpose:

Private parent/admin area.

Access:

- Adam
- future trusted finance/admin/legal support
- tightly scoped automations

Suggested libraries or folders:

```text
00_Admin
01_Corporate_Records
02_Finance_Tax
03_Legal_Contracts
04_Insurance_Risk
05_Banking_Vendors
06_Tenant_Governance
07_Master_Strategy
08_Decision_Logs
09_Archive
```

### 8.2 Guided AI Labs

Purpose:

Main day-to-day consulting and operating workspace.

Suggested libraries or folders:

```text
00_Admin
01_Strategy
02_Sales_Marketing
03_Client_Delivery
04_AI_Governance
05_Automation_Workflows
06_Templates_Methods
07_Knowledge_Graph_Exports
08_Assets
09_Archive
```

### 8.3 Guided AI Journey

Purpose:

Client-facing method, portal, readiness pathway, and engagement interface.

Suggested libraries or folders:

```text
00_Admin
01_Product_Strategy
02_Client_Portal_Method
03_Assessments
04_Readiness_Scans
05_Client_Workspace_Templates
06_Transfer_Packages
07_UX_Content
08_Assets
09_Archive
```

### 8.4 Change Leadership Tools

Purpose:

Active product/tool website support and operating documentation.

Known product backend:

```text
Supabase
```

Suggested libraries or folders:

```text
00_Admin
01_Product_Strategy
02_User_Support
03_Tool_Downloads
04_Account_Help
05_Knowledge_Base
06_Supabase_Notes
07_Website_Content
08_Assets
09_Archive
```

### 8.5 Shared Libraries

Purpose:

Reusable materials that should not be copied into every brand/product.

Suggested libraries or folders:

```text
01_Templates
02_Brand_Assets
03_AI_Governance_Standards
04_Workflow_Maps
05_Client_Delivery_Methods
06_Coding_Agent_Briefs
07_Research_References
08_Reusable_Decision_Logs
09_Archive
```

---

## 9. Teams Architecture

Teams should reflect collaboration needs, not every folder.

Recommended starting Teams:

```text
AG Operations - Admin
Guided AI Labs - Operating Team
Guided AI Labs - Client Delivery
Change Leadership Tools - Support
```

Use private channels or separate Teams for sensitive material only where needed.

Avoid creating a Team for every product until there is real collaboration need.

---

## 10. Exchange / Mailbox Architecture

### 10.1 Current Accounts

Current mail identities:

```text
admin@agoperations.ca
adamgoodwin@guidedailabs.com
contact@guidedailabs.com
support@changeleadershiptools.com
```

### 10.2 Functional Mailbox Direction

`contact@guidedailabs.com`:

- Future assistant/front-door identity.
- Should support inquiry intake, triage, routing, scheduling, drafting, and automation.
- Keep as licensed user for now because it may need independent calendar, automation ownership, and future assistant capability.

`support@changeleadershiptools.com`:

- Active product support identity.
- Supports users who download tools or create accounts in the Change Leadership Tools website.
- Microsoft 365 supports communication, support workflow, documentation, and automation.
- Supabase remains the product auth/data system unless deliberately changed.

Future review:

- Decide which future addresses should be aliases, shared mailboxes, distribution lists, Microsoft 365 groups, or licensed users.
- Do not over-license simple aliases.
- Do not under-license identities that need calendars, automation ownership, sign-in, Copilot, or independent agent functionality.

---

## 11. Client Workspace Strategy

### 11.1 Direction

Client engagements should produce live workspaces/systems, not just static deliverables.

The client should understand what they own when Guided AI Labs leaves.

### 11.2 Preferred Delivery Model

Preferred model:

- Build the live client workspace inside the client's own environment where possible.
- If the client lacks required infrastructure, coach them through setup as part of the engagement.
- Use infrastructure discovery as a critical first stage.
- Use Guided AI Journey as the client-facing guided interface where useful.

### 11.3 Guided AI Journey Role

Guided AI Journey should likely become the clear client-facing portal or interface.

It may provide:

- intake
- readiness assessment
- infrastructure discovery
- engagement roadmap
- tasks and progress
- decision gates
- artifact transfer
- links into the client's own systems
- governed "looking glass" views into relevant delivery artifacts

It should not expose raw Guided AI Labs internal structures.

### 11.4 Infrastructure Discovery

Every client engagement should assess:

- Microsoft 365 tenant availability
- SharePoint maturity
- Teams usage
- file chaos and document ownership
- admin access
- identity and MFA posture
- external sharing policy
- device posture
- security constraints
- existing workflow tools
- existing product/data systems
- ability to sustain the live workspace after the engagement

---

## 12. Obsidian / Knowledge Graph Direction

Obsidian or a similar graph tool may be used as the thinking map.

It should not be the official filing cabinet.

Recommended split:

```text
SharePoint = official records and documents
Obsidian = knowledge graph, synthesis, relationship mapping
GitHub = code and technical documentation
Supabase = product/app data
Microsoft Lists/Planner = structured operational registers and tasks
```

The knowledge graph may eventually be team/shared, but the Microsoft 365 foundation should be built first.

---

## 13. Linux / Windows / Android Requirements

The system must work across:

- Windows laptop
- Linux laptop
- Android phone
- future team devices

Important Linux note:

Microsoft OneDrive/SharePoint sync on Linux should not be assumed to behave like Windows-native OneDrive sync.

Future task:

Evaluate the most secure and seamless Linux access model for SharePoint and OneDrive.

Consider:

- browser-first access
- selective sync
- third-party OneDrive clients
- mounted access
- offline access needs
- local client-data risk
- Microsoft compatibility
- MFA and conditional access
- file locking and version history behavior

Do not design the whole company around a fragile Linux sync assumption.

---

## 14. Automation And API Direction

Immediate focus:

Set up Microsoft 365 cleanly.

Deferred focus:

Detailed points-in / points-out design for the hub brain and agentic operating system.

Future integration surfaces:

```text
Microsoft Graph
Power Automate
n8n
SharePoint APIs
Exchange APIs
Teams APIs
Planner / To Do APIs
Supabase APIs
GitHub APIs
Vercel APIs
Cloudflare APIs
```

Future hub brain must eventually be able to retrieve from approved Microsoft 365 sources, subject to permissions and audit controls.

Do not implement API app registrations, broad Graph permissions, or automated access until the tenant, SharePoint, account model, and security posture are cleaner.

---

## 15. Build Phases

### Phase 0: Confirm Current State

Tasks:

- Confirm active licenses.
- Confirm verified domains.
- Confirm DNS records in Cloudflare.
- Confirm admin roles.
- Confirm MFA status.
- Confirm available admin centers.
- Confirm current SharePoint sites and Teams.
- Confirm whether any old/default `onmicrosoft.com` addresses remain in practical use.

Output:

```text
Current-state inventory
```

### Phase 1: Tenant And Identity Foundation

Tasks:

- Define account role model.
- Define admin account model.
- Plan backup/break-glass admin account.
- Decide future admin role removal from `contact@guidedailabs.com`.
- Decide which current accounts remain licensed users.
- Identify future aliases/shared mailboxes/groups.

Output:

```text
Identity and account plan
```

### Phase 2: SharePoint Site Architecture

Tasks:

- Decide initial SharePoint sites.
- Decide document libraries versus folders.
- Create AG Operations restricted workspace.
- Create Guided AI Labs operating workspace.
- Create product/support workspaces as needed.
- Create Shared Libraries workspace.
- Define external sharing posture per site.

Output:

```text
SharePoint site and library build plan
```

### Phase 3: Exchange And Teams Structure

Tasks:

- Confirm mailbox roles.
- Confirm calendars needed.
- Decide shared mailbox versus licensed user cases.
- Create or adjust Teams structure.
- Define Teams guest access posture.
- Link Teams to SharePoint sites where appropriate.

Output:

```text
Communication and collaboration plan
```

### Phase 4: Device And Access Model

Tasks:

- Define Windows access model.
- Define Linux access model.
- Define Android access model.
- Decide what can sync locally.
- Decide what must remain browser-only or restricted.
- Evaluate whether Business Premium/Intune/Defender is needed before client data scales.

Output:

```text
Device and access policy draft
```

### Phase 5: Client Workspace Reference Implementation

Tasks:

- Build Guided AI Labs as the reference implementation.
- Create a reusable client workspace pattern.
- Define infrastructure discovery checklist.
- Define client handoff/ownership model.
- Define Guided AI Journey portal role.

Output:

```text
Client workspace reference pattern
```

### Phase 6: Automation Readiness

Tasks:

- Identify first safe automation use cases.
- Decide Power Automate versus n8n versus Graph for each.
- Avoid broad app permissions until security model is ready.
- Prepare future API architecture notes.

Output:

```text
Automation readiness plan
```

---

## 16. Codex Instructions

Codex should:

1. Treat this as a planning and implementation brief, not as permission to make live tenant changes.
2. Produce clear checklists, runbooks, and configuration plans.
3. Separate recommendations into:
   - do now
   - do soon
   - decide later
   - do not do yet
4. Avoid destructive or irreversible changes.
5. Avoid assuming Microsoft licensing details; verify current Microsoft documentation before final purchase/configuration recommendations.
6. Preserve Adam's preference for one question or decision at a time where live configuration choices are needed.
7. Keep the immediate focus on the Microsoft 365 foundation.
8. Defer detailed hub-brain metadata, indexing, and points-in/points-out design until after the M365 foundation is clean.
9. Flag risks clearly, especially around admin accounts, guest access, external sharing, Linux sync, and agent-monitored accounts.
10. Keep the build boring, durable, secure, and easy to explain to future clients.

---

## 17. Acceptance Criteria For The Foundation Plan

The Microsoft 365 foundation plan is acceptable when it clearly defines:

- tenant purpose
- verified domains
- account roles
- admin role strategy
- license direction
- SharePoint site architecture
- OneDrive role
- Teams structure
- Exchange/mailbox model
- guest/collaborator model
- client workspace strategy
- Linux/Windows/Android access approach
- security upgrades needed now versus later
- automation/API items deferred versus ready
- open questions requiring Adam's decision

---

## 18. Open Decisions

These require later decision, not guessing:

1. Exact Microsoft 365 license upgrade path.
2. Timing for removing admin access from `contact@guidedailabs.com`.
3. Whether to create a separate break-glass admin account and how to secure it.
4. Exact SharePoint sites versus document libraries.
5. Exact external sharing policy by site.
6. Which accounts remain licensed users versus shared mailboxes or aliases.
7. Linux OneDrive/SharePoint access method.
8. Whether the first client portal version lives fully in Guided AI Journey or begins as Microsoft-native client workspace templates.
9. First safe automation use cases.
10. Future Microsoft Graph permission model for hub brain integration.

