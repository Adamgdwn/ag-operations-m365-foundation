param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$GuidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [string]$RecordKey = ("GAIL-INTERNAL-WALKTHROUGH-PROD-{0}" -f (Get-Date -Format "yyyyMMdd")),
    [switch]$Apply,
    [string]$ApprovalPhrase,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# Stage 8D - approved internal CRM workflow proof.
# Writes only clearly-labelled internal dummy records to existing Lists. No mail,
# guests, sharing, permissions, app grants, tenant policy, public Forms, deletes,
# Dynamics/Dataverse, or unattended automation.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run in pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-8d-functional-workflow-walkthrough"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $transcriptRoot ("stage-8d-workflow-proof-{0}.log" -f $stamp)
$readbackPath = Join-Path $transcriptRoot ("stage-8d-workflow-proof-readback-{0}.csv" -f $stamp)

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

function ConvertTo-XmlText {
    param([string]$Value)
    return [System.Security.SecurityElement]::Escape($Value)
}

function Get-Stage8DClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-Stage8DExpectedUser {
    param([string]$TargetSiteUrl)

    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-Stage8DClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-Stage8DClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-Stage8DPnP {
    param([string]$TargetSiteUrl)

    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $TargetSiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{
            Url = $TargetSiteUrl
            ClientId = $ClientId
            Interactive = $true
            PersistLogin = $true
        }

        if ($ForceFreshLogin) {
            $connectParams.ForceAuthentication = $true
        }

        Connect-PnPOnline @connectParams
    }

    $connection = Get-PnPConnection
    Write-Host ("Connected to {0} using {1}" -f $TargetSiteUrl, $connection.ConnectionType) -ForegroundColor Gray
    Assert-Stage8DExpectedUser -TargetSiteUrl $TargetSiteUrl

    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function Resolve-Stage8DUserFieldValue {
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

function Get-ListFieldNameSet {
    param([string]$ListTitle)

    $set = @{}
    Get-PnPField -List $ListTitle | ForEach-Object {
        $set[[string]$_.InternalName] = $true
    }
    return $set
}

function Select-ExistingFieldValues {
    param(
        [hashtable]$Values,
        [hashtable]$FieldNames
    )

    $selected = @{}
    foreach ($key in $Values.Keys) {
        if ($key -eq "Title" -or $FieldNames.ContainsKey($key)) {
            $selected[$key] = $Values[$key]
        }
        else {
            Write-Host ("  [skip] Field not present on list: {0}" -f $key) -ForegroundColor DarkGray
        }
    }

    return $selected
}

function Get-ListItemByTitle {
    param(
        [string]$ListTitle,
        [string]$Title
    )

    $escapedTitle = ConvertTo-XmlText -Value $Title
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

function Set-Stage8DListItem {
    param(
        [string]$ListTitle,
        [hashtable]$Values
    )

    $title = [string]$Values["Title"]
    $fieldNames = Get-ListFieldNameSet -ListTitle $ListTitle
    $safeValues = Select-ExistingFieldValues -Values $Values -FieldNames $fieldNames
    $existing = @(Get-ListItemByTitle -ListTitle $ListTitle -Title $title)

    if (-not $Apply) {
        if ($existing.Count -gt 0) {
            Write-Host ("  DRY RUN: would update existing {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Yellow
            return $existing[0]
        }

        Write-Host ("  DRY RUN: would create {0} item: {1}" -f $ListTitle, $title) -ForegroundColor Yellow
        return [pscustomobject]@{ Id = 0; FieldValues = @{ Title = $title } }
    }

    if ($existing.Count -gt 0) {
        Set-PnPListItem -List $ListTitle -Identity $existing[0].Id -Values $safeValues | Out-Null
        Write-Host ("  [OK] Updated {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Green
        return (Get-PnPListItem -List $ListTitle -Id $existing[0].Id)
    }

    $created = Add-PnPListItem -List $ListTitle -Values $safeValues
    Write-Host ("  [OK] Created {0} item #{1}: {2}" -f $ListTitle, $created.Id, $title) -ForegroundColor Green
    return $created
}

function Get-Stage8DItemUrl {
    param(
        [string]$ListTitle,
        [int]$ItemId
    )

    if ($ItemId -le 0) {
        return ""
    }

    $list = Get-PnPList -Identity $ListTitle -Includes RootFolder
    $siteUri = [uri]$GuidedSiteUrl
    $authority = $siteUri.GetLeftPart([System.UriPartial]::Authority)
    $itemPath = ("{0}/DispForm.aspx?ID={1}" -f $list.RootFolder.ServerRelativeUrl, $ItemId)
    $itemPath = $itemPath -replace " ", "%20"
    return ("{0}{1}" -f $authority.TrimEnd("/"), $itemPath)
}

function Add-ReadbackRow {
    param(
        [System.Collections.Generic.List[object]]$Rows,
        [string]$StepId,
        [string]$Phase,
        [string]$ListTitle,
        [object]$Item,
        [string]$Outcome,
        [string]$FrictionPoint,
        [string]$FollowUp
    )

    $itemId = 0
    $title = ""
    if ($null -ne $Item) {
        $itemId = [int]$Item.Id
        if ($Item.PSObject.Properties.Name -contains "FieldValues") {
            $title = [string]$Item.FieldValues["Title"]
        }
    }

    $Rows.Add([pscustomobject]@{
        RunDate = (Get-Date).ToString("s")
        BrowserProfile = "Production PnP read-back"
        RecordPrefix = $RecordKey
        StepId = $StepId
        Phase = $Phase
        Outcome = $Outcome
        ListTitle = $ListTitle
        ItemId = $itemId
        Title = $title
        RecordOrEvidenceLink = Get-Stage8DItemUrl -ListTitle $ListTitle -ItemId $itemId
        FrictionPoint = $FrictionPoint
        FollowUp = $FollowUp
    }) | Out-Null
}

function Assert-ApprovalPhrase {
    $expectedPhrase = "record-stage-8d-internal-workflow-proof"

    if (-not $Apply) {
        return
    }

    Write-Host ""
    Write-Host "Live write approval required." -ForegroundColor Yellow
    Write-Host ("Type exactly: {0}" -f $expectedPhrase) -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($ApprovalPhrase)) {
        Write-Host "Approval phrase supplied by command parameter." -ForegroundColor Gray
        $typed = $ApprovalPhrase
    }
    else {
        $typed = Read-Host "Approval phrase"
    }
    if ($typed -ne $expectedPhrase) {
        throw "Approval phrase did not match. No live writes performed."
    }
}

$today = Get-Date
$ownerLogin = $null
$rows = [System.Collections.Generic.List[object]]::new()

Write-Host "Microsoft 365 Stage 8D - Internal workflow proof" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY with typed approval' } else { 'DRY RUN' })" -ForegroundColor Gray
Write-Host "RecordKey:  $RecordKey" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host "Safety:     Internal dummy List records only; no mail, sharing, guests, permissions, consent, policy, deletion, or automation." -ForegroundColor Gray

try {
    Assert-ApprovalPhrase

    Write-Section "Connect to Guided AI Labs"
    Connect-Stage8DPnP -TargetSiteUrl $GuidedSiteUrl
    $ownerLogin = Resolve-Stage8DUserFieldValue -UserPrincipalName $OwnerUpn

    Write-Section "Verify target Lists"
    @(
        "Guided AI Labs - Intake Register",
        "CRM - Organizations",
        "CRM - Contacts",
        "CRM - Engagements",
        "CRM - Qualification",
        "CRM - Stakeholder Map",
        "CRM - Touchpoints",
        "CRM - Action Queue",
        "CRM - Lifecycle Checklist",
        "CRM - Artifacts",
        "Agent Action Log"
    ) | ForEach-Object {
        Get-PnPList -Identity $_ -ErrorAction Stop | Out-Null
        Write-Host ("  [OK] Found List: {0}" -f $_) -ForegroundColor Green
    }

    Write-Section "Create or update workflow proof records"
    $intake = Set-Stage8DListItem -ListTitle "Guided AI Labs - Intake Register" -Values @{
        Title = "$RecordKey - Internal readiness signal"
        SourceMailbox = "contact@"
        SourceMessageId = "$RecordKey-internal"
        ReceivedDate = $today
        RequesterName = "Guided AI Labs Internal Workflow Proof"
        RequesterEmail = $OwnerUpn
        Organization = "Guided AI Labs"
        IntakeClass = "new-inquiry"
        Priority = "Normal"
        IntakeStatus = "Triage"
        ItemOwner = $ownerLogin
        NextAction = "Use this internal dummy signal to prove the CRM path from intake through handoff evidence."
        HumanApprovalRequired = $true
        AgentNotes = "Stage 8D internal production proof. No client data, no external contact, no email sent."
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-02" -Phase "Create intake signal" -ListTitle "Guided AI Labs - Intake Register" -Item $intake -Outcome "Pass" -FrictionPoint "" -FollowUp "Use the simplified intake form for future manual entries."

    $organization = Set-Stage8DListItem -ListTitle "CRM - Organizations" -Values @{
        Title = "$RecordKey - Guided AI Labs Internal Proof"
        RecordKey = "$RecordKey-ORG"
        SourceSystem = "Manual"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Continue internal CRM workflow proof and confirm the daily path is usable."
        LastReviewed = $today
        Notes = "Internal walkthrough organization only. Not a client or external prospect."
        OrganizationType = "Internal"
        RelationshipStatus = "Active"
        PrimaryDomain = "guidedailabs.com"
        PrimaryOwner = $ownerLogin
        CurrentEngagementKey = "$RecordKey-ENG"
        NextActionDueDate = $today.AddDays(2)
        Priority = "Normal"
        OperationalHealth = "Green"
        ReviewCadence = "As needed"
        AccountTier = "Emerging"
    }

    $contact = Set-Stage8DListItem -ListTitle "CRM - Contacts" -Values @{
        Title = "$RecordKey - Adam Internal Operator"
        RecordKey = "$RecordKey-CONTACT"
        SourceSystem = "Manual"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Confirm the internal workflow proof can be followed from the command center."
        LastReviewed = $today
        Notes = "Internal walkthrough contact only."
        ContactEmail = $OwnerUpn
        OrganizationKey = "$RecordKey-ORG"
        RoleTitle = "Internal operator"
        RelationshipRole = "Sponsor"
        CommunicationStatus = "Active"
        PreferredChannel = "Teams"
        OrganizationLookup = $organization.Id
        NextActionDueDate = $today.AddDays(2)
        Priority = "Normal"
        LastContacted = $today
        ContactBoundary = "Requires Adam review"
    }

    $engagement = Set-Stage8DListItem -ListTitle "CRM - Engagements" -Values @{
        Title = "$RecordKey - CRM workflow proof"
        RecordKey = "$RecordKey-ENG"
        SourceSystem = "Intake Register"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Validate CRM action queue, lifecycle checklist, and handoff evidence surface."
        LastReviewed = $today
        Notes = "Internal Stage 8D proof engagement. No external/client commitment."
        OrganizationKey = "$RecordKey-ORG"
        PrimaryContactKey = "$RecordKey-CONTACT"
        EntryPackage = "Readiness Snapshot"
        CurrentPackage = "Workspace Build"
        TargetPackage = "Guided Implementation"
        EngagementStage = "Onboarding"
        ExecutionStage = "Mobilizing"
        SuccessCriteria = "A clear daily path exists from intake to qualification, engagement, action, delivery, and evidence."
        RiskLevel = "Low"
        OrganizationLookup = $organization.Id
        PrimaryContactLookup = $contact.Id
        NextActionDueDate = $today.AddDays(2)
        Priority = "Normal"
        OperationalHealth = "Green"
        DecisionStatus = "Discovery"
        DecisionDueDate = $today.AddDays(7)
        EstimatedValue = 0
        ProbabilityPercent = 50
        NextMilestone = "Confirm CRM proof path"
        TargetGoLiveDate = $today.AddDays(14)
        HandoffStatus = "In progress"
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-04" -Phase "Create CRM spine records" -ListTitle "CRM - Engagements" -Item $engagement -Outcome "Pass" -FrictionPoint "" -FollowUp "Review the engagement in Pipeline by Stage and Delivery Control."

    $qualification = Set-Stage8DListItem -ListTitle "CRM - Qualification" -Values @{
        Title = "$RecordKey - Qualification"
        SignalSource = "Internal idea"
        QualificationStatus = "Researching"
        FitScore = 85
        Urgency = "Medium"
        BudgetSignal = "Not applicable"
        AuthoritySignal = "Decision maker"
        NeedSummary = "Internal proof that CRM intake can become qualified operating work without client data."
        RecommendedPackage = "Workspace Build"
        NextAction = "Confirm this qualification row is visible from the CRM Command Center."
        NextActionDueDate = $today.AddDays(2)
        ItemOwner = $ownerLogin
        OrganizationLookup = $organization.Id
        ContactLookup = $contact.Id
        EngagementLookup = $engagement.Id
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-03" -Phase "Qualify signal" -ListTitle "CRM - Qualification" -Item $qualification -Outcome "Pass" -FrictionPoint "" -FollowUp "Use Qualification Triage to decide whether to convert or nurture."

    $stakeholder = Set-Stage8DListItem -ListTitle "CRM - Stakeholder Map" -Values @{
        Title = "$RecordKey - Stakeholder role"
        RecordKey = "$RecordKey-STAKEHOLDER"
        SourceSystem = "Manual"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Keep the proof owner explicit while validating handoff readiness."
        LastReviewed = $today
        Notes = "Internal stakeholder map proof row."
        EngagementKey = "$RecordKey-ENG"
        ContactKey = "$RecordKey-CONTACT"
        StakeholderRole = "Sponsor"
        InfluenceLevel = "High"
        EngagementLevel = "Active"
        DecisionRole = "Approver"
        EngagementLookup = $engagement.Id
        ContactLookup = $contact.Id
        NextActionDueDate = $today.AddDays(2)
        Priority = "Normal"
        Sentiment = "Positive"
        RelationshipRisk = "Low"
    }

    $touchpoint = Set-Stage8DListItem -ListTitle "CRM - Touchpoints" -Values @{
        Title = "$RecordKey - Internal touchpoint"
        RecordKey = "$RecordKey-TOUCHPOINT"
        SourceSystem = "Manual"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Use action queue and checklist to carry the proof forward."
        LastReviewed = $today
        Notes = "Internal walkthrough touchpoint."
        EngagementKey = "$RecordKey-ENG"
        ContactKey = "$RecordKey-CONTACT"
        TouchpointDate = $today
        Channel = "Teams"
        Direction = "Internal"
        Summary = "Internal Stage 8D proof touchpoint created by approved production operator."
        FollowUpRequired = $true
        FollowUpDueDate = $today.AddDays(2)
        EngagementLookup = $engagement.Id
        ContactLookup = $contact.Id
        Priority = "Normal"
        TouchpointOutcome = "Info captured"
        NextTouchpointType = "Internal review"
    }

    $action = Set-Stage8DListItem -ListTitle "CRM - Action Queue" -Values @{
        Title = "$RecordKey - Next CRM action"
        RecordKey = "$RecordKey-ACTION"
        ItemOwner = $ownerLogin
        ActionType = "Delivery"
        ActionStatus = "In progress"
        Priority = "Normal"
        DueDate = $today.AddDays(2)
        NextAction = "Review the proof records from the CRM Command Center and decide whether Teams tabs are ready."
        Outcome = "Internal proof action created; no external or client action."
        BlocksDecision = $false
        BlocksGoLive = $false
        SourceSystem = "Intake Register"
        OrganizationLookup = $organization.Id
        EngagementLookup = $engagement.Id
        ContactLookup = $contact.Id
        TouchpointLookup = $touchpoint.Id
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-05" -Phase "Record action" -ListTitle "CRM - Action Queue" -Item $action -Outcome "Pass" -FrictionPoint "No real internal scope decision was needed, so Decision Register was not changed." -FollowUp "Complete or close this action after Adam reviews the browser path."

    $checklist = Set-Stage8DListItem -ListTitle "CRM - Lifecycle Checklist" -Values @{
        Title = "$RecordKey - Handoff checklist"
        RecordKey = "$RecordKey-CHECKLIST"
        SourceSystem = "Manual"
        ItemOwner = $ownerLogin
        CRMStatus = "Active"
        NextAction = "Confirm handoff evidence points back to the CRM proof engagement."
        LastReviewed = $today
        Notes = "Internal delivery/handoff checklist proof row."
        EngagementKey = "$RecordKey-ENG"
        ChecklistPhase = "Handoff"
        ChecklistItem = "Confirm internal proof path has a durable evidence pointer."
        DueDate = $today.AddDays(7)
        ChecklistStatus = "In progress"
        BlocksOfframp = $false
        EngagementLookup = $engagement.Id
        Priority = "Normal"
        Workstream = "Handoff"
        RequiredForGoLive = $false
        SortOrder = 10
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-06" -Phase "Move to active delivery" -ListTitle "CRM - Lifecycle Checklist" -Item $checklist -Outcome "Pass" -FrictionPoint "" -FollowUp "Use checklist/handoff views to confirm delivery state remains visible."

    $artifact = Set-Stage8DListItem -ListTitle "CRM - Artifacts" -Values @{
        Title = "$RecordKey - Handoff evidence"
        ArtifactType = "Evidence"
        ArtifactStatus = "Ready for review"
        ArtifactLink = "$GuidedSiteUrl/SitePages/Relationship-CRM-Command-Center.aspx, CRM Command Center"
        VersionLabel = "stage-8d-proof"
        EvidenceDate = $today
        ReviewDueDate = $today.AddDays(7)
        ApprovedForClientUse = $false
        Notes = "Internal placeholder evidence proving the CRM path can end with a durable pointer."
        ItemOwner = $ownerLogin
        OrganizationLookup = $organization.Id
        EngagementLookup = $engagement.Id
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-07" -Phase "Capture handoff evidence" -ListTitle "CRM - Artifacts" -Item $artifact -Outcome "Pass" -FrictionPoint "" -FollowUp "Keep ApprovedForClientUse false until a real client artifact is reviewed."

    $agentLog = Set-Stage8DListItem -ListTitle "Agent Action Log" -Values @{
        Title = "$RecordKey - Stage 8D workflow proof logged"
        ActionDate = $today
        AgentSurface = "Codex"
        ActionType = "create-record"
        ActionStatus = "Completed"
        HumanApprover = $ownerLogin
        Result = "Approved Stage 8D internal workflow proof created linked dummy records across intake, qualification, CRM spine, action queue, lifecycle checklist, artifact evidence, and this action log. No mail, guests, sharing, permissions, app grants, tenant policy, public Forms, deletion, Dynamics/Dataverse, or unattended automation."
    }
    Add-ReadbackRow -Rows $rows -StepId "8d-01" -Phase "Open daily cockpit" -ListTitle "Agent Action Log" -Item $agentLog -Outcome "Pass" -FrictionPoint "Browser subjective review still belongs with Adam, but production records now prove the back-end path." -FollowUp "Adam should visually confirm the cockpit and command center are now understandable."

    if ($Apply) {
        $rows | Sort-Object StepId | Export-Csv -Path $readbackPath -NoTypeInformation
        Write-Host ("Read-back CSV: {0}" -f $readbackPath) -ForegroundColor Green
    }
    else {
        Write-Host "Dry run complete. No tenant records were created or updated." -ForegroundColor Yellow
    }

    Write-Section "Done"
    Write-Host "Stage 8D internal workflow proof completed." -ForegroundColor Green
}
finally {
    try {
        Stop-Transcript | Out-Null
    }
    catch {}

    if (-not $NoPause) {
        Write-Host ""
        Read-Host "Press Enter to close"
    }
}
