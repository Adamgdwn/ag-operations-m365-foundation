# Microsoft 365 Stage 3 — SharePoint Information Architecture

Status: **COMPLETE** (started 2026-06-11, closed 2026-06-12). This is the Stage 3 working document
per [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md). Orientation lives in
[00_INDEX.md](00_INDEX.md); current-state facts come from
[M365_STAGE_1_CURRENT_STATE_INVENTORY.md](M365_STAGE_1_CURRENT_STATE_INVENTORY.md);
the target design intent comes from the build brief §7–8
([guided-ai-labs-m365-foundation-build-brief.md](guided-ai-labs-m365-foundation-build-brief.md)).

**Golden rule for this stage: DESIGN before BUILD. Decide the structure on paper,
then provision ONE pilot site, verify it, and only then roll the pattern out.
Every live change is a separate, explicit, reversible decision — one at a time.**

> **Execution status — DESIGN PHASE (2026-06-11):** Nothing has been built in
> SharePoint yet. This document captures the proposed architecture and an open
> decision log. No site, library, or permission has been created or changed. The
> first live write will not happen until the keystone decisions (§4) are made.
> **STAGE 3 COMPLETE (2026-06-12).** All 5 sites provisioned and verified. Design
> decisions 3.1–3.6b all made (5 sites; Hybrid; metadata schema with `Sensitivity`→
> `Classification` fix; Mixed 3 Comms + 2 Team; lean defaults; all-PnP). Provisioning
> app `agent-pnp-provisioning` registered; **AG Operations + Guided AI Labs + Change
> Leadership Tools + Shared Libraries + Guided AI Journey** all created with Hybrid
> libraries + folders + 5 metadata columns, external sharing OFF. **Read-only
> re-inventory (`Invoke-M365Stage3Verify.ps1`) returned PASS — all 5 sites match the
> design.** Next: Stage 4 (OneDrive & Local Machine Dovetail). Carry-forward / open
> (non-blocking): the 3.2b content-type-hub refinement (promote the 5 columns to a
> reusable content type), and the per-site Owner/sharing widening as people/clients
> are added.

---

## 1. Why SharePoint comes after identity

Identity (Stage 2) answered *who* each account is and *what it may do*. Stage 3
answers *where the official records live, who owns them, who can see them, and what
may leave the building (external sharing)*. SharePoint is the filing cabinet, the
knowledge base, the client-record layer, and the reusable-method library. If this
is clean, future search, Copilot, and the Agentic OS bridge become far more useful;
if it is messy, every later layer inherits the mess. Permissions here inherit
directly from the Stage 2 identity model.

---

## 2. Current SharePoint state (from Stage 1 inventory)

The tenant's SharePoint footprint is **small and entirely default/system-generated**
— the intended clean architecture does **not** exist yet. Sites found 2026-06-10:

| Site (name) | Display name | What it is |
|---|---|---|
| `A.G.OperationsLtd` | A.G. Operations Ltd | Root / tenant company site (default) |
| `allcompany` | All Company | Backs the default "All Company" M365 group |
| `agoperationsltd.sharepoint.com` | Communication site | Default root communication site |
| `contentTypeHub` | Team Site | System content-type hub (do not touch) |
| `groupforanswers…vivaengage…` | Viva Engage group — DO NOT DELETE | System/Viva Engage (do not touch) |

Read of this: **a blank canvas.** No real brand/company sites exist, so there is no
legacy structure to migrate or untangle — we get to build it clean. Related: groups
are also mostly default (`A.G. Operations Ltd`, `All Company`, a Viva Engage group),
so the group/permission model will be designed here too, not inherited.

**Licensing note:** the tenant is on **Business Standard** (not Premium). SharePoint
Online, OneDrive, and M365 Groups are fully included — site provisioning is
available now. What is *not* included (sensitivity labels via Entra P1, Defender,
Intune) is a Stage 7 decision and does not block Stage 3. `adamgoodwin@` holds the
**SharePoint Administrator** role, so we can administer sites directly.

---

## 3. Design principles (the rules we build by)

1. **Neighborhood first, then address.** Top-level sites are brands/companies
   (the neighborhood); structure *inside* a site is the address. Adam's preferred
   mental model (brief §7.4).
2. **Don't duplicate central functions everywhere.** Legal/finance/ownership live
   centrally in AG Operations; reusable templates/brand/methods live centrally in
   Shared Libraries. Product sites hold product-specific material only (brief §7.5).
3. **Site vs library vs folder — a deliberate choice, not a reflex** (decision 3.2):
   - **New site** = a distinct security boundary, audience, or external-sharing
     posture. Sites are the unit of *permission and sharing*.
   - **Library** = a major content domain within a site that may want its own
     versioning, columns, or sync behaviour.
   - **Folder** = ordinary grouping within a library. Cheapest; no permission story.
   Bias: fewer sites, clear libraries, shallow folders. A new site must *earn* itself.
4. **Official record vs draft.** SharePoint = official record; OneDrive = personal
   draft; local = working cache (brief §7.1). This boundary is enforced in Stage 4
   but designed-for here.
5. **Permissions inherit from identity (Stage 2).** Owner/member/visitor groups per
   site; least privilege; external sharing is *off by default* and opened
   deliberately per site (decision 3.4).
6. **Reversible + navigable.** Pilot one site, verify, then roll out. Names and
   structure should be self-explanatory a year from now.

---

## 4. Keystone decisions (decide in order — one at a time)

These are the open Stage 3 decisions. They are listed in dependency order; later
ones depend on earlier ones. **None are decided yet.**

### 3.1 — Site topology: which top-level sites do we create now? ⬅ FIRST DECISION

The brief lists up to eight potential workspaces (AG Operations, Guided AI Labs,
Guided AI Journey, Change Leadership Tools, OldSkoolAI, EasyDraftDocs, Freedom,
Shared Libraries). The roadmap's *starting* candidates are a tighter four. The
question is how many neighborhoods to stand up now versus defer until real use
justifies them.

| Option | Sites created now | Rationale |
|---|---|---|
| **A — Lean four (roadmap)** *(recommended)* | AG Operations · Guided AI Labs · Shared Libraries · Change Leadership Tools | Matches the roadmap's "create product sites when they have enough real use." Covers parent/admin, daily consulting, reusable IP, and the one live product. Defers Guided AI Journey + the three early-stage products until they have real content. |
| **B — Five (add Guided AI Journey)** | Lean four + Guided AI Journey | If the client-facing method/portal work is active enough to need its own home now. |
| **C — Minimal two** | AG Operations · Guided AI Labs | Absolute smallest start; add the rest one at a time as needed. |

*Deferred either way until justified by real use:* OldSkoolAI, EasyDraftDocs,
Freedom (and Guided AI Journey under Option A). Deferring is free — a site can be
created in minutes when its content is real.

**Decision 3.1 — DECIDED 2026-06-11: Option B (Five sites).** Create now:
**AG Operations · Guided AI Labs · Shared Libraries · Change Leadership Tools ·
Guided AI Journey.** Guided AI Journey gets its own home now (client-facing
method/portal work is active enough to justify it). Still deferred until real
content justifies them: OldSkoolAI, EasyDraftDocs, Freedom.

### 3.2 — Library/folder taxonomy (the "address" inside each site)

Proposed: adopt the brief's per-site `00_–09_` scheme (§8), tuned per site.
Sub-question: are `00_…09_` **document libraries** or **folders inside one library**?

**Decision 3.2 — DECIDED 2026-06-11: Hybrid.** A small number of **document
libraries** per site for genuinely distinct security / external-sharing / sync
domains (e.g. Admin, Client_Delivery, Templates, Archive), with the `00_–09_`
items as **shallow folders beneath** them — not ten libraries per site, and not one
mega-library. Rationale (AI-navigability): each library is a first-class Microsoft
Graph `drive` (a clean node to enumerate and map); folders are opaque path strings
to graph tools, so keep them few and shallow. A library must *earn* itself by
having a distinct permission, sharing, or sync need.

### 3.2b — Metadata column schema (the actual AI-navigability layer) ⬅ NEW

**Why this is the real lever:** Copilot, Microsoft Graph, and knowledge-graph /
GraphRAG tools (and the future Agentic OS bridge) traverse **metadata**, not folder
paths. A folder name is just text; a *column* turns each file into a structured,
queryable entity with relationships — which is what a knowledge graph is built from.
So a small, **consistent** set of columns applied across every library on every site
is what makes the whole estate legible to AI.

Proposed starter schema (site-managed columns / content type, applied estate-wide):

| Column | Purpose | Example values |
|---|---|---|
| `Record Type` | What kind of record this is | Contract, Invoice, Method, Deliverable, Decision, Asset, Note |
| `Brand` | Which neighborhood/entity it belongs to | AG Operations, Guided AI Labs, Guided AI Journey, Change Leadership Tools, Shared |
| `Client` | Linked client (blank if internal) | _(person/org lookup later)_ |
| `Status` | Lifecycle state | Draft, Active, Final, Superseded, Archived |
| `Classification` | Handling / sharing class _(renamed from "Sensitivity" 2026-06-11 — that title is reserved by built-in MIP sensitivity-label columns; "Classification" avoids the collision and future-proofs real labels at Stage 7)_ | Internal, Confidential, Client-Owned, Public |

Open sub-points to settle in 3.2b: site columns vs a reusable **content type** (the
content-type hub lets one definition propagate to all sites); which become **managed
metadata** (controlled term sets — best for graph consistency) vs free text; and
whether `Client` becomes a proper lookup once a client list exists. Decide after the
pilot site exists so we can test the schema on real libraries.

**Decision 3.2b:** _pending (schema drafted above; refine on the pilot site)._

### 3.3 — Permission / group model (owner / member / visitor per site)

Who, beyond `adamgoodwin@`, owns and accesses each site today (realistically: just
Adam, with `contact@`/`support@` scoped in later).

**Decision 3.3 — DEFAULT (safe baseline, 2026-06-11):** Each site uses the standard
SharePoint **Owners / Members / Visitors** group trio. For now `adamgoodwin@` is the
sole Owner of every site; no other members. `contact@` and `support@` get scoped
access **only** to the sites they need, added deliberately at the relevant later
stage (Exchange/Stage 5, support workflow). Least privilege; widen explicitly, never
by default. _(Veto/adjust anytime — this is the conservative starting point, not a
lock-in.)_

### 3.4 — External sharing posture per site

**Decision 3.4 — DEFAULT (safe baseline, 2026-06-11):** **External sharing OFF** on
every new site to start. It gets opened **deliberately, per site**, only where client
delivery actually needs it (likely candidates later: Guided AI Journey, Change
Leadership Tools). The full tenant-wide external-sharing posture is a **Stage 7**
governance topic; here we just ensure nothing new is born open. _(Veto/adjust
anytime.)_

### 3.5 — Archive strategy

**Decision 3.5 — DEFAULT (safe baseline, 2026-06-11):** Start with a simple per-site
`09_Archive` folder (or library where a site warrants it). Proper **retention
labels** need licensing/governance and are deferred to **Stage 7**. `Status =
Archived` in the 3.2b metadata schema gives a queryable archive signal in the
meantime. _(Veto/adjust anytime.)_

### 3.6 — Provisioning method + pilot order

How we actually build: SharePoint admin center (portal), PnP PowerShell, or Graph.

**Decision 3.6 — DECIDED 2026-06-11: All PnP PowerShell.** Script every site from one
provisioning template for speed + consistency across all five. Still **pilot first**:
build AG Operations (private, lowest external exposure), verify by read-back, review,
then apply the template to the other four. Each apply is logged in §8.

**Tooling check (2026-06-11):** `PnP.PowerShell 3.2.0` is already installed on
PowerShell 7.6.2 — no module install needed.

**Prerequisite — PnP authentication (must resolve before the first live write):**
Modern `PnP.PowerShell` (v2+) **no longer ships a shared multi-tenant sign-in app** —
the old "PnP Management Shell" app was retired. `Connect-PnPOnline` now requires
**your own Entra app registration** with SharePoint/Graph permissions and admin
consent. Options:
- **(a)** Register a dedicated `svc-`/setup app for provisioning (e.g.
  `PnP-Provisioning`) with delegated `AllSites.FullControl` + `User.Read`, granted to
  Adam interactively (device-code / browser) — keeps the existing
  *AG Operations Agentic Partner* app untouched and follows the naming standard.
- **(b)** Reuse the existing *AG Operations Agentic Partner* app registration by
  adding the SharePoint permission — fewer apps, but mixes setup/helper concerns.
- **(c)** Use `Connect-PnPOnline -Interactive` against a registered app via
  delegated auth so every action runs as Adam (visible-execution friendly).

Recommendation: **(a) + (c)** — a dedicated, clearly-named provisioning app using
**delegated** (act-as-Adam) auth, so the first SharePoint writes mirror the Stage 2
Level-1 model (Adam signs in, agent acts in his delegated scope, every action
narrated and reversible). This app prerequisite is the next concrete step.

**Decision 3.6b — DECIDED 2026-06-11: Dedicated provisioning app (a) + delegated
auth (c).** Register a new app `agent-pnp-provisioning` (per naming standard;
human-triggered tooling app — see note), delegated, admin-consented by Adam, used via
`Connect-PnPOnline -Interactive` so every write runs as `adamgoodwin@`. The existing
*AG Operations Agentic Partner* app stays untouched. _Naming note:_ the standard maps
app registrations to the `agent-` prefix; this one is a delegated setup/tooling app,
not an autonomous agent — flagged as a minor future refinement to the naming standard
(a `tool-`/`setup-` prefix for human-operated tooling apps). Permission scope depends
on 3.2c below.

### 3.2c — Site template: Communication vs Team site (decide before registering app)

Affects both information architecture and the app's permission scope:
- **Communication site** — groupless, clean broadcast/IA, no M365 group created. Best
  for a records/knowledge structure; avoids group sprawl. App needs only SharePoint
  `AllSites.FullControl`.
- **Team site (group-connected)** — creates an M365 group + enables Teams-backing
  (Stage 6) and membership groups. App also needs Graph `Group.ReadWrite.All`
  (broader). Better where real collaboration/Teams is imminent.

Recommendation: **Communication sites for the records-first IA** (AG Operations,
Shared Libraries, Guided AI Journey), and decide Team-vs-Comms per site for the
collaboration-heavy ones (Guided AI Labs, Change Leadership Tools) — or keep all five
Communication now and add Teams-backing deliberately at Stage 6. Keeping all five
Communication keeps the provisioning app least-privilege (no group write).

**Decision 3.2c — DECIDED 2026-06-11: Mixed.**
- **Communication sites** (groupless, records-first): **AG Operations · Shared
  Libraries · Guided AI Journey**.
- **Team sites** (group-connected, Teams-ready now): **Guided AI Labs · Change
  Leadership Tools**.

Consequence for 3.6b: the provisioning app needs delegated **SharePoint
`AllSites.FullControl`** + Graph **`Group.ReadWrite.All`** (for the two Team sites) +
**`User.Read`**. Pilot site (AG Operations) is a Communication site, so the pilot
itself only exercises the SharePoint scope.

---

## 5. Proposed library taxonomy (reference — from brief §8, pending 3.2)

Shown as the design starting point; not yet built. Numbers give stable sort order.

- **AG Operations** (private parent/admin): `00_Admin` · `01_Corporate_Records` ·
  `02_Finance_Tax` · `03_Legal_Contracts` · `04_Insurance_Risk` ·
  `05_Banking_Vendors` · `06_Tenant_Governance` · `07_Master_Strategy` ·
  `08_Decision_Logs` · `09_Archive`
- **Guided AI Labs** (daily consulting/operating): `00_Admin` · `01_Strategy` ·
  `02_Sales_Marketing` · `03_Client_Delivery` · `04_AI_Governance` ·
  `05_Automation_Workflows` · `06_Templates_Methods` · `07_Knowledge_Graph_Exports` ·
  `08_Assets` · `09_Archive`
- **Shared Libraries** (reusable IP): `01_Templates` · `02_Brand_Assets` ·
  `03_AI_Governance_Standards` · `04_Workflow_Maps` · `05_Client_Delivery_Methods` ·
  `06_Coding_Agent_Briefs` · `07_Research_References` · `08_Reusable_Decision_Logs` ·
  `09_Archive`
- **Change Leadership Tools** (live product support): `00_Admin` ·
  `01_Product_Strategy` · `02_User_Support` · `03_Tool_Downloads` · `04_Account_Help` ·
  `05_Knowledge_Base` · `06_Supabase_Notes` · `07_Website_Content` · `08_Assets` ·
  `09_Archive`
- **Guided AI Journey** (only if Option B): `00_Admin` · `01_Product_Strategy` ·
  `02_Client_Portal_Method` · `03_Assessments` · `04_Readiness_Scans` ·
  `05_Client_Workspace_Templates` · `06_Transfer_Packages` · `07_UX_Content` ·
  `08_Assets` · `09_Archive`

---

## 6. Build sequence (how Stage 3 will execute)

1. **Decide §4 keystone decisions** (one at a time, starting with 3.1). ← we are here
2. **Pilot:** provision ONE site with its libraries + permissions by the chosen
   method; verify by read-back (a Stage 3 verify script, mirroring Stage 2's pattern).
3. **Review the pilot** with Adam; adjust the template.
4. **Roll out** the remaining agreed sites from the verified template.
5. **Re-inventory** SharePoint; confirm the live structure matches this design;
   declare Stage 3 complete and update `00_INDEX.md` + state memory.

External sharing, archive, and Teams-backing (Stage 6) are layered after the sites
exist.

---

## 7. Decision log

| # | Decision | Status | Date |
|---|---|---|---|
| 3.1 | Site topology (which top-level sites now) | **DECIDED — Option B: 5 sites** (AG Operations, Guided AI Labs, Shared Libraries, Change Leadership Tools, Guided AI Journey) | 2026-06-11 |
| 3.2 | Library/folder taxonomy & granularity | **DECIDED — Hybrid** (few libraries per security/sync domain, shallow folders beneath) | 2026-06-11 |
| 3.2b | Metadata column schema (AI-navigability layer) | drafted (Record Type, Brand, Client, Status, Sensitivity); refine on pilot | 2026-06-11 |
| 3.3 | Permission/group model per site | **DEFAULT** — Owners/Members/Visitors; `adamgoodwin@` sole Owner; others scoped in later (veto-able) | 2026-06-11 |
| 3.4 | External sharing posture per site | **DEFAULT** — OFF on every new site; opened deliberately per site; full posture = Stage 7 (veto-able) | 2026-06-11 |
| 3.5 | Archive strategy | **DEFAULT** — per-site `09_Archive` + `Status=Archived`; retention labels = Stage 7 (veto-able) | 2026-06-11 |
| 3.6 | Provisioning method + pilot order | **DECIDED — All PnP PowerShell**, pilot AG Operations first then template the rest | 2026-06-11 |
| 3.2c | Site template (Communication vs Team) | **DECIDED — Mixed**: Comms = AG Operations, Shared Libraries, Guided AI Journey; Team = Guided AI Labs, Change Leadership Tools | 2026-06-11 |
| 3.6b | PnP auth app (PnP v2 needs own Entra app) | **DECIDED — dedicated `agent-pnp-provisioning`**, delegated act-as-Adam auth | 2026-06-11 |

---

## 8. Execution log (live SharePoint changes)

| Date | Action | Method | Result |
|---|---|---|---|
| 2026-06-11 | Registered provisioning app `agent-pnp-provisioning` (delegated: SP `AllSites.FullControl`, Graph `Group.ReadWrite.All`, `User.Read`) | `Invoke-M365Stage3RegisterPnPApp.ps1` (`Register-PnPEntraIDAppForInteractiveLogin`, interactive) | **App created** — ClientId `46a71fd0-068c-4f89-9575-65c6405ca067`. ClientId stashed in git-ignored `M365_ENVIRONMENT.local.env`. Delegated consent confirmed at first interactive connect. Reversible: delete the app in Entra. No SharePoint content created. |
| 2026-06-11 | Provisioned **AG Operations PILOT** Communication site (`/sites/AGOperations`), external sharing Disabled, 3 libraries (Governance_Records, Finance_Legal, Archive) + folders + metadata columns | `Invoke-M365Stage3ProvisionAGOperations.ps1` (PnP, interactive, typed-`yes` gate) | **Site + libraries + folders created; sharing OFF.** Read-back caught **4/5 columns** — the 5th (`Sensitivity`) collided with built-in **hidden MIP sensitivity-label columns** (title "Sensitivity" = `_DisplayName`). Remediated by `Invoke-M365Stage3FixSensitivityColumn.ps1`: column **renamed to `Classification`** (collision-free, future-proofs Stage 7 labels); template patched to match. No system columns deleted. **Read-back confirmed 5/5 columns on all 3 libraries** (Brand, Classification, Client, Record Type, Status). Reversible: delete site via SP admin recycle bin. |
| 2026-06-11 | Provisioned **remaining 4 sites** from the verified template: **Guided AI Labs** + **Change Leadership Tools** (Team sites, M365-group-connected), **Shared Libraries** + **Guided AI Journey** (Communication sites) — each with Hybrid libraries + folders + 5 columns, external sharing Disabled | `Invoke-M365Stage3ProvisionRemainingSites.ps1` (PnP, interactive, batch typed-`yes` gate) | **All 4 created; read-back confirmed** every library's folders + 5 columns; sharing OFF on all. **All 5 Stage 3 sites now match the design.** Reversible: delete any site via SP admin recycle bin. |
| 2026-06-12 | **Stage 3 closure re-inventory** (read-only) across all 5 sites | `Invoke-M365Stage3Verify.ps1` (PnP, interactive, read-only) | **PASS** — every site's libraries, folders, and 5 metadata columns match the design. **Stage 3 closed.** |

_Every SharePoint provisioning action below will be recorded the same way — date,
method, and read-back confirmation (Stage 2 §10 discipline)._
