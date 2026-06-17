param(
    [string]$ConfigPath = ".\config\M365_STAGE_9_BRIDGE_READINESS_CONTROL.json",
    [string]$OutputPath = ".\inventory\stage-9-agentic-os-bridge\bridge-readiness-control\STAGE_9_BRIDGE_READINESS_CONTROL_PREFLIGHT.md"
)

# Stage 9 - local-only preflight for the bridge readiness control packet.
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
        Add-Result -Results $results -Check "Bridge readiness config parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Bridge readiness config parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Bridge readiness config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    $principlesText = @($config.principles) -join " "
    $blockedText = ((@($config.adapterContracts) | ForEach-Object { $_.writeBoundary }) -join " ") + " " + ((@($config.riskControls) | ForEach-Object { $_.control }) -join " ")
    Add-Result -Results $results -Check "Config is Stage 9" -Passed ([string]$config.stage -eq "9") -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has readiness tracks" -Passed (@($config.readinessTracks).Count -ge 8) -Detail ("Tracks: {0}" -f @($config.readinessTracks).Count)
    Add-Result -Results $results -Check "Config has adapter contracts" -Passed (@($config.adapterContracts).Count -ge 8) -Detail ("Surfaces: {0}" -f @($config.adapterContracts).Count)
    Add-Result -Results $results -Check "Config has app posture options" -Passed (@($config.appPostureOptions).Count -ge 4) -Detail ("Options: {0}" -f @($config.appPostureOptions).Count)
    Add-Result -Results $results -Check "Config has risk controls" -Passed (@($config.riskControls).Count -ge 6) -Detail ("Risks: {0}" -f @($config.riskControls).Count)
    Add-Result -Results $results -Check "Config has graduation gates" -Passed (@($config.graduationGates).Count -ge 6) -Detail ("Gates: {0}" -f @($config.graduationGates).Count)
    Add-Result -Results $results -Check "Config rejects setup-helper production reuse" -Passed ($principlesText -match "do not reuse setup-helper" -or $blockedText -match "setup-helper") -Detail "Setup helper is excluded from production bridge posture"
    Add-Result -Results $results -Check "Config keeps external/client impact approval-gated" -Passed ($principlesText -match "External sends" -and $principlesText -match "approval-gated") -Detail "External/client actions remain gated"
}

$requiredFiles = @(
    "M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md",
    "config\M365_STAGE_9_AGENT_CAPABILITY_MODEL.json",
    "config\M365_STAGE_9_BRIDGE_READINESS_CONTROL.json",
    "scripts\New-M365Stage9AgentCapabilityPacket.ps1",
    "scripts\Test-M365Stage9LocalPreflight.ps1",
    "scripts\New-M365Stage9BridgeReadinessControlPacket.ps1",
    "scripts\Test-M365Stage9BridgeReadinessControlPreflight.ps1",
    "inventory\stage-9-agentic-os-bridge\agent-capability\STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-readiness-checklist.csv",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-adapter-contract.csv",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-app-posture-decision-worksheet.csv",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-risk-control-register.csv",
    "inventory\stage-9-agentic-os-bridge\bridge-readiness-control\stage-9-graduation-gates.csv"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\New-M365Stage9BridgeReadinessControlPacket.ps1",
    "scripts\Test-M365Stage9BridgeReadinessControlPreflight.ps1"
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
$lines.Add("# Stage 9 Bridge Readiness Control Preflight")
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
$lines.Add('1. Complete the Stage 8D browser/manual walkthrough capture before expanding CRM/List automation.')
$lines.Add('2. Review `inventory\stage-9-agentic-os-bridge\bridge-readiness-control\STAGE_9_BRIDGE_READINESS_CONTROL_GUIDE.md`.')
$lines.Add('3. Use the app posture worksheet before any app registration, consent, Selected permission grant, or Exchange Application RBAC change.')
$lines.Add('4. Keep next Stage 9 bridge work dry-run-first and supervised delegated unless a Decision Register item approves otherwise.')

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 9 bridge readiness control preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 9 bridge readiness control preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
