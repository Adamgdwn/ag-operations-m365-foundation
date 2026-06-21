param(
    [ValidateSet("auth", "build", "all")]
    [string]$Phase = "auth",
    [string]$Spec = ""
)

# Opens a VISIBLE Edge (via Playwright) so Adam signs in once; the Node engine
# does the building and screenshots every step into inventory/forms-build/<run>.
# Uses the same Start-Process visible-window primitive as the gated CRM apply.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
$engine = Join-Path $scriptRoot "forms-build.js"
if (-not (Test-Path -LiteralPath $engine)) { throw "Engine not found: $engine" }

$node = Get-Command "node.exe" -ErrorAction Stop
$globalModules = Join-Path $env:APPDATA "npm\node_modules"
$runStamp = "forms-{0:yyyyMMdd-HHmmss}" -f (Get-Date)

function ConvertTo-CmdArgument {
    param([string]$Argument)
    if ($Argument -match '[\s"]') { return '"' + ($Argument -replace '"', '\"') + '"' }
    return $Argument
}

$nodeArgs = @($engine, $Phase, "--run=$runStamp")
if (-not [string]::IsNullOrWhiteSpace($Spec)) { $nodeArgs += "--spec=$Spec" }

$nodeCommand = (ConvertTo-CmdArgument -Argument $node.Source) + " " + (($nodeArgs | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")

$command = @(
    "title M365 Forms Builder ($Phase)",
    "cd /d $(ConvertTo-CmdArgument -Argument $workspaceRoot)",
    "set NODE_PATH=$globalModules",
    "echo Forms builder starting. A browser window will open.",
    "echo If a Microsoft sign-in appears, complete it once - the session is remembered.",
    "echo You do not need to build anything by hand; the script drives the form.",
    $nodeCommand
) -join " && "

Write-Host "Run stamp: $runStamp" -ForegroundColor Cyan
Write-Host "Output:    inventory\forms-build\$runStamp" -ForegroundColor Gray
Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $workspaceRoot -WindowStyle Normal
Write-Host "Launched visible Forms builder window. Run stamp above." -ForegroundColor Green
