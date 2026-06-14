# Microsoft 365 Stage 5 - Exchange & Communication Routing

Status: **design complete / no tenant writes required yet** (2026-06-14). This is the Stage 5 working document per
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

> **Execution status:** no mailbox, alias, forwarding, calendar, or license
> changes have been made in Stage 5. Read-only inventory is complete and the
> target routing model is documented. Stage 5 does not currently require Exchange
> tenant writes; the next build work is Stage 6 operating-state surfaces.

> **Live inventory complete - 2026-06-14:** read-only Exchange inventory run
> `inventory/stage-5-exchange-current-state/20260614-093257/` completed with no
> tenant writes. Summary:
> [stage-5-exchange-current-state-summary.md](inventory/stage-5-exchange-current-state/20260614-093257/stage-5-exchange-current-state-summary.md).
> Agentic intake design has started in
> [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md).

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

## 3. Live current-state findings - 2026-06-14

Read-only inventory run:

```text
inventory/stage-5-exchange-current-state/20260614-093257/
```

Headline findings:

- 5 total mailboxes were found: 4 normal user mailboxes plus the hidden Discovery
  Search Mailbox.
- 0 shared mailboxes currently exist.
- 0 distribution groups currently exist.
- 5 Microsoft 365 groups exist; all require authenticated senders, so none are
  open external mail targets.
- No mailbox-level forwarding was found on the four decision mailboxes.
- No explicit Full Access mailbox delegates were found.
- No explicit Send As grants were found.
- No Send on Behalf grants were found.
- Calendar processing exported successfully, but the first inventory version did
  not tag each row with its mailbox address. The script has been patched so future
  runs include that mapping.

Decision mailbox snapshot:

| Address | Type | Aliases | Forwarding | Delegation |
|---|---|---|---|---|
| `admin@agoperations.ca` | UserMailbox | `admin@AGOperationsLtd.onmicrosoft.com` | none | none found |
| `adamgoodwin@guidedailabs.com` | UserMailbox | none | none | none found |
| `contact@guidedailabs.com` | UserMailbox | none | none | none found |
| `support@changeleadershiptools.com` | UserMailbox | none | none | none found |

Initial read: the tenant is simpler than feared. There is no forwarding/delegation
cleanup required right now. Stage 5 is therefore a routing and purpose decision,
not an Exchange remediation stage.

Stage 5 closeout posture:

- Keep the four decision addresses as user mailboxes for now.
- Keep `contact@` and `support@` as low-privilege public-facing intake mailboxes.
- Keep existing M365 group addresses authenticated-sender-only and collaboration
  oriented, not public intake surfaces.
- Do not create distribution groups, shared mailboxes, or aliases until there is
  real traffic or a clear workflow need.
- Move operational state out of email through Stage 6 Lists/Planner/Teams.

---

## 4. Stage 5 inventory scope

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

By default the runner uses Exchange Online device-code authentication to avoid
PowerShell host window-handle issues. If running in an interactive host where WAM
works correctly, add `-UseWam`.

For the smooth agent-assisted workflow, prefer the visible launcher whenever
Adam's authorization is needed:

```powershell
pwsh -File .\scripts\Start-M365Stage5ExchangeInventoryInteractive.ps1
```

That opens a visible PowerShell/auth window, uses interactive popup/WAM auth by
default, lets Adam complete sign-in/MFA directly, and then runs the local summary
script after a successful inventory. Use `-UseDeviceCode` with the launcher only
if popup/WAM auth is unreliable.

After a successful run, generate the readable current-state summary:

```powershell
pwsh -File .\scripts\Summarize-M365Stage5ExchangeInventory.ps1
```

---

## 5. Working design principles

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
7. **Human authorization stays visible.** Codex may prepare scripts, run read-only
   local processing, and summarize outputs, but Microsoft sign-in, MFA, consent,
   and tenant-impacting approvals should happen in a visible Adam-controlled
   window.
8. **Design for the future Guided AI Labs bridge.** Exchange should produce clean
   signals for intake, scheduling, support, and commitments, while privileged
   future actions flow through separate scoped app identities and governed
   approval paths.

---

## 6. Keystone decisions

These are the Stage 5 decisions to make after the read-only inventory.

### 5.1 - Mailbox type for `contact@guidedailabs.com`

Options:

| Option | Shape | Rationale |
|---|---|---|
| **A - Keep licensed user for now** | Independent mailbox/calendar/sign-in remains | Best if it will soon be assistant-monitored, own calendar signals, or run user-bound automations. Matches the original build brief. |
| **B - Convert to shared mailbox** | No direct licensed user identity for day-to-day sign-in | Best if it is only a shared reception inbox handled by Adam or a team. Lower license cost and lower account surface. |
| **C - Alias only** | Route to Adam or another mailbox | Best only if `contact@` is a simple vanity address with no independent inbox/history requirement. |

**Decision 5.1:** keep `contact@guidedailabs.com` as a licensed user mailbox for
now. Approved 2026-06-14.

**Inventory-informed recommendation:** keep `contact@guidedailabs.com` as a
licensed user mailbox for now if it is intended to become a monitored Guided AI
Labs front door, scheduling surface, or future assistant-facing mailbox. If it
will only be a shared reception inbox handled by Adam, converting to shared
mailbox is viable because no forwarding/delegation dependencies were found.

### 5.2 - Mailbox type for `support@changeleadershiptools.com`

Options mirror 5.1, but the active product-support context makes the support
workflow more important. Decide whether support history, SLA-like handling, and
future support automation need an independent mailbox or can be handled as shared
mail.

**Decision 5.2:** keep `support@changeleadershiptools.com` as a licensed user
mailbox for now. Approved 2026-06-14.

**Inventory-informed recommendation:** keep `support@changeleadershiptools.com`
as an independent mailbox for now while the Change Leadership Tools support model
is being designed. Convert to shared mailbox later only if support remains a
human-shared inbox with no direct sign-in, product calendar, or scoped automation
ownership requirement.

### 5.3 - Alias map

Decide whether future simple addresses should be aliases, shared mailboxes,
distribution lists, M365 groups, or licensed users. Candidate categories:

| Category | Likely pattern |
|---|---|
| Legal/admin/tax/vendor | `admin@` or specific aliases into an admin-owned mailbox |
| Guided AI Labs inquiries | `contact@` unless separate sales/intake names are justified |
| Product support | `support@changeleadershiptools.com` |
| Future products | Defer until the product has real external traffic |

**Decision 5.3:** use explicit mailbox addresses as public front doors and keep
existing M365 group addresses internal/collaboration-only. No new aliases,
distribution groups, shared mailboxes, or public group addresses are needed right
now. Approved by Stage 5 design posture 2026-06-14.

**Inventory-informed recommendation:** do not use existing M365 group addresses
as external front doors. They are currently authenticated-sender-only and tied to
collaboration/site structures, which is the right posture for now. Keep public
intake on explicit mailbox addresses.

Target map:

| Address/surface | Purpose | External? | Current action |
|---|---|---|---|
| `contact@guidedailabs.com` | Guided AI Labs public inquiry/intake | Yes | Keep as licensed user mailbox |
| `support@changeleadershiptools.com` | Change Leadership Tools product support | Yes | Keep as licensed user mailbox |
| `admin@agoperations.ca` | Admin/legal/vendor/tax/tenant backbone | Selective | Keep controlled; not a public front door |
| `adamgoodwin@guidedailabs.com` | Adam's person-to-person work mailbox | Yes | Keep as human mailbox and calendar |
| M365 group addresses | Site/team collaboration mail surfaces | No | Keep authenticated-sender-only |
| Future simple aliases | Vanity/routing convenience only | TBD | Defer until traffic justifies them |

### 5.4 - Calendar ownership

Decide which calendars are real scheduling surfaces. Starting assumption:

- `adamgoodwin@...` = Adam's real calendar.
- `contact@...` may need a front-door/scheduling calendar if future assistant
  scheduling is real.
- `support@...` likely does not need a general calendar unless product support
  appointments become part of the workflow.
- `admin@...` should avoid becoming a daily scheduling surface.

**Decision 5.4:** Adam's `adamgoodwin@guidedailabs.com` calendar remains the real
scheduling surface. `contact@` may be used later as an intake/scheduling signal
mailbox, but it does not become an autonomous booking calendar now. `support@`
does not need a calendar now. `admin@` must not become a daily scheduling surface.
Approved by Stage 5 design posture 2026-06-14.

Calendar map:

| Mailbox | Calendar posture | Agentic implication |
|---|---|---|
| `adamgoodwin@guidedailabs.com` | Real calendar for meetings and commitments | Agent may draft scheduling options, but Adam approves bookings |
| `contact@guidedailabs.com` | Intake/scheduling signal only for now | Agent may classify scheduling requests and draft proposed times |
| `support@changeleadershiptools.com` | No general calendar now | Add only if product support appointments become real |
| `admin@agoperations.ca` | Avoid daily scheduling | Legal/admin reminders become tasks, not calendar ownership |

### 5.5 - Intake routing and record capture

Decide what happens after important email arrives:

| Intake | Durable home |
|---|---|
| AG Operations legal/admin | AG Operations SharePoint site |
| Guided AI Labs consulting/client inquiry | Guided AI Labs or Guided AI Journey site, depending on lifecycle |
| Change Leadership Tools support | Change Leadership Tools site; later Lists/Planner in Stage 6 |
| Reusable methods/assets | Shared Libraries site |

**Decision 5.5:** email is the signal layer; durable state moves to SharePoint
and, in Stage 6, Lists/Planner/Teams. Approved by Stage 5 design posture
2026-06-14.

Target routing:

| Intake | First mailbox | Triage class | Durable home | Stage 6 state |
|---|---|---|---|---|
| Guided AI Labs inquiry | `contact@` | `new-inquiry` / `client-readiness` | Guided AI Labs or Guided AI Journey SharePoint | Guided AI Labs Intake Register + Planner task when action exists |
| Scheduling request | `contact@` or Adam | `scheduling` | Calendar decision note if material | Intake Register item, Adam-approved calendar action |
| Existing client commitment | Adam or `contact@` | `decision-or-commitment` | Correct client/project SharePoint location | Decision Register + Planner task |
| Change Leadership Tools support | `support@` | `support-request` | Change Leadership Tools SharePoint | Support Register; Planner only for action-bearing items |
| Reusable method/IP | any mailbox | `knowledge-candidate` | Shared Libraries | Candidate queue / Decision Register if approved |
| Admin/legal/vendor | `admin@` | `admin-legal` | AG Operations SharePoint | Admin task if action required |

---

## 7. Build sequence

1. ~~Run read-only Exchange inventory through the visible authorization launcher.~~
2. ~~Generate and review the Stage 5 current-state summary from the inventory.~~
3. ~~Decide mailbox type and license posture for `contact@` and `support@`.~~
4. ~~Decide alias/forwarding/calendar model.~~
5. Design Stage 6 intake/support Lists, Planner buckets, Teams channels, and Agent
   Action Log from
   [GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md](GUIDED_AI_LABS_AGENTIC_INTAKE_MODEL.md).
6. Execute only approved tenant changes, one at a time, with read-back verification.
7. Update [00_INDEX.md](00_INDEX.md), this document, and any new inventory summary.

---

## 8. Decision log

| # | Decision | Status | Date |
|---|---|---|---|
| 5.1 | `contact@guidedailabs.com` mailbox type | keep licensed user mailbox for now | 2026-06-14 |
| 5.2 | `support@changeleadershiptools.com` mailbox type | keep licensed user mailbox for now | 2026-06-14 |
| 5.3 | Alias/group/shared-mailbox map | no new aliases/groups/shared mailboxes now; public intake stays on explicit mailbox addresses | 2026-06-14 |
| 5.4 | Calendar ownership | Adam's mailbox remains real calendar; `contact@` is intake/scheduling signal only for now | 2026-06-14 |
| 5.5 | Intake routing and durable record capture | email is signal layer; durable state moves to SharePoint + Stage 6 Lists/Planner/Teams | 2026-06-14 |

---

## 9. Execution log

| Date | Action | Method | Result |
|---|---|---|---|
| 2026-06-12 | Started Stage 5 working doc and added a read-only Exchange inventory runner | Repo documentation + script only | No tenant changes. Next live action is read-only sign-in/inventory. |
| 2026-06-14 | Updated inventory runner auth posture and added local inventory summarizer | Script updates only | No tenant changes. Runner now defaults to device-code auth; summarizer writes Markdown from completed inventory JSON. |
| 2026-06-14 | Added visible authorization launcher and recorded human-auth pattern | Script + documentation updates only | No tenant changes. Future auth prompts should be surfaced in a visible Adam-controlled window. |
| 2026-06-14 | Ran read-only Exchange inventory and generated current-state summary | Visible authorization launcher + Exchange Online PowerShell | No tenant changes. Inventory found 4 user mailboxes, 0 shared mailboxes, no forwarding, no explicit mailbox/recipient delegation, and 5 authenticated-sender-only M365 groups. |
| 2026-06-14 | Approved mailbox posture for `contact@` and `support@` | Documentation decision only | No tenant changes. Both remain licensed user mailboxes for now to preserve direct sign-in, calendar, and future scoped automation options. |
| 2026-06-14 | Started Guided AI Labs agentic intake design | Documentation only | No tenant changes. New model bridges Stage 5 mailboxes, Stage 6 operating state, and Stage 9 agent bridge readiness. |
| 2026-06-14 | Closed remaining Stage 5 routing decisions | Documentation decision only | No tenant changes. No new aliases/groups/shared mailboxes now; Adam calendar remains primary; durable intake state moves to Stage 6 surfaces. |
