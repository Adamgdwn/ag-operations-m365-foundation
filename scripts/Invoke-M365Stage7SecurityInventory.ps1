param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e",
    [string]$OutputRoot = ".\inventory\stage-7-security-governance",
    [string]$SharePointAdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [switch]$IncludeSharePointAdmin,
    [switch]$SkipAuthReadyPrompt,
    [switch]$NoPause
)

# Stage 7 - read-only security/governance inventory.
# This script performs no tenant writes. Some reads require admin consent or
# premium licensing; those reads are skipped into *.error.json instead of failing
# the whole inventory.

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Export-Json {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $true)] $Data
    )

    $Data | ConvertTo-Json -Depth 30 | Out-File -FilePath $Path -Encoding utf8
}

function Get-ErrorBody {
    param($ErrorRecord)

    $body = $ErrorRecord.ErrorDetails.Message
    if ([string]::IsNullOrWhiteSpace($body) -and $null -ne $ErrorRecord.Exception.Response) {
        if ($ErrorRecord.Exception.Response.Content) {
            $body = $ErrorRecord.Exception.Response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        }
        elseif ($ErrorRecord.Exception.Response.GetResponseStream) {
            $responseStream = $ErrorRecord.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $body = $reader.ReadToEnd()
            $reader.Close()
        }
    }

    return $body
}

function Invoke-GraphCollection {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [string]$Uri,
        [Parameter(Mandatory = $true)] [string]$AccessToken
    )

    Write-Section $Name
    $headers = @{ Authorization = "Bearer $AccessToken" }
    $items = New-Object System.Collections.Generic.List[object]
    $next = $Uri

    try {
        while ($next) {
            $response = Invoke-RestMethod -Method Get -Uri $next -Headers $headers
            if ($null -ne $response.value) {
                foreach ($item in $response.value) {
                    $items.Add($item)
                }
                $next = $response.'@odata.nextLink'
            }
            else {
                $items.Add($response)
                $next = $null
            }
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.json") -Data $items
        Write-Host "Saved $Name.json ($($items.Count) item(s))" -ForegroundColor Green
        return $items
    }
    catch {
        $errorRecord = [pscustomobject]@{
            area = $Name
            uri = $Uri
            error = $_.Exception.Message
            body = Get-ErrorBody -ErrorRecord $_
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.error.json") -Data $errorRecord
        Write-Host "Skipped ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

function Invoke-GraphSingleton {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [string]$Uri,
        [Parameter(Mandatory = $true)] [string]$AccessToken
    )

    Write-Section $Name
    $headers = @{ Authorization = "Bearer $AccessToken" }

    try {
        $response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers
        Export-Json -Path (Join-Path $script:OutputDir "$Name.json") -Data $response
        Write-Host "Saved $Name.json" -ForegroundColor Green
        return $response
    }
    catch {
        $errorRecord = [pscustomobject]@{
            area = $Name
            uri = $Uri
            error = $_.Exception.Message
            body = Get-ErrorBody -ErrorRecord $_
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.error.json") -Data $errorRecord
        Write-Host "Skipped ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

function Invoke-DeviceCodeToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$Scope
    )

    $deviceCodeUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode"
    $tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

    $device = Invoke-RestMethod -Method Post -Uri $deviceCodeUri -ContentType "application/x-www-form-urlencoded" -Body @{
        client_id = $ClientId
        scope = $Scope
    }

    Write-Host ""
    Write-Host $device.message -ForegroundColor Yellow
    Write-Host ""

    $deadline = (Get-Date).AddSeconds([int]$device.expires_in)
    $interval = [Math]::Max(5, [int]$device.interval)
    $token = $null

    while ((Get-Date) -lt $deadline -and $null -eq $token) {
        Start-Sleep -Seconds $interval
        try {
            $token = Invoke-RestMethod -Method Post -Uri $tokenUri -ContentType "application/x-www-form-urlencoded" -Body @{
                grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                client_id = $ClientId
                device_code = $device.device_code
            }
        }
        catch {
            $body = Get-ErrorBody -ErrorRecord $_
            try {
                $details = $body | ConvertFrom-Json
            }
            catch {
                throw "Authentication polling failed and the response was not JSON: $body"
            }

            if ($details.error -eq "authorization_pending") {
                Write-Host "." -NoNewline
                continue
            }
            elseif ($details.error -eq "slow_down") {
                $interval += 5
                Write-Host "." -NoNewline
                continue
            }
            else {
                throw "Authentication failed: $($details.error_description)"
            }
        }
    }

    if ($null -eq $token) {
        throw "Authentication timed out before approval completed."
    }

    return $token
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$script:OutputDir = Join-Path $OutputRoot $timestamp
New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null

Write-Host "Microsoft 365 Stage 7 - Security/Governance Read-Only Inventory" -ForegroundColor Cyan
Write-Host "Output folder: $script:OutputDir"
Write-Host ""
Write-Host "This run performs read-only Graph calls. It does not change tenant policy, guests, sharing, app consent, or roles." -ForegroundColor Yellow

$scopes = @(
    "User.Read",
    "Organization.Read.All",
    "Directory.Read.All",
    "Group.Read.All",
    "Application.Read.All",
    "Policy.Read.All",
    "AuditLog.Read.All",
    "UserAuthenticationMethod.Read.All"
) -join " "

if (-not $SkipAuthReadyPrompt) {
    Write-Host ""
    Write-Host "Device-code auth can time out quickly if it sits unattended." -ForegroundColor Yellow
    Read-Host "Press Enter when you are ready to complete Microsoft sign-in for this read-only inventory" | Out-Null
    Write-Host ""
}

$token = Invoke-DeviceCodeToken -TenantId $TenantId -ClientId $ClientId -Scope $scopes

Write-Host ""
Write-Host "Authenticated. Running read-only Stage 7 inventory..." -ForegroundColor Green

Export-Json -Path (Join-Path $script:OutputDir "auth-context.json") -Data ([pscustomobject]@{
    tenantId = $TenantId
    clientId = $ClientId
    scopes = $scopes
    tokenType = $token.token_type
    expiresIn = $token.expires_in
    generatedAt = (Get-Date).ToString("o")
})

$base = "https://graph.microsoft.com/v1.0"

$organization = Invoke-GraphCollection -Name "organization" -Uri "$base/organization" -AccessToken $token.access_token
$skus = Invoke-GraphCollection -Name "subscribed-skus" -Uri "$base/subscribedSkus" -AccessToken $token.access_token
$users = Invoke-GraphCollection -Name "users" -Uri "$base/users?`$select=id,displayName,userPrincipalName,mail,userType,accountEnabled,createdDateTime,assignedLicenses" -AccessToken $token.access_token
$groups = Invoke-GraphCollection -Name "groups" -Uri "$base/groups?`$select=id,displayName,mail,mailEnabled,securityEnabled,groupTypes,visibility,createdDateTime" -AccessToken $token.access_token
$roles = Invoke-GraphCollection -Name "directory-roles" -Uri "$base/directoryRoles" -AccessToken $token.access_token
$applications = Invoke-GraphCollection -Name "app-registrations" -Uri "$base/applications?`$select=id,appId,displayName,signInAudience,createdDateTime,requiredResourceAccess" -AccessToken $token.access_token
$servicePrincipals = Invoke-GraphCollection -Name "enterprise-applications" -Uri "$base/servicePrincipals?`$select=id,appId,displayName,servicePrincipalType,accountEnabled,appOwnerOrganizationId,createdDateTime" -AccessToken $token.access_token
$oauth2Grants = Invoke-GraphCollection -Name "oauth2-permission-grants" -Uri "$base/oauth2PermissionGrants" -AccessToken $token.access_token

$authorizationPolicy = Invoke-GraphSingleton -Name "authorization-policy" -Uri "$base/policies/authorizationPolicy" -AccessToken $token.access_token
$securityDefaults = Invoke-GraphSingleton -Name "identity-security-defaults" -Uri "$base/policies/identitySecurityDefaultsEnforcementPolicy" -AccessToken $token.access_token
$conditionalAccess = Invoke-GraphCollection -Name "conditional-access-policies" -Uri "$base/identity/conditionalAccess/policies" -AccessToken $token.access_token
$authenticationMethods = Invoke-GraphSingleton -Name "authentication-methods-policy" -Uri "$base/policies/authenticationMethodsPolicy" -AccessToken $token.access_token
$adminConsentPolicy = Invoke-GraphSingleton -Name "admin-consent-request-policy" -Uri "$base/policies/adminConsentRequestPolicy" -AccessToken $token.access_token
$signIns = Invoke-GraphCollection -Name "recent-signins" -Uri "$base/auditLogs/signIns?`$top=50&`$orderby=createdDateTime desc" -AccessToken $token.access_token
$directoryAudits = Invoke-GraphCollection -Name "recent-directory-audits" -Uri "$base/auditLogs/directoryAudits?`$top=50&`$orderby=activityDateTime desc" -AccessToken $token.access_token

Write-Section "directory-role-members"
$roleMembers = New-Object System.Collections.Generic.List[object]
foreach ($role in $roles) {
    $members = Invoke-GraphCollection -Name "directory-role-$($role.id)-members" -Uri "$base/directoryRoles/$($role.id)/members" -AccessToken $token.access_token
    foreach ($member in $members) {
        $roleMembers.Add([pscustomobject]@{
            roleId = $role.id
            roleName = $role.displayName
            memberId = $member.id
            memberType = $member.'@odata.type'
            displayName = $member.displayName
            userPrincipalName = $member.userPrincipalName
        })
    }
}
Export-Json -Path (Join-Path $script:OutputDir "directory-role-members.json") -Data $roleMembers
Write-Host "Saved directory-role-members.json ($($roleMembers.Count) item(s))" -ForegroundColor Green

Write-Section "user-authentication-methods"
$authMethodRows = New-Object System.Collections.Generic.List[object]
foreach ($user in @($users | Where-Object { $_.accountEnabled -eq $true })) {
    try {
        $methods = Invoke-GraphCollection -Name "user-auth-methods-$($user.id)" -Uri "$base/users/$($user.id)/authentication/methods" -AccessToken $token.access_token
        $authMethodRows.Add([pscustomobject]@{
            userPrincipalName = $user.userPrincipalName
            displayName = $user.displayName
            methodCount = @($methods).Count
            methodTypes = (@($methods) | ForEach-Object { $_.'@odata.type' }) -join "; "
        })
    }
    catch {
        $authMethodRows.Add([pscustomobject]@{
            userPrincipalName = $user.userPrincipalName
            displayName = $user.displayName
            methodCount = $null
            methodTypes = ""
            error = $_.Exception.Message
        })
    }
}
Export-Json -Path (Join-Path $script:OutputDir "user-authentication-method-summary.json") -Data $authMethodRows
Write-Host "Saved user-authentication-method-summary.json ($($authMethodRows.Count) item(s))" -ForegroundColor Green

if ($IncludeSharePointAdmin) {
    Write-Section "sharepoint-admin"
    try {
        Import-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction Stop
        Write-Host "Connecting to SharePoint admin service for read-only sharing posture..." -ForegroundColor Yellow
        Connect-SPOService -Url $SharePointAdminUrl
        $tenant = Get-SPOTenant
        $sites = Get-SPOSite -Limit All | Select-Object Url, Title, Template, Owner, SharingCapability, DisableSharingForNonOwnersStatus, ConditionalAccessPolicy, LastContentModifiedDate, StorageUsageCurrent
        Export-Json -Path (Join-Path $script:OutputDir "sharepoint-tenant.json") -Data $tenant
        Export-Json -Path (Join-Path $script:OutputDir "sharepoint-sites.json") -Data $sites
        Write-Host "Saved SharePoint admin read-back." -ForegroundColor Green
    }
    catch {
        Export-Json -Path (Join-Path $script:OutputDir "sharepoint-admin.error.json") -Data ([pscustomobject]@{
            area = "sharepoint-admin"
            error = $_.Exception.Message
        })
        Write-Host "Skipped SharePoint admin read-back: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Section "summary"
$summary = [pscustomobject]@{
    generatedAt = (Get-Date).ToString("o")
    tenantId = $TenantId
    users = @($users).Count
    guests = @($users | Where-Object { $_.userType -eq "Guest" }).Count
    groups = @($groups).Count
    subscribedSkus = @($skus).Count
    directoryRoles = @($roles).Count
    directoryRoleMembers = @($roleMembers).Count
    appRegistrations = @($applications).Count
    enterpriseApplications = @($servicePrincipals).Count
    oauth2PermissionGrants = @($oauth2Grants).Count
    conditionalAccessPolicies = @($conditionalAccess).Count
    recentSignIns = @($signIns).Count
    recentDirectoryAudits = @($directoryAudits).Count
    securityDefaultsRead = ($null -ne $securityDefaults)
    authorizationPolicyRead = ($null -ne $authorizationPolicy)
    authenticationMethodsPolicyRead = ($null -ne $authenticationMethods)
    adminConsentPolicyRead = ($null -ne $adminConsentPolicy)
    sharePointAdminIncluded = [bool]$IncludeSharePointAdmin
}
Export-Json -Path (Join-Path $script:OutputDir "summary.json") -Data $summary
$summary | Format-List

Write-Host ""
Write-Host "Inventory complete. Output saved to:" -ForegroundColor Green
Write-Host (Resolve-Path $script:OutputDir)

$summarizer = Join-Path (Split-Path -Parent $PSCommandPath) "Summarize-M365Stage7SecurityInventory.ps1"
if (Test-Path -LiteralPath $summarizer) {
    Write-Host ""
    Write-Host "Running local Stage 7 summarizer..." -ForegroundColor Cyan
    & $summarizer -InventoryPath $script:OutputDir
}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
