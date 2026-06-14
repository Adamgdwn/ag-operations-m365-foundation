param(
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$FormsSchemaPath = ".\config\M365_FORMS_INTAKE_FEEDBACK_KIT.json",
    [string]$OutputPath = ".\inventory\stage-6-operating-state\STAGE_6_LOCAL_PREFLIGHT.md"
)

# Stage 6 - local-only preflight.
# Validates the local schema, scripts, generated guides, and module availability.
# It does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

function Resolve-Stage6Path {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Results,
        [string]$Check,
        [bool]$Passed,
        [string]$Detail
    )

    $Results.Add([pscustomobject]@{
        Check = $Check
        Passed = $Passed
        Detail = $Detail
    })
}

function Test-ScriptParse {
    param([string]$Path)

    $parseErrors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw -LiteralPath $Path), [ref]$parseErrors)
    return @($parseErrors)
}

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$resolvedSchemaPath = Resolve-Stage6Path -Path $SchemaPath
$resolvedFormsSchemaPath = Resolve-Stage6Path -Path $FormsSchemaPath
$resolvedOutputPath = Resolve-Stage6Path -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

if (Test-Path -LiteralPath $resolvedSchemaPath) {
    try {
        $schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Schema parses as JSON" -Passed $true -Detail $resolvedSchemaPath
    }
    catch {
        Add-Result -Results $results -Check "Schema parses as JSON" -Passed $false -Detail $_.Exception.Message
        $schema = $null
    }
}
else {
    Add-Result -Results $results -Check "Schema exists" -Passed $false -Detail $resolvedSchemaPath
    $schema = $null
}

if ($null -ne $schema) {
    Add-Result -Results $results -Check "Schema has four Stage 6 Lists" -Passed ($schema.lists.Count -eq 4) -Detail ("Found {0}" -f $schema.lists.Count)
    Add-Result -Results $results -Check "Schema has Planner buckets" -Passed ($schema.planner.buckets.Count -gt 0) -Detail (($schema.planner.buckets | ForEach-Object { [string]$_ }) -join ", ")
    Add-Result -Results $results -Check "Schema has Teams channels" -Passed ($schema.teams.channels.Count -gt 0) -Detail (($schema.teams.channels | ForEach-Object { [string]$_.name }) -join ", ")

    $listTitles = @($schema.lists | ForEach-Object { [string]$_.title })
    $duplicateListTitles = @($listTitles | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    Add-Result -Results $results -Check "List titles are unique" -Passed ($duplicateListTitles.Count -eq 0) -Detail ($(if ($duplicateListTitles.Count -eq 0) { "No duplicates" } else { $duplicateListTitles -join ", " }))

    $listsMissingTitle = @($schema.lists | Where-Object { [string]::IsNullOrWhiteSpace($_.title) })
    Add-Result -Results $results -Check "Every List has a title" -Passed ($listsMissingTitle.Count -eq 0) -Detail ("Missing: {0}" -f $listsMissingTitle.Count)
}

if (Test-Path -LiteralPath $resolvedFormsSchemaPath) {
    try {
        $formsSchema = Get-Content -LiteralPath $resolvedFormsSchemaPath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Forms kit schema parses as JSON" -Passed $true -Detail $resolvedFormsSchemaPath
    }
    catch {
        Add-Result -Results $results -Check "Forms kit schema parses as JSON" -Passed $false -Detail $_.Exception.Message
        $formsSchema = $null
    }
}
else {
    Add-Result -Results $results -Check "Forms kit schema exists" -Passed $false -Detail $resolvedFormsSchemaPath
    $formsSchema = $null
}

if ($null -ne $formsSchema) {
    Add-Result -Results $results -Check "Forms kit has form definitions" -Passed ($formsSchema.forms.Count -gt 0) -Detail ("Found {0}" -f $formsSchema.forms.Count)
    Add-Result -Results $results -Check "Forms kit has flow pattern" -Passed ($formsSchema.flowPattern.Count -gt 0) -Detail ("Found {0} steps" -f $formsSchema.flowPattern.Count)
}

$requiredScripts = @(
    "scripts\Invoke-M365Stage6ProvisionLists.ps1",
    "scripts\Invoke-M365Stage6VerifyLists.ps1",
    "scripts\Start-M365Stage6ListsProvisioningInteractive.ps1",
    "scripts\Show-M365Stage6PnPConsentReviewChecklist.ps1",
    "scripts\Clear-M365Stage6PnPPersistedLogin.ps1",
    "scripts\Test-M365Stage6PnPPermissions.ps1",
    "scripts\Test-M365Stage6PnPTokenClaims.ps1",
    "scripts\Invoke-M365Stage6ListOperator.ps1",
    "scripts\Start-M365Stage6ListOperatorInteractive.ps1",
    "scripts\Invoke-M365Stage6VerifyPlannerTeams.ps1",
    "scripts\Invoke-M365Stage6ProvisionPlannerTeams.ps1",
    "scripts\Invoke-M365Stage6PlannerTeamsOperator.ps1",
    "scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1",
    "scripts\New-M365Stage6ManualListBuildGuide.ps1",
    "scripts\New-M365Stage6PlannerTeamsBuildGuide.ps1",
    "scripts\New-M365FormsIntakeFeedbackKit.ps1",
    "scripts\New-M365Stage6FirstRunPacket.ps1",
    "scripts\New-M365Stage6OnboardingReadinessPacket.ps1",
    "scripts\Update-M365Stage6LocalArtifacts.ps1",
    "scripts\Test-M365Stage6LocalPreflight.ps1"
)

foreach ($relativeScript in $requiredScripts) {
    $scriptPath = Join-Path $workspaceRoot $relativeScript
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Add-Result -Results $results -Check ("Script exists: {0}" -f $relativeScript) -Passed $false -Detail $scriptPath
        continue
    }

    $errors = Test-ScriptParse -Path $scriptPath
    Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed ($errors.Count -eq 0) -Detail ($(if ($errors.Count -eq 0) { "parse-ok" } else { ($errors | ForEach-Object { $_.Message }) -join "; " }))
}

$requiredOutputs = @(
    "inventory\stage-6-operating-state\STAGE_6_MANUAL_LIST_BUILD_GUIDE.md",
    "inventory\stage-6-operating-state\STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md",
    "inventory\stage-6-operating-state\forms-intake-feedback\M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md",
    "inventory\stage-6-operating-state\forms-intake-feedback\forms-question-map.csv",
    "inventory\stage-6-operating-state\forms-intake-feedback\forms-flow-build-checklist.csv",
    "inventory\stage-6-operating-state\first-run-packet\STAGE_6_FIRST_AGENT_LOOP_RUNBOOK.md",
    "inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md",
    "inventory\stage-6-operating-state\onboarding-readiness\partner-onboarding-checklist.csv",
    "inventory\stage-6-operating-state\onboarding-readiness\client-readiness-discovery-checklist.csv",
    "inventory\stage-6-operating-state\onboarding-readiness\operating-readiness-scorecard.csv"
)

foreach ($relativeOutput in $requiredOutputs) {
    $outputFile = Join-Path $workspaceRoot $relativeOutput
    Add-Result -Results $results -Check ("Generated guide exists: {0}" -f $relativeOutput) -Passed (Test-Path -LiteralPath $outputFile) -Detail $outputFile
}

$pwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
Add-Result -Results $results -Check "PowerShell 7 host available" -Passed ($null -ne $pwsh) -Detail ($(if ($null -ne $pwsh) { $pwsh.Source } else { "pwsh.exe not found" }))

$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "PnP.PowerShell module available" -Passed ($null -ne $pnp) -Detail ($(if ($null -ne $pnp) { ("{0} {1}" -f $pnp.Name, $pnp.Version) } else { "PnP.PowerShell not found" }))

$graphAuth = Get-Module -ListAvailable -Name Microsoft.Graph.Authentication | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "Microsoft.Graph.Authentication module available" -Passed ($null -ne $graphAuth) -Detail ($(if ($null -ne $graphAuth) { ("{0} {1}" -f $graphAuth.Name, $graphAuth.Version) } else { "Microsoft.Graph.Authentication not found" }))

$graphTeams = Get-Module -ListAvailable -Name Microsoft.Graph.Teams | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "Microsoft.Graph.Teams module available" -Passed ($null -ne $graphTeams) -Detail ($(if ($null -ne $graphTeams) { ("{0} {1}" -f $graphTeams.Name, $graphTeams.Version) } else { "Microsoft.Graph.Teams not found" }))

$graphPlanner = Get-Module -ListAvailable -Name Microsoft.Graph.Planner | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "Microsoft.Graph.Planner module available" -Passed ($null -ne $graphPlanner) -Detail ($(if ($null -ne $graphPlanner) { ("{0} {1}" -f $graphPlanner.Name, $graphPlanner.Version) } else { "Microsoft.Graph.Planner not found" }))

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 6 Local Preflight")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add("Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add(("Result: {0}" -f ($(if ($failed.Count -eq 0) { "PASS" } else { "FAIL" }))))
$lines.Add("")
$lines.Add("| Status | Check | Detail |")
$lines.Add("|---|---|---|")

foreach ($result in $results) {
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $detail = ([string]$result.Detail) -replace "\|", "\|"
    $lines.Add(("| {0} | {1} | {2} |" -f $status, $result.Check, $detail))
}

$lines.Add("")
$lines.Add("Next safe actions:")
$lines.Add("")
$lines.Add('1. Prefer `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action Verify` for routine List read-back.')
$lines.Add('2. If PnP reuses the wrong account, run `.\scripts\Start-M365Stage6ListOperatorInteractive.ps1 -Action RepairLogin`, then rerun with `-UseDeviceLogin`.')
$lines.Add('3. Prefer `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action Verify` for Planner/Teams read-back.')
$lines.Add('4. Use `.\scripts\Start-M365Stage6PlannerTeamsOperatorInteractive.ps1 -Action ProvisionAndVerify` only when ready for the live Planner/Teams gate.')
$lines.Add('5. Use `inventory\stage-6-operating-state\onboarding-readiness\STAGE_6_ONBOARDING_READINESS_RUNBOOK.md` before adding a partner or shaping first client onboarding.')
$lines.Add('6. Use `inventory\stage-6-operating-state\forms-intake-feedback\M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md` before creating Forms or Power Automate flows.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 6 local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 6 local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
