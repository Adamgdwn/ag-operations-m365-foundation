param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$AdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [string[]]$TargetSiteUrls = @(
        "https://agoperationsltd.sharepoint.com/",
        "https://agoperationsltd.sharepoint.com/sites/A.G.OperationsLtd",
        "https://agoperationsltd.sharepoint.com/sites/allcompany"
    ),
    [switch]$IncludeVivaEngageSystemSite,
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 7 - approval-gated site sharing exception cleanup.
# Dry-run by default. With -Apply and typed approval, it disables external
# sharing on named root/legacy SharePoint sites. It does not delete sites,
# alter memberships, invite guests, create links, or change tenant policy.

$ErrorActionPreference = "Stop"

if ($IncludeVivaEngageSystemSite) {
    $TargetSiteUrls += "https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273"
}

$TargetSiteUrls = @($TargetSiteUrls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-7-security-governance"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-7-site-sharing-exception-window-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 7 - Site Sharing Exception Window" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Admin URL:  $AdminUrl" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned site-level changes:" -ForegroundColor Cyan
foreach ($url in $TargetSiteUrls) {
    Write-Host ("- {0}: SharingCapability -> Disabled" -f $url) -ForegroundColor White
}
Write-Host ""
Write-Host "This operator does not delete sites, change site memberships, invite guests, create links, revoke app grants, send messages, or change tenant-wide sharing policy." -ForegroundColor Yellow
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to disable these site-level sharing exceptions." -ForegroundColor Green
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
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$approval = Read-Host "Type 'apply-stage-7-site-sharing-cleanup' to disable these site-level sharing exceptions"
if ($approval -ne "apply-stage-7-site-sharing-cleanup") {
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
Write-Host "Connecting to SharePoint admin endpoint..." -ForegroundColor Cyan
$connectParams = @{
    Url = $AdminUrl
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

foreach ($url in $TargetSiteUrls) {
    Write-Host ("Disabling external sharing for {0}..." -f $url) -ForegroundColor Cyan
    Set-PnPTenantSite -Url $url -SharingCapability Disabled
    Write-Host ("  [OK] {0}" -f $url) -ForegroundColor Green
}

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

Write-Host ""
Write-Host "Stage 7 site sharing exception cleanup complete. Re-run SharePoint sharing inventory for read-back verification." -ForegroundColor Green

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
