# Bookings — native "Calendly" scheduling for Guided AI Labs (wired to the CRM backbone)

**Status (2026-06-21):** Public booking page **LIVE + verified**. Website CTA handoff **sent**.
Bookings→CRM flow **DEPLOYED (Started) + END-TO-END VERIFIED** — full website→Bookings→CRM loop
is live and proven; 0 residue after teardown. **No human steps remain.**

This is the booking sibling of the Path B intake form (see
[CRM_PUBLIC_INTAKE_PATH_B.md](CRM_PUBLIC_INTAKE_PATH_B.md)). Both are public front-doors on
`guidedailabs.com` that feed the same `CRM - New Signals` list and the Operations Follow-up
backbone. Approved plan: `C:\Users\adamg\.claude\plans\misty-wiggling-gem.md`.

## What is live

| Item | Value |
|---|---|
| Public booking page | **https://outlook.office365.com/book/GuidedAILabs1@agoperations.ca/** (resolves to `https://bookings.cloud.microsoft/book/GuidedAILabs1@agoperations.ca/`) |
| Business display name | Guided AI Labs |
| Business SMTP (connector id / Graph id) | `GuidedAILabs1@agoperations.ca` |
| Access | **`unrestricted`** — anyone can book, verified anonymously (no sign-in wall) |
| Services | **Intro call (30 min)**, **Working session (60 min)** — both online (auto Teams link), staff-assigned |
| Custom questions | Organization (optional), "What would you like to cover?" |
| Availability | Mon–Fri 09:00–17:00, 30-min slots, 24h min lead, staff-selection ON |
| Staff | Adam Goodwin = Administrator (Outlook free/busy honoured) |
| Currency / website | CAD / https://guidedailabs.com |
| Published | yes |

Anonymous render verified: `.local/bookings-builder/capture/public-page-anon.png` (shows both
services, live availability calendar, attendee form, Book button).

## How it was built (and the Graph block)

The modern Microsoft Bookings admin (bookings.cloud.microsoft) would not create/list shared
pages cleanly, and **Microsoft Graph's Bookings _list_ endpoint is 403-blocked tenant-wide**
(`/solutions/bookingBusinesses` → 403 UnknownError, despite license `MICROSOFTBOOKINGS:Success`,
scope `Bookings.ReadWrite.All`, and org Bookings enabled — a Phase-1 hardening artifact). The
working path discovered:

1. **Create** the shared page through the web wizard in the signed-in Edge profile
   (`scripts/bookings/create-wizard-run.js`). The modern homepage does **not** display shared
   pages (cosmetic bug), so it looks like nothing was created — but the mailbox provisions.
2. **Configure** everything via **Graph by DIRECT business-id** — `GET/PATCH/POST/DELETE
   /solutions/bookingBusinesses/{SMTP}` all work (200/204) even though _list_ 403s
   (`scripts/bookings/build-bookings-config.js`). Auth = silent delegated token through the
   profile (`login_hint`, no device code). This set services, questions, staff, currency,
   website, and flipped `bookingPageSettings.accessControl` to `unrestricted`.

Key scripts under `scripts/bookings/`: `create-wizard-run.js` (create), `build-bookings-config.js`
(configure + make public), `finalize-bookings.js` (neutralize duplicate + anon verify),
`verify-and-capture.js` (substrate mailbox enumerate), `build-bookings-business.js` (Graph
probe/builder, `--probe`).

### Known caveat — duplicate `GuidedAILabs2`
Diagnosing the homepage-listing bug created the page twice. Business-level **DELETE is also
403-blocked**, so the duplicate `GuidedAILabs2@agoperations.ca` was **renamed "Guided AI Labs
(duplicate – safe to delete)" and unpublished** (inert, org-only). Delete it from the Bookings UI
whenever it becomes listable, or retry `DELETE /solutions/bookingBusinesses/GuidedAILabs2@agoperations.ca`
if the tenant block lifts.

## CRM tie-in flow (create-only) — `scripts/flow-builder/create-booking-flow.js`

Standard connectors only; create-only; no deletes/updates/mail. The appointment payload is IN the
trigger output (no Get-details step, unlike the Forms flow).

```
Microsoft Bookings "When an appointment is Created"  (shared_microsoftbookings, STANDARD)
   trigger: operationId CreateAppointment, SMTPAddress = GuidedAILabs1@agoperations.ca
   │   (AppointmentData: CustomerName, CustomerEmail, CustomerNotes, CustomerPhone, ServiceName,
   │    StartTime, EndTime, Duration, JoinWebURL, StaffMembers[]{DisplayName,EmailAddress},
   │    CustomQuestionAnswers[]{Question,Answer}, SelfServiceAppointmentId)
   ▼
SharePoint Create item in "CRM - New Signals"  (shared_sharepointonline, create-only)
   Title          = "Guided AI Labs — booking — {CustomerName|Email}"
   PersonName     = CustomerName        PersonEmail = CustomerEmail
   NeedSummary    = CustomerNotes        NextAction  = "Prepare for booked call"
   FollowUpDueDate= StartTime           (drives the reminder engine)
   ItemOwner      = StaffMembers[0].EmailAddress  (booked-with person → signal owner)
   SignalType     = "Website"           IntakeSource   = "Guided AI Labs"
   SignalStatus   = "Follow-up scheduled"  Priority    = "Normal"
   SourceText     = labelled dump (service, times, duration, Teams link, phone, notes,
                    custom answers raw) + provenance footer
```

**No duplicate calendar event:** the Bookings appointment already creates the Outlook event +
Teams link, so the CRM record leaves `op_TrackOn` calendar **OFF** (empty). v1 is **create-only**
— reschedule/cancel reflection (Update/Cancel triggers editing an existing record) is the fenced
"auto-edit" class and is deferred.

**Staff-selection / future employees:** the page has staff-selection ON; adding an employee later
= add one `bookingStaffMember` + assign to services. The flow captures the chosen staff into
`ItemOwner`, so the existing per-owner mailbox-delegation backbone routes that owner's
reminders/calendar automatically.

### Deploy: DONE (2026-06-21) — warm-Edge / CDP recipe
The flow is **deployed and Started** (`createdStatus 201`, flow id
`1c0ba5b5-8162-4841-bad9-17b27cbc1825`; connections SharePoint `4c53f079…` + Bookings `3a88fb3c…`;
`inventory/forms-build/flow-result-booking.json`). The earlier blocker — flaky Power Automate
token capture, where the PA SPA serves cached data on a *cold* launch and doesn't reliably
re-issue the connectivity-API token — was solved by **Adam's warm-instance idea**:

1. **`scripts/flow-builder/warm-edge` recipe:** launch msedge **headed** with
   `--remote-debugging-port=9222 --user-data-dir=<.local/forms-builder/profile>` and navigate it
   to Power Automate; **keep it open**. A real, warm, signed-in browser actually issues the
   bearer tokens.
2. **`create-booking-flow.js` connects over CDP** (`chromium.connectOverCDP('http://127.0.0.1:9222')`,
   gated by `CDP_PORT`, default 9222) and drives the warm pages. It captured both the EHOST
   connectivity token and the `api.flow.microsoft.com` token on the **first try**, resolved the
   connections + list GUID, and POSTed the flow. On exit it **detaches** (never closes the warm
   Edge), so the instance stays reusable. Falls back to a cold *headed* launch if CDP is absent.

This warm-Edge/CDP pattern is the reusable fix for ALL Power Automate token-capture work going
forward (supersedes the flaky headless cold-launch).

Connector facts (reverse-engineered, `.local/flow-builder/capture/bookings-operations.json`):
trigger `CreateAppointment` (param `SMTPAddress`); only a Bookings **admin** can create
appointment-trigger flows (Adam is); max 5 flows/mailbox (we use 1). Connector is **STANDARD**
(no premium cost).

## Verification — DONE (Phase 4, 2026-06-21): ALL CHECKS PASS, 0 residue
End-to-end run via `scripts/bookings/verify-booking-e2e.js` (over the warm Edge / CDP). It created
a real appointment on the live page with customer name **`GAIL-INTERNAL-WALKTHROUGH`** (same
"appointment created" trigger a public visitor fires), and the flow produced a clean
`CRM - New Signals` record (item Id 10) **within ~9 seconds**. Validated:

- PersonName = `GAIL-INTERNAL-WALKTHROUGH`, PersonEmail captured
- IntakeSource = **Guided AI Labs**, SignalType = **Website**, SignalStatus = **Follow-up scheduled**, Priority = **Normal**
- NextAction = "Prepare for booked call"; **FollowUpDueDate = StartTime** (`2026-06-24T16:30`)
- SourceText carries the service name, **Teams JoinWebURL**, custom answers, and the provenance footer
- ItemOwner = **Adam Goodwin** (StaffMembers[0] → owner; backbone routing intact)

Teardown via `scripts/bookings/teardown-booking-e2e.js` (also over CDP): **cancelled the
appointment** (Graph `204` — Outlook event + Teams meeting removed) and **scope-deleted the CRM
record** (PersonName-scoped) → **0 residue** confirmed. A confirmation email + a cancellation email
were sent to Adam's own inbox (transactional, by design); visual eyeball of those is the only
thing left for Adam, and it's optional. Result: `inventory/forms-build/booking-e2e-result.json`.

Scripts: `scripts/bookings/verify-booking-e2e.js` (create appt + poll + validate),
`scripts/bookings/teardown-booking-e2e.js` (cancel + scope-delete). Both are CDP-aware
(`CDP_PORT`, default 9222). The CRM-side scope filter is identical to
`scripts/flow-builder/delete-test-records.js` (`PersonName == GAIL-INTERNAL-WALKTHROUGH`), so it
can never touch a real signal. Refine `op_Reminders` later only if the backbone needs explicit
offsets.

## Governance — scoped unlocks logged (this build)
1. **Public self-service booking page** — `accessControl = unrestricted`, scoped to the named GAIL
   page only; read-only to the world (visitors can only request a slot). Reversible by unpublish.
2. **Outbound transactional email to external bookers** — native Bookings confirmation/reminder/
   cancellation emails only; no marketing, no list, SMS OFF. Approved by Adam this session.
3. **Bookings connector consent** — one standard-connector connection (created silently in Adam's
   signed-in profile; identical class to the SharePoint/Forms/Outlook connections).
4. **Bookings reads Adam's own calendar free/busy** — within his own mailbox; no delegation, no
   Graph app.

Still fenced: no Graph **app** registration (delegated tokens only), no premium connector, no
Dataverse, no payments, no SMS, no auto-outreach/marketing, no auto-edit/auto-close of CRM
business fields (flow is create-only).
