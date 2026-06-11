param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$OutputRoot = ".\inventory\stage-1-current-state",
    [string]$ClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"
)

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
    $Data | ConvertTo-Json -Depth 20 | Out-File -FilePath $Path -Encoding utf8
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
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.error.json") -Data $errorRecord
        Write-Host "Skipped ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$script:OutputDir = Join-Path $OutputRoot $timestamp
New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null

Write-Host "Microsoft 365 Stage 1 Current-State Inventory (REST)" -ForegroundColor Cyan
Write-Host "Output folder: $script:OutputDir"
Write-Host ""
Write-Host "This uses the Microsoft Graph Command Line Tools public client and delegated read scopes." -ForegroundColor Yellow
Write-Host "Use admin@agoperations.ca unless you intentionally choose another admin account." -ForegroundColor Yellow

$scope = @(
    "User.Read",
    "Organization.Read.All",
    "Domain.Read.All",
    "Directory.Read.All",
    "Group.Read.All",
    "Sites.Read.All",
    "Files.Read.All",
    "Team.ReadBasic.All"
) -join " "

$deviceCodeUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode"
$tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

$device = Invoke-RestMethod -Method Post -Uri $deviceCodeUri -ContentType "application/x-www-form-urlencoded" -Body @{
    client_id = $ClientId
    scope = $scope
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
        $body = $_.ErrorDetails.Message
        if ([string]::IsNullOrWhiteSpace($body) -and $null -ne $_.Exception.Response) {
            if ($_.Exception.Response.Content) {
                $body = $_.Exception.Response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            }
            elseif ($_.Exception.Response.GetResponseStream) {
                $responseStream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($responseStream)
                $body = $reader.ReadToEnd()
                $reader.Close()
            }
        }

        try {
            $details = $body | ConvertFrom-Json
        }
        catch {
            Write-Host ""
            Write-Host "Authentication polling failed and the response was not JSON:" -ForegroundColor Red
            Write-Host $body -ForegroundColor Yellow
            Write-Host "Press Enter to close this window."
            Read-Host | Out-Null
            exit 1
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
            Write-Host ""
            Write-Host "Authentication failed: $($details.error_description)" -ForegroundColor Red
            Write-Host "Press Enter to close this window."
            Read-Host | Out-Null
            exit 1
        }
    }
}

if ($null -eq $token) {
    Write-Host ""
    Write-Host "Authentication timed out before approval completed." -ForegroundColor Red
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
    exit 1
}

Write-Host ""
Write-Host "Authenticated. Running read-only inventory..." -ForegroundColor Green

Export-Json -Path (Join-Path $script:OutputDir "auth-context.json") -Data ([pscustomobject]@{
    tenantId = $TenantId
    clientId = $ClientId
    scopes = $scope
    tokenType = $token.token_type
    expiresIn = $token.expires_in
})

$base = "https://graph.microsoft.com/v1.0"

$organization = Invoke-GraphCollection -Name "organization" -Uri "$base/organization" -AccessToken $token.access_token
$domains = Invoke-GraphCollection -Name "domains" -Uri "$base/domains" -AccessToken $token.access_token
$skus = Invoke-GraphCollection -Name "subscribed-skus" -Uri "$base/subscribedSkus" -AccessToken $token.access_token
$users = Invoke-GraphCollection -Name "users" -Uri "$base/users?`$select=id,displayName,userPrincipalName,mail,accountEnabled,userType,createdDateTime,assignedLicenses,assignedPlans" -AccessToken $token.access_token
$groups = Invoke-GraphCollection -Name "groups" -Uri "$base/groups?`$select=id,displayName,mail,mailEnabled,securityEnabled,groupTypes,visibility,createdDateTime" -AccessToken $token.access_token
$roles = Invoke-GraphCollection -Name "directory-roles" -Uri "$base/directoryRoles" -AccessToken $token.access_token
$sites = Invoke-GraphCollection -Name "sites" -Uri "$base/sites?search=*" -AccessToken $token.access_token
$applications = Invoke-GraphCollection -Name "app-registrations" -Uri "$base/applications?`$select=id,appId,displayName,signInAudience,createdDateTime,requiredResourceAccess" -AccessToken $token.access_token
$servicePrincipals = Invoke-GraphCollection -Name "enterprise-applications" -Uri "$base/servicePrincipals?`$select=id,appId,displayName,servicePrincipalType,accountEnabled,appOwnerOrganizationId" -AccessToken $token.access_token

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

Write-Section "summary"
$domainCount = [int]($domains | Measure-Object).Count
$userCount = [int]($users | Measure-Object).Count
$groupCount = [int]($groups | Measure-Object).Count
$skuCount = [int]($skus | Measure-Object).Count
$roleCount = [int]($roles | Measure-Object).Count
$roleMemberCount = [int]($roleMembers | Measure-Object).Count
$siteCount = [int]($sites | Measure-Object).Count
$applicationCount = [int]($applications | Measure-Object).Count
$servicePrincipalCount = [int]($servicePrincipals | Measure-Object).Count

$summary = [pscustomobject]@{
    generatedAt = (Get-Date).ToString("o")
    tenantId = $TenantId
    domains = $domainCount
    users = $userCount
    groups = $groupCount
    subscribedSkus = $skuCount
    directoryRoles = $roleCount
    directoryRoleMembers = $roleMemberCount
    sites = $siteCount
    appRegistrations = $applicationCount
    enterpriseApplications = $servicePrincipalCount
}
Export-Json -Path (Join-Path $script:OutputDir "summary.json") -Data $summary
$summary | Format-List

Write-Host ""
Write-Host "Inventory complete. Output saved to:" -ForegroundColor Green
Write-Host (Resolve-Path $script:OutputDir)
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
