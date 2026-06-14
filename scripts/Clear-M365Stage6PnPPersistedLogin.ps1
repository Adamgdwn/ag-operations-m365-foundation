param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl = "https://agoperationsltd.sharepoint.com"
)

# Stage 6 - clear persisted PnP login for the provisioning app.
# This does not write tenant content. It connects using the currently cached
# account, then clears that persisted token cache entry so the next run can pick
# the correct user.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run with PowerShell 7 on this machine."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$siteUrl = "$($RootUrl.TrimEnd('/'))/sites/GuidedAILabs"

Write-Host "Microsoft 365 Stage 6 - clear PnP persisted login" -ForegroundColor Cyan
Write-Host "Site: $siteUrl" -ForegroundColor Gray
Write-Host "No tenant content will be changed." -ForegroundColor Yellow

try {
    Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -Interactive -PersistLogin
    $connection = Get-PnPConnection
    Write-Host ("Connected using {0}; clearing persisted token cache entry." -f $connection.ConnectionType) -ForegroundColor Gray
}
catch {
    Write-Host ("Connect before clear failed: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

try {
    Disconnect-PnPOnline -ClearPersistedLogin
    Write-Host "PnP persisted login cleared for the current connection." -ForegroundColor Green
}
catch {
    Write-Host ("Clear persisted login failed: {0}" -f $_.Exception.Message) -ForegroundColor Red
    throw
}
