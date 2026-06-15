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
$transcriptPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-readback-{0}.log" -f $stamp)
$summaryPath = Join-Path $resolvedOutputDirectory ("SHAREPOINT_OWNER_ACCESS_READBACK_{0}.md" -f $stamp)
$csvPath = Join-Path $resolvedOutputDirectory ("sharepoint-owner-access-readback-{0}.csv" -f $stamp)

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

$results = New-Object System.Collections.Generic.List[object]

Start-Transcript -Path $transcriptPath -Force | Out-Null
try {
    Write-Host "Microsoft 365 SharePoint owner access read-back" -ForegroundColor Cyan
    Write-Host "User: $UserUpn" -ForegroundColor White

    foreach ($siteUrl in $SiteUrls) {
        Write-Host ""
        Write-Host "Connecting to $siteUrl" -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -OSLogin

        $web = Get-PnPWeb -Includes AssociatedOwnerGroup, AssociatedMemberGroup, AssociatedVisitorGroup, Title, Url, HasUniqueRoleAssignments
        $ownersGroupTitle = if ($null -ne $web.AssociatedOwnerGroup) { [string]$web.AssociatedOwnerGroup.Title } else { "" }

        $siteAdmins = @(Get-PnPSiteCollectionAdmin | Select-Object Title, LoginName, Email, IsSiteAdmin)
        $siteUsers = @(Get-PnPUser | Select-Object Title, LoginName, Email, IsSiteAdmin)
        $ownerMembers = @()

        if (-not [string]::IsNullOrWhiteSpace($ownersGroupTitle)) {
            $ownerMembers = @(Get-PnPGroupMember -Identity $ownersGroupTitle | Select-Object Title, LoginName, Email, IsSiteAdmin)
        }

        $inSiteAdmins = Test-UserInCollection -Users $siteAdmins -Upn $UserUpn
        $inOwnersGroup = Test-UserInCollection -Users $ownerMembers -Upn $UserUpn
        $inSiteUsers = Test-UserInCollection -Users $siteUsers -Upn $UserUpn

        Write-Host ("Site: {0} <{1}>" -f $web.Title, $web.Url) -ForegroundColor White
        Write-Host ("Owners group: {0}" -f $ownersGroupTitle) -ForegroundColor White
        Write-Host ("Read-back: siteAdmin={0}; ownersGroup={1}; siteUsers={2}" -f $inSiteAdmins, $inOwnersGroup, $inSiteUsers) -ForegroundColor ($(if ($inSiteAdmins -or $inOwnersGroup) { "Green" } else { "Red" }))

        $results.Add([pscustomobject]@{
            SiteUrl = $siteUrl
            SiteTitle = [string]$web.Title
            UserUpn = $UserUpn
            OwnersGroup = $ownersGroupTitle
            InSiteCollectionAdmins = $inSiteAdmins
            InOwnersGroup = $inOwnersGroup
            InSiteUsers = $inSiteUsers
            WebHasUniqueRoleAssignments = [bool]$web.HasUniqueRoleAssignments
        }) | Out-Null
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csvPath

    $bad = @($results | Where-Object { -not ($_.InSiteCollectionAdmins -or $_.InOwnersGroup) })

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# SharePoint Owner Access Read-Back")
    $lines.Add("")
    $lines.Add(("Run: {0}" -f $stamp))
    $lines.Add(("User: {0}" -f $UserUpn))
    $lines.Add(("Result: {0}" -f ($(if (@($bad).Count -eq 0) { "PASS" } else { "FAIL" }))))
    $lines.Add(("Transcript: {0}" -f $transcriptPath))
    $lines.Add(("CSV: {0}" -f $csvPath))
    $lines.Add("")
    $lines.Add("| Site | Site collection admin | Owners group member | Site user |")
    $lines.Add("| --- | ---: | ---: | ---: |")
    foreach ($result in $results) {
        $lines.Add(("| {0} | {1} | {2} | {3} |" -f $result.SiteUrl, $result.InSiteCollectionAdmins, $result.InOwnersGroup, $result.InSiteUsers))
    }
    $lines | Set-Content -Encoding UTF8 -Path $summaryPath

    Write-Host ""
    Write-Host ("Read-back result: {0}" -f ($(if (@($bad).Count -eq 0) { "PASS" } else { "FAIL" }))) -ForegroundColor ($(if (@($bad).Count -eq 0) { "Green" } else { "Red" }))
    Write-Host "Summary: $summaryPath" -ForegroundColor Gray
    Write-Host "CSV: $csvPath" -ForegroundColor Gray
} finally {
    Stop-Transcript | Out-Null
}
