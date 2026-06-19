# Operating Card Plan Index

Date: 2026-06-19

Status: Chunk 3 card-plan standard and placeholder map.

This index tracks the operating-card deep dives. The current cockpit has four
visible top cards, but the target workspace has ten operating-card areas. Use
`docs/CARD_PLAN_TEMPLATE.md` for each future card plan.

## Card Plan Standard

A card plan is complete only when it defines:

- purpose and operator promise;
- primary workflow and common scenarios;
- pages, lists, libraries, queues, links, and superseded surfaces;
- owner, backup owner, review cadence, and evidence location;
- employee/operator access, trusted partner/operator access, and admin-only
  authority;
- data model, required views, and data quality rules;
- runbook, acceptance test, agentic opportunities, and stop conditions.

## Current Plan Map

| Operating card | Current live surface | Plan file | Status | Next action |
|---|---|---|---|---|
| Workspace Home | Operations Cockpit homepage, Start Here nav, Login Guide | TBD | Placeholder | Define card chooser standard and first-day orientation during Chunk 5 or final walkthrough. |
| CRM / Relationships | CRM card, CRM Command Center, Open CRM Actions, Qualification Triage | `docs/CARD_PLAN_CRM_RELATIONSHIPS.md` | Active applied example | Continue functional recovery through `docs/CRM_EXECUTION_PLAN.md` when CRM is selected. |
| Delivery / Projects | Projects In Flight card, Active Delivery, Delivery Control, Lifecycle Checklist, Handoff Packets | TBD | Placeholder | Create Delivery / Projects plan from the template. |
| Decisions / Governance | Operations card signals, Decisions page, Decision Register, App Grants, Exception Register | TBD | Placeholder | Define approval workflow and separate operator access from governance/admin authority. |
| Tasks / Actions | Operations card signals, CRM Action Queue, Planner/List task surfaces | TBD | Placeholder | Decide source of truth for non-CRM tasks and daily work queues. |
| Knowledge / Records | Published Methods, Readiness Evidence, Restricted Build Evidence, Archive, Methods and IP nav | TBD | Placeholder | Define record locations, search/use rules, permissions, and archive posture. |
| Support / Intake | Operations card, Intake page, Guided AI Labs Intake Register, Change Leadership Tools Support Register | TBD | Placeholder | Separate support/intake routing from clean CRM New Signal routing. |
| Finance / Closeout | Projects In Flight, Handoff Packets, CRM Closeout Invoice Queue | TBD | Placeholder | Define closeout evidence, invoice handoff, payment follow-up, and blocked-payment escalation. |
| Agent Control Plane | Tools card, Agent Action Log, Automation Backlog, Tool Permission Review, Agent Setup, App Grants | TBD | Placeholder with active readiness map | Use `docs/AGENTIC_M365_READINESS.md` before any AI/agent expansion. |
| Access / Onboarding | Login Guide, Access Model, External Sharing Rules, App Grants | TBD | Placeholder | Build the role access matrix in Chunk 4. |

## Placeholder Notes

### Workspace Home

Known surfaces:

- Operations Cockpit homepage
- Start Here / Operations Portal navigation
- Login Guide

First plan question:

- Can a new person choose the right card for common work without reading build
  history?

### Delivery / Projects

Known surfaces:

- Projects In Flight card
- Active Delivery page
- Delivery Control
- Lifecycle Checklist
- Client Handoff Packets
- Client Discovery

First plan question:

- What is the exact workflow from assigned work to evidence, handoff, and
  closeout?

### Decisions / Governance

Known surfaces:

- Decision Register
- Exception Register
- App Grants
- External Sharing Rules
- Tool Permission Review

First plan question:

- Which decisions can an operator record, and which require Adam or admin
  authority?

### Tasks / Actions

Known surfaces:

- Open CRM Actions
- Planner / Teams operating plan
- list-based task queues

First plan question:

- Where should a non-CRM daily task live so work is not split invisibly across
  Planner, Lists, Teams, and pages?

### Knowledge / Records

Known surfaces:

- Published Methods
- Delivery Working Documents
- Readiness Evidence
- Restricted Build Evidence
- Archive
- Methods and IP navigation

First plan question:

- Where should an operator look for official methods, evidence, reusable IP,
  and historical records?

### Support / Intake

Known surfaces:

- Operations card
- Intake page
- Guided AI Labs Intake Register
- Change Leadership Tools Support Register

First plan question:

- What enters support/intake versus CRM New Signal, and who triages each lane?

### Finance / Closeout

Known surfaces:

- Client Handoff Packets
- CRM Closeout Invoice Queue
- Lifecycle Checklist
- final evidence locations

First plan question:

- What must be true before a handoff is invoice-ready or closed?

### Agent Control Plane

Known surfaces:

- Tools card
- Agent Action Log
- Automation Backlog
- Tool Permission Review
- Agent Setup
- App Grants

First plan question:

- Which actions are read-only suggestions, which are drafts, and which are
  write-capable actions requiring explicit approval and rollback evidence?

### Access / Onboarding

Known surfaces:

- Login Guide
- Access Model
- External Sharing Rules
- App Grants

First plan question:

- What does full operating access mean for each role, and what authority stays
  admin-only?

## Chunk 3 Acceptance

Chunk 3 is complete when:

- the shared card template is explicit enough to copy for any operating card;
- CRM is documented as the first applied example;
- the remaining cards have placeholders and first plan questions;
- future card deep dives can start without reopening Stage 8 build packet docs.
