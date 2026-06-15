# Microsoft 365 Stage 7 - Security, Governance, And External Sharing

Status: **active - core governance changes applied, verified, and logged**
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
| `scripts/Invoke-M365Stage7SecurityInventory.ps1` | Read-only Graph inventory for security/governance posture; uses Microsoft Graph browser/WAM auth by default |
| `scripts/Start-M365Stage7SecurityInventoryInteractive.ps1` | Visible launcher for Adam sign-in/MFA with a device-code fallback |
| `scripts/Invoke-M365Stage7SharePointSharingInventory.ps1` | Focused read-only PnP inventory for SharePoint tenant/site sharing posture |
| `scripts/Start-M365Stage7SharePointSharingInventoryInteractive.ps1` | Visible launcher for the focused SharePoint sharing read-back |
| `scripts/Invoke-M365Stage7GovernanceWriteWindow.ps1` | Dry-run-first, typed-approval operator for Stage 7 tenant policy changes |
| `scripts/Start-M365Stage7GovernanceWriteWindowInteractive.ps1` | Visible launcher for the Stage 7 governance write window |
| `scripts/Invoke-M365Stage7RecordGovernanceDecision.ps1` | Narrow operator that records the approved Stage 7 governance decision in Decision Register and Agent Action Log |
| `scripts/Start-M365Stage7RecordGovernanceDecisionInteractive.ps1` | Visible launcher for the Stage 7 governance decision record |
| `scripts/Invoke-M365Stage7GovernanceReviewPack.ps1` | Local-only review generator for app grants, MFA gaps, and site sharing exceptions from saved inventory |
| `scripts/Invoke-M365Stage7AppGrantRestingStatePlan.ps1` | Local-only plan generator for the broad delegated app grant resting-state decision |
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

Device-code fallback, only if browser/WAM auth fails:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -UseDeviceCode
```

Focused SharePoint tenant/site sharing read-back, using the existing PnP
tooling and the latest Stage 7 inventory folder:

```powershell
.\scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1
```

Governance write-window dry run:

```powershell
.\scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1
```

Governance write-window apply path, only after Adam explicitly approves the
batch and types the script's approval phrase:

```powershell
.\scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1 -Apply
```

Decision Register / Agent Action Log write-back for the approved Stage 7
governance batch:

```powershell
.\scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1 -Apply
```

Local-only governance review pack from saved inventory:

```powershell
.\scripts\Invoke-M365Stage7GovernanceReviewPack.ps1
```

Local-only app grant resting-state plan from saved inventory:

```powershell
.\scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1
```

Root/legacy site sharing exception dry run:

```powershell
.\scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1
```

Root/legacy site sharing exception apply path, only after Adam explicitly
approves the batch and types the script's approval phrase:

```powershell
.\scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1 -Apply
```

Legacy SharePoint admin read-back, if the SharePoint Online module is installed
and Adam is ready for a second admin auth prompt:

```powershell
.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin
```

The focused PnP read is preferred on this machine because PnP.PowerShell is
already installed and the older `Microsoft.Online.SharePoint.PowerShell` module
is not.

### 8.1 Live inventory result

Pre-change read-only Graph/SharePoint inventory was captured on 2026-06-14:

```text
inventory/stage-7-security-governance/20260614-191812
```

Post-change verification inventory was captured on 2026-06-14:

```text
inventory/stage-7-security-governance/20260614-193825
```

Current verified summary:

```text
inventory/stage-7-security-governance/20260614-193825/stage-7-security-inventory-summary.md
```

Current governance review pack:

```text
inventory/stage-7-security-governance/20260614-193825/stage-7-governance-review-pack.md
```

Current app grant resting-state plan:

```text
inventory/stage-7-security-governance/20260614-193825/stage-7-app-grant-resting-state-plan.md
```

Pre-change summary:

```text
inventory/stage-7-security-governance/20260614-191812/stage-7-security-inventory-summary.md
```

Key read-back results:

| Area | Result |
|---|---|
| Auth path | Microsoft Graph browser/WAM succeeded; device-code avoided |
| Users | 6 |
| Guest users | 0 |
| Global Administrators | 4: Adam daily, Adam admin, Break Glass 01, Break Glass 02 |
| Security Defaults | Enabled |
| Conditional Access | 0 policies read; Business Premium / Entra P1 not present |
| Guest invitations | `allowInvitesFrom = adminsAndGuestInviters` |
| Broad delegated grants | 5 flagged |
| SharePoint sharing | Tenant/site sharing read through focused PnP inventory |
| SharePoint tenant sharing | `ExternalUserSharingOnly` |
| SharePoint default sharing link | `Direct` |
| Sign-in logs | Not available through Graph because tenant lacks premium sign-in-log licensing |

Broad delegated grants flagged:

| App | Flagged scope |
|---|---|
| `agent-pnp-provisioning` | `AllSites.FullControl`, `Group.ReadWrite.All` |
| Microsoft Graph Command Line Tools | `RoleManagement.ReadWrite.Directory` |
| SharePoint Online Web Client Extensibility | `Sites.FullControl.All` |

Authentication method read-back showed Authenticator registered on Adam's daily
account, Adam admin, both break-glass accounts, and `contact@guidedailabs.com`.
`support@changeleadershiptools.com` currently shows password only and should get
an MFA method before partner/client operations depend on it.

Inventory interpretation:

- Security Defaults are already doing the free MFA baseline work. Keep them on
  for now and continue adapting automation away from brittle device-code flows.
- Guest users do not exist yet, which is ideal before Stage 8.
- Guest invitations are now restricted to admins and Guest Inviters.
- Broad setup/CLI grants need a resting-state review. The PnP provisioning app
  remains useful while build-out is active, but it should not be left as an
  unreviewed broad-write capability after Stage 7/8.
- SharePoint tenant/site external-sharing read-back is now captured. The core
  operating sites remain site-restricted, anonymous/Anyone links are no longer
  the tenant default, and authenticated external sharing remains available for
  future named exceptions.

SharePoint sharing read-back:

| Scope | Read-back |
|---|---|
| Tenant sharing capability | `ExternalUserSharingOnly` |
| Tenant default sharing link | `Direct` |
| OneDrive sharing capability | `ExternalUserSharingOnly` |
| `AGOperations` site | `Disabled` |
| `GuidedAILabs` site | `Disabled` |
| `ChangeLeadershipTools` site | `Disabled` |
| `GuidedAIJourney` site | `Disabled` |
| `SharedLibraries` site | `Disabled` |
| Root SharePoint site | `Disabled` after cleanup apply |
| A.G. Operations Ltd legacy/group site | `Disabled` after cleanup apply |
| All Company legacy/group site | `Disabled` after cleanup apply |
| Viva Engage system site | `ExternalUserSharingOnly`; do not delete, review dependency before changing |

### 8.2 Current Stage 7 decisions

| Decision | Status | Current direction |
|---|---|---|
| Security Defaults vs Conditional Access | Evidence captured | Stay on Security Defaults now; revisit Conditional Access after Business Premium / Entra P1 is available |
| Auth pattern for automation | Decided | Prefer browser/WAM Graph auth; use device-code only as fallback |
| Guest invitation rule | Applied and verified | `adminsAndGuestInviters` |
| Broad setup app resting state | Pending review | Keep only while actively building; record active reason or revoke/disable after build stage |
| SharePoint external sharing | Applied and verified | Tenant allows authenticated external sharing only; default link is `Direct`; operating sites remain disabled |
| Partner onboarding gate | Draft | No guest invite, external link, or client form distribution until the named partner/client workflow is approved |

### 8.3 Applied approval-gated changes

The following Stage 7 governance batch was applied on 2026-06-14 through the
typed-approval write window and verified through read-only inventory.

| Area | Applied change | Verified result |
|---|---|---|
| Entra guest invitations | Changed `allowInvitesFrom` from `everyone` to `adminsAndGuestInviters` | `authorization-policy.json` shows `adminsAndGuestInviters` |
| SharePoint tenant sharing | Changed tenant `SharingCapability` from `ExternalUserAndGuestSharing` to `ExternalUserSharingOnly` | `sharepoint-tenant.json` shows value `1`, summarized as `ExternalUserSharingOnly` |
| SharePoint default link | Changed default sharing link from `AnonymousAccess` to `Direct` / specific people | `sharepoint-tenant.json` shows value `1`, summarized as `Direct` |
| Operating evidence | Recorded the approved governance batch in Decision Register and Agent Action Log | Decision Register item #1 and Agent Action Log item #1 were created by `stage-7-record-governance-decision-20260614-200637.log` |
| Review pack | Generated local-only app grant, MFA, and site sharing exception review | `20260614-193825/stage-7-governance-review-pack.md` |
| App grant resting-state plan | Generated local-only grant posture table and recommended decision text | `20260614-193825/stage-7-app-grant-resting-state-plan.md`; no app grants revoked |
| Site sharing cleanup dry run | Built and ran a dry-run-first window for root/legacy site sharing exceptions | `stage-7-site-sharing-exception-window-20260614-203111.log`; no site changes applied |
| Site sharing cleanup apply | Disabled external sharing on root, A.G. Operations Ltd, and All Company sites | `stage-7-site-sharing-exception-window-20260614-210942.log`; read-back `20260614-193825/stage-7-sharepoint-sharing-20260614-211128.log` |

Remaining Stage 7 work:

| Area | Remaining action | Why |
|---|---|---|
| Root/legacy sites | Cleanup applied and read-back verified for root, A.G. Operations Ltd, and All Company; only the Viva Engage system site remains as an exception | Core operating sites and legacy/root surfaces are no longer broader by accident |
| Support mailbox identity | Add Authenticator/MFA method to `support@changeleadershiptools.com` | Keeps front-door/support identity aligned with the rest of the safety baseline |
| Broad delegated grants | Use the app grant resting-state plan to record time-boxed active setup grants; revoke/disable later only through a separate approval-gated operator | Broad setup permissions are useful now but should not become a forgotten standing capability |

Recommended sequence:

1. Add MFA to `support@changeleadershiptools.com`.
2. Record the resting state for broad delegated setup grants.
3. Decide whether the Viva Engage system site sharing exception is accepted or
   should be disabled after a dependency review.
4. Then begin Stage 8 client/partner workspace pattern work.

---

## 9. Stage Exit Criteria

Stage 7 is done when:

- read-only Stage 7 inventory is captured and summarized; **done**
- Business Premium / Entra P1 decision is recorded; **initial direction done**
- Security Defaults versus Conditional Access path is chosen; **Security Defaults now**
- external sharing default and exception process are documented; **tenant defaults tightened**
- guest invitation rule is documented; **applied and verified**
- governance write-window decision is recorded in the Decision Register; **done**
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
- SharePoint sharing capability enum: <https://learn.microsoft.com/en-us/previous-versions/office/sharepoint-csom/dn174825(v=office.15)>
