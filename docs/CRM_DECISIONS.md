# CRM Decisions

Date: 2026-06-18

Status: Active decision log for the recovery path.

## Decisions

| Date | Decision | Reason |
|---|---|---|
| 2026-06-17 | Use SharePoint pages, SharePoint lists/views, and OneDrive/SharePoint links for the recovery pass. | No purchase, no Dataverse/Dynamics, no premium dependency, and usable now. |
| 2026-06-17 | Make `CRM - New Signals` the daily intake list. | The older `Guided AI Labs - Intake Register` exposes technical fields and is not employee-friendly. |
| 2026-06-17 | Keep tenant writes gated by `apply-gail-crm-recovery`. | Recovery work must not accidentally change permissions, sharing, app grants, mail, public forms, deletes, or automation. |
| 2026-06-18 | Define completion as employee readiness, not script success. | A PASS verifier is insufficient if a capable employee cannot show up, log in, follow instructions, and operate. |
| 2026-06-18 | "Full access" means full operating access for the assigned role, including a broader trusted partner/operator role when deliberately granted. | Employees and partners need enough access to work without accidental tenant/global admin sprawl; security settings, app consent, billing, destructive actions, and break-glass access remain controlled separately. |
| 2026-06-18 | Root Stage 8 CRM docs become provenance once active CRM docs exist. | Older packet docs explain build history but should not compete with the recovery runbook. |
| 2026-06-20 | Add public brand intake (Path B): two anonymous Microsoft Forms (Guided AI Labs, Guided AI Journey) feed `CRM - New Signals` via a create-only Power Automate flow that stamps the brand into a new operator-visible `Source` field and writes capture provenance into the existing hidden technical fields. | Adam chose Path B: prospects submit on the brand sites and the CRM should auto-populate and identify which front-door the signal came through. Reuses the blocked technical fields as designed; no change to the daily operator path. Spec in `docs/CRM_PUBLIC_INTAKE_PATH_B.md`. |
| 2026-06-20 | Scoped governance unlock: lift "No public Forms links" and "No unattended automation" ONLY for the two named intake forms and the single create-only intake flow above. | Path B requires both, but the general posture must not erode. The flow is create-only into one list; no deletes, mail sends, auto-replies, external sharing, guest invites, permission/consent changes, premium connectors, or Dynamics/Dataverse. All other safety limits remain in force, and the PnP apply scripts still honor the full original list. |
| 2026-06-22 | Streamline the daily `CRM - New Signals` front door: require only **Title + Need/opportunity** (2 fields, was 8). Make SignalType, IntakeSource, Priority, SignalStatus, SourceText, NextAction all optional. | V5 (Chunk-6 human acceptance) surfaced the intake as **cumbersome**. The four Choice fields default sensibly on create (Referral/Direct/Normal/New) so data quality holds without forcing input; SourceText/NextAction belong at triage, the next lifecycle stage, not at capture. Lighter capture front door; verifier stays 0/0 PASS (it only enforces required=True on `requiredBusinessFields`). Quick-add / Power Apps front door remains Future Work. Applied live 2026-06-22. |
| 2026-06-22 | Accept V5 as operator-accepted and CLOSE the CRM recovery (Chunk 8), waiving the exhaustive manual lifecycle walk as a non-blocker. | Adam (acceptance authority) confirmed the live front door + streamlined capture in-browser (MFA) and directed closeout ("this is fine for now, carry on with Chunk 8"). The per-stage lifecycle (triage→qualify→next action→handoff→closeout) is SharePoint views/status changes already proven by the Chunk-3 verifier (0/0/184 PASS) and exercised daily by the live Path B / Bookings end-to-end runs into the same list+queues, so a manual per-stage walk adds little. Recovery Status → CLOSED; record kept honest (operator acceptance, not a fabricated full walk). The kit stays valid if the exhaustive walk is ever wanted. |
| 2026-06-22 | Hold the Stage 8 packet archive move until a separate explicit OK; do NOT treat "carry on with Chunk 8" as authorization for it. | The archive move (relocating root Stage 8 CRM docs + generated packets/exports into `inventory/archive/2026-06-17-stage-8-packet/`) is a file-relocation with its own long-standing guard ("do NOT do automatically"). It is not a recovery blocker — the root docs are already labelled provenance — so closing the recovery does not require it. One destructive-ish decision at a time on live structure: it waits for Adam's explicit go. |
| 2026-06-24 | Add a dedicated internal Teams channel named `New Signal` and a create-only Power Automate alert flow from `CRM - New Signals` to that channel. | First minutes matter when an opportunity or urgent signal lands. CRM remains the source of truth; Teams is the attention surface. Scope is narrow: one internal standard channel, one SharePoint-created-item trigger, one Teams post, no external sends, no prospect notification, no guest/sharing/permission changes, no QUO hookup. |
| 2026-06-24 | Treat this as one governed M365 Interaction Agent with capabilities, not separate CRM/Teams/helper bots. | Adam wants agents, not a supervised helper stack. Freedom is the architectural reference: one named agent identity with tools, contracts, evidence, and approval gates. Coordinator is the first capability, and New Signal alerting is the first live notification capability. |
| 2026-06-24 | Park QUO phone integration until after the New Signal Teams notification is proven. | QUO can later feed the same CRM -> Teams -> agent proposal path, but it should not distract from getting the first-minute Teams alert working now. |
| 2026-06-24 | Use the standard Power Automate SharePoint and Teams connectors for the New Signal proof; defer the durable `m365-interaction-agent` permission posture decision. | The alert proof needs speed and narrow scope, not a new production app registration. This allows one internal proof while keeping app registration, admin consent, broad Graph permissions, QUO, and external messaging blocked. |

## Open Decisions

- Exact Microsoft 365 group or SharePoint permission groups for future CRM
  employees and trusted partner/operators.
- Whether employees enter through Teams tabs, SharePoint navigation, browser
  bookmarks, or all three.
- Whether future automation reads approved mailbox folders after the manual
  recovery path is stable. (Note: Path B settled *form*-based intake automation
  only; mailbox-folder automation remains open and separate.)
- Whether Power Apps becomes worth the cost later.
