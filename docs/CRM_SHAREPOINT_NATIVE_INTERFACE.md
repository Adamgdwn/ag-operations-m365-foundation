# CRM SharePoint-Native Interface

Date: 2026-06-17

This is the no-purchase CRM interface target. It uses only SharePoint pages, SharePoint lists/views, and OneDrive/SharePoint document links.

## Front Door

```text
Operations Cockpit
-> CRM Command Center
-> New Signal
-> CRM - New Signals
```

The old technical `Guided AI Labs - Intake Register` is not the daily CRM front door.

## Daily Cards

- New Signal: open the clean business intake form for a new opportunity, referral, support signal, discovery start, or pasted email/context.
- QUO Intake: open the `CRM - New Signals` queue filtered to `IntakeSource = QUO` for consented phone, voice, text, and Sona follow-up inquiry records.
- Triage Queue: review new signals and decide whether they need qualification, nurture, follow-up, or closure.
- Follow Up Today: work dated follow-ups from the clean signal list.
- Proposal / Decision Blockers: clear scope, proposal, decision, or go-live blockers.
- Active Delivery: monitor delivery control and blocked execution.
- Closeout / Invoice Watch: track accepted work, final evidence, invoice handoff, and payment follow-up.

## Business Flow

1. Capture: `CRM - New Signals`
2. Qualify: `CRM - Qualification`
3. Discover and propose: `CRM - Meeting Notes`, `CRM - Action Queue`, and `CRM - Artifacts`
4. Win/loss decision: `CRM - Engagements` and blocker views
5. Delivery handoff: `CRM - Engagements`, `CRM - Artifacts`, and delivery actions
6. Closeout and invoicing: `CRM - Closeout Invoice Queue`

## Clean Intake Fields

The first intake form asks only for business information:

- Signal summary
- Person
- Email
- Organization
- Signal type
- Priority
- Need / opportunity
- Email or context paste
- Next action
- Follow-up date
- Related file/link
- Status
- Owner

It does not ask for source mailbox, source message ID, Graph node ID, Planner task URL, Central OS link, agent confidence, or other automation/audit fields.

## Source-Specific Intake Views

QUO should enter the CRM through the same clean intake list, not through a
separate phone app surface:

```text
Operations Cockpit
-> CRM Command Center
-> QUO Intake
-> CRM - New Signals filtered where IntakeSource = QUO
```

The QUO Intake view should show sanitized consented intake records created or
matched by the future approved QUO ingress path. Message-only calls should stay
in QUO's in-app message handling and should not appear here. This view should
not expose raw call transcripts, full SMS bodies, QUO secrets, webhook
configuration, or direct outbound action controls.

Recommended columns: Title, Priority, SignalType, PersonName, OrganizationName,
NeedSummary, NextAction, Follow-up date, RelatedLink, Owner, and SignalStatus.

## File Handling

Use normal OneDrive/SharePoint links for:

- pasted or saved email context
- proposals
- scopes
- evidence
- final handoff material
- invoice files

The CRM stores the link and status; it does not try to become the accounting system.
