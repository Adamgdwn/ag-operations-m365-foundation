param(
    [ValidateSet("Verify", "ProvisionAndVerify", "UpdateLocal")]
    [string]$Action = "Verify",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$TenantDomain = "AGOperationsLtd.onmicrosoft.com",
    [string]$RootUrl,
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$GroupDisplayName = "Guided AI Labs",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [switch]$UseDeviceCode,
    [switch]$SkipAuthReadyPrompt,
    [switch]$SkipWebTabs
)

# Stage 6 - efficient Planner/Teams operator.
# Keeps the same rhythm as the Lists operator:
# read-only verify -> typed-confirm live provisioning -> read-only verify.

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
        TenantId = $TenantId
        ExpectedUpn = $ExpectedUpn
        SchemaPath = $SchemaPath
        GroupDisplayName = $GroupDisplayName
        NoPause = $true
    }

    if (-not [string]::IsNullOrWhiteSpace($RootUrl)) {
        $params.RootUrl = $RootUrl
    }
    if ($UseDeviceCode) {
        $params.UseDeviceCode = $true
    }

    return $params
}

Write-Host "Microsoft 365 Stage 6 - Planner/Teams operator" -ForegroundColor Cyan
Write-Host "Action:        $Action" -ForegroundColor Gray
Write-Host "Expected user: $ExpectedUpn" -ForegroundColor Gray
Write-Host "Target group:  $GroupDisplayName" -ForegroundColor Gray
if ($UseDeviceCode) {
    Write-Host "Auth:          device code enabled" -ForegroundColor Gray
}
else {
    Write-Host "Auth:          Graph interactive/persisted token, with expected-user guard" -ForegroundColor Gray
    Write-Host "Hint:          use -UseDeviceCode if WAM/browser auth is awkward in this shell" -ForegroundColor Gray
}
Write-Host ""

if ($UseDeviceCode -and -not $SkipAuthReadyPrompt -and $Action -ne "UpdateLocal") {
    Write-Host "Device-code auth can time out quickly if it sits unattended." -ForegroundColor Yellow
    Read-Host "Press Enter when you are ready to complete Microsoft sign-in for this run" | Out-Null
    Write-Host ""
}

switch ($Action) {
    "UpdateLocal" {
        Invoke-Stage6Script -RelativePath "scripts\Update-M365Stage6LocalArtifacts.ps1" -Parameters @{ SchemaPath = $SchemaPath }
    }

    "Verify" {
        $params = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1" -Parameters $params
    }

    "ProvisionAndVerify" {
        Write-Host "Step 1/3: read-only Planner/Teams preflight." -ForegroundColor Cyan
        $verifyParams = New-BaseParameters
        $verifyParams.PreserveGraphConnection = $true
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1" -Parameters $verifyParams

        Write-Host ""
        Write-Host "Step 2/3: live Planner/Teams provisioning." -ForegroundColor Cyan
        Write-Host "The provisioning script requires typed confirmation before tenant writes." -ForegroundColor Yellow
        $provisionParams = New-BaseParameters
        $provisionParams.TenantDomain = $TenantDomain
        $provisionParams.PreserveGraphConnection = $true
        if ($SkipWebTabs) {
            $provisionParams.SkipWebTabs = $true
        }
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6ProvisionPlannerTeams.ps1" -Parameters $provisionParams

        Write-Host ""
        Write-Host "Step 3/3: read-only verification after provisioning." -ForegroundColor Cyan
        $postVerifyParams = New-BaseParameters
        Invoke-Stage6Script -RelativePath "scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1" -Parameters $postVerifyParams
    }
}

Write-Host ""
Write-Host "Stage 6 Planner/Teams operator finished." -ForegroundColor Green
