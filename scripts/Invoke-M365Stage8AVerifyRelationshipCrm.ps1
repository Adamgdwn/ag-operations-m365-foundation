param(
    [string]$ConfigPath = ".\config\M365_STAGE_8A_RELATIONSHIP_CRM.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\stage-8a-relationship-crm",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8A - read-only Relationship CRM verification.
# Verifies expected CRM page, Lists, fields, views, and navigation link. It
# performs no tenant writes.

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
$transcriptPath = Join-Path $resolvedOutputRoot ("stage-8a-relationship-crm-verify-{0}.log" -f $timestamp)
$pageCsvPath = Join-Path $resolvedOutputRoot ("stage-8a-relationship-crm-pages-{0}.csv" -f $timestamp)
$listCsvPath = Join-Path $resolvedOutputRoot ("stage-8a-relationship-crm-lists-{0}.csv" -f $timestamp)
$navCsvPath = Join-Path $resolvedOutputRoot ("stage-8a-relationship-crm-navigation-{0}.csv" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "STAGE_8A_RELATIONSHIP_CRM_VERIFY.md"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8A - Relationship CRM Verification" -ForegroundColor Cyan
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Scope: read-only verification." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1, which prefers pwsh.exe."
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

$pageResults = foreach ($page in $config.pages) {
    $found = $null
    try {
        $found = Get-PnPPage -Identity ([string]$page.fileName) -ErrorAction Stop
    }
    catch {
        $found = $null
    }

    [pscustomobject]@{
        Title = [string]$page.title
        FileName = [string]$page.fileName
        Exists = ($null -ne $found)
        ActualTitle = if ($null -ne $found) { [string]$found.PageTitle } else { "" }
    }
}

$listResults = foreach ($list in $config.lists) {
    $existingList = Get-PnPList -Identity ([string]$list.title) -ErrorAction SilentlyContinue
    if ($null -eq $existingList) {
        [pscustomobject]@{
            Title = [string]$list.title
            Exists = $false
            MissingFields = (($list.columns | ForEach-Object { [string]$_.internalName }) -join "; ")
            MissingViews = (($list.views | ForEach-Object { [string]$_.title }) -join "; ")
            Status = "Missing"
        }
        continue
    }

    $missingFields = @()
    foreach ($column in $list.columns) {
        $field = Get-PnPField -List ([string]$list.title) -Identity ([string]$column.internalName) -ErrorAction SilentlyContinue
        if ($null -eq $field) {
            $missingFields += [string]$column.internalName
        }
    }

    $missingViews = @()
    foreach ($view in $list.views) {
        $existingView = Get-PnPView -List ([string]$list.title) -Identity ([string]$view.title) -ErrorAction SilentlyContinue
        if ($null -eq $existingView) {
            $missingViews += [string]$view.title
        }
    }

    [pscustomobject]@{
        Title = [string]$list.title
        Exists = $true
        MissingFields = ($missingFields -join "; ")
        MissingViews = ($missingViews -join "; ")
        Status = if ($missingFields.Count -eq 0 -and $missingViews.Count -eq 0) { "Present" } else { "Partial" }
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

$pageResults | Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8
$listResults | Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8
$navResults | Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$missingPages = @($pageResults | Where-Object { -not $_.Exists })
$partialLists = @($listResults | Where-Object { $_.Status -ne "Present" })
$missingNav = @($navResults | Where-Object { $_.Status -ne "Present" })
$result = if ($missingPages.Count -eq 0 -and $partialLists.Count -eq 0 -and $missingNav.Count -eq 0) { "PASS" } else { "PARTIAL" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8A Relationship CRM Verification")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add(("Result: {0}" -f $result))
$lines.Add("")
$lines.Add(("Site: {0}" -f $config.site.url))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
$lines.Add(("Page CSV: {0}" -f $pageCsvPath))
$lines.Add(("List CSV: {0}" -f $listCsvPath))
$lines.Add(("Navigation CSV: {0}" -f $navCsvPath))
$lines.Add("")
$lines.Add("## Pages")
$lines.Add("")
$lines.Add("| Status | Page | File |")
$lines.Add("|---|---|---|")
foreach ($pageResult in $pageResults) {
    $lines.Add(("| {0} | {1} | {2} |" -f ($(if ($pageResult.Exists) { "PASS" } else { "MISSING" })), $pageResult.Title, $pageResult.FileName))
}
$lines.Add("")
$lines.Add("## Lists")
$lines.Add("")
$lines.Add("| Status | List | Missing fields | Missing views |")
$lines.Add("|---|---|---|---|")
foreach ($listResult in $listResults) {
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $listResult.Status, $listResult.Title, $listResult.MissingFields, $listResult.MissingViews))
}
$lines.Add("")
$lines.Add("## Navigation")
$lines.Add("")
$lines.Add("| Status | Group | Link | Expected URL | Actual URL |")
$lines.Add("|---|---|---|---|---|")
foreach ($navResult in $navResults) {
    $lines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f $navResult.Status, $navResult.Group, $navResult.Link, $navResult.ExpectedUrl, $navResult.ActualUrl))
}
$lines.Add("")

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

$resultColor = if ($result -eq "PASS") { "Green" } else { "Yellow" }
Write-Host ("Stage 8A Relationship CRM verification {0}: {1}" -f $result, $summaryPath) -ForegroundColor $resultColor

try {
    Stop-Transcript | Out-Null
}
catch {
}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
