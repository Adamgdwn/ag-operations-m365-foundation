# Microsoft 365 Stage 2 — Identity & Admin Foundation

Status: **in progress** (started 2026-06-11). This is the Stage 2 working document
per [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md). Orientation lives in
[00_INDEX.md](00_INDEX.md); current-state facts come from
[M365_STAGE_1_CURRENT_STATE_INVENTORY.md](M365_STAGE_1_CURRENT_STATE_INVENTORY.md).

**Golden rule for this stage: build the safety net (break-glass + role matrix)
BEFORE removing any admin role. Every live change is a separate, explicit,
reversible decision. Nothing in this document has been executed in the tenant.**

---

## 1. Why identity comes first

Identity is the root of every later decision. SharePoint permissions, mailbox
routing, Teams membership, and the eventual Agentic OS bridge all inherit from
"who is this account and what is it allowed to do." If account roles are blurry
now, every later layer inherits the blur. So Stage 2 produces a clean, named role
for every account and a safe path to reduce over-broad admin access — without
locking ourselves out.

---

## 2. Account role matrix — CURRENT state (from Stage 1 inventory)

The tenant has **4 accounts**, all enabled and licensed (Business Standard).
Admin roles as inventoried 2026-06-10:

| Account | Display | Current admin roles | Licensed |
|---|---|---|---|
| `admin@agoperations.ca` | Adam Goodwin | **Global Administrator** | Yes (1) |
| `adamgoodwin@guidedailabs.com` | Adam Goodwin | **Global Administrator**, Global Reader, AI Administrator, Exchange Admin, SharePoint Admin, Teams Admin, User Admin, User Experience Success Manager, Service Support Admin, Helpdesk Admin | Yes (1) |
| `contact@guidedailabs.com` | contact | **Global Administrator**, Global Reader, AI Administrator | Yes (1) |
| `support@changeleadershiptools.com` | Support at ChangeTools | (none) | Yes (1) |

Three things stand out:

1. **Three Global Administrators**, and one of them (`adamgoodwin@…`) is also the
   everyday working identity. A daily-driver account holding Global Admin is the
   single biggest identity risk here — every email link, browser session, and
   app consent runs with tenant-god rights.
2. **No true break-glass account.** All three GAs are accounts in active use. If
   one is compromised or locked out, there is no clean, untouched emergency
   account held in reserve.
3. **`contact@guidedailabs.com` is a front-door/reception identity holding Global
   Admin** — far more power than a contact address should ever carry.

---

## 3. Target identity model (recommended)

The principle: **separate "who you are day to day" from "the keys to the tenant."**
Admin power should live in accounts you sign into deliberately, not in the account
you read email and browse the web with.

| Account | Proposed role | Admin posture (target) |
|---|---|---|
| `adamgoodwin@guidedailabs.com` | **Adam's daily human identity AND primary admin** (DECIDED 2026-06-11) | Keep Global Administrator |
| `admin@agoperations.ca` | **Secondary / backup admin** — used if the daily account is unavailable | Keep Global Administrator |
| `contact@guidedailabs.com` | **Front door / reception → future agent-operated** interaction mailbox | Remove all admin roles (capability comes later via a scoped app identity, not standing admin) |
| `support@changeleadershiptools.com` | **Support identity** for Change Leadership Tools | No admin roles (already none) |
| `breakglass-01` / `breakglass-02` `@AGOperationsLtd.onmicrosoft.com` | **Emergency access (NEW ×2)** — never used day to day | Global Administrator, cloud-only, credentials held offline |

> **Accepted residual risk (2026-06-11):** Adam chose to keep his daily working
> identity as primary admin rather than splitting daily-use from admin power. This
> is a deliberate, informed trade-off for a solo operator. It means tenant-god
> rights ride along with everyday email/browser/app-consent activity, so the
> compensating controls matter more:
> - strong, ideally phishing-resistant **MFA** on `adamgoodwin@…`;
> - **deliberate app-consent hygiene** (don't approve OAuth consent prompts casually);
> - consider a **separate browser profile** for admin-center work vs. daily browsing;
> - **revisit at Stage 7:** if Business Premium / Entra ID P1–P2 comes in, enforce
>   Conditional Access and just-in-time elevation (PIM) so admin rights are only
>   active when needed. Business Standard has neither today, so this can't be
>   enforced yet — it's managed by discipline for now.

Notes that shape this:

- **Break-glass accounts do not need a license.** Global Administrator works on an
  unlicensed account, so adding emergency-access accounts costs nothing in seats.
- This tenant is **Business Standard**, so there is **no Conditional Access / Entra
  ID P1**. That means the usual "exclude break-glass from CA policies" step does
  not apply yet — but it also means our only protections today are strong unique
  passwords + MFA, so the break-glass credential hygiene matters more, not less.
- Removing roles from `adamgoodwin@…` only becomes safe **after** the controlled
  admin account and the break-glass account are both confirmed working.

---

## 4. Break-glass admin plan (DRAFT — build before any role removal)

Goal: a guaranteed way back into the tenant if the primary admin account is lost,
compromised, or locked out.

Proposed shape:

- **Two new emergency-access accounts** (DECIDED 2026-06-11) —
  `breakglass-01` and `breakglass-02` — on the tenant's own
  `AGOperationsLtd.onmicrosoft.com` domain (so they never depend on a custom domain
  that could expire or be misconfigured). This matches Microsoft's guidance and
  keeps the emergency reserve fully separate from the controlled-admin account.
- **Global Administrator**, **cloud-only**, **not used for daily work, ever.**
- **Long unique passphrase**, recorded **offline / in a vault** — never in this
  repo, never in email, never in a notes app synced to a daily identity.
- **Strong MFA** registered, with the recovery method also stored offline.
- A short written **"how to use in an emergency"** note (where the credential lives,
  who can retrieve it) kept with the offline record — not in git.

What we are NOT doing here: putting any real credential, recovery code, or MFA
secret into any file in this repository. This document only describes the plan.

---

## 5. Decision plan — reducing over-broad admin (WRITE, do not execute)

Sequenced so the safety net always exists first. Each step is its own go/no-go.
(Revised 2026-06-11: the daily account keeps Global Admin, so there is no demotion
step — the reductions are the `contact@` cleanup plus optional tidying.)

1. **Stand up the safety net.** Create the two break-glass accounts
   (`breakglass-01`, `breakglass-02`), register MFA, store credentials offline, and
   confirm each can sign in and read an admin surface. Also confirm
   `admin@agoperations.ca` still works as the backup admin. *No removals yet.*
2. **(Optional) Tidy redundant roles on `adamgoodwin@…`.** Several roles are
   already subsumed by Global Administrator (e.g. **Global Reader** is fully
   redundant; the sub-admin roles — Exchange/SharePoint/Teams/User/Helpdesk/Service
   Support/UX Success/AI Admin — add audit noise without adding power while GA is
   held). Removing them is cosmetic/audit hygiene, **not** a power reduction, and is
   fully reversible. Keep or trim per Adam's preference.
3. **Remove Global Admin (and Global Reader + AI Admin) from
   `contact@guidedailabs.com`.** Then decide separately whether it becomes a shared
   mailbox or stays a licensed user.
4. **Re-inventory** to confirm the final role assignments match this matrix.

Steps 2–3 touch live config, so each is a separate explicit approval at the time we
do it — not pre-authorized by this plan.

---

## 6. Naming standard for future service / agent identities

For when the Agentic OS bridge (Stage 9) and other automation need their own
identities, so they are instantly recognizable and auditable:

- **Human accounts:** person-named (`adamgoodwin@…`) — as today.
- **Controlled admin:** `admin@…` — as today.
- **Emergency access:** `breakglass-01@AGOperationsLtd.onmicrosoft.com` (numbered,
  on the onmicrosoft.com domain, obvious in any audit).
- **Service / app / agent identities:** prefix `svc-` for service accounts and
  `agent-` for agent-operated identities, e.g. `svc-graph-inventory@…`,
  `agent-os-bridge@…`. Where possible, prefer **app registrations + managed
  identities over real user accounts** so there is no interactive password to
  steal. Real "service user" accounts are a fallback, named with the `svc-` prefix.
- **Shared mailboxes / aliases:** function-named (`contact@…`, `support@…`,
  `billing@…`) — not tied to a person.

### Core identity principle: interaction surface ≠ capability surface

Established 2026-06-11 from the `contact@` decision; applies to **every** future
agent in this project:

- The **interaction surface** (the mailbox/account that receives external email,
  chats, requests) is the highest-exposure identity — it ingests untrusted input
  and is the prime phishing / prompt-injection target. It is kept **low-privilege**.
- The **capability surface** (the ability to actually do things — read directories,
  manage users, write to SharePoint) lives in a **separate app registration /
  service identity** with **least-privilege, explicit, audited, revocable** Graph
  permissions and a vaulted secret/certificate.
- An agent acts by binding the two: it *receives* on the interaction identity and
  *acts* through the scoped capability identity — so a compromise of the inbox can
  never exceed the narrow, granted permission set.
- **Never** grant standing Global Administrator (or broad admin) to an account that
  also receives untrusted interactions. Unlimited blast radius with no rails is the
  exact opposite of what an autonomous system needs.

This is the design contract the Stage 9 Agentic OS bridge must satisfy.

---

## 7. Decision log (filled in as Adam decides — one at a time)

| # | Decision | Choice | Date |
|---|---|---|---|
| 2.1 | Break-glass: one new account, or two? | **Two** — `breakglass-01` + `breakglass-02` | 2026-06-11 |
| 2.2 | `admin@agoperations.ca` role | **Secondary / backup admin** (not the daily-admin) | 2026-06-11 |
| 2.3 | Demote `adamgoodwin@…` from Global Admin? | **No** — stays primary admin (accepted residual risk) | 2026-06-11 |
| 2.4 | Which daily roles `adamgoodwin@…` keeps | Keeps Global Admin; optional cleanup of redundant sub-roles | 2026-06-11 |
| 2.5 | `contact@…` target | **Strip all admin now**; low-priv licensed mailbox; agentic power via scoped app identity at Stage 9 | 2026-06-11 |
| 2.6 | Adopt the naming standard in §6? | **Yes, as written** — see legend [IDENTITY_NAMING_STANDARD.md](IDENTITY_NAMING_STANDARD.md) | 2026-06-11 |

---

## 8. Stage 2 done when

Every account has a clear named role (admin / daily human / front door / support /
shared mailbox / alias / guest / future service-agent identity), a tested
break-glass path exists, and there is an agreed, reversible sequence for reducing
unnecessary admin access. Execution of removals can happen in Stage 2 or be staged
deliberately — but only after the safety net is confirmed.
