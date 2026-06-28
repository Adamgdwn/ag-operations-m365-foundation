param(
    [string]$ConfigPath = "",
    [switch]$NoPause
)

# B8 local-only packet generator for Journey loop hardening.
# This script does not connect to Microsoft 365, update flows, send HTTP
# requests, create CRM records, or touch secrets. It turns the B8 design into a
# concrete approval packet with evidence checks and exact next gates.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B8_JOURNEY_LOOP_HARDENING.json"
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "B8 config not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$outputRoot = Join-Path $workspaceRoot $config.evidenceTargets.localPacketDirectory
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonPath = Join-Path $outputRoot ("b8-journey-loop-hardening-packet-{0}.json" -f $stamp)
$mdPath = Join-Path $outputRoot ("b8-journey-loop-hardening-packet-{0}.md" -f $stamp)

function Resolve-B8Path {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

function Add-B8Line {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Text = ""
    )
    $Lines.Add($Text)
}

function ConvertTo-B8PlainText {
    param([object]$Value)

    if ($null -eq $Value) { return "" }
    if ($Value -is [array]) {
        return (@($Value | ForEach-Object { ConvertTo-B8PlainText -Value $_ }) -join "; ")
    }
    return [string]$Value
}

$evidenceChecks = @()
foreach ($propertyName in @("b7LiveProof", "b7LeadSourceProof")) {
    $relativePath = [string]$config.evidenceTargets.$propertyName
    $absolutePath = Resolve-B8Path -Path $relativePath
    $evidenceChecks += [pscustomobject][ordered]@{
        name = $propertyName
        relativePath = $relativePath
        exists = (Test-Path -LiteralPath $absolutePath)
    }
}

$flowCaptureRelative = [string]$config.evidenceTargets.flowBodyCapture
$flowCaptureAbsolute = Resolve-B8Path -Path $flowCaptureRelative
$evidenceChecks += [pscustomobject][ordered]@{
    name = "flowBodyCaptureLocalOnly"
    relativePath = $flowCaptureRelative
    exists = (Test-Path -LiteralPath $flowCaptureAbsolute)
    note = "This may be absent on a fresh machine because .local is intentionally untracked."
}

$fieldPlan = @($config.recommendedDefault.sharePointFields | ForEach-Object {
    [pscustomobject][ordered]@{
        displayName = $_.displayName
        internalName = $_.internalName
        type = $_.type
        required = [bool]$_.required
        indexed = [bool]$_.indexed
        purpose = $_.purpose
        liveWriteRequired = $true
    }
})

$flowUpdatePlan = @(
    [pscustomobject][ordered]@{
        order = 1
        action = "Compose Journey keys"
        detail = "Normalize portalEventId and correlationId before any SharePoint write."
    },
    [pscustomobject][ordered]@{
        order = 2
        action = "Lookup existing CRM signal"
        detail = "When PortalEventId is present, query CRM - New Signals by PortalEventId before Create item."
    },
    [pscustomobject][ordered]@{
        order = 3
        action = "Zero matches"
        detail = "Create one CRM item, populate SourceText plus first-class fields, then send Journey ack with crmStatus=created."
    },
    [pscustomobject][ordered]@{
        order = 4
        action = "One match"
        detail = "Skip Create item and send Journey ack with existing CRM item id/url and crmStatus=existing."
    },
    [pscustomobject][ordered]@{
        order = 5
        action = "More than one match"
        detail = "Do not create or ack as success. Stop for Adam review; optional G1 advisory requires separate approval."
    }
)

$summary = [pscustomobject][ordered]@{
    generatedAt = (Get-Date).ToString("o")
    mode = "local-only"
    safety = "No Microsoft 365 connection, no HTTP send, no CRM write, no flow update, no secret read."
    configPath = $ConfigPath
    chunk = $config.chunk
    name = $config.name
    purpose = $config.purpose
    authority = $config.authority
    currentState = $config.currentState
    fieldPlan = $fieldPlan
    deferredFields = $config.recommendedDefault.deferredFields
    duplicatePolicy = $config.recommendedDefault.duplicatePolicy
    replayPolicy = $config.recommendedDefault.replayPolicy
    cleanupPolicy = $config.recommendedDefault.cleanupPolicy
    flowUpdatePlan = $flowUpdatePlan
    liveApprovalRequired = $config.liveApprovalRequired
    evidenceChecks = $evidenceChecks
    acceptance = $config.acceptance
}

$summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
Add-B8Line -Lines $lines -Text "# B8 Journey Loop Hardening Packet"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text ("Generated: {0}" -f $summary.generatedAt)
Add-B8Line -Lines $lines -Text ("Mode: {0}" -f $summary.mode)
Add-B8Line -Lines $lines -Text ("Safety: {0}" -f $summary.safety)
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Purpose"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text $summary.purpose
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Current State"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text ('- Source list: `{0}`' -f $summary.currentState.sourceList)
Add-B8Line -Lines $lines -Text ('- Journey ledger: `{0}`' -f $summary.currentState.journeyLedger)
Add-B8Line -Lines $lines -Text ('- HTTP intake flow: `{0}` (`{1}`)' -f $summary.currentState.httpIntakeFlowDisplayName, $summary.currentState.httpIntakeFlowId)
Add-B8Line -Lines $lines -Text ("- Current portal event storage: {0}" -f $summary.currentState.currentPortalEventStorage)
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Field Plan"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "| Display name | Internal name | Type | Indexed | Purpose |"
Add-B8Line -Lines $lines -Text "|---|---|---|---|---|"
foreach ($field in $summary.fieldPlan) {
    Add-B8Line -Lines $lines -Text ('| {0} | `{1}` | {2} | {3} | {4} |' -f $field.displayName, $field.internalName, $field.type, $field.indexed, $field.purpose)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "Deferred:"
foreach ($field in @($summary.deferredFields)) {
    Add-B8Line -Lines $lines -Text ('- `{0}`: {1}' -f $field.internalName, $field.reason)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Duplicate And Replay Policy"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text ("- Duplicate policy: {0}" -f $summary.duplicatePolicy)
Add-B8Line -Lines $lines -Text ("- Replay policy: {0}" -f $summary.replayPolicy)
Add-B8Line -Lines $lines -Text ("- Cleanup policy: {0}" -f $summary.cleanupPolicy)
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Flow Update Plan"
Add-B8Line -Lines $lines
foreach ($step in $summary.flowUpdatePlan) {
    Add-B8Line -Lines $lines -Text ("{0}. {1}: {2}" -f $step.order, $step.action, $step.detail)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Live Approval Boundary"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text ('Approval phrase for the later live update: `{0}`' -f $summary.liveApprovalRequired.approvalPhrase)
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "Scope:"
foreach ($item in @($summary.liveApprovalRequired.scope)) {
    Add-B8Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "Stop conditions:"
foreach ($item in @($summary.liveApprovalRequired.stopConditions)) {
    Add-B8Line -Lines $lines -Text ("- {0}" -f $item)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Evidence Checks"
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "| Check | Path | Exists |"
Add-B8Line -Lines $lines -Text "|---|---|---|"
foreach ($check in $summary.evidenceChecks) {
    Add-B8Line -Lines $lines -Text ('| {0} | `{1}` | {2} |' -f $check.name, $check.relativePath, $check.exists)
}
Add-B8Line -Lines $lines
Add-B8Line -Lines $lines -Text "## Acceptance"
Add-B8Line -Lines $lines
foreach ($item in @($summary.acceptance)) {
    Add-B8Line -Lines $lines -Text ("- {0}" -f $item)
}

$lines | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host "B8 Journey loop hardening packet generated" -ForegroundColor Cyan
Write-Host ("JSON:   {0}" -f $jsonPath)
Write-Host ("Packet: {0}" -f $mdPath)

if (-not $NoPause) {
    Write-Host ""
    Read-Host "Press Enter to close"
}
