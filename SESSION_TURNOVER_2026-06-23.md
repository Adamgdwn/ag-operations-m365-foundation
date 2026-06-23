# Session Turnover - 2026-06-23

Canonical restart file:
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

Current workspace source of truth:
[docs/START_HERE.md](docs/START_HERE.md).

> Context: this session continued the Phase-2 CRM work past the recovery closeout
> into the **custom-branded website intake** feature. The brand sites are replacing
> the plain Microsoft Forms intake with hand-built, on-brand forms that post into the
> same `CRM - New Signals` list. Windows owns the tenant/flow side; the Linux website
> repos own the form UI. Full plan: [docs/CRM_CUSTOM_INTAKE_FORM_PLAN.md](docs/CRM_CUSTOM_INTAKE_FORM_PLAN.md).

## Stop Point

**BOTH brand custom intake forms are LIVE and JOINT-VERIFIED end-to-end.** Labs verified
late 2026-06-22→23; **Guided AI Journey verified the morning of 2026-06-23** (this session).
Nothing structurally open — remaining items are discretionary/owner-only (see Carry-Forwards).

> **2026-06-23 morning update (Journey closeout).** A background watcher caught Linux's
> Journey deploy handoff at 7:09 AM (form live at `https://www.guidedaijourney.com/intake`,
> commit `48b48df`, Vercel `dpl_2FZuT7AfQzJcNYpnY6EmbKLdUxgU`, backend route
> `/api/journey-intake`, homepage CTA → `/intake`). Windows inspected the live form DOM
> (byte-exact contract match), drove the marker test (`GAIL-INTERNAL-WALKTHROUGH`) via
> warm-Edge/CDP → `/api/journey-intake` **202 `{ok:true}`** → **CRM - New Signals Id 17,
> ALL PARITY CHECKS PASS** (IntakeSource=Guided AI Journey, IntentPath byte-exact,
> Website/New, full provenance footer + intake id `256ac23a…`) → **scope-deleted, 0 residue.**
> Closeout packet `X:\WINDOWS_TO_JOURNEY__custom-intake-joint-verified-20260623.md` sent;
> plan doc + memory + ledger updated. Reusable scratchpad scripts:
> `submit-journey-test.js`, `verify-journey-record.js`, `inspect-journey-form.js`,
> `watch-journey-deploy.ps1`. **Shared non-blocker flagged to BOTH Linux repos:** the
> `company` honeypot input renders visible in the DOM on both forms; should be visually
> hidden (NOT a gate — verified state stands; selectors drive by `name`).

### (history) Labs stop point

Completed this session:

- **Custom HTTP intake endpoint stood up + verified** (earlier today): new create-only
  Power Automate flow `GAIL — Custom site intake to CRM (create-only, HTTP)`
  (id `9582c422-158d-4975-ba7f-81b4d77e497b`), Request trigger → guard (secret header +
  honeypot empty + valid source + need present) → SharePoint Create item. Needed Power
  Automate **Premium** (Adam paid + assigned the license). Server-side e2e PASS both
  brands; guard negatives (bad secret / filled honeypot / bad source) all blocked.
  Endpoint URL + shared secret live in `.local/flow-builder/` (gitignored, never committed).
- **Spec released to both Linux website repos**, differentiated per brand (identical
  field set/order/contract for CRM parity; different look) — Journey = dark charcoal +
  cream + terracotta + owl mark; Labs = its own tokens, **no logo yet** → text wordmark +
  logo slot. Live endpoint+secret injected only into the `X:\` copies.
- **Linux Labs side built + deployed** the custom `#engage` form (commits `446e9f5`/
  `d47ae1b`, Vercel `dpl_AoiKcDRDAcZkJTFpHZDm1Rd2tfXP`, prod https://www.guidedailabs.com);
  `/api/intake` validates + forwards server-side. Their `lib/intake.ts` is a byte-exact
  contract match (field names, `source="Guided AI Labs"`, the 4 IntentPath strings).
- **Owner-approved joint browser e2e — Windows ran it directly and it PASSED.** Drove the
  LIVE prod form via warm-Edge/CDP with marker name `GAIL-INTERNAL-WALKTHROUGH`:
  `/api/intake` → **202 `{"ok":true}`** → CRM item **created (Id 16)** → ALL CHECKS PASS
  (IntakeSource=Guided AI Labs, IntentPath byte-exact, SignalType=Website, SignalStatus=New,
  full provenance footer `Intake: custom site form` + intake id + submitted + capture) →
  **scope-deleted, 0 residue.** The created item proves the real server-side secret is wired
  (a 202 alone would not — the trigger 202s before the guard runs).
- Sent closeout/awareness packets and committed the plan-doc closeout.

Latest state:

```text
Labs custom website -> CRM intake: LIVE + JOINT-VERIFIED. MS Forms fallback still up.
Journey custom form: spec released + endpoint live, NOT built yet (Adam shut that repo
down for the night). Same endpoint serves both brands (source = "Guided AI Journey").
```

## What Changed

```text
docs/CRM_CUSTOM_INTAKE_FORM_PLAN.md   (Status -> Labs joint-verified live; Journey open)
SESSION_TURNOVER_2026-06-23.md        (this file)
X:\WINDOWS_TO_LABS__custom-intake-joint-verified-20260623.md      (closeout packet)
X:\WINDOWS_TO_JOURNEY__custom-intake-build-request-20260623.md    (standing build request)
01 Work Tracking/AG Operations Workspace Setup/{latest.md,log/2026-06-23.md}  (ledger)
memory/m365-foundation-state.md       (Labs verified; Journey pending)
```

Verification scripts (scratchpad, reusable): `submit-engage-test.js` (drives the live
form via warm-Edge/CDP) + `verify-engage-record.js` (full-parity CRM check).
Cleanup: `scripts/flow-builder/delete-test-records.js` (scope: PersonName == marker).

## Git Note

Committed straight to `main`:

```text
88df2f0  Labs custom intake form: JOINT E2E VERIFIED LIVE (closeout)
(earlier today) 7fb37da release spec packets; b40ca20 stage packets;
edb21ff custom HTTP intake LIVE + verified; 3898d0f server-side e2e + premium decision
```

## Carry-Forwards

- **Guided AI Journey custom form — ✅ DONE (verified 2026-06-23 morning).** Built, deployed,
  joint-verified live (CRM Id 17, 0 residue). No longer an open item — see the morning-update
  block under Stop Point.
- **Honeypot visual-hide (both brands) — Linux cosmetic cleanup, NOT a gate.** The `company`
  honeypot renders visible in the DOM on both forms; flagged to both Linux repos in their
  closeout packets. Optional belt-and-suspenders: a ~2-min re-confirm after Linux ships the
  fix (selectors drive by `name`, so it would pass trivially). Not required to box up.
- **Adam's own `test one` submission (planned ~2026-06-23/24):** dummy values, name
  `test one`. It will NOT carry the auto-delete marker, so it won't be auto-cleaned —
  Adam deletes it, or tells me the exact name and I scope-delete it.
- **Switching the Labs primary CTA / retiring the MS Forms flow** is now unblocked but
  NOT done — Forms stays live as fallback until Adam decides. Retire via
  `scripts/flow-builder/set-flow-state.js <forms-flow-id> stop` (reversible).
- **Minor (flagged to Linux, non-blocker):** the Labs honeypot `Company` input rendered
  visible in DOM inspection; should be visually hidden so real visitors never see it.
- **STILL HELD for Adam's explicit OK (NOT a blocker, unchanged):** the Stage 8 packet
  archive move into `inventory/archive/2026-06-17-stage-8-packet/`.
- Standing stop conditions remain in force (permissions, guest invites, external sharing,
  app consent, public Forms beyond the scoped unlocks, production mail, deletes,
  unattended automation, Dynamics/Dataverse). Power Automate Premium is now licensed.

## Exact Resume Sequence

1. Open [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md) and
   [docs/START_HERE.md](docs/START_HERE.md).
2. Read [docs/CRM_CUSTOM_INTAKE_FORM_PLAN.md](docs/CRM_CUSTOM_INTAKE_FORM_PLAN.md) — Labs
   section is joint-verified; Journey section is the open item.
3. Check `X:\` for any new `LINUX_TO_WINDOWS__*` reply (e.g. a Journey deploy handoff).
4. If a Journey deploy lands: warm Edge (`node scripts/forms-builder/warm-edge.js`), then
   run the joint e2e (adapt scratchpad `submit-engage-test.js`/`verify-engage-record.js`
   to the Journey URL + `source="Guided AI Journey"`), then `delete-test-records.js`.
5. If Adam asks to retire the Labs MS Forms flow, use `set-flow-state.js <id> stop`.
6. Do not run tenant-writing commands without a fresh approval, explicit scope, evidence
   target, and rollback path.
