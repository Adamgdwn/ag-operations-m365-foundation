param(
    [string]$ConfigPath = ".\config\M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json",
    [string]$OutputDirectory = ".\inventory\stage-8d-functional-workflow-walkthrough"
)

# Stage 8D - local-only functional workflow walkthrough packet generator.
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

$guidePath = Join-Path $resolvedOutputDirectory "STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md"
$stepCsvPath = Join-Path $resolvedOutputDirectory "stage-8d-workflow-step-map.csv"
$stopGateCsvPath = Join-Path $resolvedOutputDirectory "stage-8d-stop-gate-map.csv"
$reviewCsvPath = Join-Path $resolvedOutputDirectory "stage-8d-review-question-map.csv"
$captureCsvPath = Join-Path $resolvedOutputDirectory "stage-8d-walkthrough-capture-template.csv"
$findingsCsvPath = Join-Path $resolvedOutputDirectory "stage-8d-findings-register-starter.csv"

$stepRows = foreach ($step in @($config.workflowSteps)) {
    [pscustomobject]@{
        Id = [string]$step.id
        Phase = [string]$step.phase
        SourceSurface = [string]$step.sourceSurface
        TargetSurface = [string]$step.targetSurface
        OperatorAction = [string]$step.operatorAction
        ExpectedRecord = [string]$step.expectedRecord
        EvidenceTarget = [string]$step.evidenceTarget
        Acceptance = [string]$step.acceptance
    }
}
$stepRows | Export-Csv -LiteralPath $stepCsvPath -NoTypeInformation -Encoding UTF8

$stopGateRows = foreach ($gate in @($config.stopGates)) {
    [pscustomobject]@{
        Gate = [string]$gate.gate
        Trigger = [string]$gate.trigger
        Response = [string]$gate.response
    }
}
$stopGateRows | Export-Csv -LiteralPath $stopGateCsvPath -NoTypeInformation -Encoding UTF8

$reviewRows = for ($index = 0; $index -lt @($config.reviewQuestions).Count; $index++) {
    [pscustomobject]@{
        Order = $index + 1
        Question = [string]$config.reviewQuestions[$index]
    }
}
$reviewRows | Export-Csv -LiteralPath $reviewCsvPath -NoTypeInformation -Encoding UTF8

$captureRows = foreach ($step in @($config.workflowSteps)) {
    [pscustomobject]@{
        RunDate = ""
        BrowserProfile = ""
        RecordPrefix = [string]$config.sampleScenario.recordPrefix
        StepId = [string]$step.id
        Phase = [string]$step.phase
        Outcome = ""
        RecordOrEvidenceLink = ""
        FrictionPoint = ""
        FollowUp = ""
    }
}
$captureRows | Export-Csv -LiteralPath $captureCsvPath -NoTypeInformation -Encoding UTF8

$findingsRows = foreach ($category in @($config.findingCategories)) {
    [pscustomobject]@{
        Category = [string]$category
        Severity = ""
        Surface = ""
        Finding = ""
        ProposedFix = ""
        Owner = ""
        Status = "Open"
    }
}
$findingsRows | Export-Csv -LiteralPath $findingsCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
Add-Line $lines "# Stage 8D Functional Workflow Walkthrough Guide"
Add-Line $lines ""
Add-Line $lines ("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Add-Line $lines ('Config: `{0}`' -f $resolvedConfigPath)
Add-Line $lines ""
Add-Line $lines "Scope: local-only walkthrough packet. This guide does not connect to Microsoft 365 and performs no tenant writes."
Add-Line $lines ""
Add-Line $lines "## Site"
Add-Line $lines ""
Add-Line $lines "| Field | Value |"
Add-Line $lines "|---|---|"
Add-Line $lines ("| Site | {0} |" -f $config.site.title)
Add-Line $lines ("| Site URL | {0} |" -f $config.site.url)
Add-Line $lines ("| Operations Cockpit | {0} |" -f $config.site.operationsCockpitUrl)
Add-Line $lines ("| CRM Command Center | {0} |" -f $config.site.crmCommandCenterUrl)
Add-Line $lines ""
Add-Line $lines "## Sample Scenario"
Add-Line $lines ""
Add-Line $lines ("Name: {0}" -f $config.sampleScenario.name)
Add-Line $lines ""
Add-Line $lines ('Record prefix: `{0}`' -f $config.sampleScenario.recordPrefix)
Add-Line $lines ""
Add-Line $lines $config.sampleScenario.description
Add-Line $lines ""
Add-Line $lines "Allowed data:"
Add-Line $lines ""
foreach ($item in @($config.sampleScenario.allowedData)) {
    Add-Line $lines ("- {0}" -f $item)
}
Add-Line $lines ""
Add-Line $lines "Avoid data:"
Add-Line $lines ""
foreach ($item in @($config.sampleScenario.avoidData)) {
    Add-Line $lines ("- {0}" -f $item)
}
Add-Line $lines ""
Add-Line $lines "## Safety Limits"
Add-Line $lines ""
foreach ($limit in @($config.safetyLimits)) {
    Add-Line $lines ("- {0}" -f $limit)
}
Add-Line $lines ""
Add-Line $lines "## Walkthrough Steps"
Add-Line $lines ""
Add-Line $lines "| ID | Phase | Source | Target | Acceptance |"
Add-Line $lines "|---|---|---|---|---|"
foreach ($step in @($config.workflowSteps)) {
    Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $step.id, $step.phase, $step.sourceSurface, $step.targetSurface, $step.acceptance)
}
Add-Line $lines ""
foreach ($step in @($config.workflowSteps)) {
    Add-Line $lines ("### {0} - {1}" -f $step.id, $step.phase)
    Add-Line $lines ""
    Add-Line $lines ("Action: {0}" -f $step.operatorAction)
    Add-Line $lines ""
    Add-Line $lines ("Expected record: {0}" -f $step.expectedRecord)
    Add-Line $lines ""
    Add-Line $lines ("Evidence target: {0}" -f $step.evidenceTarget)
    Add-Line $lines ""
}
Add-Line $lines "## Stop Gates"
Add-Line $lines ""
Add-Line $lines "| Gate | Trigger | Response |"
Add-Line $lines "|---|---|---|"
foreach ($gate in @($config.stopGates)) {
    Add-Line $lines ("| {0} | {1} | {2} |" -f $gate.gate, $gate.trigger, $gate.response)
}
Add-Line $lines ""
Add-Line $lines "## Review Questions"
Add-Line $lines ""
for ($index = 0; $index -lt @($config.reviewQuestions).Count; $index++) {
    Add-Line $lines ("{0}. {1}" -f ($index + 1), $config.reviewQuestions[$index])
}
Add-Line $lines ""
Add-Line $lines "## Run Capture"
Add-Line $lines ""
Add-Line $lines "Use the capture template during the browser walkthrough. Each step should end with one outcome, one evidence pointer or note, and one follow-up if anything felt unclear."
Add-Line $lines ""
Add-Line $lines "| Field | Purpose |"
Add-Line $lines "|---|---|"
foreach ($field in @($config.captureFields)) {
    Add-Line $lines ("| {0} | {1} |" -f $field.field, $field.purpose)
}
Add-Line $lines ""
Add-Line $lines "Finding categories:"
Add-Line $lines ""
foreach ($category in @($config.findingCategories)) {
    Add-Line $lines ("- {0}" -f $category)
}
Add-Line $lines ""
Add-Line $lines "## Output Files"
Add-Line $lines ""
Add-Line $lines ('- Workflow step map: `{0}`' -f $stepCsvPath)
Add-Line $lines ('- Stop gate map: `{0}`' -f $stopGateCsvPath)
Add-Line $lines ('- Review question map: `{0}`' -f $reviewCsvPath)
Add-Line $lines ('- Walkthrough capture template: `{0}`' -f $captureCsvPath)
Add-Line $lines ('- Findings register starter: `{0}`' -f $findingsCsvPath)

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8D functional workflow walkthrough packet generated:" -ForegroundColor Green
Write-Host "  $guidePath" -ForegroundColor Gray
Write-Host "  $stepCsvPath" -ForegroundColor Gray
Write-Host "  $stopGateCsvPath" -ForegroundColor Gray
Write-Host "  $reviewCsvPath" -ForegroundColor Gray
Write-Host "  $captureCsvPath" -ForegroundColor Gray
Write-Host "  $findingsCsvPath" -ForegroundColor Gray
