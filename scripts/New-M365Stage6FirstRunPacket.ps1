param(
    [string]$OutputDirectory = ".\inventory\stage-6-operating-state\first-run-packet",
    [string]$Owner = "adamgoodwin@guidedailabs.com"
)

# Stage 6 - first-run packet generator.
# Produces local seed CSVs and a human runbook for the first agent-assisted loop.
# It does not connect to Microsoft 365 and does not write tenant data.

$ErrorActionPreference = "Stop"

function Resolve-Stage6Path {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Export-Stage6Csv {
    param(
        [string]$Path,
        [object[]]$Rows
    )

    $Rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
}

$resolvedOutputDirectory = Resolve-Stage6Path -Path $OutputDirectory
New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null

$now = Get-Date
$today = $now.ToString("yyyy-MM-dd")
$stamp = $now.ToString("yyyy-MM-dd HH:mm")

$intakePath = Join-Path $resolvedOutputDirectory "guided-ai-labs-intake-register-starter.csv"
$supportPath = Join-Path $resolvedOutputDirectory "change-leadership-tools-support-register-starter.csv"
$agentLogPath = Join-Path $resolvedOutputDirectory "agent-action-log-starter.csv"
$decisionPath = Join-Path $resolvedOutputDirectory "decision-register-starter.csv"
$runbookPath = Join-Path $resolvedOutputDirectory "STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md"

$intakeRows = @(
    [pscustomobject]@{
        Title = "[Intake] First contact@ triage test"
        SourceMailbox = "contact@"
        SourceMessageId = ""
        ReceivedDate = $today
        RequesterName = "Adam Goodwin"
        RequesterEmail = $Owner
        Organization = "Guided AI Labs"
        IntakeClass = "client-readiness"
        Priority = "Normal"
        Status = "New"
        Owner = $Owner
        NextAction = "Select one real contact@ message and draft an intake row, acknowledgement, and optional Planner task for Adam review."
        DurableHome = ""
        PlannerTaskUrl = ""
        CentralOSLink = ""
        GraphNodeId = ""
        HumanApprovalRequired = "Yes"
        AgentConfidence = ""
        AgentNotes = "Starter row from the Stage 6 first-run packet. Do not send external replies without Adam approval."
    }
)

$supportRows = @(
    [pscustomobject]@{
        Title = "[Support] Confirm support register ready"
        SourceMailbox = "support@"
        SourceMessageId = ""
        ReceivedDate = $today
        RequesterName = "Adam Goodwin"
        RequesterEmail = $Owner
        Organization = "Change Leadership Tools"
        ProductArea = "Other"
        IssueType = "Question"
        Severity = "Normal"
        Priority = "Normal"
        Status = "New"
        Owner = $Owner
        NextAction = "Confirm the support register is available before routing real support issues into it."
        ResolutionSummary = ""
        KnowledgeCandidate = "No"
        DurableHome = ""
        PlannerTaskUrl = ""
        CentralOSLink = ""
        GraphNodeId = ""
        HumanApprovalRequired = "Yes"
        AgentNotes = "Starter row from the Stage 6 first-run packet."
    }
)

$agentLogRows = @(
    [pscustomobject]@{
        Title = "Generated Stage 6 manual build guides"
        ActionDate = $today
        AgentSurface = "Codex"
        Source = ""
        ActionType = "create-record"
        Status = "Completed"
        HumanApprover = ""
        Result = "Generated schema-driven manual guides for Lists, Planner, and Teams while tenant writes remained paused."
        CentralOSLink = ""
        GraphNodeId = ""
    },
    [pscustomobject]@{
        Title = "Ran Stage 6 local preflight"
        ActionDate = $today
        AgentSurface = "Codex"
        Source = ""
        ActionType = "recommend"
        Status = "Completed"
        HumanApprover = ""
        Result = "Validated local schema, scripts, generated guides, and required modules without connecting to Microsoft 365."
        CentralOSLink = ""
        GraphNodeId = ""
    }
)

$decisionRows = @(
    [pscustomobject]@{
        Title = "Stage 6 remains human-supervised"
        DecisionDate = $today
        DecisionOwner = $Owner
        Area = "Agent"
        Decision = "Codex may prepare local artifacts, run local validation, and produce human-approved runbooks. Codex will not approve consent, bypass warnings, complete MFA, send external messages, invite guests, or make tenant-wide changes unattended."
        Rationale = "This keeps the setup genuinely agent-assisted without crossing into unsafe autonomous tenant administration."
        RevisitDate = ""
        SourceLink = ""
        CentralOSLink = ""
        GraphNodeId = ""
    }
)

Export-Stage6Csv -Path $intakePath -Rows $intakeRows
Export-Stage6Csv -Path $supportPath -Rows $supportRows
Export-Stage6Csv -Path $agentLogPath -Rows $agentLogRows
Export-Stage6Csv -Path $decisionPath -Rows $decisionRows

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 6 First Agent Loop Runbook")
$lines.Add("")
$lines.Add(("Generated: {0}" -f $stamp))
$lines.Add("")
$lines.Add("Purpose: provide a controlled first run after the Stage 6 Lists exist. This keeps the first agent-assisted workflow small, reviewable, and human-approved.")
$lines.Add("")
$lines.Add("## Preconditions")
$lines.Add("")
$lines.Add("1. The four Stage 6 Lists exist.")
$lines.Add('2. `.\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly` has passed, or Adam has manually confirmed the Lists and columns.')
$lines.Add('3. Planner/Teams setup is either deferred or built from `STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md`.')
$lines.Add("4. No consent/security/MFA/admin prompt is waiting for unattended approval.")
$lines.Add("")
$lines.Add("## Starter Files")
$lines.Add("")
$lines.Add("| File | Target | Purpose |")
$lines.Add("|---|---|---|")
$lines.Add('| `guided-ai-labs-intake-register-starter.csv` | Guided AI Labs - Intake Register | One safe starter intake row |')
$lines.Add('| `change-leadership-tools-support-register-starter.csv` | Change Leadership Tools - Support Register | One safe starter support row |')
$lines.Add('| `agent-action-log-starter.csv` | Agent Action Log | Initial Codex action log entries |')
$lines.Add('| `decision-register-starter.csv` | Decision Register | The human-supervised Stage 6 operating decision |')
$lines.Add("")
$lines.Add("## First Loop")
$lines.Add("")
$lines.Add("1. Add the Decision Register starter row.")
$lines.Add("2. Add the Agent Action Log starter rows.")
$lines.Add("3. Add the Intake starter row only if Adam wants a visible test item.")
$lines.Add('4. Select one real `contact@` message for Codex to classify.')
$lines.Add("5. Codex drafts an intake row, a proposed acknowledgement, and a Planner task only if there is a next action.")
$lines.Add("6. Adam reviews before anything external is sent or any calendar/task commitment is made.")
$lines.Add("7. Log the suggestion/outcome in Agent Action Log.")
$lines.Add("")
$lines.Add("## Boundaries")
$lines.Add("")
$lines.Add("- No autonomous external replies.")
$lines.Add("- No meeting booking without Adam approval.")
$lines.Add("- No permissions, guest access, app consent, or tenant policy changes.")
$lines.Add("- No deletion or archiving of messages in the first loop.")
$lines.Add("- No broad automation until Stage 7/9 governance is ready.")
$lines.Add("")

Set-Content -LiteralPath $runbookPath -Value $lines -Encoding UTF8
Write-Host "Stage 6 first-run packet written to: $resolvedOutputDirectory" -ForegroundColor Green
