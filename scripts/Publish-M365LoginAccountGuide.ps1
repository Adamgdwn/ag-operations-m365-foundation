param(
    [string[]]$SiteUrls = @(
        "https://agoperationsltd.sharepoint.com",
        "https://agoperationsltd.sharepoint.com/sites/AGOperations",
        "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
        "https://agoperationsltd.sharepoint.com/sites/A.G.OperationsLtd",
        "https://agoperationsltd.sharepoint.com/sites/allcompany",
        "https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools",
        "https://agoperationsltd.sharepoint.com/sites/GuidedAIJourney",
        "https://agoperationsltd.sharepoint.com/sites/SharedLibraries"
    ),
    [string]$OutputDirectory = ".\inventory\access-repair"
)

$ErrorActionPreference = "Stop"

Import-Module PnP.PowerShell

$resolvedOutputDirectory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputDirectory ("login-account-guide-publish-{0}.log" -f $stamp)
$csvPath = Join-Path $resolvedOutputDirectory ("login-account-guide-publish-{0}.csv" -f $stamp)
$summaryPath = Join-Path $resolvedOutputDirectory ("LOGIN_ACCOUNT_GUIDE_PUBLISH_{0}.md" -f $stamp)

$pageFileName = "Login-And-Account-Guide.aspx"
$pageTitle = "Login And Account Guide"
$navTitle = "Login Guide"

function New-LoginGuideHtml {
@"
<div style="max-width:1040px;margin:0 auto;padding:28px 0;font-family:Segoe UI,Arial,sans-serif;color:#1f2937;">
  <p style="font-size:13px;line-height:1.5;margin:0 0 10px 0;color:#64748b;text-transform:uppercase;letter-spacing:.06em;">Microsoft 365 account clarity</p>
  <h1 style="font-size:34px;line-height:1.15;margin:0 0 12px 0;color:#111827;">Login And Account Guide</h1>
  <p style="font-size:18px;line-height:1.55;margin:0 0 22px 0;color:#374151;">If you are working, sign in as Adam Goodwin. If you are administering the tenant, sign in as Admin.</p>

  <h2 style="font-size:22px;margin:28px 0 10px 0;color:#111827;">Account Map</h2>
  <table style="width:100%;border-collapse:collapse;font-size:15px;margin:0 0 22px 0;">
    <thead>
      <tr style="background:#f8fafc;">
        <th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Account</th>
        <th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Role</th>
        <th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Use For</th>
        <th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Daily?</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style="border:1px solid #cbd5e1;padding:10px;"><strong>adamgoodwin@guidedailabs.com</strong></td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Daily operator and owner</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Guided AI Labs SharePoint, CRM, Lists, Planner, Teams, documents, daily decisions</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Yes</td>
      </tr>
      <tr>
        <td style="border:1px solid #cbd5e1;padding:10px;"><strong>admin@agoperations.ca</strong></td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Admin toolbelt</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Microsoft 365 admin center, Entra, SharePoint admin, permissions, security, break/fix</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">No</td>
      </tr>
      <tr>
        <td style="border:1px solid #cbd5e1;padding:10px;"><strong>contact@agoperations.ca</strong></td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Future front door/contact account</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">Possible future intake/mail/contact routing</td>
        <td style="border:1px solid #cbd5e1;padding:10px;">No</td>
      </tr>
    </tbody>
  </table>

  <h2 style="font-size:22px;margin:28px 0 10px 0;color:#111827;">Source Of Truth</h2>
  <table style="width:100%;border-collapse:collapse;font-size:15px;margin:0 0 22px 0;">
    <tbody>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;font-weight:600;">Daily workplace</td><td style="border:1px solid #cbd5e1;padding:10px;"><a href="https://agoperationsltd.sharepoint.com/sites/GuidedAILabs">Guided AI Labs SharePoint</a></td></tr>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;font-weight:600;">CRM and active relationship work</td><td style="border:1px solid #cbd5e1;padding:10px;"><a href="https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx">Relationship CRM Command Center</a></td></tr>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;font-weight:600;">Admin authority</td><td style="border:1px solid #cbd5e1;padding:10px;">admin@agoperations.ca</td></tr>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;font-weight:600;">Parent/router layer</td><td style="border:1px solid #cbd5e1;padding:10px;">AG Operations SharePoint surfaces</td></tr>
    </tbody>
  </table>

  <h2 style="font-size:22px;margin:28px 0 10px 0;color:#111827;">MFA And Auth Code Rule</h2>
  <table style="width:100%;border-collapse:collapse;font-size:15px;margin:0 0 22px 0;">
    <thead><tr style="background:#f8fafc;"><th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">What You Are Opening</th><th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Expected Account</th></tr></thead>
    <tbody>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;">SharePoint, Teams, Planner, Lists, CRM, documents</td><td style="border:1px solid #cbd5e1;padding:10px;">adamgoodwin@guidedailabs.com</td></tr>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;">Microsoft 365 Admin Center, Entra, SharePoint Admin, tenant settings</td><td style="border:1px solid #cbd5e1;padding:10px;">admin@agoperations.ca</td></tr>
    </tbody>
  </table>
  <p style="font-size:16px;line-height:1.55;margin:0 0 20px 0;color:#374151;"><strong>If an authentication prompt does not clearly show which account it is for, cancel it and restart from the correct Chrome profile.</strong></p>

  <h2 style="font-size:22px;margin:28px 0 10px 0;color:#111827;">Browser Profile Rule</h2>
  <table style="width:100%;border-collapse:collapse;font-size:15px;margin:0 0 22px 0;">
    <thead><tr style="background:#f8fafc;"><th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Chrome Profile</th><th style="text-align:left;border:1px solid #cbd5e1;padding:10px;">Signed-In Account</th></tr></thead>
    <tbody>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;">AG Operations - Daily</td><td style="border:1px solid #cbd5e1;padding:10px;">adamgoodwin@guidedailabs.com only</td></tr>
      <tr><td style="border:1px solid #cbd5e1;padding:10px;">AG Operations - Admin</td><td style="border:1px solid #cbd5e1;padding:10px;">admin@agoperations.ca only</td></tr>
    </tbody>
  </table>

  <h2 style="font-size:22px;margin:28px 0 10px 0;color:#111827;">Recovery Path</h2>
  <ol style="font-size:16px;line-height:1.6;margin:0 0 22px 22px;color:#374151;">
    <li>Close mixed-account Microsoft 365 tabs.</li>
    <li>Open the intended Chrome profile.</li>
    <li>Sign in with only the expected account.</li>
    <li>Open Guided AI Labs directly: <a href="https://agoperationsltd.sharepoint.com/sites/GuidedAILabs">https://agoperationsltd.sharepoint.com/sites/GuidedAILabs</a></li>
    <li>If access looks wrong, try an InPrivate window and sign in explicitly as adamgoodwin@guidedailabs.com.</li>
  </ol>

  <p style="font-size:14px;line-height:1.5;margin:24px 0 0 0;color:#64748b;">Current access state: adamgoodwin@guidedailabs.com and admin@agoperations.ca have owner-level SharePoint access. contact@agoperations.ca remains intentionally excluded for now.</p>
</div>
"@
}

$results = New-Object System.Collections.Generic.List[object]

Start-Transcript -Path $transcriptPath -Force | Out-Null
try {
    Write-Host "Publishing Microsoft 365 Login And Account Guide" -ForegroundColor Cyan
    Write-Host "Safety: page/navigation only; no permissions, guests, external sharing, tenant policy, CRM data, mail, or automation changes." -ForegroundColor Yellow

    foreach ($siteUrl in $SiteUrls) {
        Write-Host ""
        Write-Host ("Site: {0}" -f $siteUrl) -ForegroundColor Cyan
        $pageCreated = $false
        $navCreated = $false
        $success = $true
        $message = "OK"
        $pageUrl = ($siteUrl.TrimEnd("/") + "/SitePages/" + $pageFileName)

        try {
            Connect-PnPOnline -Url $siteUrl -OSLogin
            $web = Get-PnPWeb -Includes Title, Url

            $pageExists = $true
            try {
                Get-PnPPage -Identity $pageFileName | Out-Null
            } catch {
                $pageExists = $false
            }

            if (-not $pageExists) {
                Add-PnPPage -Name $pageFileName -LayoutType Article | Out-Null
                Add-PnPPageSection -Page $pageFileName -SectionTemplate OneColumn -Order 1 | Out-Null
                Add-PnPPageTextPart -Page $pageFileName -Section 1 -Column 1 -Order 1 -Text (New-LoginGuideHtml) | Out-Null
                $pageCreated = $true
                Write-Host ("  Created page: {0}" -f $pageFileName) -ForegroundColor Yellow
            } else {
                Write-Host ("  Page already exists: {0}" -f $pageFileName) -ForegroundColor Green
            }

            Set-PnPPage -Identity $pageFileName -Title $pageTitle -Publish | Out-Null

            $existingNav = @(@(Get-PnPNavigationNode -Location QuickLaunch) | Where-Object {
                $_.Title -eq $navTitle -or $_.Url -eq $pageUrl
            })
            if (@($existingNav).Count -eq 0) {
                Add-PnPNavigationNode -Location QuickLaunch -Title $navTitle -Url $pageUrl -External | Out-Null
                $navCreated = $true
                Write-Host ("  Added nav link: {0}" -f $navTitle) -ForegroundColor Yellow
            } else {
                Write-Host ("  Nav link already exists: {0}" -f $navTitle) -ForegroundColor Green
            }

            Get-PnPPage -Identity $pageFileName | Out-Null
        } catch {
            $success = $false
            $message = $_.Exception.Message
            Write-Host ("  FAILED: {0}" -f $message) -ForegroundColor Red
        }

        $results.Add([pscustomobject]@{
            SiteUrl = $siteUrl
            PageUrl = $pageUrl
            PageCreated = $pageCreated
            NavigationCreated = $navCreated
            Success = $success
            Message = $message
        }) | Out-Null
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csvPath
    $failures = @($results | Where-Object { -not $_.Success })
    $resultText = if (@($failures).Count -eq 0) { "PASS" } else { "CHECK" }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Login And Account Guide Publish")
    $lines.Add("")
    $lines.Add(("Run: {0}" -f $stamp))
    $lines.Add(("Result: {0}" -f $resultText))
    $lines.Add(("Targeted sites: {0}" -f @($SiteUrls).Count))
    $lines.Add(("Failures: {0}" -f @($failures).Count))
    $lines.Add(("Transcript: {0}" -f $transcriptPath))
    $lines.Add(("CSV: {0}" -f $csvPath))
    $lines.Add("")
    $lines.Add("## Boundary")
    $lines.Add("")
    $lines.Add("This publishes a Login And Account Guide page and navigation link on the selected human-facing SharePoint sites. It does not change permissions, invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.")
    $lines.Add("")
    $lines.Add("## Pages")
    $lines.Add("")
    $lines.Add("| Site | Page | Success |")
    $lines.Add("| --- | --- | ---: |")
    foreach ($row in $results) {
        $lines.Add(("| {0} | {1} | {2} |" -f $row.SiteUrl, $row.PageUrl, $row.Success))
    }
    $lines | Set-Content -Encoding UTF8 -Path $summaryPath

    Write-Host ""
    Write-Host ("Login guide publish result: {0}" -f $resultText) -ForegroundColor ($(if ($resultText -eq "PASS") { "Green" } else { "Yellow" }))
    Write-Host "Summary: $summaryPath" -ForegroundColor Gray
    Write-Host "CSV: $csvPath" -ForegroundColor Gray
} finally {
    Stop-Transcript | Out-Null
}
