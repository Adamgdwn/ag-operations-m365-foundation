param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_WORKSPACE_SHAPE.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$IncludePlaceholderNavigation,
    [switch]$NoPause
)

# Stage 8 - approval-gated SharePoint workspace shape builder.
# Dry-run by default. With -Apply and typed approval, it creates missing modern
# pages and adds resolvable Quick Launch navigation nodes. It does not change
# permissions, invite guests, publish public links/forms, revoke app grants,
# delete pages, overwrite existing pages, or create client-facing automation.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-8-client-workspace-reference\workspace-shape"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-8-workspace-shape-build-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function ConvertTo-HtmlList {
    param([object[]]$Items)

    $lines = foreach ($item in $Items) {
        "<li>$([System.Net.WebUtility]::HtmlEncode([string]$item))</li>"
    }

    return "<ul>$($lines -join '')</ul>"
}

function New-PageTextHtml {
    param([object]$Page)

    $title = [System.Net.WebUtility]::HtmlEncode([string]$Page.title)
    $role = [System.Net.WebUtility]::HtmlEncode([string]$Page.role)
    $sources = ConvertTo-HtmlList -Items $Page.sourceOfTruth
    $sections = ConvertTo-HtmlList -Items $Page.sections

    return @"
<h2>$title</h2>
<p><strong>Role:</strong> $role</p>
<h3>Source of truth</h3>
$sources
<h3>Operating sections</h3>
$sections
<p><em>Generated from the Stage 8 workspace shape config. This page is a routing surface; Lists, Planner, libraries, and decisions remain the durable records.</em></p>
"@
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

function Resolve-NavigationTarget {
    param(
        [object]$Config,
        [string]$LinkTitle
    )

    $pageByTitle = @{}
    foreach ($page in $Config.pages) {
        $pageByTitle[[string]$page.title] = [string]$page.fileName
    }

    $aliases = @{
        "Home" = "Guided AI Labs Home"
        "How To Use This Workspace" = "How To Use This Workspace"
        "Intake" = "Intake"
        "Active Delivery" = "Active Delivery"
        "Decisions" = "Decisions"
        "Client Workspace Pattern" = "Client Workspace Pattern"
        "Methods And IP" = "Methods And IP"
        "AI And Automation Governance" = "AI And Automation Governance"
    }

    if ($aliases.ContainsKey($LinkTitle)) {
        $pageTitle = $aliases[$LinkTitle]
        if ($pageByTitle.ContainsKey($pageTitle)) {
            return [pscustomobject]@{
                Resolved = $true
                Url = Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target ("SitePages/{0}" -f $pageByTitle[$pageTitle])
                Kind = "Page"
                Note = $pageTitle
            }
        }
    }

    if ($pageByTitle.ContainsKey($LinkTitle)) {
        return [pscustomobject]@{
            Resolved = $true
            Url = Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target ("SitePages/{0}" -f $pageByTitle[$LinkTitle])
            Kind = "Page"
            Note = $LinkTitle
        }
    }

    $knownLists = @{
        "Action Log" = "Lists/Agent%20Action%20Log/AllItems.aspx"
        "Agent Action Log" = "Lists/Agent%20Action%20Log/AllItems.aspx"
        "Decision Register" = "Lists/Decision%20Register/AllItems.aspx"
    }

    if ($knownLists.ContainsKey($LinkTitle)) {
        return [pscustomobject]@{
            Resolved = $true
            Url = Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target $knownLists[$LinkTitle]
            Kind = "ExistingList"
            Note = $LinkTitle
        }
    }

    if ($IncludePlaceholderNavigation) {
        return [pscustomobject]@{
            Resolved = $true
            Url = $Config.site.url
            Kind = "Placeholder"
            Note = "Placeholder target; replace after backing page/list/library exists."
        }
    }

    return [pscustomobject]@{
        Resolved = $false
        Url = $null
        Kind = "Deferred"
        Note = "No concrete backing page/list/library target yet."
    }
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8 - Workspace Shape Build" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned page skeletons:" -ForegroundColor Cyan
foreach ($page in $config.pages) {
    Write-Host ("- {0} ({1})" -f $page.title, $page.fileName) -ForegroundColor White
}

Write-Host ""
Write-Host "Planned navigation additions:" -ForegroundColor Cyan
foreach ($group in $config.navigationGroups) {
    Write-Host ("- {0}" -f $group.title) -ForegroundColor White
    foreach ($link in $group.links) {
        $target = Resolve-NavigationTarget -Config $config -LinkTitle ([string]$link)
        $status = if ($target.Resolved) { "ready" } else { "deferred" }
        Write-Host ("  - {0}: {1} ({2})" -f $link, $status, $target.Note) -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Safety limits: no permissions, guest invites, external sharing, app grants, public Forms, page deletion, or existing page overwrite." -ForegroundColor Yellow
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to create missing pages/navigation." -ForegroundColor Green
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
    exit 0
}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$approval = Read-Host "Type 'apply-stage-8-workspace-shape' to create missing Stage 8 pages/navigation"
if ($approval -ne "apply-stage-8-workspace-shape") {
    Write-Host "Approval phrase did not match. Nothing was changed." -ForegroundColor Yellow
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
    exit 0
}

Write-Host ""
Write-Host "Connecting to Guided AI Labs SharePoint site..." -ForegroundColor Cyan
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

foreach ($page in $config.pages) {
    $existingPage = $null
    try {
        $existingPage = Get-PnPPage -Identity ([string]$page.fileName) -ErrorAction Stop
    }
    catch {
        $existingPage = $null
    }

    if ($null -ne $existingPage) {
        Write-Host ("Page exists; leaving unchanged: {0}" -f $page.fileName) -ForegroundColor Yellow
        continue
    }

    Write-Host ("Creating page: {0}" -f $page.fileName) -ForegroundColor Cyan
    Add-PnPPage -Name ([string]$page.fileName) -LayoutType Article -HeaderLayoutType NoImage -CommentsEnabled:$false | Out-Null
    Add-PnPPageSection -Page ([string]$page.fileName) -SectionTemplate OneColumn -Order 1 | Out-Null
    Add-PnPPageTextPart -Page ([string]$page.fileName) -Section 1 -Column 1 -Order 1 -Text (New-PageTextHtml -Page $page) | Out-Null
    Set-PnPPage -Identity ([string]$page.fileName) -Title ([string]$page.title) -Publish | Out-Null
    Write-Host ("  [OK] {0}" -f $page.title) -ForegroundColor Green
}

$topNodes = @(Get-PnPNavigationNode -Location QuickLaunch)
foreach ($group in $config.navigationGroups) {
    $groupTitle = [string]$group.title
    $groupNode = @($topNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1)

    if ($groupNode.Count -eq 0) {
        Write-Host ("Creating navigation group: {0}" -f $groupTitle) -ForegroundColor Cyan
        $groupNode = Add-PnPNavigationNode -Location QuickLaunch -Title $groupTitle -Url ([string]$config.site.url)
        $topNodes += $groupNode
    }
    else {
        $groupNode = $groupNode[0]
        Write-Host ("Navigation group exists: {0}" -f $groupTitle) -ForegroundColor Yellow
    }

    $tree = @(Get-PnPNavigationNode -Location QuickLaunch -Tree)
    $currentGroup = @($tree | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1)
    $existingChildren = @()
    if ($currentGroup.Count -gt 0 -and $null -ne $currentGroup[0].Children) {
        $existingChildren = @($currentGroup[0].Children)
    }

    foreach ($link in $group.links) {
        $linkTitle = [string]$link
        $target = Resolve-NavigationTarget -Config $config -LinkTitle $linkTitle
        if (-not $target.Resolved) {
            Write-Host ("  Deferred navigation link: {0} ({1})" -f $linkTitle, $target.Note) -ForegroundColor DarkYellow
            continue
        }

        $existingLink = @($existingChildren | Where-Object { $_.Title -eq $linkTitle } | Select-Object -First 1)
        if ($existingLink.Count -gt 0) {
            Write-Host ("  Link exists; leaving unchanged: {0}" -f $linkTitle) -ForegroundColor Yellow
            continue
        }

        Write-Host ("  Adding link: {0} -> {1}" -f $linkTitle, $target.Url) -ForegroundColor Cyan
        Add-PnPNavigationNode -Location QuickLaunch -Title $linkTitle -Url ([string]$target.Url) -Parent $groupNode | Out-Null
        Write-Host ("    [OK] {0}" -f $linkTitle) -ForegroundColor Green
    }
}

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

Write-Host ""
Write-Host "Stage 8 workspace shape build complete. Review the Guided AI Labs site pages/navigation in the browser before adding Lists, libraries, or permissions." -ForegroundColor Green

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
