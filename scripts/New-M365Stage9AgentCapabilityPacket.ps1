param(
    [string]$ConfigPath = ".\config\M365_STAGE_9_AGENT_CAPABILITY_MODEL.json",
    [string]$OutputDirectory = ".\inventory\stage-9-agentic-os-bridge\agent-capability"
)

# Stage 9 - local-only packet generator for the governed coordinator/support
# agent capability model. This script does not connect to Microsoft 365 and does
# not create apps, grants, mail, guests, sharing, tenant policy, or automation.

$ErrorActionPreference = "Stop"

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Add-Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Value = ""
    )

    $Lines.Add($Value)
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputDirectory = Resolve-WorkspacePath -Path $OutputDirectory

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config not found: $resolvedConfigPath"
}

New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null
$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

$guidePath = Join-Path $resolvedOutputDirectory "STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md"
$agentCsvPath = Join-Path $resolvedOutputDirectory "stage-9-agent-capability-map.csv"
$permissionCsvPath = Join-Path $resolvedOutputDirectory "stage-9-agent-permission-lanes.csv"
$gateCsvPath = Join-Path $resolvedOutputDirectory "stage-9-agent-approval-gates.csv"
$loopCsvPath = Join-Path $resolvedOutputDirectory "stage-9-first-live-loop-candidates.csv"

$lines = New-Object System.Collections.Generic.List[string]
Add-Line $lines "# Stage 9 Agent Capability Build Guide"
Add-Line $lines ""
Add-Line $lines ("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Add-Line $lines ""
Add-Line $lines "Scope: local-only capability packet. This packet does not connect to Microsoft 365, grant permissions, create apps, send mail, invite guests, change sharing, or alter tenant policy."
Add-Line $lines ""
Add-Line $lines "## Goal"
Add-Line $lines ""
Add-Line $lines "Get Guided AI Labs to a governed M365 coordinator and support agent posture where read/write capability exists only inside named lanes, evidence is recorded, and restricted actions remain approval-gated."
Add-Line $lines ""
Add-Line $lines "## Principles"
Add-Line $lines ""
foreach ($principle in @($config.principles)) {
    Add-Line $lines ("- {0}" -f $principle)
}
Add-Line $lines ""
Add-Line $lines "## Governance Levels"
Add-Line $lines ""
Add-Line $lines "| Level | Name | Approval | Description |"
Add-Line $lines "|---|---|---|---|"
foreach ($level in @($config.governanceLevels)) {
    $approval = if ($level.humanApprovalRequired) { "Required" } else { "Not required before action" }
    Add-Line $lines ("| {0} | {1} | {2} | {3} |" -f $level.id, $level.name, $approval, $level.description)
}
Add-Line $lines ""
Add-Line $lines "## Agent Capability Map"
Add-Line $lines ""
Add-Line $lines "| Agent | Initial mode | Target mode | Primary write level | Blocked actions |"
Add-Line $lines "|---|---|---|---|---|"
foreach ($agent in @($config.agents)) {
    $levels = @($agent.writeSurfaces | ForEach-Object { $_.governanceLevel } | Sort-Object -Unique) -join ", "
    $blocked = @($agent.blockedActions) -join "; "
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $agent.name, $agent.initialMode, $agent.targetMode, $levels, $blocked)
}
Add-Line $lines ""
foreach ($agent in @($config.agents)) {
    Add-Line $lines ("## {0}" -f $agent.name)
    Add-Line $lines ""
    Add-Line $lines $agent.persona
    Add-Line $lines ""
    Add-Line $lines "Read surfaces:"
    Add-Line $lines ""
    foreach ($surface in @($agent.readSurfaces)) {
        Add-Line $lines ("- {0}" -f $surface)
    }
    Add-Line $lines ""
    Add-Line $lines "| Write surface | Governance level | Allowed writes |"
    Add-Line $lines "|---|---|---|"
    foreach ($surface in @($agent.writeSurfaces)) {
        Add-Line $lines ("| {0} | {1} | {2} |" -f $surface.surface, $surface.governanceLevel, (@($surface.allowedWrites) -join "; "))
    }
    Add-Line $lines ""
}
Add-Line $lines "## Permission Lanes"
Add-Line $lines ""
Add-Line $lines "| Lane | Recommended first | Avoid as resting state | Fit | Description |"
Add-Line $lines "|---|---|---|---|---|"
foreach ($lane in @($config.permissionLanes)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $lane.lane, $lane.recommendedFirst, $lane.avoidAsRestingState, (@($lane.fit) -join "; "), $lane.description)
}
Add-Line $lines ""
Add-Line $lines "## First Live Loop Candidates"
Add-Line $lines ""
Add-Line $lines "| ID | Agent | Name | Level | Writes | Approval phrase | Exit criteria |"
Add-Line $lines "|---|---|---|---|---|---|---|"
foreach ($loop in @($config.firstLiveLoopCandidates)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $loop.id, $loop.agent, $loop.name, $loop.governanceLevel, (@($loop.writes) -join "; "), $loop.approvalPhrase, $loop.exitCriteria)
}
Add-Line $lines ""
Add-Line $lines "## Rollout Sequence"
Add-Line $lines ""
Add-Line $lines "| Step | Name | Done when |"
Add-Line $lines "|---|---|---|"
foreach ($step in @($config.rolloutSequence)) {
    Add-Line $lines ("| {0} | {1} | {2} |" -f $step.step, $step.name, $step.doneWhen)
}
Add-Line $lines ""
Add-Line $lines "## Source Notes"
Add-Line $lines ""
foreach ($source in @($config.sourceNotes)) {
    Add-Line $lines ("- {0}: {1} (checked {2})" -f $source.title, $source.url, $source.checked)
}
Add-Line $lines ""
Add-Line $lines "## Safe Next Actions"
Add-Line $lines ""
Add-Line $lines "1. Finish the Stage 8 command-center draft apply, read-only verification, and browser review."
Add-Line $lines "2. Record the Stage 9 capability decision in Decision Register and Agent Action Log."
Add-Line $lines "3. Run the first G1 coordinator loop: suggested Agent Action Log row only."
Add-Line $lines "4. Run the first G2 support loop only after support MFA is complete and Adam approves the write."
Add-Line $lines "5. Defer app registrations, consent, Exchange RBAC, and Selected permission grants to separate approval-gated operators."
Add-Line $lines ""
Add-Line $lines "Dry-run-first operator:"
Add-Line $lines ""
Add-Line $lines '```powershell'
Add-Line $lines '.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action RecordDecision'
Add-Line $lines '.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action CoordinatorSuggestion'
Add-Line $lines '.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action SupportTriage'
Add-Line $lines '```'
Add-Line $lines ""
Add-Line $lines "Apply mode requires the matching typed approval phrase and writes only to approved operating Lists."

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

$agentRows = foreach ($agent in @($config.agents)) {
    [pscustomobject]@{
        Agent = $agent.name
        ShortName = $agent.shortName
        Persona = $agent.persona
        InitialMode = $agent.initialMode
        TargetMode = $agent.targetMode
        PrimarySites = (@($agent.primarySites) -join "; ")
        Mailboxes = (@($agent.mailboxes) -join "; ")
        ReadSurfaces = (@($agent.readSurfaces) -join "; ")
        BlockedActions = (@($agent.blockedActions) -join "; ")
    }
}
$agentRows | Export-Csv -LiteralPath $agentCsvPath -NoTypeInformation -Encoding UTF8

$permissionRows = foreach ($lane in @($config.permissionLanes)) {
    [pscustomobject]@{
        Lane = $lane.lane
        RecommendedFirst = $lane.recommendedFirst
        AvoidAsRestingState = $lane.avoidAsRestingState
        Fit = (@($lane.fit) -join "; ")
        Description = $lane.description
    }
}
$permissionRows | Export-Csv -LiteralPath $permissionCsvPath -NoTypeInformation -Encoding UTF8

$gateRows = foreach ($gate in @($config.approvalGates)) {
    [pscustomobject]@{
        Action = $gate.action
        GovernanceLevel = $gate.governanceLevel
        ApprovalRequiredBeforeAction = $gate.approvalRequiredBeforeAction
        EvidenceTarget = $gate.evidenceTarget
    }
}
$gateRows | Export-Csv -LiteralPath $gateCsvPath -NoTypeInformation -Encoding UTF8

$loopRows = foreach ($loop in @($config.firstLiveLoopCandidates)) {
    [pscustomobject]@{
        Id = $loop.id
        Agent = $loop.agent
        Name = $loop.name
        GovernanceLevel = $loop.governanceLevel
        Writes = (@($loop.writes) -join "; ")
        ApprovalPhrase = $loop.approvalPhrase
        ExitCriteria = $loop.exitCriteria
    }
}
$loopRows | Export-Csv -LiteralPath $loopCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Stage 9 agent capability packet generated:" -ForegroundColor Green
Write-Host "  $guidePath" -ForegroundColor Gray
Write-Host "  $agentCsvPath" -ForegroundColor Gray
Write-Host "  $permissionCsvPath" -ForegroundColor Gray
Write-Host "  $gateCsvPath" -ForegroundColor Gray
Write-Host "  $loopCsvPath" -ForegroundColor Gray
