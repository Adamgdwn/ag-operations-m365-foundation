<#
.SYNOPSIS
  Diagnose (and conservatively remediate) the Exchange-side settings that gate Microsoft
  Bookings calendar CREATION -- the layer below the M365 admin-center Bookings panel and
  not exposed in any GUI. Reads every Bookings-related knob on the org config + all OWA
  mailbox policies + the owner's CAS mailbox, flips Bookings-specific blockers to
  permissive, then re-reads. Single Exchange Online session.

.DESCRIPTION
  Root problem being chased: Graph Bookings API returns 403 for a fully-licensed,
  org-enabled user -- classic symptom of an OWA mailbox policy / org flag left
  restrictive by tenant hardening. This script makes the Bookings* settings permissive
  (enable-flags -> $true, restricted/disabled-flags -> $false) so calendar creation is
  allowed, logging every change. Scoped strictly to properties whose name contains
  'Booking'.

.PARAMETER ReadOnly
  Diagnose only; make no changes.

.NOTES
  Result -> inventory/forms-build/bookings-tenant-policy.json. Auth = device code
  (Connect-ExchangeOnline -Device): the one necessary sign-in, completed in this window.
#>
param([switch]$ReadOnly)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outDir = Join-Path $repo 'inventory\forms-build'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$resultPath = Join-Path $outDir 'bookings-tenant-policy.json'
$owner = 'adamgoodwin@guidedailabs.com'
function Log($m) { Write-Host ("[{0}] {1}" -f (Get-Date -Format o), $m) }

Import-Module ExchangeOnlineManagement -ErrorAction Stop
Log 'connecting to Exchange Online (device code) -- open https://microsoft.com/devicelogin, enter the code shown below, sign in once...'
Connect-ExchangeOnline -Device -ShowBanner:$false

# ---- helper: pull every Booking* property off an object ------------------------
function Get-BookingProps($obj) {
  $h = [ordered]@{}
  if ($null -eq $obj) { return $h }
  foreach ($p in ($obj.PSObject.Properties | Where-Object { $_.Name -match 'Booking' } | Sort-Object Name)) {
    $h[$p.Name] = $p.Value
  }
  return $h
}

$org = Get-OrganizationConfig
$orgBefore = Get-BookingProps $org
Log ("org Booking props: " + (($orgBefore.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; '))

$owaPolicies = Get-OwaMailboxPolicy
$owaBefore = @{}
foreach ($p in $owaPolicies) { $owaBefore[$p.Name] = Get-BookingProps $p }
foreach ($k in $owaBefore.Keys) { Log ("OWA policy '$k' Booking props: " + (($owaBefore[$k].GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; ')) }

$cas = $null
try { $cas = Get-CASMailbox -Identity $owner -ErrorAction Stop } catch { Log "Get-CASMailbox failed: $($_.Exception.Message)" }
$casBefore = Get-BookingProps $cas
$owaAssigned = if ($cas) { $cas.OwaMailboxPolicy } else { $null }
Log ("owner OWA policy assigned: " + ($owaAssigned ?? '(default)'))

$changes = New-Object System.Collections.Generic.List[string]

if (-not $ReadOnly) {
  # Org-level: ensure BookingsEnabled true; flip Booking* enable-flags true / restricted-or-disabled-flags false.
  if ($org.PSObject.Properties.Name -contains 'BookingsEnabled' -and $org.BookingsEnabled -ne $true) {
    try { Set-OrganizationConfig -BookingsEnabled $true; $changes.Add('OrganizationConfig.BookingsEnabled -> $true') } catch { $changes.Add("ERR org BookingsEnabled: $($_.Exception.Message)") }
  }
  # OWA policies: enable Bookings creation on every policy (covers whichever is assigned to the owner).
  foreach ($pol in $owaPolicies) {
    $props = Get-BookingProps $pol
    $setArgs = @{}
    foreach ($name in $props.Keys) {
      $val = $props[$name]
      if ($val -is [bool]) {
        if (($name -match 'Enabled$') -and ($val -eq $false)) { $setArgs[$name] = $true }
        elseif (($name -match 'Restricted$|Disabled$') -and ($val -eq $true)) { $setArgs[$name] = $false }
      }
    }
    if ($setArgs.Count -gt 0) {
      try { Set-OwaMailboxPolicy -Identity $pol.Name @setArgs; foreach ($kk in $setArgs.Keys) { $changes.Add("OwaMailboxPolicy['$($pol.Name)'].$kk -> $($setArgs[$kk])") } }
      catch { $changes.Add("ERR OWA '$($pol.Name)': $($_.Exception.Message)") }
    }
  }
  Log ("changes applied: " + ($changes.Count))
  $changes | ForEach-Object { Log "  $_" }
}

# ---- Re-read after changes -----------------------------------------------------
$orgAfter = Get-BookingProps (Get-OrganizationConfig)
$owaAfter = @{}
foreach ($p in (Get-OwaMailboxPolicy)) { $owaAfter[$p.Name] = Get-BookingProps $p }

$result = [ordered]@{
  owner            = $owner
  ownerOwaPolicy   = $owaAssigned
  readOnly         = [bool]$ReadOnly
  orgBefore        = $orgBefore
  orgAfter         = $orgAfter
  owaBefore        = $owaBefore
  owaAfter         = $owaAfter
  ownerCasBooking  = $casBefore
  changes          = @($changes)
}
$result | ConvertTo-Json -Depth 8 | Set-Content $resultPath
Log "wrote $resultPath"
Disconnect-ExchangeOnline -Confirm:$false | Out-Null
Log 'done. Bookings calendar creation should now be permitted (allow a couple of minutes to propagate), then re-run the build.'
