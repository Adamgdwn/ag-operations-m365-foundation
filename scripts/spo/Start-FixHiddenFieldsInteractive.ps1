$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function ConvertTo-CmdArgument {
    param([string]$Argument)
    if ($Argument -match '[\s"]') { return '"' + ($Argument -replace '"', '\"') + '"' }
    return $Argument
}

$targetScript = Join-Path $scriptRoot "Fix-HiddenBackboneFields.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) { throw "Target script not found: $targetScript" }

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) { $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop }

$arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-NoExit", "-File", $targetScript)
$psCmd = (ConvertTo-CmdArgument -Argument $powerShellHost.Source) + " " + (($arguments | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")
$command = @(
    "title M365 Fix Hidden Backbone Fields",
    "cd /d $(ConvertTo-CmdArgument -Argument $workspaceRoot)",
    "echo This diagnoses and fixes form-hiding of the 4 technical backbone fields.",
    "echo Complete any Microsoft sign-in promptly after the next prompt.",
    "pause",
    $psCmd
) -join " && "

Write-Host "Opening visible window for the hidden-field fix..." -ForegroundColor Cyan
Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $workspaceRoot -WindowStyle Normal
