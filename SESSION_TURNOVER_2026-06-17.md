# Session Turnover - 2026-06-17

Canonical restart file:
[START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).

This handoff captures the local Stage 8D continuation work and the Stage 9
bridge readiness control packet. No live Microsoft 365 tenant changes were made
in this session.

## Stop Point

Stage 8D is now ready for a browser/manual functional walkthrough of the daily
Guided AI Labs operating path:

```text
New Intake -> triage -> CRM engagement -> decision -> active delivery -> handoff evidence
```

The walkthrough should start from the live Operations Cockpit, then open the CRM
Command Center. Older Relationship CRM and CRM Operations pages remain reference
surfaces only.

Follow-on local alignment on 2026-06-17: the Stage 8B verifier was updated so
the old `Client Delivery / CRM Operations` Quick Launch link is treated as
superseded by the Stage 8C `CRM Command Center` daily door. Fresh read-only
verification now passes while still checking the Stage 8B page, fields, lookups,
and views.

Stage 9 is also advanced from "supervised loops proven" to "bridge readiness
control packet generated/preflighted and live posture recorded/read-back
verified." The default posture remains supervised delegated: no production
adapter, app registration, consent grant, SharePoint Selected permission grant,
Exchange Application RBAC assignment, mail send, guest, sharing change,
permission change, tenant policy change, public Form, deletion, or unattended
automation.

Daily URLs:

```text
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Guided-AI-Labs-Operations-Cockpit.aspx
https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx
```

## What Changed

Stage 8D local artifacts were added:

```text
M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md
config/M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json
scripts/New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1
scripts/Test-M365Stage8DLocalPreflight.ps1
inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md
inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_LOCAL_PREFLIGHT.md
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-workflow-step-map.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-stop-gate-map.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-review-question-map.csv
```

The Stage 8D packet was then improved with run-capture artifacts:

```text
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv
inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv
```

The generator and preflight now validate these capture files.

Stage 9 local bridge readiness artifacts were added:

```text
config/M365_STAGE_9_BRIDGE_READINESS_CONTROL.json
scripts/New-M365Stage9BridgeReadinessControlPacket.ps1
scripts/Test-M365Stage9BridgeReadinessControlPreflight.ps1
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_PREFLIGHT.md
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-readiness-checklist.csv
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-adapter-contract.csv
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-risk-control-register.csv
inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-graduation-gates.csv
```

## Validation

Commands run:

```powershell
.\scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1
.\scripts\Test-M365Stage8DLocalPreflight.ps1
.\scripts\New-M365Stage9BridgeReadinessControlPacket.ps1
.\scripts\Test-M365Stage9BridgeReadinessControlPreflight.ps1
.\scripts\Test-M365Stage9LocalPreflight.ps1
git diff --check
```

Result:

- Stage 8D packet generation: PASS.
- Stage 8D local preflight: PASS.
- Stage 8B packet generation/local preflight/read-only verification after
  superseded-nav alignment: PASS.
- Stage 8C read-only verification rerun: PASS.
- Stage 9 bridge readiness control packet generation: PASS.
- Stage 9 bridge readiness control preflight: PASS.
- Stage 9 bridge readiness control live dry run/apply/read-back: PASS.
- Existing Stage 9 local preflight: PASS.
- `git diff --check`: no whitespace errors; only existing LF/CRLF working-copy
  warnings on markdown files.

## Exact Resume Sequence

1. Open [START_HERE_TOKEN_FRIENDLY.md](START_HERE_TOKEN_FRIENDLY.md).
2. Open the Guided AI Labs Operations Cockpit.
3. Open the CRM Command Center from the cockpit.
4. Use the Stage 8D walkthrough guide:

   ```text
   inventory/stage-8d-functional-workflow-walkthrough/STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md
   ```

5. Capture each step result and friction point:

   ```text
   inventory/stage-8d-functional-workflow-walkthrough/stage-8d-walkthrough-capture-template.csv
   inventory/stage-8d-functional-workflow-walkthrough/stage-8d-findings-register-starter.csv
   ```

6. Stop if the walkthrough requires external sharing, guest access, public
   Forms, mail sends, app grants, permission changes, deletion, real client data,
   or unattended automation.
7. Before any Stage 9 app registration, consent, Selected permission grant,
   Exchange Application RBAC change, or production adapter discussion, review:

   ```text
   inventory/stage-9-agentic-os-bridge/bridge-readiness-control/STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md
   inventory/stage-9-agentic-os-bridge/bridge-readiness-control/stage-9-app-posture-decision-worksheet.csv
   ```

8. Keep the next Stage 9 action dry-run-first and supervised delegated unless a
   new Decision Register item approves a narrower adapter lane.

## Git Note

The Stage 8D and Stage 9 bridge readiness control work was committed and pushed
on branch `codex/m365-agent-capability-bridge` as `72e175a`. Later local
follow-on changes align the Stage 8B verifier with the Stage 8C daily-door
posture and add fresh read-only verification artifacts.
