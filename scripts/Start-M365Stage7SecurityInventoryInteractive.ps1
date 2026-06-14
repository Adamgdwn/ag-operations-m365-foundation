param(
    [switch]$IncludeSharePointAdmin
)

# Opens a visible PowerShell 7 window for Stage 7 read-only security inventory.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$targetScript = Join-Path $scriptRoot "Invoke-M365Stage7SecurityInventory.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 7 read-only security inventory..." -ForegroundColor Cyan
Write-Host "Target: $targetScript" -ForegroundColor Gray
Write-Host "Tenant writes: none" -ForegroundColor Gray
if ($IncludeSharePointAdmin) {
    Write-Host "Optional SharePoint admin read-back: enabled" -ForegroundColor Gray
}

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$targetScript`""
)

if ($IncludeSharePointAdmin) {
    $arguments += "-IncludeSharePointAdmin"
}

Start-Process -FilePath $powerShellHost.Source -ArgumentList $arguments -WorkingDirectory (Split-Path -Parent $scriptRoot) -WindowStyle Normal
