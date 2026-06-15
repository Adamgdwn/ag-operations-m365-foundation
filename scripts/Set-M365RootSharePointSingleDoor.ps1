param(
    [string]$RootSiteUrl = "https://agoperationsltd.sharepoint.com",
    [string]$OperatingSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$CommandCenterUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx",
    [string]$OutputDirectory = ".\inventory\access-repair"
)

$ErrorActionPreference = "Stop"

Import-Module PnP.PowerShell

$resolvedOutputDirectory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputDirectory ("root-sharepoint-single-door-{0}.log" -f $stamp)
$summaryPath = Join-Path $resolvedOutputDirectory ("ROOT_SHAREPOINT_SINGLE_DOOR_{0}.md" -f $stamp)
$readbackCsvPath = Join-Path $resolvedOutputDirectory ("root-sharepoint-single-door-readback-{0}.csv" -f $stamp)

$pageFileName = "Guided-AI-Labs-Operating-Door.aspx"
$pageTitle = "Guided AI Labs Operating Door"
$quickLaunchTitle = "Guided AI Labs"

function Get-RootRelativeUrl {
    param(
        [string]$SiteUrl,
        [string]$TargetUrl
    )

    $siteUri = [uri]$SiteUrl
    $targetUri = [uri]$TargetUrl
    if ($siteUri.Host -eq $targetUri.Host) {
        return $targetUri.PathAndQuery
    }

    return $TargetUrl
}

function New-SingleDoorHtml {
    param(
        [string]$OperatingSiteUrl,
        [string]$CommandCenterUrl
    )

    $encodedOperatingUrl = [System.Net.WebUtility]::HtmlEncode($OperatingSiteUrl)
    $encodedCommandCenterUrl = [System.Net.WebUtility]::HtmlEncode($CommandCenterUrl)

@"
<div style="max-width:960px;margin:0 auto;padding:30px 0;font-family:Segoe UI,Arial,sans-serif;color:#1f2937;">
  <p style="font-size:14px;line-height:1.5;margin:0 0 10px 0;color:#64748b;text-transform:uppercase;letter-spacing:.06em;">AG Operations workspace routing</p>
  <h1 style="font-size:34px;line-height:1.15;margin:0 0 14px 0;color:#111827;">Guided AI Labs is the daily operating site.</h1>
  <p style="font-size:18px;line-height:1.55;margin:0 0 22px 0;color:#374151;">Use one SharePoint workspace for daily company work, CRM, delivery, methods, decisions, intake, and operating records.</p>
  <p style="margin:0 0 26px 0;">
    <a href="$encodedCommandCenterUrl" style="display:inline-block;background:#14532d;color:#ffffff;text-decoration:none;padding:13px 18px;border-radius:6px;font-weight:600;margin-right:10px;">Open CRM Command Center</a>
    <a href="$encodedOperatingUrl" style="display:inline-block;background:#f8fafc;color:#0f172a;text-decoration:none;padding:12px 17px;border:1px solid #cbd5e1;border-radius:6px;font-weight:600;">Open Guided AI Labs Site</a>
  </p>
  <div style="border-top:1px solid #e5e7eb;padding-top:18px;margin-top:18px;">
    <p style="font-size:15px;line-height:1.5;margin:0 0 8px 0;color:#475569;"><strong>Daily source of truth:</strong> Guided AI Labs SharePoint.</p>
    <p style="font-size:15px;line-height:1.5;margin:0;color:#475569;"><strong>AG Operations root:</strong> routing and admin landing only, not a second workspace.</p>
  </div>
</div>
"@
}

Start-Transcript -Path $transcriptPath -Force | Out-Null
try {
    Write-Host "Microsoft 365 root SharePoint single-door setup" -ForegroundColor Cyan
    Write-Host "Root site: $RootSiteUrl" -ForegroundColor White
    Write-Host "Daily operating site: $OperatingSiteUrl" -ForegroundColor White
    Write-Host "Safety: page and navigation routing only; no permissions, guests, sharing, tenant policy, CRM data, or deletions." -ForegroundColor Yellow

    Connect-PnPOnline -Url $RootSiteUrl -OSLogin

    $web = Get-PnPWeb -Includes Title, Url
    $previousHomePage = Get-PnPHomePage
    Write-Host ("Connected to {0} <{1}>" -f $web.Title, $web.Url) -ForegroundColor White
    Write-Host ("Previous homepage: {0}" -f $previousHomePage) -ForegroundColor White

    $pageExists = $true
    try {
        Get-PnPPage -Identity $pageFileName | Out-Null
    } catch {
        $pageExists = $false
    }

    if (-not $pageExists) {
        Write-Host ("Creating page: {0}" -f $pageFileName) -ForegroundColor Yellow
        Add-PnPPage -Name $pageFileName -LayoutType Article | Out-Null
        Add-PnPPageSection -Page $pageFileName -SectionTemplate OneColumn -Order 1 | Out-Null
        Add-PnPPageTextPart -Page $pageFileName -Section 1 -Column 1 -Order 1 -Text (New-SingleDoorHtml -OperatingSiteUrl $OperatingSiteUrl -CommandCenterUrl $CommandCenterUrl) | Out-Null
    } else {
        Write-Host ("Page already exists: {0}" -f $pageFileName) -ForegroundColor Green
    }

    Set-PnPPage -Identity $pageFileName -Title $pageTitle -Publish | Out-Null

    $pageRootRelativeUrl = "SitePages/$pageFileName"
    Write-Host ("Setting root homepage to {0}" -f $pageRootRelativeUrl) -ForegroundColor Yellow
    Set-PnPHomePage -RootFolderRelativeUrl $pageRootRelativeUrl

    $operatingSiteRelativeUrl = Get-RootRelativeUrl -SiteUrl $RootSiteUrl -TargetUrl $OperatingSiteUrl
    $navigationUrl = $OperatingSiteUrl
    $navNodes = @(Get-PnPNavigationNode -Location QuickLaunch)
    $existingNode = @($navNodes | Where-Object { $_.Title -eq $quickLaunchTitle }) | Select-Object -First 1
    if ($null -eq $existingNode) {
        Write-Host ("Adding root quick launch link: {0} -> {1}" -f $quickLaunchTitle, $navigationUrl) -ForegroundColor Yellow
        Add-PnPNavigationNode -Location QuickLaunch -Title $quickLaunchTitle -Url $navigationUrl -External | Out-Null
    } else {
        Write-Host ("Root quick launch link already exists: {0}" -f $quickLaunchTitle) -ForegroundColor Green
    }

    $newHomePage = Get-PnPHomePage
    $pageReadback = $true
    try {
        Get-PnPPage -Identity $pageFileName | Out-Null
    } catch {
        $pageReadback = $false
    }

    $navReadback = @(@(Get-PnPNavigationNode -Location QuickLaunch) | Where-Object {
        $_.Title -eq $quickLaunchTitle -and ($_.Url -eq $operatingSiteRelativeUrl -or $_.Url -eq $OperatingSiteUrl -or $_.Url -eq $navigationUrl)
    }).Count -gt 0

    $readback = [pscustomobject]@{
        RootSiteUrl = $RootSiteUrl
        OperatingSiteUrl = $OperatingSiteUrl
        CommandCenterUrl = $CommandCenterUrl
        PageFileName = $pageFileName
        PreviousHomePage = [string]$previousHomePage
        NewHomePage = [string]$newHomePage
        PagePresent = $pageReadback
        NavigationPresent = $navReadback
    }
    $readback | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $readbackCsvPath

    $result = if ($pageReadback -and $navReadback -and ([string]$newHomePage -like "*$pageFileName*")) { "PASS" } else { "CHECK" }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Root SharePoint Single Door")
    $lines.Add("")
    $lines.Add(("Run: {0}" -f $stamp))
    $lines.Add(("Result: {0}" -f $result))
    $lines.Add(("Root site: {0}" -f $RootSiteUrl))
    $lines.Add(("Daily operating site: {0}" -f $OperatingSiteUrl))
    $lines.Add(("CRM command center: {0}" -f $CommandCenterUrl))
    $lines.Add(("Previous root homepage: {0}" -f $previousHomePage))
    $lines.Add(("New root homepage: {0}" -f $newHomePage))
    $lines.Add(("Transcript: {0}" -f $transcriptPath))
    $lines.Add(("Read-back CSV: {0}" -f $readbackCsvPath))
    $lines.Add("")
    $lines.Add("## Boundary")
    $lines.Add("")
    $lines.Add("This change makes the AG Operations root SharePoint site a routing doorway into Guided AI Labs. It does not delete the old root site content, invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.")
    $lines | Set-Content -Encoding UTF8 -Path $summaryPath

    Write-Host ""
    Write-Host ("Single-door setup result: {0}" -f $result) -ForegroundColor ($(if ($result -eq "PASS") { "Green" } else { "Yellow" }))
    Write-Host "Summary: $summaryPath" -ForegroundColor Gray
    Write-Host "Read-back CSV: $readbackCsvPath" -ForegroundColor Gray
} finally {
    Stop-Transcript | Out-Null
}
