param(
    [string]$PortalEventId = "",
    [string]$CorrelationId = "",
    [string]$JourneyInviteId = "",
    [string]$CompanyId = "journey-company-internal-walkthrough",
    [string]$EngagementId = "journey-engagement-internal-walkthrough",
    [string]$Email = "",
    [string]$FullName = "GAIL INTERNAL CRM ACK TEST",
    [string]$Organization = "Guided AI Labs Internal Walkthrough",
    [string]$LeadContext = "Internal B7 proof that Journey invite signal reaches CRM and receives an acknowledgement.",
    [switch]$NoPause
)

# B7 local-only packet generator for the Journey -> M365 -> Journey receipt loop.
# This script does not connect to Microsoft 365, send HTTP requests, write CRM
# records, send messages, or transfer secrets. It produces the exact synthetic
# payload and expected acknowledgement shape for the Journey-side test.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b7"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
if ([string]::IsNullOrWhiteSpace($PortalEventId)) {
    $PortalEventId = "GAIL-B7-PORTAL-EVENT-$stamp"
}
if ([string]::IsNullOrWhiteSpace($CorrelationId)) {
    $CorrelationId = $PortalEventId
}
if ([string]::IsNullOrWhiteSpace($JourneyInviteId)) {
    $JourneyInviteId = "journey-invite-test-$stamp"
}
if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = "adam+journey-crm-ack-$stamp@guidedailabs.com"
}

$payload = [ordered]@{
    schemaVersion         = "journey.crm-signal.v1"
    source                = "Guided AI Journey"
    signalMode            = "portal-lifecycle-event"
    eventType             = "organization_setup_saved"
    portalEventId         = $PortalEventId
    correlationId         = $CorrelationId
    companyId             = $CompanyId
    engagementId          = $EngagementId
    inviteId              = $JourneyInviteId
    journeyInviteId       = $JourneyInviteId
    journeyOrganizationId = "journey-org-internal-walkthrough"
    journeyLeadId         = "journey-lead-$stamp"
    inviteRole            = "person"
    sourceAction          = "admin_invited_person"
    portalDeepLink        = "https://www.guidedaijourney.com/dashboard/internal-walkthrough"
    eventTimestamp        = (Get-Date).ToUniversalTime().ToString("o")
    fullName              = $FullName
    email                 = $Email
    organization          = $Organization
    leadContext           = $LeadContext
    heardFrom             = "Guided AI Journey invite/admin trigger"
    consent               = $false
    company               = ""
    ackRequested          = $true
    testMode              = $true
}

$expectedAck = [ordered]@{
    schemaVersion         = "journey.crm-receipt.v1"
    eventType             = "m365.crm_signal.received"
    receivedEventType     = $payload.eventType
    source                = "Guided AI Journey"
    portalEventId         = $PortalEventId
    correlationId         = $CorrelationId
    companyId             = $CompanyId
    engagementId          = $EngagementId
    inviteId              = $JourneyInviteId
    journeyInviteId       = $JourneyInviteId
    journeyOrganizationId = $payload.journeyOrganizationId
    journeyLeadId         = $payload.journeyLeadId
    crmStatus             = "created"
    received              = $true
    crmRecordId           = "sharepoint-list-item-id"
    crmRecordUrl          = "CRM display-form URL after item exists"
    crmItemId             = 0
    crmItemUrl            = "CRM display-form URL after item exists"
    crmTitle              = "Guided AI Journey - $FullName"
    signalStatus          = "New"
    priority              = "Normal"
    flowRunId             = "optional Power Automate run id"
    receivedAt            = "CRM Created timestamp"
    processedAt           = "M365 acknowledgement timestamp"
    ackGeneratedAt        = "M365 acknowledgement timestamp"
    message               = "CRM - New Signals item created in Microsoft 365."
}

$summary = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    mode        = "local-only"
    safety      = "No Microsoft 365 connection, no HTTP send, no CRM write, no secret transfer."
    payload     = $payload
    expectedAck = $expectedAck
    nextSteps   = @(
        "Journey side sends payload to the existing server-side custom intake endpoint.",
        "M365 verifies one CRM - New Signals item contains this portalEventId/correlation id.",
        "After Journey provides an ack endpoint and secret, M365 sends expectedAck with real CRM item values."
    )
}

$jsonPath = Join-Path $outputRoot ("b7-journey-signal-ack-packet-{0}.json" -f $stamp)
$mdPath = Join-Path $outputRoot ("b7-journey-signal-ack-packet-{0}.md" -f $stamp)

$summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# B7 Journey Signal Ack Test Packet")
$lines.Add("")
$lines.Add("Generated: $($summary.generatedAt)")
$lines.Add("")
$lines.Add("Safety: $($summary.safety)")
$lines.Add("")
$lines.Add("## Journey -> M365 Payload")
$lines.Add("")
$lines.Add("````json")
$lines.Add(($payload | ConvertTo-Json -Depth 8))
$lines.Add("````")
$lines.Add("")
$lines.Add("## Expected M365 -> Journey Ack")
$lines.Add("")
$lines.Add("````json")
$lines.Add(($expectedAck | ConvertTo-Json -Depth 8))
$lines.Add("````")
$lines.Add("")
$lines.Add("## Next Steps")
$lines.Add("")
foreach ($step in $summary.nextSteps) {
    $lines.Add("- $step")
}
$lines | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host "B7 Journey signal ack packet generated" -ForegroundColor Cyan
Write-Host ("Payload: {0}" -f $jsonPath)
Write-Host ("Packet:  {0}" -f $mdPath)

if (-not $NoPause) {
    Write-Host ""
    Read-Host "Press Enter to close"
}
