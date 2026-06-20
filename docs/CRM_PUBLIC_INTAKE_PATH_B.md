# CRM Public Intake — Path B (Brand Forms → CRM)

Date: 2026-06-20
Status: AUTHORIZED design. Build is deferred to a gated session (see
`docs/CRM_DEFERRED_VERIFICATION_LOG.md`, items V7/V8). The PnP apply scripts do
NOT build this; it is built in the Microsoft 365 portals (Forms + Power Automate)
under the bounded safety envelope below.

## What this is

Two public, anonymous **Microsoft Forms** — one per brand:

- **Guided AI Labs** intake form
- **Guided AI Journey** intake form

Each form's submissions are turned into a clean record in **`CRM - New Signals`**
by a **create-only Power Automate flow**, which stamps the originating brand into
the operator-visible `Source` field (`IntakeSource`) and writes capture metadata
into the existing hidden technical fields. Submissions land as `SignalStatus = New`
for human triage. There is no automated reply or outreach to the submitter.

This is the "intake forms from Guided AI Labs and Guided AI Journey auto-populate
the CRM and identify the source" decision, implemented within a tight envelope.

## Why it needs a governance unlock

It crosses two of the standing CRM safety limits, deliberately and narrowly:

- **No public Forms links** → lifted ONLY for these two named intake forms.
- **No unattended automation** → lifted ONLY for the create-only intake flow
  described here.

Every other safety limit stays in force. The `safetyLimits` in
`config/crm.sharepoint.json` are left intact because they correctly describe the
PnP apply scripts, which still touch nothing but SharePoint lists/views/nav.

## Field mapping (Form response → CRM - New Signals)

Clean, operator-visible fields:

| CRM field (`internal`) | Source |
|---|---|
| `Title` | `"<Brand> — <Name or Organization>"` (flow-composed) |
| `PersonName` | Form: full name |
| `PersonEmail` | Form: email |
| `OrganizationName` | Form: organization (optional) |
| `NeedSummary` | Form: "What are you looking for?" |
| `SourceText` | Full raw submission dump (all answers, labelled) |
| `SignalType` | Constant `"Website"` |
| `IntakeSource` (**Source**) | Constant per form: `"Guided AI Labs"` or `"Guided AI Journey"` |
| `SignalStatus` | Constant `"New"` |
| `Priority` | Constant `"Normal"` |

Provenance written into the EXISTING blocked/hidden technical fields (never shown
on the daily form — they keep `ShowInNewForm=false` AND `ShowInEditForm=false`):

| Hidden field | Source |
|---|---|
| `SourceMessageId` | Microsoft Forms response id |
| `ReceivedDate` | Form submission timestamp |
| `IntakeStatus` | Constant `"Auto-captured"` |
| `SourceMailbox` | Originating form name (e.g. `"Guided AI Labs intake form"`) |

`DurableHome`, `PlannerTaskUrl`, `CentralOSLink`, `GraphNodeId`, `AgentConfidence`
are left blank by Path B.

## Form content (keep tight)

Each brand form collects only:

1. Full name (required)
2. Email (required, validated)
3. Organization (optional)
4. "What are you looking for?" — free text (required)
5. "How did you hear about us?" — free text (optional)
6. Consent / privacy acknowledgement (required checkbox)

Do not collect anything sensitive. No file uploads in v1. Keep the two forms
structurally identical so one flow pattern serves both.

## Flow logic (one per form, or one flow with two triggers)

1. Trigger: **When a new response is submitted** (the brand form).
2. **Get response details**.
3. **Create item** in `CRM - New Signals` with the mapping above.
4. End. No "send email", no "respond to submitter", no update/delete of any
   other item, no branch that touches another list, mailbox, or external system.

Use only **standard (non-premium) connectors** (Microsoft Forms + SharePoint).
No Dataverse, no Dynamics, no premium connectors, no HTTP action.

## Safety envelope (the exact bounds of the unlock)

- Public submission is limited to **exactly these two Forms**.
- The flow is **create-only into `CRM - New Signals`** — no deletes, no updates
  to other records, no mail sends, no auto-reply, no external sharing, no guest
  invites, no permission/consent changes.
- Standard connectors only; no Dynamics/Dataverse/premium.
- All auto-captured items enter `SignalStatus = New` for **human triage**; there
  is no automated outreach, scoring action, or downstream automation.
- Spam posture: rely on human triage of the New queue; do not auto-act on any
  submission. Revisit throttling/validation only if abuse appears.
- The blocked technical fields stay hidden — Path B writes to them from the flow
  but never surfaces them on the daily form. The Chunk 3 verifier still FAILs on
  any blocked field showing `DefaultTrue`/`True`.

## How Path B reaches the operator

No change to the daily operator path. Auto-captured signals appear in the
existing **New Signal Queue** view alongside manual captures, now with a **Source**
column showing the brand. Triage is identical; the operator simply sees where the
signal came from. The legacy `Guided AI Labs - Intake Register` remains admin-only
and is NOT involved.

## Build order (gated session)

1. Confirm `IntakeSource` exists on `CRM - New Signals` (created by the Chunk 5
   apply — it is now in `config/crm.sharepoint.json`).
2. Create the two Forms (anonymous submit) with the content above.
3. Build the flow(s) with the mapping above; keep create-only.
4. End-to-end test: submit one dummy response per brand prefixed
   `GAIL-INTERNAL-WALKTHROUGH`; confirm a clean New Signal appears with the right
   `Source`, the provenance lands in hidden fields, and nothing technical shows on
   the form. (Deferred-log V7/V8.)
5. Re-run the Chunk 3 verifier (V2) — it must still PASS (no blocked field
   became visible).

## What stays a separate, future decision

- Whether to ever auto-reply to submitters (currently NO — that is a mail send).
- Whether to read approved mailbox folders into CRM (still the open automation
  decision in `docs/CRM_DECISIONS.md`; Path B does not settle it).
- Premium Power Platform, Dataverse, or Dynamics (still out of scope).
