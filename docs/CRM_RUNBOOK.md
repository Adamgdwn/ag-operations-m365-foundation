# CRM Runbook

Date: 2026-06-18

Status: Active employee operating runbook draft.

## Who This Is For

This is for a Guided AI Labs employee, operator, or trusted partner who has been
given a Microsoft 365 account and role-appropriate access to the Guided AI Labs
workspace.

Some trusted partners may be granted full CRM and delivery operating access.
That is still an assigned operating role, not automatic tenant/global admin
authority.

The goal is simple: open the CRM, capture and work real signals, and leave clear
records behind.

## First-Day Setup And Access

Do this once, before your first Start Of Day.

Access you should already have been granted (Adam decides the exact grant; see
`docs/WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md`, "CRM / Relationships" row):

- Employee / operator doing assigned CRM work: access level **A2** (read and
  update CRM records, queues, and links for assigned work).
- Trusted partner / operator with deliberate broad CRM access: access level
  **A3** (full CRM and related delivery operating access).
- Either way this is an operating role, not tenant/global admin authority. The
  admin-only actions in that model stay with Adam.

Set up your access:

1. Sign in to Microsoft 365 with your Guided AI Labs account and complete MFA.
2. Open the Login Guide if you need account help:
   `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Login-And-Account-Guide.aspx`
3. Open the workspace and confirm you can reach the Operations Cockpit:
   `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
4. Open the CRM Command Center and bookmark it:
   `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx`
5. Optional but recommended: add the CRM Command Center as a tab in your Guided
   AI Labs Team so it is one click from Teams.
6. Confirm you can see the daily cards (Triage Queue, Follow Up Today, Proposal /
   Decision Blockers, Active Delivery, Closeout / Invoice Watch). If a card is
   missing or you cannot open it, that is an access item to escalate, not
   something to work around.

If anything above is missing or broader than your assigned role, stop and use
the Escalate section before doing CRM work.

## Start Of Day

1. Sign in to Microsoft 365 with your Guided AI Labs account and MFA.
2. Open the Guided AI Labs Operations Cockpit.
3. Open the CRM Command Center.
4. Review:
   - Triage Queue;
   - Follow Up Today;
   - Proposal / Decision Blockers;
   - Active Delivery;
   - Closeout / Invoice Watch.

## Capture A New Signal

1. From the CRM Command Center, open New Signal.
2. Enter the signal summary, person, email, organization, type, priority, need,
   context, next action, follow-up date, and any related file/link.
3. Save the item.
4. Confirm it appears in the Triage Queue.
5. Once the `New Signal` Teams alert proof is live, confirm urgent new signals
   also appear in the internal `Guided AI Labs / New Signal` channel. CRM
   remains the source of truth; Teams is only the attention surface.

Do not use the old `Guided AI Labs - Intake Register/NewForm.aspx` route for
daily CRM work.

Current build note on 2026-06-24: the Teams alert lane is prepared but not yet
proven live. Until proof exists, use the Triage Queue as the reliable check.

## Triage

For each new signal, decide:

- qualify now;
- follow up later;
- nurture;
- close as not a fit;
- escalate to Adam.

Update status, next action, owner, and due date before leaving the record.

## Qualification And Proposal

Use qualification, meeting notes, action queue, artifacts, and engagement
records to answer:

- what does the person or organization need?
- is there a real fit?
- what is the next promised action?
- what proposal, scope, or decision file matters?
- who owns the next step?

## Delivery And Closeout

When work is accepted or active:

1. Keep delivery actions visible in the CRM queues.
2. Link evidence, scope, handoff, and final files in SharePoint or OneDrive.
3. Use `CRM - Closeout Invoice Queue` for final evidence, invoice handoff,
   payment follow-up, and closure.

## Escalate

Escalate to Adam when:

- access is missing or broader permissions seem necessary;
- a client commitment is unclear;
- invoice or payment status is unclear;
- data appears duplicated or wrong;
- the next step would require external sharing, guest access, app consent,
  public forms, deletes, production mail automation, Dynamics, Dataverse, or
  premium Power Platform features.
- a Teams alert is missing, duplicated, or appears to notify anyone outside the
  internal `New Signal` channel.

## End Of Day

Before leaving the CRM:

- all new signals have a status;
- urgent follow-ups have owners and due dates;
- proposal/decision blockers are visible;
- delivery handoffs have file links;
- invoice/closeout items are not buried in notes.
