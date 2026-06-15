param(
    [string]$InventoryPath,
    [string]$OutputPath
)

# Local post-processor for Stage 7 inventory output. No Microsoft 365 connection.

$ErrorActionPreference = "Stop"

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Import-JsonIfExists {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    if ((Get-Item -LiteralPath $Path).Length -eq 0) {
        return $null
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Import-JsonArrayIfExists {
    param([string]$Path)

    $value = Import-JsonIfExists $Path
    if ($null -eq $value) {
        return @()
    }

    return @($value)
}

function Format-SharingCapability {
    param($Value)

    switch ([int]$Value) {
        0 { return "Disabled" }
        1 { return "ExternalUserSharingOnly" }
        2 { return "ExternalUserAndGuestSharing" }
        3 { return "ExistingExternalUserSharingOnly" }
        default { return "Unknown($Value)" }
    }
}

function Format-SharingLinkType {
    param($Value)

    switch ([int]$Value) {
        0 { return "None" }
        1 { return "Direct" }
        2 { return "Internal" }
        3 { return "AnonymousAccess" }
        default { return "Unknown($Value)" }
    }
}

if ([string]::IsNullOrWhiteSpace($InventoryPath)) {
    $root = Resolve-WorkspacePath ".\inventory\stage-7-security-governance"
    $latest = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($null -eq $latest) {
        throw "No Stage 7 inventory folder found under $root"
    }
    $resolvedInventoryPath = $latest.FullName
}
else {
    $resolvedInventoryPath = Resolve-WorkspacePath $InventoryPath
}

if (-not (Test-Path -LiteralPath $resolvedInventoryPath)) {
    throw "Inventory path not found: $resolvedInventoryPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutputPath = Join-Path $resolvedInventoryPath "stage-7-security-inventory-summary.md"
}
else {
    $resolvedOutputPath = Resolve-WorkspacePath $OutputPath
}

$summary = Import-JsonIfExists (Join-Path $resolvedInventoryPath "summary.json")
$skus = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "subscribed-skus.json")
$users = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "users.json")
$roleMembers = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "directory-role-members.json")
$oauth2Grants = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "oauth2-permission-grants.json")
$servicePrincipals = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "enterprise-applications.json")
$authorizationPolicy = Import-JsonIfExists (Join-Path $resolvedInventoryPath "authorization-policy.json")
$securityDefaults = Import-JsonIfExists (Join-Path $resolvedInventoryPath "identity-security-defaults.json")
$conditionalAccess = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "conditional-access-policies.json")
$authMethods = Import-JsonArrayIfExists (Join-Path $resolvedInventoryPath "user-authentication-method-summary.json")
$sharePointTenant = Import-JsonIfExists (Join-Path $resolvedInventoryPath "sharepoint-tenant.json")
$sharePointSitesPath = Join-Path $resolvedInventoryPath "sharepoint-sites.json"
$sharePointSites = Import-JsonArrayIfExists $sharePointSitesPath
$inventoryErrors = @(Get-ChildItem -LiteralPath $resolvedInventoryPath -Filter "*.error.json" -File -ErrorAction SilentlyContinue)
$servicePrincipalById = @{}
foreach ($servicePrincipal in $servicePrincipals) {
    if ($servicePrincipal.id) {
        $servicePrincipalById[[string]$servicePrincipal.id] = $servicePrincipal
    }
}

$hasBusinessPremium = @($skus | Where-Object { $_.skuPartNumber -eq "SPB" }).Count -gt 0
$businessStandard = @($skus | Where-Object { $_.skuPartNumber -eq "O365_BUSINESS_PREMIUM" }).Count -gt 0
$guestUsers = @($users | Where-Object { $_.userType -eq "Guest" })
$globalAdmins = @($roleMembers | Where-Object { $_.roleName -eq "Global Administrator" })

$broadGrantPatterns = @(
    "AllSites.FullControl",
    "Sites.FullControl.All",
    "Sites.ReadWrite.All",
    "Directory.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory",
    "Group.ReadWrite.All",
    "Mail.ReadWrite",
    "MailboxSettings.ReadWrite",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All"
)

$broadGrants = @()
foreach ($grant in $oauth2Grants) {
    $scope = [string]$grant.scope
    foreach ($pattern in $broadGrantPatterns) {
        if ($scope -like "*$pattern*") {
            $broadGrants += [pscustomobject]@{
                clientId = $grant.clientId
                clientDisplayName = if ($servicePrincipalById.ContainsKey([string]$grant.clientId)) { $servicePrincipalById[[string]$grant.clientId].displayName } else { "" }
                consentType = $grant.consentType
                principalId = $grant.principalId
                scope = $scope
                matched = $pattern
            }
            break
        }
    }
}

$securityDefaultsState = "not read"
if ($null -ne $securityDefaults) {
    $securityDefaultsState = if ($securityDefaults.isEnabled -eq $true) { "enabled" } else { "disabled" }
}

$allowInvitesFrom = if ($null -ne $authorizationPolicy) { [string]$authorizationPolicy.allowInvitesFrom } else { "not read" }
$riskyUserConsent = if ($null -ne $authorizationPolicy) { [string]$authorizationPolicy.allowUserConsentForRiskyApps } else { "not read" }
$guestRole = if ($null -ne $authorizationPolicy) { [string]$authorizationPolicy.guestUserRoleId } else { "not read" }
$sharePointSiteSharingRead = (Test-Path -LiteralPath $sharePointSitesPath) -and (@($sharePointSites).Count -gt 0)
$sharePointTenantSharing = if ($null -ne $sharePointTenant -and $null -ne $sharePointTenant.SharingCapability) { Format-SharingCapability $sharePointTenant.SharingCapability } else { "not read" }
$sharePointDefaultLinkType = if ($null -ne $sharePointTenant -and $null -ne $sharePointTenant.DefaultSharingLinkType) { Format-SharingLinkType $sharePointTenant.DefaultSharingLinkType } else { "not read" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 7 Security/Governance Inventory Summary")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(("Inventory folder: ``{0}``" -f $resolvedInventoryPath))
$lines.Add("")
$lines.Add("Scope: read-only inventory summary. This file does not change Microsoft 365.")
$lines.Add("")
$lines.Add("## Snapshot")
$lines.Add("")
$lines.Add("| Area | Value |")
$lines.Add("|---|---|")
$lines.Add(("| Users | {0} |" -f @($users).Count))
$lines.Add(("| Guest users | {0} |" -f @($guestUsers).Count))
$lines.Add(("| Directory role assignments | {0} |" -f @($roleMembers).Count))
$lines.Add(("| Global Administrators | {0} |" -f @($globalAdmins).Count))
$lines.Add(("| App delegated permission grants | {0} |" -f @($oauth2Grants).Count))
$lines.Add(("| Broad delegated grants flagged | {0} |" -f @($broadGrants).Count))
$lines.Add(("| Conditional Access policies read | {0} |" -f @($conditionalAccess).Count))
$lines.Add(("| Security Defaults | {0} |" -f $securityDefaultsState))
$lines.Add(("| Guest invite setting | {0} |" -f $allowInvitesFrom))
$lines.Add(("| Risky user consent allowed | {0} |" -f $riskyUserConsent))
$lines.Add(("| Business Standard detected | {0} |" -f $businessStandard))
$lines.Add(("| Business Premium detected | {0} |" -f $hasBusinessPremium))
$lines.Add(("| SharePoint site sharing read | {0} |" -f ($(if ($sharePointSiteSharingRead) { "yes" } else { "no" }))))
$lines.Add(("| SharePoint tenant sharing | {0} |" -f $sharePointTenantSharing))
$lines.Add(("| SharePoint default sharing link | {0} |" -f $sharePointDefaultLinkType))
$lines.Add(("| Inventory read gaps | {0} |" -f @($inventoryErrors).Count))
$lines.Add("")

$lines.Add("## Findings")
$lines.Add("")
if ($hasBusinessPremium) {
    $lines.Add("- Business Premium appears present, so Conditional Access should be evaluated as the preferred Stage 7 path.")
}
elseif ($businessStandard) {
    $lines.Add("- Business Standard appears present without Business Premium; Security Defaults is the practical free baseline unless Entra P1 is added.")
}
else {
    $lines.Add("- Business Premium was not detected from the subscribed SKU read-back; confirm licensing before planning Conditional Access.")
}

if ($securityDefaultsState -eq "enabled") {
    $lines.Add("- Security Defaults are enabled. Confirm setup scripts can use a compatible auth pattern because Security Defaults can block device-code flow.")
}
elseif ($securityDefaultsState -eq "disabled") {
    $lines.Add("- Security Defaults are disabled. Stage 7 needs either a Conditional Access replacement or an accepted-risk record.")
}
else {
    $lines.Add("- Security Defaults could not be read; keep this as a live verification gap.")
}

if ($allowInvitesFrom -eq "everyone" -or $allowInvitesFrom -eq "adminsGuestInvitersAndAllMembers") {
    $lines.Add("- Guest invitation posture may be too open for the target partner/client model; prefer admin or guest-inviter controlled invitations.")
}
elseif ($allowInvitesFrom -ne "not read") {
    $lines.Add("- Guest invitation posture is not fully open; confirm it matches the partner onboarding process.")
}
else {
    $lines.Add("- Guest invitation posture could not be read.")
}

if (@($broadGrants).Count -gt 0) {
    $lines.Add("- Broad delegated app grants were detected. Review whether each is active setup capability, idle capability, or future bridge capability.")
}
else {
    $lines.Add("- No broad delegated app grants were flagged by the local pattern scan.")
}

if (@($guestUsers).Count -gt 0) {
    $lines.Add("- Guest users already exist. Review whether each has an owner, purpose, and end date before expanding external collaboration.")
}
else {
    $lines.Add("- No guest users were found in this read-back.")
}

if (-not $sharePointSiteSharingRead) {
    $lines.Add("- SharePoint site sharing posture was not collected. Run with `-IncludeSharePointAdmin` after installing the SharePoint Online module if site-level sharing needs read-back.")
}
elseif ($sharePointTenantSharing -eq "ExternalUserAndGuestSharing" -or $sharePointDefaultLinkType -eq "AnonymousAccess") {
    $lines.Add("- SharePoint tenant sharing is permissive enough for anonymous/Anyone links. Keep site-level restrictions on AG/GAL operating sites and tighten tenant defaults before client workflows.")
}
if (@($inventoryErrors).Count -gt 0) {
    $lines.Add("- One or more read-only inventory calls wrote an error file. Review the read gaps before closing Stage 7.")
}
$lines.Add("")

$lines.Add("## Global Administrators")
$lines.Add("")
if (@($globalAdmins).Count -eq 0) {
    $lines.Add("No Global Administrator assignments were present in the inventory output, or the role-member read failed.")
}
else {
    $lines.Add("| Display name | User principal name |")
    $lines.Add("|---|---|")
    foreach ($admin in $globalAdmins | Sort-Object userPrincipalName) {
        $lines.Add(("| {0} | {1} |" -f $admin.displayName, $admin.userPrincipalName))
    }
}
$lines.Add("")

$lines.Add("## Broad Delegated Grants")
$lines.Add("")
if (@($broadGrants).Count -eq 0) {
    $lines.Add("No broad delegated grants were flagged by the pattern scan.")
}
else {
    $lines.Add("| Matched scope | App | Consent type | Client ID | Principal ID |")
    $lines.Add("|---|---|---|---|---|")
    foreach ($grant in $broadGrants | Sort-Object matched, clientDisplayName, clientId) {
        $appName = if ([string]::IsNullOrWhiteSpace($grant.clientDisplayName)) { "(unresolved)" } else { $grant.clientDisplayName }
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f $grant.matched, $appName, $grant.consentType, $grant.clientId, $grant.principalId))
    }
}
$lines.Add("")

$lines.Add("## Inventory Read Gaps")
$lines.Add("")
if (@($inventoryErrors).Count -eq 0) {
    $lines.Add("No read-only inventory errors were recorded.")
}
else {
    $lines.Add("| Area | Error |")
    $lines.Add("|---|---|")
    foreach ($errorFile in $inventoryErrors | Sort-Object Name) {
        $errorRecord = Import-JsonIfExists $errorFile.FullName
        $errorMessage = if ($null -ne $errorRecord) { ([string]$errorRecord.error) -replace "\|", "\|" } else { "Could not parse error file." }
        $area = if ($null -ne $errorRecord -and $errorRecord.area) { $errorRecord.area } else { $errorFile.BaseName }
        $lines.Add(("| {0} | {1} |" -f $area, $errorMessage))
    }
}
$lines.Add("")

$lines.Add("## SharePoint Site Sharing")
$lines.Add("")
if (-not $sharePointSiteSharingRead) {
    $lines.Add("SharePoint tenant/site sharing posture was not collected in this inventory folder.")
}
else {
    $lines.Add(("Tenant sharing capability: **{0}**" -f $sharePointTenantSharing))
    $lines.Add(("Default sharing link type: **{0}**" -f $sharePointDefaultLinkType))
    $lines.Add("")
    $lines.Add("| Site | Template | Sharing capability | Conditional access | Non-owner sharing disabled |")
    $lines.Add("|---|---|---|---|---|")
    foreach ($site in $sharePointSites | Sort-Object Url) {
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f $site.Url, $site.Template, (Format-SharingCapability $site.SharingCapability), $site.ConditionalAccessPolicy, $site.DisableSharingForNonOwnersStatus))
    }
}
$lines.Add("")

$lines.Add("## User Authentication Method Summary")
$lines.Add("")
if (@($authMethods).Count -eq 0) {
    $lines.Add("Authentication methods were not read.")
}
else {
    $lines.Add("| User | Method count | Method types |")
    $lines.Add("|---|---:|---|")
    foreach ($method in $authMethods | Sort-Object userPrincipalName) {
        $types = ([string]$method.methodTypes) -replace "\|", "\|"
        $lines.Add(("| {0} | {1} | {2} |" -f $method.userPrincipalName, $method.methodCount, $types))
    }
}
$lines.Add("")

$lines.Add("## Recommended Next Decisions")
$lines.Add("")
$lines.Add("1. Decide whether to stay on Security Defaults for now or move to Business Premium / Entra P1 Conditional Access.")
$lines.Add('2. Decide the resting state for `agent-pnp-provisioning` and any other broad setup app.')
$lines.Add("3. Decide the guest invitation rule before adding a business partner.")
$lines.Add("4. Confirm the external sharing exception path before Stage 8 client workspace templates.")
$lines.Add("5. Record any accepted risks in the Decision Register before real partner/client onboarding.")
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8
Write-Host "Stage 7 summary written: $resolvedOutputPath" -ForegroundColor Green
