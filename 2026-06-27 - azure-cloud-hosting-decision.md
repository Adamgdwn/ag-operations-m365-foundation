# Azure Cloud Hosting Decision + Credits Resolution

**Date:** 2026-06-27
**Status:** Decision locked — action items pending
**Owner:** Adam Goodwin

---

## Decision: Azure is the Primary Runtime for the Guided AI Labs OS

The Guided AI Labs Agentic OS runs on Azure. This is not a preference — it is an
architectural necessity driven by M365.

The GAIL OS is the governance backbone of the CNS. The Enterprise Body is M365
(SharePoint, Exchange, Teams, Planner, OneDrive). Every Phase 4 action — governed
writes to M365, Power Automate triggers, Microsoft Graph calls, Entra identity
validation — requires being inside the Microsoft trust boundary. Running GAIL OS on
AWS or GCP would mean building middleware to cross that boundary on every call.
Azure eliminates that friction entirely.

Specific dependencies that lock this decision:

- **Entra ID** — all M365 app registrations and identity governance live here;
  GAIL OS service identity must be in the same tenant
- **Microsoft Graph** — the API surface for all M365 execution channels (email,
  calendar, SharePoint, Teams); native from Azure, bridged from anywhere else
- **Azure Key Vault** — secrets management for the governed execution layer;
  co-located with the runtime that uses them
- **Managed Identity** — allows GAIL OS to authenticate to M365 without storing
  credentials; only available within Azure
- **Azure Container Apps / Azure Functions** — right-sized hosting for the Python
  FastAPI service (GAIL OS HTTP API, Chunk 21); pay-per-use, scales to zero

Freedom (TypeScript/Next.js) can run on Azure or Vercel — it has no hard Azure
dependency. Graphify's serving layer can also run on Azure. Keeping all three
CNS layers in the same cloud simplifies networking, secrets, and identity.

**AWS:** Strong general-purpose cloud. Not the right choice for a system whose
primary execution target is M365. Would require OAuth middleware and credential
management overhead on every M365 call.

**GCP:** Apply for free credits (see below) — free money is free money. Use for
non-M365 workloads if needed (research, scratchpad, data processing). Do not put
GAIL OS or the governance backbone here.

---

## Current Problem: Credits Linked to Personal Account

Azure credits were granted to Adam's personal Microsoft account, not the Guided AI
Labs business account. A request is in to apply through the business account, but
no resolution yet.

---

## Resolution Paths (in priority order)

### 1. Microsoft for Startups — Founders Hub (PRIMARY)

Apply at: `https://foundershub.startups.microsoft.com`

This is the right long-term solution regardless of the credit situation:

- Up to **$150,000 USD** in Azure credits, tied to the **business entity**
- Includes GitHub Enterprise, Microsoft 365, and other tools
- Credits live in the business tenant from day one — no transfer needed
- Guided AI Labs is exactly the company this program exists for (AI, B2B,
  agentic systems, enterprise focus)

**Action:** Apply through the Guided AI Labs business account. This should be
prioritized — the credits are substantially larger and properly owned by the
business.

### 2. Transfer Existing Subscription to Business Tenant

Azure supports transferring billing ownership of a subscription between accounts.

Steps:
1. Azure Portal → Cost Management + Billing → select the subscription
2. → Transfer billing ownership → enter the business account email
3. Accept the transfer from the business account

**Caveat:** Some credit types (Azure Sponsorship, MSDN/Visual Studio credits) are
non-transferable. Depends on how the credits were originally granted. Check the
credit type before attempting the transfer — if non-transferable, skip to option 3.

**Action:** Identify the credit type in Azure Portal → Cost Management. If
transferable, initiate the transfer. If not, proceed to option 3.

### 3. Bridge Strategy: Personal for Dev, Business for Prod

If the Founders Hub application takes time and the credits cannot be transferred:

- Use personal Azure credits for **development and experimentation only**: GAIL OS
  FastAPI prototype, schema validation, local evidence store testing
- Stand up the business Azure subscription (pay-as-you-go or pending Founders Hub)
  for **production-grade workloads**: Entra app registration, Key Vault, production
  Container App
- Do not commingle production M365 integrations with personal billing
- The personal credits burn productively during development; the business account is
  clean for production

**Action:** Confirm which Azure subscription the existing Entra tenant / M365 app
registration (BLK-005) is or will be associated with. That subscription is the
production one — ensure it is business-owned before any app registrations are
created.

---

## GCP Free Credits

Apply for Google Cloud free credits regardless of preference for the Google
ecosystem. Free credits = free capacity for non-M365 workloads (research,
data processing, experimentation). Do not route GAIL OS or any M365 execution
logic through GCP.

---

## Open Blockers

| Blocker | Resolution Path | Status |
|---|---|---|
| BLK-005: M365 app registration status unknown | Confirm with Entra admin; use Founders Hub subscription | Open |
| Personal vs. business Azure credits | Transfer or Founders Hub application | Open — in progress |
| Production Azure subscription (business-owned) | Founders Hub (preferred) or new pay-as-you-go | Pending Founders Hub |

---

## Next Action for Adam

1. **Apply for Microsoft for Startups (Founders Hub)** through the Guided AI Labs
   business account. This is the highest-leverage single action on the cloud
   infrastructure front.
2. **Check the credit type** on the existing personal Azure subscription — if
   transferable, initiate the billing ownership transfer.
3. **Confirm BLK-005**: does a Guided AI Labs Entra tenant / M365 app registration
   already exist? If yes, which Azure subscription is it linked to? This determines
   whether production can start on the existing personal subscription or must wait
   for the business account.
