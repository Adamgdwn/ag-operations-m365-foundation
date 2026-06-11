param(
    [string]$ApplicationName = "agent-pnp-provisioning",
    [string]$Tenant          = "AGOperationsLtd.onmicrosoft.com"
)

# Stage 3 - SharePoint Information Architecture : register the PnP provisioning app.
# FIRST LIVE WRITE of Stage 3 (decision 3.6b). PnP.PowerShell 3.x ships NO shared
# sign-in app, so Connect-PnPOnline needs our own Entra app registration. This script
# creates ONE dedicated, clearly-named app with DELEGATED ("act-as-Adam") permissions
# and walks you through admin consent in the browser. Nothing in SharePoint is created
# here - this only registers the app we will later authenticate through.
#
# Reversible: to undo, delete the "agent-pnp-provisioning" app registration in Entra
# (entra.microsoft.com -> App registrations) - no tenant content is touched.
#
# Delegated scopes requested (least-privilege for the agreed build):
#   SharePoint : AllSites.FullControl   (create sites, libraries, columns, folders)
#   Graph      : Group.ReadWrite.All    (the two group-connected Team sites - 3.2c)
#   Graph      : User.Read              (sign-in)
#
# Plan + decisions: M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md (see decision log + §8 log)

$ErrorActionPreference = "Stop"

Write-Host "Microsoft 365 Stage 3 - Register PnP provisioning app" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will CREATE one Entra app registration named:" -ForegroundColor Yellow
Write-Host "    $ApplicationName" -ForegroundColor White
Write-Host "in tenant $Tenant, with the DELEGATED permissions listed above." -ForegroundColor Yellow
Write-Host "A browser window will open twice: once to sign in and create the app," -ForegroundColor Yellow
Write-Host "then again to grant admin consent. Sign in as adamgoodwin@guidedailabs.com" -ForegroundColor Yellow
Write-Host "(a Global Administrator)." -ForegroundColor Yellow
Write-Host ""
Write-Host "Nothing in SharePoint is created by this step - it only registers the app." -ForegroundColor Green
Write-Host ""

# --- Preflight: module present? ---
$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
if ($null -eq $pnp) {
    Write-Host "PnP.PowerShell is not installed. Install with:" -ForegroundColor Red
    Write-Host "    Install-Module PnP.PowerShell -Scope CurrentUser" -ForegroundColor White
    exit 1
}
Write-Host ("Using PnP.PowerShell {0}" -f $pnp.Version) -ForegroundColor Gray
Write-Host ""

# --- Typed confirmation gate (this is a live write) ---
$confirm = Read-Host "Type 'yes' to register the app now (anything else aborts)"
if ($confirm -ne "yes") {
    Write-Host "Aborted. No app was created." -ForegroundColor Yellow
    exit 0
}

Import-Module PnP.PowerShell

Write-Host ""
Write-Host "Registering the app and requesting consent (follow the browser prompts)..." -ForegroundColor Cyan

$app = Register-PnPEntraIDAppForInteractiveLogin `
    -ApplicationName $ApplicationName `
    -Tenant $Tenant `
    -SharePointDelegatePermissions "AllSites.FullControl" `
    -GraphDelegatePermissions "Group.ReadWrite.All", "User.Read" `
    -Interactive

Write-Host ""
Write-Host "[OK] App registration complete." -ForegroundColor Green
Write-Host ""
Write-Host "Record this Client (Application) ID - the next step uses it to connect:" -ForegroundColor Yellow
Write-Host ("    ClientId : {0}" -f $app."AzureAppId/ClientId") -ForegroundColor White
if ($app.'Certificate Thumbprint') {
    Write-Host ("    Cert thumbprint : {0}" -f $app.'Certificate Thumbprint') -ForegroundColor Gray
}
Write-Host ""
Write-Host "Next: provision the AG Operations pilot site with this ClientId via" -ForegroundColor Cyan
Write-Host "Connect-PnPOnline -Interactive. See M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md." -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
