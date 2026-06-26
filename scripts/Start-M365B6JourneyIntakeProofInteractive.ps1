param(
    [ValidateSet("DirectMicrosoftForm", "JourneyWebsiteCta", "ClientInviteMessage", "CustomWebsiteForm")]
    [string]$EntryPoint = "DirectMicrosoftForm",
    [string]$Marker = "GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY",
    [int]$LookbackHours = 24,
    [switch]$Verify,
    [switch]$RunTriage,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin
)

# Opens a visible PowerShell window for the B6 Guided AI Journey intake proof
# helper. The helper has no tenant write path. Verify mode reads CRM only; the
# live B6 source-ingress write is a separate manual/client-style form submission
# through the already existing create-only intake flow.

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
        "echo This B6 helper writes nothing to Microsoft 365. Verify mode reads CRM only.",
        "echo The CRM item is created only by a separate manual Journey intake submission.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $WorkingDirectory -WindowStyle Normal
}

$targetScript = Join-Path $scriptRoot "Invoke-M365B6JourneyIntakeProof.ps1"
if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Target script not found: $targetScript"
}

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) {
    $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
}

Write-Host "Opening visible PowerShell window for B6 Journey intake proof helper..." -ForegroundColor Cyan
Write-Host ("Target: {0}" -f $targetScript) -ForegroundColor Gray
Write-Host ("Entry:  {0}" -f $EntryPoint) -ForegroundColor Gray
Write-Host ("Mode:   {0}" -f $(if ($Verify) { "VERIFY read-only" } else { "LOCAL PREP" })) -ForegroundColor Gray

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $targetScript,
    "-EntryPoint", $EntryPoint,
    "-Marker", $Marker,
    "-LookbackHours", [string]$LookbackHours
)

if ($Verify) {
    $arguments += "-Verify"
}
if ($RunTriage) {
    $arguments += "-RunTriage"
}
if ($ForceFreshLogin) {
    $arguments += "-ForceFreshLogin"
}
if ($UseDeviceLogin) {
    $arguments += "-UseDeviceLogin"
}

Start-VisiblePowerShellConsole -Title "M365 B6 Journey Intake Proof" -PowerShellPath $powerShellHost.Source -Arguments $arguments -WorkingDirectory $workspaceRoot
