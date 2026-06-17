param(
    [string]$ConfigPath = ".\config\M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json",
    [string]$OutputPath = ".\inventory\stage-8d-functional-workflow-walkthrough\STAGE_8D_LOCAL_PREFLIGHT.md"
)

# Stage 8D - local-only preflight for the functional workflow walkthrough.
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

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Results,
        [string]$Check,
        [bool]$Passed,
        [string]$Detail
    )

    $Results.Add([pscustomobject]@{
        Check = $Check
        Passed = $Passed
        Detail = $Detail
    })
}

function Test-ScriptParse {
    param([string]$Path)

    $parseErrors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw -LiteralPath $Path), [ref]$parseErrors)
    return @($parseErrors)
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputPath = Resolve-WorkspacePath -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

if (Test-Path -LiteralPath $resolvedConfigPath) {
    try {
        $config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Stage 8D config parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Stage 8D config parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Stage 8D config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    Add-Result -Results $results -Check "Config is Stage 8D" -Passed ([string]$config.stage -eq "8D") -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has Operations Cockpit URL" -Passed (-not [string]::IsNullOrWhiteSpace([string]$config.site.operationsCockpitUrl)) -Detail ([string]$config.site.operationsCockpitUrl)
    Add-Result -Results $results -Check "Config has CRM Command Center URL" -Passed (-not [string]::IsNullOrWhiteSpace([string]$config.site.crmCommandCenterUrl)) -Detail ([string]$config.site.crmCommandCenterUrl)
    Add-Result -Results $results -Check "Config has seven workflow steps" -Passed (@($config.workflowSteps).Count -eq 7) -Detail ("Steps: {0}" -f @($config.workflowSteps).Count)
    Add-Result -Results $results -Check "Config has stop gates" -Passed (@($config.stopGates).Count -ge 4) -Detail ("Stop gates: {0}" -f @($config.stopGates).Count)
    Add-Result -Results $results -Check "Config has review questions" -Passed (@($config.reviewQuestions).Count -ge 5) -Detail ("Questions: {0}" -f @($config.reviewQuestions).Count)
    Add-Result -Results $results -Check "Config has capture fields" -Passed (@($config.captureFields).Count -ge 8) -Detail ("Capture fields: {0}" -f @($config.captureFields).Count)
    Add-Result -Results $results -Check "Config has finding categories" -Passed (@($config.findingCategories).Count -ge 5) -Detail ("Finding categories: {0}" -f @($config.findingCategories).Count)
    Add-Result -Results $results -Check "Config blocks tenant-write automation" -Passed ((@($config.safetyLimits) -join " ") -match "No tenant writes") -Detail "Stage 8D scripts are local-only"
}

$requiredFiles = @(
    "M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.md",
    "config\M365_STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH.json",
    "scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1",
    "scripts\Test-M365Stage8DLocalPreflight.ps1",
    "scripts\Invoke-M365Stage8DWorkflowProof.ps1",
    "inventory\stage-8d-functional-workflow-walkthrough\STAGE_8D_FUNCTIONAL_WORKFLOW_WALKTHROUGH_GUIDE.md",
    "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-workflow-step-map.csv",
    "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-stop-gate-map.csv",
    "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-review-question-map.csv",
    "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-walkthrough-capture-template.csv",
    "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-findings-register-starter.csv"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\New-M365Stage8DFunctionalWorkflowWalkthroughPacket.ps1",
    "scripts\Test-M365Stage8DLocalPreflight.ps1",
    "scripts\Invoke-M365Stage8DWorkflowProof.ps1"
)

foreach ($relativeScript in $requiredScripts) {
    $scriptPath = Join-Path $workspaceRoot $relativeScript
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed $false -Detail "missing"
        continue
    }

    $errors = Test-ScriptParse -Path $scriptPath
    Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed ($errors.Count -eq 0) -Detail ($(if ($errors.Count -eq 0) { "parse-ok" } else { ($errors | ForEach-Object { $_.Message }) -join "; " }))
}

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8D Functional Workflow Walkthrough Local Preflight")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add("Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add(("Result: {0}" -f ($(if ($failed.Count -eq 0) { "PASS" } else { "FAIL" }))))
$lines.Add("")
$lines.Add("| Status | Check | Detail |")
$lines.Add("|---|---|---|")
foreach ($result in $results) {
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $detail = ([string]$result.Detail) -replace "\|", "\|"
    $lines.Add(("| {0} | {1} | {2} |" -f $status, $result.Check, $detail))
}
$lines.Add("")
$lines.Add("Next safe actions:")
$lines.Add("")
$lines.Add('1. Open the Guided AI Labs Operations Cockpit in Adam''s browser profile.')
$lines.Add('2. Open the CRM Command Center from the cockpit.')
$lines.Add('3. Inspect the Stage 8D proof read-back before creating another internal dummy path.')
$lines.Add('4. Fill the walkthrough capture template and findings register with any remaining browser confusion points before creating Teams tabs or more automation.')

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 8D local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 8D local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
