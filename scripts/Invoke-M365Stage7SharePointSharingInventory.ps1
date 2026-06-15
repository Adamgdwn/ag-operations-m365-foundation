param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$AdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [string]$OutputRoot = ".\inventory\stage-7-security-governance",
    [string]$InventoryPath,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 7 - read-only SharePoint sharing inventory.
# Reads tenant and site sharing posture through PnP.PowerShell. It does not
# change tenant policy, site sharing, guests, links, permissions, or content.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run with PowerShell 7 on this machine."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-Stage7Path {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Export-Json {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $true)] $Data
    )

    $Data | ConvertTo-Json -Depth 30 | Out-File -FilePath $Path -Encoding utf8
}

if ([string]::IsNullOrWhiteSpace($InventoryPath)) {
    $resolvedRoot = Resolve-Stage7Path $OutputRoot
    New-Item -ItemType Directory -Force -Path $resolvedRoot | Out-Null
    $latest = Get-ChildItem -LiteralPath $resolvedRoot -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if ($null -eq $latest) {
        $script:OutputDir = Join-Path $resolvedRoot (Get-Date -Format "yyyyMMdd-HHmmss")
        New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null
    }
    else {
        $script:OutputDir = $latest.FullName
    }
}
else {
    $script:OutputDir = Resolve-Stage7Path $InventoryPath
    New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null
}

$transcriptPath = Join-Path $script:OutputDir ("stage-7-sharepoint-sharing-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 7 - SharePoint Sharing Read-Only Inventory" -ForegroundColor Cyan
Write-Host "Admin URL:     $AdminUrl" -ForegroundColor Gray
Write-Host "Output folder: $script:OutputDir" -ForegroundColor Gray
Write-Host "Tenant writes: none" -ForegroundColor Gray
Write-Host ""
Write-Host "This reads SharePoint tenant/site sharing posture only. It does not change sharing, guests, links, permissions, or content." -ForegroundColor Yellow
Write-Host ""

$connectParams = @{
    Url = $AdminUrl
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}

Write-Host "Connecting to SharePoint admin endpoint..." -ForegroundColor Cyan
Connect-PnPOnline @connectParams
Write-Host "Connected. Reading tenant and site sharing posture..." -ForegroundColor Green

$tenant = Get-PnPTenant
$sites = Get-PnPTenantSite -Detailed | Select-Object `
    Url,
    Title,
    Template,
    Owner,
    SharingCapability,
    DisableSharingForNonOwnersStatus,
    ConditionalAccessPolicy,
    LastContentModifiedDate,
    StorageUsageCurrent,
    LockState,
    GroupId,
    SensitivityLabel

Export-Json -Path (Join-Path $script:OutputDir "sharepoint-tenant.json") -Data $tenant
Export-Json -Path (Join-Path $script:OutputDir "sharepoint-sites.json") -Data $sites

Write-Host ("Saved sharepoint-tenant.json and sharepoint-sites.json ({0} site(s))." -f @($sites).Count) -ForegroundColor Green

$summarizer = Join-Path (Split-Path -Parent $PSCommandPath) "Summarize-M365Stage7SecurityInventory.ps1"
if (Test-Path -LiteralPath $summarizer) {
    Write-Host ""
    Write-Host "Running local Stage 7 summarizer..." -ForegroundColor Cyan
    & $summarizer -InventoryPath $script:OutputDir
}

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

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
