# Microsoft 365 Stage 7 - Security, Governance, And External Sharing

Status: **started - local baseline and read-only inventory tooling prepared**
(2026-06-14).

Stage 7 protects the Microsoft 365 operating substrate before Guided AI Labs uses
it with a business partner, client, or future UAOS/M365 adapter. This is where we
make the AI-first company posture trustworthy: fast enough to build, controlled
enough to teach, and boring enough to operate.

Related:

- [M365_FOUNDATION_ROADMAP.md](M365_FOUNDATION_ROADMAP.md)
- [M365_GRAPHIFY_UAOS_ALIGNMENT.md](M365_GRAPHIFY_UAOS_ALIGNMENT.md)
- [M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md](M365_STAGE_6_TEAMS_PLANNER_LISTS_OPERATING_STATE.md)
- [TOOLING_AND_LICENSING.md](TOOLING_AND_LICENSING.md)
- [config/M365_STAGE_7_GOVERNANCE_BASELINE.json](config/M365_STAGE_7_GOVERNANCE_BASELINE.json)

---

## 1. Goal

Define and verify the safety boundaries for:

```text
who can access what
what can be shared externally
which data is sensitive
what requires approval
what must be audited
what should not sync locally
```

Stage 7 is not about slowing down the company. It is about making sure AG
Operations and Guided AI Labs can invite partners, onboard clients, and connect
agents without making trust depend on memory or luck.

---

## 2. Operating Principle

The rule from the identity naming standard carries forward:

```text
Interaction surface != capability surface
```

In Stage 7 language:

```text
Untrusted input, partner access, client access, and agent execution must not
inherit broad tenant power by accident.
```

Microsoft 365 should remain the governed business substrate. Graphify is the
decision layer. UAOS is the future mission execution layer. Stage 7 makes sure
the Microsoft substrate is clean enough for that future adapter boundary.

---

## 3. Baseline Posture

| Area | Target posture |
|---|---|
| MFA / sign-in | Security Defaults now unless replaced by Business Premium / Entra P1 Conditional Access |
| Admin roles | Two break-glass accounts, controlled admin account, and Adam's accepted-risk daily GA reviewed |
| App consent | Broad setup permissions only while needed; idle setup apps reviewed or disabled |
| Guests | No guests until a named onboarding decision is approved |
| External sharing | Off or most restrictive by default; named exceptions only |
| Microsoft Forms | Internal-only/default-restricted until public/client response collection is explicitly approved |
| Share links | Specific people or organization-only links by default |
| Labels / retention | Plain-language model now; Purview labels/retention when licensing supports it |
| Device sync | Sync active trusted libraries only; keep client/sensitive libraries browser-first |
| Audit | Written cadence for sign-ins, roles, guests, app consent, sharing, and agent actions |
| Agents | Read/propose/log first; writes and external action require explicit approval |

---

## 4. Licensing Decision

Current known license posture:

```text
Tenant has Microsoft 365 Business Standard, not Business Premium.
```

This matters because Microsoft documents:

- Security Defaults are available at no extra cost.
- Conditional Access requires Microsoft Entra ID P1.
- Microsoft 365 Business Premium includes Entra ID P1 for small and medium
  businesses.

Practical decision:

| Option | What it gives | Tradeoff |
|---|---|---|
| Security Defaults | Free MFA baseline, blocks legacy auth, protects privileged activity | Less customizable and can block device-code auth used by current setup scripts |
| Business Premium / Entra P1 | Conditional Access, richer control, better fit for agentic operations | Requires license purchase or Founders Hub benefit |
| Entra P2 / higher | Risk-based policies and deeper identity protection | Probably later, after client/partner volume proves need |

Recommendation:

1. Check the Microsoft for Startups Founders Hub path for Guided AI Labs.
2. If Business Premium is obtainable, move toward Conditional Access.
3. If not, use Security Defaults as the free baseline and adapt scripts away from
   device-code auth where needed.

---

## 5. App Consent And Setup Apps

Stage 7 review backlog includes:

```text
agent-pnp-provisioning
```

Current concern:

- It was useful for setup/provisioning.
- It has broad delegated setup capability.
- It should not sit indefinitely as an idle broad-write capability without a
  recorded reason.

Target resting-state rule:

| App type | Resting-state posture |
|---|---|
| Setup helper app | Disabled, consent-revoked, or explicitly marked active during a current build stage |
| Inventory app | Delegated read-only scopes where possible |
| Future UAOS/M365 adapter | Separate app registration, scoped by purpose, with policy gates and action logging |

No raw consent URLs should be used. Consent review happens inside Entra admin
center with the app name, publisher, permissions, and warning state visible.

---

## 6. External Sharing Rule

Default:

```text
External sharing stays off or most restrictive unless a named business workflow
requires it.
```

Exception path:

1. Identify the partner/client and business reason.
2. Decide whether the work belongs in AG/GAL tenant or the client tenant.
3. Prefer client-owned tenant for client-owned durable records.
4. If sharing from AG/GAL tenant, use a named site/library and named people.
5. Log the decision in the Decision Register.
6. Review access after the engagement closes.

This is the bridge into Stage 8: client workspaces should be repeatable, not
improvised one-off sharing.

### 6.1 Microsoft Forms collection rule

Microsoft Forms is useful enough to be treated as a first-class intake surface,
but public form links are still external collection surfaces.

Default:

```text
Forms stay internal/test-only until the specific form, audience, response data,
and routing flow are approved.
```

Required before distributing an external/client-facing form:

1. Confirm what data the form collects.
2. Confirm whether unauthenticated/public responses are acceptable.
3. Keep phishing protection enabled.
4. Route responses into the correct Microsoft List through Power Automate.
5. Avoid collecting sensitive client records until the engagement/workspace rule
   is decided.
6. Record the form link, purpose, owner, and approval in the Decision Register.

The Stage 6 Forms kit is the build source:

```text
config/M365_FORMS_INTAKE_FEEDBACK_KIT.json
inventory/stage-6-operating-state/forms-intake-feedback/M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md
```

---

## 7. Agentic Approval Gates

Agents may safely help with:

- read-only inventory;
- classification;
- summaries;
- draft rows/tasks/decisions;
- proposed sharing or guest-access requests;
- evidence logging;
- policy-gap detection.

Human approval is required before:

- inviting guests;
- changing external sharing;
- granting permissions;
- approving app consent;
- sending external messages;
- committing to calendar meetings/deadlines;
- changing tenant policy;
- deleting records;
- publishing canonical methods/IP.

The Agent Action Log and Decision Register from Stage 6 become the review trail
for these gates.

---

## 8. Read-Only Inventory

Artifacts:

| Artifact | Purpose |
|---|---|
| `config/M365_STAGE_7_GOVERNANCE_BASELINE.json` | Machine-readable baseline and exit criteria |
| `scripts/Invoke-M365Stage7SecurityInventory.ps1` | Read-only Graph inventory for security/governance posture |
| `scripts/Start-M365Stage7SecurityInventoryInteractive.ps1` | Visible launcher for Adam sign-in/MFA |
| `scripts/Summarize-M365Stage7SecurityInventory.ps1` | Local summarizer for completed inventory folders |
| `scripts/Test-M365Stage7LocalPreflight.ps1` | Local parse/config/module check, no M365 connection |

Routine local check:

```powershell
.\scripts\Test-M365Stage7LocalPreflight.ps1
```

Read-only live inventory:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1
```

Optional SharePoint admin read-back, if the SharePoint Online module is
installed and Adam is ready for a second admin auth prompt:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin
```

The SharePoint admin read is optional because this machine currently may not have
the `Microsoft.Online.SharePoint.PowerShell` module installed.

---

## 9. Stage Exit Criteria

Stage 7 is done when:

- read-only Stage 7 inventory is captured and summarized;
- Business Premium / Entra P1 decision is recorded;
- Security Defaults versus Conditional Access path is chosen;
- external sharing default and exception process are documented;
- guest invitation rule is documented;
- provisioning app resting-state decision is recorded;
- partner onboarding security gate is defined;
- Stage 8 client workspace work can begin without guessing the safety rules.

---

## 10. Source Notes

Checked Microsoft documentation on 2026-06-14:

- Security Defaults: <https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults>
- Microsoft Entra licensing: <https://learn.microsoft.com/en-us/entra/fundamentals/licensing>
- Authorization policy: <https://learn.microsoft.com/en-us/graph/api/resources/authorizationpolicy?view=graph-rest-1.0>
- Conditional Access policy list API: <https://learn.microsoft.com/en-us/graph/api/conditionalaccessroot-list-policies?view=graph-rest-1.0>
- SharePoint/OneDrive sharing: <https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off>
