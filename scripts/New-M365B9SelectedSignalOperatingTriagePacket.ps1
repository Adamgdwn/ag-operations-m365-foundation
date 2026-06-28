param(
    [string]$ConfigPath = "",
    [switch]$NoPause
)

# B9 local-only packet generator for selected-signal operating triage.
# This script does not connect to Microsoft 365, read a live tenant, write CRM
# records, write Agent Action Log rows, update flows, send HTTP requests, or
# touch secrets. It turns the B9 operating routine into queue/review artifacts.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B9_SELECTED_SIGNAL_OPERATING_TRIAGE.json"
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "B9 config not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$outputRoot = Join-Path $workspaceRoot $config.evidenceTargets.localPacketDirectory
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonPath = Join-Path $outputRoot ("b9-selected-signal-operating-triage-packet-{0}.json" -f $stamp)
$mdPath = Join-Path $outputRoot ("b9-selected-signal-operating-triage-packet-{0}.md" -f $stamp)
$queueCsvPath = Join-Path $outputRoot ("b9-selected-signal-queue-{0}.csv" -f $stamp)
$reviewCsvPath = Join-Path $outputRoot ("b9-operating-review-{0}.csv" -f $stamp)

function Resolve-B9Path {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

function Add-B9Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Text = ""
    )
    $Lines.Add($Text)
}

function Get-B9Text {
    param([object]$Value)

    if ($null -eq $Value) { return "" }
    if ($Value -is [array]) {
        return (@($Value | ForEach-Object { Get-B9Text -Value $_ }) -join "; ")
    }
    $text = [string]$Value
    $text = $text -replace [char]0x2014, " - "
    $text = $text -replace [char]0x2013, " - "
    $mojibakeEmDash = ([string][char]0x00E2) + ([string][char]0x20AC) + ([string][char]0x201D)
    $mojibakeEnDash = ([string][char]0x00E2) + ([string][char]0x20AC) + ([string][char]0x201C)
    $text = $text -replace ([regex]::Escape($mojibakeEmDash)), " - "
    $text = $text -replace ([regex]::Escape($mojibakeEnDash)), " - "
    $text = $text -replace "\s+", " "
    return ($text -replace "[^\x09\x0A\x0D\x20-\x7E]", "").Trim()
}

function Import-B9SeedEvidence {
    param([object]$Seed)

    $jsonRelative = [string]$Seed.triagePacketJson
    $mdRelative = [string]$Seed.triagePacketMarkdown
    $jsonAbsolute = Resolve-B9Path -Path $jsonRelative
    $mdAbsolute = Resolve-B9Path -Path $mdRelative
    $exists = (Test-Path -LiteralPath $jsonAbsolute)
    $parseStatus = "not-read"
    $packet = $null
    $signal = $null
    $decision = $null
    $similar = $null
    $action = $null

    if ($exists) {
        try {
            $packet = Get-Content -LiteralPath $jsonAbsolute -Raw | ConvertFrom-Json
            $signal = $packet.signal
            $decision = $packet.decision
            $similar = $packet.similarRecordAdvisory
            $action = $packet.actionLogSuggestion
            $parseStatus = "parsed"
        }
        catch {
            $parseStatus = "parse-failed: $($_.Exception.Message)"
        }
    }
    else {
        $parseStatus = "missing"
    }

    $crmItemId = [string]$Seed.crmItemId
    if ($null -ne $signal -and $null -ne $signal.Id -and [string]$signal.Id -ne "0") {
        $crmItemId = [string]$signal.Id
    }

    $title = ""
    $source = [string]$Seed.source
    $urgency = ""
    $classification = ""
    $nextGovernance = ""
    $matchSummary = ""
    $actionStatus = ""
    $actionLogItem = ""

    if ($null -ne $signal) {
        $title = Get-B9Text -Value $signal.Title
        if (-not [string]::IsNullOrWhiteSpace([string]$signal.IntakeSource)) {
            $source = Get-B9Text -Value $signal.IntakeSource
        }
    }
    if ($null -ne $decision) {
        $urgency = Get-B9Text -Value $decision.apparentUrgency
        $classification = Get-B9Text -Value $decision.classification
        $nextGovernance = Get-B9Text -Value $decision.nextGovernanceLevel
    }
    if ($null -ne $similar) {
        $matchSummary = Get-B9Text -Value $similar.summary
    }
    if ($null -ne $action) {
        $actionStatus = Get-B9Text -Value $action.status
        if ($null -ne $action.itemId) {
            $actionLogItem = Get-B9Text -Value $action.itemId
        }
    }

    return [pscustomobject][ordered]@{
        label = [string]$Seed.label
        crmItemId = $crmItemId
        source = $source
        title = $title
        triagePacketMarkdown = $mdRelative
        triagePacketMarkdownExists = (Test-Path -LiteralPath $mdAbsolute)
        triagePacketJson = $jsonRelative
        triagePacketJsonExists = $exists
        parseStatus = $parseStatus
        urgency = $urgency
        classification = $classification
        nextGovernance = $nextGovernance
        relatedSummary = $matchSummary
        priorActionLogStatus = $actionStatus
        priorActionLogItem = $actionLogItem
        note = [string]$Seed.note
    }
}

$seedEvidence = @($config.seedEvidencePackets | ForEach-Object { Import-B9SeedEvidence -Seed $_ })

$queueRows = New-Object System.Collections.Generic.List[object]
foreach ($seed in $seedEvidence) {
    $g1Status = "No prior Suggested row loaded."
    if (-not [string]::IsNullOrWhiteSpace($seed.priorActionLogItem)) {
        $g1Status = "Prior Suggested row exists: Agent Action Log #$($seed.priorActionLogItem). Do not duplicate unless Adam approves a superseding row."
    }

    $queueRows.Add([pscustomobject][ordered]@{
        SelectionStatus = "SeedEvidenceOnly"
        CrmItemId = $seed.crmItemId
        Source = $seed.source
        Title = $seed.title
        RecommendedRunMode = "ReviewExistingEvidenceOnly"
        CurrentEvidenceMarkdown = $seed.triagePacketMarkdown
        CurrentEvidenceJson = $seed.triagePacketJson
        PriorG1Status = $g1Status
        OperatorNote = $seed.note
    }) | Out-Null
}

$queueRows.Add([pscustomobject][ordered]@{
    SelectionStatus = "AdamSelectionPending"
    CrmItemId = ""
    Source = ""
    Title = ""
    RecommendedRunMode = "SelectedReadOnlyTriage"
    CurrentEvidenceMarkdown = ""
    CurrentEvidenceJson = ""
    PriorG1Status = "Check for existing Suggested rows before any G1 write."
    OperatorNote = "Fill exact CRM item id, source, or narrow window before running live read-only triage."
}) | Out-Null

$queueRows | Export-Csv -LiteralPath $queueCsvPath -NoTypeInformation -Encoding UTF8

$reviewRows = @(
    [pscustomobject][ordered]@{
        CrmItemId = ""
        TriagePacketPath = ""
        ReviewLabel = "useful_triage"
        OperatorDecision = ""
        RulesToTune = ""
        MissingData = ""
        SourceIngressIssue = ""
        FutureAutomationCandidate = ""
        ApprovedForG1SuggestedRow = "No"
        Notes = ""
    }
)
$reviewRows | Export-Csv -LiteralPath $reviewCsvPath -NoTypeInformation -Encoding UTF8

$summary = [pscustomobject][ordered]@{
    generatedAt = (Get-Date).ToString("o")
    mode = "local-only"
    safety = "No Microsoft 365 connection, no live tenant read, no CRM write, no Agent Action Log write, no flow update, no HTTP send, no secret read."
    configPath = $ConfigPath
    chunk = $config.chunk
    name = $config.name
    purpose = $config.purpose
    authority = $config.authority
    dependsOn = $config.dependsOn
    runModes = $config.runModes
    seedEvidence = $seedEvidence
    selectionPolicy = $config.selectionPolicy
    operatingReviewLabels = $config.operatingReviewLabels
    duplicateSuggestionPolicy = $config.duplicateSuggestionPolicy
    liveApprovalRequired = $config.liveApprovalRequired
    stopConditions = $config.stopConditions
    acceptance = $config.acceptance
    queueCsvPath = $queueCsvPath
    reviewCsvPath = $reviewCsvPath
    markdownPath = $mdPath
    jsonPath = $jsonPath
}

$summary | ConvertTo-Json -Depth 14 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
Add-B9Line -Lines $lines -Text "# B9 Selected Signal Operating Triage Packet"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text ("Generated: {0}" -f $summary.generatedAt)
Add-B9Line -Lines $lines -Text ("Mode: {0}" -f $summary.mode)
Add-B9Line -Lines $lines -Text ("Safety: {0}" -f $summary.safety)
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Purpose"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text $summary.purpose
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Operating Routine"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "1. Adam selects exact CRM item ids, a source type, or a narrow time window."
Add-B9Line -Lines $lines -Text "2. Run G0/R0 selected read-only triage for one to three selected items."
Add-B9Line -Lines $lines -Text "3. Review each packet with the operating labels in the review CSV."
Add-B9Line -Lines $lines -Text "4. Tune only visible decision-rule issues; do not expand the action surface."
Add-B9Line -Lines $lines -Text "5. If approved for a selected item, record at most one G1/R1 Suggested Agent Action Log row."
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Run Modes"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "| Mode | Governance | Tenant touch | Command pattern |"
Add-B9Line -Lines $lines -Text "|---|---|---|---|"
foreach ($mode in @($summary.runModes)) {
    Add-B9Line -Lines $lines -Text ('| {0} | {1} | {2} | `{3}` |' -f $mode.name, $mode.governance, $mode.tenantTouch, $mode.commandPattern)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Seed Evidence"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "| Label | CRM item | Source | Packet exists | Prior G1 | Note |"
Add-B9Line -Lines $lines -Text "|---|---:|---|---|---|---|"
foreach ($seed in @($summary.seedEvidence)) {
    $priorG1 = "none loaded"
    if (-not [string]::IsNullOrWhiteSpace($seed.priorActionLogItem)) {
        $priorG1 = "Agent Action Log #$($seed.priorActionLogItem)"
    }
    Add-B9Line -Lines $lines -Text ('| {0} | {1} | {2} | {3} | {4} | {5} |' -f $seed.label, $seed.crmItemId, $seed.source, $seed.triagePacketJsonExists, $priorG1, $seed.note)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Selection Policy"
Add-B9Line -Lines $lines
foreach ($item in @($summary.selectionPolicy)) {
    Add-B9Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Operating Review Labels"
Add-B9Line -Lines $lines
foreach ($label in @($summary.operatingReviewLabels)) {
    Add-B9Line -Lines $lines -Text ('- `{0}`' -f $label)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Duplicate Policy"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text $summary.duplicateSuggestionPolicy
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Evidence Files"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text ('- Queue CSV: `{0}`' -f $queueCsvPath)
Add-B9Line -Lines $lines -Text ('- Review CSV: `{0}`' -f $reviewCsvPath)
Add-B9Line -Lines $lines -Text ('- Summary JSON: `{0}`' -f $jsonPath)
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Approval Boundary"
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "Selected live read:"
foreach ($item in @($summary.liveApprovalRequired.selectedLiveRead)) {
    Add-B9Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "Selected Suggested row:"
foreach ($item in @($summary.liveApprovalRequired.selectedSuggestedRow)) {
    Add-B9Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Stop Conditions"
Add-B9Line -Lines $lines
foreach ($item in @($summary.stopConditions)) {
    Add-B9Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B9Line -Lines $lines
Add-B9Line -Lines $lines -Text "## Acceptance"
Add-B9Line -Lines $lines
foreach ($item in @($summary.acceptance)) {
    Add-B9Line -Lines $lines -Text ("- {0}" -f $item)
}

$lines | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host "B9 selected-signal operating triage packet generated" -ForegroundColor Cyan
Write-Host ("JSON:   {0}" -f $jsonPath)
Write-Host ("Packet: {0}" -f $mdPath)
Write-Host ("Queue:  {0}" -f $queueCsvPath)
Write-Host ("Review: {0}" -f $reviewCsvPath)

if (-not $NoPause) {
    Write-Host ""
    Read-Host "Press Enter to close"
}
