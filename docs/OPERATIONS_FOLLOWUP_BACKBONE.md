# Operations Follow-up & Task Backbone — design (cross-workspace)

Status: **PARTIALLY LIVE — email + calendar layers built, proven, and running;
Planner layer is the only remaining piece.** Raised by Adam 2026-06-21 as a
deliberate altitude change: do **not** build a CRM-only reminder. Build a
**workspace-wide follow-up / task / calendar backbone** — a broad, solid base of
the pyramid that the CRM is merely the *first consumer* of, and that onboarding +
the remaining operating functions plug into later **without rebuilding anything**.

> **BUILD PROGRESS (2026-06-21).** The engine flow is LIVE/Started:
> `73af86ea-18d2-4bc4-9cd0-aa03a461b800` ("GAIL — Operations follow-up engine"),
> built idempotently by `scripts/flow-builder/create-followup-engine-flow.js`, polling
> `Every_15_min`.
> - **Email reminder layer — DONE & verified.** Three offsets ("1 day before",
>   "30 minutes before", "Day after") send per `op_Reminders`; all three landed in
>   live smoke test, test records cleaned up.
> - **Calendar two-way layer — DONE & verified (all four directions).** Proven live via
>   `scripts/flow-builder/calendar-smoke-test.js`: **create** (tick Calendar → event
>   appears), **push** (CRM date moves → event moves), **pull** (drag event in Outlook →
>   CRM date follows), **teardown** (untick `op_TrackOn` / close → event deleted, key
>   cleared). Full cycle ran end-to-end then deleted the throwaway record — 0 residue.
>   Loop-safe via the `op_LastSyncedDue` shadow + >1-min tolerance.
> - **Planner layer — LIVE + END-TO-END VERIFIED (2026-06-22).** The hub-driven one-way
>   layer (CRM → Planner: create assigned task / push due / teardown on untrack or close) is
>   now active in the deployed engine. Consent session done: the **Planner** + **Office 365
>   Users** standard connections are Connected (added by hand — the create-connections.js
>   auto-clicker proved flaky over CDP; verified with `verify-connections.js`). The
>   **"CRM Follow-ups"** plan was **created via Graph** (silent delegated token, no app
>   registration) in the GuidedAILabs M365 group — `planner.groupId` =
>   `db49e096-5a34-48c5-9037-0f32c22bbda8`, `planner.planId` = `ukV82eUE7kqJ3aSZeL9B6n0AAyng`,
>   both written into the registry by `resolve-planner-ids.js --write`. The engine was rebuilt
>   (PATCH 200, Started, "Planner layer: ACTIVE"), and `planner-smoke-test.js` proved all three
>   behaviors against the live flow — **create** (task created + assigned, `op_PlannerTaskId`
>   stored, shadow stamped), **movecrm** (CRM due +90 min → task updated in place, shadow
>   follows), **untrack** (task deleted, id cleared) — last run Succeeded, throwaway record
>   deleted → 0 residue.
> - The old daily flow `8665f8d0-43c7-4067-b2b9-b57e7450ab6d` is **RETIRED** — turned OFF
>   (Started → Stopped, reversible, not deleted) via the new reusable
>   `scripts/flow-builder/set-flow-state.js <flowId> start|stop`. **All three engine layers
>   (email + calendar two-way + Planner one-way) are now live and coexisting cleanly; the
>   backbone is complete for consumer #1 (CRM).**

> Adam, 2026-06-21: *"Putting this narrowly into the CRM would be detrimental…
> this needs to be a higher level work scope because it is going to touch almost
> all aspects of this SharePoint."*

This supersedes the CRM-narrow design in `docs/CRM_FOLLOWUP_REMINDERS_AND_PLANNER.md`
(kept as the first-consumer reference). The old one-day-ahead daily flow
(`8665f8d0-43c7-4067-b2b9-b57e7450ab6d`) has been **retired** (turned OFF 2026-06-22) —
this backbone now fully replaces it.

---

## 1. The decisions that shaped this (Adam, 2026-06-21)

| Decision | Choice | Consequence |
|---|---|---|
| Ownership | **Multi-operator now** | Tasks/events are *per owner*, not Adam-only. Drives the assignment + calendar mechanism in §4. |
| Where it lives | **Workspace-level backbone**, not in the CRM | Reusable column set + one shared sync engine + a config registry of participating lists. |
| Default behaviour | **Opt-in per signal** | Nothing syncs unless the operator ticks it. Keeps calendars/boards uncluttered (more-with-less). |
| Control surface | **Two fields**: *Reminders* (email offsets) + *Track on* (Calendar / Planner) | Two clean Choice columns added to each participating list. |

Research grounding (why these are the safe patterns, not compromises):
- **A SharePoint list as the hub beats app-to-app sync** for reliability — the hub
  holds the foreign keys and the truth.
- **Scheduled polling avoids the SharePoint infinite-loop trap** that change-triggers
  fall into; write-only-when-different + a stored "last-synced" shadow closes the loop.
- **Two-way sync without duplicates requires storing the foreign IDs** (Outlook event
  id, Planner task id) on the hub record.

---

## 2. The pyramid: one base, many consumers

```
                 ┌─────────────────────────────────────────┐
   consumers →   │  CRM - New Signals  │ Onboarding │ …9 fns │
                 └─────────────────────────────────────────┘
                            ▲ adopt the same column contract ▲
   base      →   ┌─────────────────────────────────────────┐
                 │   OPERATIONS FOLLOW-UP & TASK BACKBONE    │
                 │  • column contract (site columns + CT)    │
                 │  • one scheduled sync engine (15-min)     │
                 │  • registry: which lists, which targets   │
                 │  • two-way date sync, loop-safe           │
                 └─────────────────────────────────────────┘
                  SharePoint (hub) · Outlook calendar · Planner · To Do (free)
```

A new function joins the backbone by **(a)** adding the column contract to its list
and **(b)** adding one row to the registry. **No new flow, no new code.** That is the
"do more with the solid base" property.

---

## 3. The column contract (defined once, reused everywhere)

Provisioned **once** as **site columns + a "Operations Follow-up" content type** on the
GuidedAILabs site, so the definition lives in one place and any list adopts it by
adding the content type. The engine reads field names **per list from the registry**,
so a list that already has its own date/owner columns keeps them (non-destructive).

| Role | Canonical site column | Type | Operator-facing? | Notes |
|---|---|---|---|---|
| Due date | `op_FollowUpDue` | DateTime | yes | The two-way field. CRM **maps this to its existing `FollowUpDueDate`** — no rename. |
| Owner | `op_Owner` | Person | yes | CRM **maps to existing `ItemOwner`**. Drives task assignment + calendar attendee. |
| Email reminders | `op_Reminders` | Choice (multi) | yes | `1 day before`, `30 minutes before`, `Day after`. Optional. |
| Sync targets | `op_TrackOn` | Choice (multi) | yes | `Calendar`, `Planner`. Optional. This is the per-record opt-in. |
| Calendar key | `op_CalendarEventId` | Text | no | Foreign key to the Outlook event. |
| Planner key | `op_PlannerTaskId` | Text | no | Foreign key to the Planner task. |
| Sync shadow | `op_LastSyncedDue` | DateTime | no | Last value the engine wrote everywhere. The loop-breaker. |
| Sync note | `op_SyncNote` | Text | no | Last sync result / error, for observability. |

**For the CRM list specifically**, the gated schema apply adds the 6 new columns
(`op_Reminders`, `op_TrackOn`, `op_CalendarEventId`, `op_PlannerTaskId`,
`op_LastSyncedDue`, `op_SyncNote`) and maps due/owner to the existing
`FollowUpDueDate` / `ItemOwner`. The 4 technical columns are hidden
(`ShowInNewForm=false`, `ShowInEditForm=false`) — same rule as the existing blocked
fields — so the **Chunk-3 verifier's expected schema is updated** to include them as
*hidden-allowed*, and verify still passes. (Note: the original schema already
reserved a `PlannerTaskUrl` — this is its proper, generalised return.)

---

## 4. Multi-operator without an app-consent escalation (the key move)

> **UPDATE 2026-06-21 — Adam chose mailbox *delegation* over the attendee trick for the
> calendar surface.** Asked how far to take calendar write access, Adam: *"I want this to
> be as robust and thorough as possible… let's not fret about the graph app registration
> mailbox delegation fencing… I don't see any major risk to it."* After laying out the
> real distinction, he selected **mailbox delegation** (not the heavier Graph app
> registration). What this changes:
> - **Calendar now lives on each owner's *own* calendar directly**, not as an attendee
>   copy of a central event. The automation account is granted **Editor** on each
>   operator's calendar (admin `Add-MailboxFolderPermission`, one line per operator), and
>   the **standard** Office 365 Outlook connector creates/updates/reads that calendar by
>   id. This makes the owner's personal calendar a **true two-way reschedule surface**
>   (drag the event → engine reads the new start → writes back to the CRM date).
> - **No central operations calendar artifact is needed** — each follow-up event is the
>   owner's own. (`centralCalendar` in the registry is therefore retired/null.)
> - **No standing tenant credential**: delegation is per-named-calendar, not a tenant-wide
>   `Calendars.ReadWrite` app grant, so there is no secret to leak and no premium connector.
>   The Graph app registration in §8 remains the documented heavier graduation, still
>   unused.
> - **v1 scope**: Adam is both the automation account *and* operator #1, so his own
>   calendar needs **no delegation** — the connector writes to his default calendar and the
>   smoke-test validates the mechanics there. Delegation grants happen per operator as
>   operator #2+ join (their calendar id is registered then). Until an operator's calendar
>   is registered, their events fall back to Adam's calendar with a note.
> - **Planner is unchanged** by this: assignment (email→AAD id via Office 365 Users) still
>   does the per-operator personalisation, free, no grant.
>
> The original attendee-trick design below is retained as the documented fallback for any
> mailbox that cannot grant delegate access.

"Multi-operator now" normally implies writing into *each* person's mailbox/plan,
which points at a **Graph app registration with application `Calendars.ReadWrite` /
`Tasks.ReadWrite`** — i.e. admin consent + a tenant-wide grant to read/write *every*
mailbox. That is exactly the app-consent / permission class we keep fenced, and it's
a heavy security surface for a v1. We can deliver true multi-operator **without** it:

**Planner (tasks) — assignment does the personalisation, natively + free.**
The engine creates the task in a **group Planner plan** and sets *Assigned To* = the
signal's Owner (resolve email→AAD id via the standard *Office 365 Users* connector).
Assigned tasks automatically surface in **that operator's** Planner "Assigned to me"
**and** roll up into their **Microsoft To Do** "Assigned to me / Planned." No per-mailbox
write, no app grant — standard connector, one connection.

**Calendar — the attendee trick puts it on the owner's *own* calendar.**
The engine creates **one event on a central operations calendar** and adds the Owner
as a **required attendee**. Through the normal meeting-invite mechanism the event then
appears on **the owner's personal calendar** (with their own native reminder + snooze),
on every device — again with **no mailbox-write permission and no app registration**.
The operator can even accept/decline. Standard *Office 365 Outlook* connector, one
connection (Adam's now; a dedicated service identity later — see §8).

> Result: genuine multi-operator personalisation (their tasks in their To Do, the
> event on their calendar) using **only standard first-party connectors and the
> existing scoped-unlock model** — no admin consent, no tenant-wide mailbox grant.
> The Graph-app path is documented in §8 as a deliberate future *graduation* if
> per-mailbox precision is ever required; it is **not** in the base.

---

## 5. The sync engine (one scheduled flow, loop-safe)

A single **15-minute Recurrence** flow (timezone-independent — all offsets are
relative). For every participating list in the registry, for every item that has a
due date and is open:

**5a. Email reminders (stateless).** For each ticked `op_Reminders` offset, compute
`minutesUntilDue = (ticks(due) - ticks(now)) / 600000000` and fire one email to the
**owner** when the window is hit:
- `1 day before` → minutesUntil ∈ [1440, 1455)
- `30 minutes before` → [30, 45)
- `Day after` → [-1440, -1425)

Window width == recurrence interval (15 min) ⇒ **exactly-once** per offset, no dedup
state. (±15-min precision accepted; a rare drift-miss is preferred over a double-send.)

**5b. Calendar + Planner sync (stateful, two-way on the date only).**
- **Create** (target ticked, no stored id): make the event/task, store
  `op_CalendarEventId` / `op_PlannerTaskId`, set `op_LastSyncedDue = due`.
- **Two-way date reconcile** (id exists): read the event's start and the task's due.
  Compare each to `op_LastSyncedDue` (the shadow):
  - If exactly one of {CRM due, event start, task due} changed vs the shadow →
    **propagate that new value to the other two**, set shadow = new value. After
    this, all three == shadow ⇒ next poll sees no change ⇒ **no loop.**
  - If two changed and disagree → **conflict → most-recently-modified wins** (each
    system carries a native modified timestamp), propagate, note it in `op_SyncNote`.
- **Untick / close / clear date** → delete the event + task, clear the ids.
- **Safety:** the engine only ever touches events/tasks **it created** (matched by the
  stored id), never the operator's other calendar entries or tasks.

> *Only the date/time is bidirectional.* Everything else (status, person, notes,
> priority) flows **one-way** out from the hub — that one-field discipline is what
> keeps the sync free of conflict storms and echo loops.

---

## 6. The config registry

`config/followup.registry.json` — the list of participating lists and where each one
points. Adding a function = adding a row here (plus the content type on its list).

```jsonc
{
  "version": "2026-06-21-backbone-v1",
  "centralCalendarId": "<operations calendar id>",
  "lists": [
    {
      "key": "crm-new-signals",
      "site": "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
      "listTitle": "CRM - New Signals",
      "fieldMap": { "due": "FollowUpDueDate", "owner": "ItemOwner",
                    "title": "Title", "status": "SignalStatus" },
      "openWhen": "status not in [Closed, Converted]",
      "plannerPlanId": "<CRM follow-ups plan id>",
      "plannerBucket": "by-priority"
    }
    // onboarding, …other functions added here later — no code change
  ]
}
```

Whether each function gets its **own** Planner plan / calendar or shares a central one
is a per-row choice — the backbone supports both, so "touches all aspects of
SharePoint" stays a config decision, not a rebuild.

---

## 7. Governance — what needs your explicit YES before any build

This backbone widens automation beyond "email Adam only." Each item below is a fresh,
scoped, reversible unlock under your flag-with-pro/con model, logged to named artifacts:

1. **Schema apply (gated, `apply-gail-crm-recovery`)** — add the 6 backbone columns to
   `CRM - New Signals` + the site-column/content-type set; update the Chunk-3 verifier's
   expected schema so the 4 hidden technical columns pass as hidden-allowed.
2. **Write-back to the SharePoint hub** — the engine writes **one field** (`due`) and the
   technical keys/shadow on the list item. Crosses the prior "read-only on the CRM" line,
   but is value-diff-guarded and field-scoped. Reversible.
3. **Calendar writes — via mailbox delegation (Adam, 2026-06-21).** Create/update/delete
   events **on each owner's own calendar** (events the engine created only, matched by the
   stored event id). The automation account is granted **Editor** on each operator's
   calendar via admin `Add-MailboxFolderPermission` — **per-named-calendar, not a tenant
   grant**. Standard Office 365 Outlook connector only. **No Graph app registration, no
   tenant-wide `Calendars.ReadWrite`, no secret, no premium connector.** Scope is limited
   to: the engine flow, the events it created, and the explicitly-delegated operator
   calendars. v1 touches only Adam's own calendar (no delegation needed). *(Supersedes the
   central-calendar + attendee-invite mechanism originally proposed in this slot.)*
4. **Planner writes** — create/update/delete/assign tasks in the group plan(s). Standard
   connector. Assignment drives the per-operator To Do rollup.
5. **Mail to owners (not just Adam)** — the reminder emails now go to each signal's
   **Owner**, not solely Adam. A widening of the existing scoped mail unlock.

Now **in scope (Adam, 2026-06-21):** mailbox **delegation** — granting the automation
account Editor on a named operator calendar via `Add-MailboxFolderPermission` — so the
standard connector can two-way-sync each operator's own calendar.

Explicitly **out of scope / still fenced:** Graph **app registration**, **application/
tenant-wide** mailbox permissions (`Calendars.ReadWrite` as Application), premium
connectors, Dataverse, external sharing, guest invites, auto-outreach to signal subjects,
any auto-close/auto-edit of business fields. (Delegation ≠ app permission: delegation is
per-named-calendar and rides the existing connection; it does not create a standing
tenant credential.)

---

## 8. Future graduations (documented, not built)

- **Dedicated service identity** for the connections (instead of Adam's personal
  connection), so the backbone isn't tied to one person's session. Small licensing
  decision.
- **Graph app registration** with application `Calendars.ReadWrite` / `Tasks.ReadWrite`
  — only if per-mailbox calendar precision (vs the attendee-invite model) ever becomes a
  hard requirement. Requires admin consent: a separate, deliberate escalation.
- **More consumers** — onboarding and the other operating functions, each a registry row.
- **CRM ↔ Planner richer bridge** (buckets by stage, progress write-back beyond the date)
  — revisit once the base has proven out.

---

## 9. Build sequence (after approvals)

1. Provision site columns + "Operations Follow-up" content type (gated apply).
2. Add the contract to `CRM - New Signals`; update the Chunk-3 verifier expected schema.
3. Write `config/followup.registry.json` with the CRM row + create the central calendar
   and the first Planner plan.
4. Build the engine flow (reverse-engineered Power Platform toolchain, same as Path B):
   email layer (5a) first, **smoke-test**, then the calendar+Planner two-way layer (5b),
   **smoke-test create→move→delete on a throwaway signal**.
5. Retire the old daily reminder flow `8665f8d0…`.
6. Update `docs/CRM_FOLLOWUP_REMINDERS_AND_PLANNER.md` to point here; log the unlocks.

Verification is **two-staged on purpose** (email layer, then sync layer) so a
calendar/Planner-write bug can't hide behind an alert bug.

---

## 9a. Planner layer — consent-session runbook (EXECUTED 2026-06-22 ✅)

> **DONE — all steps below were run on 2026-06-22; the Planner layer is LIVE and verified.**
> Kept as the reproducible record + the template for onboarding future operators/connectors.
> Result: group `db49e096-5a34-48c5-9037-0f32c22bbda8`, plan `ukV82eUE7kqJ3aSZeL9B6n0AAyng`
> ("CRM Follow-ups"); connections Planner `7fccd9fb…` + Office 365 Users `bc5f2e1f…` Connected;
> engine Started with Planner active; smoke test create/movecrm/untrack PASS, 0 residue; old
> daily flow `8665f8d0…` turned OFF.

The Planner layer is one interactive session because two new **standard** connections need
Adam's in-browser consent and a plan must exist. Everything else is scripted. Steps, in order:

1. **Consent the two connections** (Adam's only interactive step):
   ```
   node scripts/flow-builder/create-connections.js --only=planner,office365users --headed
   ```
   Pick the account / click Allow for **Planner** and **Office 365 Users**. Both are
   standard first-party connectors — same class as the SharePoint/Outlook/Forms consents.
   **NOTE (2026-06-22):** this auto-clicker did NOT reliably open the OAuth popup over CDP on
   a warm Edge (fell to an aria fallback that no-opped). Fastest reliable path = add the two
   connections **by hand** (Power Automate → Connections → **+ New connection** → search the
   connector → **Create**; first-party connectors often need no popup), then confirm with
   `node scripts/flow-builder/verify-connections.js shared_planner shared_office365users`.

2. **Create the plan + resolve + write the ids** (fully scripted — no Planner UI, no GUID
   copying; Adam chose Graph automation 2026-06-21):
   ```
   node scripts/flow-builder/resolve-planner-ids.js --write
   ```
   This reads the group id from SharePoint, looks for a **"CRM Follow-ups"** plan in the
   Guided AI Labs group and **creates it via Graph if it doesn't exist** (idempotent —
   `POST /planner/plans`, owner = the group; needs the Tasks.ReadWrite + Group.ReadWrite.All
   delegated scope, which surfaces in the same window), then writes `planner.groupId` +
   `planner.planId` into `config/followup.registry.json`. Buckets are optional — the engine
   falls back to the plan's default bucket; named buckets matching the CRM Priority values
   give by-priority bucketing for free. (Run once without `--write` first to see what it
   would do.)

3. **Rebuild the engine** (idempotent PATCH — now picks up the active Planner layer):
   ```
   node scripts/flow-builder/create-followup-engine-flow.js
   ```
   It logs `Planner layer: ACTIVE` and binds the two new connections. (Run with `--dry`
   first to write the planned body to `.local/flow-builder/capture/flow-body-engine.json`
   for a final eyeball before the POST.)

4. **Smoke-test** (throwaway `GAIL-INTERNAL-WALKTHROUGH` signal, then clean to 0 residue):
   ```
   node scripts/flow-builder/planner-smoke-test.js create     # task appears, assigned to owner
   node scripts/flow-builder/planner-smoke-test.js movecrm    # CRM date +90m -> task due moves
   node scripts/flow-builder/planner-smoke-test.js untrack    # untick Planner -> task deleted
   node scripts/flow-builder/planner-smoke-test.js close       # (optional) close -> teardown path
   node scripts/flow-builder/planner-smoke-test.js cleanup    # delete the test record
   ```

5. **Retire the old daily flow** `8665f8d0-43c7-4067-b2b9-b57e7450ab6d` and declare the
   backbone complete (§9 step 5–6):
   ```
   node scripts/flow-builder/set-flow-state.js 8665f8d0-43c7-4067-b2b9-b57e7450ab6d stop
   ```
   Turns it OFF (Started → Stopped) — reversible (`… start`), not deleted.

**Engine layer behaviour (Planner, one-way):** for each open signal ticked `Planner` on
`op_TrackOn`, the engine resolves the owner's AAD id (`UserProfile_V2`), picks a bucket by
Priority (`ListBuckets_V3`, fallback first bucket), creates a task (`CreateTask_V4`) assigned
to the owner with `dueDateTime = FollowUpDueDate`, and stores `op_PlannerTaskId`. When the
CRM date moves it pushes the new due (`UpdateTask_V3`); on untrack or close it deletes the
task (`DeleteTask`) and clears the key. The Planner branches run **after** the calendar
branches so the two layers never write the same SharePoint item concurrently, and both
write the identical `op_LastSyncedDue` shadow value (loop-safe). Assignment is the free
multi-operator mechanism — an assigned task surfaces in that owner's Planner and rolls up
into their Microsoft To Do, with **no per-mailbox write and no Graph app**.
