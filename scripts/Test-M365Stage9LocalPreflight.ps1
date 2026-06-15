param(
    [string]$ConfigPath = ".\config\M365_STAGE_9_AGENT_CAPABILITY_MODEL.json",
    [string]$OutputPath = ".\inventory\stage-9-agentic-os-bridge\STAGE_9_LOCAL_PREFLIGHT.md"
)

# Stage 9 - local-only preflight for the governed agent capability model.
# This script does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
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

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputPath = Resolve-WorkspacePath -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

if (Test-Path -LiteralPath $resolvedConfigPath) {
    try {
        $config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Agent capability config parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Agent capability config parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Agent capability config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    $agentNames = @($config.agents | ForEach-Object { $_.name })
    Add-Result -Results $results -Check "Config is Stage 9" -Passed ($config.stage -eq 9) -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has two agent personas" -Passed (@($config.agents).Count -ge 2) -Detail ("Agents: {0}" -f (@($config.agents).Count))
    Add-Result -Results $results -Check "Config includes M365 Coordinator" -Passed ($agentNames -contains "M365 Coordinator") -Detail ($agentNames -join "; ")
    Add-Result -Results $results -Check "Config includes M365 Support Agent" -Passed ($agentNames -contains "M365 Support Agent") -Detail ($agentNames -join "; ")
    Add-Result -Results $results -Check "Config has governance levels" -Passed (@($config.governanceLevels).Count -ge 5) -Detail ("Levels: {0}" -f (@($config.governanceLevels).Count))
    Add-Result -Results $results -Check "Config has approval gates" -Passed (@($config.approvalGates).Count -gt 0) -Detail ("Gates: {0}" -f (@($config.approvalGates).Count))
    Add-Result -Results $results -Check "Config keeps broad setup grants out of target posture" -Passed (@($config.permissionLanes | Where-Object { $_.lane -eq "Broad Setup Grants" -and $_.avoidAsRestingState -eq $true }).Count -eq 1) -Detail "Broad setup grants are time-boxed only"
}

$requiredFiles = @(
    "M365_STAGE_9_AGENTIC_OS_BRIDGE_READINESS.md",
    "M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md",
    "M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md",
    "config\M365_STAGE_9_AGENT_CAPABILITY_MODEL.json",
    "scripts\New-M365Stage9AgentCapabilityPacket.ps1",
    "scripts\Invoke-M365Stage9AgentCapabilityLoop.ps1",
    "scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1",
    "scripts\Test-M365Stage9LocalPreflight.ps1",
    "inventory\stage-9-agentic-os-bridge\agent-capability\STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md",
    "inventory\stage-9-agentic-os-bridge\agent-capability\stage-9-agent-capability-map.csv",
    "inventory\stage-9-agentic-os-bridge\agent-capability\stage-9-agent-permission-lanes.csv",
    "inventory\stage-9-agentic-os-bridge\agent-capability\stage-9-agent-approval-gates.csv",
    "inventory\stage-9-agentic-os-bridge\agent-capability\stage-9-first-live-loop-candidates.csv"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\New-M365Stage9AgentCapabilityPacket.ps1",
    "scripts\Invoke-M365Stage9AgentCapabilityLoop.ps1",
    "scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1",
    "scripts\Test-M365Stage9LocalPreflight.ps1"
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
$lines.Add("# Stage 9 Local Preflight")
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
$lines.Add('1. Finish Stage 8 command-center draft apply and read-only verification.')
$lines.Add('2. Review `inventory\stage-9-agentic-os-bridge\agent-capability\STAGE_9_AGENT_CAPABILITY_BUILD_GUIDE.md`.')
$lines.Add('3. Record the coordinator/support agent scope as a Decision Register item before any new app registration or consent.')
$lines.Add('4. Dry-run the first G1/G2 live-loop operators with `.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action CoordinatorSuggestion` and `.\scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1 -Action SupportTriage`.')
$lines.Add('5. Do not reuse `agent-pnp-provisioning` as the production bridge.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 9 local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 9 local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
