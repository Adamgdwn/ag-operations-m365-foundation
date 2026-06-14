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
    "-NoExit",
    "-File", $targetScript,
    "-Action", $Action
)

if ($UseDeviceCode -or -not $UseBrowserAuth) {
    $arguments += "-UseDeviceCode"
}
if ($SkipWebTabs) {
    $arguments += "-SkipWebTabs"
}

Start-VisiblePowerShellConsole -Title "M365 Stage 6 Planner Teams" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
