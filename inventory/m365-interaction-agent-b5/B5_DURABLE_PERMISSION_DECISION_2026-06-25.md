# B5 Durable Permission Decision Packet

Date: 2026-06-25

Status: recorded live in Microsoft 365 on 2026-06-25. Decision Register item
`#6` records the posture; Agent Action Log item `#10` records the evidence.

Purpose: convert the B5 competing-writer audit into a durable permission and
identity decision for the `M365 Interaction Agent`.

## Selected Posture Draft

Adopt one canonical agent lane for Guided AI Labs M365 operating decisions:

- Agent name: `M365 Interaction Agent`.
- Human owner: Adam.
- Account boundary: Guided AI Labs M365 work stays under
  `adamgoodwin@guidedailabs.com`; Prime Boiler 365 setup stays in its separate
  account/profile/session lane.
- Permission posture: supervised delegated and local-first.
- No new app registration, admin consent, SharePoint Selected grant, Exchange
  Application RBAC grant, broad Graph/Teams/Planner grant, or production bridge
  adapter is approved by B5.
- `agent-pnp-provisioning` remains a setup helper only, not production agent
  authority.

This draft keeps the agent useful at G0/G1 without granting new standing tenant
power.

## Purpose

The agent may:

- read approved Microsoft 365 operating records;
- triage new CRM signals;
- flag possible related CRM records;
- prepare reviewable next-action suggestions;
- write one `Agent Action Log` row with `ActionStatus = Suggested` only after
  a specific approval for that selected signal.

## Source-Ingress Exceptions

These source-ingress automations remain accepted business plumbing, not agent
decision writers:

- `GAIL - Guided AI Labs intake to CRM (create-only)`;
- `GAIL - Guided AI Journey intake to CRM (create-only)`;
- `GAIL - New Signal Teams alert`.

They may create a `CRM - New Signals` item or internal Teams alert according to
their existing create-only contracts. They do not approve agent action, CRM
updates, client outreach, permission changes, or downstream task creation.

## Exact Read Surfaces

Initial read surfaces:

- `CRM - New Signals`;
- `CRM - Organizations`;
- `CRM - Contacts`;
- `CRM - Engagements`;
- `CRM - Touchpoints`;
- `Agent Action Log`;
- `Decision Register`;
- local evidence under `inventory/new-signal-alert/`;
- local evidence under `inventory/new-signal-triage/`;
- local flow evidence under `inventory/forms-build/`.

## Exact Write Surfaces

Initial write surfaces after B5 approval:

- `Agent Action Log` only;
- one row per selected CRM signal;
- `ActionStatus = Suggested`;
- through `scripts/Invoke-M365NewSignalTriage.ps1 -Apply`;
- no duplicate suggestion unless `-AllowDuplicateSuggestion` is explicitly
  selected.

No CRM record, task, calendar item, Teams message, external message, permission,
app registration, guest invite, sharing link, flow, connector, or tenant policy
write is approved by this B5 decision.

## Blocked Actions

Blocked until a later explicit decision:

- CRM updates, merges, suppressions, lookup conversions, dedupe actions, or
  status changes;
- Planner task creation or update;
- calendar/reminder creation or update;
- external email, Teams chat, SMS, call, voicemail, QUO action, or client
  commitment;
- public website-to-CRM POST route or tenant secret in a website repo;
- app registration, consent grant, SharePoint Selected permission, Exchange
  Application RBAC, Graph/Teams/Planner scope grant, guest invite, sharing
  change, tenant policy change, or delete;
- unattended tenant-writing automation.

## Identity And Adapter Approach

Use the existing supervised delegated approach for now:

- PnP/SharePoint operations run under the expected Guided AI Labs user context,
  with the scripts checking for `adamgoodwin@guidedailabs.com`.
- Existing Power Automate flows keep their current standard connector posture.
- Local evidence is produced before any tenant write.
- The next live write must be specifically selected and approved.

Rejected for B5:

- production app identity;
- `agent-pnp-provisioning` as a production agent identity;
- broad setup grants as standing agent authority;
- fully unattended agent execution.

## Why Not Narrower Or Broader

G0-only is too narrow because B4 proved that one `Suggested` row creates a
useful review queue without updating CRM or contacting anyone.

G2/G3 or app-based authority is too broad because the first value proof is still
new. There is no need to grant durable app power, Selected permissions, or
mailbox/Teams/Planner permissions before more source proofs show real value.

The selected posture keeps the agent capable enough to help while leaving Adam
firmly in the approval path.

## Revoke Or Pause Path

- Stop running `scripts/Invoke-M365NewSignalTriage.ps1 -Apply`.
- Reject or supersede suggested Agent Action Log rows.
- Turn off `GAIL - New Signal Teams alert` in Power Automate if internal alerts
  should stop.
- Turn off either brand intake flow in Power Automate if source ingress should
  pause.
- Keep Prime Boiler setup signed into its own account/profile/session.
- Review or revoke setup-helper grants only under a separate governance action.

## Review Date

Revisit by 2026-07-09, or earlier if:

- B6 Guided AI Journey intake proof succeeds;
- the agent needs a new write surface;
- a production adapter/app identity is proposed;
- account/session bleed appears while switching Prime Boiler and Guided AI Labs.

## Decision Register Draft

Import-ready draft values:

- Markdown source:
  `inventory/m365-interaction-agent-b5/B5_DURABLE_PERMISSION_DECISION_2026-06-25.md`
- CSV:
  `inventory/m365-interaction-agent-b5/decision-register-draft-b5-one-writer-20260625.csv`
- JSON:
  `inventory/m365-interaction-agent-b5/decision-register-draft-b5-one-writer-20260625.json`

Approval phrase used for the approved live recording:

```text
approve-b5-record-one-writer-m365-interaction-agent-20260625
```

## Recording Helper

Prepared local script:

- `scripts/Invoke-M365B5InteractionAgentDecision.ps1`
- `scripts/Start-M365B5InteractionAgentDecisionInteractive.ps1`

Modes:

```powershell
# Local preview only; no Microsoft 365 connection.
.\scripts\Invoke-M365B5InteractionAgentDecision.ps1 -LocalOnly -NoPause

# Tenant dry run; reads/verifies target Lists and reports create/update intent.
.\scripts\Invoke-M365B5InteractionAgentDecision.ps1 -NoPause

# Live recording; writes Decision Register and Agent Action Log only.
.\scripts\Invoke-M365B5InteractionAgentDecision.ps1 -Apply -ApprovalPhrase "approve-b5-record-one-writer-m365-interaction-agent-20260625" -NoPause
```

The recorder fails before connecting if `-Apply` is used without the exact
approval phrase. It does not create or update CRM items, flows, Teams posts,
Planner tasks, mail, permissions, app registrations, guests, sharing settings,
or tenant policy.

Local preview completed on 2026-06-25:

- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-174036.json`
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-174036.log`

The preview proposed one Decision Register row and one Agent Action Log evidence
row. It made no Microsoft 365 connection and no tenant write.

Live recording completed on 2026-06-25:

- Connected site:
  `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
- Connected user:
  `adamgoodwin@guidedailabs.com`
- Decision Register item:
  `#6`, `B5 M365 Interaction Agent one-writer posture selected`
- Agent Action Log item:
  `#10`, `B5 one-writer posture recorded`
- Summary:
  `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-175449.json`
- Transcript:
  `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-175449.log`

## Next Build Step

Use B6 Guided AI Journey intake as the first source expansion:

```text
Journey Form or website CTA
-> CRM - New Signals
-> Guided AI Labs / New Signal Teams alert
-> M365 Interaction Agent triage packet
-> optional Suggested row after separate approval
```
