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
    "-NoExit",
    "-File", $targetScript
)

if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}
if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}

Start-VisiblePowerShellConsole -Title "M365 Stage 6 Lists" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
