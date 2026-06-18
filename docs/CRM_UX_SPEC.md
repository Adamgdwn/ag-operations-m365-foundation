# CRM UX Spec

Date: 2026-06-18

Status: Active recovery UX target. Supersedes the operator-facing guidance in
`M365_STAGE_8E_FRICTIONLESS_CRM_BUSINESS_FLOW.md`.

## Operator Principle

The CRM is for a business-development and delivery operator, not a SharePoint
administrator. The first screen should ask:

```text
Who is this?
What do they need?
Is this worth pursuing?
What is the next action?
What evidence or handoff file matters?
Has it been closed and invoiced?
```

Implementation metadata belongs behind the curtain.

## Daily Entry

```text
Operations Cockpit -> CRM Command Center
```

The CRM Command Center is the daily door. It should show recognizable work
queues and action cards, not a build packet, raw list catalog, or implementation
map.

## Cards

- New Signal: capture a referral, opportunity, support signal, discovery start,
  or pasted email/context.
- Triage Queue: decide whether a signal needs qualification, nurture, follow-up,
  closure, or Adam review.
- Follow Up Today: work dated follow-ups.
- Proposal / Decision Blockers: clear scope, approval, decision, or go-live
  blockers.
- Active Delivery: monitor delivery control and blocked execution.
- Closeout / Invoice Watch: track final evidence, invoice handoff, payment
  follow-up, and closure.

## Intake Form

The clean intake surface is `CRM - New Signals`.

Human-facing fields:

- signal summary;
- person name;
- email;
- organization;
- signal type;
- priority;
- need or opportunity;
- pasted email/context;
- next action;
- follow-up date;
- related file/link;
- status;
- owner.

Fields that must not appear in the daily intake path:

- `SourceMailbox`
- `SourceMessageId`
- `ReceivedDate`
- `IntakeStatus`
- `ItemOwner`
- `DurableHome`
- `PlannerTaskUrl`
- `CentralOSLink`
- `GraphNodeId`
- `AgentConfidence`

## Employee Experience Standard

A new employee should be able to use the CRM with the runbook and live links
alone. If the employee must ask which Stage 8 script, config, or packet applies,
the docs are not yet clean enough.
