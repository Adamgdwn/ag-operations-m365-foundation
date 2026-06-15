param(
    [string]$ConfigPath = ".\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json",
    [string]$OutputPath = ".\inventory\stage-8c-relationship-crm-operator-workflow\STAGE_8C_LOCAL_PREFLIGHT.md"
)

# Stage 8C - local-only Relationship CRM operator workflow preflight.

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
        Add-Result -Results $results -Check "Stage 8C CRM operator workflow config parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Stage 8C CRM operator workflow config parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Stage 8C CRM operator workflow config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    $viewCount = ((@($config.lists | ForEach-Object { @($_.views).Count }) | Measure-Object -Sum).Sum)
    $lookupCount = ((@($config.lists | ForEach-Object { @($_.lookupFields).Count }) | Measure-Object -Sum).Sum)
    Add-Result -Results $results -Check "Config is Stage 8C" -Passed ([string]$config.stage -eq "8C") -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has target site URL" -Passed (-not [string]::IsNullOrWhiteSpace([string]$config.site.url)) -Detail ([string]$config.site.url)
    Add-Result -Results $results -Check "Config has five operator workflow lists" -Passed (@($config.lists).Count -eq 5) -Detail ("Lists: {0}" -f @($config.lists).Count)
    Add-Result -Results $results -Check "Config has workflow lookup fields" -Passed ($lookupCount -ge 12) -Detail ("Lookups: {0}" -f $lookupCount)
    Add-Result -Results $results -Check "Config has filtered workflow views" -Passed ($viewCount -ge 15) -Detail ("Views: {0}" -f $viewCount)
    Add-Result -Results $results -Check "Config has approval phrase" -Passed ([string]$config.approvalPhrase -eq "apply-stage-8c-crm-workflow") -Detail ([string]$config.approvalPhrase)
}

$requiredFiles = @(
    "M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.md",
    "config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json",
    "scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1",
    "scripts\Test-M365Stage8CLocalPreflight.ps1",
    "scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1",
    "scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1",
    "scripts\Invoke-M365Stage8CVerifyRelationshipCrmOperatorWorkflow.ps1",
    "scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

foreach ($relativeScript in @($requiredFiles | Where-Object { $_ -like "scripts\*.ps1" })) {
    $scriptPath = Join-Path $workspaceRoot $relativeScript
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed $false -Detail "missing"
        continue
    }

    $errors = Test-ScriptParse -Path $scriptPath
    Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed ($errors.Count -eq 0) -Detail ($(if ($errors.Count -eq 0) { "parse-ok" } else { ($errors | ForEach-Object { $_.Message }) -join "; " }))
}

$pwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
Add-Result -Results $results -Check "PowerShell 7 host available" -Passed ($null -ne $pwsh) -Detail ($(if ($null -ne $pwsh) { $pwsh.Source } else { "pwsh.exe not found" }))

$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "PnP.PowerShell module available" -Passed ($null -ne $pnp) -Detail ($(if ($null -ne $pnp) { ("{0} {1}" -f $pnp.Name, $pnp.Version) } else { "required for live CRM workflow apply" }))

$pnpCommands = @("Connect-PnPOnline", "Get-PnPList", "New-PnPList", "Set-PnPList", "Get-PnPField", "Add-PnPField", "Add-PnPFieldFromXml", "Set-PnPField", "Get-PnPView", "Add-PnPView", "Set-PnPView", "Add-PnPPage", "Add-PnPPageSection", "Add-PnPPageTextPart", "Set-PnPPage", "Get-PnPNavigationNode", "Add-PnPNavigationNode")
foreach ($commandName in $pnpCommands) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    Add-Result -Results $results -Check ("PnP command available: {0}" -f $commandName) -Passed ($null -ne $command) -Detail ($(if ($null -ne $command) { $command.Source } else { "missing" }))
}

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8C Relationship CRM Operator Workflow Local Preflight")
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
$lines.Add('1. Run `.\scripts\New-M365Stage8CRelationshipCrmOperatorWorkflowPacket.ps1`.')
$lines.Add('2. Run `.\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1` for a dry run.')
$lines.Add('3. Run `.\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply` after approval and type `apply-stage-8c-crm-workflow`.')
$lines.Add('4. Run `.\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1` for read-only verification.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 8C local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 8C local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
