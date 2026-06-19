param(
    [string]$OutputPath = ".\inventory\workspace-usability-chunk-7\WORKSPACE_CHUNK_7_CLOSEOUT_PREFLIGHT.md"
)

# Workspace Chunk 7 - local-only closeout preflight.
# This script does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

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

function Get-Text {
    param([string]$RelativePath)

    $path = Join-Path $workspaceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        return $null
    }

    return Get-Content -Raw -LiteralPath $path
}

$resolvedOutputPath = Resolve-WorkspacePath -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

$requiredDocs = @(
    "docs\START_HERE.md",
    "docs\WORKSPACE_EXECUTION_PLAN.md",
    "docs\CARD_PLAN_INDEX.md",
    "docs\WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md",
    "docs\COCKPIT_USABILITY_INVENTORY.md",
    "docs\COCKPIT_CARD_GAP_LIST.md",
    "docs\AGENTIC_M365_READINESS.md",
    "docs\AGENTIC_M365_CHUNK_6_DECISION_LIST.md",
    "docs\WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md"
)

foreach ($relativeFile in $requiredDocs) {
    $path = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("Required doc exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $path) -Detail $path
}

$cardPlans = @(
    "docs\CARD_PLAN_WORKSPACE_HOME.md",
    "docs\CARD_PLAN_CRM_RELATIONSHIPS.md",
    "docs\CARD_PLAN_DELIVERY_PROJECTS.md",
    "docs\CARD_PLAN_DECISIONS_GOVERNANCE.md",
    "docs\CARD_PLAN_TASKS_ACTIONS.md",
    "docs\CARD_PLAN_KNOWLEDGE_RECORDS.md",
    "docs\CARD_PLAN_SUPPORT_INTAKE.md",
    "docs\CARD_PLAN_FINANCE_CLOSEOUT.md",
    "docs\CARD_PLAN_AGENT_CONTROL_PLANE.md"
)

foreach ($relativeFile in $cardPlans) {
    $path = Join-Path $workspaceRoot $relativeFile
    $exists = Test-Path -LiteralPath $path
    Add-Result -Results $results -Check ("Card plan exists: {0}" -f $relativeFile) -Passed $exists -Detail $path

    if ($exists) {
        $text = Get-Content -Raw -LiteralPath $path
        Add-Result -Results $results -Check ("Card plan has acceptance test: {0}" -f $relativeFile) -Passed ($text -match "(?m)^## Acceptance Test$") -Detail "## Acceptance Test"
        Add-Result -Results $results -Check ("Card plan has stop conditions: {0}" -f $relativeFile) -Passed ($text -match "(?m)^## Stop Conditions$") -Detail "## Stop Conditions"
    }
}

$accessModel = Get-Text -RelativePath "docs\WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md"
if ($null -ne $accessModel) {
    Add-Result -Results $results -Check "Access model has onboarding acceptance test" -Passed ($accessModel -match "(?m)^## Acceptance Test$") -Detail "docs\WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md"
    Add-Result -Results $results -Check "Access model has stop conditions" -Passed ($accessModel -match "(?m)^## Stop Conditions$") -Detail "docs\WORKSPACE_ACCESS_AND_ONBOARDING_MODEL.md"
}

$closeout = Get-Text -RelativePath "docs\WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md"
if ($null -ne $closeout) {
    $requiredSections = @(
        "## Acceptance Verdict",
        "## Evidence Base",
        "## First-Day Scenario",
        "## Walkthrough Results",
        "## Remaining Gaps",
        "## Stop Conditions Carried Forward",
        "## Sanity Checks",
        "## Closeout Note"
    )

    foreach ($section in $requiredSections) {
        Add-Result -Results $results -Check ("Closeout section exists: {0}" -f $section) -Passed ($closeout -match [regex]::Escape($section)) -Detail "docs\WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md"
    }

    $operatingCards = @(
        "Workspace Home",
        "CRM / Relationships",
        "Delivery / Projects",
        "Decisions / Governance",
        "Tasks / Actions",
        "Knowledge / Records",
        "Support / Intake",
        "Finance / Closeout",
        "Agent Control Plane",
        "Access / Onboarding"
    )

    foreach ($card in $operatingCards) {
        Add-Result -Results $results -Check ("Closeout covers card: {0}" -f $card) -Passed ($closeout -match [regex]::Escape($card)) -Detail "Walkthrough Results"
    }
}

$readbackPath = Join-Path $workspaceRoot "inventory\stage-8d-functional-workflow-walkthrough\stage-8d-workflow-proof-readback-20260617-121052.csv"
if (Test-Path -LiteralPath $readbackPath) {
    $readbackRows = @(Import-Csv -LiteralPath $readbackPath)
    $passingRows = @($readbackRows | Where-Object { $_.Outcome -eq "Pass" })
    Add-Result -Results $results -Check "Stage 8D read-back has seven passing rows" -Passed ($passingRows.Count -ge 7) -Detail ("Passing rows: {0}" -f $passingRows.Count)
}
else {
    Add-Result -Results $results -Check "Stage 8D read-back exists" -Passed $false -Detail $readbackPath
}

$activeRoutingDocs = @(
    "docs\START_HERE.md",
    "docs\WORKSPACE_EXECUTION_PLAN.md",
    "docs\CARD_PLAN_INDEX.md",
    "docs\COCKPIT_CARD_GAP_LIST.md",
    "START_HERE_TOKEN_FRIENDLY.md",
    "00_INDEX.md",
    "M365_FOUNDATION_ROADMAP.md",
    "SESSION_TURNOVER_2026-06-19.md"
)

$stalePatterns = @(
    "Chunks 1-6 are complete",
    "workspace usability Chunks 1-6",
    "next workspace chunk is Chunk 7",
    "Next workspace chunk is Chunk 7",
    "Next chunk: Chunk 7",
    "Start Chunk 7",
    "Browser/live-user acceptance evidence remains for Chunk 7",
    "Browser/live-user walkthrough evidence remains for Chunk 7"
)

foreach ($relativeFile in $activeRoutingDocs) {
    $text = Get-Text -RelativePath $relativeFile
    if ($null -eq $text) {
        Add-Result -Results $results -Check ("Routing doc exists for stale scan: {0}" -f $relativeFile) -Passed $false -Detail "missing"
        continue
    }

    for ($i = 0; $i -lt $stalePatterns.Count; $i++) {
        $pattern = $stalePatterns[$i]
        Add-Result -Results $results -Check ("No stale routing text in {0}: stale pattern {1}" -f $relativeFile, ($i + 1)) -Passed (-not $text.Contains($pattern)) -Detail "stale scan"
    }
}

$scriptPath = Join-Path $workspaceRoot "scripts\Test-WorkspaceChunk7Closeout.ps1"
if (Test-Path -LiteralPath $scriptPath) {
    $errors = Test-ScriptParse -Path $scriptPath
    Add-Result -Results $results -Check "Chunk 7 closeout script parses" -Passed ($errors.Count -eq 0) -Detail ($(if ($errors.Count -eq 0) { "parse-ok" } else { ($errors | ForEach-Object { $_.Message }) -join "; " }))
}
else {
    Add-Result -Results $results -Check "Chunk 7 closeout script exists" -Passed $false -Detail $scriptPath
}

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Workspace Chunk 7 Closeout Preflight")
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
$lines.Add("1. Use `docs\START_HERE.md` for workspace handoff.")
$lines.Add("2. Use `docs\WORKSPACE_CHUNK_7_FINAL_USABILITY_WALKTHROUGH.md` as the usability closeout evidence.")
$lines.Add("3. Continue only with a named card-specific chunk or controlled governance/read-back task.")
$lines.Add("4. Keep tenant writes blocked unless Adam defines the approval phrase, scope, evidence, and rollback path.")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Workspace Chunk 7 closeout preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Workspace Chunk 7 closeout preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
