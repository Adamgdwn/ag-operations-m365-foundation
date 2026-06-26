param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$GuidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$ListTitle = "CRM - New Signals",
    [string]$ActionLogListTitle = "Agent Action Log",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [int]$ItemId = 0,
    [switch]$Newest,
    [string]$InputJson = "",
    [string]$RelatedRecordsJson = "",
    [bool]$IncludeSimilar = $true,
    [int]$MaxRelatedCandidates = 8,
    [switch]$Apply,
    [switch]$Approve,
    [switch]$AllowDuplicateSuggestion,
    [switch]$UseDeviceLogin,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# B2/B3/B4 Signal triage lane.
#
# G0 by default: reads one CRM - New Signals item, reasons locally, adds a
# similar-record advisory, and writes markdown/json evidence under
# inventory/new-signal-triage. With -Apply, it can write ONE G1 Suggested row
# to Agent Action Log after confirmation. It does not update CRM records, create
# tasks/reminders, send messages, merge records, or change permissions.

$ErrorActionPreference = "Stop"

$now = Get-Date
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\new-signal-triage"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

$stamp = $now.ToString("yyyyMMdd-HHmmss")
$transcriptPath = Join-Path $outputRoot ("new-signal-triage-{0}.log" -f $stamp)
$packetPath = Join-Path $outputRoot ("new-signal-triage-{0}.md" -f $stamp)
$packetJsonPath = Join-Path $outputRoot ("new-signal-triage-{0}.json" -f $stamp)
$matchJsonPath = Join-Path $outputRoot ("new-signal-match-{0}.json" -f $stamp)

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

function Resolve-UserFieldValue {
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

function Get-PropertyValue {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Collections.IDictionary]) {
        if ($null -ne $Object.PSObject.Methods["ContainsKey"] -and $Object.ContainsKey($Name)) { return $Object[$Name] }
        foreach ($key in $Object.Keys) {
            if ([string]$key -eq $Name) { return $Object[$key] }
        }
        return $null
    }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -ne $prop) { return $prop.Value }
    return $null
}

function ConvertTo-SignalText {
    param([object]$Value)
    if ($null -eq $Value) { return "" }

    $choiceValue = Get-PropertyValue -Object $Value -Name "Value"
    if ($null -ne $choiceValue) { return (ConvertTo-SignalText -Value $choiceValue) }

    $lookupValue = Get-PropertyValue -Object $Value -Name "LookupValue"
    if ($null -ne $lookupValue) { return (ConvertTo-SignalText -Value $lookupValue) }

    $urlValue = Get-PropertyValue -Object $Value -Name "Url"
    if ($null -ne $urlValue) {
        $description = Get-PropertyValue -Object $Value -Name "Description"
        if (-not [string]::IsNullOrWhiteSpace([string]$description)) {
            return ("{0} ({1})" -f $description, $urlValue)
        }
        return [string]$urlValue
    }

    if ($Value -is [array]) {
        return (($Value | ForEach-Object { ConvertTo-SignalText -Value $_ }) -join ", ").Trim()
    }

    $text = [string]$Value
    $text = ($text -replace '<[^>]+>', ' ')
    $text = ($text -replace '&nbsp;', ' ')
    $text = ($text -replace '&amp;', '&')
    $text = ($text -replace '\s+', ' ')
    return $text.Trim()
}

function ConvertTo-IsoDateText {
    param([object]$Value)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { return "" }
    try {
        return ([datetime]$Value).ToString("o")
    }
    catch {
        return (ConvertTo-SignalText -Value $Value)
    }
}

function Get-ListItemLink {
    param([object]$List, [int]$Id)
    $siteUri = [uri]$GuidedSiteUrl
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

function Get-FieldText {
    param([object]$Fields, [string]$Name)
    return (ConvertTo-SignalText -Value (Get-PropertyValue -Object $Fields -Name $Name))
}

function Get-FieldDateText {
    param([object]$Fields, [string]$Name)
    return (ConvertTo-IsoDateText -Value (Get-PropertyValue -Object $Fields -Name $Name))
}

function Get-NormalizedSignalFromFields {
    param(
        [object]$Fields,
        [int]$Id,
        [string]$ItemLink
    )

    $fieldLink = Get-FieldText -Fields $Fields -Name "ItemLink"
    if ([string]::IsNullOrWhiteSpace($ItemLink) -and -not [string]::IsNullOrWhiteSpace($fieldLink)) {
        $ItemLink = $fieldLink
    }

    return [pscustomobject][ordered]@{
        Id = $Id
        Title = Get-FieldText -Fields $Fields -Name "Title"
        PersonName = Get-FieldText -Fields $Fields -Name "PersonName"
        PersonEmail = Get-FieldText -Fields $Fields -Name "PersonEmail"
        OrganizationName = Get-FieldText -Fields $Fields -Name "OrganizationName"
        SignalType = Get-FieldText -Fields $Fields -Name "SignalType"
        IntakeSource = Get-FieldText -Fields $Fields -Name "IntakeSource"
        IntentPath = Get-FieldText -Fields $Fields -Name "IntentPath"
        Priority = Get-FieldText -Fields $Fields -Name "Priority"
        SignalStatus = Get-FieldText -Fields $Fields -Name "SignalStatus"
        NeedSummary = Get-FieldText -Fields $Fields -Name "NeedSummary"
        SourceText = Get-FieldText -Fields $Fields -Name "SourceText"
        NextAction = Get-FieldText -Fields $Fields -Name "NextAction"
        FollowUpDueDate = Get-FieldDateText -Fields $Fields -Name "FollowUpDueDate"
        Created = Get-FieldDateText -Fields $Fields -Name "Created"
        Modified = Get-FieldDateText -Fields $Fields -Name "Modified"
        Owner = Get-FieldText -Fields $Fields -Name "ItemOwner"
        ItemLink = $ItemLink
    }
}

function Get-PnPSignalItem {
    param([object]$List)
    if ($ItemId -gt 0) {
        return (Get-PnPListItem -List $ListTitle -Id $ItemId)
    }

    $query = @"
<View>
  <Query>
    <OrderBy>
      <FieldRef Name='Created' Ascending='FALSE' />
    </OrderBy>
  </Query>
  <RowLimit>1</RowLimit>
</View>
"@
    $items = @(Get-PnPListItem -List $ListTitle -Query $query)
    if ($items.Count -eq 0) {
        throw "No items found in $ListTitle."
    }
    return $items[0]
}

function Get-SignalFromJson {
    param([string]$Path)
    $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    $fields = Get-PropertyValue -Object $json -Name "FieldValues"
    if ($null -eq $fields) { $fields = Get-PropertyValue -Object $json -Name "fields" }
    if ($null -eq $fields) { $fields = $json }

    $idValue = Get-PropertyValue -Object $json -Name "Id"
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $json -Name "ID" }
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $fields -Name "Id" }
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $fields -Name "ID" }
    [int]$id = 0
    if ($null -ne $idValue) { [int]::TryParse([string]$idValue, [ref]$id) | Out-Null }

    $link = Get-FieldText -Fields $fields -Name "ItemLink"
    if ([string]::IsNullOrWhiteSpace($link)) {
        $link = Get-FieldText -Fields $fields -Name "Link"
    }

    return (Get-NormalizedSignalFromFields -Fields $fields -Id $id -ItemLink $link)
}

function Normalize-CompareText {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    $normalized = $Text.ToLowerInvariant()
    $normalized = $normalized -replace '&amp;', ' and '
    $normalized = $normalized -replace '\b(the|inc|ltd|llc|corp|corporation|company|co|limited|plc|group)\b', ' '
    $normalized = $normalized -replace '[^a-z0-9@.\s-]', ' '
    $normalized = $normalized -replace '\s+', ' '
    return $normalized.Trim()
}

function Normalize-DomainText {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return "" }
    $domain = $Value.ToLowerInvariant().Trim()
    if ($domain -match '@([^>\s,;]+)$') {
        $domain = $matches[1]
    }
    $domain = $domain -replace '^https?://', ''
    $domain = $domain -replace '^www\.', ''
    $domain = ($domain -split '/')[0]
    $domain = ($domain -split ',')[0]
    $domain = $domain.Trim('. ')
    return $domain
}

function Get-EmailDomain {
    param([string]$Email)
    if ([string]::IsNullOrWhiteSpace($Email)) { return "" }
    if ($Email -match '@([^>\s,;]+)') {
        return (Normalize-DomainText -Value $matches[1])
    }
    return ""
}

function Test-BusinessDomain {
    param([string]$Domain)
    if ([string]::IsNullOrWhiteSpace($Domain)) { return $false }
    $publicDomains = @(
        "gmail.com", "googlemail.com", "outlook.com", "hotmail.com", "live.com",
        "icloud.com", "me.com", "mac.com", "yahoo.com", "proton.me", "protonmail.com",
        "aol.com", "example.com", "example.invalid"
    )
    return -not ($publicDomains -contains $Domain.ToLowerInvariant())
}

function Get-PhoneCandidates {
    param([string]$Text)
    $phones = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
    $matches = [regex]::Matches($Text, '(?x)(?:\+?1[\s\-.]?)?(?:\(?\d{3}\)?[\s\-.]?)\d{3}[\s\-.]?\d{4}')
    foreach ($match in $matches) {
        $digits = ($match.Value -replace '\D', '')
        if ($digits.Length -eq 11 -and $digits.StartsWith("1")) {
            $digits = $digits.Substring(1)
        }
        if ($digits.Length -ge 7 -and -not $phones.Contains($digits)) {
            $phones.Add($digits) | Out-Null
        }
    }
    return $phones.ToArray()
}

function Get-KeywordSet {
    param([string]$Text)
    $stopWords = @(
        "about", "after", "again", "also", "because", "being", "could", "from",
        "have", "into", "just", "more", "need", "needs", "over", "that", "their",
        "there", "this", "through", "want", "wants", "with", "would", "your",
        "guided", "labs", "journey", "internal", "proof", "signal", "please"
    )
    $tokens = New-Object System.Collections.Generic.List[string]
    $normalized = Normalize-CompareText -Text $Text
    foreach ($token in ($normalized -split '\s+')) {
        if ($token.Length -lt 4) { continue }
        if ($stopWords -contains $token) { continue }
        if ($token -match '^\d+$') { continue }
        if (-not $tokens.Contains($token)) {
            $tokens.Add($token) | Out-Null
        }
    }
    return $tokens.ToArray()
}

function Get-TokenOverlap {
    param([string[]]$Left, [string[]]$Right)
    $matches = New-Object System.Collections.Generic.List[string]
    foreach ($token in $Left) {
        if ($Right -contains $token -and -not $matches.Contains($token)) {
            $matches.Add($token) | Out-Null
        }
    }
    return $matches.ToArray()
}

function Test-CloseText {
    param([string]$Left, [string]$Right)
    $leftNorm = Normalize-CompareText -Text $Left
    $rightNorm = Normalize-CompareText -Text $Right
    if ([string]::IsNullOrWhiteSpace($leftNorm) -or [string]::IsNullOrWhiteSpace($rightNorm)) { return $false }
    if ($leftNorm -eq $rightNorm) { return $true }
    if ($leftNorm.Length -ge 5 -and $rightNorm.Contains($leftNorm)) { return $true }
    if ($rightNorm.Length -ge 5 -and $leftNorm.Contains($rightNorm)) { return $true }

    $leftTokens = @($leftNorm -split '\s+' | Where-Object { $_.Length -ge 3 })
    $rightTokens = @($rightNorm -split '\s+' | Where-Object { $_.Length -ge 3 })
    if ($leftTokens.Count -eq 0 -or $rightTokens.Count -eq 0) { return $false }
    $overlap = @(Get-TokenOverlap -Left $leftTokens -Right $rightTokens)
    $shorter = [math]::Min($leftTokens.Count, $rightTokens.Count)
    return (($overlap.Count / $shorter) -ge 0.66)
}

function Get-FirstFieldText {
    param([object]$Fields, [string[]]$Names)
    foreach ($name in $Names) {
        $value = Get-FieldText -Fields $Fields -Name $name
        if (-not [string]::IsNullOrWhiteSpace($value)) { return $value }
    }
    return ""
}

function Get-RelatedRecordFromFields {
    param(
        [string]$RelatedListTitle,
        [object]$Fields,
        [int]$Id,
        [string]$ItemLink
    )

    $title = Get-FieldText -Fields $Fields -Name "Title"
    $personName = Get-FirstFieldText -Fields $Fields -Names @("PersonName", "RequesterName", "ContactKey", "PrimaryContactKey")
    $email = Get-FirstFieldText -Fields $Fields -Names @("PersonEmail", "ContactEmail", "RequesterEmail", "Email")
    $organization = Get-FirstFieldText -Fields $Fields -Names @("OrganizationName", "Organization", "OrganizationKey", "OrganizationLookup")
    if ($RelatedListTitle -eq "CRM - Organizations" -and [string]::IsNullOrWhiteSpace($organization)) {
        $organization = $title
    }
    if ($RelatedListTitle -eq "CRM - Contacts" -and [string]::IsNullOrWhiteSpace($personName)) {
        $personName = $title
    }

    $domain = Get-FirstFieldText -Fields $Fields -Names @("PrimaryDomain", "Domain")
    if ([string]::IsNullOrWhiteSpace($domain)) {
        $domain = Get-FirstFieldText -Fields $Fields -Names @("Website")
    }
    $domain = Normalize-DomainText -Value $domain

    $status = Get-FirstFieldText -Fields $Fields -Names @("SignalStatus", "CRMStatus", "CommunicationStatus", "ActionStatus")
    $summary = Get-FirstFieldText -Fields $Fields -Names @("NeedSummary", "SourceText", "Summary", "Notes", "NextAction", "SuccessCriteria")
    $sourceLink = Get-FirstFieldText -Fields $Fields -Names @("ItemLink", "RelatedLink", "SourceLink")
    if ([string]::IsNullOrWhiteSpace($ItemLink) -and -not [string]::IsNullOrWhiteSpace($sourceLink)) {
        $ItemLink = $sourceLink
    }
    $phoneText = Get-FirstFieldText -Fields $Fields -Names @("PersonPhone", "Phone", "PhoneNumber", "CustomerPhone", "MobilePhone")
    $phoneCandidates = @(Get-PhoneCandidates -Text (@($phoneText, $summary, $title) -join " "))

    $textBag = @(
        $title,
        $personName,
        $email,
        $organization,
        $domain,
        $status,
        $summary,
        (Get-FieldText -Fields $Fields -Name "NextAction")
    ) -join " "

    return [pscustomobject][ordered]@{
        listTitle = $RelatedListTitle
        id = $Id
        title = $title
        link = $ItemLink
        personName = $personName
        email = $email
        emailDomain = Get-EmailDomain -Email $email
        organizationName = $organization
        organizationKey = Get-FieldText -Fields $Fields -Name "OrganizationKey"
        primaryDomain = $domain
        phoneCandidates = @($phoneCandidates)
        status = $status
        crmStatus = Get-FieldText -Fields $Fields -Name "CRMStatus"
        signalStatus = Get-FieldText -Fields $Fields -Name "SignalStatus"
        relationshipStatus = Get-FieldText -Fields $Fields -Name "RelationshipStatus"
        communicationStatus = Get-FieldText -Fields $Fields -Name "CommunicationStatus"
        engagementStage = Get-FieldText -Fields $Fields -Name "EngagementStage"
        sourceText = $summary
        modified = Get-FieldDateText -Fields $Fields -Name "Modified"
        created = Get-FieldDateText -Fields $Fields -Name "Created"
        textBag = $textBag
        keywords = @(Get-KeywordSet -Text $textBag)
    }
}

function Get-JsonRecordId {
    param([object]$Record, [object]$Fields)
    $idValue = Get-PropertyValue -Object $Record -Name "Id"
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $Record -Name "ID" }
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $Fields -Name "Id" }
    if ($null -eq $idValue) { $idValue = Get-PropertyValue -Object $Fields -Name "ID" }
    [int]$id = 0
    if ($null -ne $idValue) { [int]::TryParse([string]$idValue, [ref]$id) | Out-Null }
    return $id
}

function Get-RelatedListTitleFromJsonName {
    param([string]$Name)
    switch -Regex ($Name) {
        '^CRM - New Signals$|^newSignals$|^signals$' { return $ListTitle }
        '^CRM - Organizations$|^organizations$|^orgs$' { return "CRM - Organizations" }
        '^CRM - Contacts$|^contacts$' { return "CRM - Contacts" }
        '^CRM - Engagements$|^engagements$' { return "CRM - Engagements" }
        '^CRM - Touchpoints$|^touchpoints$' { return "CRM - Touchpoints" }
        default { return $Name }
    }
}

function Get-RelatedRecordsFromJson {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "RelatedRecordsJson not found: $Path"
    }

    $records = New-Object System.Collections.Generic.List[object]
    $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json

    function Add-RelatedJsonRecord {
        param([string]$ListName, [object]$Record)
        $fields = Get-PropertyValue -Object $Record -Name "FieldValues"
        if ($null -eq $fields) { $fields = Get-PropertyValue -Object $Record -Name "fields" }
        if ($null -eq $fields) { $fields = $Record }
        $id = Get-JsonRecordId -Record $Record -Fields $fields
        $link = Get-FirstFieldText -Fields $fields -Names @("ItemLink", "Link", "link")
        $records.Add((Get-RelatedRecordFromFields -RelatedListTitle $ListName -Fields $fields -Id $id -ItemLink $link)) | Out-Null
    }

    if ($json -is [array]) {
        foreach ($record in $json) {
            $listName = Get-PropertyValue -Object $record -Name "listTitle"
            if ([string]::IsNullOrWhiteSpace([string]$listName)) { $listName = Get-PropertyValue -Object $record -Name "ListTitle" }
            if ([string]::IsNullOrWhiteSpace([string]$listName)) { $listName = Get-PropertyValue -Object $record -Name "list" }
            if ([string]::IsNullOrWhiteSpace([string]$listName)) { $listName = "Related Records" }
            Add-RelatedJsonRecord -ListName (Get-RelatedListTitleFromJsonName -Name $listName) -Record $record
        }
        return $records.ToArray()
    }

    foreach ($prop in $json.PSObject.Properties) {
        $listName = Get-RelatedListTitleFromJsonName -Name $prop.Name
        $value = $prop.Value
        $items = $value
        $nestedItems = Get-PropertyValue -Object $value -Name "items"
        if ($null -ne $nestedItems) { $items = $nestedItems }
        foreach ($record in @($items)) {
            Add-RelatedJsonRecord -ListName $listName -Record $record
        }
    }

    return $records.ToArray()
}

function Get-RelatedRecordsLive {
    param([object]$SourceSignal)

    $records = New-Object System.Collections.Generic.List[object]
    $relatedListTitles = @(
        $ListTitle,
        "CRM - Organizations",
        "CRM - Contacts",
        "CRM - Engagements",
        "CRM - Touchpoints"
    ) | Select-Object -Unique

    foreach ($relatedListTitle in $relatedListTitles) {
        try {
            $relatedList = Get-PnPList -Identity $relatedListTitle -Includes RootFolder, Id -ErrorAction Stop
            $items = @(Get-PnPListItem -List $relatedList.Title -PageSize 500 -ErrorAction Stop)
            Write-Host ("  Read {0} row(s) from {1}" -f $items.Count, $relatedList.Title) -ForegroundColor Green
            foreach ($item in $items) {
                if ($relatedListTitle -eq $ListTitle -and $SourceSignal.Id -gt 0 -and $item.Id -eq $SourceSignal.Id) {
                    continue
                }
                $itemLink = Get-ListItemLink -List $relatedList -Id $item.Id
                $records.Add((Get-RelatedRecordFromFields -RelatedListTitle $relatedListTitle -Fields $item.FieldValues -Id $item.Id -ItemLink $itemLink)) | Out-Null
            }
        }
        catch {
            Write-Host ("  [skip] {0}: {1}" -f $relatedListTitle, $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    return $records.ToArray()
}

function Add-MatchReason {
    param(
        [System.Collections.Generic.List[string]]$Reasons,
        [string]$Reason
    )
    if (-not [string]::IsNullOrWhiteSpace($Reason) -and -not $Reasons.Contains($Reason)) {
        $Reasons.Add($Reason) | Out-Null
    }
}

function New-SimilarRecordAdvisory {
    param(
        [object]$Signal,
        [object[]]$RelatedRecords,
        [string]$EvidencePath
    )

    $signalEmail = $Signal.PersonEmail.ToLowerInvariant().Trim()
    $signalDomain = Get-EmailDomain -Email $Signal.PersonEmail
    $signalOrg = Normalize-CompareText -Text $Signal.OrganizationName
    $signalPerson = Normalize-CompareText -Text $Signal.PersonName
    $signalSourceText = Normalize-CompareText -Text $Signal.SourceText
    $signalPhones = @(Get-PhoneCandidates -Text (@($Signal.SourceText, $Signal.NeedSummary, $Signal.NextAction) -join " "))
    $signalKeywords = @(Get-KeywordSet -Text (@($Signal.Title, $Signal.NeedSummary, $Signal.SourceText, $Signal.NextAction) -join " "))

    $matches = New-Object System.Collections.Generic.List[object]
    foreach ($record in $RelatedRecords) {
        $score = 0
        $reasons = New-Object System.Collections.Generic.List[string]

        $recordEmail = $record.email.ToLowerInvariant().Trim()
        if (-not [string]::IsNullOrWhiteSpace($signalEmail) -and $signalEmail -eq $recordEmail) {
            $score += 100
            Add-MatchReason -Reasons $reasons -Reason "exact email match"
        }

        $phoneOverlap = @(Get-TokenOverlap -Left $signalPhones -Right $record.phoneCandidates)
        if ($phoneOverlap.Count -gt 0) {
            $score += 100
            Add-MatchReason -Reasons $reasons -Reason "exact phone match"
        }

        $recordOrgText = Normalize-CompareText -Text $record.organizationName
        if (-not [string]::IsNullOrWhiteSpace($signalOrg) -and $signalOrg -eq $recordOrgText) {
            $score += 55
            Add-MatchReason -Reasons $reasons -Reason "exact normalized organization match"
        }
        elseif (Test-CloseText -Left $Signal.OrganizationName -Right $record.organizationName) {
            $score += 30
            Add-MatchReason -Reasons $reasons -Reason "close organization name match"
        }

        if (Test-BusinessDomain -Domain $signalDomain) {
            $recordDomains = @($record.emailDomain, $record.primaryDomain) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
            if ($recordDomains -contains $signalDomain) {
                $score += 45
                Add-MatchReason -Reasons $reasons -Reason ("business email/domain match: {0}" -f $signalDomain)
            }
        }

        $recordPersonText = Normalize-CompareText -Text $record.personName
        if (-not [string]::IsNullOrWhiteSpace($signalPerson) -and (Test-CloseText -Left $signalPerson -Right $recordPersonText)) {
            if ($signalOrg -eq $recordOrgText -or (Test-CloseText -Left $Signal.OrganizationName -Right $record.organizationName)) {
                $score += 70
                Add-MatchReason -Reasons $reasons -Reason "close person name plus same organization"
            }
            else {
                $score += 15
                Add-MatchReason -Reasons $reasons -Reason "close person name"
            }
        }

        $recordSourceText = Normalize-CompareText -Text $record.sourceText
        if (-not [string]::IsNullOrWhiteSpace($signalSourceText) -and $signalSourceText.Length -ge 24 -and $signalSourceText -eq $recordSourceText) {
            $score += 70
            Add-MatchReason -Reasons $reasons -Reason "same submitted/source text"
        }

        $keywordOverlap = @(Get-TokenOverlap -Left $signalKeywords -Right $record.keywords)
        if ($keywordOverlap.Count -ge 2) {
            $keywordScore = [math]::Min(25, 10 + ($keywordOverlap.Count * 3))
            $score += $keywordScore
            Add-MatchReason -Reasons $reasons -Reason ("similar need/opportunity keywords: {0}" -f (($keywordOverlap | Select-Object -First 5) -join ", "))
        }

        $activeStates = @("New", "Triage", "Waiting on Adam", "Waiting on External", "Active", "At Risk", "Prospect", "Signal")
        $recordStates = @($record.status, $record.crmStatus, $record.signalStatus, $record.relationshipStatus, $record.communicationStatus, $record.engagementStage)
        if ($score -gt 0 -and (@($recordStates | Where-Object { $activeStates -contains $_ }).Count -gt 0)) {
            $score += 8
            Add-MatchReason -Reasons $reasons -Reason "related record is active/open or waiting on Adam"
        }

        if ($score -le 0) { continue }

        $confidence = "Low"
        if ($score -ge 80) {
            $confidence = "High"
        }
        elseif ($score -ge 45) {
            $confidence = "Medium"
        }

        $matches.Add([pscustomobject][ordered]@{
            listTitle = $record.listTitle
            id = $record.id
            title = $record.title
            link = $record.link
            confidence = $confidence
            score = $score
            reasons = @($reasons)
            status = $record.status
            organizationName = $record.organizationName
            personName = $record.personName
            email = $record.email
        }) | Out-Null
    }

    $confidenceOrder = @{ High = 0; Medium = 1; Low = 2 }
    $sortedMatches = @($matches | Sort-Object @{ Expression = { $confidenceOrder[$_.confidence] } }, @{ Expression = { -1 * $_.score } }, listTitle, title | Select-Object -First $MaxRelatedCandidates)
    $summary = "No obvious related records found."
    if ($sortedMatches.Count -gt 0) {
        $summary = ("Found {0} possible related record(s)." -f $sortedMatches.Count)
    }

    $advisory = [pscustomobject][ordered]@{
        included = $true
        generatedAt = (Get-Date).ToString("o")
        searchedSurfaces = @($ListTitle, "CRM - Organizations", "CRM - Contacts", "CRM - Engagements", "CRM - Touchpoints")
        candidateCount = @($RelatedRecords).Count
        matchCount = $sortedMatches.Count
        summary = $summary
        matches = @($sortedMatches)
        evidencePath = $EvidencePath
        boundary = "Advisory only. No merge, lookup conversion, suppression, dedupe, update, delete, or hidden decision occurred."
    }

    $advisory | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $EvidencePath -Encoding UTF8
    return $advisory
}

function Test-AnyTextMatch {
    param([string]$Text, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) { return $true }
    }
    return $false
}

function New-TriageDecision {
    param([object]$Signal)

    $combined = @(
        $Signal.Title,
        $Signal.SignalType,
        $Signal.IntakeSource,
        $Signal.NeedSummary,
        $Signal.SourceText,
        $Signal.NextAction
    ) -join " "
    $combinedLower = $combined.ToLowerInvariant()
    $priority = $Signal.Priority

    $timeSensitivePatterns = @(
        'urgent',
        '\basap\b',
        'immediate',
        'today',
        'tomorrow',
        'deadline',
        'missed call',
        'voicemail',
        'called',
        'call me',
        '\bsms\b',
        'text message',
        'meeting'
    )
    $noFitPatterns = @('spam', 'unsubscribe', 'not a fit', 'no fit', 'wrong number')
    $supportPatterns = @('support', 'bug', 'broken', 'access issue', 'cannot log in', 'refund', 'billing problem', 'error')

    $isHighPriority = ($priority -in @("High", "Urgent"))
    $isTimeSensitive = $isHighPriority -or (Test-AnyTextMatch -Text $combinedLower -Patterns $timeSensitivePatterns)

    $urgency = "Normal"
    if ($priority -eq "Urgent") {
        $urgency = "Attention now"
    }
    elseif ($priority -eq "High" -or $isTimeSensitive) {
        $urgency = "Time-sensitive"
    }
    elseif ($priority -eq "Low") {
        $urgency = "Low"
    }

    $missing = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($Signal.PersonName)) { $missing.Add("person name") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.PersonEmail)) { $missing.Add("email") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.OrganizationName)) { $missing.Add("organization") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.NeedSummary)) { $missing.Add("need/opportunity summary") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.NextAction)) { $missing.Add("next action") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.FollowUpDueDate)) { $missing.Add("follow-up due date") | Out-Null }
    if ([string]::IsNullOrWhiteSpace($Signal.Owner)) { $missing.Add("owner") | Out-Null }

    $classification = "qualification"
    if (Test-AnyTextMatch -Text $combinedLower -Patterns $noFitPatterns) {
        $classification = "close/no-fit"
    }
    elseif ($Signal.SignalType -eq "Support signal" -or (Test-AnyTextMatch -Text $combinedLower -Patterns $supportPatterns)) {
        $classification = "support"
    }
    elseif ($Signal.SignalType -eq "Referral" -or $combinedLower -match 'referral') {
        $classification = "referral"
    }
    elseif ([string]::IsNullOrWhiteSpace($Signal.NeedSummary) -and [string]::IsNullOrWhiteSpace($Signal.OrganizationName)) {
        $classification = "nurture"
    }

    $suggestedFirstMove = ""
    $nextGovernanceLevel = "G0"
    $governanceNote = "G0 review only. No write or external action is needed until Adam chooses the next move."

    if (-not [string]::IsNullOrWhiteSpace($Signal.NextAction)) {
        $suggestedFirstMove = "Review the existing NextAction and decide whether to accept it: $($Signal.NextAction)"
        $nextGovernanceLevel = "G0"
    }
    elseif ($classification -eq "support") {
        $suggestedFirstMove = "Open the CRM item, confirm whether this is a support issue, and draft a response or support handoff for Adam review."
        $nextGovernanceLevel = "G1"
        $governanceNote = "G1 draft/recommend is appropriate. Sending any reply or creating a task/reminder needs separate approval."
    }
    elseif ($classification -eq "close/no-fit") {
        $suggestedFirstMove = "Review for spam/no-fit evidence. Do not close or update the CRM item until Adam confirms."
        $nextGovernanceLevel = "G1"
        $governanceNote = "G1 recommendation only. Closing, suppressing, or updating the CRM record is a later approval."
    }
    elseif ($isTimeSensitive) {
        $suggestedFirstMove = "Review immediately, enrich missing contact context if needed, and draft a short first response for Adam approval."
        $nextGovernanceLevel = "G1"
        $governanceNote = "G1 draft/recommend is the next agent step. Any external email, SMS, phone call, or client commitment is G3 and remains blocked until Adam approves."
    }
    elseif ($classification -eq "nurture") {
        $suggestedFirstMove = "Open the signal, fill in the missing context manually, then decide whether it is qualification or nurture."
        $nextGovernanceLevel = "G0"
    }
    else {
        $suggestedFirstMove = "Open the CRM item, qualify the need, and draft a concise discovery follow-up for Adam review."
        $nextGovernanceLevel = "G1"
        $governanceNote = "G1 draft/recommend is appropriate. Any CRM update, task creation, or external reply needs a later gate."
    }

    $followUpWindow = "Today or next business morning"
    if ($urgency -eq "Attention now") {
        $followUpWindow = "Within 15 minutes if possible; same business hour at latest"
    }
    elseif ($urgency -eq "Time-sensitive") {
        $followUpWindow = "Today"
    }
    elseif ($urgency -eq "Low") {
        $followUpWindow = "Within two business days"
    }

    $owner = $Signal.Owner
    if ([string]::IsNullOrWhiteSpace($owner)) {
        $owner = "Adam"
    }

    return [pscustomobject][ordered]@{
        apparentUrgency = $urgency
        classification = $classification
        suggestedFirstMove = $suggestedFirstMove
        missingInformation = @($missing)
        suggestedOwner = $owner
        suggestedFollowUpDueWindow = $followUpWindow
        nextGovernanceLevel = $nextGovernanceLevel
        governanceNote = $governanceNote
        blockedActions = @(
            "Do not update CRM fields in B2.",
            "Do not create Planner tasks or calendar reminders in B2.",
            "Do not send email, Teams chat, SMS, calls, or prospect replies.",
            "Do not merge, suppress, convert, close, or dedupe records automatically.",
            "Do not grant app permissions, consent, guest access, or sharing changes."
        )
        requiredApprovals = @(
            "G1 approval before writing an Agent Action Log Suggested row.",
            "G2 approval before internal CRM/list updates or task/reminder creation.",
            "G3 approval before any external/prospect communication or access-affecting write.",
            "G4 remains blocked for destructive, broad-permission, guest/share, billing, or client-commitment actions."
        )
    }
}

function Add-LineValue {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Label,
        [string]$Value
    )
    if ([string]::IsNullOrWhiteSpace($Value)) { $Value = "(blank)" }
    $Lines.Add(("- **{0}:** {1}" -f $Label, $Value))
}

function Get-SignalDisplayName {
    param([object]$Signal)
    $parts = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($Signal.PersonName)) { $parts.Add($Signal.PersonName) | Out-Null }
    if (-not [string]::IsNullOrWhiteSpace($Signal.OrganizationName)) { $parts.Add($Signal.OrganizationName) | Out-Null }
    if ($parts.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($Signal.Title)) { $parts.Add($Signal.Title) | Out-Null }
    if ($parts.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($Signal.PersonEmail)) { $parts.Add($Signal.PersonEmail) | Out-Null }
    if ($parts.Count -eq 0) { return "selected signal" }
    return (($parts | Select-Object -First 2) -join " / ")
}

function New-ActionLogResultText {
    param(
        [object]$Signal,
        [object]$Decision,
        [object]$SimilarAdvisory,
        [string]$EvidenceMarkdownPath,
        [string]$EvidenceJsonPath
    )

    $resultLines = New-Object System.Collections.Generic.List[string]
    $resultLines.Add(("CRM signal triage recommendation generated {0}." -f (Get-Date).ToString("yyyy-MM-dd HH:mm")))
    $resultLines.Add(("CRM item: #{0}" -f $Signal.Id))
    $resultLines.Add(("CRM link: {0}" -f $Signal.ItemLink))
    $resultLines.Add("")
    $resultLines.Add(("Summary: {0}" -f $(if ([string]::IsNullOrWhiteSpace($Signal.NeedSummary)) { $Signal.Title } else { $Signal.NeedSummary })))
    $resultLines.Add(("Urgency: {0}" -f $Decision.apparentUrgency))
    $resultLines.Add(("Recommended lane: {0}" -f $Decision.classification))
    $resultLines.Add(("Recommended first move: {0}" -f $Decision.suggestedFirstMove))
    $resultLines.Add(("Next governance level: {0}" -f $Decision.nextGovernanceLevel))
    $resultLines.Add("")

    if ($null -ne $SimilarAdvisory -and $SimilarAdvisory.included -eq $true) {
        $resultLines.Add(("Similar-record advisory: {0}" -f $SimilarAdvisory.summary))
        $topMatches = @($SimilarAdvisory.matches | Select-Object -First 5)
        foreach ($match in $topMatches) {
            $resultLines.Add(("- [{0}] {1} #{2}: {3} - {4}" -f $match.confidence, $match.listTitle, $match.id, $match.title, (@($match.reasons) -join "; ")))
        }
        if ($SimilarAdvisory.matches.Count -gt $topMatches.Count) {
            $resultLines.Add(("- (+{0} more in the local evidence)" -f ($SimilarAdvisory.matches.Count - $topMatches.Count)))
        }
    }
    else {
        $resultLines.Add("Similar-record advisory: not included or no related-record corpus was available.")
    }

    $resultLines.Add("")
    $resultLines.Add(("Local evidence markdown: {0}" -f $EvidenceMarkdownPath))
    $resultLines.Add(("Local evidence JSON: {0}" -f $EvidenceJsonPath))
    if ($null -ne $SimilarAdvisory -and -not [string]::IsNullOrWhiteSpace($SimilarAdvisory.evidencePath)) {
        $resultLines.Add(("Match evidence JSON: {0}" -f $SimilarAdvisory.evidencePath))
    }
    $resultLines.Add("")
    $resultLines.Add("Status boundary: Suggested only. Not approved, not executed, and not verified.")
    $resultLines.Add("Pause/rollback: reject or supersede this Agent Action Log row. No CRM record, task, reminder, message, merge, permission, guest/share, or external action was created by this suggestion.")

    return ($resultLines -join "`n")
}

function Get-UrlFieldText {
    param([object]$Value)
    if ($null -eq $Value) { return "" }
    $url = Get-PropertyValue -Object $Value -Name "Url"
    if ($null -ne $url) { return [string]$url }
    return (ConvertTo-SignalText -Value $Value)
}

function Get-ExistingActionLogSuggestions {
    param([object]$Signal)

    $existing = New-Object System.Collections.Generic.List[object]
    try {
        $rows = @(Get-PnPListItem -List $ActionLogListTitle -PageSize 500 -ErrorAction Stop)
    }
    catch {
        Write-Host ("  [warn] Could not read existing {0} rows for duplicate check: {1}" -f $ActionLogListTitle, $_.Exception.Message) -ForegroundColor Yellow
        return @()
    }

    foreach ($row in $rows) {
        $status = ConvertTo-SignalText -Value (Get-PropertyValue -Object $row.FieldValues -Name "ActionStatus")
        if ($status -ne "Suggested") { continue }
        $source = Get-UrlFieldText -Value (Get-PropertyValue -Object $row.FieldValues -Name "ActionSource")
        $result = ConvertTo-SignalText -Value (Get-PropertyValue -Object $row.FieldValues -Name "Result")
        $title = ConvertTo-SignalText -Value (Get-PropertyValue -Object $row.FieldValues -Name "Title")

        $matchesSignal = $false
        if (-not [string]::IsNullOrWhiteSpace($Signal.ItemLink) -and ($source -match [regex]::Escape($Signal.ItemLink) -or $result -match [regex]::Escape($Signal.ItemLink))) {
            $matchesSignal = $true
        }
        if ($Signal.Id -gt 0 -and $result -match ("CRM item:\s*#{0}\b" -f $Signal.Id)) {
            $matchesSignal = $true
        }

        if ($matchesSignal) {
            $existing.Add([pscustomobject][ordered]@{
                id = $row.Id
                title = $title
                status = $status
                source = $source
            }) | Out-Null
        }
    }

    return $existing.ToArray()
}

function Invoke-ActionLogSuggestion {
    param(
        [object]$Signal,
        [object]$Decision,
        [object]$SimilarAdvisory,
        [string]$EvidenceMarkdownPath,
        [string]$EvidenceJsonPath
    )

    $displayName = Get-SignalDisplayName -Signal $Signal
    $suggestionTitle = "Triage new CRM signal - $displayName"
    if ($suggestionTitle.Length -gt 255) {
        $suggestionTitle = $suggestionTitle.Substring(0, 255)
    }
    $resultText = New-ActionLogResultText -Signal $Signal -Decision $Decision -SimilarAdvisory $SimilarAdvisory -EvidenceMarkdownPath $EvidenceMarkdownPath -EvidenceJsonPath $EvidenceJsonPath

    if (-not $Apply) {
        Write-Host "  DRY RUN: would add ONE Suggested Agent Action Log row:" -ForegroundColor Yellow
        Write-Host ("    Title: {0}" -f $suggestionTitle) -ForegroundColor Yellow
        Write-Host "  Re-run with -Apply to record it after one approval prompt." -ForegroundColor Yellow
        return [pscustomobject][ordered]@{
            status = "dry-run"
            title = $suggestionTitle
            actionStatus = "Suggested"
            actionType = "recommend"
            resultPreview = $resultText
            itemId = $null
            itemLink = ""
            duplicateSuggestions = @()
            boundary = "No tenant write occurred."
        }
    }

    if ([string]::IsNullOrWhiteSpace($Signal.ItemLink)) {
        throw "B4 requires a CRM item link before writing Agent Action Log. Run against a live CRM signal or include ItemLink in InputJson."
    }

    Write-Host ""
    Write-Host "Approve this live write? It records ONE Suggested Agent Action Log row." -ForegroundColor Yellow
    Write-Host ("  Title: {0}" -f $suggestionTitle) -ForegroundColor Gray
    Write-Host "  Scope: Agent Action Log only. Suggested is not approved or executed." -ForegroundColor Gray

    Get-PnPList -Identity $ActionLogListTitle -Includes RootFolder, Id -ErrorAction Stop | Out-Null
    $duplicates = @(Get-ExistingActionLogSuggestions -Signal $Signal)
    if ($duplicates.Count -gt 0 -and -not $AllowDuplicateSuggestion) {
        $ids = (($duplicates | ForEach-Object { "#$($_.id)" }) -join ", ")
        throw "Existing Suggested Agent Action Log row(s) already reference this signal: $ids. Re-run with -AllowDuplicateSuggestion only if Adam intentionally wants another row."
    }

    if ($Approve) {
        Write-Host "  Approval supplied by -Approve switch." -ForegroundColor Gray
        $confirmed = $true
    }
    else {
        $answer = Read-Host "Type Y to approve (anything else cancels)"
        $confirmed = ($answer -match '^(y|yes)$')
    }
    if (-not $confirmed) {
        throw "Not approved. No Agent Action Log row was written. Local triage evidence is still available at $EvidenceMarkdownPath."
    }

    $actionLogList = Get-PnPList -Identity $ActionLogListTitle -Includes RootFolder, Id -ErrorAction Stop
    $actionValues = @{
        Title        = $suggestionTitle
        ActionDate   = Get-Date
        AgentSurface = "Codex"
        ActionSource = "$($Signal.ItemLink), CRM - New Signals #$($Signal.Id)"
        ActionType   = "recommend"
        ActionStatus = "Suggested"
        Result       = $resultText
    }
    $created = Add-PnPListItem -List $ActionLogListTitle -Values $actionValues
    $createdLink = Get-ListItemLink -List $actionLogList -Id $created.Id
    Write-Host ("  [OK] Added Suggested Agent Action Log row #{0}" -f $created.Id) -ForegroundColor Green
    Write-Host ("  Link: {0}" -f $createdLink) -ForegroundColor Gray

    return [pscustomobject][ordered]@{
        status = "created"
        title = $suggestionTitle
        actionStatus = "Suggested"
        actionType = "recommend"
        itemId = $created.Id
        itemLink = $createdLink
        duplicateSuggestions = @($duplicates)
        boundary = "G1 Suggested row only. Not approved, not completed, not executed."
    }
}

Write-Host "B2/B3/B4 - New Signal triage lane" -ForegroundColor Cyan
Write-Host ("Mode:       {0}" -f $(if ($Apply) { "APPLY: G0 triage + one G1 Suggested Agent Action Log row" } elseif (-not [string]::IsNullOrWhiteSpace($InputJson)) { "OFFLINE JSON" } elseif ($ItemId -gt 0) { "LIVE READ: item #$ItemId" } else { "LIVE READ: newest item" })) -ForegroundColor Gray
Write-Host ("Output:     {0}" -f $packetPath) -ForegroundColor Gray
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
Write-Host "Safety:     G0 read/reason by default. -Apply writes at most one G1 Suggested Agent Action Log row; no CRM updates, tasks, reminders, messages, merges, or permissions." -ForegroundColor Gray

$signal = $null
$sourceMode = "sharepoint"
$isSharePointConnected = $false

if (-not [string]::IsNullOrWhiteSpace($InputJson)) {
    Write-Section "Read local JSON"
    if (-not (Test-Path -LiteralPath $InputJson)) {
        throw "InputJson not found: $InputJson"
    }
    $signal = Get-SignalFromJson -Path $InputJson
    $sourceMode = "local-json"
    Write-Host ("PASS: read local signal JSON {0}" -f $InputJson) -ForegroundColor Green
}
else {
    if ($ItemId -le 0 -and -not $Newest) {
        Write-Host "No -ItemId supplied; defaulting to -Newest." -ForegroundColor Yellow
        $Newest = $true
    }

    Write-Section "Connect to CRM"
    Connect-NewSignalPnP
    $isSharePointConnected = $true
    $list = Get-PnPList -Identity $ListTitle -Includes RootFolder, Id
    Write-Host ("PASS: list found: {0} ({1})" -f $list.Title, $list.Id) -ForegroundColor Green

    Write-Section "Read signal"
    $item = Get-PnPSignalItem -List $list
    $itemLink = Get-ListItemLink -List $list -Id $item.Id
    $signal = Get-NormalizedSignalFromFields -Fields $item.FieldValues -Id $item.Id -ItemLink $itemLink
    Write-Host ("PASS: signal read: #{0} {1}" -f $signal.Id, $signal.Title) -ForegroundColor Green
}

Write-Section "Triage"
$decision = New-TriageDecision -Signal $signal
Write-Host ("Urgency: {0}" -f $decision.apparentUrgency) -ForegroundColor $(if ($decision.apparentUrgency -eq "Attention now") { "Red" } elseif ($decision.apparentUrgency -eq "Time-sensitive") { "Yellow" } else { "Green" })
Write-Host ("Classification: {0}" -f $decision.classification) -ForegroundColor Gray
Write-Host ("Next governance: {0}" -f $decision.nextGovernanceLevel) -ForegroundColor Gray

Write-Section "B3 similar-record advisory"
$similarAdvisory = [pscustomobject][ordered]@{
    included = $false
    summary = "Skipped by -IncludeSimilar:`$false."
    matches = @()
    evidencePath = ""
    boundary = "No merge, lookup conversion, suppression, dedupe, update, delete, or hidden decision occurred."
}

if ($IncludeSimilar) {
    $relatedRecords = @()
    if (-not [string]::IsNullOrWhiteSpace($RelatedRecordsJson)) {
        $relatedRecords = @(Get-RelatedRecordsFromJson -Path $RelatedRecordsJson)
        Write-Host ("PASS: read {0} related-record candidate(s) from local JSON" -f $relatedRecords.Count) -ForegroundColor Green
    }
    elseif ($sourceMode -eq "sharepoint") {
        $relatedRecords = @(Get-RelatedRecordsLive -SourceSignal $signal)
    }
    else {
        Write-Host "SKIP: offline signal JSON has no related-record corpus. Supply -RelatedRecordsJson to test B3 locally." -ForegroundColor Yellow
    }

    $similarAdvisory = New-SimilarRecordAdvisory -Signal $signal -RelatedRecords $relatedRecords -EvidencePath $matchJsonPath
    Write-Host ("B3 result: {0}" -f $similarAdvisory.summary) -ForegroundColor $(if ($similarAdvisory.matchCount -gt 0) { "Yellow" } else { "Green" })
    if ($similarAdvisory.matchCount -gt 0) {
        foreach ($match in @($similarAdvisory.matches | Select-Object -First 5)) {
            Write-Host ("  [{0}] {1} #{2}: {3} - {4}" -f $match.confidence, $match.listTitle, $match.id, $match.title, (@($match.reasons) -join "; ")) -ForegroundColor Gray
        }
    }
}
else {
    Write-Host "SKIP: -IncludeSimilar is false." -ForegroundColor Yellow
}

Write-Section "B4 Agent Action Log suggestion"
if ($Apply -and -not $isSharePointConnected) {
    Write-Host "Connecting to SharePoint for the B4 Agent Action Log write." -ForegroundColor Yellow
    Connect-NewSignalPnP
    $isSharePointConnected = $true
}
$actionLogSuggestion = Invoke-ActionLogSuggestion -Signal $signal -Decision $decision -SimilarAdvisory $similarAdvisory -EvidenceMarkdownPath $packetPath -EvidenceJsonPath $packetJsonPath

$packet = [ordered]@{
    purpose = "B2/B3/B4 Signal triage lane"
    generatedAt = (Get-Date).ToString("o")
    sourceMode = $sourceMode
    sourceInputJson = $InputJson
    relatedRecordsInputJson = $RelatedRecordsJson
    signal = $signal
    decision = $decision
    similarRecordAdvisory = $similarAdvisory
    actionLogSuggestion = $actionLogSuggestion
    safety = $(if ($Apply) { "G1 Agent Action Log Suggested row only. No CRM update, task, reminder, message, merge, permission, or external action occurred." } else { "G0 read/reason only. No tenant write occurred." })
    markdownPath = $packetPath
    jsonPath = $packetJsonPath
    matchEvidencePath = $(if ($similarAdvisory.included) { $matchJsonPath } else { "" })
    transcript = $transcriptPath
}
$packet | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $packetJsonPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# New Signal Triage Packet")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm")))
$lines.Add(("Governance: {0}" -f $packet.safety))
$lines.Add("")
$lines.Add("## Source")
$lines.Add("")
Add-LineValue -Lines $lines -Label "CRM item" -Value $(if ($signal.Id -gt 0) { "#$($signal.Id)" } else { "offline/local" })
Add-LineValue -Lines $lines -Label "CRM link" -Value $signal.ItemLink
Add-LineValue -Lines $lines -Label "Created" -Value $signal.Created
Add-LineValue -Lines $lines -Label "Modified" -Value $signal.Modified
$lines.Add("")
$lines.Add("## Normalized Fields")
$lines.Add("")
Add-LineValue -Lines $lines -Label "Title" -Value $signal.Title
Add-LineValue -Lines $lines -Label "Person" -Value $signal.PersonName
Add-LineValue -Lines $lines -Label "Email" -Value $signal.PersonEmail
Add-LineValue -Lines $lines -Label "Organization" -Value $signal.OrganizationName
Add-LineValue -Lines $lines -Label "Signal type" -Value $signal.SignalType
Add-LineValue -Lines $lines -Label "Source" -Value $signal.IntakeSource
Add-LineValue -Lines $lines -Label "Intent / Path" -Value $signal.IntentPath
Add-LineValue -Lines $lines -Label "Priority" -Value $signal.Priority
Add-LineValue -Lines $lines -Label "Status" -Value $signal.SignalStatus
Add-LineValue -Lines $lines -Label "Owner" -Value $signal.Owner
Add-LineValue -Lines $lines -Label "Follow-up due date" -Value $signal.FollowUpDueDate
$lines.Add("")
$lines.Add("## Signal Summary")
$lines.Add("")
Add-LineValue -Lines $lines -Label "Need" -Value $signal.NeedSummary
Add-LineValue -Lines $lines -Label "Source text" -Value $signal.SourceText
Add-LineValue -Lines $lines -Label "Existing next action" -Value $signal.NextAction
$lines.Add("")
$lines.Add("## Agent Triage")
$lines.Add("")
Add-LineValue -Lines $lines -Label "Apparent urgency" -Value $decision.apparentUrgency
Add-LineValue -Lines $lines -Label "Recommended lane" -Value $decision.classification
Add-LineValue -Lines $lines -Label "Suggested first move" -Value $decision.suggestedFirstMove
Add-LineValue -Lines $lines -Label "Suggested owner" -Value $decision.suggestedOwner
Add-LineValue -Lines $lines -Label "Suggested follow-up window" -Value $decision.suggestedFollowUpDueWindow
Add-LineValue -Lines $lines -Label "Next governance level" -Value $decision.nextGovernanceLevel
Add-LineValue -Lines $lines -Label "Governance note" -Value $decision.governanceNote
$lines.Add("")
$lines.Add("## Possible Related CRM Records")
$lines.Add("")
if ($similarAdvisory.included -ne $true) {
    $lines.Add($similarAdvisory.summary)
}
elseif ($similarAdvisory.matchCount -eq 0) {
    $lines.Add("No obvious related records found.")
    $lines.Add("")
    Add-LineValue -Lines $lines -Label "Candidate records searched" -Value ([string]$similarAdvisory.candidateCount)
}
else {
    foreach ($match in $similarAdvisory.matches) {
        $lines.Add(("- **[{0}] {1} #{2}:** {3}" -f $match.confidence, $match.listTitle, $match.id, $match.title))
        Add-LineValue -Lines $lines -Label "Link" -Value $match.link
        Add-LineValue -Lines $lines -Label "Why" -Value ((@($match.reasons) -join "; "))
        Add-LineValue -Lines $lines -Label "Status" -Value $match.status
        $lines.Add("")
    }
}
if ($similarAdvisory.included -eq $true) {
    Add-LineValue -Lines $lines -Label "Match evidence JSON" -Value $similarAdvisory.evidencePath
}
$lines.Add("")
$lines.Add("## Missing Information")
$lines.Add("")
if ($decision.missingInformation.Count -eq 0) {
    $lines.Add("No obvious missing information from the B2 field set.")
}
else {
    foreach ($missing in $decision.missingInformation) {
        $lines.Add(("- {0}" -f $missing))
    }
}
$lines.Add("")
$lines.Add("## Blocked Actions")
$lines.Add("")
foreach ($blocked in $decision.blockedActions) {
    $lines.Add(("- {0}" -f $blocked))
}
$lines.Add("")
$lines.Add("## Required Approvals")
$lines.Add("")
foreach ($approval in $decision.requiredApprovals) {
    $lines.Add(("- {0}" -f $approval))
}
$lines.Add("")
$lines.Add("## Agent Action Log Suggestion")
$lines.Add("")
Add-LineValue -Lines $lines -Label "Status" -Value $actionLogSuggestion.status
Add-LineValue -Lines $lines -Label "Title" -Value $actionLogSuggestion.title
Add-LineValue -Lines $lines -Label "Action status" -Value $actionLogSuggestion.actionStatus
Add-LineValue -Lines $lines -Label "Action type" -Value $actionLogSuggestion.actionType
if ($null -ne $actionLogSuggestion.itemId) {
    Add-LineValue -Lines $lines -Label "Agent Action Log item" -Value ("#{0}" -f $actionLogSuggestion.itemId)
    Add-LineValue -Lines $lines -Label "Agent Action Log link" -Value $actionLogSuggestion.itemLink
}
Add-LineValue -Lines $lines -Label "Boundary" -Value $actionLogSuggestion.boundary
$lines.Add("")
$lines.Add(("JSON evidence: {0}" -f $packetJsonPath))
$lines.Add(("Transcript: {0}" -f $transcriptPath))

Set-Content -LiteralPath $packetPath -Value $lines -Encoding UTF8

Write-Section "Done"
Write-Host ("Packet markdown: {0}" -f $packetPath) -ForegroundColor Green
Write-Host ("Packet JSON:     {0}" -f $packetJsonPath) -ForegroundColor Green

try {
    Stop-Transcript | Out-Null
}
catch {}
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
