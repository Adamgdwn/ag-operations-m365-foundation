# Custom Intake Form Plan (replace Microsoft Forms with a branded site form)

**Status:** ✅ **ENDPOINT LIVE + VERIFIED (2026-06-23).** Premium license assigned → flow
**Started** → e2e PASS both brands (full field + provenance parity) → guard negatives
(bad secret / honeypot / bad source) all correctly **blocked** → 0 residue. Remaining:
hand the endpoint + secret + form spec to the Linux website repos, they build the branded
form, joint browser e2e, then switch CTAs + retire the Forms flows (§6).

**Status (history):** APPROVED — Power Automate HTTP-trigger path. Was BLOCKED ON LICENSE: the
HTTP request trigger needs **Power Automate Premium** (activation returned 403
`MissingAdequateQuotaPolicy`); resolved once a premium license was assigned to the maker. Decisions (2026-06-22): Adam chose to **pay for Power
Automate Premium** (over the non-premium app-reg/Graph or Forms-proxy paths) and confirmed
the brand sites **have a backend** (so the backend POSTs server-side to the flow URL with the
secret). Anti-spam = **secret header + honeypot** only (no CAPTCHA). Next: assign the license
→ `set-flow-state.js start` → `http-intake-e2e.js` → release form spec to the Linux repos.

Flow: `GAIL — Custom site intake to CRM (create-only, HTTP)` id
`9582c422-158d-4975-ba7f-81b4d77e497b`. Endpoint URL + shared secret live in
`.local/flow-builder/` (gitignored); handed to the website repos only after activation + e2e.

**Status (original):** DRAFT / awaiting go-ahead on the public HTTP write endpoint (see §7).
**Decided 2026-06-22:** Adam chose "go straight to custom form" over theming the
Microsoft Forms shell. The Forms look can't truly match a landing page (Forms only
allows a background colour/image, an accent colour, and a header image — no custom
fonts/layout/CSS). A custom form built into each brand site gives pixel-level control.

This supersedes the *look* of the Path B Microsoft Forms intake. It does **not**
change the CRM, the list schema, or the create-only safety model — the custom form
feeds the **same** `CRM - New Signals` list with the **same** fields.

---

## 1. Goal

Each brand site gets a hand-built intake form that matches its landing page
(Journey = dark charcoal bg, terracotta/burnt-orange accent, cream text, owl mark;
Labs = its own brand), submitting to the **same CRM** with full field + provenance
parity with today's Microsoft Forms path.

## 2. Architecture — current vs target

**Current (Path B, stays live as fallback until §6 is done):**
```
Microsoft Form (anon)  ──Forms "new response" trigger──>  Power Automate flow
   (one per brand)                                          Get response details
                                                            └─> SharePoint Create item  ─> CRM - New Signals
   Labs flow  0d717c08-2558-4ff8-a88f-26d723712b6d
   Journey    2a2cd963-1469-48a5-95a5-04e696ff3543
```

**Target:**
```
Custom HTML form on the site  ──HTTPS POST (JSON + secret)──>  Intake endpoint
   (matches landing page)            │                          └─ Power Automate
                                     │                             "When a HTTP request
   guidedaijourney.com              │                              is received" trigger (STANDARD)
   guidedailabs.com                 │                             └─> validate secret
                                     │                             └─> SharePoint Create item ─> CRM - New Signals
                          (optional site backend proxy
                           holds the secret server-side)
```

One **parameterised** HTTP flow handles both brands (payload carries `source`), so
there is a single intake endpoint to secure and maintain — not two.

## 3. Windows/tenant side (my build)

A new Power Automate flow **"GAIL — Custom site intake to CRM (create-only)"**:
- Trigger: **When a HTTP request is received** (Request trigger — *standard*, not premium).
  Gives a public POST URL with a SAS signature.
- Step 1: validate a shared secret (`x-intake-secret` header) — reject otherwise (HTTP 401).
- Step 2: validate honeypot field is empty + required fields present — reject otherwise (HTTP 400).
- Step 3: SharePoint **Create item** into `CRM - New Signals` (create-only; no updates/deletes/mail),
  mapping the payload to the **same** columns the Forms flow writes (see §4).
- Response: HTTP 200 `{ "ok": true }` on success; non-2xx with a short reason otherwise.
- Build script (to be added): `scripts/flow-builder/create-http-intake-flow.js`, using the
  same reverse-engineered Flow management API + warm-Edge/CDP token capture as the existing
  flow builders. Connection reused: SharePoint `4c53f079…` (no Forms connection needed).

## 4. Payload contract (what the site POSTs) and CRM mapping

```jsonc
POST {flow http url}
Headers: { "Content-Type": "application/json", "x-intake-secret": "<shared secret>" }
Body:
{
  "source":    "Guided AI Journey" | "Guided AI Labs",   // required, drives IntakeSource
  "fullName":  "string",                                  // -> PersonName
  "email":     "string",                                  // -> PersonEmail
  "organization": "string",                               // -> OrganizationName
  "needSummary":  "string (required)",                    // -> NeedSummary (+ Title = "<source> — <fullName|needSummary>")
  "situation": "one of the 4 IntentPath choices | ''",    // -> IntentPath (byte-identical strings) + SourceText line
  "heardFrom": "string",                                  // -> SourceText line
  "consent":   true,                                      // required true; -> SourceText "Consent: I agree"
  "company":   ""                                         // HONEYPOT — must be empty; bots fill it -> reject
}
```
Server-stamped on create (not from the client): `SignalType=Website`, `SignalStatus=New`,
`Priority=Normal`, `NextAction="Triage new website signal"`, and the **provenance footer**
appended to SourceText (Source, Capture="Auto-captured via custom site form", submitted timestamp,
a generated intake id). `IntentPath` choice strings MUST stay byte-identical to
`config/crm.sharepoint.json` (the four "Just me / My team / My organization / Governance or policy"
values) so it passes straight through — same rule as today.

## 5. Linux/website side (the form itself — handoff to the brand repos)

The form UI + client behaviour is built in each website repo (it is their landing-page design):
- Markup/styling that matches the landing page (full control: fonts, layout, colours, owl mark).
- Fields exactly matching §4 (same set + order as the Forms version, so CRM record shape is unchanged).
- A **honeypot** field (hidden `company` input) and a real **CAPTCHA** (recommend Cloudflare
  Turnstile — free, privacy-light) because a public write endpoint has none of Forms' built-in bot defence.
- Submit handling — **two options, the site picks by its stack:**
  - **(A) Server proxy (preferred if the site has any backend / API route / serverless fn):**
    form POSTs to the site's own endpoint; the backend holds the secret + verifies Turnstile,
    then forwards to the flow URL. The flow URL and secret never reach the browser. Most secure.
  - **(B) Direct (if the site is fully static):** form POSTs straight to the flow URL with the
    secret header + Turnstile token. The flow URL/secret are visible in client JS — acceptable
    for a create-only public intake, but relies on the secret + Turnstile + honeypot for abuse control.
- On success show an on-brand thank-you state; on error, a friendly retry.

A spec packet mirroring §4 will go to each repo: `WINDOWS_TO_{LABS,JOURNEY}__custom-intake-form-spec.json`.

## 6. Transition plan (non-destructive)

1. Build + deploy the HTTP flow (gated — §7).
2. e2e test it server-side (POST a `GAIL-INTERNAL-WALKTHROUGH` payload → confirm CRM item parity →
   scope-delete) exactly like the Forms e2e, using `scripts/flow-builder/delete-test-records.js`.
3. Linux builds the branded form against the contract; joint e2e from a real browser submit.
4. Only after both brands pass: switch each site's CTA to the new form and **retire** the Microsoft
   Forms flows (turn OFF via `scripts/flow-builder/set-flow-state.js`, reversible) — do not delete the
   forms immediately. The Microsoft Forms path stays the live fallback until then.

## 7. Open decision — public HTTP write endpoint into the live CRM (needs Adam's OK)

This introduces a **new public write surface**: an internet-reachable URL that creates items in the
live CRM. Today's Forms path writes to the CRM too, but only Microsoft Forms can trigger it; a raw
HTTP endpoint can be called by anyone who has (or guesses traffic to) the URL.

**Safety envelope proposed (scoped, same spirit as Path B):**
- Create-only into `CRM - New Signals`; no updates, deletes, mail, sharing, or other lists. Standard connectors only.
- Shared-secret header required; honeypot + Cloudflare Turnstile required on the form; server proxy preferred.
- All items land `SignalStatus=New` for human triage; no automated outreach.
- Reversible: flow can be turned OFF instantly; Microsoft Forms fallback stays live through transition.

**Residual risk:** a leaked secret/URL allows spam *create* of New-Signal items (triage noise), not
data exfiltration or modification. Mitigated by Turnstile + secret rotation + the create-only fence.

**Decision needed:** approve standing up this endpoint under the envelope above (then I build + deploy
the flow and run the server-side e2e), or hold and keep Forms-only for now.
