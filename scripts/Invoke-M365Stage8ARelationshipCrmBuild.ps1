param(
    [string]$ConfigPath = ".\config\M365_STAGE_8A_RELATIONSHIP_CRM.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8A - approval-gated Relationship CRM builder.
# Dry-run by default. With -Apply and typed approval, it creates missing CRM
# Lists, fields, views, the Relationship CRM routing page, and one Quick Launch
# link. It does not change permissions, invite guests, widen sharing, grant apps,
# publish Forms, send mail, delete anything, provision Dynamics/Dataverse, or run
# unattended automation.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-8a-relationship-crm"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-8a-relationship-crm-build-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Test-JsonProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    return ($Object.PSObject.Properties.Name -contains $Name)
}

function ConvertTo-HtmlText {
    param([string]$Value)

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function ConvertTo-HtmlList {
    param([object[]]$Items)

    $lines = foreach ($item in $Items) {
        "<li>$(ConvertTo-HtmlText -Value ([string]$item))</li>"
    }

    return "<ul>$($lines -join '')</ul>"
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

function Get-ListViewUrl {
    param(
        [string]$ListTitle,
        [string]$ViewTitle
    )

    $view = Get-PnPView -List $ListTitle -Identity $ViewTitle -ErrorAction SilentlyContinue
    if ($null -ne $view) {
        $viewUrl = [string]$view.ServerRelativeUrl
        if (-not [string]::IsNullOrWhiteSpace($viewUrl)) {
            return $viewUrl
        }
    }

    return Get-ListUrl -Title $ListTitle
}

function Add-Stage8AField {
    param(
        [string]$ListTitle,
        [object]$Column
    )

    $existing = Get-PnPField -List $ListTitle -Identity ([string]$Column.internalName) -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] Field exists: {0}" -f $Column.displayName) -ForegroundColor Gray
        return
    }

    $params = @{
        List = $ListTitle
        DisplayName = [string]$Column.displayName
        InternalName = [string]$Column.internalName
        Type = [string]$Column.type
        AddToDefaultView = $true
    }

    if ((Test-JsonProperty -Object $Column -Name "required") -and $Column.required -eq $true) {
        $params.Required = $true
    }

    if ([string]$Column.type -eq "Choice") {
        $params.Choices = @($Column.choices | ForEach-Object { [string]$_ })
    }

    Add-PnPField @params | Out-Null
    Write-Host ("  [OK] Field created: {0}" -f $Column.displayName) -ForegroundColor Green

    if (Test-JsonProperty -Object $Column -Name "default") {
        try {
            Set-PnPField -List $ListTitle -Identity ([string]$Column.internalName) -Values @{ DefaultValue = [string]$Column.default } | Out-Null
        }
        catch {
            Write-Host ("  [warn] Could not set default for {0}: {1}" -f $Column.displayName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

function Add-Stage8AView {
    param(
        [string]$ListTitle,
        [object]$View
    )

    $existing = Get-PnPView -List $ListTitle -Identity ([string]$View.title) -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] View exists: {0}" -f $View.title) -ForegroundColor Gray
        return
    }

    $params = @{
        List = $ListTitle
        Title = [string]$View.title
        Fields = @($View.fields | ForEach-Object { [string]$_ })
    }

    if ((Test-JsonProperty -Object $View -Name "default") -and $View.default -eq $true) {
        $params.SetAsDefault = $true
    }

    Add-PnPView @params | Out-Null
    Write-Host ("  [OK] View created: {0}" -f $View.title) -ForegroundColor Green
}

function New-RelationshipCrmPageHtml {
    param([object]$Config)

    $page = $Config.pages[0]
    $title = ConvertTo-HtmlText -Value ([string]$page.title)
    $role = ConvertTo-HtmlText -Value ([string]$page.role)

    $laneHtml = foreach ($lane in $page.operatorLanes) {
        $laneTitle = ConvertTo-HtmlText -Value ([string]$lane.title)
        $purpose = ConvertTo-HtmlText -Value ([string]$lane.purpose)
        "<li><strong>$laneTitle</strong><br />$purpose</li>"
    }

    $linkHtml = foreach ($link in $page.directLinks) {
        $label = ConvertTo-HtmlText -Value ([string]$link.label)
        $listTitle = [string]$link.list
        $viewTitle = [string]$link.view
        $url = Get-ListViewUrl -ListTitle $listTitle -ViewTitle $viewTitle
        $encodedUrl = ConvertTo-HtmlText -Value $url
        $encodedList = ConvertTo-HtmlText -Value $listTitle
        $encodedView = ConvertTo-HtmlText -Value $viewTitle
        "<li><a href=""$encodedUrl"">$label</a> - $encodedList / $encodedView</li>"
    }

    $workflows = foreach ($workflow in $Config.workflows) {
        $workflowName = ConvertTo-HtmlText -Value ([string]$workflow.name)
        $steps = ConvertTo-HtmlList -Items $workflow.steps
        "<h3>$workflowName</h3>$steps"
    }

    return @"
<h2>$title</h2>
<p><strong>Role:</strong> $role</p>
<p>This page is the staff-facing CRM cockpit. Microsoft Lists hold the operating state; this page routes people to the right list views. Dashboard counts come later after source records are stable.</p>
<h3>Operator lanes</h3>
<ul>$($laneHtml -join '')</ul>
<h3>Direct links</h3>
<ul>$($linkHtml -join '')</ul>
<h3>Workflow rules</h3>
$($workflows -join '')
<p><em>Generated from the Stage 8A Relationship CRM config. No Dynamics, Dataverse, permissions, guests, sharing, public Forms, sends, deletes, or unattended automation are created by this page.</em></p>
"@
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
                throw "Navigation target page is not defined in config: $value"
            }
            return Get-SiteRelativeUrl -SiteUrl ([string]$Config.site.url) -Target ("SitePages/{0}" -f $page[0].fileName)
        }
        "List" {
            return Get-ListUrl -Title $value
        }
        default {
            throw "Unknown navigation target kind: $kind"
        }
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

Write-Host "Microsoft 365 Stage 8A - Relationship CRM Build" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned page:" -ForegroundColor Cyan
foreach ($page in $config.pages) {
    Write-Host ("- {0} ({1})" -f $page.title, $page.fileName) -ForegroundColor White
}
Write-Host ""
Write-Host "Planned CRM Lists:" -ForegroundColor Cyan
foreach ($list in $config.lists) {
    Write-Host ("- {0}" -f $list.title) -ForegroundColor White
}
Write-Host ""
Write-Host "Planned navigation targets:" -ForegroundColor Cyan
foreach ($target in $config.navigationTargets) {
    Write-Host ("- {0} / {1} -> {2} ({3})" -f $target.group, $target.link, $target.target, $target.kind) -ForegroundColor White
}
Write-Host ""
Write-Host "Safety limits:" -ForegroundColor Yellow
foreach ($limit in $config.safetyLimits) {
    Write-Host ("- {0}" -f $limit) -ForegroundColor Yellow
}
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to create missing Stage 8A CRM structure." -ForegroundColor Green
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
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$approvalPhrase = [string]$config.approvalPhrase
$approval = Read-Host "Type '$approvalPhrase' to create missing Stage 8A Relationship CRM structure"
if ($approval -ne $approvalPhrase) {
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

foreach ($list in $config.lists) {
    Write-Host ""
    Write-Host ("List: {0}" -f $list.title) -ForegroundColor Cyan
    $existingList = Get-PnPList -Identity ([string]$list.title) -ErrorAction SilentlyContinue
    if ($null -eq $existingList) {
        New-PnPList -Title ([string]$list.title) -Template GenericList -OnQuickLaunch:$false | Out-Null
        Write-Host ("  [OK] List created: {0}" -f $list.title) -ForegroundColor Green
    }
    else {
        Write-Host ("  [skip] List exists: {0}" -f $list.title) -ForegroundColor Gray
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$list.description)) {
        Set-PnPList -Identity ([string]$list.title) -Description ([string]$list.description) | Out-Null
    }

    foreach ($column in $list.columns) {
        Add-Stage8AField -ListTitle ([string]$list.title) -Column $column
    }

    foreach ($view in $list.views) {
        Add-Stage8AView -ListTitle ([string]$list.title) -View $view
    }
}

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
    Add-PnPPageTextPart -Page ([string]$page.fileName) -Section 1 -Column 1 -Order 1 -Text (New-RelationshipCrmPageHtml -Config $config) | Out-Null
    Set-PnPPage -Identity ([string]$page.fileName) -Title ([string]$page.title) -Publish | Out-Null
    Write-Host ("  [OK] {0}" -f $page.title) -ForegroundColor Green
}

$topNodes = @(Get-PnPNavigationNode -Location QuickLaunch)
foreach ($target in $config.navigationTargets) {
    $groupTitle = [string]$target.group
    $linkTitle = [string]$target.link
    $url = Resolve-NavigationUrl -Config $config -Target $target

    $groupNode = @($topNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1)
    if ($groupNode.Count -eq 0) {
        Write-Host ("Creating navigation group: {0}" -f $groupTitle) -ForegroundColor Cyan
        $groupNode = Add-PnPNavigationNode -Location QuickLaunch -Title $groupTitle -Url ([string]$config.site.url)
        $topNodes += $groupNode
    }
    else {
        $groupNode = $groupNode[0]
    }

    $nodeWithChildren = Get-PnPNavigationNode -Id $groupNode.Id -ErrorAction SilentlyContinue
    $existingChildren = @()
    if ($null -ne $nodeWithChildren -and $null -ne $nodeWithChildren.Children) {
        $existingChildren = @($nodeWithChildren.Children)
    }

    $existingLink = @($existingChildren | Where-Object { $_.Title -eq $linkTitle } | Select-Object -First 1)
    if ($existingLink.Count -gt 0) {
        Write-Host ("Navigation link exists; leaving unchanged: {0} / {1}" -f $groupTitle, $linkTitle) -ForegroundColor Yellow
        continue
    }

    Write-Host ("Adding navigation link: {0} / {1} -> {2}" -f $groupTitle, $linkTitle, $url) -ForegroundColor Cyan
    Add-PnPNavigationNode -Location QuickLaunch -Title $linkTitle -Url $url -Parent $groupNode | Out-Null
    Write-Host ("  [OK] {0}" -f $linkTitle) -ForegroundColor Green
}

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

Write-Host ""
Write-Host "Stage 8A Relationship CRM build complete. Run read-only verification next." -ForegroundColor Green

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
