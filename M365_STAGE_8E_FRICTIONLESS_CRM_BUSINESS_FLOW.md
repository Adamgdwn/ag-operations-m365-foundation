# Microsoft 365 Stage 8E - Frictionless CRM Business Flow

> Superseded for active CRM UX direction.
>
> The active UX target is now `docs/CRM_UX_SPEC.md`, with completion gates in
> `docs/CRM_ACCEPTANCE_TESTS.md`. Keep this file as historical/provenance until
> archived.

Status: **design baseline after Stage 8D browser friction finding** (2026-06-17).

Stage 8E reframes the CRM around a business-development operator, not a
SharePoint administrator. The seller should never start by filling technical
capture metadata such as source mailbox, source message id, graph ids, planner
links, or automation confidence. Those fields may exist for later automation and
audit, but they belong behind the curtain.

Research baseline:

- Microsoft Dynamics 365 describes sales as a repeatable path from lead through
  opportunity close and recorded sale.
- Microsoft Dynamics sales entities include lead, opportunity, quote, order, and
  invoice as distinct business records.
- Salesforce frames pipeline management as tracking defined activities at each
  stage and keeping customer data tidy.
- HubSpot's B2B sales pipeline guidance emphasizes lead capture, qualification,
  accepted/sales-qualified work, closed deal, and post-sale handoff.

Sources:

- https://learn.microsoft.com/en-us/dynamics365/sales/nurture-sales-from-lead-order-sales
- https://learn.microsoft.com/en-us/dynamics365/sales/developer/sales-entities-lead-opportunity-competitor-quote-order-invoice
- https://www.salesforce.com/sales/pipeline/management/
- https://blog.hubspot.com/sales/sales-pipeline-stages-visual-guide

---

## 1. Operator Principle

The CRM should ask the business-development person only:

```text
Who is this?
What do they want?
Is this worth pursuing?
What is the next step?
What are we selling?
Has it been accepted?
What must delivery know?
Has the work been closed and invoiced?
```

Everything else is system metadata.

---

## 2. End-To-End Flow

```text
Capture -> Qualify -> Discovery -> Proposal -> Won / Lost -> Delivery Handoff -> Closeout -> Invoice
```

### Capture

Purpose: get the signal out of someone's head or inbox.

Minimum fields:

- Intake summary
- Person name
- Email
- Organization
- Paste email / notes
- Signal type
- Priority
- Best next step

Email handling:

- Preferred manual path: drag/upload the email or paste the useful body text.
- Future automation path: monitor approved mailbox folders and extract sender,
  subject, received date, and message id automatically.
- The human does not type source mailbox or source message id.

Current surface:

- `Guided AI Labs - Intake Register`

### Qualify

Purpose: decide whether to pursue, nurture, reject, or convert.

Minimum fields:

- Fit: low / medium / high
- Urgency: low / medium / high / immediate
- Need summary
- Budget signal: clear / unclear / no
- Decision role: decision maker / influencer / unknown
- Recommended offer
- Qualification status
- Next action

Current surface:

- `CRM - Qualification`

### Discovery

Purpose: understand the real problem before proposing.

Minimum fields:

- Discovery date
- Business problem
- Desired outcome
- Current workflow or pain
- Decision process
- Timeline
- Risks or blockers
- Follow-up commitment

Current surfaces:

- `CRM - Meeting Notes`
- `CRM - Touchpoints`

### Proposal

Purpose: turn qualified need into a simple commercial offer.

Minimum fields:

- Offer / package
- Scope summary
- Price estimate
- Proposal status
- Proposal link
- Decision due date
- Next action

Current surfaces:

- `CRM - Engagements`
- `CRM - Artifacts`
- `CRM - Action Queue`

### Won / Lost

Purpose: make the decision explicit.

Minimum fields:

- Outcome: won / lost / no decision / nurture
- Reason
- Accepted scope link
- Start date
- Handoff owner
- Invoice needed: yes / no

Current surfaces:

- `CRM - Engagements`
- `Decision Register` only when there is a real governance, scope, access, or
  commercial decision to preserve.

### Delivery Handoff

Purpose: make sure delivery does not have to rediscover what sales already
learned.

Minimum fields:

- Customer priorities
- Promised outcomes
- Sensitive context
- Milestone dates
- Required artifacts
- Open risks
- Owner

Current surfaces:

- `CRM - Lifecycle Checklist`
- `CRM - Artifacts`
- Client handoff packet surfaces

### Closeout

Purpose: close the delivery loop and preserve evidence.

Minimum fields:

- Closeout status
- Delivered outcomes
- Evidence link
- Follow-up / support need
- Testimonial or case-study candidate
- Renewal / expansion signal

Current surfaces:

- `CRM - Artifacts`
- `CRM - Health Reviews`
- Handoff packet surfaces

### Invoice

Purpose: make revenue follow the accepted work without turning CRM into an
accounting system.

Minimum fields:

- Invoice status: not needed / draft / sent / paid / overdue / written off
- Invoice date
- Due date
- Amount
- Invoice link or accounting-system reference
- Payment status
- Follow-up owner

Recommended next surface:

- `CRM - Commercial Register` or `CRM - Invoice Tracker`

This should be a lightweight tracker and pointer, not the official accounting
ledger. Real invoices should remain in the chosen accounting/payment system.

---

## 3. What The Intake Form Should Look Like

First screen:

```text
Intake summary
Person name
Email
Organization
Signal type
Priority
Paste email / notes
Best next step
Needs Adam review
Attachments
```

Hidden from first screen:

```text
SourceMailbox
SourceMessageId
ReceivedDate
IntakeStatus
ItemOwner
DurableHome
PlannerTaskUrl
CentralOSLink
GraphNodeId
AgentConfidence
```

Those fields are retained only for automation, evidence, routing, or future
read-back.

---

## 4. Build Rules

- One first action per stage.
- No technical metadata on first-entry forms.
- Every stage has an owner and a next action.
- Every proposal has a scope or artifact link.
- Every won deal has a handoff checklist.
- Every closed delivery has evidence.
- Every invoice has a link/reference to the official accounting system.
- Public/client-facing forms and mailbox automation remain approval-gated.

---

## 5. Immediate Stage 8D Finding

The live intake form exposed source mailbox and source message id to the browser
operator. That is a failed business-development experience. The Stage 8C intake
formatter and field requirements were corrected on 2026-06-17 so system/source
fields are non-blocking and absent from the first-pass formatter.

Evidence:

```text
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-20260617-145712.log
inventory/stage-8c-relationship-crm-operator-workflow/stage-8c-crm-operator-workflow-verify-20260617-150340.log
inventory/stage-8c-relationship-crm-operator-workflow/STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md
```
