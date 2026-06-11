# Identity Naming Standard — Legend & Reference

**AG Operations / Guided AI Labs — Microsoft 365**
Adopted 2026-06-11 (Stage 2 decision 2.6). This is the canonical legend for how
every identity in the tenant is named, what each type means, and how much power it
is allowed to hold. When in doubt about naming or creating any account, app, or
mailbox — start here.

Related: [00_INDEX.md](00_INDEX.md) ·
[M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md)

---

## The one rule behind the whole legend

> **Interaction surface ≠ capability surface.**
> The identity that *receives* untrusted input (email, chat, requests) is kept
> low-privilege. The ability to *do* powerful things lives in a separate, scoped,
> audited identity. Never combine "receives untrusted input" with "holds broad
> admin" in the same account.

---

## Legend — identity types at a glance

| Type | Pattern / prefix | Example | What it is | Privilege posture | Licensed? |
|---|---|---|---|---|---|
| **Human (person)** | person name | `adamgoodwin@guidedailabs.com` | A real person's everyday working identity | Only what the person genuinely needs. (Exception in effect: `adamgoodwin@` keeps Global Admin as primary admin — an accepted, documented risk.) | Yes |
| **Controlled admin** | `admin@` | `admin@agoperations.ca` | A deliberate administration account (here: the secondary/backup admin) | Global Administrator; used on purpose, not for daily browsing/email | Yes |
| **Emergency access (break-glass)** | `breakglass-NN@…onmicrosoft.com` | `breakglass-01@AGOperationsLtd.onmicrosoft.com` | Last-resort recovery accounts, held in reserve, never used day to day | Global Administrator, cloud-only; credentials + MFA recovery stored **offline**, never in this repo | No (GA needs no license) |
| **Shared mailbox / function alias** | function name | `contact@`, `support@`, `billing@` | A role/function address not tied to one person | No admin roles; mailbox only | Shared mailbox = no license; alias = none |
| **Service account** | `svc-` | `svc-graph-inventory@…` | A non-human account running a defined automated job, used **only** when an app registration can't do it | Least-privilege, exactly the scopes the job needs; no interactive daily use | As required by the job |
| **App registration / agent capability** | `agent-` (app display name) | `agent-contact-bridge` | The **preferred** way automation/agents get power: an app identity with scoped Microsoft Graph permissions | Least-privilege **application permissions**, explicit + audited + revocable; secret/cert **vaulted** | n/a (not a user) |
| **Guest** | external, by invite | `name_contoso.com#EXT#@…` | An external collaborator invited into the tenant | Lowest necessary; reviewed periodically | No |

---

## How to read "privilege posture"

- **Least-privilege** means: grant the specific permission the task needs, nothing
  broader, and remove it when no longer needed. Reversible by design.
- **Standing Global Admin** is reserved for: the controlled/primary admin
  account(s) and the break-glass reserve — and nothing that receives untrusted
  external input.
- For agents/automation, **prefer an app registration (`agent-…`) over a real user
  account.** An app identity has no interactive password to phish and its
  permissions are explicit and auditable. A `svc-` user account is only a fallback
  for the rare case an app registration can't perform the task.

---

## Decision shortcut — "what do I name this?"

```text
Is it a real person?                         -> person name (human identity)
Is it for deliberate tenant administration?  -> admin@  (controlled admin)
Is it a last-resort recovery account?        -> breakglass-NN@…onmicrosoft.com
Does it receive email/requests for a role?   -> function name (contact@, support@…)
Is it automation/an agent doing work?
   - can an app registration do it?  YES      -> app registration, agent-… (PREFERRED)
   - truly needs a user account?     YES      -> svc-… (least-privilege, fallback)
Is it an outside collaborator?               -> guest (invite, lowest privilege)
```

---

## Current identities mapped to this legend (as of 2026-06-11)

| Account | Type per legend | Target posture |
|---|---|---|
| `adamgoodwin@guidedailabs.com` | Human + primary admin | Keeps Global Admin (accepted risk) |
| `admin@agoperations.ca` | Controlled admin | Global Admin, secondary/backup |
| `contact@guidedailabs.com` | Shared/function → future agent-operated | Strip all admin; low-priv mailbox |
| `support@changeleadershiptools.com` | Shared/function | No admin (already clean) |
| `breakglass-01/02@…onmicrosoft.com` | Emergency access (to be created) | Global Admin, offline creds |
| `AG Operations Agentic Partner` (app `2d0c6ba1-…`) | App registration | Keep as setup/helper; scoped, not a broad bridge yet |

This legend is the convention for all later stages — apply it whenever a new
identity is created.
