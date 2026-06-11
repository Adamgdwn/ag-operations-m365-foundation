param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e",
    [string]$TargetUpn = "contact@guidedailabs.com",
    # Roles to remove from the target, by built-in display name. Resolved live, so
    # this does NOT depend on hardcoded role GUIDs (matters for newer roles like AI Admin).
    [string[]]$RolesToRemove = @("Global Administrator", "Global Reader", "AI Administrator")
)

# Stage 2 - Identity & Admin Foundation : GATED LIVE WRITE - strip admin from contact@.
# Plan + decisions: M365_STAGE_2_IDENTITY_FOUNDATION.md (decision 2.5; §5 step 3).
#
# Background: contact@ is a front-door / reception identity that today holds
# Global Administrator + Global Reader + AI Administrator. That violates the core
# principle interaction-surface != capability-surface (see §6). Its future agentic
# power comes from a SCOPED app registration at Stage 9 - never standing admin.
#
# What this does (each step narrated; every action reversible):
#   1. Sign in (device-code, YOUR MFA) requesting WRITE scopes - this consent IS
#      the write authorization.
#   2. READ the target account + its current role assignments (expanded to names).
#   3. SAFETY CHECK: confirm at least one OTHER Global Administrator remains, so we
#      can never strip the tenant's last GA. Aborts the GA removal if not.
#   4. Show exactly which assignments will be removed and ask for a typed 'yes'.
#   5. REMOVE each matching role assignment (idempotent: missing roles are skipped).
#   6. READ BACK the account's roles to confirm.
#
# Reversibility: a removed role assignment can be re-created with a single POST to
#   /roleManagement/directory/roleAssignments (same call the break-glass script uses).
#   This run touches ONLY role assignments - it does not disable, relicense, or
#   delete the account, and it does not touch its mailbox.

$ErrorActionPreference = "Stop"

function Write-Section { param([string]$m) Write-Host ""; Write-Host "== $m ==" -ForegroundColor Cyan }
function Write-Step    { param([string]$m) Write-Host "-> $m" -ForegroundColor White }
function Write-Ok      { param([string]$m) Write-Host "   [OK] $m" -ForegroundColor Green }
function Write-Skip    { param([string]$m) Write-Host "   [SKIP] $m" -ForegroundColor Yellow }
function Write-Warn    { param([string]$m) Write-Host "   [!] $m" -ForegroundColor Yellow }

Write-Host "Microsoft 365 Stage 2 - STRIP admin roles from $TargetUpn (LIVE WRITE)" -ForegroundColor Cyan
Write-Host ""
Write-Host "This run WILL remove directory role assignments from one account." -ForegroundColor Yellow
Write-Host "It is idempotent and reversible, and it will NOT proceed without a typed 'yes'." -ForegroundColor Yellow
Write-Host "Sign in as an admin (adamgoodwin@guidedailabs.com or admin@agoperations.ca)." -ForegroundColor Yellow

# WRITE scopes - this consent screen IS the write authorization.
$scope = @(
    "RoleManagement.ReadWrite.Directory",
    "Directory.Read.All"
) -join " "

$deviceCodeUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode"
$tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

$device = Invoke-RestMethod -Method Post -Uri $deviceCodeUri -ContentType "application/x-www-form-urlencoded" -Body @{
    client_id = $ClientId; scope = $scope
}
Write-Host ""; Write-Host $device.message -ForegroundColor Yellow; Write-Host ""

$deadline = (Get-Date).AddSeconds([int]$device.expires_in)
$interval = [Math]::Max(5, [int]$device.interval)
$token = $null
while ((Get-Date) -lt $deadline -and $null -eq $token) {
    Start-Sleep -Seconds $interval
    try {
        $token = Invoke-RestMethod -Method Post -Uri $tokenUri -ContentType "application/x-www-form-urlencoded" -Body @{
            grant_type = "urn:ietf:params:oauth:grant-type:device_code"; client_id = $ClientId; device_code = $device.device_code
        }
    } catch {
        $body = $_.ErrorDetails.Message; try { $details = $body | ConvertFrom-Json } catch { $details = $null }
        if ($details -and $details.error -eq "authorization_pending") { Write-Host "." -NoNewline; continue }
        elseif ($details -and $details.error -eq "slow_down") { $interval += 5; Write-Host "." -NoNewline; continue }
        else { Write-Host ""; Write-Host "Authentication failed: $($details.error_description)" -ForegroundColor Red; Read-Host "Press Enter to close" | Out-Null; exit 1 }
    }
}
if ($null -eq $token) { Write-Host ""; Write-Host "Authentication timed out." -ForegroundColor Red; Read-Host "Press Enter to close" | Out-Null; exit 1 }

$base = "https://graph.microsoft.com/v1.0"
$auth = @{ Authorization = "Bearer $($token.access_token)" }
Write-Host ""; Write-Host "Authenticated." -ForegroundColor Green

# --- Who am I ---
Write-Section "Signed-in account"
$me = Invoke-RestMethod -Method Get -Uri "$base/me?`$select=displayName,userPrincipalName" -Headers $auth
Write-Host ("Signed in as: {0} <{1}>" -f $me.displayName, $me.userPrincipalName) -ForegroundColor Green

# --- Step 2: read the target + its current role assignments (with names) ---
Write-Section "Target account: $TargetUpn"
try {
    $target = Invoke-RestMethod -Method Get -Uri "$base/users/$TargetUpn`?`$select=id,displayName,userPrincipalName,accountEnabled" -Headers $auth
} catch {
    Write-Host "Could not find $TargetUpn. Aborting (nothing changed)." -ForegroundColor Red
    Read-Host "Press Enter to close" | Out-Null; exit 1
}
$targetId = $target.id
$state = if ($target.accountEnabled) { "enabled" } else { "DISABLED" }
Write-Ok ("{0} <{1}>  [{2}]  id={3}" -f $target.displayName, $target.userPrincipalName, $state, $targetId)

Write-Step "Reading current role assignments (expanding role names)..."
$assignments = (Invoke-RestMethod -Method Get -Headers $auth `
    -Uri "$base/roleManagement/directory/roleAssignments?`$filter=principalId eq '$targetId'&`$expand=roleDefinition").value

if (-not $assignments -or $assignments.Count -eq 0) {
    Write-Host ""; Write-Ok "This account already has NO directory role assignments. Nothing to do."
    Read-Host "Press Enter to close" | Out-Null; exit 0
}

Write-Host "  Current roles on this account:" -ForegroundColor Gray
foreach ($a in ($assignments | Sort-Object { $_.roleDefinition.displayName })) {
    $mark = if ($RolesToRemove -contains $a.roleDefinition.displayName) { "PLAN: remove" } else { "keep" }
    Write-Host ("    - {0}  ({1})" -f $a.roleDefinition.displayName, $mark) -ForegroundColor Gray
}

# Which assignments actually match the removal list?
$toRemove = $assignments | Where-Object { $RolesToRemove -contains $_.roleDefinition.displayName }
if (-not $toRemove -or $toRemove.Count -eq 0) {
    Write-Host ""; Write-Ok "None of the target roles ($($RolesToRemove -join ', ')) are currently assigned. Nothing to do."
    Read-Host "Press Enter to close" | Out-Null; exit 0
}

# --- Step 3: SAFETY CHECK - never strip the last Global Administrator ---
$gaRoleId = "62e90394-69f5-4237-9190-012177145e10"
$removingGA = $toRemove | Where-Object { $_.roleDefinition.displayName -eq "Global Administrator" }
if ($removingGA) {
    Write-Section "Safety check: remaining Global Administrators"
    $allGA = (Invoke-RestMethod -Method Get -Headers $auth `
        -Uri "$base/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$gaRoleId'").value
    $otherGA = $allGA | Where-Object { $_.principalId -ne $targetId } | Select-Object -ExpandProperty principalId -Unique
    Write-Host ("  Global Administrators other than the target: {0}" -f $otherGA.Count) -ForegroundColor Gray
    foreach ($principalId in $otherGA) {
        $name = $principalId
        try { $p = Invoke-RestMethod -Method Get -Uri "$base/directoryObjects/$principalId" -Headers $auth; if ($p.userPrincipalName) { $name = $p.userPrincipalName } elseif ($p.displayName) { $name = $p.displayName } } catch {}
        Write-Host ("    * {0}" -f $name) -ForegroundColor Gray
    }
    if ($otherGA.Count -lt 1) {
        Write-Host ""; Write-Host "ABORTING: removing Global Administrator from $TargetUpn would leave the tenant" -ForegroundColor Red
        Write-Host "with no other Global Administrator. Nothing changed." -ForegroundColor Red
        Read-Host "Press Enter to close" | Out-Null; exit 1
    }
    Write-Ok "Safe to proceed - the tenant keeps at least one other Global Administrator."
}

# --- Step 4: explicit, typed confirmation gate ---
Write-Section "Confirm removal"
Write-Host "About to REMOVE these role assignments from $TargetUpn :" -ForegroundColor Yellow
foreach ($a in $toRemove) { Write-Host ("    - {0}" -f $a.roleDefinition.displayName) -ForegroundColor Yellow }
Write-Host ""
Write-Host "The account, its license, and its mailbox are NOT touched. This is reversible." -ForegroundColor Gray
$answer = Read-Host "Type 'yes' to remove the roles above (anything else aborts)"
if ($answer -ne "yes") {
    Write-Host "Aborted by you. Nothing was changed." -ForegroundColor Yellow
    Read-Host "Press Enter to close" | Out-Null; exit 0
}

# --- Step 5: remove each matching assignment ---
Write-Section "Removing role assignments"
$removed = New-Object System.Collections.Generic.List[string]
foreach ($a in $toRemove) {
    $roleName = $a.roleDefinition.displayName
    Write-Step "Removing '$roleName'..."
    try {
        Invoke-RestMethod -Method Delete -Uri "$base/roleManagement/directory/roleAssignments/$($a.id)" -Headers $auth | Out-Null
        Write-Ok "Removed '$roleName'."
        $removed.Add($roleName)
    } catch {
        $msg = $_.ErrorDetails.Message; if (-not $msg) { $msg = $_.Exception.Message }
        Write-Warn "Failed to remove '$roleName': $msg"
    }
}

# --- Step 6: read-back confirmation ---
Write-Section "Read-back confirmation"
$after = (Invoke-RestMethod -Method Get -Headers $auth `
    -Uri "$base/roleManagement/directory/roleAssignments?`$filter=principalId eq '$targetId'&`$expand=roleDefinition").value
if (-not $after -or $after.Count -eq 0) {
    Write-Ok "$TargetUpn now has NO directory role assignments."
} else {
    Write-Host ("{0} now holds these roles:" -f $TargetUpn) -ForegroundColor Green
    foreach ($a in ($after | Sort-Object { $_.roleDefinition.displayName })) {
        $stillTarget = $RolesToRemove -contains $a.roleDefinition.displayName
        $colour = if ($stillTarget) { "Red" } else { "Green" }
        $note = if ($stillTarget) { "  (STILL PRESENT - removal did not take)" } else { "" }
        Write-Host ("  - {0}{1}" -f $a.roleDefinition.displayName, $note) -ForegroundColor $colour
    }
}

Write-Section "Done"
Write-Host ("Removed: {0}" -f ($(if ($removed.Count) { $removed -join ', ' } else { "(nothing)" }))) -ForegroundColor Green
Write-Host "Update §10 Execution Log in M365_STAGE_2_IDENTITY_FOUNDATION.md with this run." -ForegroundColor Cyan
Write-Host "Re-run Invoke-M365Stage2Verify.ps1 to see the new live role matrix." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close this window" | Out-Null
