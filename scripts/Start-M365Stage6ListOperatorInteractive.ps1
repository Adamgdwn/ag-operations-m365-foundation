param(
    [ValidateSet("Verify", "ProvisionAndVerify", "RepairLogin", "UpdateLocal")]
    [string]$Action = "Verify",
    [switch]$UseDeviceLogin,
    [switch]$ForceFreshLogin
)

# Opens a visible PowerShell 7 window for the optimized Stage 6 Lists operator.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$targetScript = Join-Path $scriptRoot "Invoke-M365Stage6ListOperator.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 6 Lists operator..." -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Gray
Write-Host "Target: $targetScript" -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$targetScript`"",
    "-Action", $Action
)

if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}

Start-Process -FilePath $powerShellHost.Source -ArgumentList $arguments -WorkingDirectory (Split-Path -Parent $scriptRoot) -WindowStyle Normal
