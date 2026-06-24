# CRM Acceptance Tests

Date: 2026-06-18

Status: Active completion gates.

## Completion Rule

The CRM recovery is complete only when it is employee-ready. Script verification
and read-back evidence matter, but they do not replace a human browser pass.

## Employee Readiness Test

Given a capable employee, operator, or trusted partner with a Guided AI Labs
login and role-appropriate access, the person can:

1. sign in with MFA;
2. open the Operations Cockpit;
3. open the CRM Command Center;
4. create a New Signal in `CRM - New Signals`;
5. see the saved signal in Triage Queue;
6. assign or record next action, owner, status, and due date;
7. find proposal, evidence, handoff, and invoice/closeout places;
8. identify what must be escalated to Adam.

For a trusted partner role, "full access" includes full CRM and delivery
operating access for the assigned role. The test should still confirm that
tenant/global admin authority, break-glass access, billing, security settings,
app consent, and destructive actions are not granted unless separately intended.

## Browser Path Test

```text
Operations Cockpit
-> CRM Command Center
-> New Signal
-> CRM - New Signals
-> Triage Queue
```

Pass conditions:

- no daily card opens `Guided AI Labs - Intake Register/NewForm.aspx`;
- New Signal opens the clean CRM intake path;
- the CRM Command Center labels are business-facing;
- the next action after save is obvious.

## Hidden Field Test

The daily intake path must not show:

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

## Data Test

Pass conditions:

- saved signal lands in `CRM - New Signals`;
- the record has human intake fields plus normal SharePoint created/modified
  metadata;
- related files are links to SharePoint or OneDrive;
- no private mailbox or source-message metadata is required from the employee.

## Workflow Test

Walk one internal dummy record with prefix:

```text
GAIL-INTERNAL-WALKTHROUGH
```

Pass conditions:

- record starts in intake;
- record reaches triage;
- qualification or closure decision is recorded;
- next action is visible;
- delivery/handoff/evidence or closeout/invoice route is visible when relevant.

## Governance Test

Pass conditions:

- no permissions changed;
- no guests invited;
- no external sharing widened;
- no app consent granted;
- no mail sends or mailbox automation created;
- no public forms created;
- no deletes performed;
- no Dynamics, Dataverse, or premium Power Platform dependency introduced.

## Supersession Test

Pass conditions:

- active CRM docs live under `docs/`;
- old root Stage 8 CRM docs are marked superseded or provenance;
- a new operator can identify `START_HERE.md` as the active CRM start file.
