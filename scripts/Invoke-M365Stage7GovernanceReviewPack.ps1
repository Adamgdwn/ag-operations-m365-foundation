param(
    [string]$InventoryRoot = ".\inventory\stage-7-security-governance",
    [string]$InventoryPath,
    [string]$OutputPath
)

# Stage 7 - local-only governance review pack.
# Reads saved Stage 7 inventory files and produces a recommendation artifact.
# It does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-Stage7Path {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Read-Stage7Json {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    return ($raw | ConvertFrom-Json)
}

function Convert-Stage7SharingCapability {
    param([object]$Value)

    $asString = [string]$Value
    switch ($asString) {
        "0" { return "Disabled" }
        "1" { return "ExternalUserSharingOnly" }
        "2" { return "ExternalUserAndGuestSharing" }
        "3" { return "ExistingExternalUserSharingOnly" }
        default {
            if ([string]::IsNullOrWhiteSpace($asString)) {
                return ""
            }
            return $asString
        }
    }
}

function Get-Stage7LatestInventoryPath {
    param([string]$Root)

    $resolvedRoot = Resolve-Stage7Path -Path $Root
    if (-not (Test-Path -LiteralPath $resolvedRoot)) {
        throw "Inventory root was not found: $resolvedRoot"
    }

    $candidate = Get-ChildItem -LiteralPath $resolvedRoot -Directory |
        Where-Object {
            (Test-Path -LiteralPath (Join-Path $_.FullName "oauth2-permission-grants.json")) -or
            (Test-Path -LiteralPath (Join-Path $_.FullName "sharepoint-sites.json"))
        } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if ($null -eq $candidate) {
        throw "No Stage 7 inventory folder with reviewable JSON files was found under $resolvedRoot"
    }

    return $candidate.FullName
}

function Get-Stage7AppName {
    param(
        [hashtable]$AppsByObjectId,
        [string]$ObjectId
    )

    if ($AppsByObjectId.ContainsKey($ObjectId)) {
        return $AppsByObjectId[$ObjectId]
    }

    return $ObjectId
}

if ([string]::IsNullOrWhiteSpace($InventoryPath)) {
    $resolvedInventoryPath = Get-Stage7LatestInventoryPath -Root $InventoryRoot
}
else {
    $resolvedInventoryPath = Resolve-Stage7Path -Path $InventoryPath
}

if (-not (Test-Path -LiteralPath $resolvedInventoryPath)) {
    throw "Inventory path was not found: $resolvedInventoryPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutputPath = Join-Path $resolvedInventoryPath "stage-7-governance-review-pack.md"
}
else {
    $resolvedOutputPath = Resolve-Stage7Path -Path $OutputPath
}

$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$apps = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "enterprise-applications.json"))
$grants = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "oauth2-permission-grants.json"))
$sites = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "sharepoint-sites.json"))
$authMethods = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "user-authentication-method-summary.json"))

$appsByObjectId = @{}
foreach ($app in $apps) {
    if ($null -ne $app.id -and -not $appsByObjectId.ContainsKey([string]$app.id)) {
        $appsByObjectId[[string]$app.id] = [string]$app.displayName
    }
}

$criticalScopes = @(
    "AllSites.FullControl",
    "Sites.FullControl.All",
    "RoleManagement.ReadWrite.Directory",
    "Policy.ReadWrite.Authorization",
    "Directory.ReadWrite.All",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All"
)

$highScopes = @(
    "Group.ReadWrite.All",
    "User.ReadWrite.All",
    "Files.ReadWrite.All",
    "Sites.ReadWrite.All",
    "TermStore.ReadWrite.All",
    "ExternalConnection.ReadWrite.All",
    "Calendars.ReadWrite",
    "Calendars.ReadWrite.Shared",
    "Tasks.ReadWrite",
    "Forms.ReadWrite",
    "SMTP.Send",
    "EWS.AccessAsUser.All",
    "IMAP.AccessAsUser.All",
    "POP.AccessAsUser.All"
)

$mediumScopes = @(
    "offline_access",
    "AuditLog.Read.All",
    "Application.Read.All",
    "Directory.Read.All",
    "UserAuthenticationMethod.Read.All",
    "Files.Read.All",
    "Sites.Read.All"
)

$scopePriority = @{}
foreach ($scope in $criticalScopes) { $scopePriority[$scope] = "Critical" }
foreach ($scope in $highScopes) { $scopePriority[$scope] = "High" }
foreach ($scope in $mediumScopes) { $scopePriority[$scope] = "Medium" }

$flaggedGrants = New-Object System.Collections.Generic.List[object]
foreach ($grant in $grants) {
    $scopeNames = @(([string]$grant.scope) -split "\s+" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $matchedScopes = @($scopeNames | Where-Object { $scopePriority.ContainsKey($_) })
    if ($matchedScopes.Count -eq 0) {
        continue
    }

    $severity = "Medium"
    if (@($matchedScopes | Where-Object { $scopePriority[$_] -eq "Critical" }).Count -gt 0) {
        $severity = "Critical"
    }
    elseif (@($matchedScopes | Where-Object { $scopePriority[$_] -eq "High" }).Count -gt 0) {
        $severity = "High"
    }

    $appName = Get-Stage7AppName -AppsByObjectId $appsByObjectId -ObjectId ([string]$grant.clientId)
    $resourceName = Get-Stage7AppName -AppsByObjectId $appsByObjectId -ObjectId ([string]$grant.resourceId)
    $recommendation = "Review and document business need before partner/client onboarding."

    if ($appName -eq "agent-pnp-provisioning") {
        $recommendation = "Keep only while active build automation needs it; after Stage 8 setup, revoke broad delegated grants or disable the app registration/service principal."
    }
    elseif ($appName -eq "Microsoft Graph Command Line Tools") {
        $recommendation = "Keep only during admin inventory/write windows; remove admin-write delegated scopes when Stage 7 cleanup closes."
    }
    elseif ($appName -eq "SharePoint Online Web Client Extensibility") {
        $recommendation = "Treat carefully as a Microsoft first-party service principal; verify the exact feature dependency before revoking any SharePoint/connector grants."
    }
    elseif ($appName -eq "Thunderbird") {
        $recommendation = "Confirm mailbox use; prefer modern Outlook/Graph patterns and avoid standing POP/IMAP/EWS/SMTP access unless there is a named mailbox workflow."
    }
    elseif ($appName -eq "Calendly") {
        $recommendation = "Accept only if scheduling workflow is active; document owner and review date for calendar read/write access."
    }

    $flaggedGrants.Add([pscustomobject]@{
        Severity = $severity
        App = $appName
        Resource = $resourceName
        ConsentType = [string]$grant.consentType
        MatchedScopes = ($matchedScopes -join ", ")
        Recommendation = $recommendation
    })
}

$siteExceptions = New-Object System.Collections.Generic.List[object]
foreach ($site in $sites) {
    $sharing = Convert-Stage7SharingCapability -Value $site.SharingCapability
    if ($sharing -eq "Disabled") {
        continue
    }

    $url = [string]$site.Url
    $title = [string]$site.Title
    $recommendation = "Disable site-level external sharing unless there is a named workflow owner and partner/client use case."

    if ($url -eq "https://agoperationsltd.sharepoint.com/") {
        $recommendation = "Recommended Stage 7 cleanup candidate: disable external sharing on the root communication site unless it has a deliberate public/partner sharing workflow."
    }
    elseif ($url -like "*/sites/groupforanswersinvivaengagedonotdelete*") {
        $recommendation = "System-created Viva Engage site; avoid deleting, but disable external sharing if no external community workflow exists."
    }
    elseif ($title -in @("A.G. Operations Ltd", "All Company")) {
        $recommendation = "Recommended Stage 7 cleanup candidate: disable external sharing unless this group site is the approved partner collaboration location."
    }

    $siteExceptions.Add([pscustomobject]@{
        Site = ($(if ([string]::IsNullOrWhiteSpace($title)) { $url } else { $title }))
        Url = $url
        Template = [string]$site.Template
        SharingCapability = $sharing
        Recommendation = $recommendation
    })
}

$mfaGaps = New-Object System.Collections.Generic.List[object]
foreach ($user in $authMethods) {
    $methodTypes = @($user.methodTypes)
    $hasAuthenticator = (($methodTypes -join " ") -match "microsoftAuthenticatorAuthenticationMethod")
    if (-not $hasAuthenticator) {
        $mfaGaps.Add([pscustomobject]@{
            User = [string]$user.userPrincipalName
            MethodCount = [int]$user.methodCount
            MethodTypes = ($methodTypes -join ", ")
            Recommendation = "Register Microsoft Authenticator or equivalent strong method before this identity is used for business workflows."
        })
    }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 7 Governance Review Pack")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Inventory folder: `{0}`' -f $resolvedInventoryPath))
$lines.Add("")
$lines.Add("Scope: local-only review of saved Stage 7 inventory. This file does not change Microsoft 365.")
$lines.Add("")
$lines.Add("## Executive Recommendation")
$lines.Add("")
$lines.Add("Stage 7 core guardrails are in place. Before onboarding a business partner or client, close three cleanup items: set a resting state for broad delegated app grants, add MFA to the support mailbox identity, and disable or explicitly accept root/legacy SharePoint sharing exceptions.")
$lines.Add("")
$lines.Add("## Approval Gates")
$lines.Add("")
$lines.Add("| Gate | Recommended owner action | Automation stance |")
$lines.Add("|---|---|---|")
$lines.Add("| Broad app grants | Decide which setup grants remain active, time-boxed, or revoked | Approval required before any revoke/disable action |")
$lines.Add('| Support mailbox MFA | Register a strong method for `support@changeleadershiptools.com` | Manual/user-driven registration |')
$lines.Add("| Root/legacy site sharing | Disable exceptions unless a named workflow needs them | Approval required before site sharing changes |")
$lines.Add("")

$lines.Add("## Broad Delegated App Grants")
$lines.Add("")
if ($flaggedGrants.Count -eq 0) {
    $lines.Add("No risky delegated grants were flagged in the saved inventory.")
}
else {
    $lines.Add("| Severity | App | Resource | Consent | Matched scopes | Recommendation |")
    $lines.Add("|---|---|---|---|---|---|")
    foreach ($grant in ($flaggedGrants | Sort-Object @{ Expression = { switch ($_.Severity) { "Critical" { 0 } "High" { 1 } default { 2 } } } }, App, Resource)) {
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} |" -f $grant.Severity, $grant.App, $grant.Resource, $grant.ConsentType, $grant.MatchedScopes, $grant.Recommendation))
    }
}
$lines.Add("")

$lines.Add("## SharePoint Sharing Exceptions")
$lines.Add("")
if ($siteExceptions.Count -eq 0) {
    $lines.Add("No site-level sharing exceptions were flagged; all reviewed sites are disabled for external sharing.")
}
else {
    $lines.Add("| Site | Sharing | Template | Recommendation |")
    $lines.Add("|---|---|---|---|")
    foreach ($site in ($siteExceptions | Sort-Object Site)) {
        $lines.Add(("| [{0}]({1}) | {2} | {3} | {4} |" -f $site.Site, $site.Url, $site.SharingCapability, $site.Template, $site.Recommendation))
    }
}
$lines.Add("")

$lines.Add("## MFA Gaps")
$lines.Add("")
if ($mfaGaps.Count -eq 0) {
    $lines.Add("No MFA gaps were flagged in the saved authentication-method summary.")
}
else {
    $lines.Add("| User | Method count | Methods | Recommendation |")
    $lines.Add("|---|---:|---|---|")
    foreach ($gap in ($mfaGaps | Sort-Object User)) {
        $lines.Add(("| {0} | {1} | {2} | {3} |" -f $gap.User, $gap.MethodCount, $gap.MethodTypes, $gap.Recommendation))
    }
}
$lines.Add("")

$lines.Add("## Suggested Closeout Sequence")
$lines.Add("")
$lines.Add('1. Register MFA for `support@changeleadershiptools.com`.')
$lines.Add('2. Record a time-boxed resting-state decision for `agent-pnp-provisioning` and Microsoft Graph PowerShell admin scopes.')
$lines.Add("3. Approve a site-sharing cleanup batch for root/legacy exceptions, or record accepted exceptions with workflow owner and review date.")
$lines.Add("4. Start Stage 8 client workspace pattern only after those exceptions are either closed or explicitly accepted.")
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

Write-Host "Stage 7 governance review pack written:" -ForegroundColor Green
Write-Host $resolvedOutputPath -ForegroundColor Gray
