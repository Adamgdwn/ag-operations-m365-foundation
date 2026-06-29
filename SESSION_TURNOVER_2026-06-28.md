# Session Turnover - 2026-06-28

Canonical restart file:
[START_HERE.md](START_HERE.md).

Status: night box-up turnover after documentation cleanup, QUO/Sona prompt
placement, Linux M365 setup, GAIL OS local proof, Azure pilot deployment, and
`01 Work Tracking` ledger refresh.

## Read First

1. [START_HERE.md](START_HERE.md)
2. [docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md](docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md)
3. [docs/2026-06-28_DOCUMENTATION_STATUS_REVIEW.md](docs/2026-06-28_DOCUMENTATION_STATUS_REVIEW.md)
4. `C:\Users\adamg\01. Code Projects\01 Work Tracking\AG Operations Workspace Setup\latest.md`

Open older chunk ledgers, stage packets, exports, or inventory evidence only
when auditing a specific proof or historical decision.

## M365 Interaction Agent State

B1-B9 G0 are live-proven for the first signal lane:

```text
Journey/site signal -> CRM - New Signals -> New Signal Teams alert
-> selected triage/advisory -> optional Suggested row -> evidence
```

Completed since the 2026-06-25 turnover:

- B8 Journey receipt/replay hardening and idempotency proof.
- B9 selected internal read-only operating triage proof.
- B10a QUO local inbound source readiness packet.
- B10b QUO source contract/design pack.
- B10c.0 local QUO API key readiness with sanitized dry-run evidence and no
  live QUO API read.
- B10c.0a QUO/Sona CRM intake prompt and placement guidance. Message-only
  calls stay in QUO; consented follow-up inquiries may later enter
  `CRM - New Signals` with `IntakeSource = QUO` and `CreateCrmSignal: true`.
- D1 documentation currentness sweep. Startup and index files now point to the
  2026-06-28 active build plan as the execution source of truth.
- D2 night box-up. The startup path, documentation status review, and external
  `01 Work Tracking` ledger were refreshed so a future agent can start without
  loading old stage packets or oversized historical ledgers.

## Cross-Repo / DirectLink Context

Context only; this does not authorize Phase 4 M365 connector execution.

- Linux M365 CLI is authenticated as `adamgoodwin@guidedailabs.com` through a
  tenant-local delegated app.
- The tenant-local CLI app has limited delegated permissions for the setup
  proof; it is not the production GAIL OS connector authority.
- GAIL OS CTP-2 local triangle proof is complete with dry-run M365 bridge
  evidence and no live Graph write.
- Personal-credit Azure subscription hosts the pilot resources:
  GAIL OS API and Graphify CNS API are deployed to Azure Container Apps.
- Graphify CNS persistence is mounted on Azure Files and health remains green.
- Upstream Chunk 5.5 added
  `docs/2026-06-28 - M365 CNS Source Surface Map.md` as Phase 5
  connector-planning context. It does not override this repo's transitional
  Power Automate proof-flow status.

## Current Default Next Move

Hold after the documentation cleanup unless Adam asks to continue.

When resumed, the default build move is B11 selected operating cadence:

```text
Adam-approved low-risk signal batch
-> G0 triage/advisory evidence
-> optional per-item G1 Suggested rows
-> no external send
```

Alternative later move: B10c.1 live QUO proof, but only after exact approval of
number, event, ingress, secret handling, retention, disable/revoke path, and
outbound-block posture.

## Boundaries

No file in this repo grants standing approval for live tenant/source work.

Stop before app registration, app consent, permission expansion, external send,
guest/sharing change, public form, delete/merge, billing/client commitment,
custom action, source webhook, QUO live read, CRM write from QUO, unattended
automation, or Phase 4 connector execution unless Adam gives fresh explicit
approval for that exact scope.

## Current Docs

Use:

- Active execution plan:
  [docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md](docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md)
- Documentation status:
  [docs/2026-06-28_DOCUMENTATION_STATUS_REVIEW.md](docs/2026-06-28_DOCUMENTATION_STATUS_REVIEW.md)
- QUO prompt/placement:
  [docs/2026-06-28_QUO_CRM_INTAKE_PROMPT.md](docs/2026-06-28_QUO_CRM_INTAKE_PROMPT.md)
- M365 CNS source surface map:
  [docs/2026-06-28 - M365 CNS Source Surface Map.md](docs/2026-06-28%20-%20M365%20CNS%20Source%20Surface%20Map.md)
- Historical chunk ledger:
  [docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md](docs/2026-06-25_M365_INTERACTION_AGENT_NEXT_BUILD_CHUNKS.md)

## Work Tracking

The external local work-tracking folder has been updated:

```text
C:\Users\adamg\01. Code Projects\01 Work Tracking\AG Operations Workspace Setup\
```

Current files:

- `latest.md`
- `log\2026-06-28.md`

No secrets, tokens, API keys, ACR passwords, storage keys, or tenant credentials
belong in this turnover.
