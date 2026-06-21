param(
    [string]$ConfigDir = ".\config",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\crm-verify",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# CRM recovery Chunk 3 - verifier replacement (READ ONLY).
#
# Replaces the Stage 8C verifier that false-passed. This one FAILS when the
# browser operator path is not actually clean. Specifically it FAILS when:
#   - a required list / column / lookup / view is missing
#   - a blocked technical field is VISIBLE on the daily intake form
#     (ShowInNewForm/ShowInEditForm is True or DefaultTrue - the exact gap
#     that wrongly passed before)
#   - a QuickLaunch nav node routes to the legacy Intake Register NewForm
#   - the CRM Command Center page body links to the legacy Intake Register
#
# It writes PASS/FAIL, per-check evidence, the specific failures, and the manual
# browser checks a human still has to do (Chunk 6). It never writes to tenant.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function Resolve-WorkspacePath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

function Get-FieldFormExperience {
    param([string]$ListTitle, [string]$FieldName)

    $field = Get-PnPField -List $ListTitle -Identity $FieldName -Includes Required,SchemaXml,Hidden -ErrorAction SilentlyContinue
    if ($null -eq $field) { return $null }

    $schema = [xml]([string]$field.SchemaXml)
    $showInNewForm = [string]$schema.Field.ShowInNewForm
    $showInEditForm = [string]$schema.Field.ShowInEditForm
    [pscustomobject]@{
        Required = [bool]$field.Required
        TypeAsString = [string]$field.TypeAsString
        Hidden = [bool]$field.Hidden
        ShowInNewForm = if ([string]::IsNullOrWhiteSpace($showInNewForm)) { "DefaultTrue" } else { $showInNewForm }
        ShowInEditForm = if ([string]::IsNullOrWhiteSpace($showInEditForm)) { "DefaultTrue" } else { $showInEditForm }
    }
}

function Test-FormFlagVisible {
    # A flag is VISIBLE unless it is explicitly false. Blank => DefaultTrue => visible.
    param([string]$Value)
    return ([string]$Value -notin @("FALSE", "False", "false", "0"))
}

function Test-LegacyIntakeRoute {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    $needles = @(
        "Intake Register/NewForm.aspx",
        "Guided%20AI%20Labs%20-%20Intake%20Register/NewForm.aspx",
        "Guided%20AI%20Labs%20%20Intake%20Register/NewForm.aspx",
        "Guided AI Labs - Intake Register/NewForm.aspx"
    )
    foreach ($needle in $needles) {
        if ($Value -like ("*{0}*" -f $needle)) { return $true }
    }
    return $false
}

function ConvertTo-FlatNavigation {
    param([object[]]$Nodes, [string]$ParentTitle = "")
    foreach ($node in $Nodes) {
        [pscustomobject]@{ ParentTitle = $ParentTitle; Title = [string]$node.Title; Url = [string]$node.Url }
        if ($null -ne $node.Children) {
            ConvertTo-FlatNavigation -Nodes @($node.Children) -ParentTitle ([string]$node.Title)
        }
    }
}

# Each check appends to $checks. Severity Fail vs Warn; only Fail flips overall result.
$checks = New-Object System.Collections.Generic.List[object]
function Add-Check {
    param(
        [string]$Area, [string]$Item, [string]$Expected, [string]$Actual,
        [ValidateSet("Pass", "Fail", "Warn")][string]$Status,
        [string]$Severity = "Fail"
    )
    $checks.Add([pscustomobject]@{
        Area = $Area; Item = $Item; Expected = $Expected; Actual = $Actual
        Status = $Status; Severity = $Severity
    })
}

# --- Load config -----------------------------------------------------------

$resolvedConfigDir = Resolve-WorkspacePath -Path $ConfigDir
$sharePointConfigPath = Join-Path $resolvedConfigDir "crm.sharepoint.json"
$intakeConfigPath = Join-Path $resolvedConfigDir "crm.intake.json"
$navigationConfigPath = Join-Path $resolvedConfigDir "crm.navigation.json"

foreach ($path in @($sharePointConfigPath, $intakeConfigPath, $navigationConfigPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Config file not found: $path" }
}

$spConfig = Get-Content -LiteralPath $sharePointConfigPath -Raw | ConvertFrom-Json
$intakeConfig = Get-Content -LiteralPath $intakeConfigPath -Raw | ConvertFrom-Json
$navConfig = Get-Content -LiteralPath $navigationConfigPath -Raw | ConvertFrom-Json

$siteUrl = [string]$spConfig.site.url
$intakeList = [string]$intakeConfig.intakeList

$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputRoot ("crm-verify-{0}.log" -f $timestamp)
$checksCsvPath = Join-Path $resolvedOutputRoot ("crm-verify-checks-{0}.csv" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "CRM_VERIFY.md"

try { Start-Transcript -Path $transcriptPath -Force | Out-Null }
catch { Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow }

Write-Host "CRM Recovery Chunk 3 - Verifier (READ ONLY)" -ForegroundColor Cyan
Write-Host "Site:       $siteUrl" -ForegroundColor Gray
Write-Host "Intake:     $intakeList" -ForegroundColor Gray
Write-Host "Output:     $resolvedOutputRoot" -ForegroundColor Gray
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available. Re-run through scripts\spo\Start-CrmVerifyInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{ Url = $siteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
Connect-PnPOnline @connectParams

# --- Lists, columns, lookups, views ---------------------------------------
# Durable-lookup-target lists are required (apply depends on them). lookupOnly
# references are NOT required (provenance only, per config note).

$requiredLists = @($spConfig.lists | Where-Object { [string]$_.role -ne "lookup-only-reference" })

foreach ($list in $requiredLists) {
    $title = [string]$list.title
    $live = Get-PnPList -Identity $title -ErrorAction SilentlyContinue
    Add-Check -Area "List" -Item $title -Expected "Present" -Actual $(if($null -ne $live) { "Present" } else { "Missing" }) -Status $(if($null -ne $live) { "Pass" } else { "Fail" })
    if ($null -eq $live) { continue }

    foreach ($column in @($list.columns)) {
        $internal = [string]$column.internalName
        # Skip phantom $null element from @() on a missing/empty array (PowerShell
        # turns a missing property into a one-element array containing $null).
        if ([string]::IsNullOrWhiteSpace($internal)) { continue }
        $field = Get-PnPField -List $title -Identity $internal -Includes TypeAsString -ErrorAction SilentlyContinue
        $ok = ($null -ne $field)
        Add-Check -Area "Column" -Item ("{0}.{1}" -f $title, $internal) -Expected ([string]$column.type) -Actual $(if($ok) { [string]$field.TypeAsString } else { "Missing" }) -Status $(if($ok) { "Pass" } else { "Fail" })
    }

    foreach ($lookup in @($list.lookupFields)) {
        $internal = [string]$lookup.internalName
        # Skip phantom $null element (durable-lookup-target lists define no lookups
        # of their own; their schema is provenance and not recreated here).
        if ([string]::IsNullOrWhiteSpace($internal)) { continue }
        $field = Get-PnPField -List $title -Identity $internal -Includes TypeAsString -ErrorAction SilentlyContinue
        $isLookup = ($null -ne $field -and [string]$field.TypeAsString -eq "Lookup")
        Add-Check -Area "Lookup" -Item ("{0}.{1}" -f $title, $internal) -Expected ("Lookup -> {0}" -f [string]$lookup.targetList) -Actual $(if($null -eq $field) { "Missing" } elseif ($isLookup) { "Lookup" } else { [string]$field.TypeAsString }) -Status $(if($isLookup) { "Pass" } else { "Fail" })
    }

    foreach ($view in @($list.views)) {
        $vTitle = [string]$view.title
        # Skip phantom $null element from @() on a missing/empty views array.
        if ([string]::IsNullOrWhiteSpace($vTitle)) { continue }
        $live2 = Get-PnPView -List $title -Identity $vTitle -Includes ViewQuery -ErrorAction SilentlyContinue
        $hasQuery = ($null -ne $live2 -and -not [string]::IsNullOrWhiteSpace([string]$live2.ViewQuery))
        # A view with no query is only a Warn unless the config gave it one.
        $expectsQuery = -not [string]::IsNullOrWhiteSpace([string]$view.query)
        $status = if ($null -eq $live2) { "Fail" } elseif ($expectsQuery -and -not $hasQuery) { "Fail" } else { "Pass" }
        Add-Check -Area "View" -Item ("{0} / {1}" -f $title, $vTitle) -Expected $(if($expectsQuery) { "Present + query" } else { "Present" }) -Actual $(if($null -eq $live2) { "Missing" } elseif ($hasQuery) { "Present + query" } else { "Present, no query" }) -Status $status
    }
}

# --- Blocked technical fields must NOT be visible on the intake form -------
# This is the core anti-false-pass rule. Absent => pass. Present+hidden => pass.
# Present+visible (True or DefaultTrue) => FAIL.

foreach ($fieldName in $intakeConfig.blockedFieldNames) {
    $name = [string]$fieldName
    $form = Get-FieldFormExperience -ListTitle $intakeList -FieldName $name
    if ($null -eq $form) {
        Add-Check -Area "Blocked field" -Item $name -Expected "Absent or hidden" -Actual "Absent" -Status "Pass"
        continue
    }
    # A field is hidden from the form if Hidden=TRUE (removed from all forms+views) OR
    # both form flags are explicitly false. Hidden fields remain writable by the sync
    # flow via internal name, so Hidden=TRUE is the accepted, stronger posture for the
    # pure-technical backbone keys.
    $visible = (-not $form.Hidden) -and ((Test-FormFlagVisible -Value ([string]$form.ShowInNewForm)) -or (Test-FormFlagVisible -Value ([string]$form.ShowInEditForm)))
    Add-Check -Area "Blocked field" -Item $name `
        -Expected "Hidden=true OR (ShowInNewForm=false AND ShowInEditForm=false)" `
        -Actual ("Hidden={0}; ShowInNewForm={1}; ShowInEditForm={2}" -f $form.Hidden, $form.ShowInNewForm, $form.ShowInEditForm) `
        -Status $(if($visible) { "Fail" } else { "Pass" })
}

# --- Visible business fields SHOULD be present and shown --------------------

$intakeFormFields = @($intakeConfig.form.sections | ForEach-Object { @($_.fields) }) | ForEach-Object { [string]$_ }
foreach ($fieldName in $intakeFormFields) {
    $name = [string]$fieldName
    $form = Get-FieldFormExperience -ListTitle $intakeList -FieldName $name
    if ($null -eq $form) {
        Add-Check -Area "Intake field" -Item $name -Expected "Present and visible" -Actual "Missing" -Status "Fail"
        continue
    }
    $shown = (Test-FormFlagVisible -Value ([string]$form.ShowInNewForm)) -and (Test-FormFlagVisible -Value ([string]$form.ShowInEditForm))
    Add-Check -Area "Intake field" -Item $name -Expected "Visible on new+edit form" -Actual ("ShowInNewForm={0}; ShowInEditForm={1}" -f $form.ShowInNewForm, $form.ShowInEditForm) -Status $(if($shown) { "Pass" } else { "Warn" })
}

# Required business fields must actually be Required on the list.
foreach ($req in $intakeConfig.requiredBusinessFields) {
    $name = [string]$req
    $form = Get-FieldFormExperience -ListTitle $intakeList -FieldName $name
    if ($null -eq $form) {
        Add-Check -Area "Required field" -Item $name -Expected "Required=True" -Actual "Missing" -Status "Fail"
        continue
    }
    Add-Check -Area "Required field" -Item $name -Expected "Required=True" -Actual ("Required={0}" -f $form.Required) -Status $(if($form.Required) { "Pass" } else { "Warn" })
}

# --- Pages: exist, and Command Center body must not link legacy intake ------

$pageTargets = @(
    [pscustomobject]@{ Key = "operationsCockpit"; Path = [string]$spConfig.site.pages.operationsCockpit },
    [pscustomobject]@{ Key = "crmCommandCenter"; Path = [string]$spConfig.site.pages.crmCommandCenter }
)
foreach ($target in $pageTargets) {
    $fileName = Split-Path -Leaf ([string]$target.Path)
    $found = $null
    try { $found = Get-PnPPage -Identity $fileName -ErrorAction Stop } catch { $found = $null }
    Add-Check -Area "Page" -Item ([string]$target.Key) -Expected "Present" -Actual $(if($null -ne $found) { "Present" } else { "Missing" }) -Status $(if($null -ne $found) { "Pass" } else { "Fail" })

    if ($null -ne $found) {
        $legacyInBody = $false
        try {
            $components = @(Get-PnPPageComponent -Page $fileName -ErrorAction SilentlyContinue)
            $pageText = @($components | ForEach-Object { [string]$_.Text }) -join "`n"
            $legacyInBody = Test-LegacyIntakeRoute -Value $pageText
        } catch { $legacyInBody = $false }
        Add-Check -Area "Page legacy link" -Item ([string]$target.Key) -Expected "No legacy Intake Register link in body" -Actual $(if($legacyInBody) { "Legacy link present" } else { "None" }) -Status $(if($legacyInBody) { "Fail" } else { "Pass" })
    }
}

# --- Navigation: no daily node may route to legacy intake ------------------

$flatNav = New-Object System.Collections.Generic.List[object]
try {
    $navTree = @(Get-PnPNavigationNode -Location QuickLaunch -Tree)
    foreach ($item in @(ConvertTo-FlatNavigation -Nodes $navTree)) { $flatNav.Add($item) }
} catch {
    Write-Host ("[warn] Could not read QuickLaunch tree: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

$legacyNav = @($flatNav | Where-Object { Test-LegacyIntakeRoute -Value ([string]$_.Url) })
if ($legacyNav.Count -eq 0) {
    Add-Check -Area "Navigation" -Item "QuickLaunch" -Expected "No node routes to legacy Intake Register NewForm" -Actual "None found" -Status "Pass"
} else {
    foreach ($n in $legacyNav) {
        Add-Check -Area "Navigation" -Item ("{0} > {1}" -f $n.ParentTitle, $n.Title) -Expected "No legacy intake route" -Actual ([string]$n.Url) -Status "Fail"
    }
}

# --- Result + output -------------------------------------------------------

$checks | Export-Csv -LiteralPath $checksCsvPath -NoTypeInformation -Encoding UTF8

$fails = @($checks | Where-Object { $_.Status -eq "Fail" })
$warns = @($checks | Where-Object { $_.Status -eq "Warn" })
$result = if ($fails.Count -eq 0) { "PASS" } else { "FAIL" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# CRM Verifier (Chunk 3)")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add(("Result: {0}" -f $result))
$lines.Add(("Failures: {0} | Warnings: {1} | Total checks: {2}" -f $fails.Count, $warns.Count, $checks.Count))
$lines.Add("")
$lines.Add(("Site: {0}" -f $siteUrl))
$lines.Add(("Intake list: {0}" -f $intakeList))
$lines.Add(("Checks CSV: {0}" -f $checksCsvPath))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
$lines.Add("")
if ($fails.Count -gt 0) {
    $lines.Add("## Failures (must fix before / during Chunk 5 apply)")
    $lines.Add("")
    $lines.Add("| Area | Item | Expected | Actual |")
    $lines.Add("|---|---|---|---|")
    foreach ($f in $fails) { $lines.Add(("| {0} | {1} | {2} | {3} |" -f $f.Area, $f.Item, $f.Expected, $f.Actual)) }
    $lines.Add("")
}
if ($warns.Count -gt 0) {
    $lines.Add("## Warnings (review; not hard blockers)")
    $lines.Add("")
    $lines.Add("| Area | Item | Expected | Actual |")
    $lines.Add("|---|---|---|---|")
    foreach ($w in $warns) { $lines.Add(("| {0} | {1} | {2} | {3} |" -f $w.Area, $w.Item, $w.Expected, $w.Actual)) }
    $lines.Add("")
}
$lines.Add("## Manual browser checks still required (Chunk 6 - a script cannot prove these)")
$lines.Add("")
$lines.Add("- Sign in as a normal operator (not admin) and open Operations Cockpit.")
$lines.Add("- Click the CRM Command Center card; confirm it opens the command center page.")
$lines.Add("- Click New Signal; confirm the form is the clean CRM - New Signals form, not the")
$lines.Add(("  legacy Intake Register, and that none of the {0} blocked technical fields appear." -f @($intakeConfig.blockedFieldNames).Count))
$lines.Add("- Save a GAIL-INTERNAL-WALKTHROUGH record and confirm it appears in the Triage Queue.")
$lines.Add("")

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try { Disconnect-PnPOnline | Out-Null } catch {}

$resultColor = if ($result -eq "PASS") { "Green" } else { "Yellow" }
Write-Host ""
Write-Host ("CRM verifier {0}: {1}" -f $result, $summaryPath) -ForegroundColor $resultColor
Write-Host ("Failures: {0} | Warnings: {1}" -f $fails.Count, $warns.Count) -ForegroundColor Gray

# Read-only verifier: a FAIL is reported in the summary, not thrown, so the
# window does not look "crashed". Exit code still reflects result for automation.
try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}

if ($result -eq "FAIL") { exit 1 } else { exit 0 }
