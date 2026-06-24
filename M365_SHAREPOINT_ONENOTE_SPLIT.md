# Microsoft 365, SharePoint, and OneNote Split

> **Local-machine track — Stage 4 input.** Context-separation philosophy for the
> device-side work in **Stage 4**. Start at [START_HERE.md](START_HERE.md).

The target is context separation, not hard lockout.

When working in a Prime Boiler context, mostly Prime Boiler things should be visible. When working in City of Red Deer, mostly City of Red Deer things should be visible. When working in AG Operations, mostly AG Operations material should be visible.

## Layers

1. Identity

   The account currently signed in:

   - Personal Microsoft/Google
   - AG Operations
   - Prime Boiler Microsoft 365
   - City of Red Deer
   - future client accounts

2. Tenant / Cloud Home

   Where durable records belong:

   - client records in the client tenant
   - AG Operations records in AG Operations storage
   - personal records in personal storage

3. Working Surface

   What is visible day to day:

   - Chrome profile
   - bookmarks
   - SharePoint followed sites
   - Teams
   - OneNote notebooks
   - synced folders

4. Local Cache / Drafts

   Laptop-local files:

   - drafts
   - exports
   - scripts
   - working copies
   - backups

## Recommended Browser Profiles

- Chrome - Personal
- Chrome - AG Operations
- Chrome - Prime Boiler
- Chrome - City of Red Deer
- Chrome - Client Name, for future clients with their own login or heavy web context

Each profile should stay signed into only the relevant Microsoft 365 identity where practical.

## OneNote Rule

Prefer opening client notebooks through the matching browser profile / account.

OneNote desktop can become visually noisy because it tends to show every notebook ever opened. If using desktop OneNote, close notebooks that do not belong to the current working lane.

## OneDrive / SharePoint Sync Rule

Be conservative.

- Do not sync every tenant broadly.
- Sync only active folders or libraries genuinely needed offline.
- Prefer browser access for archives and rarely used libraries.
- Clearly name synced folders so File Explorer does not become ambiguous.

## Tool-Building Rule

If a tool is permanent and belongs to the client, build/store it in the client tenant:

- SharePoint site
- Microsoft Lists
- Power Apps
- Power Automate
- Teams tabs
- SharePoint pages
- client-owned document libraries

If the tool is reusable AG Operations IP or methodology, keep the master under AG Operations and deploy/copy a client-specific version into the client tenant.

