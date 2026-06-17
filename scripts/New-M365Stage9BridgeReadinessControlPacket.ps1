param(
    [string]$ConfigPath = ".\config\M365_STAGE_9_BRIDGE_READINESS_CONTROL.json",
    [string]$OutputDirectory = ".\inventory\stage-9-agentic-os-bridge\bridge-readiness-control"
)

# Stage 9 - local-only bridge readiness control packet generator.
# This script does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

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

$guidePath = Join-Path $resolvedOutputDirectory "STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md"
$readinessCsvPath = Join-Path $resolvedOutputDirectory "stage-9-readiness-checklist.csv"
$adapterCsvPath = Join-Path $resolvedOutputDirectory "stage-9-adapter-contract.csv"
$postureCsvPath = Join-Path $resolvedOutputDirectory "stage-9-app-posture-decision-worksheet.csv"
$riskCsvPath = Join-Path $resolvedOutputDirectory "stage-9-risk-control-register.csv"
$gateCsvPath = Join-Path $resolvedOutputDirectory "stage-9-graduation-gates.csv"

$readinessRows = foreach ($track in @($config.readinessTracks)) {
    [pscustomobject]@{
        Track = [string]$track.track
        CurrentState = [string]$track.currentState
        RequiredEvidence = [string]$track.requiredEvidence
        DefaultStatus = [string]$track.defaultStatus
        Owner = [string]$track.owner
        ReviewNote = ""
    }
}
$readinessRows | Export-Csv -LiteralPath $readinessCsvPath -NoTypeInformation -Encoding UTF8

$adapterRows = foreach ($surface in @($config.adapterContracts)) {
    [pscustomobject]@{
        Surface = [string]$surface.surface
        SourceOfTruth = [string]$surface.sourceOfTruth
        ReadBoundary = [string]$surface.readBoundary
        WriteBoundary = [string]$surface.writeBoundary
        GovernanceLevel = [string]$surface.governanceLevel
        ApprovalGate = [string]$surface.approvalGate
        EvidenceTarget = [string]$surface.evidenceTarget
        GraduationRule = [string]$surface.graduationRule
    }
}
$adapterRows | Export-Csv -LiteralPath $adapterCsvPath -NoTypeInformation -Encoding UTF8

$postureRows = foreach ($option in @($config.appPostureOptions)) {
    [pscustomobject]@{
        Option = [string]$option.option
        RecommendedNow = [string]$option.recommendedNow
        Fit = [string]$option.fit
        Benefit = [string]$option.benefit
        Tradeoff = [string]$option.tradeoff
        DecisionNeeded = [string]$option.decisionNeeded
        Decision = ""
    }
}
$postureRows | Export-Csv -LiteralPath $postureCsvPath -NoTypeInformation -Encoding UTF8

$riskRows = foreach ($risk in @($config.riskControls)) {
    [pscustomobject]@{
        Risk = [string]$risk.risk
        Impact = [string]$risk.impact
        Control = [string]$risk.control
        Severity = [string]$risk.severity
        Owner = [string]$risk.owner
        Status = [string]$risk.status
        FollowUp = ""
    }
}
$riskRows | Export-Csv -LiteralPath $riskCsvPath -NoTypeInformation -Encoding UTF8

$gateRows = foreach ($gate in @($config.graduationGates)) {
    [pscustomobject]@{
        Gate = [string]$gate.gate
        RequiredBefore = [string]$gate.requiredBefore
        Evidence = [string]$gate.evidence
        Status = [string]$gate.status
        DecisionLink = ""
    }
}
$gateRows | Export-Csv -LiteralPath $gateCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
Add-Line $lines "# Stage 9 Bridge Readiness Control Guide"
Add-Line $lines ""
Add-Line $lines ("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Add-Line $lines ('Config: `{0}`' -f $resolvedConfigPath)
Add-Line $lines ""
Add-Line $lines "Scope: local-only readiness packet. This guide does not connect to Microsoft 365, create apps, grant consent, send mail, invite guests, change sharing, change permissions, change tenant policy, publish public forms, delete records, or run unattended automation."
Add-Line $lines ""
Add-Line $lines "## Goal"
Add-Line $lines ""
Add-Line $lines "Turn Stage 9 from proven supervised loops into a clear bridge control plane: what can stay delegated, what might become a purpose-built adapter, what evidence is required, and what remains blocked until Adam approves it."
Add-Line $lines ""
Add-Line $lines "## Current Daily Doors"
Add-Line $lines ""
Add-Line $lines "| Surface | URL |"
Add-Line $lines "|---|---|"
Add-Line $lines ("| Operations Cockpit | {0} |" -f $config.site.operationsCockpitUrl)
Add-Line $lines ("| CRM Command Center | {0} |" -f $config.site.crmCommandCenterUrl)
Add-Line $lines ""
Add-Line $lines "## Principles"
Add-Line $lines ""
foreach ($principle in @($config.principles)) {
    Add-Line $lines ("- {0}" -f $principle)
}
Add-Line $lines ""
Add-Line $lines "## Readiness Checklist"
Add-Line $lines ""
Add-Line $lines "| Track | Current state | Required evidence | Default status | Owner |"
Add-Line $lines "|---|---|---|---|---|"
foreach ($track in @($config.readinessTracks)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $track.track, $track.currentState, $track.requiredEvidence, $track.defaultStatus, $track.owner)
}
Add-Line $lines ""
Add-Line $lines "## Adapter Contract"
Add-Line $lines ""
Add-Line $lines "| Surface | Read boundary | Write boundary | Level | Evidence | Graduation rule |"
Add-Line $lines "|---|---|---|---|---|---|"
foreach ($surface in @($config.adapterContracts)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} | {5} |" -f $surface.surface, $surface.readBoundary, $surface.writeBoundary, $surface.governanceLevel, $surface.evidenceTarget, $surface.graduationRule)
}
Add-Line $lines ""
Add-Line $lines "## App Posture Decision"
Add-Line $lines ""
Add-Line $lines "| Option | Recommended now | Fit | Decision needed |"
Add-Line $lines "|---|---|---|---|"
foreach ($option in @($config.appPostureOptions)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} |" -f $option.option, $option.recommendedNow, $option.fit, $option.decisionNeeded)
}
Add-Line $lines ""
Add-Line $lines "## Risk Controls"
Add-Line $lines ""
Add-Line $lines "| Risk | Severity | Control | Owner | Status |"
Add-Line $lines "|---|---|---|---|---|"
foreach ($risk in @($config.riskControls)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $risk.risk, $risk.severity, $risk.control, $risk.owner, $risk.status)
}
Add-Line $lines ""
Add-Line $lines "## Graduation Gates"
Add-Line $lines ""
Add-Line $lines "| Gate | Required before | Evidence | Status |"
Add-Line $lines "|---|---|---|---|"
foreach ($gate in @($config.graduationGates)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} |" -f $gate.gate, $gate.requiredBefore, $gate.evidence, $gate.status)
}
Add-Line $lines ""
Add-Line $lines "## Output Files"
Add-Line $lines ""
Add-Line $lines ('- Readiness checklist: `{0}`' -f $readinessCsvPath)
Add-Line $lines ('- Adapter contract: `{0}`' -f $adapterCsvPath)
Add-Line $lines ('- App posture decision worksheet: `{0}`' -f $postureCsvPath)
Add-Line $lines ('- Risk control register: `{0}`' -f $riskCsvPath)
Add-Line $lines ('- Graduation gates: `{0}`' -f $gateCsvPath)
Add-Line $lines ""
Add-Line $lines "## Safe Next Actions"
Add-Line $lines ""
Add-Line $lines "1. Complete the Stage 8D browser/manual dummy walkthrough and fill the capture files."
Add-Line $lines "2. Review this readiness guide and worksheet before any app registration, consent, or adapter permission change."
Add-Line $lines "3. Keep the next Stage 9 action in dry-run-first supervised delegated posture."
Add-Line $lines "4. Record a Decision Register item before moving from delegated loops to any purpose-built bridge adapter."
Add-Line $lines "5. Do not reuse broad setup-helper app grants as production bridge capability."

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 9 bridge readiness control packet generated:" -ForegroundColor Green
Write-Host "  $guidePath" -ForegroundColor Gray
Write-Host "  $readinessCsvPath" -ForegroundColor Gray
Write-Host "  $adapterCsvPath" -ForegroundColor Gray
Write-Host "  $postureCsvPath" -ForegroundColor Gray
Write-Host "  $riskCsvPath" -ForegroundColor Gray
Write-Host "  $gateCsvPath" -ForegroundColor Gray
