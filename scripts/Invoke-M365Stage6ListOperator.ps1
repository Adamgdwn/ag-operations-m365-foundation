param(
    [ValidateSet("Verify", "ProvisionAndVerify", "RepairLogin", "UpdateLocal")]
    [string]$Action = "Verify",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl,
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [switch]$UseDeviceLogin,
    [switch]$ForceFreshLogin
)

# Stage 6 - efficient Lists operator.
# Optimizes the normal flow while preserving safety:
# - local artifacts can be regenerated without tenant access;
# - read-only verification runs before/after writes;
# - live writes still require the provisioning script's typed confirmation;
# - every PnP operation asserts the expected delegated user.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot

function Invoke-Stage6Script {
    param(
        [string]$RelativePath,
        [hashtable]$Parameters
    )

    $path = Join-Path $workspaceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required script not found: $path"
    }

    & $path @Parameters
}

function New-BaseParameters {
    $params = @{
        ClientId = $ClientId
        SchemaPath = $SchemaPath
        Tenant = $Tenant
        ExpectedUpn = $ExpectedUpn
        NoPause = $true
    }

    if (-not [string]::IsNullOrWhiteSpace($RootUrl)) {
        $params.RootUrl = $RootUrl
    }
    if ($UseDeviceLogin) {
        $params.UseDeviceLogin = $true
    }
    if ($ForceFreshLogin) {
        $params.ForceFreshLogin = $true
    }

    return $params
}

Write-Host "Microsoft 365 Stage 6 - Lists operator" -ForegroundColor Cyan
Write-Host "Action:        $Action" -ForegroundColor Gray
Write-Host "Expected user: $ExpectedUpn" -ForegroundColor Gray
if ($UseDeviceLogin) {
    Write-Host "Auth:          device login enabled" -ForegroundColor Gray
}
elseif ($ForceFreshLogin) {
    Write-Host "Auth:          force fresh interactive login enabled" -ForegroundColor Gray
}
else {
    Write-Host "Auth:          use persisted/interactive PnP login, with expected-user guard" -ForegroundColor Gray
}
Write-Host ""

switch ($Action) {
    "UpdateLocal" {
        Invoke-Stage6Script -RelativePath "scripts\Update-M365Stage6LocalArtifacts.ps1" -Parameters @{ SchemaPath = $SchemaPath }
    }

    "RepairLogin" {
        Invoke-Stage6Script -RelativePath "scripts\Clear-M365Stage6PnPPersistedLogin.ps1" -Parameters @{
            ClientId = $ClientId
            RootUrl = $(if ([string]::IsNullOrWhiteSpace($RootUrl)) { "https://agoperationsltd.sharepoint.com" } else { $RootUrl })
        }
        Write-Host ""
        Write-Host "Persisted login cleared. Re-run this operator with -UseDeviceLogin and choose $ExpectedUpn." -ForegroundColor Yellow
    }

    "Verify" {
        $params = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyLists.ps1" -Parameters $params
    }

    "ProvisionAndVerify" {
        Write-Host "Step 1/3: read-only site/list preflight." -ForegroundColor Cyan
        $verifyParams = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyLists.ps1" -Parameters $verifyParams

        Write-Host ""
        Write-Host "Step 2/3: live Lists provisioning." -ForegroundColor Cyan
        Write-Host "The provisioning step still requires typed confirmation before tenant writes." -ForegroundColor Yellow
        $provisionParams = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6ProvisionLists.ps1" -Parameters $provisionParams

        Write-Host ""
        Write-Host "Step 3/3: read-only verification after provisioning." -ForegroundColor Cyan
        $postVerifyParams = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyLists.ps1" -Parameters $postVerifyParams
    }
}

Write-Host ""
Write-Host "Stage 6 Lists operator finished." -ForegroundColor Green
