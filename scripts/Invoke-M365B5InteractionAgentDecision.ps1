param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [string]$PayloadPath = "",
    [string]$EvidenceMarkdownPath = "",
    [switch]$Apply,
    [string]$ApprovalPhrase = "",
    [switch]$LocalOnly,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# B5 - record the M365 Interaction Agent one-writer decision.
#
# Local-only by request with -LocalOnly. Otherwise dry-run connects to verify the
# target Lists and reports create/update intent. Apply mode writes only to the
# existing Decision Register and Agent Action Log after the exact approval
# phrase is supplied. It does not update CRM records, flows, Teams, Planner,
# permissions, app registrations, guest access, sharing, mail, or tenant policy.

$ErrorActionPreference = "Stop"

$RequiredApprovalPhrase = "approve-b5-record-one-writer-m365-interaction-agent-20260625"
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b5"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

if ([string]::IsNullOrWhiteSpace($PayloadPath)) {
    $PayloadPath = Join-Path $outputRoot "decision-register-draft-b5-one-writer-20260625.json"
}
if ([string]::IsNullOrWhiteSpace($EvidenceMarkdownPath)) {
    $EvidenceMarkdownPath = Join-Path $outputRoot "B5_DURABLE_PERMISSION_DECISION_2026-06-25.md"
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $outputRoot ("b5-interaction-agent-decision-{0}.log" -f $stamp)
$summaryPath = Join-Path $outputRoot ("b5-interaction-agent-decision-{0}.json" -f $stamp)

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

function Write-Section {
    param([string]$Message)

    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Get-B5PropertyValue {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.ContainsKey($Name)) { return $Object[$Name] }
        foreach ($key in $Object.Keys) {
            if ([string]$key -eq $Name) { return $Object[$key] }
        }
        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -ne $property) { return $property.Value }
    return $null
}

function Get-B5RequiredText {
    param(
        [object]$Object,
        [string]$Name
    )

    $value = [string](Get-B5PropertyValue -Object $Object -Name $Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Payload is missing required value '$Name'."
    }
    return $value
}

function ConvertTo-B5Date {
    param(
        [object]$Value,
        [string]$Name
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        throw "Payload is missing required date '$Name'."
    }

    try {
        return [datetime]$Value
    }
    catch {
        throw "Payload value '$Name' is not a valid date: $Value"
    }
}

function ConvertTo-B5XmlText {
    param([string]$Value)

    return [System.Security.SecurityElement]::Escape($Value)
}

function Get-B5ClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-B5ExpectedUser {
    param([string]$TargetSiteUrl)

    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-B5ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-B5ClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-B5PnP {
    param([string]$TargetSiteUrl)

    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is not available in this PowerShell host. Use scripts\Start-M365B5InteractionAgentDecisionInteractive.ps1 or install the module before running live dry-run/apply."
    }
    Import-Module PnP.PowerShell -ErrorAction Stop

    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $TargetSiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{
            Url          = $TargetSiteUrl
            ClientId     = $ClientId
            Interactive  = $true
            PersistLogin = $true
        }
        if ($ForceFreshLogin) {
            $connectParams.ForceAuthentication = $true
        }

        Connect-PnPOnline @connectParams
    }

    $connection = Get-PnPConnection
    Write-Host ("Connected to {0} using {1}" -f $TargetSiteUrl, $connection.ConnectionType) -ForegroundColor Gray
    Assert-B5ExpectedUser -TargetSiteUrl $TargetSiteUrl

    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function Resolve-B5UserFieldValue {
    param([string]$UserPrincipalName)

    $user = $null
    try {
        $user = Get-PnPUser -Identity $UserPrincipalName -ErrorAction SilentlyContinue
    }
    catch {
        $user = $null
    }

    if ($null -eq $user) {
        $user = New-PnPUser -LoginName $UserPrincipalName
    }

    if ($null -ne $user -and -not [string]::IsNullOrWhiteSpace($user.LoginName)) {
        return $user.LoginName
    }

    return $UserPrincipalName
}

function Get-B5ListItemByTitle {
    param(
        [string]$ListTitle,
        [string]$Title
    )

    $escapedTitle = ConvertTo-B5XmlText -Value $Title
    $query = @"
<View>
  <Query>
    <Where>
      <Eq>
        <FieldRef Name='Title' />
        <Value Type='Text'>$escapedTitle</Value>
      </Eq>
    </Where>
  </Query>
  <RowLimit>1</RowLimit>
</View>
"@

    return @(Get-PnPListItem -List $ListTitle -Query $query -ErrorAction Stop | Select-Object -First 1)
}

function Set-B5ListItem {
    param(
        [string]$ListTitle,
        [hashtable]$Values
    )

    $title = [string]$Values["Title"]
    $existing = @(Get-B5ListItemByTitle -ListTitle $ListTitle -Title $title)

    if (-not $Apply) {
        if ($existing.Count -gt 0) {
            Write-Host ("  DRY RUN: would update existing {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Yellow
            return [pscustomobject][ordered]@{ list = $ListTitle; intent = "update"; itemId = $existing[0].Id; title = $title }
        }

        Write-Host ("  DRY RUN: would create {0} item: {1}" -f $ListTitle, $title) -ForegroundColor Yellow
        return [pscustomobject][ordered]@{ list = $ListTitle; intent = "create"; itemId = $null; title = $title }
    }

    if ($existing.Count -gt 0) {
        Set-PnPListItem -List $ListTitle -Identity $existing[0].Id -Values $Values | Out-Null
        Write-Host ("  [OK] Updated {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Green
        return [pscustomobject][ordered]@{ list = $ListTitle; intent = "updated"; itemId = $existing[0].Id; title = $title }
    }

    $created = Add-PnPListItem -List $ListTitle -Values $Values
    Write-Host ("  [OK] Created {0} item #{1}: {2}" -f $ListTitle, $created.Id, $title) -ForegroundColor Green
    return [pscustomobject][ordered]@{ list = $ListTitle; intent = "created"; itemId = $created.Id; title = $title }
}

function New-B5ActionResultText {
    param(
        [string]$DecisionTitle,
        [string]$PayloadFile,
        [string]$EvidenceFile
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add(("B5 M365 Interaction Agent one-writer posture recorded {0}." -f (Get-Date).ToString("yyyy-MM-dd HH:mm")))
    $lines.Add(("Decision: {0}" -f $DecisionTitle))
    $lines.Add(("Payload JSON: {0}" -f $PayloadFile))
    $lines.Add(("Decision packet: {0}" -f $EvidenceFile))
    $lines.Add("")
    $lines.Add("Selected posture: one canonical Guided AI Labs agent lane named M365 Interaction Agent.")
    $lines.Add("Account boundary: Guided AI Labs stays under adamgoodwin@guidedailabs.com; Prime Boiler setup stays in its separate account/profile/session lane.")
    $lines.Add("Immediate agent write surface: one Agent Action Log row with ActionStatus=Suggested per selected CRM signal through scripts/Invoke-M365NewSignalTriage.ps1 -Apply.")
    $lines.Add("Source-ingress exceptions: Guided AI Labs intake flow, Guided AI Journey intake flow, and New Signal Teams alert flow remain create-only/source-ingress plumbing, not agent decision writers.")
    $lines.Add("")
    $lines.Add("Blocked by this B5 record: CRM updates/merges/status changes, Planner or calendar writes, external sends, QUO/client commitments, website-to-CRM direct POST/secrets, permission/app/guest/sharing/policy changes, deletes, and unattended tenant-writing automation.")
    $lines.Add("No CRM record, flow, connector, Teams post, Planner task, mail, permission, app registration, guest/share, or tenant policy change was made by this recorder.")

    return ($lines -join "`n")
}

try {
    Write-Host "B5 - M365 Interaction Agent decision recorder" -ForegroundColor Cyan
    Write-Host ("Site:       {0}" -f $SiteUrl) -ForegroundColor Gray
    Write-Host ("Payload:    {0}" -f $PayloadPath) -ForegroundColor Gray
    Write-Host ("Evidence:   {0}" -f $EvidenceMarkdownPath) -ForegroundColor Gray
    Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
    Write-Host ("Mode:       {0}" -f $(if ($LocalOnly) { "LOCAL ONLY: no Microsoft 365 connection" } elseif ($Apply) { "APPLY: Decision Register + Agent Action Log" } else { "DRY RUN: tenant read/verify only" })) -ForegroundColor Gray
    Write-Host "Writes:     Decision Register and Agent Action Log only when -Apply is used with the exact approval phrase." -ForegroundColor Gray

    if ($Apply -and $LocalOnly) {
        throw "Use either -LocalOnly or -Apply, not both."
    }
    if ($Apply -and $ApprovalPhrase -ne $RequiredApprovalPhrase) {
        throw "Apply mode requires -ApprovalPhrase '$RequiredApprovalPhrase'. No Microsoft 365 connection or write was attempted."
    }
    if (-not (Test-Path -LiteralPath $PayloadPath)) {
        throw "Payload JSON not found: $PayloadPath"
    }
    if (-not (Test-Path -LiteralPath $EvidenceMarkdownPath)) {
        throw "Decision packet markdown not found: $EvidenceMarkdownPath"
    }

    Write-Section "Read local payload"
    $payload = Get-Content -LiteralPath $PayloadPath -Raw | ConvertFrom-Json
    $values = Get-B5PropertyValue -Object $payload -Name "values"
    if ($null -eq $values) {
        throw "Payload JSON must include a top-level 'values' object."
    }

    $decisionTitle = Get-B5RequiredText -Object $values -Name "Title"
    $decisionArea = Get-B5RequiredText -Object $values -Name "DecisionArea"
    $decisionText = Get-B5RequiredText -Object $values -Name "Decision"
    $rationale = Get-B5RequiredText -Object $values -Name "Rationale"
    $decisionDate = ConvertTo-B5Date -Value (Get-B5PropertyValue -Object $values -Name "DecisionDate") -Name "DecisionDate"
    $revisitDate = ConvertTo-B5Date -Value (Get-B5PropertyValue -Object $values -Name "RevisitDate") -Name "RevisitDate"
    Write-Host ("PASS: payload loaded for '{0}'" -f $decisionTitle) -ForegroundColor Green

    $summary = [ordered]@{
        generatedAt = (Get-Date).ToString("o")
        mode = $(if ($LocalOnly) { "local-only" } elseif ($Apply) { "apply" } else { "dry-run" })
        siteUrl = $SiteUrl
        expectedUpn = $ExpectedUpn
        payloadPath = $PayloadPath
        evidenceMarkdownPath = $EvidenceMarkdownPath
        requiredApprovalPhrase = $RequiredApprovalPhrase
        decisionTitle = $decisionTitle
        safety = "No Microsoft 365 write occurs unless -Apply and the exact approval phrase are both supplied."
        records = @()
    }

    if ($LocalOnly) {
        Write-Section "Local preview"
        Write-Host ("Would record Decision Register item: {0}" -f $decisionTitle) -ForegroundColor Yellow
        Write-Host "Would record Agent Action Log item: B5 one-writer posture recorded" -ForegroundColor Yellow
        $summary.records = @(
            [pscustomobject][ordered]@{ list = "Decision Register"; intent = "local-preview"; itemId = $null; title = $decisionTitle },
            [pscustomobject][ordered]@{ list = "Agent Action Log"; intent = "local-preview"; itemId = $null; title = "B5 one-writer posture recorded" }
        )
    }
    else {
        Write-Section "Connect"
        Connect-B5PnP -TargetSiteUrl $SiteUrl
        $ownerLogin = Resolve-B5UserFieldValue -UserPrincipalName $OwnerUpn

        Write-Section "Verify target Lists"
        $decisionList = Get-PnPList -Identity "Decision Register" -ErrorAction Stop
        $actionLog = Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop
        Write-Host ("  Found Decision Register: {0}" -f $decisionList.Title) -ForegroundColor Green
        Write-Host ("  Found Agent Action Log: {0}" -f $actionLog.Title) -ForegroundColor Green

        $decisionValues = @{
            Title         = $decisionTitle
            DecisionDate  = $decisionDate
            DecisionOwner = $ownerLogin
            DecisionArea  = $decisionArea
            Decision      = $decisionText
            Rationale     = $rationale
            RevisitDate   = $revisitDate
        }

        $actionValues = @{
            Title          = "B5 one-writer posture recorded"
            ActionDate     = Get-Date
            AgentSurface   = "Codex / M365 Interaction Agent"
            ActionType     = "record-decision"
            ActionStatus   = "Completed"
            HumanApprover  = $ownerLogin
            Result         = (New-B5ActionResultText -DecisionTitle $decisionTitle -PayloadFile $PayloadPath -EvidenceFile $EvidenceMarkdownPath)
        }

        Write-Section "Record operating evidence"
        $decisionRecord = Set-B5ListItem -ListTitle "Decision Register" -Values $decisionValues
        $actionRecord = Set-B5ListItem -ListTitle "Agent Action Log" -Values $actionValues
        $summary.records = @($decisionRecord, $actionRecord)
    }

    Write-Section "Write local summary"
    $summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $summaryPath -Encoding UTF8
    Write-Host ("Summary JSON: {0}" -f $summaryPath) -ForegroundColor Green

    Write-Section "Done"
    if ($LocalOnly) {
        Write-Host "Local preview complete. No Microsoft 365 connection or write occurred." -ForegroundColor Green
    }
    elseif ($Apply) {
        Write-Host "B5 decision evidence is now recorded in Decision Register and Agent Action Log." -ForegroundColor Green
    }
    else {
        Write-Host ("Dry run complete. Re-run with -Apply -ApprovalPhrase '{0}' to write the records after Adam approval." -f $RequiredApprovalPhrase) -ForegroundColor Yellow
    }
    Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
}
finally {
    try {
        Stop-Transcript | Out-Null
    }
    catch {}
    if (-not $NoPause) {
        Write-Host ""
        Write-Host "Press Enter to close this window."
        Read-Host | Out-Null
    }
}

