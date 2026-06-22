<#
.SYNOPSIS
  Launch the Microsoft Bookings calendar builder in a VISIBLE console window so Adam
  can complete the one delegated sign-in (device-code) once. Mirrors the
  Start-FlowBuilder.ps1 visible-window primitive used for the CRM/Forms/flow consents.

.DESCRIPTION
  Spawns pwsh in a new window running Build-BookingsBusiness.ps1 -UseDeviceCode. The
  window prints "go to https://microsoft.com/devicelogin and enter CODE"; Adam completes
  it once, then the script builds + publishes the calendar and writes
  inventory/forms-build/bookings-result.json. The window stays open (-NoExit) so the
  device code + progress are readable.

.PARAMETER Probe
  Read-only: consent + list businesses, no writes (proves scope first).
#>
param([switch]$Probe)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $PSCommandPath
$build = Join-Path $scriptRoot 'Build-BookingsBusiness.ps1'
if (-not (Test-Path -LiteralPath $build)) { throw "Builder not found: $build" }
$pwsh = (Get-Command pwsh.exe -ErrorAction SilentlyContinue)?.Source
if (-not $pwsh) { $pwsh = (Get-Command powershell.exe).Source }

$inner = "& '$build' -UseDeviceCode" + ($(if ($Probe) { ' -Probe' } else { '' }))
$argList = @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $inner)
Start-Process -FilePath $pwsh -ArgumentList $argList -WindowStyle Normal
Write-Host "Launched visible Bookings builder window. In it: open https://microsoft.com/devicelogin, enter the shown code, sign in as adamgoodwin@guidedailabs.com, and approve once." -ForegroundColor Green
Write-Host "When it finishes it writes inventory/forms-build/bookings-result.json." -ForegroundColor Green
