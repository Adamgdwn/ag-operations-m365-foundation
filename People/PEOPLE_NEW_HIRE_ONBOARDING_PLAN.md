# People & New-Hire Onboarding — System Plan

> **Status:** Plan only. No scripts, no live tenant config. This document describes
> the system to be built; nothing here provisions anything yet.
> **Owner:** Adam (absolute superuser). **Entity:** runs under Guided AI Labs, on the
> AG Operations governed substrate.
> **Last updated:** 2026-06-20.

---

## 0. Purpose in one line

A **clean, single place** where hiring someone is a *guided, governed, mostly-prepared-by-the-agent*
pathway — from "we need a role" all the way to "they're ramped and agent-supported" — with the
consequential, access-changing steps gated behind one sign-in and a single approval each.

You pick a role. The agent assembles the entire packet — role description, access profile, every
checklist, every draft record — as proposals. You approve the steps that actually create identity
or grant access. Nothing irreversible happens without your `Y`.

---

## 1. Where it lives — the clean area

A dedicated **`People/`** area, mirrored in three places so it is both navigable for you and
operable by an agent:

| Layer | What lives here | Purpose |
|---|---|---|
| **`People/` folder (this repo)** | This plan, the Role Library, Access Profiles, checklist templates, the new-hire packet template | The human-readable, version-controlled source of truth for *how* hiring works |
| **People & Onboarding SharePoint area** (`/sites/GuidedAILabs`, People hub) | The live operating Lists (below) | The records substrate the agent reads and writes |
| **AG Daily Routines menu → "New Hire"** | The one-click entry point | How you actually launch the process |

### Supporting SharePoint Lists (to be built later, when we stand this up)

- **New Hire Register** — one row per candidate/hire; tracks them through every pipeline stage and holds their status.
- **Role Library** — reusable role definitions (one row per role).
- **Access Profiles** — predefined access bundles, one per role-tier (the heart of "user access").
- These plug into the existing substrate: **Decision Register** (the hire decision and the access-grant decisions are logged here), **Agent Action Log** (every agent-proposed onboarding step: `Suggested / Approved / Completed / Rejected / Superseded`).

> The People area does **not** invent a new governance model. It reuses G0–G4, the
> dry-run-first preview, and the one-sign-in + single-Y approval already in force.

---

## 2. What "one click" actually means

The Daily Routines menu gets a **New Hire** entry. One launch does this:

1. **You pick a role** from the Role Library (or define a new one once).
2. **The agent assembles the full packet automatically (G0/G1 — no approval needed):**
   - Pulls the role description and the matching Access Profile.
   - Generates all four checklists, pre-filled for this role.
   - Drafts the New Hire Register row and the Decision Register entry.
   - Produces the provisioning *plan* (mailbox, license, group/site access) as a **dry-run preview** — what it *would* do, nothing done.
3. **You review, then approve the gated steps one at a time (G2/G3 — sign in once, `Y` each):**
   - Each identity/license/access step is its own approval, so the audit trail shows exactly which access you granted and when.
   - Decline any step and it's logged `Rejected`; nothing partial leaks through.
4. **The agent completes approved steps and logs each as `Completed`**, then hands you the remaining human-only items (equipment handover, signatures, day-1 orientation).

So "one click" = **the agent does all the assembly and proposing in one motion; you approve only what changes access.** That is the maximum leverage the governance model allows without crossing into unattended tenant writes.

### Governance of the steps (per your "approve each" choice)

| Onboarding action | Tier | Who |
|---|---|---|
| Assemble packet, draft records, build checklists, dry-run the plan | G0/G1 | Agent, no approval |
| Create internal List rows (Register, decision log) | G2 | Agent → your single `Y` |
| Create mailbox / identity, assign license, grant SharePoint/group access | **G3** (access write) | **Agent proposes → you approve each, signed in** |
| Send the offer, send external welcome mail, anything leaving the tenant | **G3 external** | **Adam-only** |
| Unattended/scheduled provisioning | G4 | **Blocked** (parked — see §8) |

---

## 3. Building blocks (define once, reuse every hire)

### 3.1 Role Library
Each role is a reusable template so onboarding becomes "pick a role," not "write from scratch."
A role entry holds:
- **Title & purpose** — one paragraph: why this role exists.
- **Responsibilities** — the 5–8 things this person owns.
- **What they'll actually do day-to-day** — the concrete work, including which substrate Lists they touch.
- **Access Profile reference** — points to the bundle in §3.2.
- **Agent capability cap** — the highest governance tier this role's agents may act at (e.g. employee agents may *propose* freely but never approve their own G2; only you approve).
- **Tools & agents** — which apps, which agent loops they get to use.
- **Success metrics / ramp expectations** — what "ramped" looks like at 30/60/90.

### 3.2 Access Profiles (designed for all three tiers now)
A profile maps a **role tier → exact access bundle**, so granting access is "apply profile X," reviewed step-by-step.

| Tier | Identity / mailbox | License | SharePoint / groups | Agent authority | External actions |
|---|---|---|---|---|---|
| **Superuser (Adam)** | Full | Top SKU | Owner, all sites | Approves G2; authorizes G3; sets the rules | Yes (you) |
| **Partner-superuser** (future) | Full | Top SKU | Owner / co-owner | Peer approver of G2; co-authority on G3 via Decision Register | Yes, co-ratified |
| **Employee** | Standard mailbox | Business Premium (Founders Hub) | Member on scoped sites/lists only | Agents *propose* (G1) freely; G2 writes need a superuser `Y`; G3/G4 blocked to them | No — routes up |

> Building all three tiers now means adding a partner or an employee later is *applying a
> profile*, not redesigning the model. The partner tier stays defined-but-unused until you
> create that person (a deliberate, likely co-ratified, decision).

### 3.3 New-Hire Packet template
The single artifact the agent fills per hire: role description + access profile + all four
checklists + the draft records, assembled into one reviewable bundle.

---

## 4. The pipeline — full pathway with checklists

Five stages. Each stage has an owner, an exit condition, and a checklist. The agent pre-fills
every checklist; items marked **[gate]** require your approval; **[you]** are human-only;
unmarked items the agent can complete or draft.

### Stage A — Requisition & Role Definition  *(the "start before" — begins before a person exists)*
**Exit:** an approved role + access profile + headcount sign-off.
- [ ] Confirm the role from the Role Library (or define it once) — purpose, responsibilities, day-to-day
- [ ] Select/confirm the Access Profile and the agent capability cap
- [ ] **[you]** Confirm headcount need and budget
- [ ] **[gate]** Log the decision to open the role → Decision Register
- [ ] Confirm licensing capacity exists (Business Premium seat available — see §7)
- [ ] Draft the job description / posting from the role definition

### Stage B — Sourcing & Hiring
**Exit:** a signed offer.
- [ ] Post / circulate the role (channels, referrals)
- [ ] Track candidates in the New Hire Register (status: Sourcing → Interviewing)
- [ ] Schedule and record interviews; capture notes against the candidate row
- [ ] **[you]** Make the hire decision
- [ ] **[gate]** Log the hire decision → Decision Register
- [ ] **[you / Adam-only]** Issue the offer (external send = G3 external)
- [ ] **[you]** Contract / employment agreement signed (legal, external)
- [ ] Update the Register row → Offer Accepted

### Stage C — Pre-Onboarding  *(offer accepted → day 1; prepare everything, activate nothing)*
**Exit:** everything staged and ready for a clean day 1.
- [ ] Reserve the identity / UPN and mailbox plan (prepared, not yet created)
- [ ] Stage the Access Profile as a dry-run plan (preview only)
- [ ] **[you]** Order / prepare equipment (laptop, peripherals, phone if any)
- [ ] Prepare accounts and tool seats (draft state)
- [ ] Assemble the welcome packet (what to expect, day-1 schedule, who they'll meet)
- [ ] **[you]** Assign an onboarding buddy / first-week owner
- [ ] Schedule day 1 (orientation, access-grant window, first tasks)
- [ ] **[Adam-only]** Send the welcome / day-1 logistics email (external)

### Stage D — Onboarding  *(day 1 → ramped; this is where the gated provisioning happens)*
**Exit:** the person is operational and agent-supported.
- [ ] **[gate]** Create mailbox / identity (G3 — sign in, `Y`)  *(requires Stage 5 Exchange — see §7)*
- [ ] **[gate]** Assign license (G3 — `Y`)
- [ ] **[gate]** Apply Access Profile: SharePoint/site membership, groups, scoped Lists (G3 — `Y` each step)
- [ ] **[you]** Hand over equipment; confirm sign-in works
- [ ] Run orientation: the substrate (Lists, Registers), how decisions get logged, the governance ladder in plain terms
- [ ] Set up their agent support: which loops/tools they use, their capability cap, how to *propose* vs. when a superuser `Y` is needed
- [ ] Walk through their first real, agent-supported task end to end
- [ ] **[gate]** Log onboarding-complete → Agent Action Log / Decision Register
- [ ] Update Register row → Onboarded

### Stage E — Ramp & Steady State  *(continued agentic support)*
**Exit:** independent operation within their tier.
- [ ] 30-day check: tooling working, access correct (no gaps, no over-grant), comfortable proposing via agents
- [ ] 60-day check: owning their responsibilities; agent leverage growing
- [ ] 90-day check: ramped to the role's success metrics
- [ ] Periodic access review: confirm the Access Profile still matches what they do (least privilege)

> **Offboarding mirror (placeholder):** every Access Profile grant in Stage D has a
> corresponding revoke. A separate offboarding checklist will reverse this pathway cleanly.
> Out of scope for this plan; noted so the model stays symmetric.

---

## 5. Role description template (what every role entry answers)

1. **Title** —
2. **Purpose** — one paragraph: why this role exists at Guided AI Labs.
3. **Reports to** — (today: Adam; later: partner).
4. **Responsibilities** — 5–8 owned outcomes.
5. **What they'll actually do** — concrete day-to-day work and which substrate Lists/Registers they touch.
6. **Access Profile** — which tier/bundle (§3.2).
7. **Agent capability cap** — highest tier their agents may act at; what always routes up to a superuser.
8. **Tools & agents** — apps and loops they're entitled to.
9. **Success at 30 / 60 / 90** — ramp expectations.

---

## 6. User access — the matrix view

"User access" = the Access Profile applied per tier (§3.2), enforced step-by-step at grant time.
The principles that govern it:
- **Least privilege:** an employee gets *member* on scoped sites/Lists only — never owner, never tenant-wide.
- **Bounded agent blast radius:** an employee's agent can propose all day (G1); it cannot self-approve a write (G2 needs a superuser `Y`); it can never send externally, change sharing, or grant consent (G3/G4).
- **Audit by construction:** every grant is its own approved, logged step — so a periodic access review reads straight off the Agent Action Log + Register.
- **Reversible:** every grant maps to a revoke (offboarding mirror).

---

## 7. Dependencies & sequencing (what must be true first)

| Dependency | Why it gates onboarding | Status |
|---|---|---|
| **Stage 5 — Exchange / identity** | You cannot create employee mailboxes or real user identities until Exchange identity is stood up. Until then, the pipeline runs in **prep/dry form** — everything *except* live identity creation (Stages A–C fully; Stage D as dry-run). | **Next M365 stage** (not yet started) |
| **Licensing capacity** (Business Premium via Founders Hub) | Each provisioned employee needs a seat. Headcount is bounded by available seats. | Founders Hub app **paused** on eligibility bug (domain-verify lever) |
| **Partner-superuser decision** | The partner tier is *designed* but unused until you create that person — likely a co-ratified decision. | Parked |
| **Layer B app-registration** | Truly unattended/scheduled provisioning (G4) needs its own credential. Deliberately parked. | Parked (see §8) |

**Practical read:** we can build and rehearse this entire system *now* in prep/dry form. The
first *live* provisioning waits on Stage 5 Exchange + a licensing seat. That sequencing is a
feature, not a blocker — it lets the pathway be proven before any real identity is created.

---

## 8. The one remaining frontier

Everything above keeps a human `Y` on each access grant. **Fully hands-off onboarding** — a
new hire provisioned end-to-end with no human present — would cross into the parked **Layer B
app-registration** decision (a service credential, since a persisted sign-in eventually
expires). That stays blocked by design and is a deliberate "when you're ready" call, ideally
co-ratified once a partner exists. Not part of this build.

---

## 9. Suggested build order (when you green-light construction — separate from this plan)

1. **Seed the `People/` area** — Role Library + Access Profiles (all three tiers) + the four checklist templates + packet template, as documents. *(No tenant writes; pure prep.)*
2. **Stand up the three Lists** in the People hub (New Hire Register, Role Library, Access Profiles) — internal G2 writes, gated.
3. **Add the "New Hire" menu entry** to AG Daily Routines, wired to assemble-the-packet (G0/G1 dry-run only at first).
4. **Wire the gated provisioning steps** (Stage D) — only after Stage 5 Exchange exists.
5. **Add the offboarding mirror.**

Each is its own gated, dry-run-first step, one decision at a time — consistent with how the
rest of the foundation was built.

---

## 10. Open decisions for you (none blocking the plan)

- First role(s) to define in the Library — what's the realistic first hire?
- Whether the first live run waits for Stage 5, or we rehearse fully in dry form first.
- When (and with whom) to activate the partner-superuser tier.
