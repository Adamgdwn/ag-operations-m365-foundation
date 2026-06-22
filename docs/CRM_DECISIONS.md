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

## Open Decisions

- Exact Microsoft 365 group or SharePoint permission groups for future CRM
  employees and trusted partner/operators.
- Whether employees enter through Teams tabs, SharePoint navigation, browser
  bookmarks, or all three.
- Whether future automation reads approved mailbox folders after the manual
  recovery path is stable. (Note: Path B settled *form*-based intake automation
  only; mailbox-folder automation remains open and separate.)
- Whether Power Apps becomes worth the cost later.
