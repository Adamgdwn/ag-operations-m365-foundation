# B5 Competing Writer Audit

Date: 2026-06-25

Status: B5 resume packet recorded live in Microsoft 365 on 2026-06-25. Decision
Register item `#6` records the one-writer posture; Agent Action Log item `#10`
records the evidence.

Purpose: restart the `M365 Interaction Agent` lane after the B1-B4 proof without
letting two M365-writing agents compete for the same account, list, flow, or
approval surface.

## Resume Finding

The repo-visible competing writer family is the older Stage 9
`M365 Coordinator` / `M365 Support Agent` supervised loop path. The newer plan
now wants one governed `M365 Interaction Agent`, with coordinator, support,
CRM, Teams, Planner, mailbox, and future QUO work treated as capabilities of
one agent rather than separate helper agents.

This packet identifies the writers visible from repo evidence.

Adam clarified on 2026-06-25 that the other live work was in the Prime Boiler
365 setup while he was logging in and out of two accounts. Treat that as a
separate tenant/account lane, not as a second Guided AI Labs agent competing for
the `CRM - New Signals` path. The remaining risk is account/session bleed while
switching browser profiles or persisted M365 tokens.

The Guided AI Labs `New Signal` path remains canonical for this repo. Guided AI
Journey intake should feed the same `CRM - New Signals` list through the
existing create-only intake flow and then alert Adam in `Guided AI Labs / New
Signal`.

## Writer And Surface Inventory

| Writer or automation | Evidence | Current or potential writes | B5 posture |
|---|---|---|---|
| `GAIL - New Signal Teams alert` Power Automate flow | `inventory/forms-build/flow-result-new-signal-teams.json`; flow id `c54964d6-0042-430d-b542-90214e49224b` | Posts internal Teams alerts to `Guided AI Labs / New Signal` when `CRM - New Signals` items are created. | Keep as the canonical internal alert lane unless Adam explicitly disables it. It is an automation writer, not an agent decision writer. |
| Guided AI Labs and Guided AI Journey intake flows | `inventory/forms-build/flow-result-labs.json`; `inventory/forms-build/flow-result-journey.json`; `docs/CRM_PUBLIC_INTAKE_PATH_B.md` | Create new `CRM - New Signals` items from the two public Microsoft Forms, stamping `IntakeSource` as `Guided AI Labs` or `Guided AI Journey`. | Accepted source-ingress automations. They are create-only into CRM and do not replace the agent decision lane. Guided AI Journey client invites should use this path. |
| `M365 Interaction Agent` B2/B3/B4 lane | `scripts/Invoke-M365NewSignalTriage.ps1`; B4 row `Agent Action Log #9` | Reads `CRM - New Signals` and related CRM lists; with `-Apply`, writes one G1 `Suggested` row to `Agent Action Log`. | Recommended canonical agent lane after B5. Keep `-Apply` paused until Adam explicitly approves the next G1 write. |
| Stage 9 `M365 Coordinator` loop | `scripts/Invoke-M365Stage9AgentCapabilityLoop.ps1`; Decision Register `#2/#3`; Agent Action Log `#2/#3/#5` | Can write `Decision Register` and `Agent Action Log`; config also describes approved internal List/Planner writes after gates. | Freeze as historical/proof path or fold into `M365 Interaction Agent` as a capability. Do not run with `-Apply` or `-Approve` without a later explicit approval. |
| Stage 9 `M365 Support Agent` loop | `scripts/Invoke-M365Stage9AgentCapabilityLoop.ps1 -Action SupportTriage`; Support Register `#1`; Agent Action Log `#4` | Can write `Change Leadership Tools - Support Register` and `Agent Action Log`; mailbox drafts are future only. | Keep parked unless Adam is intentionally working the support lane. Support mailbox adapter still waits for MFA and a separate decision. |
| `agent-pnp-provisioning` setup helper | Stage 7 security inventory and roadmap docs | Broad delegated setup/provisioning authority such as SharePoint and Graph build scopes. | Not a production agent identity. Needs a resting-state decision; do not use as `m365-interaction-agent`. |
| Bookings / follow-up backbone flows | setup and verification docs under `docs/` and `inventory/forms-build/` | Existing source-ingress and follow-up automation can create CRM records, tasks, calendar/reminder state, or alerts depending on flow. | Treat as business automations, not free-form agents. Keep only if they do not duplicate agent decision writes. |
| Prime Boiler 365 setup agent/session | Adam clarification on 2026-06-25 | Separate Prime Boiler Microsoft 365 setup work while Adam was switching accounts. | Keep separated by account/profile/session. Do not let Prime Boiler tooling write to Guided AI Labs M365 surfaces, and do not use Guided AI Labs tokens for Prime Boiler setup. |

## Recommended B5 Decision

Adopt a one-writer rule for agent decisions:

- Canonical agent name: `M365 Interaction Agent`.
- Human owner: Adam.
- Immediate purpose: read new CRM signals, produce triage/similar-record
  judgment, and record reviewable suggestions.
- Immediate write surface after B5 only: `Agent Action Log` rows with
  `ActionStatus = Suggested`.
- Existing automation exception: keep the `GAIL - New Signal Teams alert` flow
  as the internal Teams alert lane for any approved `CRM - New Signals` source.
- Existing source-ingress exception: keep the Guided AI Labs and Guided AI
  Journey public Microsoft Forms flows as create-only CRM item creators.
- Guided AI Journey client-invite intake should enter through the Journey Form
  or website CTA/embed that points at that Form. Do not build a direct website
  CRM POST route, store tenant secrets in the site, or introduce a native
  website-to-CRM writer without a separate B5/B6 decision.
- Prime Boiler 365 setup is a separate account lane. It is not part of the
  Guided AI Labs `M365 Interaction Agent` permission boundary.
- Historical loop posture: Stage 9 `M365 Coordinator` and `M365 Support Agent`
  are no longer independent live writers by default. They are prior proof loops
  or future capabilities under the single `M365 Interaction Agent` contract.
- Durable permission posture for now: stay supervised/delegated and local-first.
  Do not create an app registration, grant consent, grant SharePoint Selected
  permissions, configure Exchange Application RBAC, or reuse
  `agent-pnp-provisioning` as production authority.

This recommendation was selected and recorded live as Decision Register item
`#6`, with the evidence row recorded as Agent Action Log item `#10`.

Decision packet prepared:

- `inventory/m365-interaction-agent-b5/B5_DURABLE_PERMISSION_DECISION_2026-06-25.md`
- `inventory/m365-interaction-agent-b5/decision-register-draft-b5-one-writer-20260625.csv`
- `inventory/m365-interaction-agent-b5/decision-register-draft-b5-one-writer-20260625.json`

These files are the local source packet for the approved live B5 recording.

## B5 Permission Posture Draft

Agent name:

- `M365 Interaction Agent`

Owner:

- Adam

Purpose:

- Monitor approved Microsoft 365 operating records.
- Triage new CRM signals.
- Flag related CRM records.
- Prepare suggested next actions for human review.
- Leave durable local evidence and, after approval, one `Suggested` action-log
  row.

Non-goals:

- Do not send external email, Teams chats, SMS, calls, or QUO responses.
- Do not merge or suppress CRM records.
- Do not update CRM fields, create Planner/calendar work, or make client
  commitments without later G2/G3 approval.
- Do not invite guests, change sharing, grant permissions, create apps, grant
  consent, change tenant policy, publish public forms, delete records, or run
  unattended automation.

Initial read surfaces:

- `CRM - New Signals`
- `CRM - Organizations`
- `CRM - Contacts`
- `CRM - Engagements`
- `CRM - Touchpoints`
- `Agent Action Log`
- `Decision Register`
- `inventory/forms-build/flow-result-labs.json`
- `inventory/forms-build/flow-result-journey.json`
- local evidence under `inventory/new-signal-alert/` and
  `inventory/new-signal-triage/`

Initial write surfaces after B5:

- One G1 `Suggested` `Agent Action Log` row per selected CRM signal, only
  through `scripts/Invoke-M365NewSignalTriage.ps1 -Apply` and only after
  confirmation.

Blocked actions:

- CRM updates, merges, suppressions, dedupe conversions, Planner/calendar work,
  external sends, QUO actions, app/permission changes, guest/share changes,
  deletes, client commitments, and unattended tenant-writing automation.

Proposed Microsoft permissions:

- No new permission grant for B5.
- No production app registration for B5.
- No SharePoint Selected grant for B5.
- No Exchange Application RBAC grant for B5.
- Continue using supervised delegated read/propose/log only until the one-writer
  decision is recorded.

Approval phrase used for the approved live recording:

```text
approve-b5-record-one-writer-m365-interaction-agent-20260625
```

Recording helper:

- Local preview, no Microsoft 365 connection:
  `scripts/Invoke-M365B5InteractionAgentDecision.ps1 -LocalOnly -NoPause`
- Tenant dry run, read/verify only:
  `scripts/Invoke-M365B5InteractionAgentDecision.ps1 -NoPause`
- Live recording after explicit approval:
  `scripts/Invoke-M365B5InteractionAgentDecision.ps1 -Apply -ApprovalPhrase "approve-b5-record-one-writer-m365-interaction-agent-20260625" -NoPause`

Review date:

- 2026-07-09, or earlier if B6 source expansion starts.

Evidence location:

- This file.
- `inventory/m365-interaction-agent-b5/B5_DURABLE_PERMISSION_DECISION_2026-06-25.md`
- `scripts/Invoke-M365B5InteractionAgentDecision.ps1`
- `scripts/Start-M365B5InteractionAgentDecisionInteractive.ps1`
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-174036.json`
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-174036.log`
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-175449.json`
- `inventory/m365-interaction-agent-b5/b5-interaction-agent-decision-20260625-175449.log`
- `docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md`
- `SESSION_TURNOVER_2026-06-25.md`
- `inventory/new-signal-alert/new-signal-alert-proof-20260625-162306.md`
- `inventory/new-signal-triage/new-signal-triage-20260625-162436.md`

## Disable Or Revoke Paths

| Surface | Pause / revoke path | Approval needed |
|---|---|---|
| New Signal Teams alert flow | Turn off flow `GAIL - New Signal Teams alert` in Power Automate. | Adam approval before disabling a live alert lane. |
| Guided AI Labs intake flow | Turn off flow `GAIL - Guided AI Labs intake to CRM (create-only)` in Power Automate. | Adam approval before disabling a live intake lane. |
| Guided AI Journey intake flow | Turn off flow `GAIL - Guided AI Journey intake to CRM (create-only)` in Power Automate, or remove the Journey website CTA/embed that points at the Form. | Adam approval before disabling a live intake lane. |
| B4 Suggested-row script | Do not run `scripts/Invoke-M365NewSignalTriage.ps1 -Apply` or `-Approve`; reject or supersede Agent Action Log row `#9` if needed. | Adam approval before any further row write. |
| Stage 9 coordinator/support loops | Do not run `scripts/Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Apply` or `-Approve`. | Adam approval before any future Stage 9 write loop. |
| Persisted local PnP session | Use the existing clear-login helper if Adam wants local token cleanup. | Local-only cleanup, but still coordinate because it affects operator convenience. |
| `agent-pnp-provisioning` setup helper | Revoke delegated grants, disable the enterprise app, or delete the app registration after a formal decision. | Requires explicit tenant/admin approval and evidence. |
| Prime Boiler 365 setup agent/session | Keep it in the Prime Boiler account/profile/session. Pause or sign out before returning to Guided AI Labs work if browser token confusion appears. | Adam controls the account switch; no Guided AI Labs tenant write should be performed from the Prime Boiler lane. |

## Adam Clarification Recorded

- The other live work was Prime Boiler 365 setup under a separate account/session.
- The Guided AI Labs `New Signal` path remains the path for this repo.
- Guided AI Journey client intake should create a `CRM - New Signals` record in
  this M365 environment.

## Pending Adam Decisions

1. Should `agent-pnp-provisioning` stay consented as a setup helper for now, or
   should a resting-state revoke/disable decision be scheduled before B6?
2. For the first B6 Guided AI Journey proof, should the test entry be the direct
   Microsoft Form link, the Journey website CTA/embed, or a client-invite
   workflow that points to the same Form?

## Resume Rule

B5 decision path is recorded. Do not run B6 or any follow-on live write until
Adam approves the exact selected proof:

```text
one canonical agent
-> named write surfaces
-> named pause/revoke paths
-> no setup-helper authority as production agent power
-> then source expansion
```
