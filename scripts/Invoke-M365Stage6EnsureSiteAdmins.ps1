param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$AdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [string]$RootUrl = "https://agoperationsltd.sharepoint.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [switch]$ForceFreshLogin
)

# Stage 6 - live prerequisite fix.
# Adds Adam as a secondary site collection administrator on the two Stage 6
# group-connected sites. This is intentionally narrow: it does not create Lists,
# Teams, Planner plans, guests, sharing changes, or automation.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run with PowerShell 7 on this machine."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-ensure-site-admins-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
Start-Transcript -Path $transcriptPath -Force | Out-Null

$sites = @(
    "$($RootUrl.TrimEnd('/'))/sites/ChangeLeadershipTools",
    "$($RootUrl.TrimEnd('/'))/sites/GuidedAILabs"
)

Write-Host "Microsoft 365 Stage 6 - Ensure site collection admin prerequisites" -ForegroundColor Cyan
Write-Host "Admin URL: $AdminUrl" -ForegroundColor Gray
Write-Host "Owner:     $OwnerUpn" -ForegroundColor Gray
Write-Host "Log:       $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "This will add the owner above as a SECONDARY site collection administrator on:" -ForegroundColor Yellow
foreach ($site in $sites) {
    Write-Host "- $site" -ForegroundColor White
}
Write-Host ""
Write-Host "It will NOT create Lists, Teams, Planner plans, guests, sharing changes, mailbox rules, or automation." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Type 'yes' to add this site-admin prerequisite now (anything else aborts)"
if ($confirm -ne "yes") {
    Write-Host "Aborted. Nothing was changed." -ForegroundColor Yellow
    Stop-Transcript | Out-Null
    exit 0
}

$connectParams = @{
    Url = $AdminUrl
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}

Write-Host ""
Write-Host "Connecting to SharePoint admin endpoint..." -ForegroundColor Cyan
Connect-PnPOnline @connectParams
Write-Host "Connected." -ForegroundColor Green

foreach ($site in $sites) {
    Write-Host ""
    Write-Host ("== {0} ==" -f $site) -ForegroundColor Cyan
    Set-PnPTenantSite -Identity $site -Owners @($OwnerUpn)
    Write-Host ("[OK] Ensured secondary site collection admin: {0}" -f $OwnerUpn) -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Rerun Stage 6 Lists provisioning next." -ForegroundColor Green
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Stop-Transcript | Out-Null
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
