# Microsoft for Startups Founders Hub — Application Packet

Date: 2026-06-19

Status: Draft application content, ready for Adam to review, fill the marked
inputs, and submit.

This is **Step 2** of `docs/AI_FIRST_TOOLING_ACTIVATION.md`. It is the long-pole
external action: Founders Hub approval has lead time and gates all of **Bucket C**
(Business Premium, Entra ID P1, Intune/Defender, Purview, Azure AI credits). The
clock only starts when the application is submitted, so this is sequenced first
even though the free-tier wins (Step 1) are faster.

Nothing here touches the tenant. Submitting the application is an outward-facing
action that **only Adam should do**, from `https://www.microsoft.com/en-us/startups`,
signed in as Guided AI Labs.

---

## 0. Decisions I need from you (the only blockers)

Status as of 2026-06-19: all required inputs confirmed. Packet is submit-ready.

Confirmed from the Certificate of Incorporation (2026-06-19):

- [x] **Applying entity** — **Guided AI Labs Ltd.** is its own federal
  corporation. Apply directly as GAIL (option (a)); no AG-Operations framing
  needed. The §2 consultancy-exclusion mitigation still applies to the *pitch
  wording* — keep it product-first — but the legal registrant is unambiguously a
  for-profit corporation.
  - Incorporated under the **Canada Business Corporations Act** (federal).
  - **Corporation number: 1797857-0** (have this ready for Founders Hub business
    verification).
  - **Adam Goodwin is the sole founder, owner, and director** of Guided AI Labs
    Ltd. (The "Hantz Prosper" signature on the certificate is the government CBCA
    Director who issues incorporation certificates — not a company officer.) So
    the applicant, founder, and director are all the same person; use Adam's
    personal LinkedIn for the founder-verification field.
- [x] **Incorporation / founding date** — **2026-05-29**. Well under the 7-year
  limit (~3 weeks old at application).

Confirmed by Adam (2026-06-19):

- [x] **Website** — `https://guidedailabs.com`, live and product-facing. Use as
  the application URL. (Note: site returns HTTP 403 to automated fetchers — bot
  protection, not an outage; reviewers in a browser are unaffected.)
- [x] **Funding** — none. Bootstrapped, no institutional funding → self-serve
  tier.
- [x] **Investor / accelerator affiliation** — none. Self-serve tier only; do not
  claim the $150K investor path.
- [x] **Founder identity / brand face** — everything is presented under Guided AI
  Labs. There is an existing **AG Operations** LinkedIn presence but the public
  face is GAIL. For the application's founder-verification field, use Adam
  Goodwin's personal founder LinkedIn (individual profile, not a company page);
  confirm/supply that URL. Separately consider whether a GAIL-branded LinkedIn
  presence is worth standing up so the product face is consistent (optional, not
  a blocker).

---

## 1. What Founders Hub grants (why this matters)

Self-serve tier, no VC required (verify exact terms at submission — Microsoft
changes these):

- **Microsoft 365 Business Premium** seats at $0 → unlocks Entra ID P1
  (Conditional Access, real least-privilege boundaries for agents), Intune +
  Defender for Business, and Purview labels/DLP/retention. This is the **Stage 7
  security upgrade, potentially free**.
- **Azure credits** ($1,000 on signup → up to $5,000 after business verification)
  → Azure Key Vault for Stage 9 agent secrets, Azure OpenAI / AI Foundry for the
  custom-model lane.
- **GitHub Enterprise** free (overkill for a solo repo, but free).
- Full Microsoft 365 Copilot is **not** automatically included on the free tier;
  re-check at application time whether a Copilot benefit applies. Bucket B
  (pay-as-you-go Copilot Credits) remains the interim grounding path regardless.

---

## 2. Eligibility assessment + framing strategy

**Eligibility signals (likely PASS):** for-profit; bootstrapped/solo founder is
explicitly allowed; under 7 years old (pending the founding-date confirmation);
not previously enrolled.

**The one real risk: the consultancy exclusion.** Founders Hub targets companies
building a **software/AI product**; pure consultancies are typically excluded.
Your own `guided-ai-labs-m365-foundation-build-brief.md` describes GAIL as a
"consulting and client-facing AI governance/automation company" — that wording,
if it reaches a reviewer, reads as a services firm.

**Mitigation — lead with the products, which are real and verifiable:**

- **Change Leadership Tools** — a live software product (Supabase backend, user
  accounts, downloadable tools) at `changeleadershiptools.com`.
- **Graphify** — a workspace knowledge / decision-intelligence product layer.
- **A user-facing AI Operating System (UAOS)** under active development.
- An early product pipeline (OldSkoolAI, EasyDraftDocs, Freedom).

This is an **honest reframe, not a fabrication**: the company genuinely builds AI
software products; consulting is how early product work is funded, not the thing
being pitched. Every free-text answer below describes Guided AI Labs as an **AI
product company**, names shipping/active products first, and keeps the word
"consultancy/consulting" out of the pitch. Keep the live product URL prominent so
a reviewer who clicks sees a product, not a services brochure.

---

## 3. Drafted application answers (field by field)

The Founders Hub flow asks short structured fields plus one or two free-text
"about your startup" boxes. Exact fields change; map these to whatever the live
form shows.

| Field | Drafted answer |
|---|---|
| Company / startup name | **Guided AI Labs Ltd.** |
| Legal entity / registration | Federal corporation, Canada Business Corporations Act; corp. # **1797857-0** |
| Website | `https://guidedailabs.com` (confirmed) |
| Country / region | Canada |
| Your role | Founder |
| Company stage | Bootstrapped / pre-seed, building and shipping AI products |
| Year founded | **2026** (incorporated 2026-05-29) |
| Funding raised | None / bootstrapped (confirmed) |
| Industry / category | Artificial Intelligence / SaaS productivity & governance tooling |
| Investor / accelerator affiliation | None — self-serve tier (confirmed) |
| Microsoft products of interest | Azure (OpenAI / AI Foundry, Key Vault), Microsoft 365, GitHub |
| Founder identity link | `https://www.linkedin.com/in/adamgoodwin1/` |
| What are you building? | See §4 short pitch |

---

## 4. Company description (the field that decides it)

**One-liner (if a tagline field exists):**

> Guided AI Labs builds AI products that turn everyday business operations into
> governed, agent-ready systems.

**Short pitch (~75 words — the "what does your company do" box):**

> Guided AI Labs is an AI product company building tools that let small and
> mid-sized organizations run like much larger, AI-native firms. Our live product,
> Change Leadership Tools, gives teams structured tooling for organizational
> change. We are extending this into Graphify, a workspace decision-intelligence
> layer, and a user-facing AI Operating System that safely connects AI agents to
> the systems a business already runs on — with governance, audit, and human
> approval built in from the start.

**Extended pitch (~150 words — if a longer box is offered):**

> Guided AI Labs builds AI products that make business operations agent-ready
> without giving up control. Most AI tooling either stays a disconnected chatbot
> or wires agents straight into production systems with no guardrails. We build
> the governed middle layer: an architecture where AI suggests, a human approves,
> and the system acts, with every action logged and reversible.
>
> Our shipping product, Change Leadership Tools, already serves users with
> account-based software for organizational change. We are building on it with
> Graphify, a workspace knowledge and decision-intelligence layer, and a
> user-facing AI Operating System (UAOS) that connects agents to Microsoft 365,
> local, and cloud systems through scoped, audited bridges.
>
> We are bootstrapped and founder-led, and we need Azure AI and identity-grade
> security (Entra ID P1, Purview, Key Vault) to take these products from governed
> pilots to production safely.

> Note: keep this benefits-focused and product-first. Do not describe the company
> as a consultancy or services firm in any field (see §2).

---

## 5. Decision Register entry (governance tie-in)

Per `docs/AGENTIC_M365_READINESS.md` and the activation plan, the Founders Hub
application is a recorded decision, not a silent action. Draft entry for the
Guided AI Labs **Decision Register**:

```text
Title:    Apply to Microsoft for Startups Founders Hub as Guided AI Labs
Decision: Submit a self-serve Founders Hub application framing Guided AI Labs as
          an AI product company (lead products: Change Leadership Tools, Graphify,
          UAOS), to unlock Business Premium + Azure credits at $0 and resolve the
          Stage 7 security upgrade and Bucket C tooling at no/low cost.
Owner:    Adam Goodwin
Scope:    External program application only. No tenant write, no consent grant,
          no spend commitment. Founders Hub Azure credits, if granted, are used
          under a stated ceiling per future Decision Register entries.
Risk:     Consultancy-exclusion risk mitigated by product-first framing (§2).
Rollback: Application can be withdrawn; no benefit is auto-enabled until claimed.
Status:   Submitted [DATE ON SUBMISSION]
Links:    docs/FOUNDERS_HUB_APPLICATION_PACKET.md,
          docs/AI_FIRST_TOOLING_ACTIVATION.md
```

This is a documentation draft; the live Decision Register write is a separate,
approval-gated step and is **not** required before submitting the application.

---

## 6. Submission checklist

1. Fill the six inputs in §0.
2. Re-verify Founders Hub current terms and tiers at
   `https://www.microsoft.com/en-us/startups` (Microsoft changes these often —
   tier amounts, Copilot inclusion, eligibility wording).
3. Confirm the website URL resolves to a product-facing page before submitting.
4. Submit as Guided AI Labs, signed in with the founder identity.
5. Record the submission date in the §5 Decision Register entry and in the next
   session turnover.
6. After approval: do **not** auto-claim Business Premium seats. Treat the
   Premium/Copilot/Azure-credit activation as separate Decision Register entries
   with stated scope and ceiling (Bucket C, activation Steps 5–6).

---

## 7. Account & eligibility gotcha (live finding 2026-06-19)

First submission attempt hit an account-eligibility wall. Recorded so it is not
relitigated:

- Going to `foundershub.microsoft.com` → **Get started** → signing in with the
  **GAIL work account** `adamgoodwin@guidedailabs.com` failed eligibility and
  redirected to `portal.azure.com` with: *"This account can't be used for
  Microsoft for Startups"* and *"You are not eligible for startup credit offers
  … sign in with a personal Microsoft account to redeem Azure credits."*
- **Likely cause:** the work account is Global Admin of the A.G. Operations Ltd
  tenant, which already holds an Azure subscription ("Azure subscription 1"). The
  self-serve startup-credit flow will not provision a clean sponsored
  subscription onto that entangled work account, so it requires a personal MSA.
- **Resolution / decision:** own the Founders Hub **membership** on Adam's
  **personal Microsoft account**; enter **Guided AI Labs Ltd.** as the company in
  the application (name, website, corp # 1797857-0, pitch). The company is what is
  vetted and what the benefits attach to. Benefits route to GAIL afterward: Azure
  credits to a sponsored subscription used for GAIL workloads; Business Premium /
  M365 routing into the tenant resolved at claim time.
- **Trade-off accepted:** the membership login is a personal account, not the
  GAIL identity — a deliberate exception to the "everything under GAIL" lane
  preference, forced by Microsoft's flow. The *company, benefits, and product
  face* stay GAIL.
- **Open item to verify at claim time:** how the Business Premium benefit applies
  to the existing A.G. Operations Ltd tenant (new tenant vs. add seats to current
  tenant), and whether the Azure credit subscription should be associated/
  transferred into the GAIL-facing structure.

### Refined diagnosis after first live attempt (2026-06-19, web-verified)

Both accounts hit the "This account can't be used for Microsoft for Startups
credits" wall. Per Microsoft Q&A, this is a known issue with several triggers,
and **multiple apply at once here** — which is why the flow felt incoherent:

1. **Account/domain mismatch** — signing in with personal `adamgdwn@hotmail.com`
   while the company is tied to `guidedailabs.com`.
2. **Unmanaged Azure AD** — the personal account sits in an auto-created
   "DEFAULT DIRECTORY (ADAMGD…)", a named trigger for this error.
3. **Incomplete verification** — the $1,000 → $5,000 unlock requires completing
   the Founders Hub checklist, especially **business domain verification**.
4. **Existing subscription** — the work tenant already holds "Azure subscription
   1," which can contend with a new sponsored subscription.

**The real lever:** business **domain verification of `guidedailabs.com`**. It
ties the membership to Guided AI Labs Ltd. AND unlocks the $5K + Business Premium
benefits. But `guidedailabs.com` lives in the **work tenant** while Microsoft
forced the membership onto the **personal** account — a routing knot.

**Decision: paused the live signup at the credit-card / identity step.** No card
was entered; no card should be entered while the flow is throwing eligibility
errors.

**Recommended next attempt (own session, not rushed):**
- Resolve the account-routing question first: either complete domain verification
  of `guidedailabs.com` against whichever account owns the membership, or open a
  Microsoft for Startups support ticket at `aka.ms/startuphelp-mfs-portal` to sort
  the personal-vs-work-tenant eligibility routing.
- Confirmed benefits still real (web-verified 2026-06-19): M365 Business Premium,
  GitHub Enterprise, $1K→$5K self-serve Azure credits. Worth getting right.
- Sources: Microsoft Q&A "this account can't be used for credits"; Founders Hub
  Azure activation FAQs (`aka.ms/startuphelp-mfs-portal`).

## 8. Reconciliation note

`TOOLING_AND_LICENSING.md` and project memory record a sibling local project
("Guided AI Labs — Funding & Benefits", local-only, not in git) that was meant to
hold the Founders Hub execution plan. That folder is **not present on this
machine**. If a fuller plan exists there on another laptop, reconcile this packet
with it before submitting so the two do not diverge. This packet is written to be
self-sufficient if that plan is unavailable.
