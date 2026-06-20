param(
    [ValidateSet("RecordDecision", "CoordinatorSuggestion", "SupportTriage", "BridgeReadinessControl")]
    [string]$Action = "RecordDecision",
    [switch]$Apply,
    [switch]$Approve,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin
)

# Opens a visible PowerShell window for the Stage 9 governed coordinator/support
# first loops. The target script is dry-run-first; live writes need one persisted
# sign-in plus a single Y confirmation (-Approve pre-confirms scripted runs).

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
        "echo This writes only to approved operating Lists when -Apply is used, after a single Y approval.",
        "echo It does not send mail, invite guests, change sharing, grant consent, alter tenant policy, delete records, or run unattended automation.",
        "echo Complete any Microsoft sign-in promptly after the next prompt appears.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $WorkingDirectory -WindowStyle Normal
}

$targetScript = Join-Path $scriptRoot "Invoke-M365Stage9AgentCapabilityLoop.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

Write-Host "Opening visible PowerShell window for Stage 9 agent capability loop..." -ForegroundColor Cyan
Write-Host "Target: $targetScript" -ForegroundColor Gray
Write-Host "Action: $Action" -ForegroundColor Gray
Write-Host "Mode: $(if ($Apply) { if ($Approve) { 'APPLY (pre-confirmed via -Approve)' } else { 'APPLY (single Y approval)' } } else { 'DRY RUN' })" -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $targetScript,
    "-Action", $Action
)

if ($Apply) {
    $arguments += "-Apply"
}
if ($Approve) {
    $arguments += "-Approve"
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}
if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}

Start-VisiblePowerShellConsole -Title "M365 Stage 9 Agent Capability Loop" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
