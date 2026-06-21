# CRM Path B — V7 Build Kit (Forms + Flow, portal session)

Date: 2026-06-20
Status: READY TO BUILD. Path B is already authorized (scoped unlock: two named
brand Forms + one create-only flow). This kit makes the gated M365 portal session
a fast click-through. The CRM list target is live (`IntakeSource` created;
Chunk 3 verifier 0 failures / 0 warnings, 2026-06-20).

Why a portal session and not a script: **Microsoft Forms has no supported
creation API** — the form is authored in the browser. Everything else (the list,
the field mapping, verification) is already scripted/proven. One persisted
sign-in covers the whole session.

Build Guided AI Labs first end-to-end, then clone the pattern for Guided AI
Journey (structurally identical form, second flow or second trigger).

---

## Step 1 — Create the Form (forms.office.com, signed in as tenant)

New Form, title: **Guided AI Labs — Get started**
Settings: **Anyone can respond** (anonymous). No sign-in required. One response
per submit (do NOT limit to one response per person — public intake).
No file upload. No quiz.

Questions (order matters; keep tight):

1. **Full name** — Text, single line — **Required**
2. **Email** — Text, single line, **Restrict to email format** — **Required**
3. **Organization** — Text, single line — optional
4. **What are you looking for?** — Text, **long answer** — **Required**
5. **How did you hear about us?** — Text, long answer — optional
6. **I agree to be contacted about my enquiry.** — Choice (single) with one
   option "I agree", marked **Required** (acts as consent checkbox)

> If Adam said yes to extras: add **Intent** — Choice (Just me / My team / My
> organization / Governance) and/or **Phone** — Text optional. Keep both forms
> identical if added.

After publishing, **Collect responses → copy the public link**. That link is the
URL handed to the website (`WINDOWS_TO_LINUX__crm-intake-form-url.json`).

---

## Step 2 — Create the Flow (make.powerautomate.com, same sign-in)

Automated cloud flow. **Standard connectors only** (Microsoft Forms + SharePoint).
No premium, no HTTP action, no Dataverse/Dynamics.

1. **Trigger:** Microsoft Forms → *When a new response is submitted* → select the
   Guided AI Labs form.
2. **Action:** Microsoft Forms → *Get response details* → same form → Response Id
   from the trigger.
3. **Action:** SharePoint → *Create item*
   - Site: `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
   - List: **CRM - New Signals**
   - Field mapping below.
4. End. **No** send-email, **no** respond-to-submitter, **no** update/delete of any
   other item, **no** branch to another list/mailbox/system.

### Create item — field mapping

Operator-visible (clean) fields:

| CRM column (internal) | Value |
|---|---|
| `Title` | `concat('Guided AI Labs — ', coalesce(<Full name>, <Organization>, <Email>))` |
| `PersonName` | Form: Full name |
| `PersonEmail` | Form: Email |
| `OrganizationName` | Form: Organization |
| `NeedSummary` | Form: "What are you looking for?" |
| `SourceText` | Labelled dump of ALL answers (incl. "How did you hear", consent) |
| `SignalType` | constant `Website` |
| `IntakeSource` (**Source**) | constant `Guided AI Labs` |
| `SignalStatus` | constant `New` |
| `Priority` | constant `Normal` |

Provenance → existing **hidden** technical fields (never on the form; stay
`ShowInNewForm=false` AND `ShowInEditForm=false`):

| Hidden column | Value |
|---|---|
| `SourceMessageId` | Forms response id |
| `ReceivedDate` | submission timestamp |
| `IntakeStatus` | constant `Auto-captured` |
| `SourceMailbox` | constant `Guided AI Labs intake form` |

Leave blank: `DurableHome`, `PlannerTaskUrl`, `CentralOSLink`, `GraphNodeId`,
`AgentConfidence`, `FollowUpDueDate`, `RelatedLink`, `ItemOwner`.

> Choice-field note: `SignalType`, `IntakeSource`, `SignalStatus`, `Priority` are
> Choice columns. If `Website` is not already an allowed choice on `SignalType`,
> add it to the column (or set SignalType to an existing allowed value and carry
> "Website" via Source) — confirm allowed choices during the session.

---

## Step 3 — End-to-end test (V8)

1. Submit one dummy response on the live form, **Full name prefixed
   `GAIL-INTERNAL-WALKTHROUGH`**.
2. Confirm a new **CRM - New Signals** item appears: `Source = Guided AI Labs`,
   `SignalStatus = New`, clean fields populated, provenance written IN-BAND into the
   visible `SourceText` note (brand, intake form, Forms response id, submit time,
   "Auto-captured") — the recovered list has NO hidden technical fields, so there is
   nothing technical to hide; **nothing technical visible** on the item's display/edit form.
3. Re-run the Chunk 3 verifier (V2): must still PASS 0/0 (no blocked field became
   visible).
4. Later: repeat the live test via the **website CTA** (not just the raw form
   link) once Linux deploys the CTA component.

---

## Step 4 — Mint + hand off the URL

Drop the public form link to the website agent:
`X:\WINDOWS_TO_LINUX__crm-intake-form-url.json` with the Guided AI Labs URL.
Linux swaps its placeholder `NEXT_PUBLIC_GAIL_INTAKE_FORM_URL` → real URL →
redeploy.

---

## Step 5 — Second brand (Guided AI Journey)

Clone Step 1 (identical questions, title "Guided AI Journey — Get started") and
Step 2 (constant `IntakeSource = Guided AI Journey`, `SourceMailbox = Guided AI
Journey intake form`). Either a second flow or a second trigger on one flow. Then
repeat Steps 3–4 with `NEXT_PUBLIC_GAJ_INTAKE_FORM_URL`.

---

## Safety envelope (unchanged, must hold)

Public submission limited to exactly these two Forms. Flow is **create-only** into
`CRM - New Signals`: no deletes, no updates to other records, no mail sends, no
auto-reply, no external sharing, no guest invites, no permission/consent changes,
standard connectors only, no Dynamics/Dataverse. All items land `SignalStatus=New`
for human triage; no automated outreach. Blocked technical fields stay hidden.
Source of truth: `docs/CRM_PUBLIC_INTAKE_PATH_B.md`.
