[CmdletBinding()]
param(
    [string]$PidPath = "$PSScriptRoot\http-server.pid"
)

$ErrorActionPreference = "SilentlyContinue"

$pids = @()
if (Test-Path -LiteralPath $PidPath) {
    $pids += Get-Content -Path $PidPath
}

$pids += Get-NetTCPConnection -LocalAddress 10.77.77.1 -LocalPort 8787 -State Listen |
    Select-Object -ExpandProperty OwningProcess

$pids |
    Where-Object { $_ } |
    Select-Object -Unique |
    ForEach-Object { Stop-Process -Id ([int]$_) -Force }

Remove-Item -LiteralPath $PidPath -Force
Write-Host "DirectLinkHub stopped."
