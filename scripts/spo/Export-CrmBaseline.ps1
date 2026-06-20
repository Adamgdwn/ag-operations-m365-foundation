param(
    [string]$ConfigDir = ".\config",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\crm-baseline",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# CRM recovery Chunk 2 - read-only baseline export.
#
# Captures the live tenant CRM state BEFORE any recovery write, so Chunk 3
# (verifier) and Chunk 5 (apply) have a trustworthy "before" picture. This
# script never creates, updates, deletes, invites, shares, consents, or sends
# mail. It only reads. "Missing" / "Absent" are valid evidence, not errors.
#
# Reads the three split config files:
#   config/crm.sharepoint.json  - lists, columns, views, content-type expectations
#   config/crm.intake.json      - clean intake contract + blocked technical fields
#   config/crm.navigation.json  - pages, daily cards, forbidden legacy route

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Get-FieldFormExperience {
    # Reads ShowInNewForm / ShowInEditForm / ShowInDisplayForm exactly as the
    # Stage 8C verifier did. The key recovery lesson: a blank flag means
    # "DefaultTrue" (i.e. VISIBLE), which is what wrongly passed before.
    param(
        [string]$ListTitle,
        [string]$FieldName
    )

    $field = Get-PnPField -List $ListTitle -Identity $FieldName -Includes Required,SchemaXml -ErrorAction SilentlyContinue
    if ($null -eq $field) {
        return $null
    }

    $schema = [xml]([string]$field.SchemaXml)
    $showInNewForm = [string]$schema.Field.ShowInNewForm
    $showInEditForm = [string]$schema.Field.ShowInEditForm
    $showInDisplayForm = [string]$schema.Field.ShowInDisplayForm

    [pscustomobject]@{
        Required = [bool]$field.Required
        TypeAsString = [string]$field.TypeAsString
        ShowInNewForm = if ([string]::IsNullOrWhiteSpace($showInNewForm)) { "DefaultTrue" } else { $showInNewForm }
        ShowInEditForm = if ([string]::IsNullOrWhiteSpace($showInEditForm)) { "DefaultTrue" } else { $showInEditForm }
        ShowInDisplayForm = if ([string]::IsNullOrWhiteSpace($showInDisplayForm)) { "DefaultTrue" } else { $showInDisplayForm }
    }
}

function Test-FormFlagVisible {
    param([string]$Value)

    return ([string]$Value -notin @("FALSE", "False", "false", "0"))
}

function Test-LegacyIntakeRoute {
    # Returns $true if a URL/text resolves to the forbidden legacy intake route,
    # covering raw and URL-encoded spellings of "Guided AI Labs - Intake Register".
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    $needles = @(
        "Intake Register/NewForm.aspx",
        "Guided%20AI%20Labs%20-%20Intake%20Register/NewForm.aspx",
        "Guided%20AI%20Labs%20%20Intake%20Register/NewForm.aspx",
        "Guided AI Labs - Intake Register/NewForm.aspx"
    )
    foreach ($needle in $needles) {
        if ($Value -like ("*{0}*" -f $needle)) {
            return $true
        }
    }
    return $false
}

function ConvertTo-FlatNavigation {
    param(
        [object[]]$Nodes,
        [string]$ParentTitle = ""
    )

    foreach ($node in $Nodes) {
        [pscustomobject]@{
            ParentTitle = $ParentTitle
            Title = [string]$node.Title
            Url = [string]$node.Url
        }

        if ($null -ne $node.Children) {
            ConvertTo-FlatNavigation -Nodes @($node.Children) -ParentTitle ([string]$node.Title)
        }
    }
}

# --- Load config -----------------------------------------------------------

$resolvedConfigDir = Resolve-WorkspacePath -Path $ConfigDir
$sharePointConfigPath = Join-Path $resolvedConfigDir "crm.sharepoint.json"
$intakeConfigPath = Join-Path $resolvedConfigDir "crm.intake.json"
$navigationConfigPath = Join-Path $resolvedConfigDir "crm.navigation.json"

foreach ($path in @($sharePointConfigPath, $intakeConfigPath, $navigationConfigPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Config file not found: $path"
    }
}

$spConfig = Get-Content -LiteralPath $sharePointConfigPath -Raw | ConvertFrom-Json
$intakeConfig = Get-Content -LiteralPath $intakeConfigPath -Raw | ConvertFrom-Json
$navConfig = Get-Content -LiteralPath $navigationConfigPath -Raw | ConvertFrom-Json

$siteUrl = [string]$spConfig.site.url

$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputRoot ("crm-baseline-{0}.log" -f $timestamp)
$listCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-lists-{0}.csv" -f $timestamp)
$fieldCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-fields-{0}.csv" -f $timestamp)
$lookupCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-lookups-{0}.csv" -f $timestamp)
$viewCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-views-{0}.csv" -f $timestamp)
$blockedCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-blocked-fields-{0}.csv" -f $timestamp)
$intakeCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-intake-fields-{0}.csv" -f $timestamp)
$pageCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-pages-{0}.csv" -f $timestamp)
$navCsvPath = Join-Path $resolvedOutputRoot ("crm-baseline-navigation-{0}.csv" -f $timestamp)
$snapshotJsonPath = Join-Path $resolvedOutputRoot ("crm-baseline-snapshot-{0}.json" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "CRM_BASELINE_EXPORT.md"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "CRM Recovery Chunk 2 - Read-Only Baseline Export" -ForegroundColor Cyan
Write-Host "Site:       $siteUrl" -ForegroundColor Gray
Write-Host "Config dir: $resolvedConfigDir" -ForegroundColor Gray
Write-Host "Output:     $resolvedOutputRoot" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Scope: READ ONLY. No create/update/delete/invite/share/consent/mail." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\spo\Start-CrmBaselineExportInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{
    Url = $siteUrl
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

# --- Lists -----------------------------------------------------------------

$listResults = foreach ($list in $spConfig.lists) {
    $title = [string]$list.title
    $live = Get-PnPList -Identity $title -Includes ItemCount,Hidden,DefaultViewUrl,OnQuickLaunch -ErrorAction SilentlyContinue
    [pscustomobject]@{
        List = $title
        Role = [string]$list.role
        Exists = ($null -ne $live)
        ItemCount = if ($null -ne $live) { [int]$live.ItemCount } else { "" }
        Hidden = if ($null -ne $live) { [string]$live.Hidden } else { "" }
        OnQuickLaunch = if ($null -ne $live) { [string]$live.OnQuickLaunch } else { "" }
        DefaultViewUrl = if ($null -ne $live) { [string]$live.DefaultViewUrl } else { "" }
        State = if ($null -ne $live) { "Present" } else { "Missing" }
    }
}

# Lookup-only provenance references (CRM - Touchpoints, CRM - Lifecycle Checklist).
if ($spConfig.PSObject.Properties.Name -contains "lookupOnlyReferences") {
    $listResults += foreach ($ref in $spConfig.lookupOnlyReferences) {
        $title = [string]$ref.title
        $live = Get-PnPList -Identity $title -Includes ItemCount,Hidden -ErrorAction SilentlyContinue
        [pscustomobject]@{
            List = $title
            Role = "lookup-only-reference"
            Exists = ($null -ne $live)
            ItemCount = if ($null -ne $live) { [int]$live.ItemCount } else { "" }
            Hidden = if ($null -ne $live) { [string]$live.Hidden } else { "" }
            OnQuickLaunch = ""
            DefaultViewUrl = ""
            State = if ($null -ne $live) { "Present" } else { "Missing" }
        }
    }
}

# --- Columns (with the critical form-flag evidence) ------------------------

$fieldResults = foreach ($list in $spConfig.lists) {
    if ($null -eq $list.columns) { continue }
    $listTitle = [string]$list.title
    foreach ($column in $list.columns) {
        $internal = [string]$column.internalName
        $form = Get-FieldFormExperience -ListTitle $listTitle -FieldName $internal
        $field = Get-PnPField -List $listTitle -Identity $internal -Includes TypeAsString,Indexed -ErrorAction SilentlyContinue
        [pscustomobject]@{
            List = $listTitle
            Field = [string]$column.displayName
            InternalName = $internal
            ExpectedType = [string]$column.type
            Exists = ($null -ne $field)
            ActualType = if ($null -ne $field) { [string]$field.TypeAsString } else { "" }
            Indexed = if ($null -ne $field) { [string]$field.Indexed } else { "" }
            Required = if ($null -ne $form) { [string]$form.Required } else { "" }
            ShowInNewForm = if ($null -ne $form) { [string]$form.ShowInNewForm } else { "" }
            ShowInEditForm = if ($null -ne $form) { [string]$form.ShowInEditForm } else { "" }
            State = if ($null -ne $field) { "Present" } else { "Missing" }
        }
    }
}

# --- Lookup fields ---------------------------------------------------------

$lookupResults = foreach ($list in $spConfig.lists) {
    if ($null -eq $list.lookupFields) { continue }
    $listTitle = [string]$list.title
    foreach ($lookup in $list.lookupFields) {
        $internal = [string]$lookup.internalName
        $field = Get-PnPField -List $listTitle -Identity $internal -Includes TypeAsString,Indexed -ErrorAction SilentlyContinue
        [pscustomobject]@{
            List = $listTitle
            Field = [string]$lookup.displayName
            InternalName = $internal
            TargetList = [string]$lookup.targetList
            Exists = ($null -ne $field)
            ActualType = if ($null -ne $field) { [string]$field.TypeAsString } else { "" }
            Indexed = if ($null -ne $field) { [string]$field.Indexed } else { "" }
            State = if ($null -ne $field) { "Present" } else { "Missing" }
        }
    }
}

# --- Views -----------------------------------------------------------------

$viewResults = foreach ($list in $spConfig.lists) {
    if ($null -eq $list.views) { continue }
    $listTitle = [string]$list.title
    foreach ($view in $list.views) {
        $live = Get-PnPView -List $listTitle -Identity ([string]$view.title) -Includes ViewQuery,RowLimit -ErrorAction SilentlyContinue
        $hasQuery = $false
        if ($null -ne $live) {
            $hasQuery = -not [string]::IsNullOrWhiteSpace([string]$live.ViewQuery)
        }
        [pscustomobject]@{
            List = $listTitle
            View = [string]$view.title
            Exists = ($null -ne $live)
            HasQuery = $hasQuery
            RowLimit = if ($null -ne $live) { [string]$live.RowLimit } else { "" }
            State = if ($null -ne $live) { "Present" } else { "Missing" }
        }
    }
}

# --- Blocked technical fields on the intake list (the bad-state evidence) ---

$intakeList = [string]$intakeConfig.intakeList
$blockedResults = foreach ($fieldName in $intakeConfig.blockedFieldNames) {
    $name = [string]$fieldName
    $form = Get-FieldFormExperience -ListTitle $intakeList -FieldName $name
    $exists = ($null -ne $form)
    $visibleInNew = ($exists -and (Test-FormFlagVisible -Value ([string]$form.ShowInNewForm)))
    $visibleInEdit = ($exists -and (Test-FormFlagVisible -Value ([string]$form.ShowInEditForm)))
    [pscustomobject]@{
        List = $intakeList
        BlockedField = $name
        Exists = $exists
        ShowInNewForm = if ($exists) { [string]$form.ShowInNewForm } else { "" }
        ShowInEditForm = if ($exists) { [string]$form.ShowInEditForm } else { "" }
        # Observation only; Chunk 3 decides pass/fail. This flags whether the
        # known Stage 8C failure (visible technical field) is present today.
        VisibleInDailyForm = ($visibleInNew -or $visibleInEdit)
        Observation = if (-not $exists) { "Absent" } elseif ($visibleInNew -or $visibleInEdit) { "Present-and-visible" } else { "Present-but-hidden" }
    }
}

# --- Visible business intake fields ----------------------------------------

$intakeFormFields = @($intakeConfig.form.sections | ForEach-Object { @($_.fields) }) | ForEach-Object { [string]$_ }
$intakeFieldResults = foreach ($fieldName in $intakeFormFields) {
    $name = [string]$fieldName
    $form = Get-FieldFormExperience -ListTitle $intakeList -FieldName $name
    [pscustomobject]@{
        List = $intakeList
        Field = $name
        Exists = ($null -ne $form)
        Required = if ($null -ne $form) { [string]$form.Required } else { "" }
        ShowInNewForm = if ($null -ne $form) { [string]$form.ShowInNewForm } else { "" }
        ShowInEditForm = if ($null -ne $form) { [string]$form.ShowInEditForm } else { "" }
        State = if ($null -ne $form) { "Present" } else { "Missing" }
    }
}

# Intake list content-type mode (provenance: native vs content-type form).
$intakeContentTypesEnabled = ""
$liveIntake = Get-PnPList -Identity $intakeList -Includes ContentTypesEnabled -ErrorAction SilentlyContinue
if ($null -ne $liveIntake) {
    $intakeContentTypesEnabled = [string]$liveIntake.ContentTypesEnabled
}

# --- Pages -----------------------------------------------------------------

$pageTargets = @(
    [pscustomobject]@{ Key = "operationsCockpit"; Path = [string]$spConfig.site.pages.operationsCockpit },
    [pscustomobject]@{ Key = "crmCommandCenter"; Path = [string]$spConfig.site.pages.crmCommandCenter }
)

$pageResults = foreach ($target in $pageTargets) {
    $fileName = Split-Path -Leaf ([string]$target.Path)
    $found = $null
    try {
        $found = Get-PnPPage -Identity $fileName -ErrorAction Stop
    }
    catch {
        $found = $null
    }

    $legacyLinkInText = $false
    if ($null -ne $found) {
        try {
            $components = @(Get-PnPPageComponent -Page $fileName -ErrorAction SilentlyContinue)
            $pageText = @($components | ForEach-Object { [string]$_.Text }) -join "`n"
            $legacyLinkInText = Test-LegacyIntakeRoute -Value $pageText
        }
        catch {
            $legacyLinkInText = $false
        }
    }

    [pscustomobject]@{
        Page = [string]$target.Key
        FileName = $fileName
        Exists = ($null -ne $found)
        # Observation only: is the forbidden legacy intake link present in the
        # page body today? Chunk 3 turns this into a pass/fail check.
        LegacyIntakeLinkPresent = $legacyLinkInText
        State = if ($null -ne $found) { "Present" } else { "Missing" }
    }
}

# --- Navigation (flattened) + legacy-route detection -----------------------

$flatNav = New-Object System.Collections.Generic.List[object]
try {
    $navTree = @(Get-PnPNavigationNode -Location QuickLaunch -Tree)
    foreach ($item in @(ConvertTo-FlatNavigation -Nodes $navTree)) {
        $flatNav.Add($item)
    }
}
catch {
    Write-Host ("[warn] Could not read QuickLaunch tree: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

$navResults = foreach ($node in $flatNav) {
    [pscustomobject]@{
        ParentTitle = [string]$node.ParentTitle
        Title = [string]$node.Title
        Url = [string]$node.Url
        RoutesToLegacyIntake = (Test-LegacyIntakeRoute -Value ([string]$node.Url))
    }
}

# --- Write evidence --------------------------------------------------------

$listResults | Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8
$fieldResults | Export-Csv -LiteralPath $fieldCsvPath -NoTypeInformation -Encoding UTF8
$lookupResults | Export-Csv -LiteralPath $lookupCsvPath -NoTypeInformation -Encoding UTF8
$viewResults | Export-Csv -LiteralPath $viewCsvPath -NoTypeInformation -Encoding UTF8
$blockedResults | Export-Csv -LiteralPath $blockedCsvPath -NoTypeInformation -Encoding UTF8
$intakeFieldResults | Export-Csv -LiteralPath $intakeCsvPath -NoTypeInformation -Encoding UTF8
$pageResults | Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8
$navResults | Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$snapshot = [pscustomobject]@{
    generatedUtc = (Get-Date).ToUniversalTime().ToString("o")
    site = $siteUrl
    intakeList = $intakeList
    intakeContentTypesEnabled = $intakeContentTypesEnabled
    lists = $listResults
    fields = $fieldResults
    lookups = $lookupResults
    views = $viewResults
    blockedFields = $blockedResults
    intakeFields = $intakeFieldResults
    pages = $pageResults
    navigation = $navResults
}
$snapshot | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $snapshotJsonPath -Encoding UTF8

# --- Observation tallies (NOT pass/fail; this is a baseline, not a verifier) -

$missingLists = @($listResults | Where-Object { $_.State -eq "Missing" })
$blockedVisible = @($blockedResults | Where-Object { $_.VisibleInDailyForm })
$blockedPresent = @($blockedResults | Where-Object { $_.Exists })
$navLegacy = @($navResults | Where-Object { $_.RoutesToLegacyIntake })
$pagesLegacy = @($pageResults | Where-Object { $_.LegacyIntakeLinkPresent })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# CRM Baseline Export (Chunk 2)")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add("Read-only snapshot of the live tenant CRM state before any recovery write.")
$lines.Add("This is evidence, not a verdict. Chunk 3 (Verify-CrmSharePoint.ps1) decides PASS/FAIL.")
$lines.Add("")
$lines.Add(("Site: {0}" -f $siteUrl))
$lines.Add(("Intake list: {0} (ContentTypesEnabled={1})" -f $intakeList, $intakeContentTypesEnabled))
$lines.Add("")
$lines.Add("## Evidence files")
$lines.Add("")
$lines.Add(("- Transcript: {0}" -f $transcriptPath))
$lines.Add(("- Lists CSV: {0}" -f $listCsvPath))
$lines.Add(("- Fields CSV: {0}" -f $fieldCsvPath))
$lines.Add(("- Lookups CSV: {0}" -f $lookupCsvPath))
$lines.Add(("- Views CSV: {0}" -f $viewCsvPath))
$lines.Add(("- Blocked-fields CSV: {0}" -f $blockedCsvPath))
$lines.Add(("- Intake-fields CSV: {0}" -f $intakeCsvPath))
$lines.Add(("- Pages CSV: {0}" -f $pageCsvPath))
$lines.Add(("- Navigation CSV: {0}" -f $navCsvPath))
$lines.Add(("- Full JSON snapshot: {0}" -f $snapshotJsonPath))
$lines.Add("")
$lines.Add("## Observations (for Chunk 3 to act on)")
$lines.Add("")
$lines.Add("| Observation | Count |")
$lines.Add("|---|---:|")
$lines.Add(("| Configured lists missing | {0} |" -f $missingLists.Count))
$lines.Add(("| Blocked technical fields present on intake list | {0} |" -f $blockedPresent.Count))
$lines.Add(("| ...of those, visible in the daily form (Stage 8C failure) | {0} |" -f $blockedVisible.Count))
$lines.Add(("| Nav nodes routing to legacy Intake Register NewForm | {0} |" -f $navLegacy.Count))
$lines.Add(("| Pages with legacy Intake Register link in body | {0} |" -f $pagesLegacy.Count))
$lines.Add("")
if ($missingLists.Count -gt 0) {
    $lines.Add("Missing lists:")
    foreach ($m in $missingLists) { $lines.Add(("- {0} ({1})" -f $m.List, $m.Role)) }
    $lines.Add("")
}
if ($blockedVisible.Count -gt 0) {
    $lines.Add("Blocked fields visible in the daily intake form (must be hidden by Chunk 5):")
    foreach ($b in $blockedVisible) { $lines.Add(("- {0}: ShowInNewForm={1}, ShowInEditForm={2}" -f $b.BlockedField, $b.ShowInNewForm, $b.ShowInEditForm)) }
    $lines.Add("")
}
if ($navLegacy.Count -gt 0) {
    $lines.Add("Navigation nodes routing to the legacy intake (must be removed/relabelled admin-only):")
    foreach ($n in $navLegacy) { $lines.Add(("- {0} > {1} -> {2}" -f $n.ParentTitle, $n.Title, $n.Url)) }
    $lines.Add("")
}

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try { Disconnect-PnPOnline | Out-Null } catch {}

Write-Host ""
Write-Host ("Baseline export complete: {0}" -f $summaryPath) -ForegroundColor Green
Write-Host ("Lists missing: {0} | Blocked-visible: {1} | Nav-legacy: {2}" -f $missingLists.Count, $blockedVisible.Count, $navLegacy.Count) -ForegroundColor Gray

try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
