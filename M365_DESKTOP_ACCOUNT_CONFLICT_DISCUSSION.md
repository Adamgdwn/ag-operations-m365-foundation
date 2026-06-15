# Microsoft 365 Desktop Account Conflict Discussion

> **Local-machine track — Stage 4 input.** Desktop Office license/identity conflict
> notes for the device-side work in **Stage 4**. Start at [00_INDEX.md](00_INDEX.md).

Date: 2026-05-27

## Context

Adam is using multiple Microsoft 365 accounts at the same time, with separate Chrome profiles for each account. The goal was to avoid repeated sign-ins and account switching while keeping documents fully usable in desktop Microsoft 365 apps.

The main symptom was Word reporting that Microsoft 365 Premium was required even though both accounts have Microsoft 365 coverage.

## What Was Observed

In Word under `File > Account`, the desktop app showed:

- User Information: `adamgwdn@hotmail.com`
- Product Information / active subscription: `adam.goodwin@primeboiler.com`
- Product: Microsoft 365 Apps for business

This means Word was signed in as the personal Hotmail account, but the local Office installation was activated/licensed through the Prime Boiler business account.

## Likely Cause

Separate Chrome profiles isolate browser sessions, cookies, and web Microsoft 365 logins, but they do not isolate the installed desktop Office apps.

Desktop Word, Excel, PowerPoint, Outlook, and related Microsoft 365 apps share one local Office identity/licensing state on Windows. When a document is opened from a browser profile into the desktop app, the desktop app may use its existing local account/license context instead of the browser profile's identity.

This can create a mismatch between:

- The browser account used to locate/open the document
- The OneDrive/SharePoint account that owns the file
- The desktop Office account shown under User Information
- The active Microsoft 365 license shown under Product Information

## Options Discussed

### Option 1: Keep Desktop Office Personal

Preferred direction if desktop Word should always be personal.

Steps:

1. Open Word.
2. Go to `File > Account`.
3. Use `Switch License`.
4. Choose `adamgwdn@hotmail.com`.
5. Use `Update License`.
6. Close all Office apps completely.
7. Reopen Word and confirm both User Information and Product Information point to the personal account/license.

This would make desktop Word consistently personal, while business files could still be opened through connected services or synced folders.

### Option 2: Use Web Apps for One Account

This would keep both accounts isolated through separate Chrome profiles. It was rejected as a preferred workflow because Microsoft web apps are too limited for the document work being done.

### Option 3: Use OneDrive Sync for Business Files

A possible desktop-friendly approach:

- Keep desktop Office licensed to the personal Microsoft 365 account.
- Add/sync the Prime Boiler OneDrive or SharePoint libraries through OneDrive.
- Open business documents from File Explorer rather than from Chrome.

This keeps full desktop Office features while reducing browser-to-desktop identity handoff problems.

## Current Decision

For now, keep things as they are.

The current setup is workable enough, and changing the license/device/account configuration could create more churn than it solves right now.

## 2026-06-15 Update — Browser Profiles and Windows Account Broker

Adam reported recurring Microsoft 365 sign-in collisions across City of Red Deer,
Guided AI Labs, A.G. Operations, and other Microsoft 365 accounts, especially when
email, Office web apps, and Chrome profiles are all in use.

Local profile inventory found:

| Surface | Profile / folder | Visible identity state |
|---|---|---|
| Chrome | `Default` / `Adam` | Chrome signed in as `adamgdwn@gmail.com`; profile metadata also listed `admin@agoperations.ca` |
| Chrome | `Profile 1` / `Prime Boiler 2026` | No visible signed-in account metadata |
| Chrome | `Profile 2` / `AI Labs` | No visible signed-in account metadata |
| Edge | `Default` / `Personal` | Signed in as `adamgdwn@hotmail.com` |

Windows identity broker / device join inventory found:

- `AzureAdJoined: NO`
- `EnterpriseJoined: NO`
- `DomainJoined: NO`
- `WorkplaceJoined: YES`
- Workplace tenant: `A.G. Operations Ltd`
- Workplace tenant id: `1ca92af5-21ff-42e3-87ae-3bde9c2cc501`
- Workplace join record user email: `contact@guidedailabs.com`
- WAM default authority: `consumers`

Interpretation:

- Chrome `Default` was doing double duty: personal Google profile plus an A.G.
  Operations Microsoft 365 account hint. That profile should now be treated as
  personal-only.
- Windows has a cross-identity workplace join: `contact@guidedailabs.com` is
  registered against the `A.G. Operations Ltd` tenant. This may be legitimate,
  but it is exactly the kind of broker-level overlap that can make Microsoft 365
  sign-ins feel like they are taking turns evicting each other.
- Browser profiles isolate cookies and Microsoft web sessions. They do not
  isolate Windows WAM, Office desktop licensing, OneDrive sync state, or tenant
  conditional-access rules.

Action taken on 2026-06-15:

- Created Chrome `Profile 3` named `City of Red Deer`.
- Removed an accidental blank Chrome profile named `Your Chrome` / folder
  `Profile` that was created during first-launch testing.
- Created desktop shortcut:
  `C:\Users\adamg\OneDrive\Desktop\Chrome - City of Red Deer.lnk`
- Backed up Chrome local profile registry before edits:
  `C:\Users\adamg\AppData\Local\Google\Chrome\User Data\Local State.codex-backup-20260615-110914`
- Opened the new City profile at `https://www.office.com/` so Chrome could finish
  initializing it.

Current recommended browser-lane model:

| Lane | Browser profile | Intended Microsoft 365 identity |
|---|---|---|
| Personal | Chrome `Default` / `Adam`; Edge `Personal` | Personal Google/Hotmail only |
| Operator | Chrome `Profile 2` / `AI Labs` | `adamgoodwin@guidedailabs.com` and Guided AI Labs / A.G. Operations work |
| Client | Chrome `Profile 1` / `Prime Boiler 2026` | Prime Boiler work only |
| City | Chrome `Profile 3` / `City of Red Deer` | City of Red Deer work only |

Operating rule:

- Do not sign into multiple work/school Microsoft 365 tenants in the same Chrome
  profile unless intentionally troubleshooting.
- Use each profile as a separate Microsoft web-session container.
- Keep `Settings > Accounts > Access work or school` under review; disconnect or
  replace the current workplace join only after confirming which tenant/account
  actually needs device-level registration.

## If This Comes Back Later

Check these first:

1. In Word, confirm `File > Account` and compare:
   - User Information
   - Product Information / Subscription Product for
2. If desktop should be personal, use `Switch License` and `Update License` to move activation back to `adamgwdn@hotmail.com`.
3. Check Windows account connections:
   - `Settings > Accounts > Email & accounts`
   - `Settings > Accounts > Access work or school`
4. Be careful disconnecting the Prime Boiler work account if the device is managed or needs business access.
5. Consider syncing business SharePoint/OneDrive libraries locally and opening files through File Explorer for full desktop Office features.
