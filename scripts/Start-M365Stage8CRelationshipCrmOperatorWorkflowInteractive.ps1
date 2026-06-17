param(
    [switch]$Apply,
    [switch]$ForceFreshLogin
)

# Opens a visible PowerShell window for the Stage 8C CRM operator workflow apply.

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
        "echo This adds or refreshes Stage 8C CRM workflow lists, lookup columns, filtered views, command-center stage path, page, and navigation when -Apply and typed approval are used.",
        "echo Complete any Microsoft sign-in promptly after the next prompt appears.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $WorkingDirectory -WindowStyle Normal
}

$targetScript = Join-Path $scriptRoot "Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) {
    $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
}

Write-Host "Opening visible PowerShell window for Stage 8C CRM operator workflow..." -ForegroundColor Cyan
Write-Host "Target: $targetScript" -ForegroundColor Gray
Write-Host "Mode: $(if ($Apply) { 'APPLY, with typed approval required' } else { 'DRY RUN' })" -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $targetScript
)

if ($Apply) {
    $arguments += "-Apply"
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}

Start-VisiblePowerShellConsole -Title "M365 Stage 8C CRM Workflow" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
