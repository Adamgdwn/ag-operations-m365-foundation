param(
    [ValidateSet("RecordDecision", "CoordinatorSuggestion", "SupportTriage", "BridgeReadinessControl")]
    [string]$Action = "RecordDecision",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$GuidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$SupportSiteUrl = "https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [switch]$Apply,
    [string]$ApprovalPhrase,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# Stage 9 - governed M365 coordinator/support first loops.
# Dry-run-first and typed-approval for every live write. This script writes only
# to approved operating Lists. It does not create app registrations, grant
# consent, send mail, invite guests, change sharing, alter permissions, change
# tenant policy, publish Forms, delete records, or run unattended automation.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage9AgentCapabilityLoopInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-9-agentic-os-bridge"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-9-agent-capability-loop-{0}-{1}.log" -f $Action.ToLowerInvariant(), (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Get-Stage9ClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-Stage9ExpectedUser {
    param([string]$TargetSiteUrl)

    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-Stage9ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-Stage9ClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-Stage9PnP {
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
    Assert-Stage9ExpectedUser -TargetSiteUrl $TargetSiteUrl

    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function Resolve-Stage9UserFieldValue {
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

function Set-Stage9ListItem {
    param(
        [string]$ListTitle,
        [hashtable]$Values
    )

    $title = [string]$Values["Title"]
    $existing = @(Get-ListItemByTitle -ListTitle $ListTitle -Title $title)

    if (-not $Apply) {
        if ($existing.Count -gt 0) {
            Write-Host ("  DRY RUN: would update existing {0} item: {1}" -f $ListTitle, $title) -ForegroundColor Yellow
        }
        else {
            Write-Host ("  DRY RUN: would create {0} item: {1}" -f $ListTitle, $title) -ForegroundColor Yellow
        }
        return
    }

    if ($existing.Count -gt 0) {
        Set-PnPListItem -List $ListTitle -Identity $existing[0].Id -Values $Values | Out-Null
        Write-Host ("  [OK] Updated {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Green
    }
    else {
        $created = Add-PnPListItem -List $ListTitle -Values $Values
        Write-Host ("  [OK] Created {0} item #{1}: {2}" -f $ListTitle, $created.Id, $title) -ForegroundColor Green
    }
}

function Assert-ApprovalPhrase {
    param([string]$ExpectedPhrase)

    if (-not $Apply) {
        return
    }

    Write-Host ""
    Write-Host "Live write approval required." -ForegroundColor Yellow
    Write-Host ("Type exactly: {0}" -f $ExpectedPhrase) -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($ApprovalPhrase)) {
        Write-Host "Approval phrase supplied by command parameter." -ForegroundColor Gray
        $typed = $ApprovalPhrase
    }
    else {
        $typed = Read-Host "Approval phrase"
    }
    if ($typed -ne $ExpectedPhrase) {
        throw "Approval phrase did not match. No live writes performed."
    }
}

function Invoke-RecordDecision {
    param([string]$OwnerLogin)

    Write-Section "Verify target Lists"
    Get-PnPList -Identity "Decision Register" -ErrorAction Stop | Out-Null
    Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop | Out-Null
    Write-Host "  Found Decision Register and Agent Action Log" -ForegroundColor Green

    $decisionText = @"
Approved the local Stage 9 M365 Coordinator and M365 Support Agent capability model for supervised first loops.

The coordinator may write only within G1/G2 internal operating lanes: Suggested Agent Action Log rows, approved intake/list updates, approved Decision Register entries, approved automation/tool-review records, and supervised Planner task updates.

The support agent may write only within G1/G2 support lanes: Suggested Agent Action Log rows, approved Change Leadership Tools Support Register updates, approved mailbox drafts, and supervised support follow-up tasks.

G3/G4 actions remain blocked without explicit human approval: external sends, guest invites, sharing or permission changes, app consent, tenant policy, public/client Forms, destructive deletes, secrets, and break-glass accounts.
"@.Trim()

    $rationale = @"
This creates real read/write operating capability without inheriting broad setup grants or turning the existing agent-pnp-provisioning helper into a production bridge. SharePoint Selected permissions and Exchange Application RBAC remain future app-posture options, not live grants from this decision.
"@.Trim()

    $result = @"
Codex created the local Stage 9 capability model, generated the local packet, and prepared dry-run-first loop operators. No app registrations, consent grants, mail sends, guests, sharing changes, permission changes, tenant policy changes, public Forms, deletions, or unattended automation were created.
"@.Trim()

    $decisionValues = @{
        Title = "Stage 9 M365 coordinator and support agent capability approved for supervised loops"
        DecisionDate = Get-Date
        DecisionOwner = $OwnerLogin
        DecisionArea = "Agent"
        Decision = $decisionText
        Rationale = $rationale
        RevisitDate = (Get-Date).AddDays(30)
    }

    $actionValues = @{
        Title = "Stage 9 agent capability model prepared"
        ActionDate = Get-Date
        AgentSurface = "Codex"
        ActionType = "recommend"
        ActionStatus = "Completed"
        HumanApprover = $OwnerLogin
        Result = $result
    }

    Write-Section "Record operating evidence"
    Set-Stage9ListItem -ListTitle "Decision Register" -Values $decisionValues
    Set-Stage9ListItem -ListTitle "Agent Action Log" -Values $actionValues
}

function Invoke-CoordinatorSuggestion {
    param([string]$OwnerLogin)

    Write-Section "Read operating state"
    $intakeList = Get-PnPList -Identity "Guided AI Labs - Intake Register" -ErrorAction Stop
    $actionLog = Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop
    $recentIntake = @(Get-PnPListItem -List $intakeList.Title -PageSize 25 -ErrorAction Stop)
    Write-Host ("  Read {0} recent intake item(s)" -f $recentIntake.Count) -ForegroundColor Green
    Write-Host ("  Found action log: {0}" -f $actionLog.Title) -ForegroundColor Green

    $result = @"
G1 coordinator loop read the intake register and prepared a Suggested action-log row. This loop is intentionally limited to propose/log behavior: no intake rows, Planner tasks, mail, guests, sharing, permissions, app grants, tenant policy, public Forms, deletions, or automation were changed.
"@.Trim()

    $actionValues = @{
        Title = "Stage 9 coordinator suggestion loop"
        ActionDate = Get-Date
        AgentSurface = "future bridge"
        ActionType = "recommend"
        ActionStatus = "Suggested"
        HumanApprover = $OwnerLogin
        Result = $result
    }

    Write-Section "Record G1 suggestion"
    Set-Stage9ListItem -ListTitle "Agent Action Log" -Values $actionValues
}

function Invoke-SupportTriage {
    param([string]$OwnerLogin)

    Write-Section "Verify support List"
    Get-PnPList -Identity "Change Leadership Tools - Support Register" -ErrorAction Stop | Out-Null
    Write-Host "  Found Change Leadership Tools - Support Register" -ForegroundColor Green

    $supportValues = @{
        Title = "Stage 9 supervised support triage test"
        SourceMailbox = "support@"
        ReceivedDate = Get-Date
        RequesterName = "Internal Stage 9 Test"
        RequesterEmail = "support@changeleadershiptools.com"
        Organization = "Guided AI Labs"
        ProductArea = "Other"
        IssueType = "Question"
        Severity = "Low"
        Priority = "Low"
        SupportStatus = "Triage"
        ItemOwner = $OwnerLogin
        NextAction = "Confirm support agent G2 list-write loop; do not send external mail from this test."
        ResolutionSummary = "Stage 9 support loop test only; no customer-impacting action."
        KnowledgeCandidate = $false
        HumanApprovalRequired = $true
        AgentNotes = "Created by approved Stage 9 support triage loop. No external email sent."
    }

    Write-Section "Record support triage row"
    Set-Stage9ListItem -ListTitle "Change Leadership Tools - Support Register" -Values $supportValues

    Write-Section "Connect back to Guided AI Labs for action log"
    Connect-Stage9PnP -TargetSiteUrl $GuidedSiteUrl
    $guidedOwnerLogin = Resolve-Stage9UserFieldValue -UserPrincipalName $OwnerUpn
    Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop | Out-Null

    $result = @"
G2 support triage loop created or updated the supervised support triage test row and logged the result. No mailbox draft was created, no external email was sent, and no guests, sharing, permissions, app grants, tenant policy, public Forms, deletions, or automation were changed.
"@.Trim()

    $actionValues = @{
        Title = "Stage 9 support triage loop"
        ActionDate = Get-Date
        AgentSurface = "future bridge"
        ActionType = "create-record"
        ActionStatus = "Completed"
        HumanApprover = $guidedOwnerLogin
        Result = $result
    }

    Set-Stage9ListItem -ListTitle "Agent Action Log" -Values $actionValues
}

function Invoke-BridgeReadinessControl {
    param([string]$OwnerLogin)

    Write-Section "Verify target Lists"
    Get-PnPList -Identity "Decision Register" -ErrorAction Stop | Out-Null
    Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop | Out-Null
    Write-Host "  Found Decision Register and Agent Action Log" -ForegroundColor Green

    $decisionText = @"
Approved the Stage 9 bridge readiness control posture for the next live work window.

The current production posture remains supervised delegated. No production UAOS/M365 adapter is approved yet. No new app registration, consent grant, SharePoint Selected permission grant, Exchange Application RBAC assignment, tenant policy change, external send, guest access, public Form, sharing change, deletion, or unattended automation is approved by this decision.

The setup helper app remains setup-only and must not be reused as production bridge power. The Stage 8D internal workflow proof is now live-recorded/read-back verified, but future adapter work still requires the remaining named graduation gates: setup-helper resting-state decision, support MFA, permission-scope design, rollback/pause worksheet, G0/G1 dry run, and a separate production bridge decision.
"@.Trim()

    $rationale = @"
Stage 9 now has live-proven supervised List loops, a local bridge readiness control packet, and Stage 8D internal workflow proof evidence. Recording the updated posture in M365 keeps the system auditable while preventing quiet drift from setup tooling into permanent automation authority.
"@.Trim()

    $result = @"
Stage 9 bridge readiness control was recorded as a governed M365 decision and action-log entry after the Stage 8D internal proof. The approved next posture is supervised delegated evidence work only; app registrations, consent, permission grants, mailbox adapter work, external/client-impacting actions, and unattended automation remain blocked pending separate approval gates.
"@.Trim()

    $decisionValues = @{
        Title = "Stage 9 bridge readiness control posture approved"
        DecisionDate = Get-Date
        DecisionOwner = $OwnerLogin
        DecisionArea = "Agent"
        Decision = $decisionText
        Rationale = $rationale
        RevisitDate = (Get-Date).AddDays(14)
    }

    $actionValues = @{
        Title = "Stage 9 bridge readiness control recorded"
        ActionDate = Get-Date
        AgentSurface = "Codex"
        ActionType = "recommend"
        ActionStatus = "Completed"
        HumanApprover = $OwnerLogin
        Result = $result
    }

    Write-Section "Record bridge readiness evidence"
    Set-Stage9ListItem -ListTitle "Decision Register" -Values $decisionValues
    Set-Stage9ListItem -ListTitle "Agent Action Log" -Values $actionValues
}

$approvalPhrases = @{
    RecordDecision = "record-stage-9-agent-capability-decision"
    CoordinatorSuggestion = "record-stage-9-coordinator-suggestion"
    SupportTriage = "record-stage-9-support-triage"
    BridgeReadinessControl = "record-stage-9-bridge-readiness-control"
}

Write-Host "Microsoft 365 Stage 9 - Agent capability loop" -ForegroundColor Cyan
Write-Host "Action:     $Action" -ForegroundColor Gray
Write-Host "Mode:       $(if ($Apply) { 'APPLY with typed approval' } else { 'DRY RUN' })" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host "Safety:     List records only; no mail sends, guests, sharing, consent, tenant policy, deletion, or automation." -ForegroundColor Gray

Assert-ApprovalPhrase -ExpectedPhrase $approvalPhrases[$Action]

switch ($Action) {
    "RecordDecision" {
        Write-Section "Connect to Guided AI Labs"
        Connect-Stage9PnP -TargetSiteUrl $GuidedSiteUrl
        $ownerLogin = Resolve-Stage9UserFieldValue -UserPrincipalName $OwnerUpn
        Invoke-RecordDecision -OwnerLogin $ownerLogin
    }
    "CoordinatorSuggestion" {
        Write-Section "Connect to Guided AI Labs"
        Connect-Stage9PnP -TargetSiteUrl $GuidedSiteUrl
        $ownerLogin = Resolve-Stage9UserFieldValue -UserPrincipalName $OwnerUpn
        Invoke-CoordinatorSuggestion -OwnerLogin $ownerLogin
    }
    "SupportTriage" {
        Write-Section "Connect to Change Leadership Tools"
        Connect-Stage9PnP -TargetSiteUrl $SupportSiteUrl
        $ownerLogin = Resolve-Stage9UserFieldValue -UserPrincipalName $OwnerUpn
        Invoke-SupportTriage -OwnerLogin $ownerLogin
    }
    "BridgeReadinessControl" {
        Write-Section "Connect to Guided AI Labs"
        Connect-Stage9PnP -TargetSiteUrl $GuidedSiteUrl
        $ownerLogin = Resolve-Stage9UserFieldValue -UserPrincipalName $OwnerUpn
        Invoke-BridgeReadinessControl -OwnerLogin $ownerLogin
    }
}

Write-Section "Done"
if ($Apply) {
    Write-Host "Stage 9 agent capability loop completed with approved List writes only." -ForegroundColor Green
}
else {
    Write-Host "Dry run complete. Re-run with -Apply to perform the approved List write." -ForegroundColor Yellow
}
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray

try {
    Stop-Transcript | Out-Null
}
catch {}
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
