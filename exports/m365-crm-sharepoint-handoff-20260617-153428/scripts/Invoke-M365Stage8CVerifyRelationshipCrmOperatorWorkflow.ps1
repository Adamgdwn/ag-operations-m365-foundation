param(
    [string]$ConfigPath = ".\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\stage-8c-relationship-crm-operator-workflow",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8C - read-only Relationship CRM operator workflow verification.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Get-SiteRelativeUrl {
    param(
        [string]$SiteUrl,
        [string]$Target
    )

    $siteUri = [System.Uri]$SiteUrl
    $path = $siteUri.AbsolutePath.TrimEnd("/")
    if ($path -eq "") {
        return "/$($Target.TrimStart('/'))"
    }

    return "$path/$($Target.TrimStart('/'))"
}

function Get-ListUrl {
    param([string]$Title)

    $list = Get-PnPList -Identity $Title -Includes DefaultViewUrl,RootFolder
    if (-not [string]::IsNullOrWhiteSpace([string]$list.DefaultViewUrl)) {
        return [string]$list.DefaultViewUrl
    }

    return ([string]$list.RootFolder.ServerRelativeUrl)
}

function Get-FieldFormExperience {
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
        ShowInNewForm = if ([string]::IsNullOrWhiteSpace($showInNewForm)) { "DefaultTrue" } else { $showInNewForm }
        ShowInEditForm = if ([string]::IsNullOrWhiteSpace($showInEditForm)) { "DefaultTrue" } else { $showInEditForm }
        ShowInDisplayForm = if ([string]::IsNullOrWhiteSpace($showInDisplayForm)) { "DefaultTrue" } else { $showInDisplayForm }
    }
}

function Test-FormFlagVisible {
    param([string]$Value)

    return ([string]$Value -notin @("FALSE", "False", "false", "0"))
}

function Resolve-NavigationUrl {
    param(
        [object]$Config,
        [object]$Target
    )

    $kind = [string]$Target.kind
    $value = [string]$Target.target

    switch ($kind) {
        "Page" {
            $page = @($Config.pages | Where-Object { [string]$_.title -eq $value } | Select-Object -First 1)
            if ($page.Count -eq 0) {
                return ""
            }
            return Get-SiteRelativeUrl -SiteUrl ([string]$Config.site.url) -Target ("SitePages/{0}" -f $page[0].fileName)
        }
        "List" {
            return Get-ListUrl -Title $value
        }
        default {
            return ""
        }
    }
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

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-operator-workflow-verify-{0}.log" -f $timestamp)
$listCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-lists-{0}.csv" -f $timestamp)
$fieldCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-fields-{0}.csv" -f $timestamp)
$lookupCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-lookups-{0}.csv" -f $timestamp)
$viewCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-views-{0}.csv" -f $timestamp)
$pageCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-pages-{0}.csv" -f $timestamp)
$navCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-workflow-navigation-{0}.csv" -f $timestamp)
$intakeCsvPath = Join-Path $resolvedOutputRoot ("stage-8c-crm-intake-experience-{0}.csv" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_VERIFY.md"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8C - Relationship CRM Operator Workflow Verification" -ForegroundColor Cyan
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Scope: read-only verification." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{
    Url = [string]$config.site.url
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

$listResults = foreach ($list in $config.lists) {
    $found = Get-PnPList -Identity ([string]$list.title) -ErrorAction SilentlyContinue
    [pscustomobject]@{
        List = [string]$list.title
        Exists = ($null -ne $found)
        Status = if ($null -ne $found) { "Present" } else { "Missing" }
    }
}

$fieldResults = foreach ($list in $config.lists) {
    foreach ($column in $list.columns) {
        $field = Get-PnPField -List ([string]$list.title) -Identity ([string]$column.internalName) -Includes TypeAsString,Indexed,Required -ErrorAction SilentlyContinue
        [pscustomobject]@{
            List = [string]$list.title
            Field = [string]$column.displayName
            InternalName = [string]$column.internalName
            ExpectedType = [string]$column.type
            Exists = ($null -ne $field)
            ActualType = if ($null -ne $field) { [string]$field.TypeAsString } else { "" }
            Indexed = if ($null -ne $field) { [string]$field.Indexed } else { "" }
            Status = if ($null -ne $field) { "Present" } else { "Missing" }
        }
    }
}

$lookupResults = foreach ($list in $config.lists) {
    foreach ($lookup in $list.lookupFields) {
        $field = Get-PnPField -List ([string]$list.title) -Identity ([string]$lookup.internalName) -Includes TypeAsString,Indexed -ErrorAction SilentlyContinue
        [pscustomobject]@{
            List = [string]$list.title
            Field = [string]$lookup.displayName
            InternalName = [string]$lookup.internalName
            TargetList = [string]$lookup.targetList
            Exists = ($null -ne $field)
            Type = if ($null -ne $field) { [string]$field.TypeAsString } else { "" }
            Indexed = if ($null -ne $field) { [string]$field.Indexed } else { "" }
            Status = if ($null -ne $field -and [string]$field.TypeAsString -eq "Lookup") { "Present" } elseif ($null -ne $field) { "WrongType" } else { "Missing" }
        }
    }
}

$viewResults = foreach ($list in $config.lists) {
    foreach ($view in $list.views) {
        $existingView = Get-PnPView -List ([string]$list.title) -Identity ([string]$view.title) -Includes ViewQuery,ViewFields,RowLimit -ErrorAction SilentlyContinue
        $hasQuery = $false
        if ($null -ne $existingView) {
            $hasQuery = -not [string]::IsNullOrWhiteSpace([string]$existingView.ViewQuery)
        }

        [pscustomobject]@{
            List = [string]$list.title
            View = [string]$view.title
            Exists = ($null -ne $existingView)
            HasQuery = $hasQuery
            RowLimit = if ($null -ne $existingView) { [string]$existingView.RowLimit } else { "" }
            Status = if ($null -ne $existingView -and $hasQuery) { "Present" } elseif ($null -ne $existingView) { "NoQuery" } else { "Missing" }
        }
    }
}

$pageResults = foreach ($page in $config.pages) {
    $found = $null
    try {
        $found = Get-PnPPage -Identity ([string]$page.fileName) -ErrorAction Stop
    }
    catch {
        $found = $null
    }

    $stagePathPresent = $false
    if ($null -ne $found) {
        try {
            $components = @(Get-PnPPageComponent -Page ([string]$page.fileName) -ErrorAction SilentlyContinue)
            $pageText = @($components | Where-Object { [string]$_.Type -like "*PageText*" -or [string]$_.ControlType -eq "4" } | ForEach-Object { [string]$_.Text }) -join "`n"
            $stagePathPresent = (
                $pageText -like "*CRM stage path*" -and
                $pageText -like "*Add intake signal*" -and
                $pageText -like "*Use this as the CRM workspace*" -and
                $pageText -like "*Engagement Pipeline*" -and
                $pageText -like "*Handoff Evidence*"
            )
        }
        catch {
            $stagePathPresent = $false
        }
    }

    [pscustomobject]@{
        Title = [string]$page.title
        FileName = [string]$page.fileName
        Exists = ($null -ne $found)
        ContentStatus = if ($stagePathPresent) { "StagePathPresent" } elseif ($null -ne $found) { "StagePathMissing" } else { "" }
        Status = if ($null -ne $found -and $stagePathPresent) { "Present" } elseif ($null -ne $found) { "ContentMissing" } else { "Missing" }
    }
}

$flatNav = New-Object System.Collections.Generic.List[object]
$navTree = @(Get-PnPNavigationNode -Location QuickLaunch -Tree)
foreach ($item in @(ConvertTo-FlatNavigation -Nodes $navTree)) {
    $flatNav.Add($item)
}

$topNav = @(Get-PnPNavigationNode -Location QuickLaunch)
foreach ($topNode in $topNav) {
    $nodeWithChildren = Get-PnPNavigationNode -Id $topNode.Id -ErrorAction SilentlyContinue
    if ($null -eq $nodeWithChildren -or $null -eq $nodeWithChildren.Children) {
        continue
    }

    foreach ($child in @($nodeWithChildren.Children)) {
        $flatNav.Add([pscustomobject]@{
            ParentTitle = [string]$nodeWithChildren.Title
            Title = [string]$child.Title
            Url = [string]$child.Url
        })
    }
}

$intakeResults = @()
if ($config.PSObject.Properties.Name -contains "intakeExperience") {
    $intake = $config.intakeExperience
    $intakeList = [string]$intake.list
    $formatterJson = ""
    $contentTypeFound = $false
    $contentTypesEnabled = $false
    try {
        $liveIntakeList = Get-PnPList -Identity $intakeList -Includes ContentTypesEnabled -ErrorAction Stop
        $contentTypesEnabled = [bool]$liveIntakeList.ContentTypesEnabled
    }
    catch {
        $contentTypesEnabled = $false
    }

    $intakeResults += [pscustomobject]@{
        Area = "Form mode"
        Item = $intakeList
        Expected = "ContentTypesEnabled=True"
        Actual = "ContentTypesEnabled=$contentTypesEnabled"
        Status = if ($contentTypesEnabled) { "Present" } else { "Mismatch" }
    }

    try {
        $clientContext = Get-PnPContext
        $contentType = Get-PnPContentType -List $intakeList | Where-Object { $_.Name -eq [string]$intake.contentTypeName } | Select-Object -First 1
        if ($null -ne $contentType) {
            $clientContext.Load($contentType)
            $clientContext.ExecuteQuery()
            $formatterJson = [string]$contentType.ClientFormCustomFormatter
            $contentTypeFound = $true
        }
    }
    catch {
        $formatterJson = ""
    }

    $intakeResults += [pscustomobject]@{
        Area = "Form formatter"
        Item = $intakeList
        Expected = [string]$intake.contentTypeName
        Actual = if ($contentTypeFound) { "ContentTypePresent" } else { "ContentTypeMissing" }
        Status = if ($contentTypeFound -and $formatterJson -like "*Quick intake*" -and $formatterJson -like "*Triage*") { "Present" } else { "Missing" }
    }

    foreach ($field in $intake.friendlyFieldNames) {
        $actualField = Get-PnPField -List $intakeList -Identity ([string]$field.internalName) -Includes Title -ErrorAction SilentlyContinue
        $intakeResults += [pscustomobject]@{
            Area = "Friendly field label"
            Item = [string]$field.internalName
            Expected = [string]$field.displayName
            Actual = if ($null -ne $actualField) { [string]$actualField.Title } else { "" }
            Status = if ($null -ne $actualField -and [string]$actualField.Title -eq [string]$field.displayName) { "Present" } elseif ($null -ne $actualField) { "Mismatch" } else { "Missing" }
        }
    }

    foreach ($fieldName in $intake.notRequiredFields) {
        $actualField = Get-PnPField -List $intakeList -Identity ([string]$fieldName) -Includes Required -ErrorAction SilentlyContinue
        $intakeResults += [pscustomobject]@{
            Area = "Manual intake blocker"
            Item = [string]$fieldName
            Expected = "Required=False"
            Actual = if ($null -ne $actualField) { "Required=$($actualField.Required)" } else { "" }
            Status = if ($null -ne $actualField -and $actualField.Required -eq $false) { "Present" } elseif ($null -ne $actualField) { "Mismatch" } else { "Missing" }
        }
    }

    $visibleFormFields = @($intake.formSections | ForEach-Object { @($_.fields) }) | ForEach-Object { [string]$_ }
    foreach ($fieldName in $visibleFormFields) {
        $formExperience = Get-FieldFormExperience -ListTitle $intakeList -FieldName ([string]$fieldName)
        $isShownOnForm = (
            $null -ne $formExperience -and
            (Test-FormFlagVisible -Value ([string]$formExperience.ShowInNewForm)) -and
            (Test-FormFlagVisible -Value ([string]$formExperience.ShowInEditForm))
        )
        $intakeResults += [pscustomobject]@{
            Area = "Visible intake form field"
            Item = [string]$fieldName
            Expected = "FormatterContainsField; ShowInNewForm=True; ShowInEditForm=True"
            Actual = if ($null -ne $formExperience) {
                "FormatterContainsField=$($formatterJson -like "*$fieldName*"); ShowInNewForm=$($formExperience.ShowInNewForm); ShowInEditForm=$($formExperience.ShowInEditForm)"
            }
            else {
                ""
            }
            Status = if (($formatterJson -like "*$fieldName*") -and ($isShownOnForm -or $contentTypesEnabled)) { "Present" } elseif ($null -ne $formExperience) { "Mismatch" } else { "Missing" }
        }
    }

    foreach ($fieldName in $intake.readOnlySystemFields) {
        $formExperience = Get-FieldFormExperience -ListTitle $intakeList -FieldName ([string]$fieldName)
        $formatterContainsField = ($formatterJson -like "*$fieldName*")
        $isNonBlocking = ($null -ne $formExperience -and $formExperience.Required -eq $false)
        $isHiddenFromForm = (
            $null -ne $formExperience -and
            -not (Test-FormFlagVisible -Value ([string]$formExperience.ShowInNewForm)) -and
            -not (Test-FormFlagVisible -Value ([string]$formExperience.ShowInEditForm))
        )
        $intakeResults += [pscustomobject]@{
            Area = "Hidden system field"
            Item = [string]$fieldName
            Expected = "Not in formatter; Required=False; ShowInNewForm=False; ShowInEditForm=False"
            Actual = if ($null -ne $formExperience) {
                "FormatterContainsField=$formatterContainsField; Required=$($formExperience.Required); ShowInNewForm=$($formExperience.ShowInNewForm); ShowInEditForm=$($formExperience.ShowInEditForm)"
            }
            else {
                ""
            }
            Status = if ((-not $formatterContainsField) -and $isNonBlocking -and ($isHiddenFromForm -or $contentTypesEnabled)) { "Present" } elseif ($null -ne $formExperience) { "Mismatch" } else { "Missing" }
        }
    }
}

$navResults = foreach ($target in $config.navigationTargets) {
    $expectedUrl = ""
    try {
        $expectedUrl = Resolve-NavigationUrl -Config $config -Target $target
    }
    catch {
        $expectedUrl = ""
    }

    $match = @($flatNav | Where-Object { $_.ParentTitle -eq [string]$target.group -and $_.Title -eq [string]$target.link } | Select-Object -First 1)
    [pscustomobject]@{
        Group = [string]$target.group
        Link = [string]$target.link
        Kind = [string]$target.kind
        ExpectedUrl = $expectedUrl
        Status = if ($match.Count -gt 0) { "Present" } else { "Missing" }
        ActualUrl = if ($match.Count -gt 0) { [string]$match[0].Url } else { "" }
    }
}

$listResults | Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8
$fieldResults | Export-Csv -LiteralPath $fieldCsvPath -NoTypeInformation -Encoding UTF8
$lookupResults | Export-Csv -LiteralPath $lookupCsvPath -NoTypeInformation -Encoding UTF8
$viewResults | Export-Csv -LiteralPath $viewCsvPath -NoTypeInformation -Encoding UTF8
$pageResults | Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8
$navResults | Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8
$intakeResults | Export-Csv -LiteralPath $intakeCsvPath -NoTypeInformation -Encoding UTF8

$badLists = @($listResults | Where-Object { $_.Status -ne "Present" })
$badFields = @($fieldResults | Where-Object { $_.Status -ne "Present" })
$badLookups = @($lookupResults | Where-Object { $_.Status -ne "Present" })
$badViews = @($viewResults | Where-Object { $_.Status -ne "Present" })
$badPages = @($pageResults | Where-Object { $_.Status -ne "Present" })
$badNav = @($navResults | Where-Object { $_.Status -ne "Present" })
$badIntake = @($intakeResults | Where-Object { $_.Status -ne "Present" })
$result = if ($badLists.Count -eq 0 -and $badFields.Count -eq 0 -and $badLookups.Count -eq 0 -and $badViews.Count -eq 0 -and $badPages.Count -eq 0 -and $badNav.Count -eq 0 -and $badIntake.Count -eq 0) { "PASS" } else { "PARTIAL" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8C Relationship CRM Operator Workflow Verification")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add(("Result: {0}" -f $result))
$lines.Add("")
$lines.Add(("Site: {0}" -f $config.site.url))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
$lines.Add(("List CSV: {0}" -f $listCsvPath))
$lines.Add(("Field CSV: {0}" -f $fieldCsvPath))
$lines.Add(("Lookup CSV: {0}" -f $lookupCsvPath))
$lines.Add(("View CSV: {0}" -f $viewCsvPath))
$lines.Add(("Page CSV: {0}" -f $pageCsvPath))
$lines.Add(("Navigation CSV: {0}" -f $navCsvPath))
$lines.Add(("Intake experience CSV: {0}" -f $intakeCsvPath))
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
$lines.Add("| Area | Bad count |")
$lines.Add("|---|---:|")
$lines.Add(("| Lists | {0} |" -f $badLists.Count))
$lines.Add(("| Fields | {0} |" -f $badFields.Count))
$lines.Add(("| Lookup fields | {0} |" -f $badLookups.Count))
$lines.Add(("| Views | {0} |" -f $badViews.Count))
$lines.Add(("| Pages | {0} |" -f $badPages.Count))
$lines.Add(("| Navigation | {0} |" -f $badNav.Count))
$lines.Add(("| Intake experience | {0} |" -f $badIntake.Count))
$lines.Add("")
$lines.Add("## Workflow Views")
$lines.Add("")
$lines.Add("| Status | List | View | Has query |")
$lines.Add("|---|---|---|---|")
foreach ($viewResult in $viewResults) {
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $viewResult.Status, $viewResult.List, $viewResult.View, $viewResult.HasQuery))
}
$lines.Add("")

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try { Disconnect-PnPOnline | Out-Null } catch {}

$resultColor = if ($result -eq "PASS") { "Green" } else { "Yellow" }
Write-Host ("Stage 8C Relationship CRM operator workflow verification {0}: {1}" -f $result, $summaryPath) -ForegroundColor $resultColor

try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
