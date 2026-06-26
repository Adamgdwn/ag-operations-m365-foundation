# B6 Guided AI Journey Client Intake Source Packet

Date: 2026-06-25

Status: B6 source-expansion proof completed. The direct Guided AI Journey
Microsoft Form was submitted on 2026-06-25 at 18:18 MDT, the create-only flow
created `CRM - New Signals` item `#21`, verification passed, the
source-specific Teams alert proof passed, and Agent Action Log `#11` was
recorded as a G1 `Suggested` row after Adam's approval.

Purpose: prepare the first B6 source expansion after B5 by routing Guided AI
Journey client invites into the existing `CRM - New Signals` lane.

## Source Decision Draft

Use the existing Guided AI Journey Microsoft Form as the intake target when Adam
invites a client or prospect.

```text
Adam sends or surfaces Journey intake link
-> client submits Guided AI Journey Form
-> create-only Power Automate flow creates CRM - New Signals item
-> GAIL - New Signal Teams alert posts internally
-> M365 Interaction Agent reads/triages the signal
-> optional Agent Action Log Suggested row after approval
```

This is source ingress only. It does not authorize external replies, agent-sent
invites, CRM updates, Planner/calendar work, permission changes, or app
registration.

Selected first proof entry point:

- Direct Journey Microsoft Form link.

Recognized but not selected for the first B6 proof:

- Journey website CTA/embed pointing to the same Microsoft Form.
- Guided AI Journey custom branded website form under
  `inventory/forms-build/RELEASED__WINDOWS_TO_JOURNEY__custom-intake-form-spec.json`.
  That contract is present locally, but its endpoint URL and secret are not
  committed; if selected later, verification still has to prove the same
  `CRM - New Signals` shape.

## Existing Evidence

- Journey Form: `Guided AI Journey - Get started`.
- Journey flow: `GAIL - Guided AI Journey intake to CRM (create-only)`.
- Flow id/name: `2a2cd963-1469-48a5-95a5-04e696ff3543`.
- Flow state in local evidence: `Started`.
- Target list id: `a64ef810-ad45-407b-b1ea-516533a8611d`.
- Target list: `CRM - New Signals`.
- Source stamp: `IntakeSource = Guided AI Journey`.
- Evidence file: `inventory/forms-build/flow-result-journey.json`.
- Website handoff packet:
  `inventory/forms-build/STAGED__WINDOWS_TO_LINUX__journey-intake-form-url.json`.
- Custom website form contract, not selected for this first proof:
  `inventory/forms-build/RELEASED__WINDOWS_TO_JOURNEY__custom-intake-form-spec.json`.
- B6 proof helper:
  `scripts/Invoke-M365B6JourneyIntakeProof.ps1`.
- B6 visible verifier launcher:
  `scripts/Start-M365B6JourneyIntakeProofInteractive.ps1`.
- Local prep artifact:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-180736.md`
  and `.json`.
- Live Form submission evidence:
  `inventory/m365-interaction-agent-b6/b6-journey-form-submission-20260626-001841.json`.
- Live CRM verification evidence:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-182051.md`
  and `.json`.
- Live triage and G1 Suggested-row evidence:
  `inventory/new-signal-triage/new-signal-triage-20260625-182141.md` and
  `.json`.
- Live source-specific Teams alert evidence:
  `inventory/new-signal-alert/new-signal-alert-proof-20260625-184447.md` and
  `.json`.
- Teams web proof for CRM item `#21`:
  `inventory/new-signal-alert/new-signal-teams-web-proof-b6-21-20260626-004415.txt`
  and `.png`.
- Path B contract: `docs/CRM_PUBLIC_INTAKE_PATH_B.md`.

## Source Owner

- Business owner: Adam.
- Brand/source: Guided AI Journey.
- M365 owner surface: Guided AI Labs M365 environment.
- Agent lane: `M365 Interaction Agent`.

## Event Types

- Adam manually sends a client/prospect the Journey intake link.
- Adam links to the Journey intake from a client-invite message, proposal,
  onboarding note, or website CTA.
- A client/prospect submits the Guided AI Journey Form.

Out of scope:

- Agent automatically sending the invite.
- Agent replying to the submitter.
- New website-to-CRM writer beyond the already released custom form contract.
- Browser-side tenant secret, Graph token, or CRM credential.

## Data Captured

Expected Form fields:

- Full name.
- Email.
- Organization.
- What are you looking for?
- How did you hear about us?
- Intent/path selection.
- Consent acknowledgement.

Expected CRM mapping:

- `Title`: starts with `Guided AI Journey` and includes the submitted
  name, organization, or email.
- `PersonName`: Form full name.
- `PersonEmail`: Form email.
- `OrganizationName`: Form organization.
- `NeedSummary`: Form need/opportunity text.
- `SourceText`: labelled raw submission and provenance.
- `SignalType`: `Website`.
- `IntakeSource`: `Guided AI Journey`.
- `IntentPath`: selected intent/path, if present.
- `SignalStatus`: `New`.
- `Priority`: `Normal`.

## Dedupe And Advisory Rules

- The flow does not dedupe or merge.
- All submissions land as `SignalStatus = New`.
- The agent triage packet may flag similar CRM records as advisory-only.
- Any merge, suppression, field update, or follow-up task remains blocked until
  a separate approval lane exists.

## Expected Latency

- Microsoft Forms submission to CRM item: normally near-immediate through Power
  Automate.
- CRM item to Teams alert: SharePoint-created-item trigger polls on the standard
  connector cadence, usually within a few minutes.
- No SLA is assumed.

## Privacy And Security Notes

- Collect only non-sensitive intake details.
- No file uploads in this source path.
- No external auto-reply.
- No tenant secret in browser/client code.
- No premium connector, Dataverse, Dynamics, HTTP trigger, or custom public
  write endpoint unless Adam explicitly selects the already released custom
  website form contract for a later proof.
- Use account/profile separation while Prime Boiler 365 setup is active.

## Stop Conditions

- New direct website-to-CRM POST route outside the released contract.
- Tenant secret or Graph token in browser/client code or a public repo.
- Agent-sent client invite.
- Auto-reply to submitter.
- CRM updates beyond the one created signal item.
- Guest invite, external sharing, app registration, consent grant, or permission
  change.
- Any source that bypasses `CRM - New Signals`.

## Rollback Or Disable Path

- Stop sending the Journey intake link.
- Remove or hide the Journey website CTA/embed.
- Turn off `GAIL - Guided AI Journey intake to CRM (create-only)` in Power
  Automate after Adam approval.
- Turn off `GAIL - New Signal Teams alert` only if Adam wants to stop internal
  alerting for all new CRM signals.
- Reject or supersede any `Agent Action Log` suggestion generated from the test.

## Proof Result

Completed first proof:

1. Submitted the direct Journey Form link with dummy client-invite values:
   `GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY`.
2. Confirmed Microsoft Forms returned `Your response was submitted`.
3. Verified one `CRM - New Signals` item appeared with
   `IntakeSource = Guided AI Journey`: item `#21`.
4. Verified B6 shape checks passed for `IntakeSource`, `SignalType`,
   `SignalStatus`, `Priority`, marker, and `NeedSummary`.
5. Confirmed one internal Teams post appeared in
   `Guided AI Labs / New Signal` for CRM item `#21`, with CRM link text.
6. Ran `scripts/Invoke-M365NewSignalTriage.ps1` read-only against item `#21`.
7. After Adam's G1 approval, wrote one `Suggested` Agent Action Log row:
   item `#11`.

No B6 proof add-on remains for the selected direct Journey Form entry point.

Prepared local helper:

```powershell
# Local prep only; no Microsoft 365 connection.
.\scripts\Invoke-M365B6JourneyIntakeProof.ps1 -NoPause

# Read-only verification after Adam manually submits the dummy Journey intake.
.\scripts\Start-M365B6JourneyIntakeProofInteractive.ps1 -Verify -ForceFreshLogin

# Optional read-only verification plus B2/B3 triage packet after the item exists.
.\scripts\Start-M365B6JourneyIntakeProofInteractive.ps1 -Verify -RunTriage -ForceFreshLogin
```

Local prep completed on 2026-06-25:

- Marker: `GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY`.
- Email:
  `adam+gail-b6-journey-20260625-180736@guidedailabs.com`.
- Packet:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-180736.md`.
- Summary:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-180736.json`.
- Transcript:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-180736.log`.

Live proof completed on 2026-06-25:

- Microsoft Forms confirmation evidence:
  `inventory/m365-interaction-agent-b6/b6-journey-form-submission-20260626-001841.json`.
- CRM item: `#21`,
  `Guided AI Journey — GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY`.
- CRM created time: `2026-06-26T00:18:48.0000000Z`
  (`2026-06-25 18:18 MDT`).
- B6 verification packet:
  `inventory/m365-interaction-agent-b6/b6-journey-intake-proof-20260625-182051.md`.
- Read-only triage packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-182104.md`.
- Approved G1 Suggested-row packet:
  `inventory/new-signal-triage/new-signal-triage-20260625-182141.md`.
- Agent Action Log item: `#11`, status `Suggested`; not approved, completed,
  or executed.
- Source-specific Teams alert proof:
  `inventory/new-signal-alert/new-signal-alert-proof-20260625-184447.md`.
- Teams post observed: one `Guided AI Labs / New Signal` post at
  `2026-06-25 18:19 America/Edmonton`, with CRM link text.
- Teams web evidence:
  `inventory/new-signal-alert/new-signal-teams-web-proof-b6-21-20260626-004415.txt`
  and `.png`.

Approval phrase used by the local browser submitter for the live source proof:

```text
approve-b6-journey-client-intake-form-proof-20260625
```

Separate approval phrase proposal for future optional G1 action-log writes:

```text
approve-b6-journey-triage-suggested-row-20260625
```

The live G1 Suggested-row write for item `#21` was approved by Adam in-session
with "Ok, go ahead" after confirming that M365 permanence requires deliberate
writes.

## Selected Proof Entry Point

First proof entry point completed:

- Direct Journey Microsoft Form link.

Later proof options:

- Journey website CTA/embed.
- The actual client-invite message/link Adam intends to send.
- Guided AI Journey custom branded website form.
