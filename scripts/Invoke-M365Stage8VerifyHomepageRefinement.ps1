param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_HOMEPAGE_REFINEMENT.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\stage-8-client-workspace-reference\homepage-refinement",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8 - read-only command-center homepage refinement verification.
# Verifies the draft review page and checks that the current homepage was not
# replaced by the draft. It performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Test-ContainsAllMarkers {
    param(
        [string]$Text,
        [string[]]$Markers
    )

    $missing = @()
    foreach ($marker in $Markers) {
        if ($Text -notlike "*$marker*") {
            $missing += $marker
        }
    }

    return $missing
}

function Get-PageTextSnapshot {
    param([object]$Page)

    if ($null -eq $Page -or $null -eq $Page.Controls) {
        return ""
    }

    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($control in @($Page.Controls)) {
        foreach ($propertyName in @("Text", "Title", "PropertiesJson")) {
            try {
                $value = $control.$propertyName
            }
            catch {
                $value = $null
            }

            if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
                $parts.Add([string]$value)
            }
        }
    }

    return ($parts -join "`n")
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputRoot ("stage-8-homepage-refinement-verify-{0}.log" -f $timestamp)
$checkCsvPath = Join-Path $resolvedOutputRoot ("stage-8-homepage-refinement-checks-{0}.csv" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "STAGE_8_HOMEPAGE_REFINEMENT_VERIFY.md"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8 - Homepage Refinement Verification" -ForegroundColor Cyan
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Scope: read-only draft page verification." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{
    Url = [string]$config.site.url
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

$draftPage = $null
try {
    $draftPage = Get-PnPPage -Identity ([string]$config.homepage.draftFileName) -ErrorAction Stop
}
catch {
    $draftPage = $null
}

$existingHomePage = $null
try {
    $existingHomePage = Get-PnPPage -Identity ([string]$config.homepage.existingHomeFileName) -ErrorAction Stop
}
catch {
    $existingHomePage = $null
}

$currentHomePage = ""
$homePageCheckStatus = "Unknown"
$homePageDetail = "Get-PnPHomePage command not available in this PnP.PowerShell host."
if (Get-Command "Get-PnPHomePage" -ErrorAction SilentlyContinue) {
    try {
        $currentHomePage = [string](Get-PnPHomePage)
        $homePageCheckStatus = if ($currentHomePage -notlike "*$($config.homepage.draftFileName)") { "PASS" } else { "FAIL" }
        $homePageDetail = $currentHomePage
    }
    catch {
        $homePageCheckStatus = "Unknown"
        $homePageDetail = $_.Exception.Message
    }
}

$textSnapshot = Get-PageTextSnapshot -Page $draftPage
$expectedMarkers = @(
    [string]$config.homepage.workingTitle,
    "Command Cards",
    "Active Work Snapshot",
    "Client Pathway Snapshot",
    "Operational Readiness",
    "Safety Limits For This Draft"
)
$expectedMarkers += @($config.commandCards | ForEach-Object { [string]$_.title })
$missingMarkers = Test-ContainsAllMarkers -Text $textSnapshot -Markers $expectedMarkers

$checks = @(
    [pscustomobject]@{
        Check = "Draft page exists"
        Status = if ($null -ne $draftPage) { "PASS" } else { "MISSING" }
        Detail = [string]$config.homepage.draftFileName
    },
    [pscustomobject]@{
        Check = "Draft page title matches"
        Status = if ($null -ne $draftPage -and [string]$draftPage.PageTitle -eq [string]$config.homepage.workingTitle) { "PASS" } elseif ($null -eq $draftPage) { "MISSING" } else { "FAIL" }
        Detail = if ($null -ne $draftPage) { [string]$draftPage.PageTitle } else { "" }
    },
    [pscustomobject]@{
        Check = "Draft page contains expected command-center markers"
        Status = if ($null -eq $draftPage) { "MISSING" } elseif ($missingMarkers.Count -eq 0) { "PASS" } else { "PARTIAL" }
        Detail = if ($missingMarkers.Count -eq 0) { "all expected markers found" } else { ($missingMarkers -join "; ") }
    },
    [pscustomobject]@{
        Check = "Existing home page still exists"
        Status = if ($null -ne $existingHomePage) { "PASS" } else { "MISSING" }
        Detail = [string]$config.homepage.existingHomeFileName
    },
    [pscustomobject]@{
        Check = "Current homepage is not the draft page"
        Status = $homePageCheckStatus
        Detail = $homePageDetail
    },
    [pscustomobject]@{
        Check = "Draft and existing homepage filenames are distinct"
        Status = if ([string]$config.homepage.draftFileName -ne [string]$config.homepage.existingHomeFileName) { "PASS" } else { "FAIL" }
        Detail = ("Draft: {0}; Existing: {1}" -f $config.homepage.draftFileName, $config.homepage.existingHomeFileName)
    }
)

$checks | Export-Csv -LiteralPath $checkCsvPath -NoTypeInformation -Encoding UTF8

$failed = @($checks | Where-Object { $_.Status -in @("FAIL", "MISSING", "PARTIAL") })
$unknown = @($checks | Where-Object { $_.Status -eq "Unknown" })
$result = if ($failed.Count -eq 0 -and $unknown.Count -eq 0) { "PASS" } elseif ($failed.Count -eq 0) { "PASS-WITH-UNKNOWN" } else { "PARTIAL" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Homepage Refinement Verification")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add(("Result: {0}" -f $result))
$lines.Add("")
$lines.Add(("Site: {0}" -f $config.site.url))
$lines.Add(("Draft page: {0}" -f $config.homepage.draftFileName))
$lines.Add(("Existing homepage file: {0}" -f $config.homepage.existingHomeFileName))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
$lines.Add(("Check CSV: {0}" -f $checkCsvPath))
$lines.Add("")
$lines.Add("Scope: read-only verification. This script does not replace the homepage, change navigation, permissions, sharing, guests, app grants, public Forms, deletion, or automation.")
$lines.Add("")
$lines.Add("| Status | Check | Detail |")
$lines.Add("|---|---|---|")
foreach ($check in $checks) {
    $detail = ([string]$check.Detail) -replace "\|", "\|"
    $lines.Add(("| {0} | {1} | {2} |" -f $check.Status, $check.Check, $detail))
}
$lines.Add("")
$lines.Add("Next step if PASS: browser-review the draft page with Adam before any separate homepage promotion operator is created or run.")
$lines.Add("")

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

$resultColor = if ($result -eq "PASS") { "Green" } elseif ($result -eq "PASS-WITH-UNKNOWN") { "Yellow" } else { "Yellow" }
Write-Host ("Stage 8 homepage refinement verification {0}: {1}" -f $result, $summaryPath) -ForegroundColor $resultColor

try {
    Stop-Transcript | Out-Null
}
catch {
}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
