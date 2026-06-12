# Microsoft 365 Stage 5 - Exchange & Communication Routing

Status: **started** (2026-06-12). This is the Stage 5 working document per
[M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md). Orientation lives in
[00_INDEX.md](00_INDEX.md). Identity/admin safety is complete in
[M365_STAGE_2_IDENTITY_FOUNDATION.md](M365_STAGE_2_IDENTITY_FOUNDATION.md);
SharePoint record homes are complete in
[M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md](M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md);
local/browser lanes are complete in
[M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md](M365_STAGE_4_ONEDRIVE_LOCAL_DOVETAIL.md).

**Golden rule for this stage: email is a signal and intake layer, not the hub.**
Exchange routes communication to the correct owner, calendar, mailbox, SharePoint
record home, support workflow, or future scoped agent. Do not turn public-facing
mailboxes into broad capability surfaces.

> **Execution status - inventory phase:** no mailbox, alias, forwarding, calendar,
> or license changes have been made in Stage 5. The first concrete step is a
> read-only Exchange inventory using
> [scripts/Invoke-M365Stage5ExchangeInventory.ps1](scripts/Invoke-M365Stage5ExchangeInventory.ps1).

---

## 1. Why Exchange comes after Stages 2-4

Stage 2 made the identities safe enough to reason about. Stage 3 created the
official record homes. Stage 4 separated the local/browser working lanes. Now
Exchange can be shaped deliberately: which addresses receive communication, who
owns the calendar, where commitments get recorded, and which mailboxes may later
be monitored by an agent through a scoped app identity.

The Stage 2 principle still controls the design:

```text
interaction surface != capability surface
```

Mailboxes that receive untrusted external messages stay low-privilege. Future
automation acts through a separate, scoped, audited app registration.

---

## 2. Known current communication identities

From Stage 1 inventory and Stage 2 decisions:

| Address | Current interpretation | Current posture |
|---|---|---|
| `admin@agoperations.ca` | Admin/legal/backbone address and secondary admin identity | Licensed user, Global Administrator |
| `adamgoodwin@guidedailabs.com` | Adam's daily operator identity and primary admin | Licensed user, Global Administrator accepted risk |
| `contact@guidedailabs.com` | Guided AI Labs front door / future assistant-monitored mailbox | Licensed user, no admin roles after Stage 2 |
| `support@changeleadershiptools.com` | Change Leadership Tools product support identity | Licensed user, no admin roles |

Stage 5 needs live Exchange inventory before changing any of these. Stage 1 used
Graph inventory and did not deeply inspect mailbox types, aliases, forwarding,
mailbox permissions, Send As grants, Send on Behalf grants, or calendar processing.

---

## 3. Stage 5 inventory scope

The read-only inventory should answer:

- Which mailboxes exist, and what type are they?
- Which aliases/proxy addresses exist on each mailbox?
- Are any forwarding rules or mailbox-level forwarding settings present?
- Are any delegates, Send As, or Send on Behalf grants present?
- Are any distribution groups, Microsoft 365 groups, or mail contacts present?
- What are the calendar-processing settings for the main mailboxes?
- Which identities are licensed users today but could later become shared mailboxes
  or aliases?

The first runner is:

```powershell
pwsh -File .\scripts\Invoke-M365Stage5ExchangeInventory.ps1
```

It is read-only and exports JSON under:

```text
inventory/stage-5-exchange-current-state/<timestamp>/
```

---

## 4. Working design principles

1. **Person mail is for the person.** `adamgoodwin@...` is Adam's daily work
   mailbox, calendar, meeting identity, and normal external communication address.
2. **Admin mail is not the front door.** `admin@agoperations.ca` should stay an
   admin/legal/backbone identity, not the public inquiry or support intake address.
3. **Front-door mailboxes stay low-privilege.** `contact@...` and `support@...`
   receive untrusted external input, so they do not hold admin roles. Stage 2 has
   already enforced this for `contact@`.
4. **Shared mailbox vs licensed user is a capability decision.** Use a shared
   mailbox or alias for simple shared receipt. Keep a licensed user only when the
   address needs direct sign-in, its own calendar, automation ownership, or future
   assistant behavior.
5. **Commitments leave email.** Decisions, deliverables, support knowledge, and
   official records should be captured in the Stage 3 SharePoint sites or later
   Planner/Lists surfaces, not left only in inboxes.
6. **No forwarding surprises.** Forwarding can be useful, but every mailbox-level
   forward should be intentional and documented.

---

## 5. Keystone decisions

These are the Stage 5 decisions to make after the read-only inventory.

### 5.1 - Mailbox type for `contact@guidedailabs.com`

Options:

| Option | Shape | Rationale |
|---|---|---|
| **A - Keep licensed user for now** | Independent mailbox/calendar/sign-in remains | Best if it will soon be assistant-monitored, own calendar signals, or run user-bound automations. Matches the original build brief. |
| **B - Convert to shared mailbox** | No direct licensed user identity for day-to-day sign-in | Best if it is only a shared reception inbox handled by Adam or a team. Lower license cost and lower account surface. |
| **C - Alias only** | Route to Adam or another mailbox | Best only if `contact@` is a simple vanity address with no independent inbox/history requirement. |

**Decision 5.1:** _pending live inventory._

### 5.2 - Mailbox type for `support@changeleadershiptools.com`

Options mirror 5.1, but the active product-support context makes the support
workflow more important. Decide whether support history, SLA-like handling, and
future support automation need an independent mailbox or can be handled as shared
mail.

**Decision 5.2:** _pending live inventory._

### 5.3 - Alias map

Decide whether future simple addresses should be aliases, shared mailboxes,
distribution lists, M365 groups, or licensed users. Candidate categories:

| Category | Likely pattern |
|---|---|
| Legal/admin/tax/vendor | `admin@` or specific aliases into an admin-owned mailbox |
| Guided AI Labs inquiries | `contact@` unless separate sales/intake names are justified |
| Product support | `support@changeleadershiptools.com` |
| Future products | Defer until the product has real external traffic |

**Decision 5.3:** _pending._

### 5.4 - Calendar ownership

Decide which calendars are real scheduling surfaces. Starting assumption:

- `adamgoodwin@...` = Adam's real calendar.
- `contact@...` may need a front-door/scheduling calendar if future assistant
  scheduling is real.
- `support@...` likely does not need a general calendar unless product support
  appointments become part of the workflow.
- `admin@...` should avoid becoming a daily scheduling surface.

**Decision 5.4:** _pending._

### 5.5 - Intake routing and record capture

Decide what happens after important email arrives:

| Intake | Durable home |
|---|---|
| AG Operations legal/admin | AG Operations SharePoint site |
| Guided AI Labs consulting/client inquiry | Guided AI Labs or Guided AI Journey site, depending on lifecycle |
| Change Leadership Tools support | Change Leadership Tools site; later Lists/Planner in Stage 6 |
| Reusable methods/assets | Shared Libraries site |

**Decision 5.5:** _pending._

---

## 6. Build sequence

1. Run read-only Exchange inventory.
2. Write a Stage 5 current-state summary from the inventory.
3. Decide mailbox type and license posture for `contact@` and `support@`.
4. Decide alias/forwarding/calendar model.
5. Execute only the approved changes, one at a time, with read-back verification.
6. Update [00_INDEX.md](00_INDEX.md), this document, and any new inventory summary.

---

## 7. Decision log

| # | Decision | Status | Date |
|---|---|---|---|
| 5.1 | `contact@guidedailabs.com` mailbox type | pending inventory | - |
| 5.2 | `support@changeleadershiptools.com` mailbox type | pending inventory | - |
| 5.3 | Alias/group/shared-mailbox map | pending | - |
| 5.4 | Calendar ownership | pending | - |
| 5.5 | Intake routing and durable record capture | pending | - |

---

## 8. Execution log

| Date | Action | Method | Result |
|---|---|---|---|
| 2026-06-12 | Started Stage 5 working doc and added a read-only Exchange inventory runner | Repo documentation + script only | No tenant changes. Next live action is read-only sign-in/inventory. |

