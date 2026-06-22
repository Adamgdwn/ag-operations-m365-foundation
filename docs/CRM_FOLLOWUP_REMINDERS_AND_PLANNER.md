# CRM Follow-up Reminders + Task Tracking (Planner) — design

> **SUPERSEDED BY THE BACKBONE (2026-06-21).** This CRM-narrow design was the seed,
> but the work was lifted to a workspace-wide capability — see
> **`docs/OPERATIONS_FOLLOWUP_BACKBONE.md`** (canonical). The CRM is now consumer #1
> of a shared engine (`73af86ea-…`), not the owner of a private reminder flow. The
> original one-day-ahead daily flow `8665f8d0-43c7-4067-b2b9-b57e7450ab6d` is **retired
> by the backbone (turned OFF 2026-06-22)**. This doc is kept as the first-consumer
> reference / rationale.

Status: **SUPERSEDED — all three backbone layers now LIVE: email reminders (3 offsets) +
two-way calendar + Planner one-way task tracking, each built & smoke-tested (Planner
end-to-end verified 2026-06-22, 0 residue). The backbone is complete for CRM (consumer #1).**
Raised 2026-06-21 (Adam, during V5). Adam approved building the reminder agentically
("Go", 2026-06-21) — same reverse-engineered Power Platform toolchain as the Path B intake
flows, NOT a hand-clicked template. That reminder grew into the backbone's email layer
(3 offsets), two-way calendar layer, and the now-live Planner layer.

## The shape (agreed)

- **CRM list = system of record.** `CRM - New Signals` holds the signal + its
  `Follow-up date` (FollowUpDueDate) and `Owner` (ItemOwner).
- **Planner = where follow-ups become actionable tasks.** Board/buckets, due dates,
  native notifications. Other tools bolt on and link back into Planner.
- **Microsoft To Do = daily surface.** Planner tasks assigned to you roll up into
  To Do "My Day / Planned" — one place to see what's due today, for free.
- **Lists reminder = the safety-net nudge**, one day before the Follow-up date.

Why Planner over a third-party tracker (Asana/Todoist/ClickUp): it's already in the
tenant, same identity, **zero new vendor / no new consent / data never leaves** —
satisfies Adam's "identically run, governed" bar that an outside tool would break.

## 1. One-day-ahead reminder on Follow-up date — BUILT AGENTICALLY

Built as a small **Power Automate flow** via the same reverse-engineered Power
Platform management API as the Path B intake flows — NOT a hand-clicked Lists
template. (Correction to the earlier draft: Lists has no one-click "Set a reminder"
button on a *list* command bar — that's the OneDrive/library feature. A true
"X days before a date" reminder is always a small standard flow underneath, so we
build it properly and version-control it.)

Artifacts:
- Builder: `scripts/flow-builder/create-reminder-flow.js`
- Launcher: `scripts/flow-builder/Start-FlowBuilder.ps1 -Phase reminder` (visible
  window, so Adam can approve the one Outlook consent).
- Result record (after build): `inventory/forms-build/flow-result-reminder.json`.

**LIVE 2026-06-21** — flow id `8665f8d0-43c7-4067-b2b9-b57e7450ab6d`, state=Started.
Outlook connection `c0eeec32…` created by Adam in-browser; build + idempotent PATCH
done headless. Definition verified (trigger + 4 actions, recipient = Adam, no error).

Flow shape (`GAIL — CRM follow-up reminder (one day ahead)`):
1. **Recurrence** — daily at 07:00 `Mountain Standard Time` (adjust `REMINDER_HOUR`/
   `REMINDER_TZ` in the script + re-run `--headless` if Adam's TZ differs).
2. **SharePoint "Get items"** on `CRM - New Signals`, `$filter` = Follow-up date in
   `[tomorrow, day-after)`. **Read-only** — it never edits or closes a record.
3. **Filter array** drops `Closed`/`Converted` (done in-flow, so a choice-column
   quirk can't break the SharePoint query).
4. **Condition** — only if ≥1 item: build an HTML table and **email Adam only**
   (`adamgoodwin@guidedailabs.com`) a heads-up. No email on an empty day.

Connectors (both Standard, non-premium): **SharePoint** (the existing Path B conn
`4c53f079…`, reused) + **Office 365 Outlook** (new — created during the build).

### Governance: scoped, logged unlock of mail automation
This is the tenant's **FIRST outbound-mail automation** — a class otherwise fenced.
Approved by Adam 2026-06-21 ("Go"). The unlock is scoped to EXACTLY this one flow:
- Recipient = **Adam only**; no external/other recipients.
- **Create-only / read-only** against the CRM list — never writes, edits, deletes,
  or closes a record.
- Standard first-party connectors only; no premium, no app consent, no permission/
  sharing/Dynamics changes.
- **Reversible**: delete the flow (and optionally the Outlook connection) to undo.
This does NOT open mail automation generally — any further mail/notification
automation is a fresh decision under the same flag-with-pro/con model.

### The one human step
Creating the **Office 365 Outlook connection** needs Adam's consent once, in his own
browser — identical to the SharePoint/Forms consents he clicked for Path B. The
builder surfaces a visible window and waits (~4 min) for the connection to go
Connected, then creates the flow automatically. If the auto-click misses the row,
Adam can add "Office 365 Outlook" by hand in the same open window; the poll catches
it. Everything else (token capture, list-GUID resolve, flow definition + POST) is
automated and was dry-run-verified before any tenant write.

To run: `pwsh scripts/flow-builder/Start-FlowBuilder.ps1 -Phase reminder` (or
`node scripts/flow-builder/create-reminder-flow.js` from a signed-in session).
Re-runs PATCH the same flow in place (idempotent via flow-result-reminder.json).

## 2. CRM ↔ Planner bridge — FUTURE WORK (not now)

Direction agreed; build later, after V5 + alignment. Options, cheapest-first:

1. **Manual, link-only (no automation).** When a signal needs a tracked follow-up,
   create a Planner task and paste the CRM item link into it. Re-add a visible
   "Planner task" URL column to `CRM - New Signals` so the round-trip is one click
   each way. (The original schema had a hidden `PlannerTaskUrl`; the clean recovered
   schema dropped it — re-adding a *visible* one is a small, governed column add.)
2. **Assisted creation (later).** A create-only step (same governed pattern as the
   Path B intake flows) that turns a flagged signal into a Planner task. Automation =
   governance-gated; revisit only if manual proves too heavy.

Do NOT auto-close or auto-edit anything from Planner — advisory/manual, matching the
non-destructive working style.

## Sequencing

- Reminder (item 1): scripts written + dry-run-verified 2026-06-21; awaiting the one
  Outlook consent + build run (`-Phase reminder`) to go live.
- Planner bridge (item 2): after V5 acceptance closes and the queued label/reorder
  alignment (`docs/CRM_INTAKE_SURFACE_ALIGNMENT.md`) is applied. Bundle the visible
  "Planner task" column with that schema pass if/when Adam wants it.
