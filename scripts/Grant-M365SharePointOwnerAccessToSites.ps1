param(
    [string]$AdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [string[]]$UserUpns = @(
        "adamgoodwin@guidedailabs.com",
        "admin@agoperations.ca"
    ),
    [string]$OutputDirectory = ".\inventory\access-repair",
    [switch]$IncludeOneDriveSites
)

$ErrorActionPreference = "Stop"

Import-Module PnP.PowerShell

$resolvedOutputDirectory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-all-sites-{0}.log" -f $stamp)
$siteInventoryCsvPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-site-inventory-{0}.csv" -f $stamp)
$tenantAdminGrantCsvPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-tenant-admin-grants-{0}.csv" -f $stamp)
$resultCsvPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-all-sites-results-{0}.csv" -f $stamp)
$summaryPath = Join-Path $resolvedOutputDirectory ("SHAREPOINT_OWNER_ACCESS_ALL_SITES_{0}.md" -f $stamp)

function Test-UserInCollection {
    param(
        [object[]]$Users,
        [string]$Upn
    )

    return (@($Users | Where-Object {
        $_.Email -eq $Upn -or
        $_.LoginName -like "*$Upn*" -or
        $_.UserPrincipalName -eq $Upn
    }).Count -gt 0)
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Results,
        [string]$SiteUrl,
        [string]$SiteTitle,
        [string]$Template,
        [string]$UserUpn,
        [string]$OwnersGroup,
        [bool]$AlreadyInOwnersGroup,
        [bool]$AddedToOwnersGroup,
        [bool]$AlreadySiteCollectionAdmin,
        [bool]$AddedAsSiteCollectionAdmin,
        [bool]$Success,
        [string]$Message
    )

    $Results.Add([pscustomobject]@{
        SiteUrl = $SiteUrl
        SiteTitle = $SiteTitle
        Template = $Template
        UserUpn = $UserUpn
        OwnersGroup = $OwnersGroup
        AlreadyInOwnersGroup = $AlreadyInOwnersGroup
        AddedToOwnersGroup = $AddedToOwnersGroup
        AlreadySiteCollectionAdmin = $AlreadySiteCollectionAdmin
        AddedAsSiteCollectionAdmin = $AddedAsSiteCollectionAdmin
        Success = $Success
        Message = $Message
    }) | Out-Null
}

$results = New-Object System.Collections.Generic.List[object]
$tenantAdminGrantResults = New-Object System.Collections.Generic.List[object]

Start-Transcript -Path $transcriptPath -Force | Out-Null
try {
    Write-Host "Microsoft 365 SharePoint owner access grant - all tenant sites" -ForegroundColor Cyan
    Write-Host ("Admin URL: {0}" -f $AdminUrl) -ForegroundColor White
    Write-Host ("Users: {0}" -f ($UserUpns -join ", ")) -ForegroundColor White
    Write-Host "Safety: named internal users only; no guests, external sharing, anonymous links, tenant policy, CRM data, mail, or automation changes." -ForegroundColor Yellow

    Connect-PnPOnline -Url $AdminUrl -OSLogin
    $tenantSiteParams = @{ Detailed = $true }
    if ($IncludeOneDriveSites) {
        $tenantSiteParams.IncludeOneDriveSites = $true
    }

    $sites = @(Get-PnPTenantSite @tenantSiteParams | Sort-Object Url)
    $targetSites = @($sites | Where-Object {
        $_.Url -like "https://agoperationsltd.sharepoint.com*" -and
        $_.Url -notlike "https://agoperationsltd-my.sharepoint.com*"
    })

    $targetSites |
        Select-Object Title, Url, Template, GroupId, Owner, Status, LockState, SharingCapability |
        Export-Csv -NoTypeInformation -Encoding UTF8 -Path $siteInventoryCsvPath

    Write-Host ("Tenant sites found: {0}; targeted: {1}" -f @($sites).Count, @($targetSites).Count) -ForegroundColor White

    foreach ($site in $targetSites) {
        Write-Host ("Adding secondary site collection admins from tenant admin: {0}" -f $site.Url) -ForegroundColor Cyan
        $tenantAdminGrantOk = $true
        $tenantAdminGrantMessage = "OK"
        try {
            Set-PnPTenantSite -Identity $site.Url -Owners $UserUpns
        } catch {
            $tenantAdminGrantOk = $false
            $tenantAdminGrantMessage = $_.Exception.Message
            Write-Host ("  Tenant-admin grant failed: {0}" -f $tenantAdminGrantMessage) -ForegroundColor Yellow
        }

        $tenantAdminGrantResults.Add([pscustomobject]@{
            SiteUrl = [string]$site.Url
            SiteTitle = [string]$site.Title
            Template = [string]$site.Template
            UserUpns = ($UserUpns -join ";")
            Success = $tenantAdminGrantOk
            Message = $tenantAdminGrantMessage
        }) | Out-Null
    }

    $tenantAdminGrantResults | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $tenantAdminGrantCsvPath

    foreach ($site in $targetSites) {
        $siteUrl = [string]$site.Url
        $siteTitle = [string]$site.Title
        $template = [string]$site.Template

        Write-Host ""
        Write-Host ("Site: {0} <{1}> [{2}]" -f $siteTitle, $siteUrl, $template) -ForegroundColor Cyan

        try {
            Connect-PnPOnline -Url $siteUrl -OSLogin
            $web = Get-PnPWeb -Includes AssociatedOwnerGroup, Title, Url
            $ownersGroupTitle = if ($null -ne $web.AssociatedOwnerGroup) { [string]$web.AssociatedOwnerGroup.Title } else { "" }
            $ownerMembers = @()
            if (-not [string]::IsNullOrWhiteSpace($ownersGroupTitle)) {
                $ownerMembers = @(Get-PnPGroupMember -Identity $ownersGroupTitle | Select-Object Title, LoginName, Email)
            }
            $siteAdmins = @(Get-PnPSiteCollectionAdmin | Select-Object Title, LoginName, Email)

            foreach ($userUpn in $UserUpns) {
                $addedToOwnersGroup = $false
                $addedAsSiteAdmin = $false
                $alreadyInOwnersGroup = $false
                $alreadySiteAdmin = $false

                try {
                    Write-Host ("  Ensuring {0}" -f $userUpn) -ForegroundColor White
                    New-PnPUser -LoginName $userUpn | Out-Null

                    if (-not [string]::IsNullOrWhiteSpace($ownersGroupTitle)) {
                        $alreadyInOwnersGroup = Test-UserInCollection -Users $ownerMembers -Upn $userUpn
                        if (-not $alreadyInOwnersGroup) {
                            Add-PnPGroupMember -Identity $ownersGroupTitle -LoginName $userUpn | Out-Null
                            $addedToOwnersGroup = $true
                            $ownerMembers = @(Get-PnPGroupMember -Identity $ownersGroupTitle | Select-Object Title, LoginName, Email)
                            Write-Host ("    Added to owners group: {0}" -f $ownersGroupTitle) -ForegroundColor Yellow
                        } else {
                            Write-Host ("    Already in owners group: {0}" -f $ownersGroupTitle) -ForegroundColor Green
                        }
                    } else {
                        Write-Host "    No associated owners group returned; relying on site collection admin." -ForegroundColor Yellow
                    }

                    $alreadySiteAdmin = Test-UserInCollection -Users $siteAdmins -Upn $userUpn
                    if (-not $alreadySiteAdmin) {
                        Add-PnPSiteCollectionAdmin -Owners $userUpn
                        $addedAsSiteAdmin = $true
                        $siteAdmins = @(Get-PnPSiteCollectionAdmin | Select-Object Title, LoginName, Email)
                        Write-Host "    Added as site collection admin." -ForegroundColor Yellow
                    } else {
                        Write-Host "    Already site collection admin." -ForegroundColor Green
                    }

                    Add-Result -Results $results -SiteUrl $siteUrl -SiteTitle $siteTitle -Template $template -UserUpn $userUpn -OwnersGroup $ownersGroupTitle -AlreadyInOwnersGroup $alreadyInOwnersGroup -AddedToOwnersGroup $addedToOwnersGroup -AlreadySiteCollectionAdmin $alreadySiteAdmin -AddedAsSiteCollectionAdmin $addedAsSiteAdmin -Success $true -Message "OK"
                } catch {
                    Write-Host ("    FAILED for {0}: {1}" -f $userUpn, $_.Exception.Message) -ForegroundColor Red
                    Add-Result -Results $results -SiteUrl $siteUrl -SiteTitle $siteTitle -Template $template -UserUpn $userUpn -OwnersGroup $ownersGroupTitle -AlreadyInOwnersGroup $alreadyInOwnersGroup -AddedToOwnersGroup $addedToOwnersGroup -AlreadySiteCollectionAdmin $alreadySiteAdmin -AddedAsSiteCollectionAdmin $addedAsSiteAdmin -Success $false -Message $_.Exception.Message
                }
            }
        } catch {
            Write-Host ("  FAILED site connection/apply: {0}" -f $_.Exception.Message) -ForegroundColor Red
            foreach ($userUpn in $UserUpns) {
                Add-Result -Results $results -SiteUrl $siteUrl -SiteTitle $siteTitle -Template $template -UserUpn $userUpn -OwnersGroup "" -AlreadyInOwnersGroup $false -AddedToOwnersGroup $false -AlreadySiteCollectionAdmin $false -AddedAsSiteCollectionAdmin $false -Success $false -Message $_.Exception.Message
            }
        }
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $resultCsvPath

    $failures = @($results | Where-Object { -not $_.Success })
    $resultText = if (@($failures).Count -eq 0) { "PASS" } else { "CHECK" }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# SharePoint Owner Access - All Sites")
    $lines.Add("")
    $lines.Add(("Run: {0}" -f $stamp))
    $lines.Add(("Result: {0}" -f $resultText))
    $lines.Add(("Admin URL: {0}" -f $AdminUrl))
    $lines.Add(("Users: {0}" -f ($UserUpns -join ", ")))
    $lines.Add(("Targeted sites: {0}" -f @($targetSites).Count))
    $lines.Add(("Successful user-site grants/read-backs: {0}" -f @($results | Where-Object { $_.Success }).Count))
    $lines.Add(("Failed user-site grants/read-backs: {0}" -f @($failures).Count))
    $lines.Add(("Transcript: {0}" -f $transcriptPath))
    $lines.Add(("Site inventory CSV: {0}" -f $siteInventoryCsvPath))
    $lines.Add(("Tenant-admin grant CSV: {0}" -f $tenantAdminGrantCsvPath))
    $lines.Add(("Result CSV: {0}" -f $resultCsvPath))
    $lines.Add("")
    $lines.Add("## Boundary")
    $lines.Add("")
    $lines.Add("This grants only the named internal user accounts owner-level SharePoint access. It does not add contact@agoperations.ca, invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.")
    $lines.Add("")
    $lines.Add("## Site Summary")
    $lines.Add("")
    $lines.Add("| Site | Template | User | Added to owners | Added as site collection admin | Success |")
    $lines.Add("| --- | --- | --- | ---: | ---: | ---: |")
    foreach ($row in $results) {
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} |" -f $row.SiteUrl, $row.Template, $row.UserUpn, $row.AddedToOwnersGroup, $row.AddedAsSiteCollectionAdmin, $row.Success))
    }
    if (@($failures).Count -gt 0) {
        $lines.Add("")
        $lines.Add("## Failures")
        $lines.Add("")
        foreach ($failure in $failures) {
            $lines.Add(("- {0} / {1}: {2}" -f $failure.SiteUrl, $failure.UserUpn, $failure.Message))
        }
    }
    $lines | Set-Content -Encoding UTF8 -Path $summaryPath

    Write-Host ""
    Write-Host ("All-site owner access result: {0}" -f $resultText) -ForegroundColor ($(if ($resultText -eq "PASS") { "Green" } else { "Yellow" }))
    Write-Host "Summary: $summaryPath" -ForegroundColor Gray
    Write-Host "Result CSV: $resultCsvPath" -ForegroundColor Gray
} finally {
    Stop-Transcript | Out-Null
}
