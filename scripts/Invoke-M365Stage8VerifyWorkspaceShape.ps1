param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_WORKSPACE_SHAPE.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\stage-8-client-workspace-reference\workspace-shape",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8 - read-only SharePoint workspace shape verification.
# Verifies expected modern pages and resolvable Quick Launch links. It does not
# create pages, change navigation, alter permissions, invite guests, or change
# tenant/site policy.

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

function Resolve-ExpectedNavigationTarget {
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
            return Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target ("SitePages/{0}" -f $pageByTitle[$pageTitle])
        }
    }

    if ($pageByTitle.ContainsKey($LinkTitle)) {
        return Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target ("SitePages/{0}" -f $pageByTitle[$LinkTitle])
    }

    $knownLists = @{
        "Action Log" = "Lists/Agent%20Action%20Log/AllItems.aspx"
        "Agent Action Log" = "Lists/Agent%20Action%20Log/AllItems.aspx"
        "Decision Register" = "Lists/Decision%20Register/AllItems.aspx"
    }

    if ($knownLists.ContainsKey($LinkTitle)) {
        return Get-SiteRelativeUrl -SiteUrl $Config.site.url -Target $knownLists[$LinkTitle]
    }

    return $null
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
$transcriptPath = Join-Path $resolvedOutputRoot ("stage-8-workspace-shape-verify-{0}.log" -f $timestamp)
$pageCsvPath = Join-Path $resolvedOutputRoot ("stage-8-workspace-shape-pages-{0}.csv" -f $timestamp)
$navCsvPath = Join-Path $resolvedOutputRoot ("stage-8-workspace-shape-navigation-{0}.csv" -f $timestamp)
$summaryPath = Join-Path $resolvedOutputRoot "STAGE_8_WORKSPACE_SHAPE_VERIFY.md"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8 - Workspace Shape Verification" -ForegroundColor Cyan
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Scope: read-only page and navigation verification." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1, which prefers pwsh.exe."
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

$navTree = @(Get-PnPNavigationNode -Location QuickLaunch -Tree)
$flatNav = New-Object System.Collections.Generic.List[object]
foreach ($item in @(ConvertTo-FlatNavigation -Nodes $navTree)) {
    $flatNav.Add($item)
}

# PnP 3.x can return Quick Launch top-level nodes without flattening child
# nodes in the normal -Tree output. Read each top-level node directly so child
# links added with -Parent are included in verification.
$topNav = @(Get-PnPNavigationNode -Location QuickLaunch)
foreach ($topNode in $topNav) {
    $nodeWithChildren = $null
    try {
        $nodeWithChildren = Get-PnPNavigationNode -Id $topNode.Id -ErrorAction Stop
    }
    catch {
        $nodeWithChildren = $null
    }

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

$navResults = foreach ($group in $config.navigationGroups) {
    $groupTitle = [string]$group.title
    foreach ($link in $group.links) {
        $expectedUrl = Resolve-ExpectedNavigationTarget -Config $config -LinkTitle ([string]$link)
        if ([string]::IsNullOrWhiteSpace($expectedUrl)) {
            [pscustomobject]@{
                Group = $groupTitle
                Link = [string]$link
                ExpectedUrl = ""
                Status = "Deferred"
                ActualUrl = ""
            }
            continue
        }

        $match = @($flatNav | Where-Object { $_.ParentTitle -eq $groupTitle -and $_.Title -eq [string]$link } | Select-Object -First 1)
        [pscustomobject]@{
            Group = $groupTitle
            Link = [string]$link
            ExpectedUrl = $expectedUrl
            Status = if ($match.Count -gt 0) { "Present" } else { "Missing" }
            ActualUrl = if ($match.Count -gt 0) { [string]$match[0].Url } else { "" }
        }
    }
}

$pageResults | Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8
$navResults | Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$missingPages = @($pageResults | Where-Object { -not $_.Exists })
$missingNav = @($navResults | Where-Object { $_.Status -eq "Missing" })
$deferredNav = @($navResults | Where-Object { $_.Status -eq "Deferred" })
$result = if ($missingPages.Count -eq 0 -and $missingNav.Count -eq 0) { "PASS" } else { "PARTIAL" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Workspace Shape Verification")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add(("Result: {0}" -f $result))
$lines.Add("")
$lines.Add(("Site: {0}" -f $config.site.url))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
$lines.Add(("Page CSV: {0}" -f $pageCsvPath))
$lines.Add(("Navigation CSV: {0}" -f $navCsvPath))
$lines.Add("")
$lines.Add("## Page Results")
$lines.Add("")
$lines.Add("| Status | Page | File | Actual title |")
$lines.Add("|---|---|---|---|")
foreach ($pageResult in $pageResults) {
    $status = if ($pageResult.Exists) { "PASS" } else { "MISSING" }
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $status, $pageResult.Title, $pageResult.FileName, $pageResult.ActualTitle))
}
$lines.Add("")
$lines.Add("## Navigation Results")
$lines.Add("")
$lines.Add("| Status | Group | Link | Expected URL | Actual URL |")
$lines.Add("|---|---|---|---|---|")
foreach ($navResult in $navResults) {
    $lines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f $navResult.Status, $navResult.Group, $navResult.Link, $navResult.ExpectedUrl, $navResult.ActualUrl))
}
$lines.Add("")
$lines.Add(("Deferred navigation links are intentional until their backing pages, Lists, or libraries exist: {0}" -f $deferredNav.Count))
$lines.Add("")

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

$resultColor = if ($result -eq "PASS") { "Green" } else { "Yellow" }
Write-Host ("Stage 8 workspace shape verification {0}: {1}" -f $result, $summaryPath) -ForegroundColor $resultColor

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
