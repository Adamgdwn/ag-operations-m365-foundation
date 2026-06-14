param(
    [ValidateSet("Verify", "ProvisionAndVerify", "UpdateLocal")]
    [string]$Action = "Verify",
    [switch]$UseDeviceCode,
    [switch]$UseBrowserAuth,
    [switch]$SkipWebTabs
)

# Opens a visible PowerShell 7 window for the optimized Stage 6 Planner/Teams operator.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$targetScript = Join-Path $scriptRoot "Invoke-M365Stage6PlannerTeamsOperator.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 6 Planner/Teams operator..." -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Gray
Write-Host "Target: $targetScript" -ForegroundColor Gray
if (-not $UseBrowserAuth) {
    Write-Host "Auth: device-code path will be used by default." -ForegroundColor Gray
}

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$targetScript`"",
    "-Action", $Action
)

if ($UseDeviceCode -or -not $UseBrowserAuth) {
    $arguments += "-UseDeviceCode"
}
if ($SkipWebTabs) {
    $arguments += "-SkipWebTabs"
}

Start-Process -FilePath $powerShellHost.Source -ArgumentList $arguments -WorkingDirectory (Split-Path -Parent $scriptRoot) -WindowStyle Normal
