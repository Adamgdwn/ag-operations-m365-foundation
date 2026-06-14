param(
    [switch]$VerifyOnly,
    [switch]$ForceFreshLogin,
    [switch]$EnsureSiteAdmins,
    [switch]$UseDeviceLogin
)

# Opens a visible PowerShell window for Stage 6 Lists provisioning or read-back
# verification. Use this when Adam needs to complete Microsoft sign-in/MFA or type
# the live-write confirmation.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$targetScript = if ($EnsureSiteAdmins) {
    Join-Path $scriptRoot "Invoke-M365Stage6EnsureSiteAdmins.ps1"
}
elseif ($VerifyOnly) {
    Join-Path $scriptRoot "Invoke-M365Stage6VerifyLists.ps1"
}
else {
    Join-Path $scriptRoot "Invoke-M365Stage6ProvisionLists.ps1"
}

if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$mode = if ($EnsureSiteAdmins) { "live site-admin prerequisite" } elseif ($VerifyOnly) { "read-only verification" } else { "live Lists provisioning" }
$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 6 $mode..." -ForegroundColor Cyan
Write-Host "Target: $targetScript" -ForegroundColor Gray
Write-Host "Host:   $($powerShellHost.Source)" -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$targetScript`""
)

if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}
if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}

Start-Process -FilePath $powerShellHost.Source -ArgumentList $arguments -WorkingDirectory (Split-Path -Parent $scriptRoot)
