param(
    [string]$ConfigPath = ".\config\M365_STAGE_8A_RELATIONSHIP_CRM.json",
    [string]$OutputPath = ".\inventory\stage-8a-relationship-crm\STAGE_8A_LOCAL_PREFLIGHT.md"
)

# Stage 8A - local-only Relationship CRM preflight.
# Validates the CRM config, scripts, generated packet, and module availability.
# It does not connect to Microsoft 365 or perform tenant writes.

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
        Add-Result -Results $results -Check "Stage 8A CRM config parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Stage 8A CRM config parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Stage 8A CRM config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    Add-Result -Results $results -Check "Config is Stage 8A" -Passed ([string]$config.stage -eq "8A") -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has target site URL" -Passed (-not [string]::IsNullOrWhiteSpace([string]$config.site.url)) -Detail ([string]$config.site.url)
    Add-Result -Results $results -Check "Config has six CRM Lists" -Passed (@($config.lists).Count -eq 6) -Detail ("Lists: {0}" -f @($config.lists).Count)
    Add-Result -Results $results -Check "Config has Relationship CRM page" -Passed (@($config.pages | Where-Object { [string]$_.fileName -eq "Relationship-CRM.aspx" }).Count -eq 1) -Detail (($config.pages | ForEach-Object { [string]$_.fileName }) -join "; ")
    Add-Result -Results $results -Check "Config has approval phrase" -Passed ([string]$config.approvalPhrase -eq "apply-stage-8a-relationship-crm") -Detail ([string]$config.approvalPhrase)
    Add-Result -Results $results -Check "Config has safety limits" -Passed (@($config.safetyLimits).Count -ge 9) -Detail ("Limits: {0}" -f @($config.safetyLimits).Count)
}

$requiredFiles = @(
    "M365_STAGE_8A_RELATIONSHIP_CRM_SPINE.md",
    "config\M365_STAGE_8A_RELATIONSHIP_CRM.json",
    "scripts\New-M365Stage8ARelationshipCrmPacket.ps1",
    "scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1",
    "scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8AVerifyRelationshipCrm.ps1",
    "scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1",
    "scripts\Test-M365Stage8ALocalPreflight.ps1",
    "inventory\stage-8a-relationship-crm\STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-page-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-list-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-field-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-view-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-navigation-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-workflow-map.csv",
    "inventory\stage-8a-relationship-crm\stage-8a-relationship-crm-teams-tab-later-map.csv"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\New-M365Stage8ARelationshipCrmPacket.ps1",
    "scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1",
    "scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8AVerifyRelationshipCrm.ps1",
    "scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1",
    "scripts\Test-M365Stage8ALocalPreflight.ps1"
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

$pwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
Add-Result -Results $results -Check "PowerShell 7 host available" -Passed ($null -ne $pwsh) -Detail ($(if ($null -ne $pwsh) { $pwsh.Source } else { "pwsh.exe not found" }))

$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "PnP.PowerShell module available" -Passed ($null -ne $pnp) -Detail ($(if ($null -ne $pnp) { ("{0} {1}" -f $pnp.Name, $pnp.Version) } else { "required for live CRM page/list build" }))

$pnpCommands = @("Add-PnPPage", "Add-PnPPageTextPart", "Add-PnPPageSection", "Set-PnPPage", "Get-PnPPage", "Add-PnPNavigationNode", "Get-PnPNavigationNode", "New-PnPList", "Set-PnPList", "Get-PnPList", "Add-PnPField", "Set-PnPField", "Get-PnPField", "Add-PnPView", "Get-PnPView")
foreach ($commandName in $pnpCommands) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    Add-Result -Results $results -Check ("PnP command available: {0}" -f $commandName) -Passed ($null -ne $command) -Detail ($(if ($null -ne $command) { $command.Source } else { "missing" }))
}

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8A Local Preflight")
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
$lines.Add('1. Run `.\scripts\New-M365Stage8ARelationshipCrmPacket.ps1` to regenerate the local CRM packet after config changes.')
$lines.Add('2. Run `.\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1` for a local dry-run.')
$lines.Add('3. Run `.\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply` only after approving live CRM Lists/page/navigation creation; type `apply-stage-8a-relationship-crm` in the visible window.')
$lines.Add('4. Run `.\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1` for read-only CRM read-back after live apply.')
$lines.Add('5. Defer Teams tabs until SharePoint CRM verification passes.')
$lines.Add('6. Do not create permissions, sharing, guests, app grants, public Forms, sends, deletes, Dynamics/Dataverse, or unattended automation as part of Stage 8A.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 8A local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 8A local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
