# AI-First Tooling Activation

Date: 2026-06-19

Status: Active activation plan for the Microsoft AI/automation surface. Companion
to `docs/AGENTIC_M365_READINESS.md` (governance) and `docs/START_HERE.md`
(operator handoff). Readiness says *how to govern* AI work. This doc says *which
Microsoft tools to turn on, in what order, free first*.

Read this alongside the readiness map. Nothing here overrides the G0–G4 approval
gates, the Decision Register, or the Agent Action Log. This doc adds the missing
half: the capability inventory and turn-on sequence so "AI-first" is a checklist,
not a posture.

## The Organizing Fact

Guided AI Labs is on **Microsoft 365 Business Standard**, not Business Premium
(confirmed: raw SKU `O365_BUSINESS_PREMIUM` is the legacy name for Business
Standard; true Premium is SKU `SPB`, not held). That single fact decides which
AI tools are reachable today versus which need a license unlock.

The license unlock is **Microsoft for Startups Founders Hub** (apply as *Guided
AI Labs*, the AI product entity — not AG Operations the consultancy, which may be
excluded). Founders Hub can grant Business Premium seats + Azure credits at $0.
So the entire paid AI tier is potentially free — *if* the application lands.

This reframes the whole plan into three buckets:

```text
A. Free + yours today          -> turn on now, inside G0–G2
B. Metered, pay-per-use        -> turn on when a card needs it, costs controllable
C. License-gated               -> unlock via Founders Hub, not by paying per seat
```

## Bucket A — Free And Yours Today (turn on now)

All of these are included with Business Standard / Entra ID Free and fit inside
the existing G0–G2 envelope. None require the $30/seat Copilot license.

| Tool | What it gives an AI-first agency | Governance lane | Cost |
|---|---|---|---|
| **Microsoft 365 Copilot Chat** | Web-grounded AI chat with commercial data protection for every user. NOT grounded in tenant records. Safe daily AI assistant. | G0/G1 | Free with M365 |
| **Declarative agents (instructions + public web)** | Custom agents published to Copilot Chat, scoped by instructions and public sites. Consume **zero** Copilot Credits. | G1 | Free |
| **Copilot Studio (maker access)** | Build and test agents. Note: trial license builds/tests but **cannot publish**; publishing tenant-grounded agents needs Bucket B or C. | G0/G1 | Free to build |
| **Power Automate (standard connectors)** | Cloud-flow automation across SharePoint, Outlook, Lists, Teams, Forms. The agency's automation backbone. | G1/G2 | Seeded with M365 |
| **Power Apps (standard connectors)** | Better front doors for cards than raw SharePoint forms (SharePoint-backed apps). | G1/G2 | Seeded with M365 |
| **Forms / Lists / Planner / To Do / Loop** | Intake, queues, task state, collaborative AI-assisted pages — the signal layer agents read. | G0–G2 | Free |
| **Microsoft Graph** | The controlled API substrate already used by the provisioning scripts. | G0–G3 | Free |
| **Security Defaults (free MFA)** | Entra ID Free MFA. The standing mitigation for `adamgoodwin@` holding Global Admin. | n/a | Free |
| **Designer / Clipchamp** | AI image + video generation for marketing/content with monthly credits. | G0 | Free tier |

Immediate move: confirm Copilot Chat is enabled for the tenant, and build one
declarative agent (instructions + public-web only) as the first visible AI-first
artifact — zero cost, zero new permission risk, demonstrable to clients.

## Bucket B — Metered, Pay-Per-Use (the key unlock most shops miss)

You do **not** need a $30/seat Copilot license to get AI grounded in *your own*
SharePoint records. Tenant-grounded agents run on **Copilot Credits** via
**pay-as-you-go** ($0.01/credit, billed through an Azure subscription — no seat
commitment, pay only for what's consumed).

| Capability | When credits are consumed | Cost control |
|---|---|---|
| Agent grounded in SharePoint / Graph tenant data | On each tenant-data retrieval / generative answer | PAYG meter; unlink Azure billing to stop |
| Agent flows / actions from Copilot Studio | On flow/action execution | Cap via capacity pack or PAYG ceiling |
| Capacity packs (alternative to PAYG) | 25,000 credits / $200 / month, prepaid | Fixed monthly ceiling |

Why this matters: it lets Guided AI Labs run agents over the already-built
SharePoint IA (the 5 sites, the metadata schema) at consumption cost — likely a
few dollars/month at pilot scale — instead of buying full Copilot seats. This is
the highest-leverage, lowest-commitment AI move available right now.

Gate: Bucket B touches tenant records, so it requires a **Decision Register**
entry (scope, owner, PAYG ceiling, rollback = unlink billing) before the first
tenant-grounded publish. Maps to **G2** (internal read/draft) — not G3 unless the
agent writes, sends, or shares.

## Bucket C — License-Gated (unlock via Founders Hub)

These need Business Premium or the full Microsoft 365 Copilot add-on. The
recommended path is to obtain them through Founders Hub rather than paying.

| Tool | Unlocks | Comes with |
|---|---|---|
| **Microsoft 365 Copilot (full, $30/seat)** | Zero-rated tenant grounding, **SharePoint agents free**, Copilot in Word/Excel/Outlook/Teams, Copilot Analytics | Per-seat add-on, or Founders Hub |
| **Entra ID P1** | Conditional Access, real least-privilege boundaries for agents, JIT groundwork | Business Premium |
| **Intune + Defender for Business** | Device + endpoint security posture | Business Premium |
| **Purview (auto labels, DLP, retention)** | The sensitivity/DLP controls the readiness doc currently has to defer | Business Premium / higher SKUs |
| **Azure AI Foundry / Azure OpenAI** | Custom-model lane beyond Copilot | Founders Hub Azure credits |

Founders Hub credit tiers (verified 2026): $1,000 on signup → verify business →
up to $5,000 → investor-affiliated startups up to $150,000. Software/AI product
companies are the target; consultancies may be excluded.

## Activation Sequence

Ordered so value lands early and risk stays inside existing gates.

1. **Confirm + use the free tier (Bucket A).** Enable/confirm Copilot Chat
   tenant-wide; confirm Security Defaults MFA is on. Ship one declarative agent
   (instructions + public web only) — first AI-first artifact, $0, G1.
2. **Apply to Founders Hub as Guided AI Labs.** This is now a near-term action,
   not a Stage 7 footnote — it gates all of Bucket C. Decision Register entry.
3. **Pilot one tenant-grounded agent (Bucket B)** over a single SharePoint site
   (e.g. Published Methods or CRM knowledge), on PAYG with a stated credit
   ceiling. Decision Register entry; rollback = unlink Azure billing. Log it in
   the Agent Action Log. This proves the G2 read/draft loop end-to-end.
4. **Stand up one Power Automate flow** for a real card (e.g. intake → Lists →
   notify). Proves the free automation backbone. G2.
5. **On Founders Hub approval**, evaluate full Copilot seats (zero-rated
   grounding + free SharePoint agents) and Business Premium security stack;
   migrate the Bucket B pilot to zero-rated if the seat math wins.
6. **Harden with Purview/DLP/Conditional Access** (Bucket C) before any broad
   rollout or external-facing agent — closes the open governance deferrals in
   the readiness doc.

## What This Changes In The Existing Docs

- `docs/AGENTIC_M365_READINESS.md` — its "Open Decisions" list (Security Defaults
  vs Premium, Copilot pilot scope, which content is too sensitive) now has a
  sequenced answer here. A6-03 (Business Premium) and A6-05 (first Copilot use)
  are effectively resolved: free-tier + PAYG pilot first, Premium via Founders
  Hub.
- The readiness model's "Copilot agents start read-only" lane is correct and
  unchanged — Bucket A/B both stay inside G0–G2.
- No change to G3/G4: external sends, writes, sharing, app consent, and
  unattended automation remain blocked behind the Decision Register.

## Verification Notes

Microsoft changes Copilot Chat / Copilot Studio metering and Founders Hub terms
frequently. Facts in this doc were verified live on 2026-06-19 against:

- Copilot Studio licensing (free declarative agents; PAYG $0.01/credit; tenant
  grounding zero-rated only with full Copilot license; SharePoint agents included
  with full Copilot): `https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing`
- Microsoft 365 Copilot pricing: `https://www.microsoft.com/en-us/microsoft-365-copilot/pricing`
- Founders Hub benefits/tiers (community summaries; confirm exact current terms
  at application time): `https://www.microsoft.com/en-us/startups`

Re-verify the metering rates and Founders Hub eligibility at the moment of each
activation step before committing spend.
