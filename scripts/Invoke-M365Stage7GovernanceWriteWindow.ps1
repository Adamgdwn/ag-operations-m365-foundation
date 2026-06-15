param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$GraphClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e",
    [string]$PnPClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SharePointAdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [ValidateSet("adminsAndGuestInviters", "adminsGuestInvitersAndAllMembers", "everyone", "none")]
    [string]$GuestInviteSetting = "adminsAndGuestInviters",
    [ValidateSet("Disabled", "ExternalUserSharingOnly", "ExternalUserAndGuestSharing", "ExistingExternalUserSharingOnly")]
    [string]$SharePointSharingCapability = "ExternalUserSharingOnly",
    [ValidateSet("None", "Direct", "Internal", "AnonymousAccess")]
    [string]$DefaultSharingLinkType = "Direct",
    [switch]$Apply,
    [switch]$SkipGraphGuestPolicy,
    [switch]$SkipSharePointTenantPolicy,
    [switch]$NoPause
)

# Stage 7 - approval-gated governance write window.
# Dry-run by default. With -Apply and typed approval, it can:
# - restrict who can invite guests in Entra;
# - tighten SharePoint tenant external sharing and default link type.
#
# It does not invite guests, create links, change site memberships, revoke app
# grants, delete records, send messages, or create calendar commitments.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw "Microsoft.Graph.Authentication is not available in this PowerShell host. Install Microsoft.Graph or run Stage 7 preflight first."
}
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns)) {
    throw "Microsoft.Graph.Identity.SignIns is not available in this PowerShell host. Install Microsoft.Graph or run Stage 7 preflight first."
}
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run Stage 7 preflight first."
}

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
Import-Module Microsoft.Graph.Identity.SignIns -ErrorAction Stop
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-7-security-governance"
New-Item -ItemType Directory -Force -Path $transcriptRoot | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-7-governance-write-window-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 7 - Governance Write Window" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned changes:" -ForegroundColor Cyan
if (-not $SkipGraphGuestPolicy) {
    Write-Host "- Entra guest invitations: allowInvitesFrom -> $GuestInviteSetting" -ForegroundColor White
}
if (-not $SkipSharePointTenantPolicy) {
    Write-Host "- SharePoint tenant sharing: SharingCapability -> $SharePointSharingCapability" -ForegroundColor White
    Write-Host "- SharePoint default link: DefaultSharingLinkType -> $DefaultSharingLinkType" -ForegroundColor White
}
Write-Host ""
Write-Host "This operator does not invite guests, create links, revoke app grants, delete records, send messages, or change calendar commitments." -ForegroundColor Yellow
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to make these tenant policy changes." -ForegroundColor Green
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

$approval = Read-Host "Type 'apply-stage-7-governance' to apply these Stage 7 tenant policy changes"
if ($approval -ne "apply-stage-7-governance") {
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

if (-not $SkipGraphGuestPolicy) {
    Write-Host ""
    Write-Host "Connecting to Microsoft Graph for authorization policy update..." -ForegroundColor Cyan
    Connect-MgGraph -ClientId $GraphClientId -TenantId $TenantId -Scopes @("User.Read", "Policy.ReadWrite.Authorization") -ContextScope Process -NoWelcome | Out-Null
    $context = Get-MgContext
    Write-Host ("Connected Graph account: {0}" -f $context.Account) -ForegroundColor Gray
    Update-MgPolicyAuthorizationPolicy -AllowInvitesFrom $GuestInviteSetting -Confirm:$false
    Write-Host "Updated Entra guest invitation policy." -ForegroundColor Green
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}

if (-not $SkipSharePointTenantPolicy) {
    Write-Host ""
    Write-Host "Connecting to SharePoint admin endpoint for tenant sharing update..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $SharePointAdminUrl -ClientId $PnPClientId -Interactive -PersistLogin
    Set-PnPTenant -SharingCapability $SharePointSharingCapability -DefaultSharingLinkType $DefaultSharingLinkType -Force
    Write-Host "Updated SharePoint tenant sharing policy." -ForegroundColor Green
    Disconnect-PnPOnline -ErrorAction SilentlyContinue | Out-Null
}

Write-Host ""
Write-Host "Stage 7 governance write window complete. Re-run read-only Stage 7 inventory for verification." -ForegroundColor Green

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
