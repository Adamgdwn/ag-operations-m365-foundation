param(
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json"
)

# Stage 6 - regenerate all local-only artifacts.
# This script does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath

$steps = @(
    @{
        Name = "Manual Lists build guide"
        Path = Join-Path $scriptRoot "New-M365Stage6ManualListBuildGuide.ps1"
        Params = @{ SchemaPath = $SchemaPath }
    },
    @{
        Name = "Planner/Teams build guide"
        Path = Join-Path $scriptRoot "New-M365Stage6PlannerTeamsBuildGuide.ps1"
        Params = @{ SchemaPath = $SchemaPath }
    },
    @{
        Name = "Forms intake/feedback kit"
        Path = Join-Path $scriptRoot "New-M365FormsIntakeFeedbackKit.ps1"
        Params = @{}
    },
    @{
        Name = "First-run packet"
        Path = Join-Path $scriptRoot "New-M365Stage6FirstRunPacket.ps1"
        Params = @{}
    },
    @{
        Name = "Onboarding readiness packet"
        Path = Join-Path $scriptRoot "New-M365Stage6OnboardingReadinessPacket.ps1"
        Params = @{}
    },
    @{
        Name = "Local preflight"
        Path = Join-Path $scriptRoot "Test-M365Stage6LocalPreflight.ps1"
        Params = @{ SchemaPath = $SchemaPath }
    }
)

Write-Host "Microsoft 365 Stage 6 - update local artifacts" -ForegroundColor Cyan
Write-Host "No Microsoft 365 connection or tenant writes will be attempted." -ForegroundColor Yellow
Write-Host ""

foreach ($step in $steps) {
    if (-not (Test-Path -LiteralPath $step.Path)) {
        throw "Missing required script for '$($step.Name)': $($step.Path)"
    }

    Write-Host ("== {0} ==" -f $step.Name) -ForegroundColor Cyan
    $params = $step.Params
    & $step.Path @params
    Write-Host ""
}

Write-Host "Stage 6 local artifacts are up to date." -ForegroundColor Green
