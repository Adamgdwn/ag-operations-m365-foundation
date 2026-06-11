# Microsoft 365 Desktop Account Conflict Discussion

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

