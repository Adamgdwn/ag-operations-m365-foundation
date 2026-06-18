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

## Open Decisions

- Exact Microsoft 365 group or SharePoint permission groups for future CRM
  employees and trusted partner/operators.
- Whether employees enter through Teams tabs, SharePoint navigation, browser
  bookmarks, or all three.
- Whether future automation reads approved mailbox folders after the manual
  recovery path is stable.
- Whether Power Apps becomes worth the cost later.
