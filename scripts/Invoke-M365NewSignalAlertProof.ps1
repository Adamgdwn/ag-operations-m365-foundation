param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$GuidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$ListTitle = "CRM - New Signals",
    [int]$ItemId = 0,
    [switch]$Apply,
    [string]$OperatorEvidenceJson = "",
    [switch]$UseDeviceLogin,
    [switch]$ForceFreshLogin,
    [switch]$SkipOperatorEvidence,
    [switch]$NoPause
)

# B1 New Signal alert proof.
#
# Read-only mode checks local channel/flow artifacts and writes a readiness
# packet. With -Apply it creates ONE synthetic CRM signal after a typed approval,
# then captures operator-observed Teams evidence. It does not send external
# messages, change permissions, create guests, grant consent, delete records,
# update CRM records, or call QUO.

$ErrorActionPreference = "Stop"

$now = Get-Date
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\new-signal-alert"
$formsBuildRoot = Join-Path $workspaceRoot "inventory\forms-build"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = $now.ToString("yyyyMMdd-HHmmss")
$transcriptPath = Join-Path $outputRoot ("new-signal-alert-proof-{0}.log" -f $stamp)
$proofJsonPath = Join-Path $outputRoot ("new-signal-alert-proof-{0}.json" -f $stamp)
$proofMdPath = Join-Path $outputRoot ("new-signal-alert-proof-{0}.md" -f $stamp)
$channelEvidencePath = Join-Path $formsBuildRoot "new-signal-teams-channel.json"
$flowEvidencePath = Join-Path $formsBuildRoot "flow-result-new-signal-teams.json"

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

function Read-JsonFileOrNull {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Get-ClaimValue {
    param([object]$Token, [string]$Name)
    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-ExpectedUser {
    param([string]$TargetSiteUrl)
    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-ClaimValue -Token $token -Name "preferred_username"
    }
    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-NewSignalPnP {
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is not available in this PowerShell host."
    }
    Import-Module PnP.PowerShell -ErrorAction Stop

    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $GuidedSiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{
            Url          = $GuidedSiteUrl
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
    Write-Host ("Connected to {0} using {1}" -f $GuidedSiteUrl, $connection.ConnectionType) -ForegroundColor Gray
    Assert-ExpectedUser -TargetSiteUrl $GuidedSiteUrl
}

function Get-ListItemLink {
    param([object]$List, [int]$Id)
    $siteUri = [uri]$GuidedSiteUrl
    $authority = $siteUri.GetLeftPart([System.UriPartial]::Authority)
    $listPath = $null
    if ($null -ne $List.RootFolder -and -not [string]::IsNullOrWhiteSpace($List.RootFolder.ServerRelativeUrl)) {
        $listPath = $List.RootFolder.ServerRelativeUrl
    }
    if ([string]::IsNullOrWhiteSpace($listPath)) {
        $listPath = "/sites/GuidedAILabs/Lists/CRM%20%20New%20Signals"
    }
    $listPath = $listPath -replace ' ', '%20'
    return ("{0}{1}/DispForm.aspx?ID={2}" -f $authority, $listPath, $Id)
}

function Get-FVText {
    param([object]$Item, [string]$Name)
    if ($null -eq $Item -or -not $Item.FieldValues.ContainsKey($Name)) { return "" }
    $value = $Item.FieldValues[$Name]
    if ($null -eq $value) { return "" }
    $text = [string]$value
    $text = ($text -replace '<[^>]+>', ' ')
    $text = ($text -replace '&nbsp;', ' ')
    return $text.Trim()
}

function Get-FVDateText {
    param([object]$Item, [string]$Name)
    if ($null -eq $Item -or -not $Item.FieldValues.ContainsKey($Name)) { return "" }
    $value = $Item.FieldValues[$Name]
    if ($null -eq $value) { return "" }
    try {
        return ([datetime]$value).ToString("o")
    }
    catch {
        return ([string]$value)
    }
}

function Add-SyntheticSignal {
    param([object]$List)

    Write-Host ""
    Write-Host "This will create ONE internal synthetic CRM signal for the B1 Teams alert proof." -ForegroundColor Yellow
    Write-Host "No external message will be sent. The item is only to trigger the internal New Signal Teams alert." -ForegroundColor Yellow
    $confirm = Read-Host "Type 'create-new-signal-proof-item' to create it now (anything else aborts)"
    if ($confirm -ne "create-new-signal-proof-item") {
        throw "B1 synthetic CRM signal creation was not approved."
    }

    $title = "B1 New Signal Teams alert proof $stamp"
    $values = @{
        Title            = $title
        PersonName       = "B1 Internal Proof"
        PersonEmail      = "new-signal-proof@example.invalid"
        OrganizationName = "Guided AI Labs internal proof"
        SignalType       = "Website"
        IntakeSource     = "Direct"
        Priority         = "High"
        SignalStatus     = "New"
        NeedSummary      = "Internal proof that a CRM - New Signals create produces exactly one internal Teams alert."
        SourceText       = "Created by scripts/Invoke-M365NewSignalAlertProof.ps1. No external response, phone action, or prospect commitment is authorized."
        NextAction       = "Confirm exactly one Teams post in Guided AI Labs / New Signal with a CRM item link; then run B2 triage against this item if useful."
    }

    $created = Add-PnPListItem -List $ListTitle -Values $values
    Start-Sleep -Seconds 2
    return (Get-PnPListItem -List $ListTitle -Id $created.Id)
}

function Read-OperatorEvidence {
    param([string]$Title)

    if (-not [string]::IsNullOrWhiteSpace($OperatorEvidenceJson)) {
        if (-not (Test-Path -LiteralPath $OperatorEvidenceJson)) {
            throw "Operator evidence JSON was not found: $OperatorEvidenceJson"
        }
        $loaded = Get-Content -LiteralPath $OperatorEvidenceJson -Raw | ConvertFrom-Json
        $postCount = $null
        if ($null -ne $loaded.postCount) {
            [int]$parsedPostCount = 0
            if ([int]::TryParse([string]$loaded.postCount, [ref]$parsedPostCount)) {
                $postCount = $parsedPostCount
            }
        }
        $hasCrmLink = ($loaded.crmLinkPresent -eq $true -or ([string]$loaded.crmLinkPresent) -match '^(y|yes|true)$')
        $status = [string]$loaded.status
        if ([string]::IsNullOrWhiteSpace($status)) {
            if ($null -eq $postCount) {
                $status = "incomplete"
            }
            elseif ($postCount -eq 1 -and $hasCrmLink) {
                $status = "pass"
            }
            else {
                $status = "fail"
            }
        }
        return [ordered]@{
            captured = $true
            status = $status
            postCount = $postCount
            crmLinkPresent = $hasCrmLink
            teamsPostTime = [string]$loaded.teamsPostTime
            teamsPostLink = [string]$loaded.teamsPostLink
            flowRunStatus = [string]$loaded.flowRunStatus
            notes = [string]$loaded.notes
            evidenceSource = "operator-evidence-json"
            evidenceJsonPath = $OperatorEvidenceJson
            webEvidenceTextPath = [string]$loaded.webEvidenceTextPath
            webEvidenceScreenshotPath = [string]$loaded.webEvidenceScreenshotPath
        }
    }

    if ($SkipOperatorEvidence) {
        return [ordered]@{
            captured = $false
            reason = "Skipped by -SkipOperatorEvidence"
        }
    }

    Write-Host ""
    Write-Host "Open Teams channel Guided AI Labs / New Signal and search for this proof title:" -ForegroundColor Yellow
    Write-Host ("  {0}" -f $Title) -ForegroundColor Gray
    Write-Host "Capture what you see. This script records evidence only; it does not read Teams messages or request extra Graph scopes." -ForegroundColor Yellow

    $postCountText = Read-Host "How many Teams posts for this exact proof title?"
    $crmLinkAnswer = Read-Host "Does the Teams post include a CRM item link? (Y/N)"
    $teamsPostTime = Read-Host "Teams post time observed (blank if not posted)"
    $teamsPostLink = Read-Host "Teams post link or channel URL (optional)"
    $flowRunStatus = Read-Host "Power Automate run status, if checked (optional)"
    $notes = Read-Host "Duplicate/error notes (optional)"

    $postCount = $null
    if (-not [string]::IsNullOrWhiteSpace($postCountText)) {
        [int]$parsedPostCount = 0
        if ([int]::TryParse($postCountText, [ref]$parsedPostCount)) {
            $postCount = $parsedPostCount
        }
    }

    $hasCrmLink = ($crmLinkAnswer -match '^(y|yes)$')
    $status = "operator-captured"
    if ($null -eq $postCount) {
        $status = "incomplete"
    }
    elseif ($postCount -eq 1 -and $hasCrmLink) {
        $status = "pass"
    }
    else {
        $status = "fail"
    }

    return [ordered]@{
        captured = $true
        status = $status
        postCount = $postCount
        crmLinkPresent = $hasCrmLink
        teamsPostTime = $teamsPostTime
        teamsPostLink = $teamsPostLink
        flowRunStatus = $flowRunStatus
        notes = $notes
    }
}

Write-Host "B1 - New Signal Teams alert proof" -ForegroundColor Cyan
Write-Host ("Mode:       {0}" -f $(if ($Apply) { "APPLY: create one synthetic CRM signal after typed approval" } elseif ($ItemId -gt 0) { "READ: capture proof for existing CRM signal #$ItemId" } else { "READINESS: local artifact check only" })) -ForegroundColor Gray
Write-Host ("Output:     {0}" -f $proofMdPath) -ForegroundColor Gray
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
Write-Host "Safety:     Internal CRM/Teams proof only. No external send, permission change, guest/share change, delete, or QUO action." -ForegroundColor Gray

Write-Section "Local B1 artifacts"
$channelEvidence = Read-JsonFileOrNull -Path $channelEvidencePath
$flowEvidence = Read-JsonFileOrNull -Path $flowEvidencePath

if ($null -eq $channelEvidence) {
    Write-Host ("MISSING: {0}" -f $channelEvidencePath) -ForegroundColor Yellow
}
else {
    Write-Host ("PASS: channel evidence found: {0} / {1}" -f $channelEvidence.teamDisplayName, $channelEvidence.channelDisplayName) -ForegroundColor Green
}

if ($null -eq $flowEvidence) {
    Write-Host ("MISSING: {0}" -f $flowEvidencePath) -ForegroundColor Yellow
}
else {
    Write-Host ("PASS: flow evidence found: {0} ({1})" -f $flowEvidence.displayName, $flowEvidence.state) -ForegroundColor Green
}

$connectRequired = ($Apply -or $ItemId -gt 0)
$listEvidence = $null
$signalEvidence = $null
$operatorEvidence = $null

if ($connectRequired) {
    Write-Section "Connect to CRM"
    Connect-NewSignalPnP
    $list = Get-PnPList -Identity $ListTitle -Includes RootFolder, Id
    $listEvidence = [ordered]@{
        title = $list.Title
        id = [string]$list.Id
        rootFolder = [string]$list.RootFolder.ServerRelativeUrl
    }
    Write-Host ("PASS: list found: {0} ({1})" -f $list.Title, $list.Id) -ForegroundColor Green

    if ($null -ne $flowEvidence -and -not [string]::IsNullOrWhiteSpace([string]$flowEvidence.listId)) {
        if ([string]$flowEvidence.listId -eq [string]$list.Id) {
            Write-Host "PASS: flow evidence list id matches live CRM list id." -ForegroundColor Green
        }
        else {
            Write-Host ("WARN: flow evidence list id {0} does not match live CRM list id {1}." -f $flowEvidence.listId, $list.Id) -ForegroundColor Yellow
        }
    }

    Write-Section "CRM proof item"
    $item = $null
    if ($Apply) {
        $item = Add-SyntheticSignal -List $list
    }
    else {
        $item = Get-PnPListItem -List $ListTitle -Id $ItemId
    }

    $itemTitle = Get-FVText -Item $item -Name "Title"
    $itemLink = Get-ListItemLink -List $list -Id $item.Id
    $signalEvidence = [ordered]@{
        itemId = $item.Id
        title = $itemTitle
        created = Get-FVDateText -Item $item -Name "Created"
        modified = Get-FVDateText -Item $item -Name "Modified"
        priority = Get-FVText -Item $item -Name "Priority"
        signalType = Get-FVText -Item $item -Name "SignalType"
        intakeSource = Get-FVText -Item $item -Name "IntakeSource"
        itemLink = $itemLink
    }
    Write-Host ("PASS: proof signal available: #{0} {1}" -f $item.Id, $itemTitle) -ForegroundColor Green
    Write-Host ("CRM item: {0}" -f $itemLink) -ForegroundColor Gray

    $operatorEvidence = Read-OperatorEvidence -Title $itemTitle
}

$overallStatus = "readiness-only"
if ($connectRequired) {
    if ($null -eq $operatorEvidence) {
        $overallStatus = "no-operator-evidence"
    }
    elseif ($operatorEvidence.status -eq "pass") {
        $overallStatus = "pass"
    }
    elseif ($operatorEvidence.status -eq "fail") {
        $overallStatus = "fail"
    }
    elseif ($operatorEvidence.captured -eq $false) {
        $overallStatus = "pending-operator-evidence"
    }
    else {
        $overallStatus = "incomplete"
    }
}

$proof = [ordered]@{
    purpose = "B1 New Signal Teams alert proof"
    generatedAt = (Get-Date).ToString("o")
    status = $overallStatus
    mode = $(if ($Apply) { "apply" } elseif ($ItemId -gt 0) { "existing-item" } else { "readiness" })
    safety = "Internal CRM/Teams proof only; no external messages or permission changes."
    channelEvidencePath = $channelEvidencePath
    channelEvidence = $channelEvidence
    flowEvidencePath = $flowEvidencePath
    flowEvidence = $flowEvidence
    listEvidence = $listEvidence
    signalEvidence = $signalEvidence
    operatorEvidence = $operatorEvidence
    transcript = $transcriptPath
}

$proof | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $proofJsonPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# B1 New Signal Teams Alert Proof")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm")))
$lines.Add(("Status: {0}" -f $overallStatus))
$lines.Add("")
$lines.Add("## Local Artifacts")
$lines.Add("")
$lines.Add(("- Channel evidence: {0}" -f $(if ($null -ne $channelEvidence) { $channelEvidencePath } else { "MISSING - $channelEvidencePath" })))
$lines.Add(("- Flow evidence: {0}" -f $(if ($null -ne $flowEvidence) { $flowEvidencePath } else { "MISSING - $flowEvidencePath" })))
$lines.Add("")
if ($null -ne $signalEvidence) {
    $lines.Add("## CRM Proof Item")
    $lines.Add("")
    $lines.Add(("- Item: #{0} - {1}" -f $signalEvidence.itemId, $signalEvidence.title))
    $lines.Add(("- Created: {0}" -f $signalEvidence.created))
    $lines.Add(("- CRM link: {0}" -f $signalEvidence.itemLink))
    $lines.Add("")
}
if ($null -ne $operatorEvidence) {
    $lines.Add("## Teams Evidence")
    $lines.Add("")
    if ($operatorEvidence.captured -eq $false) {
        $lines.Add(("- Evidence capture: {0}" -f $operatorEvidence.reason))
    }
    else {
        $lines.Add(("- Teams posts observed: {0}" -f $operatorEvidence.postCount))
        $lines.Add(("- CRM link present: {0}" -f $operatorEvidence.crmLinkPresent))
        $lines.Add(("- Teams post time: {0}" -f $operatorEvidence.teamsPostTime))
        $lines.Add(("- Teams post link: {0}" -f $operatorEvidence.teamsPostLink))
        $lines.Add(("- Flow run status: {0}" -f $operatorEvidence.flowRunStatus))
        $lines.Add(("- Notes: {0}" -f $operatorEvidence.notes))
        if (-not [string]::IsNullOrWhiteSpace([string]$operatorEvidence.evidenceJsonPath)) {
            $lines.Add(("- Evidence JSON: {0}" -f $operatorEvidence.evidenceJsonPath))
        }
        if (-not [string]::IsNullOrWhiteSpace([string]$operatorEvidence.webEvidenceTextPath)) {
            $lines.Add(("- Web evidence text: {0}" -f $operatorEvidence.webEvidenceTextPath))
        }
        if (-not [string]::IsNullOrWhiteSpace([string]$operatorEvidence.webEvidenceScreenshotPath)) {
            $lines.Add(("- Web evidence screenshot: {0}" -f $operatorEvidence.webEvidenceScreenshotPath))
        }
    }
    $lines.Add("")
}
$lines.Add("## Boundary")
$lines.Add("")
$lines.Add("- No external/prospect notification.")
$lines.Add("- No CRM update beyond the optional one synthetic create in -Apply mode.")
$lines.Add("- No permission, sharing, guest, app registration, consent, delete, billing, or QUO action.")
$lines.Add("- CRM remains the source of truth; Teams is the attention surface.")
$lines.Add("")
$lines.Add(("JSON evidence: {0}" -f $proofJsonPath))
$lines.Add(("Transcript: {0}" -f $transcriptPath))
Set-Content -LiteralPath $proofMdPath -Value $lines -Encoding UTF8

Write-Section "Done"
Write-Host ("Proof markdown: {0}" -f $proofMdPath) -ForegroundColor Green
Write-Host ("Proof JSON:     {0}" -f $proofJsonPath) -ForegroundColor Green
Write-Host ("Status:         {0}" -f $overallStatus) -ForegroundColor $(if ($overallStatus -eq "pass") { "Green" } elseif ($overallStatus -eq "fail") { "Red" } else { "Yellow" })

try {
    Stop-Transcript | Out-Null
}
catch {}
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
