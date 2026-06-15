param(
    [string]$InventoryPath,
    [switch]$ForceFreshLogin
)

# Opens a visible PowerShell 7 window for Stage 7 read-only SharePoint sharing inventory.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot

function ConvertTo-CmdArgument {
    param([string]$Argument)

    if ($Argument -match '[\s"]') {
        return '"' + ($Argument -replace '"', '\"') + '"'
    }

    return $Argument
}

function Start-VisiblePowerShellConsole {
    param(
        [string]$Title,
        [string]$PowerShellPath,
        [string[]]$Arguments,
        [string]$WorkingDirectory
    )

    $powerShellCommand = (ConvertTo-CmdArgument -Argument $PowerShellPath) + " " + (($Arguments | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")
    $command = @(
        "title $Title",
        "cd /d $(ConvertTo-CmdArgument -Argument $WorkingDirectory)",
        "echo Ready to start $Title.",
        "echo Complete any Microsoft sign-in promptly after the next prompt appears.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $WorkingDirectory -WindowStyle Normal
}

$targetScript = Join-Path $scriptRoot "Invoke-M365Stage7SharePointSharingInventory.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 7 SharePoint sharing inventory..." -ForegroundColor Cyan
Write-Host "Target: $targetScript" -ForegroundColor Gray
Write-Host "Tenant writes: none" -ForegroundColor Gray
if ($InventoryPath) {
    Write-Host "Inventory path: $InventoryPath" -ForegroundColor Gray
}

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $targetScript
)

if ($InventoryPath) {
    $arguments += @("-InventoryPath", $InventoryPath)
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}

Start-VisiblePowerShellConsole -Title "M365 Stage 7 SharePoint Sharing" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
