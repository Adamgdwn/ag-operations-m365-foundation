# Microsoft 365 Stage 4 — OneDrive & Local Machine Dovetail

Status: **COMPLETE** (started + closed 2026-06-12). All 7 decisions (4.1–4.7) made; the
machine now gives the operator identity a clean local home and browser lane, with
ownership named per layer. This is the Stage 4 working
document per [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md). Orientation lives
in [00_INDEX.md](00_INDEX.md). This stage **absorbs the May local-machine track** —
its inputs are [README.md](README.md),
[M365_SHAREPOINT_ONENOTE_SPLIT.md](M365_SHAREPOINT_ONENOTE_SPLIT.md),
[NEXT_SESSION_CHECKLIST.md](NEXT_SESSION_CHECKLIST.md),
[SYSTEM_NOTES_FROM_INITIAL_DIG.md](SYSTEM_NOTES_FROM_INITIAL_DIG.md), and
[M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md).

**Golden rule for this stage: this is LIVE machine configuration, and almost every
change is an interactive GUI action (OneDrive client, Windows known folders, Office
sign-in, Chrome profiles) — not a scriptable Graph write. So: INVENTORY first (done,
read-only), DECIDE the lane model on paper, then change ONE thing at a time, verify it,
and move on. Non-destructive throughout — nothing is moved, unsynced, closed, or
re-pointed without an explicit, separate decision.**

> **Why Stage 4 is different from Stages 2–3.** Stages 2–3 wrote to the *tenant* via
> PowerShell/Graph (auditable, idempotent, read-back-verifiable). Stage 4 writes to
> *this laptop*: the OneDrive sync client, Windows shell known-folder redirects, the
> desktop Office identity/licence, browser profiles, and OneNote. These are owned by
> Adam at the keyboard. My role here is: produce the inventory (below), frame each
> decision with a recommendation, then hand precise click-steps and verify the result.

---

## 1. The core rule this stage enforces

```text
SharePoint   = official record        (built in Stage 3 — the 5 sites)
OneDrive     = personal working drafts (per identity)
Local machine = active work / cache / access layer
```

The job is not to sync everything. It is to make active work easy without local file
chaos, and — critically for this project — to give the **operator identity**
(`adamgoodwin@guidedailabs.com`) a clean local home, because right now it has none
(see §3 finding F1). See [[m365-foundation-state]] and the context-separation
philosophy in [M365_SHAREPOINT_ONENOTE_SPLIT.md](M365_SHAREPOINT_ONENOTE_SPLIT.md).

---

## 2. Current device state — read-only inventory (2026-06-12)

All values below were read from this machine (registry + OneDrive client + browser
`Local State` + `dsregcmd`), changing nothing.

### 2.1 OneDrive accounts connected to the client

| Slot | Account | Identity | Local root |
|---|---|---|---|
| `Personal` | `adamgdwn@hotmail.com` | Adam's **personal** Microsoft account | `C:\Users\adamg\OneDrive` |
| `Business1` | `adam.goodwin@primeboiler.com` | **Prime Boiler** (a *client* tenant) | `C:\Users\adamg\OneDrive - Prime Boiler Services Ltd` |
| `Business2` | `adamgoodwin@guidedailabs.com` | **A.G. Operations Ltd** (operator) — *added 2026-06-12, decision 4.1* | `C:\Users\adamg\OneDrive - A.G. Operations Ltd` |
| `FileCoAuth` | — | (Office co-authoring helper, not an account) | — |

**Original finding (F1):** at inventory time, `adamgoodwin@guidedailabs.com` was NOT
connected to the OneDrive client at all. **Resolved 2026-06-12** by decision 4.1 — now
slot `Business2`. (Note: the local root is named after the tenant org **A.G. Operations
Ltd**, not "Guided AI Labs" — `guidedailabs.com` is a domain inside that tenant.)

### 2.2 Active OneDrive environment variables

| Variable | Points at |
|---|---|
| `OneDrive` | `…\OneDrive - Prime Boiler Services Ltd` (the **client** tenant) |
| `OneDriveCommercial` | `…\OneDrive - Prime Boiler Services Ltd` |
| `OneDriveConsumer` | `…\OneDrive` (personal Hotmail) |

### 2.3 Windows known-folder redirects (Desktop / Documents / Pictures)

| Known folder | Redirected to |
|---|---|
| Desktop | `C:\Users\adamg\OneDrive\Desktop` → **personal Hotmail OneDrive** |
| Documents | `C:\Users\adamg\OneDrive\Documents` → **personal Hotmail OneDrive** |
| Pictures | `C:\Users\adamg\OneDrive\Pictures` → **personal Hotmail OneDrive** |

### 2.4 Synced SharePoint document libraries

**None.** Only the Prime Boiler OneDrive *root* is mounted. None of the five Stage-3
SharePoint sites (AG Operations, Guided AI Labs, Change Leadership Tools, Shared
Libraries, Guided AI Journey) are synced — they are browser-only today.

### 2.5 Windows device join

- **Workplace-Joined** to tenant **A.G. Operations Ltd** (`WorkplaceJoined: YES`).
- Not Azure-AD-joined (`AzureAdJoined: NO`). So the project tenant *is* registered at
  the Windows level (add-work-account style), but the machine is not tenant-managed.

### 2.6 Browser profiles

| Browser | Profile dir | Profile name | Bound account |
|---|---|---|---|
| Chrome | `Default` | "Adam" | `adamgdwn@gmail.com` (personal Google) |
| Chrome | `Profile 1` | "Prime Boiler 2026" | *(no account bound)* |
| Chrome | `Profile 2` | "AI Labs" | *(no account bound)* |
| Edge | `Default` | — | `adamgdwn@hotmail.com` (personal) |

A Chrome **"AI Labs"** profile shell already exists but is not signed into the
`guidedailabs.com` identity.

**2026-06-15 update:** a fourth Chrome lane now exists for City of Red Deer:
`Profile 3` / "City of Red Deer". The desktop launcher is
`C:\Users\adamg\OneDrive\Desktop\Chrome - City of Red Deer.lnk`.

### 2.7 Local top-level lanes (`C:\Users\adamg`)

`Personal`, `AG Operations` (with the README's `00.–06.` + `Consulting` + `Prime
Boiler` sub-lanes), `01. Code Projects`, plus the two OneDrive roots. Also present:
`01.chrome-profile-quarantine-2026-06-03` — a stray Chrome `User Data` directory that
was quarantined on 2026-06-03 (contains its own `FOLDER_ORIGINATION_INVESTIGATION_LOG.md`).

### 2.8 OneNote

No notebooks are registered with desktop OneNote (no `OpenNotebooks` entries). OneNote
is effectively browser/app-only on this machine today.

---

## 3. Findings (what the inventory means)

- **F1 — The operator identity has no local home.** The whole foundation project is
  for `adamgoodwin@guidedailabs.com`, yet that account is not connected to OneDrive,
  owns none of the known folders, and isn't bound to a browser profile. The machine is
  currently shaped around **Personal (Hotmail)** + **Prime Boiler (a client)**. This is
  the central thing Stage 4 fixes.
- **F2 — Split-brain known folders (carried from May).** "Documents/Desktop/Pictures"
  silently save into the **personal** Hotmail cloud, while the shell's `$OneDrive`
  ("the" OneDrive) is the **Prime Boiler client** tenant. Neither is the operator
  identity. Confirmed unchanged since [SYSTEM_NOTES_FROM_INITIAL_DIG.md](SYSTEM_NOTES_FROM_INITIAL_DIG.md).
  **Re-read after content inspection (2026-06-12, decision 4.2):** the known folders
  hold ~7 GB of genuinely personal/historical content (Desktop 59 MB, Documents 4.3 GB /
  6,282 files, Pictures 2.5 GB / 1,356 files — Mexico photos, game saves, app caches,
  EndNote/NVivo/Sony folders). So Personal OneDrive is in fact their *correct* owner; the
  gap was never a wrong-cloud redirect but the **absence of a business-drafts lane** (now
  fixed by 4.1). Resolved by ownership-by-layer, not by moving files.
- **F3 — A client tenant is the machine's default OneDrive.** Prime Boiler being
  `$OneDrive`/`Business1` means a *client* owns the laptop's primary cloud lane —
  backwards for an operator whose own records should be primary. (Capability/ownership
  hygiene, same spirit as the Stage 2 "interaction ≠ capability" principle.)
- **F4 — Stage-3 sites are browser-only.** Consistent with the conservative sync rule,
  but it means daily work against the new SharePoint sites has no local lane yet — a
  deliberate choice to confirm, not an accident to fix.
- **F5 — Browser lanes are half-built.** "Prime Boiler 2026" and "AI Labs" Chrome
  profiles exist but aren't bound to their identities; personal identity spans Chrome
  Default + Edge Default.
- **F6 — Office desktop licence conflict still unresolved (deferred in May).** Word
  showed user `adamgdwn@hotmail.com` but licence via `adam.goodwin@primeboiler.com`.
  Decision in May was "keep as is." Revisit here only if we want desktop Office to have
  a defined owner. See [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md).
- **F7 — Housekeeping: quarantine folder.** `01.chrome-profile-quarantine-2026-06-03`
  is dead Chrome cache; safe to archive/delete after a glance at its investigation log.

---

## 4. Decision register (OPEN — one at a time, non-destructive)

Ordered so earlier decisions gate later ones. Nothing below is executed yet.

| # | Decision | Recommendation (to confirm) | Status |
|---|---|---|---|
| **4.1** | **Operator identity's local home.** Connect `adamgoodwin@guidedailabs.com` to the OneDrive client as a business account, giving the project identity a real local root? | **Yes — connect it.** It's the prerequisite for every other lane choice. | **DONE 2026-06-12** (slot `Business2`, root `…\OneDrive - A.G. Operations Ltd`, verified by registry read-back) |
| **4.2** | **Known-folder ownership (split-brain fix).** Where should Desktop/Documents/Pictures live? | **DECIDED: leave them on Personal OneDrive — they hold ~7 GB of genuinely personal/historical content, so Personal is their correct owner. Business working drafts go to the new `…\OneDrive - A.G. Operations Ltd` instead.** Resolves F2 by *naming ownership per layer*, not by migrating files (non-destructive). Rejected: moving to business OneDrive (would dump 7 GB of personal data into the business tenant) and un-redirecting to local (risky 4.3 GB migration that drops personal cloud backup). No folder structure seeded yet. **Lever for the future, if ever needed:** OneDrive enforces one folder-backup owner at a time — to hand Desktop/Docs/Pics to A.G. Operations Ltd you would first turn OFF folder backup in the Personal account. | **DONE 2026-06-12** |
| **4.3** | **Which Stage-3 libraries sync locally vs browser-only.** Of the 5 sites, which (if any) get a synced library for offline/desktop-Office work? | **DECIDED: stay browser-only — sync nothing now.** Browser access to the sites is confirmed working (4.4). Revisit only if a specific library needs offline/desktop-Office editing. Conservative per the sync rule. | **DONE 2026-06-12** (no action) |
| **4.4** | **Browser-profile binding.** Bind Chrome "AI Labs" → `guidedailabs.com`, "Prime Boiler 2026" → Prime Boiler, keep Default/Edge personal? | **DECIDED: adopt 3-lane model — Default = Personal, "Prime Boiler 2026" = client, "AI Labs" = operator/business lane (sign into office.com as `adamgoodwin@guidedailabs.com`). Generated importable bookmarks file [M365_STAGE_4_AILABS_BOOKMARKS.html](M365_STAGE_4_AILABS_BOOKMARKS.html) (5 SharePoint sites + 7 admin centers + daily links). No Google-account sync binding — lane is identity-by-use + bookmarks.** | **DONE 2026-06-12** (file generated; user to import + sign in) |
| **4.5** | **Prime Boiler demotion.** Should the operator OneDrive become the machine's primary lane, with Prime Boiler demoted from "the" `$OneDrive`? | **DECIDED: leave as-is.** `$OneDrive`/`OneDriveCommercial` still point at Prime Boiler (it was the first business account added). Changing the "primary" commercial OneDrive requires unlinking/relinking both business accounts (resync churn) for a cosmetic env var — not worth it. The real separation already exists: each account has its own clearly-named root folder. Accepted carry-forward (F3); revisit only if a wrong-save actually occurs. | **DONE 2026-06-12** (no action) |
| **4.6** | **Office desktop licence/identity.** Resolve F6 (give desktop Office a defined owner) or keep-as-is? | **DECIDED: keep-as-is** (May decision still holds — not causing friction). Levers documented in [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md) if it returns. | **DONE 2026-06-12** (no action) |
| **4.7** | **Quarantine-folder cleanup.** Archive/delete `01.chrome-profile-quarantine-2026-06-03`? | **DECIDED: deleted.** Its own investigation log confirmed retired Chrome automation-profile data from an unrelated local project lane, quarantined 2026-06-03, not recreated, superseded by the real "Prime Boiler 2026" Chrome profile. | **DONE 2026-06-12** (854.8 MB freed; removal verified) |

---

## 5. Execution log

- **2026-06-12 — Decision 4.1 (connect operator OneDrive).** Added
  `adamgoodwin@guidedailabs.com` to the OneDrive client via Settings → Account → Add an
  account. Accepted default root `C:\Users\adamg\OneDrive - A.G. Operations Ltd`
  (named after tenant org, not domain). **Declined** the "Back up your folders" prompt —
  OneDrive reported the Personal account currently owns Desktop/Documents/Pictures
  backup, which it requires turned off before another account can take them (this is the
  F2 split-brain, deferred to decision 4.2). Verified by registry read-back: new slot
  `Business2`, correct email + root. **F1 resolved.** Nothing else on the machine
  changed (known folders, env vars, browser profiles all untouched).
- **2026-06-12 — Decision 4.2 (known-folder ownership).** No machine change made —
  decision only. Inspected the Personal-OneDrive known folders read-only (Desktop 59 MB /
  80 files; Documents 4.3 GB / 6,282 files; Pictures 2.5 GB / 1,356 files) and found them
  genuinely personal/historical. Decided to **leave them on Personal OneDrive** as the
  personal-life bucket and route business working drafts to `…\OneDrive - A.G. Operations
  Ltd` instead. Nothing moved, re-pointed, or unsynced. Folder-structure seeding declined
  for now. **F2 resolved by ownership clarification.**
- **2026-06-12 — Decision 4.4 (working-surface lane).** Adopted the 3-lane Chrome model
  (Default = Personal, "Prime Boiler 2026" = client, "AI Labs" = operator/business).
  Generated [M365_STAGE_4_AILABS_BOOKMARKS.html](M365_STAGE_4_AILABS_BOOKMARKS.html) for
  import into the AI Labs profile. No registry/profile system change made by me — the
  import + office.com sign-in are user GUI steps. Addresses F5.
  **Verified 2026-06-12:** user imported the bookmarks into the AI Labs profile, signed
  into office.com as `adamgoodwin@guidedailabs.com`, and the AG Operations SharePoint
  site loaded cleanly *in that profile* showing its Stage-3 libraries in nav
  (Governance_Records, Finance_Legal, Archive). Browser lane ↔ identity ↔ SharePoint
  confirmed working. (No Google/Chrome sign-in used — promo dismissed; lane is
  Microsoft-only by design.)
- **2026-06-12 — Decisions 4.3 / 4.5 / 4.6 (lean defaults, no action).** Confirmed:
  stay browser-only (no library sync); leave `$OneDrive` pointing at Prime Boiler (not
  worth resync churn for a cosmetic pointer); keep the Office desktop licence as-is. No
  machine change. Each is a documented, reversible accepted-default carry-forward.
- **2026-06-12 — Decision 4.7 (quarantine cleanup).** Read the folder's
  `FOLDER_ORIGINATION_INVESTIGATION_LOG.md` first (confirmed retired Chrome automation
  profile, not recreated, superseded). Deleted
  `C:\Users\adamg\01.chrome-profile-quarantine-2026-06-03` via
  `Remove-Item -Recurse -Force`. **854.8 MB freed.** Verified: folder gone; sibling
  `01. Code Projects` intact; no bare `C:\Users\adamg\01` recreated. Harmless stale
  Windows-Recent `01.lnk` left to clear itself. **F7 resolved.**
- **2026-06-15 — City of Red Deer browser lane added.** Investigated recurring
  Microsoft 365 sign-in collisions across Chrome profiles and Windows WAM. Found
  Chrome `Default` carrying both personal Google identity and an
  `admin@agoperations.ca` account hint, plus a Windows workplace join to
  `A.G. Operations Ltd` with join record email `contact@guidedailabs.com`.
  Created Chrome `Profile 3` named "City of Red Deer", removed an accidental blank
  `Profile` / "Your Chrome" profile created during first-launch testing, and added
  desktop shortcut `Chrome - City of Red Deer.lnk`. Backed up Chrome `Local State` to
  `Local State.codex-backup-20260615-110914` before editing. See
  [M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md](M365_DESKTOP_ACCOUNT_CONFLICT_DISCUSSION.md)
  for the full account-broker notes.

---

## 6. Stage 4 close-out — the lane model now in force

The roadmap's "Done when" test for Stage 4 is that Adam can work day to day without
guessing *am I in the right account / is this draft or official / local-OneDrive-
SharePoint-or-client / sync or browser-only*. The answers are now:

| Question | Answer |
|---|---|
| **Which identity am I in?** | Browser: the **Chrome profile** says it — Default = Personal, "Prime Boiler 2026" = client, **"AI Labs" = operator** (`adamgoodwin@guidedailabs.com`, signed into office.com). Files: the **named OneDrive root** says it. |
| **Is this a draft or an official record?** | Draft → **OneDrive**. Official → **SharePoint** (the 5 Stage-3 sites). |
| **Local, OneDrive, SharePoint, or client?** | Personal life → **Personal OneDrive** (Desktop/Docs/Pics). Operator business drafts → **`OneDrive - A.G. Operations Ltd`**. Client work → **`OneDrive - Prime Boiler Services Ltd`** + the client tenant. Official records → **SharePoint**. |
| **Sync or browser-only?** | **Browser-only** for all SharePoint sites (4.3). Only OneDrive roots sync locally. |

**Three connected lanes, cleanly separated:**

```text
Personal  → Hotmail/Gmail · Chrome Default · OneDrive (personal life: Desktop/Docs/Pics)
Operator  → adamgoodwin@guidedailabs.com · Chrome "AI Labs" · OneDrive - A.G. Operations Ltd · SharePoint ×5
Client    → adam.goodwin@primeboiler.com · Chrome "Prime Boiler 2026" · OneDrive - Prime Boiler Services Ltd
City      → City of Red Deer account · Chrome "City of Red Deer" · browser-only M365 lane
```

**What changed on the machine:** (1) connected the operator OneDrive (`Business2`);
(2) deleted 855 MB of dead Chrome profile data. **That's it** — everything else was a
*decision* (ownership named per layer) or a *user GUI step* (bookmark import + office.com
sign-in), not a destructive move. No known folder was re-pointed, no library force-synced,
no client data touched.

**Carry-forwards (non-blocking):** F3 — `$OneDrive` env var still points at the Prime
Boiler client (cosmetic; revisit only on a wrong-save). F6 — Office desktop licence
mismatch unresolved by choice. Optional future: seed a starter folder structure inside
`OneDrive - A.G. Operations Ltd`; sync one library if offline editing is ever needed.
