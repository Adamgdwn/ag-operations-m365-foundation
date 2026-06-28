param(
    [string]$ConfigPath = "",
    [switch]$NoPause
)

# B10 local-only packet generator for QUO inbound source proof readiness.
# This script does not connect to QUO or Microsoft 365, create CRM records,
# update flows, send HTTP requests, read .local secrets, or trigger outbound
# phone/SMS behavior. It writes only local readiness artifacts.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B10_QUO_INBOUND_SOURCE_PROOF.json"
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "B10 config not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$outputRoot = Join-Path $workspaceRoot $config.evidenceTargets.localPacketDirectory
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonPath = Join-Path $outputRoot ("b10-quo-inbound-source-proof-packet-{0}.json" -f $stamp)
$mdPath = Join-Path $outputRoot ("b10-quo-inbound-source-proof-packet-{0}.md" -f $stamp)
$eventMappingCsvPath = Join-Path $outputRoot ("b10-quo-event-mapping-{0}.csv" -f $stamp)
$decisionWorksheetCsvPath = Join-Path $outputRoot ("b10-quo-live-decision-worksheet-{0}.csv" -f $stamp)
$proofChecklistCsvPath = Join-Path $outputRoot ("b10-quo-proof-checklist-{0}.csv" -f $stamp)

function Resolve-B10Path {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

function Add-B10Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Text = ""
    )
    $Lines.Add($Text)
}

function Get-B10Text {
    param([object]$Value)

    if ($null -eq $Value) { return "" }
    if ($Value -is [array]) {
        return (@($Value | ForEach-Object { Get-B10Text -Value $_ }) -join "; ")
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

function Test-B10EvidencePath {
    param(
        [string]$Name,
        [string]$RelativePath,
        [string]$Note = ""
    )

    $absolutePath = Resolve-B10Path -Path $RelativePath
    [pscustomobject][ordered]@{
        name = $Name
        relativePath = $RelativePath
        exists = (Test-Path -LiteralPath $absolutePath)
        note = $Note
    }
}

$eventRows = New-Object System.Collections.Generic.List[object]
foreach ($eventClass in @($config.recommendedDefault.eventClasses)) {
    $eventRows.Add([pscustomobject][ordered]@{
        EventClass = Get-B10Text -Value $eventClass.eventClass
        CreatesCrmSignalByDefault = Get-B10Text -Value $eventClass.createsCrmSignalByDefault
        SignalType = Get-B10Text -Value $eventClass.signalType
        DefaultPriority = Get-B10Text -Value $eventClass.priority
        RequiredFields = Get-B10Text -Value $eventClass.requiredFields
        DuplicateKey = "sourceEventId; fallback conversationId/callId + fromPhone + timestamp bucket"
        Notes = Get-B10Text -Value $eventClass.notes
    }) | Out-Null
}
$eventMappingRows = @($eventRows.ToArray())
$eventRows | Export-Csv -LiteralPath $eventMappingCsvPath -NoTypeInformation -Encoding UTF8

$decisionRows = @(
    [pscustomobject][ordered]@{ Decision = "Business intake number(s)"; Default = "Adam-approved QUO number(s) only"; RequiredForB10b = "Exact number(s)"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "First proof event class"; Default = "One no-real-client or internal event"; RequiredForB10b = "missed_call, voicemail, inbound_sms, or completed_call_summary"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Ingress option"; Default = "Purpose-built signed ingress adapter for production; manual bridge only as fallback"; RequiredForB10b = "manualBridge, noCodeWebhookBridge, or purposeBuiltIngressAdapter"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Signature and secret storage"; Default = "Server-side only, never git/inventory/browser"; RequiredForB10b = "Storage location and revoke path"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Raw payload evidence"; Default = ".local only when approved; sanitized summaries in inventory"; RequiredForB10b = "Retention and redaction rule"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Duplicate/idempotency rule"; Default = "sourceEventId first; fallback call/conversation plus phone/time bucket"; RequiredForB10b = "Approved duplicate window"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Disable/pause path"; Default = "Named owner plus exact webhook/flow/adapter pause location"; RequiredForB10b = "Owner and pause steps"; Status = "Pending"; Notes = "" },
    [pscustomobject][ordered]@{ Decision = "Outbound block"; Default = "No SMS reply, callback, or outbound QUO API send"; RequiredForB10b = "Explicitly confirmed"; Status = "Pending"; Notes = "" }
)
$decisionRows | Export-Csv -LiteralPath $decisionWorksheetCsvPath -NoTypeInformation -Encoding UTF8

$proofRows = @(
    [pscustomobject][ordered]@{ Order = 1; Check = "Approval phrase and exact B10b scope recorded"; EvidenceTarget = "Decision Register or B10 proof packet"; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 2; Check = "QUO event payload redacted or synthetic"; EvidenceTarget = $config.evidenceTargets.futureSanitizedPayloadSummary; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 3; Check = "Ingress bridge owner and disable path captured"; EvidenceTarget = $decisionWorksheetCsvPath; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 4; Check = "Exactly one CRM - New Signals item created or mapped"; EvidenceTarget = $config.evidenceTargets.futureProofPacket; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 5; Check = "Existing New Signal Teams alert posts once"; EvidenceTarget = $config.evidenceTargets.futureProofPacket; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 6; Check = "G0 triage packet handles QUO source"; EvidenceTarget = "inventory/new-signal-triage/new-signal-triage-*.md"; RequiredBeforeLive = "Yes"; Status = "Pending" },
    [pscustomobject][ordered]@{ Order = 7; Check = "No outbound SMS, callback, client commitment, merge, delete, or task write"; EvidenceTarget = $config.evidenceTargets.futureProofPacket; RequiredBeforeLive = "Yes"; Status = "Pending" }
)
$proofRows | Export-Csv -LiteralPath $proofChecklistCsvPath -NoTypeInformation -Encoding UTF8

$evidenceChecks = @(
    (Test-B10EvidencePath -Name "b8aJourneyHardeningPacket" -RelativePath $config.dependsOn.b8aJourneyHardeningPacket),
    (Test-B10EvidencePath -Name "b9aSelectedSignalOperatingPacket" -RelativePath $config.dependsOn.b9aSelectedSignalOperatingPacket),
    (Test-B10EvidencePath -Name "futureRawPayloadLocalOnlyDirectory" -RelativePath $config.evidenceTargets.futureRawPayloadLocalOnly -Note "Expected to be absent until a live proof is approved. Raw payloads are intentionally untracked.")
)

$summary = [pscustomobject][ordered]@{
    generatedAt = (Get-Date).ToString("o")
    mode = "local-only"
    safety = "No QUO connection, no Microsoft 365 connection, no CRM write, no Teams post, no flow update, no HTTP send, no .local secret read, no outbound phone/SMS action."
    configPath = $ConfigPath
    chunk = $config.chunk
    name = $config.name
    purpose = $config.purpose
    dependsOn = $config.dependsOn
    currentState = $config.currentState
    authority = $config.authority
    sourcePrinciples = $config.sourcePrinciples
    ingressOptions = $config.ingressOptions
    recommendedDefault = $config.recommendedDefault
    eventMapping = $eventMappingRows
    liveDecisionWorksheet = $decisionRows
    proofChecklist = $proofRows
    liveApprovalRequired = $config.liveApprovalRequired
    evidenceChecks = $evidenceChecks
    acceptance = $config.acceptance
    eventMappingCsvPath = $eventMappingCsvPath
    decisionWorksheetCsvPath = $decisionWorksheetCsvPath
    proofChecklistCsvPath = $proofChecklistCsvPath
    markdownPath = $mdPath
    jsonPath = $jsonPath
}

$summary | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
Add-B10Line -Lines $lines -Text "# B10 QUO Inbound Source Proof Packet"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ("Generated: {0}" -f $summary.generatedAt)
Add-B10Line -Lines $lines -Text ("Mode: {0}" -f $summary.mode)
Add-B10Line -Lines $lines -Text ("Safety: {0}" -f $summary.safety)
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Purpose"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text $summary.purpose
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Current State"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ("- QUO live hookup: {0}" -f $summary.currentState.quoLiveHookup)
Add-B10Line -Lines $lines -Text ('- CRM source list: `{0}`' -f $summary.currentState.crmSourceList)
Add-B10Line -Lines $lines -Text ('- Teams alert flow: `{0}` ({1})' -f $summary.currentState.teamsAlertFlow, $summary.currentState.teamsAlertFlowState)
Add-B10Line -Lines $lines -Text ("- Triage lane: {0}" -f $summary.currentState.triageLane)
Add-B10Line -Lines $lines -Text ("- Outbound status: {0}" -f $summary.currentState.outboundStatus)
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Source Principles"
Add-B10Line -Lines $lines
foreach ($principle in @($summary.sourcePrinciples)) {
    Add-B10Line -Lines $lines -Text ("- {0}" -f $principle)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Ingress Options"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "| Option | Governance | Fit |"
Add-B10Line -Lines $lines -Text "|---|---|---|"
foreach ($option in @($summary.ingressOptions)) {
    Add-B10Line -Lines $lines -Text ('| {0} | {1} | {2} |' -f $option.name, $option.governance, $option.fit)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "Recommended proof path:"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text $summary.recommendedDefault.proofPath
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Event Mapping"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "| Event class | Creates CRM signal | Signal type | Priority | Required fields |"
Add-B10Line -Lines $lines -Text "|---|---|---|---|---|"
foreach ($eventRow in $eventMappingRows) {
    Add-B10Line -Lines $lines -Text ('| {0} | {1} | {2} | {3} | {4} |' -f $eventRow.EventClass, $eventRow.CreatesCrmSignalByDefault, $eventRow.SignalType, $eventRow.DefaultPriority, $eventRow.RequiredFields)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Normalized CRM Shape"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ('- `IntakeSource`: `{0}`' -f $summary.recommendedDefault.normalizedCrmShape.IntakeSource)
Add-B10Line -Lines $lines -Text ('- `SignalStatus`: `{0}`' -f $summary.recommendedDefault.normalizedCrmShape.SignalStatus)
Add-B10Line -Lines $lines -Text ('- Title pattern: `{0}`' -f $summary.recommendedDefault.normalizedCrmShape.TitlePattern)
Add-B10Line -Lines $lines -Text "- `SourceText` metadata:"
foreach ($item in @($summary.recommendedDefault.normalizedCrmShape.SourceTextMetadata)) {
    Add-B10Line -Lines $lines -Text ("  - {0}" -f $item)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Duplicate, Payload, And Disable Rules"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ("- Duplicate policy: {0}" -f $summary.recommendedDefault.duplicatePolicy)
Add-B10Line -Lines $lines -Text ("- Raw payload policy: {0}" -f $summary.recommendedDefault.rawPayloadPolicy)
Add-B10Line -Lines $lines -Text ("- Retention default: {0}" -f $summary.recommendedDefault.retentionDefault)
Add-B10Line -Lines $lines -Text ("- Disable path: {0}" -f $summary.recommendedDefault.disablePath)
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Evidence Files"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ('- Event mapping CSV: `{0}`' -f $eventMappingCsvPath)
Add-B10Line -Lines $lines -Text ('- Decision worksheet CSV: `{0}`' -f $decisionWorksheetCsvPath)
Add-B10Line -Lines $lines -Text ('- Proof checklist CSV: `{0}`' -f $proofChecklistCsvPath)
Add-B10Line -Lines $lines -Text ('- Summary JSON: `{0}`' -f $jsonPath)
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Live Approval Boundary"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text ('Approval phrase for the later live proof: `{0}`' -f $summary.liveApprovalRequired.approvalPhrase)
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "Scope:"
foreach ($item in @($summary.liveApprovalRequired.scope)) {
    Add-B10Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "Stop conditions:"
foreach ($item in @($summary.liveApprovalRequired.stopConditions)) {
    Add-B10Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Evidence Checks"
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "| Check | Path | Exists | Note |"
Add-B10Line -Lines $lines -Text "|---|---|---|---|"
foreach ($check in @($summary.evidenceChecks)) {
    Add-B10Line -Lines $lines -Text ('| {0} | `{1}` | {2} | {3} |' -f $check.name, $check.relativePath, $check.exists, $check.note)
}
Add-B10Line -Lines $lines
Add-B10Line -Lines $lines -Text "## Acceptance"
Add-B10Line -Lines $lines
foreach ($item in @($summary.acceptance)) {
    Add-B10Line -Lines $lines -Text ("- {0}" -f $item)
}

$lines | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host "B10 QUO inbound source proof packet generated" -ForegroundColor Cyan
Write-Host ("JSON:      {0}" -f $jsonPath)
Write-Host ("Packet:    {0}" -f $mdPath)
Write-Host ("Events:    {0}" -f $eventMappingCsvPath)
Write-Host ("Decision:  {0}" -f $decisionWorksheetCsvPath)
Write-Host ("Checklist: {0}" -f $proofChecklistCsvPath)

if (-not $NoPause) {
    Write-Host ""
    Read-Host "Press Enter to close"
}
