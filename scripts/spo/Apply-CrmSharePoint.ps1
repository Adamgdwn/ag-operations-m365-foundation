param(
    [string]$ConfigDir = ".\config",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\crm-apply",
    [switch]$Apply,
    [string]$ApprovalPhrase = "",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# CRM recovery Chunk 4/5 - SharePoint apply (structure + clean intake form).
#
# DEFAULT: dry-run. Prints the exact intended tenant changes from the three
# split configs and writes NOTHING. No sign-in needed for dry-run.
#
# WRITE MODE: requires BOTH -Apply AND -ApprovalPhrase 'apply-gail-crm-recovery'.
# Without the exact phrase the script REFUSES and exits without connecting.
#
# In write mode it is idempotent and additive only:
#   - ensures the 7 workflow lists exist (primary-intake + workflow roles)
#   - ensures their columns, lookups, and views
#   - HIDES every blocked technical field on CRM - New Signals
#     (ShowInNewForm=false AND ShowInEditForm=false) if present
#   - sets required / not-required flags on the intake business fields
# It never deletes a list/field/item, never touches permissions, sharing, app
# consent, mail, public forms, automation, or Dynamics/Dataverse. Durable
# lookup-target lists (Organizations/Contacts/Engagements) are referenced, not
# recreated. Page/navigation changes live in scripts/portal/Apply-CrmPortal.ps1.

$ErrorActionPreference = "Stop"
$APPROVAL_PHRASE = "apply-gail-crm-recovery"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function Resolve-WorkspacePath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

function Test-JsonProperty {
    param([object]$Object, [string]$Name)
    return ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name)
}

function ConvertTo-XmlAttributeText {
    param([string]$Value)
    return ([System.Security.SecurityElement]::Escape([string]$Value))
}

# --- Load config -----------------------------------------------------------

$resolvedConfigDir = Resolve-WorkspacePath -Path $ConfigDir
$sharePointConfigPath = Join-Path $resolvedConfigDir "crm.sharepoint.json"
$intakeConfigPath = Join-Path $resolvedConfigDir "crm.intake.json"

foreach ($path in @($sharePointConfigPath, $intakeConfigPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Config file not found: $path" }
}

$spConfig = Get-Content -LiteralPath $sharePointConfigPath -Raw | ConvertFrom-Json
$intakeConfig = Get-Content -LiteralPath $intakeConfigPath -Raw | ConvertFrom-Json
$siteUrl = [string]$spConfig.site.url
$intakeList = [string]$intakeConfig.intakeList

# Lists this script manages (creates/updates). Durable lookup targets and
# lookup-only references are intentionally excluded - they are not recreated.
$manageableRoles = @("primary-intake", "workflow")
$manageableLists = @($spConfig.lists | Where-Object { $manageableRoles -contains [string]$_.role })

# --- Build the intended-change plan (used for dry-run print AND write log) --

$plan = New-Object System.Collections.Generic.List[string]
$plan.Add(("Site: {0}" -f $siteUrl))
$plan.Add("")
foreach ($list in $manageableLists) {
    $title = [string]$list.title
    $plan.Add(("LIST: {0} ({1})" -f $title, [string]$list.role))
    $plan.Add(("  ensure list exists (GenericList, OnQuickLaunch={0})" -f [bool]$list.quickLaunch))
    foreach ($c in @($list.columns)) {
        $req = if ((Test-JsonProperty -Object $c -Name "required") -and $c.required) { ", Required" } else { "" }
        $idx = if ((Test-JsonProperty -Object $c -Name "indexed") -and $c.indexed) { ", Indexed" } else { "" }
        $plan.Add(("  ensure column: {0} [{1}{2}{3}]" -f [string]$c.internalName, [string]$c.type, $req, $idx))
    }
    foreach ($l in @($list.lookupFields)) {
        $plan.Add(("  ensure lookup: {0} -> {1}.{2}" -f [string]$l.internalName, [string]$l.targetList, [string]$l.targetField))
    }
    foreach ($v in @($list.views)) {
        $def = if ((Test-JsonProperty -Object $v -Name "default") -and $v.default) { ", default" } else { "" }
        $plan.Add(("  ensure view: {0} ({1} fields{2})" -f [string]$v.title, @($v.fields).Count, $def))
    }
    $plan.Add("")
}
$plan.Add(("INTAKE FORM ({0}):" -f $intakeList))
foreach ($b in $intakeConfig.blockedFieldNames) {
    $plan.Add(("  HIDE blocked field if present: {0} (ShowInNewForm=false, ShowInEditForm=false)" -f [string]$b))
}
foreach ($r in $intakeConfig.requiredBusinessFields) {
    $plan.Add(("  set Required=True: {0}" -f [string]$r))
}
foreach ($n in $intakeConfig.notRequiredFields) {
    $plan.Add(("  set Required=False: {0}" -f [string]$n))
}
$plan.Add("")
$plan.Add("NOT TOUCHED: durable lookup targets (Organizations/Contacts/Engagements), permissions, sharing, consent, mail, deletes.")

# --- Output paths ----------------------------------------------------------

$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$mode = if ($Apply) { "apply" } else { "dryrun" }
$planPath = Join-Path $resolvedOutputRoot ("crm-apply-sharepoint-plan-{0}-{1}.txt" -f $mode, $timestamp)
Set-Content -LiteralPath $planPath -Value $plan -Encoding UTF8

Write-Host "CRM Recovery - SharePoint Apply" -ForegroundColor Cyan
Write-Host ("Mode:   {0}" -f $mode.ToUpper()) -ForegroundColor $(if ($Apply) { "Yellow" } else { "Green" })
Write-Host ("Site:   {0}" -f $siteUrl) -ForegroundColor Gray
Write-Host ("Plan:   {0}" -f $planPath) -ForegroundColor Gray
Write-Host ""
Write-Host "----- INTENDED TENANT CHANGES -----" -ForegroundColor Cyan
$plan | ForEach-Object { Write-Host $_ }
Write-Host "-----------------------------------" -ForegroundColor Cyan
Write-Host ""

# --- Approval gate ---------------------------------------------------------

if (-not $Apply) {
    Write-Host "DRY-RUN ONLY. No tenant connection, no changes were made." -ForegroundColor Green
    Write-Host ("To apply: re-run with -Apply -ApprovalPhrase '{0}'" -f $APPROVAL_PHRASE) -ForegroundColor Gray
    if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
    exit 0
}

if ($ApprovalPhrase -ne $APPROVAL_PHRASE) {
    Write-Host "REFUSED: write mode requires the exact approval phrase." -ForegroundColor Red
    Write-Host ("  Re-run with: -Apply -ApprovalPhrase '{0}'" -f $APPROVAL_PHRASE) -ForegroundColor Red
    Write-Host "No tenant connection was made. No changes." -ForegroundColor Red
    if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
    exit 2
}

# --- WRITE MODE (approved) -------------------------------------------------

$transcriptPath = Join-Path $resolvedOutputRoot ("crm-apply-sharepoint-{0}.log" -f $timestamp)
try { Start-Transcript -Path $transcriptPath -Force | Out-Null } catch {}

Write-Host "APPROVED. Connecting for write..." -ForegroundColor Yellow

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available. Re-run through scripts\spo\Start-CrmApplyInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{ Url = $siteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
Connect-PnPOnline @connectParams

function Add-CrmField {
    param([string]$ListTitle, [object]$Column)
    $internal = [string]$Column.internalName
    $existing = Get-PnPField -List $ListTitle -Identity $internal -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] field exists: {0}" -f $internal) -ForegroundColor Gray
    }
    else {
        $params = @{ List = $ListTitle; DisplayName = [string]$Column.displayName; InternalName = $internal; Type = [string]$Column.type; AddToDefaultView = $true }
        if ((Test-JsonProperty -Object $Column -Name "required") -and $Column.required -eq $true) { $params.Required = $true }
        if ([string]$Column.type -eq "Choice") { $params.Choices = @($Column.choices | ForEach-Object { [string]$_ }) }
        Add-PnPField @params | Out-Null
        Write-Host ("  [OK] field created: {0}" -f $internal) -ForegroundColor Green
    }
    if (Test-JsonProperty -Object $Column -Name "default") {
        try { Set-PnPField -List $ListTitle -Identity $internal -Values @{ DefaultValue = [string]$Column.default } | Out-Null } catch { Write-Host ("  [warn] default {0}: {1}" -f $internal, $_.Exception.Message) -ForegroundColor Yellow }
    }
    if ((Test-JsonProperty -Object $Column -Name "indexed") -and $Column.indexed -eq $true) {
        try { Set-PnPField -List $ListTitle -Identity $internal -Values @{ Indexed = $true } | Out-Null } catch { Write-Host ("  [warn] index {0}: {1}" -f $internal, $_.Exception.Message) -ForegroundColor Yellow }
    }
}

function Add-CrmLookup {
    param([string]$ListTitle, [object]$Lookup)
    $internal = [string]$Lookup.internalName
    $existing = Get-PnPField -List $ListTitle -Identity $internal -ErrorAction SilentlyContinue
    if ($null -ne $existing) { Write-Host ("  [skip] lookup exists: {0}" -f $internal) -ForegroundColor Gray; return }
    $targetList = Get-PnPList -Identity ([string]$Lookup.targetList) -ErrorAction SilentlyContinue
    if ($null -eq $targetList) {
        Write-Host ("  [warn] lookup target missing, skipping {0} -> {1}" -f $internal, [string]$Lookup.targetList) -ForegroundColor Yellow
        return
    }
    $targetId = $targetList.Id
    $displayName = ConvertTo-XmlAttributeText -Value ([string]$Lookup.displayName)
    $safeName = ConvertTo-XmlAttributeText -Value $internal
    $showField = ConvertTo-XmlAttributeText -Value ([string]$Lookup.targetField)
    $fieldXml = "<Field Type='Lookup' DisplayName='$displayName' Name='$safeName' StaticName='$safeName' List='{$targetId}' ShowField='$showField' Required='FALSE' />"
    Add-PnPFieldFromXml -List $ListTitle -FieldXml $fieldXml | Out-Null
    Write-Host ("  [OK] lookup created: {0}" -f $internal) -ForegroundColor Green
    if ((Test-JsonProperty -Object $Lookup -Name "indexed") -and $Lookup.indexed -eq $true) {
        try { Set-PnPField -List $ListTitle -Identity $internal -Values @{ Indexed = $true } | Out-Null } catch {}
    }
}

function Add-CrmView {
    param([string]$ListTitle, [object]$View)
    $title = [string]$View.title
    $fields = @($View.fields | ForEach-Object { [string]$_ })
    $existing = Get-PnPView -List $ListTitle -Identity $title -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        $params = @{ List = $ListTitle; Title = $title; Fields = $fields }
        if (Test-JsonProperty -Object $View -Name "rowLimit") { $params.RowLimit = [uint32]$View.rowLimit }
        if ((Test-JsonProperty -Object $View -Name "query") -and -not [string]::IsNullOrWhiteSpace([string]$View.query)) { $params.Query = [string]$View.query }
        Add-PnPView @params | Out-Null
        Write-Host ("  [OK] view created: {0}" -f $title) -ForegroundColor Green
    }
    else {
        $values = @{}
        if ((Test-JsonProperty -Object $View -Name "query") -and -not [string]::IsNullOrWhiteSpace([string]$View.query)) { $values.ViewQuery = [string]$View.query }
        if (Test-JsonProperty -Object $View -Name "rowLimit") { $values.RowLimit = [uint32]$View.rowLimit }
        Set-PnPView -List $ListTitle -Identity $title -Fields $fields -Values $values | Out-Null
        Write-Host ("  [OK] view updated: {0}" -f $title) -ForegroundColor Green
    }
    if ((Test-JsonProperty -Object $View -Name "default") -and $View.default -eq $true) {
        try { Set-PnPView -List $ListTitle -Identity $title -Values @{ DefaultView = $true } | Out-Null } catch {}
    }
}

function Set-FieldFormHidden {
    param([string]$ListTitle, [string]$FieldName)
    $field = Get-PnPField -List $ListTitle -Identity $FieldName -ErrorAction SilentlyContinue
    if ($null -eq $field) { Write-Host ("  [skip] blocked field absent (good): {0}" -f $FieldName) -ForegroundColor Gray; return }
    $field.SetShowInNewForm($false)
    $field.SetShowInEditForm($false)
    $field.Update()
    (Get-PnPContext).ExecuteQuery()
    Write-Host ("  [OK] blocked field hidden: {0}" -f $FieldName) -ForegroundColor Green
}

function Set-FieldRequired {
    param([string]$ListTitle, [string]$FieldName, [bool]$Required)
    $field = Get-PnPField -List $ListTitle -Identity $FieldName -ErrorAction SilentlyContinue
    if ($null -eq $field) { Write-Host ("  [skip] field absent: {0}" -f $FieldName) -ForegroundColor Gray; return }
    try {
        Set-PnPField -List $ListTitle -Identity $FieldName -Values @{ Required = $Required } | Out-Null
        Write-Host ("  [OK] Required={0}: {1}" -f $Required, $FieldName) -ForegroundColor Green
    } catch { Write-Host ("  [warn] required {0}: {1}" -f $FieldName, $_.Exception.Message) -ForegroundColor Yellow }
}

foreach ($list in $manageableLists) {
    $title = [string]$list.title
    Write-Host ("LIST: {0}" -f $title) -ForegroundColor Cyan
    $existing = Get-PnPList -Identity $title -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        New-PnPList -Title $title -Template GenericList -OnQuickLaunch:([bool]$list.quickLaunch) | Out-Null
        if (-not [string]::IsNullOrWhiteSpace([string]$list.description)) {
            Set-PnPList -Identity $title -Description ([string]$list.description) | Out-Null
        }
        Write-Host ("  [OK] list created: {0}" -f $title) -ForegroundColor Green
    } else {
        Write-Host ("  [skip] list exists: {0}" -f $title) -ForegroundColor Gray
    }
    foreach ($c in @($list.columns)) { Add-CrmField -ListTitle $title -Column $c }
    foreach ($l in @($list.lookupFields)) { Add-CrmLookup -ListTitle $title -Lookup $l }
    foreach ($v in @($list.views)) { Add-CrmView -ListTitle $title -View $v }
}

Write-Host ("INTAKE FORM: {0}" -f $intakeList) -ForegroundColor Cyan
foreach ($b in $intakeConfig.blockedFieldNames) { Set-FieldFormHidden -ListTitle $intakeList -FieldName ([string]$b) }
foreach ($r in $intakeConfig.requiredBusinessFields) { Set-FieldRequired -ListTitle $intakeList -FieldName ([string]$r) -Required $true }
foreach ($n in $intakeConfig.notRequiredFields) { Set-FieldRequired -ListTitle $intakeList -FieldName ([string]$n) -Required $false }

try { Disconnect-PnPOnline | Out-Null } catch {}

Write-Host ""
Write-Host ("SharePoint apply complete. Re-run scripts/spo/Verify-CrmSharePoint.ps1 to confirm PASS.") -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
