param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$OutputRoot = ".\inventory\stage-1-current-state"
)

$ErrorActionPreference = "Continue"

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
    $Data | ConvertTo-Json -Depth 12 | Out-File -FilePath $Path -Encoding utf8
}

function Try-Inventory {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [scriptblock]$Command
    )
    Write-Section $Name
    try {
        $result = & $Command
        Export-Json -Path (Join-Path $script:OutputDir "$Name.json") -Data $result
        Write-Host "Saved $Name.json" -ForegroundColor Green
        return $result
    }
    catch {
        $errorRecord = [pscustomobject]@{
            area = $Name
            error = $_.Exception.Message
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.error.json") -Data $errorRecord
        Write-Host "Skipped ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$script:OutputDir = Join-Path $OutputRoot $timestamp
New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null

Write-Host "Microsoft 365 Stage 1 Current-State Inventory" -ForegroundColor Cyan
Write-Host "Output folder: $script:OutputDir"
Write-Host ""
Write-Host "A device-code sign-in will appear below. Use admin@agoperations.ca unless you intentionally choose another admin account." -ForegroundColor Yellow

Import-Module Microsoft.Graph.Authentication

$scopes = @(
    "User.Read",
    "Organization.Read.All",
    "Domain.Read.All",
    "Directory.Read.All",
    "Group.Read.All",
    "Sites.Read.All",
    "Files.Read.All",
    "Team.ReadBasic.All"
)

try {
    Connect-MgGraph -TenantId $TenantId -Scopes $scopes -UseDeviceCode -ContextScope Process -NoWelcome
}
catch {
    Write-Host ""
    Write-Host "Graph sign-in failed before inventory could run:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
    exit 1
}

$context = Get-MgContext
Export-Json -Path (Join-Path $script:OutputDir "graph-context.json") -Data ([pscustomobject]@{
    account = $context.Account
    tenantId = $context.TenantId
    clientId = $context.ClientId
    scopes = $context.Scopes
})

Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Sites
Import-Module Microsoft.Graph.Applications

$org = Try-Inventory -Name "organization" -Command {
    Get-MgOrganization | Select-Object Id,DisplayName,VerifiedDomains,AssignedPlans,ProvisionedPlans
}

$domains = Try-Inventory -Name "domains" -Command {
    Get-MgDomain -All | Select-Object Id,AuthenticationType,AvailabilityStatus,IsAdminManaged,IsDefault,IsInitial,IsRoot,IsVerified,SupportedServices
}

$skus = Try-Inventory -Name "subscribed-skus" -Command {
    Get-MgSubscribedSku -All | Select-Object SkuId,SkuPartNumber,ConsumedUnits,PrepaidUnits,AppliesTo,CapabilityStatus
}

$users = Try-Inventory -Name "users" -Command {
    Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,Mail,AccountEnabled,UserType,CreatedDateTime,AssignedLicenses,AssignedPlans |
        Select-Object Id,DisplayName,UserPrincipalName,Mail,AccountEnabled,UserType,CreatedDateTime,AssignedLicenses,AssignedPlans
}

$groups = Try-Inventory -Name "groups" -Command {
    Get-MgGroup -All -Property Id,DisplayName,Mail,MailEnabled,SecurityEnabled,GroupTypes,Visibility,CreatedDateTime |
        Select-Object Id,DisplayName,Mail,MailEnabled,SecurityEnabled,GroupTypes,Visibility,CreatedDateTime
}

$roles = Try-Inventory -Name "directory-roles" -Command {
    Get-MgDirectoryRole -All | Select-Object Id,DisplayName,Description,RoleTemplateId
}

if ($roles) {
    Write-Section "directory-role-members"
    $roleMembers = foreach ($role in $roles) {
        try {
            Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All | ForEach-Object {
                [pscustomobject]@{
                    roleId = $role.Id
                    roleName = $role.DisplayName
                    memberId = $_.Id
                    memberType = $_.AdditionalProperties["@odata.type"]
                    displayName = $_.AdditionalProperties["displayName"]
                    userPrincipalName = $_.AdditionalProperties["userPrincipalName"]
                }
            }
        }
        catch {
            [pscustomobject]@{
                roleId = $role.Id
                roleName = $role.DisplayName
                error = $_.Exception.Message
            }
        }
    }
    Export-Json -Path (Join-Path $script:OutputDir "directory-role-members.json") -Data $roleMembers
    Write-Host "Saved directory-role-members.json" -ForegroundColor Green
}

$sites = Try-Inventory -Name "sites" -Command {
    Get-MgSite -All -Property Id,Name,DisplayName,WebUrl,CreatedDateTime,LastModifiedDateTime |
        Select-Object Id,Name,DisplayName,WebUrl,CreatedDateTime,LastModifiedDateTime
}

$applications = Try-Inventory -Name "app-registrations" -Command {
    Get-MgApplication -All -Property Id,AppId,DisplayName,SignInAudience,CreatedDateTime,RequiredResourceAccess,Web,PublicClient,Spa |
        Select-Object Id,AppId,DisplayName,SignInAudience,CreatedDateTime,RequiredResourceAccess,Web,PublicClient,Spa
}

$servicePrincipals = Try-Inventory -Name "enterprise-applications" -Command {
    Get-MgServicePrincipal -All -Property Id,AppId,DisplayName,ServicePrincipalType,AccountEnabled,AppOwnerOrganizationId |
        Select-Object Id,AppId,DisplayName,ServicePrincipalType,AccountEnabled,AppOwnerOrganizationId
}

Write-Section "summary"
$summary = [pscustomobject]@{
    generatedAt = (Get-Date).ToString("o")
    tenantId = $TenantId
    account = $context.Account
    domains = @($domains).Count
    users = @($users).Count
    groups = @($groups).Count
    subscribedSkus = @($skus).Count
    directoryRoles = @($roles).Count
    sites = @($sites).Count
    appRegistrations = @($applications).Count
    enterpriseApplications = @($servicePrincipals).Count
}
Export-Json -Path (Join-Path $script:OutputDir "summary.json") -Data $summary
$summary | Format-List

Write-Host ""
Write-Host "Inventory complete. Output saved to:" -ForegroundColor Green
Write-Host (Resolve-Path $script:OutputDir)
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
