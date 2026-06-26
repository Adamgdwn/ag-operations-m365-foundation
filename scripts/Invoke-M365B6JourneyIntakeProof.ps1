param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$ListTitle = "CRM - New Signals",
    [ValidateSet("DirectMicrosoftForm", "JourneyWebsiteCta", "ClientInviteMessage", "CustomWebsiteForm")]
    [string]$EntryPoint = "DirectMicrosoftForm",
    [string]$Marker = "GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY",
    [int]$LookbackHours = 24,
    [switch]$Verify,
    [switch]$RunTriage,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# B6 - Guided AI Journey intake proof helper.
#
# Default mode is local prep only: it reads local evidence, emits the exact dummy
# values Adam can submit through the chosen entry point, and records a local proof
# packet. Verify mode connects to SharePoint read-only and looks for the created
# CRM - New Signals item. This script has no tenant write path. The only CRM write
# in B6 is the manual/client-style form submission through the already existing
# create-only intake flow.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b6"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$flowEvidencePath = Join-Path $workspaceRoot "inventory\forms-build\flow-result-journey.json"
$formUrlPacketPath = Join-Path $workspaceRoot "inventory\forms-build\STAGED__WINDOWS_TO_LINUX__journey-intake-form-url.json"
$intentPacketPath = Join-Path $workspaceRoot "inventory\forms-build\STAGED__WINDOWS_TO_LINUX__crm-intake-intent-live.json"
$customSpecPath = Join-Path $workspaceRoot "inventory\forms-build\RELEASED__WINDOWS_TO_JOURNEY__custom-intake-form-spec.json"
$b5EvidencePath = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b5\b5-interaction-agent-decision-20260625-175449.json"
$triageScriptPath = Join-Path $workspaceRoot "scripts\Invoke-M365NewSignalTriage.ps1"

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $outputRoot ("b6-journey-intake-proof-{0}.log" -f $stamp)
$summaryPath = Join-Path $outputRoot ("b6-journey-intake-proof-{0}.json" -f $stamp)
$packetPath = Join-Path $outputRoot ("b6-journey-intake-proof-{0}.md" -f $stamp)

$testEmail = "adam+gail-b6-journey-{0}@guidedailabs.com" -f $stamp
$testNeed = "{0} {1} - verifying Guided AI Journey client invite intake creates one CRM New Signal for M365 Interaction Agent triage." -f $Marker, $stamp
$testHeardFrom = "Internal B6 source proof after B5 Decision Register #6."
$testSituation = "My team - I want to build team capability"

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

function Get-B6PropertyValue {
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

function Get-B6NestedPropertyValue {
    param(
        [object]$Object,
        [string[]]$Path
    )

    $current = $Object
    foreach ($name in $Path) {
        $current = Get-B6PropertyValue -Object $current -Name $name
        if ($null -eq $current) { return $null }
    }
    return $current
}

function Read-B6JsonFile {
    param(
        [string]$Path,
        [string]$Label,
        [bool]$Required = $true
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($Required) {
            throw "$Label not found: $Path"
        }
        return $null
    }

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function ConvertTo-B6XmlText {
    param([string]$Value)

    return [System.Security.SecurityElement]::Escape($Value)
}

function ConvertTo-B6Text {
    param([object]$Value)

    if ($null -eq $Value) { return "" }
    if ($Value -is [array]) {
        return (@($Value | ForEach-Object { ConvertTo-B6Text -Value $_ }) -join "; ")
    }
    if ($Value -is [datetime]) {
        return $Value.ToString("o")
    }

    foreach ($propertyName in @("LookupValue", "Email", "Title", "Url", "Description")) {
        $property = $Value.PSObject.Properties[$propertyName]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [string]$property.Value
        }
    }

    return [string]$Value
}

function Get-B6FieldText {
    param(
        [object]$Fields,
        [string]$Name
    )

    return (ConvertTo-B6Text -Value (Get-B6PropertyValue -Object $Fields -Name $Name))
}

function Get-B6ClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-B6ExpectedUser {
    param([string]$TargetSiteUrl)

    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-B6ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-B6ClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-B6PnP {
    param([string]$TargetSiteUrl)

    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is not available in this PowerShell host. Use scripts\Start-M365B6JourneyIntakeProofInteractive.ps1 or install the module before running verification."
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
    Assert-B6ExpectedUser -TargetSiteUrl $TargetSiteUrl

    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function Get-B6ListItemLink {
    param(
        [object]$List,
        [int]$Id
    )

    $siteUri = [uri]$SiteUrl
    $authority = $siteUri.GetLeftPart([System.UriPartial]::Authority)
    $listPath = $null
    if ($null -ne $List -and $null -ne $List.RootFolder -and -not [string]::IsNullOrWhiteSpace($List.RootFolder.ServerRelativeUrl)) {
        $listPath = $List.RootFolder.ServerRelativeUrl
    }
    if ([string]::IsNullOrWhiteSpace($listPath)) {
        $listPath = "/sites/GuidedAILabs/Lists/CRM%20%20New%20Signals"
    }
    $listPath = $listPath -replace ' ', '%20'
    return ("{0}{1}/DispForm.aspx?ID={2}" -f $authority, $listPath, $Id)
}

function ConvertTo-B6Signal {
    param(
        [object]$Item,
        [object]$List
    )

    $fields = $Item.FieldValues
    $link = Get-B6ListItemLink -List $List -Id $Item.Id
    return [pscustomobject][ordered]@{
        Id = $Item.Id
        Title = Get-B6FieldText -Fields $fields -Name "Title"
        PersonName = Get-B6FieldText -Fields $fields -Name "PersonName"
        PersonEmail = Get-B6FieldText -Fields $fields -Name "PersonEmail"
        OrganizationName = Get-B6FieldText -Fields $fields -Name "OrganizationName"
        SignalType = Get-B6FieldText -Fields $fields -Name "SignalType"
        IntakeSource = Get-B6FieldText -Fields $fields -Name "IntakeSource"
        IntentPath = Get-B6FieldText -Fields $fields -Name "IntentPath"
        Priority = Get-B6FieldText -Fields $fields -Name "Priority"
        SignalStatus = Get-B6FieldText -Fields $fields -Name "SignalStatus"
        NeedSummary = Get-B6FieldText -Fields $fields -Name "NeedSummary"
        SourceText = Get-B6FieldText -Fields $fields -Name "SourceText"
        NextAction = Get-B6FieldText -Fields $fields -Name "NextAction"
        Created = Get-B6FieldText -Fields $fields -Name "Created"
        Modified = Get-B6FieldText -Fields $fields -Name "Modified"
        ItemLink = $link
    }
}

function Test-B6MarkerMatch {
    param(
        [object]$Signal,
        [string]$Text
    )

    $haystack = @(
        $Signal.Title,
        $Signal.PersonName,
        $Signal.PersonEmail,
        $Signal.OrganizationName,
        $Signal.NeedSummary,
        $Signal.SourceText,
        $Signal.NextAction
    ) -join "`n"

    return ($haystack -like ("*" + $Text + "*"))
}

function Get-B6JourneyCandidates {
    param(
        [object]$List,
        [string]$SearchMarker
    )

    $escapedSource = ConvertTo-B6XmlText -Value "Guided AI Journey"
    $query = @"
<View>
  <Query>
    <Where>
      <Eq>
        <FieldRef Name='IntakeSource' />
        <Value Type='Choice'>$escapedSource</Value>
      </Eq>
    </Where>
    <OrderBy>
      <FieldRef Name='Created' Ascending='FALSE' />
    </OrderBy>
  </Query>
  <RowLimit>50</RowLimit>
</View>
"@

    $items = @(Get-PnPListItem -List $ListTitle -Query $query -ErrorAction Stop)
    $cutoff = (Get-Date).AddHours(-1 * [math]::Abs($LookbackHours))
    $signals = New-Object System.Collections.Generic.List[object]

    foreach ($item in $items) {
        $signal = ConvertTo-B6Signal -Item $item -List $List
        $created = $null
        if (-not [string]::IsNullOrWhiteSpace($signal.Created)) {
            $parsedCreated = [datetime]::MinValue
            if ([datetime]::TryParse([string]$signal.Created, [ref]$parsedCreated)) {
                $created = $parsedCreated
            }
        }
        $withinWindow = ($null -eq $created -or $created -ge $cutoff)
        if ($withinWindow -and (Test-B6MarkerMatch -Signal $signal -Text $SearchMarker)) {
            $signals.Add($signal) | Out-Null
        }
    }

    return @($signals.ToArray())
}

function Test-B6SignalShape {
    param([object]$Signal)

    $checks = New-Object System.Collections.Generic.List[object]
    $checks.Add([pscustomobject][ordered]@{ name = "IntakeSource"; expected = "Guided AI Journey"; actual = $Signal.IntakeSource; pass = ($Signal.IntakeSource -eq "Guided AI Journey") }) | Out-Null
    $checks.Add([pscustomobject][ordered]@{ name = "SignalType"; expected = "Website"; actual = $Signal.SignalType; pass = ($Signal.SignalType -eq "Website") }) | Out-Null
    $checks.Add([pscustomobject][ordered]@{ name = "SignalStatus"; expected = "New"; actual = $Signal.SignalStatus; pass = ($Signal.SignalStatus -eq "New") }) | Out-Null
    $checks.Add([pscustomobject][ordered]@{ name = "Priority"; expected = "Normal"; actual = $Signal.Priority; pass = ($Signal.Priority -eq "Normal") }) | Out-Null
    $checks.Add([pscustomobject][ordered]@{ name = "Marker"; expected = $Marker; actual = $(if (Test-B6MarkerMatch -Signal $Signal -Text $Marker) { "found" } else { "missing" }); pass = (Test-B6MarkerMatch -Signal $Signal -Text $Marker) }) | Out-Null
    $checks.Add([pscustomobject][ordered]@{ name = "NeedSummary"; expected = "not blank"; actual = $(if ([string]::IsNullOrWhiteSpace($Signal.NeedSummary)) { "blank" } else { "present" }); pass = (-not [string]::IsNullOrWhiteSpace($Signal.NeedSummary)) }) | Out-Null

    return @($checks.ToArray())
}

function Get-B6EntryPointLabel {
    param([string]$Name)

    switch ($Name) {
        "DirectMicrosoftForm" { return "Direct Journey Microsoft Form link" }
        "JourneyWebsiteCta" { return "Guided AI Journey website CTA or embed" }
        "ClientInviteMessage" { return "Client invite message that points to the Journey intake" }
        "CustomWebsiteForm" { return "Guided AI Journey custom branded website form" }
    }
}

function Add-B6LineValue {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Label,
        [object]$Value
    )

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) { $text = "(blank)" }
    $Lines.Add(("- {0}: {1}" -f $Label, $text))
}

function Write-B6Packet {
    param(
        [object]$Summary,
        [object]$FoundSignal = $null,
        [object[]]$Checks = @()
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# B6 Guided AI Journey Intake Proof")
    $lines.Add("")
    Add-B6LineValue -Lines $lines -Label "Generated" -Value $Summary.generatedAt
    Add-B6LineValue -Lines $lines -Label "Mode" -Value $Summary.mode
    Add-B6LineValue -Lines $lines -Label "Entry point" -Value $Summary.entryPointLabel
    Add-B6LineValue -Lines $lines -Label "Safety" -Value $Summary.safety
    $lines.Add("")
    $lines.Add("## Local Evidence")
    Add-B6LineValue -Lines $lines -Label "B5 evidence" -Value $Summary.b5Evidence.status
    Add-B6LineValue -Lines $lines -Label "Journey flow" -Value $Summary.flow.displayName
    Add-B6LineValue -Lines $lines -Label "Journey flow state" -Value $Summary.flow.state
    Add-B6LineValue -Lines $lines -Label "Target list id" -Value $Summary.flow.listId
    Add-B6LineValue -Lines $lines -Label "Microsoft Form URL" -Value $Summary.form.publicUrl
    Add-B6LineValue -Lines $lines -Label "Custom form contract" -Value $Summary.customForm.status
    $lines.Add("")
    $lines.Add("## Dummy Submission Values")
    Add-B6LineValue -Lines $lines -Label "Full name" -Value $Summary.testSubmission.fullName
    Add-B6LineValue -Lines $lines -Label "Email" -Value $Summary.testSubmission.email
    Add-B6LineValue -Lines $lines -Label "Organization" -Value $Summary.testSubmission.organization
    Add-B6LineValue -Lines $lines -Label "What are you looking for" -Value $Summary.testSubmission.needSummary
    Add-B6LineValue -Lines $lines -Label "What best describes your situation" -Value $Summary.testSubmission.situation
    Add-B6LineValue -Lines $lines -Label "How did you hear about us" -Value $Summary.testSubmission.heardFrom
    Add-B6LineValue -Lines $lines -Label "Consent" -Value $Summary.testSubmission.consent
    $lines.Add("")
    $lines.Add("## Verify After Manual Submission")
    $lines.Add("")
    $lines.Add('```powershell')
    $lines.Add(".\scripts\Start-M365B6JourneyIntakeProofInteractive.ps1 -Verify -ForceFreshLogin")
    $lines.Add('```')
    $lines.Add("")
    $lines.Add("This verification reads CRM only. It does not write a CRM item, Agent Action Log row, Teams message, task, email, permission, app, guest, sharing setting, or tenant policy.")

    if ($null -ne $FoundSignal) {
        $lines.Add("")
        $lines.Add("## Verification Result")
        Add-B6LineValue -Lines $lines -Label "CRM item" -Value ("#{0}" -f $FoundSignal.Id)
        Add-B6LineValue -Lines $lines -Label "Title" -Value $FoundSignal.Title
        Add-B6LineValue -Lines $lines -Label "CRM link" -Value $FoundSignal.ItemLink
        Add-B6LineValue -Lines $lines -Label "IntakeSource" -Value $FoundSignal.IntakeSource
        Add-B6LineValue -Lines $lines -Label "SignalStatus" -Value $FoundSignal.SignalStatus
        Add-B6LineValue -Lines $lines -Label "IntentPath" -Value $FoundSignal.IntentPath
        $lines.Add("")
        $lines.Add("Checks:")
        foreach ($check in $Checks) {
            $status = if ($check.pass) { "PASS" } else { "FAIL" }
            $lines.Add(("- {0}: {1} (expected {2}; actual {3})" -f $status, $check.name, $check.expected, $check.actual))
        }
        $lines.Add("")
        $lines.Add("Read-only triage command:")
        $lines.Add("")
        $lines.Add('```powershell')
        $lines.Add((".\scripts\Invoke-M365NewSignalTriage.ps1 -ItemId {0} -NoPause" -f $FoundSignal.Id))
        $lines.Add('```')
    }

    $lines | Set-Content -LiteralPath $packetPath -Encoding UTF8
}

try {
    Write-Host "B6 - Guided AI Journey intake proof helper" -ForegroundColor Cyan
    Write-Host ("Site:       {0}" -f $SiteUrl) -ForegroundColor Gray
    Write-Host ("Entry:      {0}" -f (Get-B6EntryPointLabel -Name $EntryPoint)) -ForegroundColor Gray
    Write-Host ("Marker:     {0}" -f $Marker) -ForegroundColor Gray
    Write-Host ("Packet:     {0}" -f $packetPath) -ForegroundColor Gray
    Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
    Write-Host ("Mode:       {0}" -f $(if ($Verify) { "VERIFY: read CRM only" } else { "LOCAL PREP: no Microsoft 365 connection" })) -ForegroundColor Gray
    Write-Host "Writes:     None by this script. Manual form submission is the only B6 source-ingress write." -ForegroundColor Gray

    if ($RunTriage -and -not $Verify) {
        throw "-RunTriage requires -Verify so the CRM item can be found first."
    }

    Write-Section "Read local B6 evidence"
    $flowEvidence = Read-B6JsonFile -Path $flowEvidencePath -Label "Journey flow evidence"
    $formPacket = Read-B6JsonFile -Path $formUrlPacketPath -Label "Journey form URL packet"
    $intentPacket = Read-B6JsonFile -Path $intentPacketPath -Label "Intent field packet" -Required $false
    $customSpec = Read-B6JsonFile -Path $customSpecPath -Label "Custom Journey form spec" -Required $false
    $b5Evidence = Read-B6JsonFile -Path $b5EvidencePath -Label "B5 live evidence" -Required $false

    $publicUrl = [string](Get-B6NestedPropertyValue -Object $formPacket -Path @("formToWireIn", "publicUrl"))
    $embedUrl = [string](Get-B6NestedPropertyValue -Object $formPacket -Path @("formToWireIn", "embedUrl"))
    if ([string]::IsNullOrWhiteSpace($publicUrl)) {
        $publicUrl = [string](Get-B6PropertyValue -Object (Read-B6JsonFile -Path (Join-Path $workspaceRoot "inventory\forms-build\result-journey.json") -Label "Journey form result") -Name "publicUrl")
    }

    $customStatus = ""
    if ($null -ne $customSpec) {
        $customStatus = [string](Get-B6PropertyValue -Object $customSpec -Name "status")
    }
    if ([string]::IsNullOrWhiteSpace($customStatus)) {
        $customStatus = "not selected for this proof"
    }

    $b5Status = "not found locally"
    if ($null -ne $b5Evidence) {
        $records = @($b5Evidence.records | ForEach-Object { "{0} #{1}" -f $_.list, $_.itemId })
        $b5Status = "recorded: {0}" -f ($records -join "; ")
    }

    Write-Host ("PASS: Journey flow evidence loaded ({0}, state {1})" -f $flowEvidence.displayName, $flowEvidence.state) -ForegroundColor Green
    Write-Host ("PASS: Journey form URL loaded") -ForegroundColor Green
    if ($null -ne $intentPacket) {
        Write-Host "PASS: IntentPath packet loaded" -ForegroundColor Green
    }
    if ($null -ne $customSpec) {
        Write-Host "PASS: custom website form contract is present locally" -ForegroundColor Green
    }

    $summary = [ordered]@{
        generatedAt = (Get-Date).ToString("o")
        mode = $(if ($Verify) { "verify-read-only" } else { "local-prep" })
        siteUrl = $SiteUrl
        expectedUpn = $ExpectedUpn
        entryPoint = $EntryPoint
        entryPointLabel = Get-B6EntryPointLabel -Name $EntryPoint
        marker = $Marker
        safety = "No tenant write is performed by this script. B6 live source proof requires a manual/client-style form submission through an existing create-only intake path."
        b5Evidence = [ordered]@{
            path = $b5EvidencePath
            status = $b5Status
        }
        flow = [ordered]@{
            evidencePath = $flowEvidencePath
            brand = [string]$flowEvidence.brand
            displayName = [string]$flowEvidence.displayName
            flowName = [string]$flowEvidence.flowName
            formId = [string]$flowEvidence.formId
            listId = [string]$flowEvidence.listId
            state = [string]$flowEvidence.state
        }
        form = [ordered]@{
            packetPath = $formUrlPacketPath
            publicUrl = $publicUrl
            embedUrl = $embedUrl
        }
        customForm = [ordered]@{
            specPath = $customSpecPath
            status = $customStatus
            note = "Endpoint URL and secret are intentionally not committed. Use only server-side website secrets if this entry point is selected."
        }
        testSubmission = [ordered]@{
            fullName = $Marker
            email = $testEmail
            organization = "Guided AI Labs Internal Walkthrough"
            needSummary = $testNeed
            situation = $testSituation
            heardFrom = $testHeardFrom
            consent = "I agree"
        }
        verification = $null
        output = [ordered]@{
            packetPath = $packetPath
            summaryPath = $summaryPath
            transcriptPath = $transcriptPath
        }
    }

    $foundSignal = $null
    $checks = @()

    if ($Verify) {
        Write-Section "Connect"
        Connect-B6PnP -TargetSiteUrl $SiteUrl

        Write-Section "Verify target list"
        $list = Get-PnPList -Identity $ListTitle -Includes RootFolder,Id,Title -ErrorAction Stop
        Write-Host ("PASS: list found: {0} ({1})" -f $list.Title, $list.Id) -ForegroundColor Green
        if ([string]$flowEvidence.listId -and ([string]$list.Id -ne [string]$flowEvidence.listId)) {
            Write-Host ("WARN: local flow evidence list id is {0}; live list id is {1}" -f $flowEvidence.listId, $list.Id) -ForegroundColor Yellow
        }

        Write-Section "Find Journey proof signal"
        $candidates = @(Get-B6JourneyCandidates -List $list -SearchMarker $Marker)
        if ($candidates.Count -eq 0) {
            throw "No Guided AI Journey CRM signal containing marker '$Marker' was found in the last $LookbackHours hour(s). Submit the dummy values first, wait for the flow, then rerun verification."
        }

        $foundSignal = $candidates[0]
        $summary["testSubmission"] = [ordered]@{
            fullName = $foundSignal.PersonName
            email = $foundSignal.PersonEmail
            organization = $foundSignal.OrganizationName
            needSummary = $foundSignal.NeedSummary
            situation = $foundSignal.IntentPath
            heardFrom = $testHeardFrom
            consent = "I agree"
        }
        $checks = @(Test-B6SignalShape -Signal $foundSignal)
        Write-Host ("PASS: found CRM - New Signals item #{0}: {1}" -f $foundSignal.Id, $foundSignal.Title) -ForegroundColor Green
        foreach ($check in $checks) {
            $color = if ($check.pass) { "Green" } else { "Red" }
            Write-Host ("  {0}: {1}" -f $(if ($check.pass) { "PASS" } else { "FAIL" }), $check.name) -ForegroundColor $color
        }

        $summary["verification"] = [ordered]@{
            found = $true
            item = $foundSignal
            checks = $checks
            pass = (-not @($checks | Where-Object { -not $_.pass }))
        }

        if ($RunTriage) {
            Write-Section "Run read-only triage"
            if (-not (Test-Path -LiteralPath $triageScriptPath)) {
                throw "Triage script not found: $triageScriptPath"
            }
            $triageArgs = @("-ItemId", [string]$foundSignal.Id, "-NoPause")
            if ($UseDeviceLogin) { $triageArgs += "-UseDeviceLogin" }
            if ($ForceFreshLogin) { $triageArgs += "-ForceFreshLogin" }
            & $triageScriptPath @triageArgs
        }
    }
    else {
        Write-Section "Prepare manual proof"
        Write-Host "Use these dummy values in the selected Journey intake entry point:" -ForegroundColor Yellow
        Write-Host ("  Full name: {0}" -f $Marker) -ForegroundColor Gray
        Write-Host ("  Email: {0}" -f $testEmail) -ForegroundColor Gray
        Write-Host ("  Organization: Guided AI Labs Internal Walkthrough") -ForegroundColor Gray
        Write-Host ("  Need: {0}" -f $testNeed) -ForegroundColor Gray
        Write-Host ("  Situation: {0}" -f $testSituation) -ForegroundColor Gray
        Write-Host ("  Heard from: {0}" -f $testHeardFrom) -ForegroundColor Gray
        Write-Host ("  Microsoft Form URL: {0}" -f $publicUrl) -ForegroundColor Gray
        if ($EntryPoint -eq "CustomWebsiteForm") {
            Write-Host "  Custom form endpoint and secret are not committed; use the website backend route, not browser-side secrets." -ForegroundColor Yellow
        }
    }

    Write-Section "Write local summary"
    Write-B6Packet -Summary ([pscustomobject]$summary) -FoundSignal $foundSignal -Checks $checks
    $summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $summaryPath -Encoding UTF8
    Write-Host ("Packet markdown: {0}" -f $packetPath) -ForegroundColor Green
    Write-Host ("Summary JSON:     {0}" -f $summaryPath) -ForegroundColor Green

    Write-Section "Done"
    if ($Verify) {
        Write-Host "B6 verification complete. No tenant write was performed by this script." -ForegroundColor Green
    }
    else {
        Write-Host "B6 proof packet prepared. Manual form submission is still the approval boundary." -ForegroundColor Green
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
