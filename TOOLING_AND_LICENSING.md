# Tooling & Licensing — Optimization Reference

**AG Operations / Guided AI Labs — Microsoft 365 Foundation**
Created 2026-06-11. A project-wide "are we using the optimum tools, and are there
free licenses that save time/tokens" reference. Findings are dated because
licensing programs change. Start at [00_INDEX.md](00_INDEX.md).

---

## TL;DR — the three things worth acting on

1. **Apply to Microsoft for Startups Founders Hub as _Guided AI Labs_.** It can
   grant **Microsoft 365 Business Premium free** + **Azure credits** + free GitHub
   Enterprise. Business Premium = Entra ID P1 (Conditional Access), Intune, Defender
   for Business — i.e. the **Stage 7 security upgrade, potentially at $0**, plus
   Azure for break-glass/agent secrets. **Biggest time/token saver on the table.**
2. **Turn on (or confirm) Security Defaults now — it's free.** Business Standard
   already includes Entra ID Free, which gives **free MFA via Security Defaults**.
   This is the immediate mitigation for the "`adamgoodwin@` keeps Global Admin"
   accepted risk, available today at no cost.
3. **Stay API-first (Microsoft Graph).** Our current raw-REST + device-code approach
   is already the token-cheapest, most auditable way for an agent to operate M365.
   Keep it as the workhorse; reserve browser automation for true no-API gaps.

---

## 1. Free / low-cost licensing — what actually applies

| Program | What you'd get | Eligibility (as of 2026-06) | Verdict for us |
|---|---|---|---|
| **Microsoft for Startups Founders Hub** | Up to **$5K Azure credits** self-serve ($150K via investor path); **free M365 Business Premium**; free GitHub Enterprise; Azure OpenAI/AI credits; mentors | Bootstrapped/solo/pre-revenue OK, **<7 yrs old**, no VC needed. **For-profit software/AI product** is the target; **consultancies are typically excluded.** | **Apply as Guided AI Labs (the AI product), NOT AG Operations (consulting).** Highest-value, do this early. |
| **Microsoft 365 Developer Program** (free E5 sandbox, 25 seats, 90-day auto-renew) | A **separate throwaway tenant** to practice writes/agents safely without touching production | **Restricted in 2025–26:** now needs a **Visual Studio Pro/Enterprise** subscription or **Microsoft Partner** status | Only if you have/obtain VS or Partner status. Valuable as a **safe test tenant** if obtainable. |
| **Entra ID Free** (already included) | **Security Defaults = free MFA**, basic identity protection | Included in every Business plan you already own | **Use now.** Free baseline security. |
| **Azure free tier / credits** | Key Vault (secret storage), Functions, AI services — pennies or free under credits | Pay-as-you-go free tier; or covered by Founders Hub credits | Use Key Vault for Stage 9 secrets; free under Founders Hub credits. |
| **GitHub Free** (already in use) | Unlimited private repos | Already active | Keep. Founders Hub would add Enterprise (overkill but free). |

**Action:** evaluate the Founders Hub application for Guided AI Labs before the
Stage 7 license decision — it may make "upgrade to Business Premium" a free yes.

---

## 2. Our toolchain — is it optimum?

| Tool / choice | Status | Note |
|---|---|---|
| **Microsoft Graph REST + device-code** (our scripts) | ✅ Keep as primary | Lean, transparent, no heavy module load; device-code makes sign-in visibly attended. Token-cheapest interface. |
| **Microsoft Graph PowerShell SDK** | ◻ Not preferred | Typed cmdlets but large/slow module load; heavier than REST for an agent. Use only where a cmdlet is clearly simpler. |
| **Graph `$batch`** | ⬆ Optimization to adopt | Combine up to **20 requests per call** — collapses our N+1 role-member loops into far fewer round-trips. Faster + fewer agent tokens. Apply when scripts grow. |
| **Graph delta queries** | ◻ Minor here | Avoids re-pulling everything on re-inventory; marginal at 4 users. |
| **PnP PowerShell** | ✅ For Stage 3 | Free, standard for SharePoint IA work. |
| **Graph X-Ray / Graph Explorer** | ✅ Free dev aid | Graph X-Ray (browser ext) reveals the exact Graph calls the admin portal makes — speeds writing our scripts; Graph Explorer for safe read tests. |
| **Azure Key Vault** | ✅ Stage 9 secrets | Cheap/free-under-credits home for the agent's vaulted certificate/secret. |
| **Webwright** (code-driven browser) | ⏳ Earmark for Stage 9 | Token-efficient browser automation for portal-only gaps; low-priv/read only. See below. |

### Token-efficiency principle (applies to every agent runner)

Cheapest → most expensive interface to M365:

1. **Graph API** — structured JSON; the workhorse.
2. **Code-driven browser** (Webwright-style) — for no-API gaps; far cheaper than
   screenshot streaming.
3. **Live screenshot/frame streaming** — avoid for routine work.

Also: prefer **`$batch`-ed Graph calls** and **write-code-then-read-concise-output**
over chatty step-by-step narration. "Watch the trace/log," not "watch every frame."

---

## 3. Webwright (Microsoft Research, ~2026-05-24)

`github.com/microsoft/Webwright` — terminal-native web-agent harness. The model
**writes Playwright/bash code** to drive a browser and screenshots **only when
needed**, compacting history every ~20 steps. Model-agnostic (GPT-5.4, Claude Opus
4.7). Markedly cheaper than naive screenshot-per-step browser watching.

- Does **not** replace Graph — a Graph call is cheaper and most M365 admin has an API.
- **Does** make the **Level-2 portal-only fallback** much cheaper → earmark for Stage 9.
- Caveats: savings come from *not* live-streaming (review artifacts after, not a live
  window); no defined auth model in its writeup → keep to **low-priv/read** portal
  tasks, never a path to admin power; research-grade and new — experiment only.

---

## 4. Open follow-ups

- [ ] Assess Founders Hub eligibility/application for **Guided AI Labs** (pre-Stage 7).
      Planning now lives in the **sibling local project** `Guided AI Labs - Funding &
      Benefits` (folder beside this repo; local-only, not in git). It maps the broad
      funding landscape and holds the Founders Hub execution plan.
- [ ] Confirm current MFA posture in-tenant (Security Defaults on? per-user MFA?) —
      add a read to the Stage 2 verify script next time it runs.
- [ ] If a safe test tenant is wanted, check Visual Studio / Partner eligibility for
      the M365 Developer sandbox.
- [ ] Adopt Graph `$batch` when the Stage 2+ scripts add write/verify breadth.
