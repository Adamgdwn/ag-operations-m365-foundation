param(
    [ValidateSet("auth", "connections", "build")]
    [string]$Phase = "auth"
)

# Surfaces a VISIBLE Edge (via Playwright) to Adam's desktop so he signs into
# Power Automate ONCE. Same Start-Process visible-window primitive as the gated
# CRM apply + the Forms builder. The "auth" phase persists the session and runs
# the read-only environment/connection discovery in the same sign-in.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
$engine = switch ($Phase) {
    "auth" { Join-Path $scriptRoot "auth-flow.js" }
    "connections" { Join-Path $scriptRoot "create-connections.js" }
    default { Join-Path $scriptRoot "create-flow.js" }
}
if (-not (Test-Path -LiteralPath $engine)) { throw "Engine not found: $engine" }

$node = Get-Command "node.exe" -ErrorAction Stop
$globalModules = Join-Path $env:APPDATA "npm\node_modules"

function ConvertTo-CmdArgument {
    param([string]$Argument)
    if ($Argument -match '[\s"]') { return '"' + ($Argument -replace '"', '\"') + '"' }
    return $Argument
}

$engineArgs = @($engine)
if ($Phase -eq "connections") { $engineArgs += "--headed" }
$nodeCommand = (ConvertTo-CmdArgument -Argument $node.Source) + " " + (($engineArgs | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")

$command = @(
    "title M365 Flow Builder ($Phase)",
    "cd /d $(ConvertTo-CmdArgument -Argument $workspaceRoot)",
    "set NODE_PATH=$globalModules",
    "echo Flow builder starting. A browser window will open to Power Automate.",
    "echo If a Microsoft sign-in or consent appears, complete it once - it is remembered.",
    "echo You do not need to build anything by hand; the script drives the flow.",
    $nodeCommand
) -join " && "

Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $workspaceRoot -WindowStyle Normal
Write-Host "Launched visible Flow builder window ($Phase). Complete any sign-in once." -ForegroundColor Green
