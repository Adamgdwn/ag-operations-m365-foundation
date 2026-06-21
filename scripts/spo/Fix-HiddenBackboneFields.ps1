param(
    [string]$ConfigDir = ".\config",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$NoPause
)

# Hide the 4 hidden backbone technical fields on CRM - New Signals, reliably.
#
# The apply's ShowInNewForm/ShowInEditForm setter (and a SchemaXml-string write)
# reported success but did NOT persist on this list. For pure-technical foreign
# keys the correct, bulletproof mechanism is Hidden=$true: the field is removed
# from every form AND view, yet remains fully writable by the sync flow via its
# internal name. This script sets Hidden=$true, READS THE SCHEMA BACK, prints a
# per-field result, and writes inventory/crm-verify/hidden-fields-fix.json so the
# outcome is recorded (no dependence on the console window staying open).
#
# Writes only field visibility (Hidden + form flags). No data, permissions, deletes.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
function Resolve-WorkspacePath { param([string]$Path) if ([System.IO.Path]::IsPathRooted($Path)) { return $Path } return (Join-Path $workspaceRoot $Path) }

$resolvedConfigDir = Resolve-WorkspacePath -Path $ConfigDir
$spConfig = Get-Content -LiteralPath (Join-Path $resolvedConfigDir "crm.sharepoint.json") -Raw | ConvertFrom-Json
$contract = Get-Content -LiteralPath (Join-Path $resolvedConfigDir "followup.contract.json") -Raw | ConvertFrom-Json
$siteUrl = [string]$spConfig.site.url
$listTitle = "CRM - New Signals"
$fields = @($contract.hiddenTechnicalColumns | ForEach-Object { [string]$_ })

$outDir = Resolve-WorkspacePath -Path ".\inventory\crm-verify"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$resultPath = Join-Path $outDir "hidden-fields-fix.json"

Write-Host "Hide backbone technical fields on $listTitle (Hidden=true)" -ForegroundColor Cyan
Write-Host ("Fields: {0}" -f ($fields -join ", ")) -ForegroundColor Gray
Write-Host ""

Import-Module PnP.PowerShell -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -Interactive -PersistLogin

function Read-FieldState {
    param([string]$Name)
    $f = Get-PnPField -List $listTitle -Identity $Name -Includes SchemaXml, Hidden -ErrorAction SilentlyContinue
    if ($null -eq $f) { return $null }
    $x = [xml]([string]$f.SchemaXml)
    [pscustomobject]@{
        ShowInNewForm  = if ([string]::IsNullOrWhiteSpace([string]$x.Field.ShowInNewForm)) { "DefaultTrue" } else { [string]$x.Field.ShowInNewForm }
        ShowInEditForm = if ([string]::IsNullOrWhiteSpace([string]$x.Field.ShowInEditForm)) { "DefaultTrue" } else { [string]$x.Field.ShowInEditForm }
        Hidden         = [bool]$f.Hidden
    }
}

$results = @()
foreach ($name in $fields) {
    Write-Host ("--- {0} ---" -f $name) -ForegroundColor Cyan
    $before = Read-FieldState -Name $name
    if ($null -eq $before) { Write-Host "  field not found, skipping" -ForegroundColor Yellow; continue }
    Write-Host ("  before: Hidden={0} ShowInNewForm={1} ShowInEditForm={2}" -f $before.Hidden, $before.ShowInNewForm, $before.ShowInEditForm) -ForegroundColor Gray

    try {
        $f = Get-PnPField -List $listTitle -Identity $name
        $f.Hidden = $true
        $f.SetShowInNewForm($false); $f.SetShowInEditForm($false)
        $f.Update()
        (Get-PnPContext).ExecuteQuery()
    } catch { Write-Host ("  [warn] {0}" -f $_.Exception.Message) -ForegroundColor Yellow }

    $after = Read-FieldState -Name $name
    $pass = ($after.Hidden) -or (($after.ShowInNewForm -match 'FALSE') -and ($after.ShowInEditForm -match 'FALSE'))
    $color = if ($pass) { "Green" } else { "Red" }
    Write-Host ("  FINAL: Hidden={0} ShowInNewForm={1} ShowInEditForm={2}  => {3}" -f $after.Hidden, $after.ShowInNewForm, $after.ShowInEditForm, $(if($pass){"HIDDEN"}else{"STILL VISIBLE"})) -ForegroundColor $color
    $results += [pscustomobject]@{ Field = $name; Hidden = $after.Hidden; ShowInNewForm = $after.ShowInNewForm; ShowInEditForm = $after.ShowInEditForm; Pass = $pass }
}

$failCount = @($results | Where-Object { -not $_.Pass }).Count
$payload = [pscustomobject]@{
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    list = $listTitle
    stillVisible = $failCount
    results = $results
}
$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding UTF8

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
$results | Format-Table -AutoSize | Out-String | Write-Host
Write-Host ("Fields still visible: {0}" -f $failCount) -ForegroundColor $(if($failCount -eq 0){"Green"}else{"Yellow"})
Write-Host ("Result written: {0}" -f $resultPath) -ForegroundColor Gray

try { Disconnect-PnPOnline | Out-Null } catch {}
if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
