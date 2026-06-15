param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# Stage 7 - record the approved governance write window in operating-state Lists.
# This writes only to the existing Decision Register and Agent Action Log. It does
# not invite guests, change sharing, grant consent, revoke permissions, send mail,
# or alter tenant policy.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-7-security-governance"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-7-record-governance-decision-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Get-Stage7ClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-Stage7ExpectedUser {
    param([string]$TargetSiteUrl)

    $authority = ([uri]$TargetSiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-Stage7ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-Stage7ClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-Stage7PnP {
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
    Assert-Stage7ExpectedUser -TargetSiteUrl $TargetSiteUrl

    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function ConvertTo-XmlText {
    param([string]$Value)
    return [System.Security.SecurityElement]::Escape($Value)
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

function Set-Stage7ListItem {
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

function Resolve-Stage7UserFieldValue {
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

Write-Host "Microsoft 365 Stage 7 - Record governance decision" -ForegroundColor Cyan
Write-Host "Site:   $SiteUrl" -ForegroundColor Gray
Write-Host "Log:    $transcriptPath" -ForegroundColor Gray
Write-Host "Mode:   $(if ($Apply) { 'APPLY list records' } else { 'DRY RUN' })" -ForegroundColor Gray
Write-Host "Writes: Decision Register, Agent Action Log only" -ForegroundColor Gray

Write-Section "Connect"
Connect-Stage7PnP -TargetSiteUrl $SiteUrl
$ownerLogin = Resolve-Stage7UserFieldValue -UserPrincipalName $OwnerUpn

Write-Section "Verify target Lists"
$decisionList = Get-PnPList -Identity "Decision Register" -ErrorAction Stop
$actionLog = Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop
Write-Host ("  Found Decision Register: {0}" -f $decisionList.Title) -ForegroundColor Green
Write-Host ("  Found Agent Action Log: {0}" -f $actionLog.Title) -ForegroundColor Green

$decisionTitle = "Stage 7 governance baseline tightened and verified"
$decisionText = @"
Approved and applied the Stage 7 governance write window:
- Entra guest invitations restricted from everyone to adminsAndGuestInviters.
- SharePoint tenant sharing restricted from ExternalUserAndGuestSharing to ExternalUserSharingOnly.
- SharePoint default sharing link changed from AnonymousAccess to Direct / specific people.

Post-change read-back verified in inventory/stage-7-security-governance/20260614-193825.
"@.Trim()

$rationale = @"
This keeps partner/client onboarding possible while removing broad default sharing and casual guest-invite paths before real external collaboration begins. Core operating sites remain disabled for external sharing; future exceptions require a named business workflow and review trail.
"@.Trim()

$actionResult = @"
Codex built and ran the dry-run-first Stage 7 governance write window, captured pre/post read-only evidence, and updated the operating documents. Remaining Stage 7 items are support mailbox MFA, broad setup app resting-state review, and root/legacy site exception review.
"@.Trim()

$decisionValues = @{
    Title = $decisionTitle
    DecisionDate = [datetime]"2026-06-14T19:45:00"
    DecisionOwner = $ownerLogin
    DecisionArea = "Governance"
    Decision = $decisionText
    Rationale = $rationale
    RevisitDate = [datetime]"2026-07-14T09:00:00"
}

$actionValues = @{
    Title = "Stage 7 governance write window applied and verified"
    ActionDate = [datetime]"2026-06-14T19:45:00"
    AgentSurface = "Codex"
    ActionType = "update-record"
    ActionStatus = "Completed"
    HumanApprover = $ownerLogin
    Result = $actionResult
}

Write-Section "Record operating evidence"
Set-Stage7ListItem -ListTitle "Decision Register" -Values $decisionValues
Set-Stage7ListItem -ListTitle "Agent Action Log" -Values $actionValues

Write-Section "Done"
if ($Apply) {
    Write-Host "Stage 7 governance decision and agent action records are now written to Microsoft Lists." -ForegroundColor Green
}
else {
    Write-Host "Dry run complete. Re-run with -Apply to write the records." -ForegroundColor Yellow
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
