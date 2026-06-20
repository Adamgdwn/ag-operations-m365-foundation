[CmdletBinding()]
param(
    [string]$HubScript = "$PSScriptRoot\DirectLinkHub.py",
    [string]$PidPath = "$PSScriptRoot\http-server.pid"
)

$ErrorActionPreference = "Stop"

$existing = Get-NetTCPConnection -LocalAddress 10.77.77.1 -LocalPort 8787 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($existing) {
    $existing.OwningProcess | Set-Content -Path $PidPath
    Write-Host "DirectLinkHub already listening on 10.77.77.1:8787 with PID $($existing.OwningProcess)."
    exit 0
}

$python = (Get-Command python.exe -ErrorAction Stop).Source
$out = Join-Path $PSScriptRoot "hub.out.log"
$err = Join-Path $PSScriptRoot "hub.err.log"
$process = Start-Process `
    -FilePath $python `
    -ArgumentList @($HubScript) `
    -WorkingDirectory $PSScriptRoot `
    -WindowStyle Hidden `
    -RedirectStandardOutput $out `
    -RedirectStandardError $err `
    -PassThru

$process.Id | Set-Content -Path $PidPath
Start-Sleep -Seconds 2

Write-Host "DirectLinkHub started on http://10.77.77.1:8787/ with PID $($process.Id)."
