param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$GuidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$OwnerUpn = "adamgoodwin@guidedailabs.com",
    [int]$StaleIntakeDays = 14,
    [int]$RevisitSoonDays = 7,
    [int]$EngagementReviewDays = 30,
    [int]$OrgTouchDays = 60,
    [int]$SuggestionAgeDays = 7,
    [switch]$Apply,
    [switch]$Approve,
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# M365 Coordinator - daily read loop (G0 read + G1 propose-and-log).
#
# This is the "intelligent" version of the Stage 9 coordinator loop: instead of
# writing a canned row, it reads the live operating Lists, applies dated
# detection rules, and produces content-specific findings.
#
# - G0 (always): read-only inventory of operating Lists + a local digest file.
#   No tenant write happens in dry-run mode.
# - G1 (only with -Apply): write ONE Suggested Agent Action Log row summarising
#   the findings, for human review. The live write asks for a single Y approval
#   (one click). Sign-in is interactive and persisted, so a session signs in once.
#
# It never creates app registrations, grants consent, sends mail, invites guests,
# changes sharing, alters permissions, changes tenant policy, publishes Forms,
# deletes records, or runs unattended automation. The single G1 write is a
# Suggested row only; nothing is approved or executed by this script.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365CoordinatorDailyReadInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$now = Get-Date
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$digestRoot = Join-Path $workspaceRoot "inventory\coordinator-daily-read"
New-Item -ItemType Directory -Path $digestRoot -Force | Out-Null
$stamp = $now.ToString("yyyyMMdd-HHmmss")
$transcriptPath = Join-Path $digestRoot ("coordinator-daily-read-{0}.log" -f $stamp)
$digestPath = Join-Path $digestRoot ("coordinator-daily-read-{0}.md" -f $stamp)
$digestRelative = $digestPath.Substring($workspaceRoot.Length).TrimStart('\', '/')

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

function Connect-CoordinatorPnP {
    param([string]$TargetSiteUrl)
    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $TargetSiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{
            Url         = $TargetSiteUrl
            ClientId    = $ClientId
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
    Assert-ExpectedUser -TargetSiteUrl $TargetSiteUrl
    $web = Get-PnPWeb -Includes Title, Url
    Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
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

# --- read helpers ----------------------------------------------------------

function Get-ListRows {
    param([string]$ListTitle)
    try {
        $list = Get-PnPList -Identity $ListTitle -ErrorAction Stop
    }
    catch {
        Write-Host ("  [skip] List not found or not readable: {0}" -f $ListTitle) -ForegroundColor Yellow
        return $null
    }
    $rows = @(Get-PnPListItem -List $list.Title -PageSize 500 -ErrorAction Stop)
    Write-Host ("  Read {0} row(s) from {1}" -f $rows.Count, $list.Title) -ForegroundColor Green
    return $rows
}

function Get-FV {
    param([object]$Item, [string]$Name)
    if ($null -eq $Item) { return $null }
    if (-not $Item.FieldValues.ContainsKey($Name)) { return $null }
    return $Item.FieldValues[$Name]
}

function Get-FVText {
    param([object]$Item, [string]$Name)
    $value = Get-FV -Item $Item -Name $Name
    if ($null -eq $value) { return "" }
    $text = [string]$value
    # strip simple HTML that Note fields can carry
    $text = ($text -replace '<[^>]+>', ' ')
    $text = ($text -replace '&nbsp;', ' ')
    return $text.Trim()
}

function Get-FVDate {
    param([object]$Item, [string]$Name)
    $value = Get-FV -Item $Item -Name $Name
    if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)) { return $null }
    try {
        return [datetime]$value
    }
    catch {
        return $null
    }
}

$findings = New-Object System.Collections.Generic.List[object]
function Add-Finding {
    param(
        [string]$Category,
        [ValidateSet("High", "Medium", "Low")][string]$Severity,
        [string]$Item,
        [string]$Detail
    )
    $findings.Add([pscustomobject]@{
            Category = $Category
            Severity = $Severity
            Item     = $Item
            Detail   = $Detail
        }) | Out-Null
}

$openIntakeStates = @("New", "Triage", "In Progress", "Waiting on Adam")
$highPriority = @("High", "Urgent")

# --- main ------------------------------------------------------------------

Write-Host "Microsoft 365 - Coordinator daily read" -ForegroundColor Cyan
Write-Host ("Date:       {0}" -f $now.ToString("yyyy-MM-dd HH:mm")) -ForegroundColor Gray
Write-Host ("Mode:       {0}" -f $(if ($Apply) { 'APPLY: G0 read + one G1 Suggested row (single Y approval)' } else { 'DRY RUN: G0 read + local digest only' })) -ForegroundColor Gray
Write-Host ("Digest:     {0}" -f $digestPath) -ForegroundColor Gray
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
Write-Host "Safety:     Read-only analysis. The only possible write is ONE Suggested Agent Action Log row." -ForegroundColor Gray

Write-Section "Connect to Guided AI Labs"
Connect-CoordinatorPnP -TargetSiteUrl $GuidedSiteUrl

Write-Section "Read operating Lists (G0)"

# Intake Register
$intake = Get-ListRows -ListTitle "Guided AI Labs - Intake Register"
if ($null -ne $intake) {
    foreach ($row in $intake) {
        $title = Get-FVText -Item $row -Name "Title"
        $status = [string](Get-FV -Item $row -Name "IntakeStatus")
        $priority = [string](Get-FV -Item $row -Name "Priority")
        $nextAction = Get-FVText -Item $row -Name "NextAction"
        $received = Get-FVDate -Item $row -Name "ReceivedDate"
        $isOpen = $openIntakeStates -contains $status

        if ($isOpen -and [string]::IsNullOrWhiteSpace($nextAction)) {
            Add-Finding -Category "Intake" -Severity "Medium" -Item $title -Detail ("Open ({0}) with no next action set." -f $status)
        }
        if (($highPriority -contains $priority) -and $status -eq "New") {
            Add-Finding -Category "Intake" -Severity "High" -Item $title -Detail ("{0}-priority intake still in New - not yet triaged." -f $priority)
        }
        if ($isOpen -and $null -ne $received -and ($now - $received).TotalDays -gt $StaleIntakeDays) {
            $age = [int]($now - $received).TotalDays
            Add-Finding -Category "Intake" -Severity "Medium" -Item $title -Detail ("Open for {0} days (received {1}); still {2}." -f $age, $received.ToString("yyyy-MM-dd"), $status)
        }
    }
}

# Decision Register
$decisions = Get-ListRows -ListTitle "Decision Register"
if ($null -ne $decisions) {
    foreach ($row in $decisions) {
        $title = Get-FVText -Item $row -Name "Title"
        $revisit = Get-FVDate -Item $row -Name "RevisitDate"
        $area = [string](Get-FV -Item $row -Name "DecisionArea")
        if ($null -ne $revisit) {
            $days = ($revisit - $now).TotalDays
            if ($days -lt 0) {
                Add-Finding -Category "Decisions" -Severity "High" -Item $title -Detail ("Revisit date passed ({0}, {1} days ago); area {2}." -f $revisit.ToString("yyyy-MM-dd"), [int]([math]::Abs($days)), $area)
            }
            elseif ($days -le $RevisitSoonDays) {
                Add-Finding -Category "Decisions" -Severity "Medium" -Item $title -Detail ("Revisit due in {0} day(s) ({1}); area {2}." -f [int]$days, $revisit.ToString("yyyy-MM-dd"), $area)
            }
        }
    }
}

# Agent Action Log
$actionLog = Get-ListRows -ListTitle "Agent Action Log"
if ($null -ne $actionLog) {
    foreach ($row in $actionLog) {
        $title = Get-FVText -Item $row -Name "Title"
        $status = [string](Get-FV -Item $row -Name "ActionStatus")
        $actionDate = Get-FVDate -Item $row -Name "ActionDate"
        if ($null -eq $actionDate) { continue }
        $age = [int]($now - $actionDate).TotalDays
        if ($status -eq "Suggested" -and $age -gt $SuggestionAgeDays) {
            Add-Finding -Category "Agent Action Log" -Severity "Medium" -Item $title -Detail ("Suggested for {0} days with no decision - approve, reject, or supersede." -f $age)
        }
        if ($status -eq "Approved" -and $age -gt $SuggestionAgeDays) {
            Add-Finding -Category "Agent Action Log" -Severity "Medium" -Item $title -Detail ("Approved {0} days ago but not yet Completed." -f $age)
        }
    }
}

# CRM - Engagements
$engagements = Get-ListRows -ListTitle "CRM - Engagements"
if ($null -ne $engagements) {
    foreach ($row in $engagements) {
        $title = Get-FVText -Item $row -Name "Title"
        $crmStatus = [string](Get-FV -Item $row -Name "CRMStatus")
        $risk = [string](Get-FV -Item $row -Name "RiskLevel")
        $stage = [string](Get-FV -Item $row -Name "EngagementStage")
        $lastReviewed = Get-FVDate -Item $row -Name "LastReviewed"
        if ($risk -eq "At Risk" -or $crmStatus -eq "At Risk") {
            Add-Finding -Category "CRM Engagements" -Severity "High" -Item $title -Detail ("Flagged At Risk (stage {0})." -f $stage)
        }
        if ($crmStatus -eq "Waiting on Adam") {
            Add-Finding -Category "CRM Engagements" -Severity "High" -Item $title -Detail ("Waiting on you (stage {0})." -f $stage)
        }
        if ($crmStatus -eq "Active") {
            if ($null -eq $lastReviewed) {
                Add-Finding -Category "CRM Engagements" -Severity "Low" -Item $title -Detail "Active engagement with no LastReviewed date."
            }
            elseif (($now - $lastReviewed).TotalDays -gt $EngagementReviewDays) {
                Add-Finding -Category "CRM Engagements" -Severity "Medium" -Item $title -Detail ("Active but not reviewed in {0} days (last {1})." -f [int]($now - $lastReviewed).TotalDays, $lastReviewed.ToString("yyyy-MM-dd"))
            }
        }
    }
}

# CRM - Touchpoints
$touchpoints = Get-ListRows -ListTitle "CRM - Touchpoints"
if ($null -ne $touchpoints) {
    foreach ($row in $touchpoints) {
        $title = Get-FVText -Item $row -Name "Title"
        $followUp = Get-FV -Item $row -Name "FollowUpRequired"
        $due = Get-FVDate -Item $row -Name "FollowUpDueDate"
        $isFollowUp = ($followUp -eq $true -or [string]$followUp -eq "True" -or [string]$followUp -eq "1")
        if ($isFollowUp -and $null -ne $due -and $due -lt $now) {
            Add-Finding -Category "CRM Touchpoints" -Severity "High" -Item $title -Detail ("Follow-up overdue (due {0}, {1} days ago)." -f $due.ToString("yyyy-MM-dd"), [int]($now - $due).TotalDays)
        }
    }
}

# CRM - Organizations
$orgs = Get-ListRows -ListTitle "CRM - Organizations"
if ($null -ne $orgs) {
    $keyRelationships = @("Active", "Client", "Partner")
    foreach ($row in $orgs) {
        $title = Get-FVText -Item $row -Name "Title"
        $rel = [string](Get-FV -Item $row -Name "RelationshipStatus")
        $lastReviewed = Get-FVDate -Item $row -Name "LastReviewed"
        if ($keyRelationships -contains $rel) {
            if ($null -eq $lastReviewed) {
                Add-Finding -Category "CRM Organizations" -Severity "Low" -Item $title -Detail ("{0} organization with no LastReviewed date." -f $rel)
            }
            elseif (($now - $lastReviewed).TotalDays -gt $OrgTouchDays) {
                Add-Finding -Category "CRM Organizations" -Severity "Medium" -Item $title -Detail ("{0} organization not touched in {1} days (last {2})." -f $rel, [int]($now - $lastReviewed).TotalDays, $lastReviewed.ToString("yyyy-MM-dd"))
            }
        }
    }
}

# --- summarise -------------------------------------------------------------

Write-Section "Findings"
$severityOrder = @{ High = 0; Medium = 1; Low = 2 }
$sorted = $findings | Sort-Object @{ Expression = { $severityOrder[$_.Severity] } }, Category
$high = @($findings | Where-Object { $_.Severity -eq "High" }).Count
$medium = @($findings | Where-Object { $_.Severity -eq "Medium" }).Count
$low = @($findings | Where-Object { $_.Severity -eq "Low" }).Count
$total = $findings.Count

Write-Host ("  {0} finding(s): {1} High, {2} Medium, {3} Low" -f $total, $high, $medium, $low) -ForegroundColor $(if ($high -gt 0) { "Red" } elseif ($total -gt 0) { "Yellow" } else { "Green" })
foreach ($f in $sorted) {
    $colour = switch ($f.Severity) { "High" { "Red" } "Medium" { "Yellow" } default { "Gray" } }
    Write-Host ("  [{0}] {1}: {2} - {3}" -f $f.Severity, $f.Category, $f.Item, $f.Detail) -ForegroundColor $colour
}

# --- digest (G0 artifact) --------------------------------------------------

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Coordinator Daily Read")
$lines.Add("")
$lines.Add(("Generated: {0}" -f $now.ToString("yyyy-MM-dd HH:mm")))
$lines.Add(("Site: {0}" -f $GuidedSiteUrl))
$lines.Add(("Signed-in user expected: {0}" -f $ExpectedUpn))
$lines.Add(("Mode: {0}" -f $(if ($Apply) { "APPLY (G0 read + one G1 Suggested row)" } else { "DRY RUN (G0 read only)" })))
$lines.Add("")
$lines.Add(("**{0} finding(s): {1} High, {2} Medium, {3} Low**" -f $total, $high, $medium, $low))
$lines.Add("")
if ($total -eq 0) {
    $lines.Add("No attention items detected against the current thresholds. Nothing to suggest.")
}
else {
    foreach ($group in ($sorted | Group-Object Category)) {
        $lines.Add(("## {0}" -f $group.Name))
        $lines.Add("")
        foreach ($f in $group.Group) {
            $lines.Add(("- **[{0}]** {1} - {2}" -f $f.Severity, $f.Item, $f.Detail))
        }
        $lines.Add("")
    }
}
$lines.Add("---")
$lines.Add("")
$lines.Add("Thresholds: stale intake > $StaleIntakeDays d; revisit soon <= $RevisitSoonDays d; engagement review > $EngagementReviewDays d; org touch > $OrgTouchDays d; suggestion/approval age > $SuggestionAgeDays d.")
$lines.Add("")
$lines.Add("Governance: G0 read produced this digest. Any write is a single G1 *Suggested* Agent Action Log row, reviewed by a human. No G2+ action is taken by this loop.")
Set-Content -Path $digestPath -Value $lines -Encoding UTF8
Write-Host ""
Write-Host ("Digest written: {0}" -f $digestPath) -ForegroundColor Green

# --- G1 write (gated) ------------------------------------------------------

Write-Section "G1 Agent Action Log suggestion"

$summaryLines = @()
$summaryLines += ("Coordinator daily read on {0}: {1} finding(s) - {2} High, {3} Medium, {4} Low." -f $now.ToString("yyyy-MM-dd"), $total, $high, $medium, $low)
$topItems = @($sorted | Select-Object -First 8)
if ($topItems.Count -gt 0) {
    $summaryLines += ""
    $summaryLines += "Top items:"
    foreach ($f in $topItems) {
        $summaryLines += ("- [{0}] {1}: {2} - {3}" -f $f.Severity, $f.Category, $f.Item, $f.Detail)
    }
    if ($total -gt $topItems.Count) {
        $summaryLines += ("- (+{0} more in the digest)" -f ($total - $topItems.Count))
    }
}
$summaryLines += ""
$summaryLines += ("Full digest: {0}" -f $digestRelative)
$summaryLines += "Proposed for: Adam. This is a Suggested row only - review, then approve/reject/supersede."
$resultText = ($summaryLines -join "`n")

$suggestionTitle = ("Coordinator daily read {0} - {1} item(s) need attention" -f $now.ToString("yyyy-MM-dd"), $total)

if (-not $Apply) {
    Write-Host "  DRY RUN: would add ONE Suggested Agent Action Log row:" -ForegroundColor Yellow
    Write-Host ("    Title: {0}" -f $suggestionTitle) -ForegroundColor Yellow
    Write-Host "  Re-run with -Apply to record it (you will get one Y approval prompt)." -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Host "Approve this live write? It records ONE Suggested Agent Action Log row." -ForegroundColor Yellow
    Write-Host ("  Title: {0}" -f $suggestionTitle) -ForegroundColor Gray
    if ($Approve) {
        Write-Host "  Approval supplied by -Approve switch." -ForegroundColor Gray
        $confirmed = $true
    }
    else {
        $answer = Read-Host "Type Y to approve (anything else cancels)"
        $confirmed = ($answer -match '^(y|yes)$')
    }
    if (-not $confirmed) {
        throw "Not approved. No write performed. Digest is still available at $digestPath."
    }

    Get-PnPList -Identity "Agent Action Log" -ErrorAction Stop | Out-Null
    $actionValues = @{
        Title        = $suggestionTitle
        ActionDate   = $now
        AgentSurface = "Codex"
        ActionType   = "recommend"
        ActionStatus = "Suggested"
        Result       = $resultText
    }
    $created = Add-PnPListItem -List "Agent Action Log" -Values $actionValues
    Write-Host ("  [OK] Added Suggested Agent Action Log row #{0}" -f $created.Id) -ForegroundColor Green
}

Write-Section "Done"
if ($Apply) {
    Write-Host "Coordinator daily read complete: G0 read, digest written, one G1 Suggested row recorded." -ForegroundColor Green
}
else {
    Write-Host "Dry run complete: G0 read and digest written. Re-run with -Apply to record the G1 Suggested row." -ForegroundColor Yellow
}
Write-Host ("Digest:     {0}" -f $digestPath) -ForegroundColor Gray
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray

try {
    Stop-Transcript | Out-Null
}
catch {}
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
