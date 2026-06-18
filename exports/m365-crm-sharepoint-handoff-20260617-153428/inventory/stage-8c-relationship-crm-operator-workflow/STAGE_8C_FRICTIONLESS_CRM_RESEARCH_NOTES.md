# Stage 8C Frictionless CRM Research Notes

Generated: 2026-06-17

## Sources Reviewed

- Nielsen Norman Group, "Progressive Disclosure": https://www.nngroup.com/articles/progressive-disclosure/
- Nielsen Norman Group, forms topic index: https://www.nngroup.com/topic/forms/
- U.S. Web Design System, "Progress easily": https://designsystem.digital.gov/patterns/complete-a-complex-form/progress-easily/
- Microsoft Learn, "Configure the list form": https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/list-form-configuration
- PnP Samples, "Apply custom Form Formatting": https://pnp.github.io/script-samples/spo-apply-custom-form-formatting-json/README.html
- Salesforce, "What are the Stages of a Sales Pipeline?": https://www.salesforce.com/ca/sales/pipeline/stages/

## Design Translation

The CRM front door should show a small set of high-frequency actions first:

- add a new intake signal;
- review the intake queue;
- qualify the next relationship;
- work open CRM actions.

The stage path should be visible without becoming the whole page:

```text
Intake -> Qualification -> Engagement Pipeline -> Decision / Proposal -> Active Delivery -> Handoff Evidence
```

The intake form should expose only the first human decisions:

```text
Quick intake: Intake summary, Person name, Email, Organization
Triage: Signal type, Priority, What should happen next?, Context / notes, Needs Adam review
```

Source mailbox, source message id, received date, owner, durable links, planner
links, graph ids, and agent confidence remain on the SharePoint record as
system/source metadata. They are not part of the first human intake task.

## Production Change Applied

The Stage 8C apply script now:

- refreshes `Relationship-CRM-Command-Center.aspx` into a compact action hub;
- adds an `Add intake signal` action that opens the intake new-item form;
- applies SharePoint list-form formatting to `Guided AI Labs - Intake Register`;
- updates field labels for the human-facing intake pass;
- relaxes source/system fields so they do not block manual intake;
- keeps source/system fields out of the first-pass business-development intake
  formatter.

Read-back verification passed on 2026-06-17 after the formatter was corrected to
use internal field names for form sections. The live read-back confirms human
intake fields are present in the formatter and source/system fields are absent
from the formatter and non-required.
