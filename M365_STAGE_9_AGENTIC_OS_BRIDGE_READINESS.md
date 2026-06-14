# Microsoft 365 Stage 9 - Agentic OS Bridge Readiness

Status: **planned - prepare after Stage 7 governance and Stage 8 workspace pattern**
(2026-06-14).

Stage 9 prepares Microsoft 365 to become a governed spoke for the future Guided
AI Labs User AI Operating System and Graphify Workspace Cockpit. It does not
build unattended automation yet. It defines the bridge so future automation can
be powerful without becoming vague, over-permissioned, or hard to audit.

Related:

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md](M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md)
- [M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md](M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)

---

## 1. Goal

Define the M365 bridge contract for the future Agentic OS:

```text
where the OS may read
where the OS may write
what the OS may propose
what always requires Adam approval
how actions are logged
how failures are detected
how access can be paused or revoked
```

Stage 9 should leave Microsoft 365 ready to connect to Graphify/UAOS without
turning the setup helper apps into permanent broad automation power.

---

## 2. Operating Principle

The bridge rule:

```text
The Agentic OS gets purpose-built access, not inherited setup power.
```

Setup apps, human admin sessions, delegated scripts, Power Automate flows, and
future UAOS adapters should have distinct purposes and distinct resting states.

M365 remains the governed business substrate. Graphify is the knowledge and
decision intelligence layer. UAOS is the mission execution layer. Stage 9 defines
the boundary between them.

---

## 3. Bridge Layers

| Layer | Responsibility |
|---|---|
| Microsoft 365 | Identity, mail signals, files, Lists, Planner tasks, Teams conversations, Forms intake, audit |
| Graphify Workspace Cockpit | Cross-system graph, decisions, recommendations, workspace map, work queue |
| UAOS | Policy-gated missions, adapters, approvals, execution evidence, rollback/stop rules |
| Codex/local repo | Build control room, scripts, design docs, reproducible setup/handoff trail |

The bridge should make links and identifiers durable enough for these layers to
refer to the same work item without copying every record into every system.

---

## 4. Access Categories

| Category | Allowed posture |
|---|---|
| Read | Inventory, summarize, classify, map, detect gaps |
| Propose | Draft List rows, tasks, decisions, replies, forms/flow changes |
| Human-approved write | Create/update records, tasks, decisions, forms/flow routing after review |
| Restricted write | Guest access, sharing, app consent, tenant policy, external sends, calendar commitments |
| Never autonomous | Secrets, break-glass accounts, destructive tenant actions, broad permission grants |

Default:

```text
Read/propose/log first. Write only through named approval gates.
```

---

## 5. Adapter Surface Map

Initial M365 bridge candidates:

| Surface | Read use | Write use | Approval posture |
|---|---|---|---|
| Exchange | Intake/signal summaries | Draft replies only at first | External sends require approval |
| Microsoft Lists | Operating state, decisions, agent log | Create/update rows | Human approval for client/external-sensitive rows |
| Planner | Tasks and next actions | Create/update action tasks | No calendar/deadline commitments without approval |
| SharePoint | Durable records and links | Create folders/files only within approved workspace | Client/sensitive records require workspace rule |
| Teams | Channel context and coordination | Post summaries/notices | No guest invites or broad posts without approval |
| Forms | Intake/feedback schema and response routing | Propose forms/flows; later create/update if supported | Public/client links require approval |
| Entra/app registrations | Inventory, consent posture, app ownership | None by default | Consent/permissions always approval-gated |

This map should become the future UAOS adapter contract.

---

## 6. Identity And App Registration Posture

Stage 9 should separate:

| App/account | Purpose | Resting state |
|---|---|---|
| Human admin account | Tenant administration | Used only when needed; protected by MFA/governance |
| Setup helper app | Provisioning and repair during build stages | Disabled, revoked, or explicitly time-bound when idle |
| Read-only inventory app | Audits and health checks | Least-privilege delegated or application read scopes |
| UAOS M365 adapter app | Future governed operations | Purpose-built, scoped, logged, and approval-gated |
| Power Automate connections | Forms/List/Planner/Teams routing | Owned by controlled account; documented and reviewed |

No future production bridge should simply reuse `agent-pnp-provisioning` because
it was convenient during setup.

---

## 7. Action Logging And Evidence

Every meaningful bridge action should produce:

```text
source -> classification -> proposed action -> approval state -> execution result -> durable link -> action log entry
```

Minimum log fields:

| Field | Purpose |
|---|---|
| Action id | Stable reference across M365/Graphify/UAOS |
| Source | Message, form response, list item, task, file, or channel |
| Surface | Exchange, Lists, Planner, SharePoint, Teams, Forms, Entra |
| Action type | read, summarize, draft, create-record, create-task, update-record, recommend |
| Approval state | suggested, approved, completed, rejected, superseded |
| Human approver | Adam or delegated owner |
| Result | Outcome, error, rollback, or reason not executed |
| Links | M365 item link plus future Graphify/UAOS link |

The Stage 6 Agent Action Log is the first implementation of this evidence trail.

---

## 8. Stop, Rollback, And Review Rules

The bridge must stop before:

- unexpected permission prompts;
- unknown publisher or risky app warnings;
- tenant-wide policy changes;
- public sharing changes;
- guest invitations;
- external sends;
- destructive deletes;
- access to a client workspace whose ownership rule is unclear;
- repeated automation failures without human review.

Rollback expectations:

| Action type | Rollback expectation |
|---|---|
| Draft/proposal | Mark superseded or rejected |
| List/task update | Preserve prior value when practical, log correction |
| File/folder creation | Move/archive only with approval |
| Flow/app change | Disable or revert documented change |
| Permission/share change | Remove access and log review |

---

## 9. Stage Exit Criteria

Stage 9 is done when:

- M365/Graphify/UAOS boundary is documented;
- adapter surface map is approved;
- read/propose/write/restricted categories are defined;
- setup helper app resting-state decision is complete;
- future UAOS app registration posture is documented;
- action logging schema is aligned with Stage 6 Lists;
- stop/rollback/review rules are documented;
- at least one low-risk read/propose/log bridge loop is demonstrated without
  autonomous external action.

---

## 10. Source Notes

This stage should be implemented only after Stage 7 governance decisions are
recorded. Microsoft Graph, Entra app registration, Power Automate, and browser
automation choices should be checked against current official Microsoft
documentation before any production adapter or app consent is approved.
