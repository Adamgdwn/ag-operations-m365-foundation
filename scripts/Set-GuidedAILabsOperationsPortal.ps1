param(
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Creates the practical Guided AI Labs daily operating portal and makes it the
# site home page. This script does not delete pages, lists, libraries, items,
# permissions, sharing settings, app grants, guests, mail, or automation.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$evidenceRoot = Join-Path $workspaceRoot "inventory\gail-sharepoint-portal"
New-Item -ItemType Directory -Path $evidenceRoot -Force | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $evidenceRoot ("gail-operations-portal-{0}.log" -f $stamp)
$summaryPath = Join-Path $evidenceRoot ("GAIL_OPERATIONS_PORTAL_{0}.md" -f $stamp)

function ConvertTo-HtmlText {
    param([string]$Value)
    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function New-Link {
    param(
        [string]$Href,
        [string]$Label,
        [string]$Note
    )

    return "<li><a href=""$(ConvertTo-HtmlText $Href)"">$(ConvertTo-HtmlText $Label)</a> - $(ConvertTo-HtmlText $Note)</li>"
}

function New-PortalCard {
    param(
        [string]$Title,
        [string]$Subtitle,
        [string]$Href,
        [array]$Signals,
        [string]$Accent = "#2563eb"
    )

    $signalHtml = @($Signals | ForEach-Object {
        "<li style=""margin:4px 0;"">$(ConvertTo-HtmlText $_)</li>"
    }) -join ""

    return @"
<td style="width:25%;vertical-align:top;padding:8px;">
  <div style="border:1px solid #d0d7de;border-top:5px solid $Accent;border-radius:8px;padding:14px;min-height:210px;background:#ffffff;">
    <h3 style="margin:0 0 6px 0;font-size:20px;">$(ConvertTo-HtmlText $Title)</h3>
    <p style="margin:0 0 12px 0;color:#475569;">$(ConvertTo-HtmlText $Subtitle)</p>
    <ul style="margin:0 0 14px 18px;padding:0;">$signalHtml</ul>
    <p style="margin:0;"><a href="$(ConvertTo-HtmlText $Href)" style="font-weight:600;">Open</a></p>
  </div>
</td>
"@
}

function New-OperationsPortalHtml {
    param([string]$BaseUrl)

    $site = $BaseUrl.TrimEnd("/")
    $crm = "$site/SitePages/Relationship-CRM-Command-Center.aspx"
    $intake = "$site/SitePages/Intake.aspx"
    $clientDiscovery = "$site/SitePages/Client-Discovery.aspx"
    $activeDelivery = "$site/SitePages/Active-Delivery.aspx"
    $handoff = "$site/Client%20Handoff%20Packets"
    $appGrants = "$site/SitePages/App-Grants.aspx"
    $toolPermissions = "$site/Lists/Tool%20Permission%20Review/Needs%20Review.aspx"
    $automation = "$site/Lists/Automation%20Backlog/Backlog.aspx"
    $decisions = "$site/Lists/Decision%20Register/Recent%20Decisions.aspx"
    $agentLog = "$site/Lists/Agent%20Action%20Log/Needs%20Review.aspx"
    $loginGuide = "$site/SitePages/Login-And-Account-Guide.aspx"
    $projects = "$site/SitePages/Active-Delivery.aspx"
    $engagements = "$site/Lists/CRM%20%20Engagements/Delivery%20Control.aspx"
    $lifecycle = "$site/Lists/CRM%20%20Lifecycle%20Checklist/Open%20Checklist.aspx"
    $agentSetup = "$site/SitePages/Agent-Setup.aspx"

    $cards = @(
        New-PortalCard -Title "CRM" -Subtitle "Relationships, opportunities, follow-ups, meetings, and account health." -Href $crm -Accent "#0f766e" -Signals @(
            "Open CRM actions"
            "Qualification triage"
            "Meetings and debriefs"
            "Health reviews and risk"
        )
        New-PortalCard -Title "Operations" -Subtitle "Daily intake, decisions, assisted actions, and operating records." -Href $intake -Accent "#2563eb" -Signals @(
            "Attention-now intake"
            "Agent action review"
            "Recent decisions"
            "Active delivery flow"
        )
        New-PortalCard -Title "Tools" -Subtitle "Tooling, permissions, agents, grants, and automation readiness." -Href $toolPermissions -Accent "#7c3aed" -Signals @(
            "Tool permission review"
            "App grants governance"
            "Automation backlog"
            "Agent setup"
        )
        New-PortalCard -Title "Projects In Flight" -Subtitle "Current delivery work, blockers, handoff material, and next steps." -Href $projects -Accent "#ca8a04" -Signals @(
            "Delivery control"
            "Lifecycle checklist"
            "Handoff packets"
            "Client discovery"
        )
    )

    $crmLinks = @(
        New-Link -Href $crm -Label "CRM Command Center" -Note "Single daily CRM door."
        New-Link -Href $engagements -Label "Delivery Control" -Note "Active engagements and work in motion."
        New-Link -Href $lifecycle -Label "Open Lifecycle Checklist" -Note "Onboarding, delivery, and offboarding blockers."
    )

    $customerLinks = @(
        New-Link -Href $clientDiscovery -Label "Client Discovery" -Note "Customer experience, onboarding readiness, fit, and workspace planning."
        New-Link -Href $handoff -Label "Handoff Packets" -Note "Closeout, onboarding material, ownership notes, and review packets."
        New-Link -Href $decisions -Label "Decision Register" -Note "Scope, access, delivery, governance, and operating decisions."
    )

    $opsLinks = @(
        New-Link -Href $agentLog -Label "Agent Action Log" -Note "Suggested and completed assisted actions with evidence."
        New-Link -Href $automation -Label "Automation Backlog" -Note "Automation ideas before build, approval, or production use."
        New-Link -Href $toolPermissions -Label "Tool Permission Review" -Note "App grants, agent scopes, risky permissions, owner, status, and review date."
    )

    $governanceLinks = @(
        New-Link -Href $appGrants -Label "App Grants" -Note "Governance page for app grants and resting-state decisions. It is not a live Funding & Benefits agent connection yet."
        New-Link -Href $agentSetup -Label "Agent Setup" -Note "Future agent operating setup and readiness references."
        New-Link -Href $loginGuide -Label "Login Guide" -Note "Which account to use, where to work, and what to do when Microsoft asks for MFA."
    )

    return @"
<h2>Guided AI Labs Operations Cockpit</h2>
<p style="font-size:17px;"><strong>Daily cockpit:</strong> Guided AI Labs is the working home. Start with the four cards, then use the live queues below for the actual work.</p>
<table style="width:100%;border-collapse:collapse;margin:14px 0 22px 0;"><tr>$($cards -join '')</tr></table>

<table style="width:100%;border-collapse:collapse;">
  <tr>
    <td style="width:50%;vertical-align:top;padding-right:12px;">
      <h3>CRM And Customer Flow</h3>
      <ul>$($crmLinks -join '')</ul>
      <ul>$($customerLinks -join '')</ul>
    </td>
    <td style="width:50%;vertical-align:top;padding-left:12px;">
      <h3>Operations And Tools</h3>
      <ul>$($opsLinks -join '')</ul>
      <ul>$($governanceLinks -join '')</ul>
    </td>
  </tr>
</table>

<p><em>No permissions, guests, sharing, app grants, mail, list items, or automation were changed. App Grants is a governance surface, not a live Funding & Benefits agent connection yet.</em></p>
"@
}

function Add-PortalListWebPart {
    param(
        [string]$PageName,
        [string]$ListTitle,
        [string]$ViewTitle,
        [int]$Section,
        [int]$Column,
        [int]$Order
    )

    try {
        $list = Get-PnPList -Identity $ListTitle -Includes RootFolder -ErrorAction Stop
        $view = Get-PnPView -List $ListTitle -Identity $ViewTitle -ErrorAction Stop
        $properties = @{
            selectedListId = $list.Id.ToString()
            selectedViewId = $view.Id.ToString()
            selectedListUrl = $list.RootFolder.ServerRelativeUrl
            webRelativeListUrl = $list.RootFolder.ServerRelativeUrl
            isDocumentLibrary = "false"
            title = $ViewTitle
        }
        Add-PnPPageTextPart -Page $PageName -Section $Section -Column $Column -Order $Order -Text ("<h3>{0}</h3>" -f (ConvertTo-HtmlText $ViewTitle)) | Out-Null
        Add-PnPPageWebPart -Page $PageName -DefaultWebPartType List -Section $Section -Column $Column -Order ($Order + 1) -WebPartProperties $properties | Out-Null
        return [pscustomobject]@{
            List = $ListTitle
            View = $ViewTitle
            Status = "Added"
            Message = ""
        }
    }
    catch {
        Add-PnPPageTextPart -Page $PageName -Section $Section -Column $Column -Order $Order -Text ("<h3>{0}</h3><p>Open the source list: {1}</p><p><em>List web part was skipped: {2}</em></p>" -f (ConvertTo-HtmlText $ViewTitle), (ConvertTo-HtmlText $ListTitle), (ConvertTo-HtmlText $_.Exception.Message)) | Out-Null
        return [pscustomobject]@{
            List = $ListTitle
            View = $ViewTitle
            Status = "Skipped"
            Message = $_.Exception.Message
        }
    }
}

function Get-NavigationNodesRecursive {
    param([object[]]$Nodes)

    foreach ($node in $Nodes) {
        if ($null -eq $node -or $null -eq $node.Id) {
            continue
        }

        $fullNode = Get-PnPNavigationNode -Id $node.Id
        $fullNode
        if ($null -ne $fullNode.Children) {
            Get-NavigationNodesRecursive -Nodes @($fullNode.Children)
        }
    }
}

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Guided AI Labs SharePoint operations portal cleanup" -ForegroundColor Cyan
Write-Host "Site:       $SiteUrl" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{
    Url = $SiteUrl
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

$portalFileName = "Guided-AI-Labs-Operations-Cockpit.aspx"
$portalTitle = "Guided AI Labs Operations Cockpit"
$portalRelativeHome = "SitePages/$portalFileName"
$createdPage = $false
$refreshedPage = $false
$removedNavTitles = New-Object System.Collections.Generic.List[string]
$addedNavTitles = New-Object System.Collections.Generic.List[string]
$dashboardWebParts = New-Object System.Collections.Generic.List[object]

$existingPage = $null
try {
    $existingPage = Get-PnPPage -Identity $portalFileName -ErrorAction Stop
}
catch {
    $existingPage = $null
}

if ($null -eq $existingPage) {
    Write-Host ("Creating portal page: {0}" -f $portalFileName) -ForegroundColor Cyan
    Add-PnPPage -Name $portalFileName -LayoutType Article -HeaderLayoutType NoImage -CommentsEnabled:$false | Out-Null
    Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 1 | Out-Null
    $createdPage = $true
}
else {
    Write-Host ("Refreshing portal page: {0}" -f $portalFileName) -ForegroundColor Cyan
    $components = @(Get-PnPPageComponent -Page $portalFileName)
    foreach ($component in $components) {
        if ($null -ne $component.InstanceId) {
            try {
                Remove-PnPPageComponent -Page $portalFileName -InstanceId $component.InstanceId -Force | Out-Null
            }
            catch {
                Write-Host ("  [warn] Could not remove stale page component {0}: {1}" -f $component.InstanceId, $_.Exception.Message) -ForegroundColor Yellow
            }
        }
    }
    Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 1 | Out-Null
    $refreshedPage = $true
}

Add-PnPPageTextPart -Page $portalFileName -Section 1 -Column 1 -Order 1 -Text (New-OperationsPortalHtml -BaseUrl $SiteUrl) | Out-Null
Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 2 | Out-Null
Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 3 | Out-Null
Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 4 | Out-Null
Add-PnPPageSection -Page $portalFileName -SectionTemplate OneColumn -Order 5 | Out-Null

Write-Host "Adding live dashboard list web parts" -ForegroundColor Cyan
$dashboardTargets = @(
    @{ List = "CRM - Action Queue"; View = "Open CRM Actions"; Section = 2; Column = 1; Order = 1 }
    @{ List = "CRM - Qualification"; View = "Qualification Triage"; Section = 3; Column = 1; Order = 1 }
    @{ List = "Guided AI Labs - Intake Register"; View = "Attention Now"; Section = 4; Column = 1; Order = 1 }
    @{ List = "Agent Action Log"; View = "Needs Review"; Section = 5; Column = 1; Order = 1 }
)
foreach ($target in $dashboardTargets) {
    $result = Add-PortalListWebPart -PageName $portalFileName -ListTitle $target.List -ViewTitle $target.View -Section $target.Section -Column $target.Column -Order $target.Order
    $dashboardWebParts.Add($result)
    if ($result.Status -eq "Added") {
        Write-Host ("  [OK] {0} / {1}" -f $result.List, $result.View) -ForegroundColor Green
    }
    else {
        Write-Host ("  [warn] {0} / {1}: {2}" -f $result.List, $result.View, $result.Message) -ForegroundColor Yellow
    }
}

Set-PnPPage -Identity $portalFileName -Title $portalTitle -Publish | Out-Null
Set-PnPHomePage -RootFolderRelativeUrl $portalRelativeHome | Out-Null
Write-Host ("Homepage set to: {0}" -f $portalRelativeHome) -ForegroundColor Green

$quickLaunchTree = @(Get-PnPNavigationNode -Location QuickLaunch)
$flatNodes = @(Get-NavigationNodesRecursive -Nodes $quickLaunchTree)
$removeTitles = @("Relationship CRM", "CRM Operations", "Recent")
foreach ($title in $removeTitles) {
    $matches = @($flatNodes | Where-Object { $_.Title -eq $title })
    foreach ($node in $matches) {
        Write-Host ("Removing navigation node: {0}" -f $node.Title) -ForegroundColor Cyan
        Remove-PnPNavigationNode -Identity $node.Id -Force | Out-Null
        $removedNavTitles.Add([string]$node.Title)
    }
}

$topNodes = @(Get-PnPNavigationNode -Location QuickLaunch)
$startHere = @($topNodes | Where-Object { $_.Title -eq "Start Here" } | Select-Object -First 1)
if ($startHere.Count -eq 0) {
    $startHere = Add-PnPNavigationNode -Location QuickLaunch -Title "Start Here" -Url $SiteUrl
}
else {
    $startHere = $startHere[0]
}

$startHereFull = Get-PnPNavigationNode -Id $startHere.Id
$startHereChildren = @()
if ($null -ne $startHereFull.Children) {
    $startHereChildren = @($startHereFull.Children)
}

$existingOperationsPortalLinks = @($startHereChildren | Where-Object { $_.Title -eq "Operations Portal" })
foreach ($node in $existingOperationsPortalLinks) {
    Remove-PnPNavigationNode -Identity $node.Id -Force | Out-Null
    $removedNavTitles.Add("Start Here / Operations Portal")
}

Add-PnPNavigationNode -Location QuickLaunch -Title "Operations Portal" -Url ("/sites/GuidedAILabs/$portalRelativeHome") -Parent $startHere | Out-Null
$addedNavTitles.Add("Start Here / Operations Portal")

if (-not @($startHereChildren | Where-Object { $_.Title -eq "Login Guide" })) {
    Add-PnPNavigationNode -Location QuickLaunch -Title "Login Guide" -Url "/sites/GuidedAILabs/SitePages/Login-And-Account-Guide.aspx" -Parent $startHere | Out-Null
    $addedNavTitles.Add("Start Here / Login Guide")
}

$web = Get-PnPWeb -Includes WelcomePage,Title,Url
$pageCheck = Get-PnPPage -Identity $portalFileName
$navCheck = @(Get-NavigationNodesRecursive -Nodes @(Get-PnPNavigationNode -Location QuickLaunch))

try {
    Disconnect-PnPOnline | Out-Null
}
catch {
}

$summary = @"
# Guided AI Labs Operations Cockpit Cleanup

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Result

- Site: $($web.Url)
- Homepage: $($web.WelcomePage)
- Portal page: $portalFileName
- Portal title: $($pageCheck.PageTitle)
- Page created: $createdPage
- Page refreshed: $refreshedPage
- Removed navigation nodes: $($removedNavTitles -join ", ")
- Added navigation nodes: $($addedNavTitles -join ", ")
- Dashboard web parts: $(@($dashboardWebParts | ForEach-Object { "{0} / {1}: {2}" -f $_.List, $_.View, $_.Status }) -join "; ")

## Operator Notes

- The daily CRM entry point is now `CRM Command Center`.
- `Relationship CRM` and `CRM Operations` remain available as reference pages, but were removed from daily navigation.
- The stock SharePoint `News` and `Quick links` experience is no longer the site homepage.
- `App Grants` remains a governance surface. It is not currently a direct live connection to a Guided AI Labs Funding & Benefits agent.
- The homepage is now organized as dashboard cards plus embedded SharePoint list views for live attention queues.

## Verification Snapshot

- Portal page exists: $($null -ne $pageCheck)
- Extra CRM nav visible: $(@($navCheck | Where-Object { $_.Title -in @("Relationship CRM", "CRM Operations") }).Count)
"@

Set-Content -LiteralPath $summaryPath -Value $summary -Encoding utf8
Write-Host ("Evidence written: {0}" -f $summaryPath) -ForegroundColor Green

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
