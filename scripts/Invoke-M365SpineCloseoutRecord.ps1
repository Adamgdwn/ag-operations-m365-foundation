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

# Phase 1 spine closeout - record the Stage 7 final-close and Stage 9
# declared-ready / adapter-deferred decisions in operating-state Lists.
# This writes only to the existing Decision Register and Agent Action Log. It does
# not invite guests, change sharing, grant consent, revoke permissions, send mail,
# or alter tenant policy. Dry run is connection-free (preview only). The -Apply
# path uses one persisted sign-in plus a single Y confirmation (no typed phrase).

$ErrorActionPreference = "Stop"

# ----- Planned records (single source of truth for preview and write) ---------

$stage7DecisionTitle = "Stage 7 security and governance closed (2026-06-20)"
$stage7DecisionText = @"
Stage 7 (Security, Governance & External Sharing) is closed. Final closeout decisions (2026-06-20):
- Broad app grants (agent-pnp-provisioning, delegated AllSites.FullControl + Group.ReadWrite.All): LEFT CONSENTED AS-IS as an accepted residual risk, consistent with keeping Global Admin on the daily identity. Managed by MFA + consent discipline; revisit when JIT/PIM (Entra P1/P2) lands.
- Viva Engage system site external sharing: DISABLED (no external Viva Engage workflow exists), bringing it in line with the rest of the tenant.
- Support mailbox MFA (support@changeleadershiptools.com): registered by Adam.
- Root, A.G. Operations Ltd, and All Company sites: already disabled for external sharing (prior window).
"@.Trim()

$stage7Rationale = @"
Closes the last governance exceptions while keeping partner/client onboarding possible. The one accepted residual risk (broad app grant + GA on daily identity) is a deliberate, time-aware choice, not an oversight; it has a review trigger. Core operating and system sites are now uniformly disabled for external sharing.
"@.Trim()

$stage7ActionTitle = "Stage 7 Viva Engage sharing exception disabled and stage closed"
$stage7ActionResult = @"
Ran the dry-run-first Stage 7 site-sharing exception window with -IncludeVivaEngageSystemSite and applied SharingCapability=Disabled to the Viva Engage system site (root/legacy sites already disabled). Recorded the final Stage 7 closeout decisions. Stage 7 is complete.
"@.Trim()

$stage9DecisionTitle = "Stage 9 agentic bridge declared ready; production adapter deferred (2026-06-20)"
$stage9DecisionText = @"
Stage 9 (Agentic OS Bridge Readiness): DECLARED READY. The production app/adapter is intentionally deferred to a later deliberate decision - no new tenant power is granted now. This matches the Stage 9 exit criteria, which explicitly allow the adapter graduation gates to be deferred. The governed substrate (identity, records, governance ladder G0-G4, approval model) is in place and is what a future externally-built Agentic OS will connect to.
"@.Trim()

$stage9Rationale = @"
The spine is ready to be connected to, but standing up a production adapter would grant new autonomous power and is a separate, deliberate decision best made when the consuming Agentic OS is actually being built. Declaring ready now closes Phase 1 without over-provisioning; deferring the adapter keeps the interaction-surface != capability-surface contract intact.
"@.Trim()

$stage9ActionTitle = "Stage 9 readiness declared; adapter graduation deferred"
$stage9ActionResult = @"
Recorded the Stage 9 declare-ready / defer-adapter decision. No app registration, consent grant, or tenant power change was made. Phase 1 (the infrastructure spine) is complete; the production agentic adapter remains the explicitly deferred 'later bridge'.
"@.Trim()

$plannedDecisions = @(
    [pscustomobject]@{ Title = $stage7DecisionTitle; Area = "Governance"; Text = $stage7DecisionText; Rationale = $stage7Rationale; RevisitDate = [datetime]"2026-12-20T09:00:00" }
    [pscustomobject]@{ Title = $stage9DecisionTitle; Area = "Governance"; Text = $stage9DecisionText; Rationale = $stage9Rationale; RevisitDate = $null }
)

$plannedActions = @(
    [pscustomobject]@{ Title = $stage7ActionTitle; Type = "update-record"; Result = $stage7ActionResult }
    [pscustomobject]@{ Title = $stage9ActionTitle; Type = "update-record"; Result = $stage9ActionResult }
)

# ----- Preview (always; connection-free) --------------------------------------

Write-Host "Microsoft 365 Phase 1 Spine Closeout - Record decisions" -ForegroundColor Cyan
Write-Host "Site:   $SiteUrl" -ForegroundColor Gray
Write-Host "Mode:   $(if ($Apply) { 'APPLY list records' } else { 'DRY RUN (preview only, no sign-in)' })" -ForegroundColor Yellow
Write-Host "Writes: Decision Register, Agent Action Log only" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned Decision Register records:" -ForegroundColor Cyan
foreach ($d in $plannedDecisions) {
    Write-Host ("- [{0}] {1}" -f $d.Area, $d.Title) -ForegroundColor White
}
Write-Host ""
Write-Host "Planned Agent Action Log records:" -ForegroundColor Cyan
foreach ($a in $plannedActions) {
    Write-Host ("- ({0}, Completed) {1}" -f $a.Type, $a.Title) -ForegroundColor White
}
Write-Host ""
Write-Host "This operator writes only to the two Lists above. It does not change sharing, grant consent, invite guests, send mail, or alter tenant policy." -ForegroundColor Yellow
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply to write these records (one sign-in + single Y)." -ForegroundColor Green
    exit 0
}

# ----- Apply path (connect + single-Y + write) --------------------------------

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365SpineCloseoutRecordInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-7-security-governance"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("spine-closeout-record-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Connect-CloseoutPnP {
    param([string]$TargetSiteUrl)
    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $TargetSiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{ Url = $TargetSiteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
        if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
        Connect-PnPOnline @connectParams
    }
    $connection = Get-PnPConnection
    Write-Host ("Connected to {0} using {1}" -f $TargetSiteUrl, $connection.ConnectionType) -ForegroundColor Gray
    Assert-ExpectedUser -TargetSiteUrl $TargetSiteUrl
    $web = Get-PnPWeb -Includes Title,Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
}

function ConvertTo-XmlText {
    param([string]$Value)
    return [System.Security.SecurityElement]::Escape($Value)
}

function Get-ListItemByTitle {
    param([string]$ListTitle, [string]$Title)
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

function Set-CloseoutListItem {
    param([string]$ListTitle, [hashtable]$Values)
    $title = [string]$Values["Title"]
    $existing = @(Get-ListItemByTitle -ListTitle $ListTitle -Title $title)
    if ($existing.Count -gt 0) {
        Set-PnPListItem -List $ListTitle -Identity $existing[0].Id -Values $Values | Out-Null
        Write-Host ("  [OK] Updated {0} item #{1}: {2}" -f $ListTitle, $existing[0].Id, $title) -ForegroundColor Green
    }
    else {
        $created = Add-PnPListItem -List $ListTitle -Values $Values
        Write-Host ("  [OK] Created {0} item #{1}: {2}" -f $ListTitle, $created.Id, $title) -ForegroundColor Green
    }
}

function Resolve-UserFieldValue {
    param([string]$UserPrincipalName)
    $user = $null
    try { $user = Get-PnPUser -Identity $UserPrincipalName -ErrorAction SilentlyContinue } catch { $user = $null }
    if ($null -eq $user) { $user = New-PnPUser -LoginName $UserPrincipalName }
    if ($null -ne $user -and -not [string]::IsNullOrWhiteSpace($user.LoginName)) { return $user.LoginName }
    return $UserPrincipalName
}

Write-Section "Connect"
Connect-CloseoutPnP -TargetSiteUrl $SiteUrl
$ownerLogin = Resolve-UserFieldValue -UserPrincipalName $OwnerUpn

Write-Section "Verify target Lists"
$decisionList = Get-PnPList -Identity "Decision Register" -ErrorAction Stop
$actionLog = Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop
Write-Host ("  Found Decision Register: {0}" -f $decisionList.Title) -ForegroundColor Green
Write-Host ("  Found Agent Action Log: {0}" -f $actionLog.Title) -ForegroundColor Green

Write-Section "Approval"
$confirm = Read-Host "Write the 2 decision + 2 action closeout records now? Type Y to proceed"
if ($confirm -notin @("Y", "y")) {
    Write-Host "Not confirmed. Nothing was written." -ForegroundColor Yellow
    try { Stop-Transcript | Out-Null } catch {}
    if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close this window."; Read-Host | Out-Null }
    exit 0
}

Write-Section "Record closeout evidence"
$decisionDate = [datetime]"2026-06-20T09:30:00"
foreach ($d in $plannedDecisions) {
    $values = @{
        Title = $d.Title
        DecisionDate = $decisionDate
        DecisionOwner = $ownerLogin
        DecisionArea = $d.Area
        Decision = $d.Text
        Rationale = $d.Rationale
    }
    if ($null -ne $d.RevisitDate) { $values["RevisitDate"] = $d.RevisitDate }
    Set-CloseoutListItem -ListTitle "Decision Register" -Values $values
}
foreach ($a in $plannedActions) {
    $values = @{
        Title = $a.Title
        ActionDate = $decisionDate
        AgentSurface = "Claude Code"
        ActionType = $a.Type
        ActionStatus = "Completed"
        HumanApprover = $ownerLogin
        Result = $a.Result
    }
    Set-CloseoutListItem -ListTitle "Agent Action Log" -Values $values
}

Write-Section "Done"
Write-Host "Phase 1 spine closeout records written to Microsoft Lists. Stage 7 closed; Stage 9 declared ready (adapter deferred)." -ForegroundColor Green
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray

try { Stop-Transcript | Out-Null } catch {}
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
