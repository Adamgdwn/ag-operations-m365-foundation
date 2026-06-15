param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_HOMEPAGE_REFINEMENT.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8 - approval-gated homepage refinement builder.
# Dry-run by default. With -Apply and typed approval, it creates a draft review
# page only. It does not replace the current homepage, change navigation,
# permissions, sharing, app grants, public Forms, or automation.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-8-client-workspace-reference\homepage-refinement"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-8-homepage-refinement-build-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function ConvertTo-HtmlText {
    param([string]$Value)

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function ConvertTo-HtmlList {
    param([object[]]$Items)

    $lines = foreach ($item in $Items) {
        "<li>$([System.Net.WebUtility]::HtmlEncode([string]$item))</li>"
    }

    return "<ul>$($lines -join '')</ul>"
}

function New-CommandCenterHtml {
    param([object]$Config)

    $cardRows = foreach ($card in $Config.commandCards) {
        $sources = ConvertTo-HtmlList -Items $card.futureSources
        @"
<tr>
  <td><strong>$(ConvertTo-HtmlText $card.title)</strong></td>
  <td>$(ConvertTo-HtmlText $card.statusLine)</td>
  <td>$(ConvertTo-HtmlText $card.pageTitle)</td>
  <td>$sources</td>
</tr>
"@
    }

    $activeRows = foreach ($column in $Config.activeWorkSnapshot) {
        "<tr><td><strong>$(ConvertTo-HtmlText $column.column)</strong></td><td>$(ConvertTo-HtmlText $column.purpose)</td></tr>"
    }

    $pathwayRows = foreach ($stage in $Config.clientPathwaySnapshot) {
        "<tr><td><strong>$(ConvertTo-HtmlText $stage.stage)</strong></td><td>$(ConvertTo-HtmlText $stage.toolsetDirection)</td></tr>"
    }

    $runwayRows = foreach ($phase in $Config.operationalReadiness.dashboardRunway) {
        "<tr><td><strong>$(ConvertTo-HtmlText $phase.phase)</strong></td><td>$(ConvertTo-HtmlText $phase.shape)</td><td>$(ConvertTo-HtmlText $phase.sourceCandidates)</td></tr>"
    }

    $metrics = ConvertTo-HtmlList -Items $Config.operationalReadiness.futureMetrics
    $safety = ConvertTo-HtmlList -Items $Config.safetyLimits

    return @"
<h2>$(ConvertTo-HtmlText $Config.homepage.workingTitle)</h2>
<p><strong>Purpose:</strong> $(ConvertTo-HtmlText $Config.homepage.purpose)</p>
<p><strong>Routing:</strong> $(ConvertTo-HtmlText $Config.homepage.routingDefault)</p>
<p><strong>Dashboard posture:</strong> $(ConvertTo-HtmlText $Config.homepage.cardMode)</p>

<h3>Command Cards</h3>
<table>
  <thead><tr><th>Card</th><th>Status line</th><th>Page target</th><th>Future sources</th></tr></thead>
  <tbody>
$($cardRows -join "`n")
  </tbody>
</table>

<h3>Active Work Snapshot</h3>
<table>
  <thead><tr><th>Column</th><th>Purpose</th></tr></thead>
  <tbody>
$($activeRows -join "`n")
  </tbody>
</table>

<h3>Client Pathway Snapshot</h3>
<p><strong>Flow:</strong> $((($Config.clientPathwaySnapshot | ForEach-Object { ConvertTo-HtmlText $_.stage }) -join " -&gt; "))</p>
<table>
  <thead><tr><th>Stage</th><th>Toolset direction</th></tr></thead>
  <tbody>
$($pathwayRows -join "`n")
  </tbody>
</table>

<h3>Operational Readiness</h3>
<p>$(ConvertTo-HtmlText $Config.operationalReadiness.orientation)</p>
<p><strong>Placement:</strong> $(ConvertTo-HtmlText $Config.operationalReadiness.placement)</p>
<table>
  <thead><tr><th>Phase</th><th>Dashboard shape</th><th>Source candidates</th></tr></thead>
  <tbody>
$($runwayRows -join "`n")
  </tbody>
</table>
<h4>Future metrics</h4>
$metrics

<h3>Safety Limits For This Draft</h3>
$safety
<p><em>This is a draft review page. It does not replace the current homepage. Promote only after browser review and explicit approval.</em></p>
"@
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8 - Homepage Refinement Build" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Draft page: $($config.homepage.draftFileName)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""

Write-Host "Planned homepage refinement:" -ForegroundColor Cyan
Write-Host ("- Title: {0}" -f $config.homepage.workingTitle) -ForegroundColor White
Write-Host ("- Purpose: {0}" -f $config.homepage.purpose) -ForegroundColor White
Write-Host "- Command cards:" -ForegroundColor White
foreach ($card in $config.commandCards) {
    Write-Host ("  - {0}: {1}" -f $card.title, $card.statusLine) -ForegroundColor Gray
}
Write-Host "- Active Work Snapshot:" -ForegroundColor White
foreach ($column in $config.activeWorkSnapshot) {
    Write-Host ("  - {0}" -f $column.column) -ForegroundColor Gray
}
Write-Host ("- Client Pathway: {0}" -f (($config.clientPathwaySnapshot | ForEach-Object { [string]$_.stage }) -join " -> ")) -ForegroundColor White
Write-Host ("- Operational Readiness: {0}" -f $config.operationalReadiness.placement) -ForegroundColor White
Write-Host ""
Write-Host "Safety limits: draft page only; no homepage replacement, navigation, permissions, sharing, app grants, public Forms, deletion, or automation." -ForegroundColor Yellow
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to create the draft review page." -ForegroundColor Green
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
    exit 0
}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8HomepageRefinementInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$approval = Read-Host ("Type '{0}' to create the Stage 8 command-center draft page" -f $config.approvalPhrase)
if ($approval -ne [string]$config.approvalPhrase) {
    Write-Host "Approval phrase did not match. Nothing was changed." -ForegroundColor Yellow
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
    exit 0
}

Write-Host ""
Write-Host "Connecting to Guided AI Labs SharePoint site..." -ForegroundColor Cyan
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

$existingPage = $null
try {
    $existingPage = Get-PnPPage -Identity ([string]$config.homepage.draftFileName) -ErrorAction Stop
}
catch {
    $existingPage = $null
}

if ($null -ne $existingPage) {
    Write-Host ("Draft page already exists; leaving unchanged: {0}" -f $config.homepage.draftFileName) -ForegroundColor Yellow
}
else {
    Write-Host ("Creating draft review page: {0}" -f $config.homepage.draftFileName) -ForegroundColor Cyan
    Add-PnPPage -Name ([string]$config.homepage.draftFileName) -LayoutType Article -HeaderLayoutType NoImage -CommentsEnabled:$false | Out-Null
    Add-PnPPageSection -Page ([string]$config.homepage.draftFileName) -SectionTemplate OneColumn -Order 1 | Out-Null
    Add-PnPPageTextPart -Page ([string]$config.homepage.draftFileName) -Section 1 -Column 1 -Order 1 -Text (New-CommandCenterHtml -Config $config) | Out-Null
    Set-PnPPage -Identity ([string]$config.homepage.draftFileName) -Title ([string]$config.homepage.workingTitle) -Publish | Out-Null
    Write-Host "Draft review page created and published for review." -ForegroundColor Green
}

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

Write-Host ""
Write-Host "Stage 8 homepage refinement build complete. Review the draft page before any homepage replacement or navigation change." -ForegroundColor Green

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
