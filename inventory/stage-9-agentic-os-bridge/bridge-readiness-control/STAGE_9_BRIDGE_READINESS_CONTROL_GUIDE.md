# Stage 9 Bridge Readiness Control Guide

Generated: 2026-06-17 12:17:32
Config: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\config\M365_STAGE_9_BRIDGE_READINESS_CONTROL.json`

Scope: local-only readiness packet. This guide does not connect to Microsoft 365, create apps, grant consent, send mail, invite guests, change sharing, change permissions, change tenant policy, publish public forms, delete records, or run unattended automation.

## Goal

Turn Stage 9 from proven supervised loops into a clear bridge control plane: what can stay delegated, what might become a purpose-built adapter, what evidence is required, and what remains blocked until Adam approves it.

## Current Daily Doors

| Surface | URL |
|---|---|
| Operations Cockpit | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx |
| CRM Command Center | https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx |

## Principles

- Keep supervised delegated loops as the default until evidence proves the workflow, app posture, and rollback path.
- Use purpose-built bridge identities; do not reuse setup-helper app grants as production agent power.
- Keep reads, proposals, internal writes, restricted writes, and blocked autonomous actions visibly separate.
- Every write-capable bridge action must leave durable evidence in Agent Action Log and, when scope or policy changes, Decision Register.
- External sends, guest access, sharing, app consent, permissions, tenant policy, public forms, destructive actions, and real client commitments remain approval-gated.

## Readiness Checklist

| Track | Current state | Required evidence | Default status | Owner |
|---|---|---|---|---|
| Functional workflow evidence | Stage 8D local walkthrough packet exists and one internal production proof chain is live-recorded/read-back verified. | Completed Stage 8D capture worksheet, findings register, and proof read-back CSV. | Internal proof complete; Adam visual polish review remains | Adam plus Codex |
| Action logging | Agent Action Log exists and Stage 9 supervised loops wrote evidence rows. | Action log row for each bridge action with source, approval state, result, and links. | Ready for supervised loops | Codex/local operator |
| Decision logging | Decision Register item #2 approved the coordinator/support capability for supervised loops. | New Decision Register item before any app registration, consent, or adapter permission change. | Ready for supervised loops | Adam |
| App identity posture | No production bridge app is approved; setup helper app is not a production bridge. | Chosen app posture and resting-state decision for broad setup grants. | Needs decision | Adam plus Codex |
| Support mailbox readiness | Support List loop is proven; support mailbox app/delegated access waits for support MFA. | MFA method exists for support@changeleadershiptools.com before mailbox adapter testing. | Blocked pending MFA | Adam |
| Permission scope design | Selected permissions and Exchange Application RBAC are target options, not granted. | Reviewed permission design with least-privilege scope, revocation path, and test plan. | Needs design approval | Adam plus Codex |
| Rollback and pause path | Stop rules are documented; adapter-specific pause/revoke checklist needs a worksheet. | Rollback owner, revoke command/manual path, and evidence target for each adapter lane. | Needs worksheet | Codex/local operator |
| External/client impact | No autonomous external sends, guest access, public forms, client commitments, or sharing changes are allowed. | Named approval gate and Decision Register entry before any external/client-impacting action. | Blocked for autonomous use | Adam |

## Adapter Contract

| Surface | Read boundary | Write boundary | Level | Evidence | Graduation rule |
|---|---|---|---|---|---|
| Agent Action Log | Read all action log rows needed for audit, status, and suggestions. | Create suggested, dry-run, verification, and completed-action rows. | G1/G2 | Agent Action Log | Required for every later adapter lane. |
| Decision Register | Read prior governance, app posture, and operating decisions. | Record approved decisions only; never infer approval from context. | G2/G3 | Decision Register and Agent Action Log | Required before new app, consent, permission, sharing, or external-send posture. |
| Guided AI Labs operating Lists | Read intake, workspace, handoff, tool review, automation backlog, exceptions, readiness, and CRM records. | Create/update internal records only after approval; no real client commitments without review. | G2 | Agent Action Log plus target List item link | Stage 8D internal proof is captured; broader internal writes still require named approval and evidence. |
| Relationship CRM Lists | Read organizations, contacts, engagements, stakeholders, touchpoints, lifecycle, actions, qualification, notes, artifacts, and health. | Create/update internal relationship records and follow-ups after approval; do not create external commitments. | G2 | Agent Action Log plus CRM item link | CRM command center and Stage 8D proof records must remain easy for Adam to inspect. |
| Planner | Read tasks and bucket state for coordination. | Create/update supervised internal tasks only; no calendar/deadline commitment without approval. | G2 | Agent Action Log plus task link or title | Remain delegated/supervised until a narrower app posture is approved. |
| SharePoint evidence libraries | Read approved evidence, methods, handoff packets, and readiness materials. | Create folders/files only in approved workspace paths; no permission/share changes. | G2/G3 | Agent Action Log plus file/folder link | Selected permissions design must be approved before app-based writes. |
| Exchange support mailbox | Read approved support mailbox metadata and message bodies only after support MFA/access posture is complete. | Create draft replies only; sending remains approval-gated. | G2/G3 | Support Register and Agent Action Log | Support MFA and Exchange Application RBAC design must be complete before app-based access. |
| Teams | Read approved channel context for coordination summaries. | Post internal summaries only after approval; no broad announcements or guest-impacting posts. | G2/G3 | Agent Action Log plus channel/post link when available | Keep manual/supervised until posting etiquette and channel scope are reviewed. |
| Forms and intake routing | Read approved form schema and response routing evidence. | Propose form/flow updates locally; public/client-facing publishing requires approval. | G1/G3 | Decision Register and Agent Action Log | No public/client form publishing until Stage 8D and access decisions are reviewed. |
| Entra app registrations and enterprise apps | Read app ownership, permissions, consent posture, and sign-in/audit evidence. | No default writes. App creation, consent, permission grants, and tenant policy changes require separate approval-gated operators. | G3/G4 | Decision Register, Agent Action Log, and inventory transcript | Must not reuse broad setup helper grants as production bridge capability. |

## App Posture Decision

| Option | Recommended now | Fit | Decision needed |
|---|---|---|---|
| Stay supervised delegated | True | Low-volume approved internal List writes after Stage 8D proof. | Use as default until app resting-state, support MFA, permission design, and rollback decisions are complete. |
| Selected SharePoint/List adapter | False | Future app-based access to specific Guided AI Labs Lists and evidence libraries. | Approve only after adapter contract and rollback worksheet are complete. |
| Exchange Application RBAC support adapter | False | Future support mailbox read/draft loop for Change Leadership Tools. | Wait until support@changeleadershiptools.com MFA is complete. |
| Mixed M365 bridge adapter | False | Later UAOS bridge that combines selected Lists/SharePoint plus scoped support mailbox access. | Only after individual lanes prove safe. |
| Reuse broad setup helper app | False | None for production bridge. | Reject as production posture; decide resting state for setup-helper grants. |

## Risk Controls

| Risk | Severity | Control | Owner | Status |
|---|---|---|---|---|
| Broad setup helper grants remain idle but consented. | High | Record resting-state decision; disable/revoke/time-box broad setup grants when idle. | Adam | Open |
| Stage 8D workflow proof still needs Adam visual polish review. | High | Use the Stage 8D proof read-back and findings register before Teams tab expansion or new automation. | Adam plus Codex | Partially mitigated |
| Support mailbox MFA/access is incomplete. | Medium | Complete MFA method for support@changeleadershiptools.com before mailbox adapter work. | Adam | Open |
| Draft response is mistaken for sent response. | Medium | Separate draft-created evidence from send-approved evidence in Agent Action Log. | Codex/local operator | Open |
| Client or external records enter the bridge before ownership rules are reviewed. | High | Use internal dummy records only until Stage 8D findings and ownership rules are reviewed. | Adam | Open |
| Permission grant lacks a tested revocation path. | High | Document revoke/disable path and evidence target before granting app permissions. | Adam plus Codex | Open |
| Action logs become too vague to audit. | Medium | Require source, classification, proposed action, approval state, result, and links. | Codex/local operator | Open |

## Graduation Gates

| Gate | Required before | Evidence | Status |
|---|---|---|---|
| Stage 8D walkthrough captured | Any broader internal CRM/List write automation or Teams tab expansion. | Completed stage-8d-walkthrough-capture-template.csv, findings register, and stage-8d-workflow-proof-readback-20260617-121052.csv. | Internal proof complete; visual polish review remains |
| Setup-helper resting-state decision recorded | Any production bridge app approval. | Decision Register entry plus Agent Action Log row. | Open |
| Support MFA completed | Support mailbox adapter or mailbox draft loop. | Account/session guide update or verified support MFA note. | Open |
| Adapter permission design approved | Selected permissions or Exchange Application RBAC grant. | Bridge readiness guide reviewed and Decision Register approval. | Open |
| Rollback worksheet complete | Any app-based write permission. | Risk register and adapter contract include pause/revoke owner and target. | Open |
| G0/G1 adapter dry run designed | Any unattended or app-based G2 write test. | Dry-run transcript showing no restricted write. | Open |
| Production bridge decision recorded | Creating or granting a production UAOS M365 adapter. | Decision Register item with scope, owner, expiry/review cadence, blocked actions, and rollback path. | Open |

## Output Files

- Readiness checklist: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-readiness-checklist.csv`
- Adapter contract: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-adapter-contract.csv`
- App posture decision worksheet: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-app-posture-decision-worksheet.csv`
- Risk control register: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-risk-control-register.csv`
- Graduation gates: `C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\.\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-graduation-gates.csv`

## Safe Next Actions

1. Complete the Stage 8D browser/manual dummy walkthrough and fill the capture files.
2. Review this readiness guide and worksheet before any app registration, consent, or adapter permission change.
3. Keep the next Stage 9 action in dry-run-first supervised delegated posture.
4. Record a Decision Register item before moving from delegated loops to any purpose-built bridge adapter.
5. Do not reuse broad setup-helper app grants as production bridge capability.
