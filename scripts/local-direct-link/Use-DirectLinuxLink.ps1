[CmdletBinding()]
param(
    [ValidateSet("Status", "Shell", "Share", "Runbook", "StartHub", "StopHub", "RepairHint")]
    [string]$Action = "Status",
    [string]$DirectLinkPath = "C:\Users\adamg\DirectLink"
)

$ErrorActionPreference = "Stop"

function Invoke-DirectLinkScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptName
    )

    $scriptPath = Join-Path $DirectLinkPath $ScriptName
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw "Missing direct-link script: $scriptPath"
    }

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath
}

switch ($Action) {
    "Status" {
        Invoke-DirectLinkScript -ScriptName "Test-DirectLinuxLink.ps1"
    }
    "Shell" {
        Invoke-DirectLinkScript -ScriptName "Test-DirectLinuxLink.ps1" | Out-Host
        ssh.exe linux-direct
    }
    "Share" {
        Invoke-DirectLinkScript -ScriptName "Map-DirectLinuxShares.ps1"
        if (Test-Path -LiteralPath "X:\") {
            Start-Process -FilePath "X:\"
        } elseif (Test-Path -LiteralPath "L:\") {
            Start-Process -FilePath "L:\"
        }
    }
    "Runbook" {
        $runbook = Join-Path $DirectLinkPath "RUNBOOK.md"
        if (-not (Test-Path -LiteralPath $runbook)) {
            throw "Missing runbook: $runbook"
        }
        Start-Process -FilePath $runbook
    }
    "StartHub" {
        Invoke-DirectLinkScript -ScriptName "Start-DirectLinkHub.ps1"
    }
    "StopHub" {
        Invoke-DirectLinkScript -ScriptName "Stop-DirectLinkHub.ps1"
    }
    "RepairHint" {
        @"
Use only when SSH is not accepting the dedicated key.

1. Start the temporary Windows bootstrap hub:
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Use-DirectLinuxLink.ps1 -Action StartHub

2. On Linux, run as adamgoodwin, without sudo:
   curl -fsSL http://10.77.77.1:8787/Repair-LinuxDirectLinkUser.sh | bash

For the natural shared drive layer, Linux publishes:
   \\10.77.77.2\linux-code
   \\10.77.77.2\direct-exchange

Windows remaps the active shares with:
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Map-DirectLinuxShares.ps1

Expected drives:
   L: -> \\10.77.77.2\linux-code
   X: -> \\10.77.77.2\direct-exchange

3. Stop the temporary hub:
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\adamg\DirectLink\Use-DirectLinuxLink.ps1 -Action StopHub
"@ | Write-Host
    }
}
