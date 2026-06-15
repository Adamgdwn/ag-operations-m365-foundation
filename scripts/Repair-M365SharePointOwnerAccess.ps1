param(
    [string[]]$SiteUrls = @(
        "https://agoperationsltd.sharepoint.com",
        "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs"
    ),
    [string]$UserUpn = "adamgoodwin@guidedailabs.com",
    [string]$OutputDirectory = ".\inventory\access-repair"
)

$ErrorActionPreference = "Stop"

Import-Module PnP.PowerShell

$resolvedOutputDirectory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-repair-{0}.log" -f $stamp)
$summaryPath = Join-Path $resolvedOutputDirectory ("SHAREPOINT_OWNER_ACCESS_REPAIR_{0}.md" -f $stamp)
$csvPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-repair-{0}.csv" -f $stamp)

$results = New-Object System.Collections.Generic.List[object]

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

Start-Transcript -Path $transcriptPath -Force | Out-Null
try {
    Write-Host "Microsoft 365 SharePoint owner access repair" -ForegroundColor Cyan
    Write-Host "User: $UserUpn" -ForegroundColor White
    Write-Host "Safety: named internal owner only; no guests, external sharing, anonymous links, tenant policy, or CRM data changes." -ForegroundColor Yellow

    foreach ($siteUrl in $SiteUrls) {
        Write-Host ""
        Write-Host "Connecting to $siteUrl" -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -OSLogin

        $web = Get-PnPWeb -Includes AssociatedOwnerGroup,AssociatedMemberGroup,AssociatedVisitorGroup,Title,Url
        Write-Host ("Site: {0} <{1}>" -f $web.Title, $web.Url) -ForegroundColor White

        $ensuredUser = New-PnPUser -LoginName $UserUpn
        Write-Host ("Resolved user: {0} <{1}>" -f $ensuredUser.Title, $ensuredUser.LoginName) -ForegroundColor White

        $ownersGroupTitle = if ($null -ne $web.AssociatedOwnerGroup) { [string]$web.AssociatedOwnerGroup.Title } else { "" }
        $addedToOwnersGroup = $false
        $alreadyInOwnersGroup = $false

        if (-not [string]::IsNullOrWhiteSpace($ownersGroupTitle)) {
            $ownerMembersBefore = @(Get-PnPGroupMember -Identity $ownersGroupTitle | Select-Object Title, LoginName, Email)
            $alreadyInOwnersGroup = Test-UserInCollection -Users $ownerMembersBefore -Upn $UserUpn
            if (-not $alreadyInOwnersGroup) {
                Write-Host ("Adding {0} to owners group: {1}" -f $UserUpn, $ownersGroupTitle) -ForegroundColor Yellow
                Add-PnPGroupMember -Identity $ownersGroupTitle -LoginName $UserUpn | Out-Null
                $addedToOwnersGroup = $true
            } else {
                Write-Host ("Already in owners group: {0}" -f $ownersGroupTitle) -ForegroundColor Green
            }
        } else {
            Write-Host "No associated owners group was returned for this site." -ForegroundColor Yellow
        }

        $siteAdminsBefore = @(Get-PnPSiteCollectionAdmin | Select-Object Title, LoginName, Email)
        $alreadySiteAdmin = Test-UserInCollection -Users $siteAdminsBefore -Upn $UserUpn
        $addedAsSiteAdmin = $false

        if (-not $alreadySiteAdmin) {
            Write-Host ("Adding {0} as site collection admin" -f $UserUpn) -ForegroundColor Yellow
            Add-PnPSiteCollectionAdmin -Owners $UserUpn
            $addedAsSiteAdmin = $true
        } else {
            Write-Host "Already a site collection admin." -ForegroundColor Green
        }

        $result = [pscustomobject]@{
            SiteUrl = $siteUrl
            SiteTitle = [string]$web.Title
            UserUpn = $UserUpn
            OwnersGroup = $ownersGroupTitle
            AlreadyInOwnersGroup = $alreadyInOwnersGroup
            AddedToOwnersGroup = $addedToOwnersGroup
            AlreadySiteCollectionAdmin = $alreadySiteAdmin
            AddedAsSiteCollectionAdmin = $addedAsSiteAdmin
        }
        $results.Add($result) | Out-Null
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csvPath

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# SharePoint Owner Access Repair")
    $lines.Add("")
    $lines.Add(("Run: {0}" -f $stamp))
    $lines.Add(("User: {0}" -f $UserUpn))
    $lines.Add(("Transcript: {0}" -f $transcriptPath))
    $lines.Add(("CSV: {0}" -f $csvPath))
    $lines.Add("")
    $lines.Add("## Scope")
    $lines.Add("")
    $lines.Add("This repair grants only the named internal owner account access to the listed SharePoint sites.")
    $lines.Add("It does not invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.")
    $lines.Add("")
    $lines.Add("## Results")
    $lines.Add("")
    $lines.Add("| Site | Owners group | Added to owners | Added as site collection admin |")
    $lines.Add("| --- | --- | ---: | ---: |")
    foreach ($result in $results) {
        $lines.Add(("| {0} | {1} | {2} | {3} |" -f $result.SiteUrl, $result.OwnersGroup, $result.AddedToOwnersGroup, $result.AddedAsSiteCollectionAdmin))
    }
    $lines | Set-Content -Encoding UTF8 -Path $summaryPath

    Write-Host ""
    Write-Host "Access repair complete." -ForegroundColor Green
    Write-Host "Summary: $summaryPath" -ForegroundColor Gray
    Write-Host "CSV: $csvPath" -ForegroundColor Gray
} finally {
    Stop-Transcript | Out-Null
}
