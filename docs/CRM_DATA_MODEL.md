# CRM Data Model

Date: 2026-06-18

Status: Active recovery data target.

## Primary Lists

| List | Responsibility |
|---|---|
| `CRM - New Signals` | Clean business intake and triage entry. |
| `CRM - Qualification` | Qualification notes, fit, next decision, and pursuit status. |
| `CRM - Action Queue` | Follow-ups, blockers, owner, due date, and completion state. |
| `CRM - Meeting Notes` | Discovery, proposal, decision, and delivery meeting notes. |
| `CRM - Artifacts` | Links to proposals, scopes, evidence, handoff files, and supporting material. |
| `CRM - Health Reviews` | Relationship health, expansion/risk signals, and periodic review notes. |
| `CRM - Closeout Invoice Queue` | Final evidence, invoice handoff, payment follow-up, and closeout status. |
| `CRM - Organizations` | Durable organization records. |
| `CRM - Contacts` | Durable person/stakeholder records. |
| `CRM - Engagements` | Opportunity, delivery, and lifecycle tracking. |

## Intake Fields

`CRM - New Signals` is allowed to use the native SharePoint form because it
contains only clean business fields:

- `Title`
- `PersonName`
- `PersonEmail`
- `OrganizationName`
- `SignalType`
- `SignalStatus`
- `Priority`
- `NeedSummary`
- `SourceText`
- `NextAction`
- `FollowUpDueDate`
- `RelatedLink`

## Metadata Boundary

Automation, graph, mailbox, Planner, and legacy intake metadata may exist in
older lists or future integration layers. Those fields do not belong in the
daily employee intake path.

## File Links

The CRM stores links to OneDrive/SharePoint files. It does not become the file
system, proposal generator, accounting system, or invoice ledger.
