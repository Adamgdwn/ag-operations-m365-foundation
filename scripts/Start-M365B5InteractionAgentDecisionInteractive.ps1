param(
    [switch]$Apply,
    [string]$ApprovalPhrase = "",
    [switch]$LocalOnly,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin
)

# Opens a visible PowerShell window for the B5 M365 Interaction Agent decision
# recorder. Apply mode writes only to Decision Register and Agent Action Log, and
# the target script still requires the exact approval phrase.

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
        "echo This B5 recorder writes only to Decision Register and Agent Action Log when apply mode is explicitly approved.",
        "echo Complete any Microsoft sign-in promptly after the next prompt appears.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $WorkingDirectory -WindowStyle Normal
}

$targetScript = Join-Path $scriptRoot "Invoke-M365B5InteractionAgentDecision.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) {
    $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
}

Write-Host "Opening visible PowerShell window for B5 Interaction Agent decision recorder..." -ForegroundColor Cyan
Write-Host ("Target: {0}" -f $targetScript) -ForegroundColor Gray
Write-Host ("Mode: {0}" -f $(if ($LocalOnly) { "LOCAL ONLY" } elseif ($Apply) { "APPLY list records" } else { "DRY RUN" })) -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $targetScript
)

if ($Apply) {
    $arguments += "-Apply"
}
if (-not [string]::IsNullOrWhiteSpace($ApprovalPhrase)) {
    $arguments += @("-ApprovalPhrase", $ApprovalPhrase)
}
if ($LocalOnly) {
    $arguments += "-LocalOnly"
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}
if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}

Start-VisiblePowerShellConsole -Title "M365 B5 Interaction Agent Decision" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot

