param(
    [switch]$Apply,
    [switch]$UseDeviceCode
)

# Opens a visible PowerShell window for the New Signal Teams channel read-back or
# creation gate.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot
$targetScript = Join-Path $scriptRoot "Ensure-M365NewSignalTeamsChannel.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) {
    $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
}

function ConvertTo-Argument {
    param([string]$Value)
    if ($Value -match '[\s"]') { return '"' + ($Value -replace '"', '\"') + '"' }
    return $Value
}

$arguments = @(
    "-NoExit",
    "-ExecutionPolicy", "Bypass",
    "-File", (ConvertTo-Argument $targetScript)
)
if ($Apply) {
    $arguments += "-Apply"
}
if ($UseDeviceCode) {
    $arguments += "-UseDeviceCode"
}

Start-Process -FilePath $powerShellHost.Source -ArgumentList $arguments -WorkingDirectory $workspaceRoot -WindowStyle Normal
Write-Host "Opened visible New Signal Teams channel setup window." -ForegroundColor Green
