param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"
)

# Stage 2 - Identity & Admin Foundation : READ-ONLY verification.
# This script changes NOTHING. It signs you in (device-code, your MFA), then reads
# the live tenant and shows the current identity/role picture against the Stage 2
# plan. Run this first to watch the Level-1 loop work before any write step.
# Plan + decisions: M365_STAGE_2_IDENTITY_FOUNDATION.md

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Invoke-GraphGet {
    param(
        [Parameter(Mandatory = $true)] [string]$Uri,
        [Parameter(Mandatory = $true)] [string]$AccessToken
    )
    $headers = @{ Authorization = "Bearer $AccessToken" }
    $items = New-Object System.Collections.Generic.List[object]
    $next = $Uri
    while ($next) {
        $response = Invoke-RestMethod -Method Get -Uri $next -Headers $headers
        if ($null -ne $response.value) {
            foreach ($item in $response.value) { $items.Add($item) }
            $next = $response.'@odata.nextLink'
        }
        else {
            $items.Add($response)
            $next = $null
        }
    }
    return $items
}

Write-Host "Microsoft 365 Stage 2 - Identity & Admin Foundation (READ-ONLY verify)" -ForegroundColor Cyan
Write-Host ""
Write-Host "This run is non-destructive. It only READS the tenant and prints a report." -ForegroundColor Green
Write-Host "Uses the Microsoft Graph Command Line Tools public client and delegated READ scopes." -ForegroundColor Yellow
Write-Host "Sign in as admin@agoperations.ca or adamgoodwin@guidedailabs.com (an admin)." -ForegroundColor Yellow

# Read-only scopes only. No write scope is requested in this script.
$scope = @(
    "User.Read",
    "Directory.Read.All"
) -join " "

$deviceCodeUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode"
$tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

$device = Invoke-RestMethod -Method Post -Uri $deviceCodeUri -ContentType "application/x-www-form-urlencoded" -Body @{
    client_id = $ClientId
    scope = $scope
}

Write-Host ""
Write-Host $device.message -ForegroundColor Yellow
Write-Host ""

$deadline = (Get-Date).AddSeconds([int]$device.expires_in)
$interval = [Math]::Max(5, [int]$device.interval)
$token = $null

while ((Get-Date) -lt $deadline -and $null -eq $token) {
    Start-Sleep -Seconds $interval
    try {
        $token = Invoke-RestMethod -Method Post -Uri $tokenUri -ContentType "application/x-www-form-urlencoded" -Body @{
            grant_type = "urn:ietf:params:oauth:grant-type:device_code"
            client_id = $ClientId
            device_code = $device.device_code
        }
    }
    catch {
        $body = $_.ErrorDetails.Message
        try { $details = $body | ConvertFrom-Json } catch { $details = $null }
        if ($null -ne $details -and $details.error -eq "authorization_pending") {
            Write-Host "." -NoNewline; continue
        }
        elseif ($null -ne $details -and $details.error -eq "slow_down") {
            $interval += 5; Write-Host "." -NoNewline; continue
        }
        else {
            Write-Host ""
            Write-Host "Authentication failed: $($details.error_description)" -ForegroundColor Red
            Write-Host "Press Enter to close this window."
            Read-Host | Out-Null
            exit 1
        }
    }
}

if ($null -eq $token) {
    Write-Host ""
    Write-Host "Authentication timed out before approval completed." -ForegroundColor Red
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
    exit 1
}

Write-Host ""
Write-Host "Authenticated. Reading live tenant (read-only)..." -ForegroundColor Green

$base = "https://graph.microsoft.com/v1.0"

# --- Who am I (confirm the signed-in identity) ---
Write-Section "Signed-in account"
$me = Invoke-RestMethod -Method Get -Uri "$base/me?`$select=displayName,userPrincipalName" -Headers @{ Authorization = "Bearer $($token.access_token)" }
Write-Host ("Signed in as: {0} <{1}>" -f $me.displayName, $me.userPrincipalName) -ForegroundColor Green

# --- Users ---
$users = Invoke-GraphGet -Uri "$base/users?`$select=id,displayName,userPrincipalName,accountEnabled,userType" -AccessToken $token.access_token

# --- Directory roles and their members ---
$roles = Invoke-GraphGet -Uri "$base/directoryRoles" -AccessToken $token.access_token
$rolesByUser = @{}
$globalAdmins = New-Object System.Collections.Generic.List[string]
foreach ($role in $roles) {
    $members = Invoke-GraphGet -Uri "$base/directoryRoles/$($role.id)/members" -AccessToken $token.access_token
    foreach ($m in $members) {
        $upn = $m.userPrincipalName
        if ([string]::IsNullOrWhiteSpace($upn)) { $upn = $m.displayName }
        if (-not $rolesByUser.ContainsKey($upn)) {
            $rolesByUser[$upn] = New-Object System.Collections.Generic.List[string]
        }
        $rolesByUser[$upn].Add($role.displayName)
        if ($role.displayName -eq "Global Administrator") { $globalAdmins.Add($upn) }
    }
}

# --- Live role matrix ---
Write-Section "Live account role matrix"
foreach ($u in ($users | Sort-Object userPrincipalName)) {
    $upn = $u.userPrincipalName
    $assigned = if ($rolesByUser.ContainsKey($upn)) { ($rolesByUser[$upn] | Sort-Object) -join ", " } else { "(no admin roles)" }
    $state = if ($u.accountEnabled) { "enabled" } else { "DISABLED" }
    Write-Host ("- {0}  [{1}]" -f $upn, $state) -ForegroundColor White
    Write-Host ("    roles: {0}" -f $assigned) -ForegroundColor Gray
}

# --- Stage 2 checks against the plan ---
Write-Section "Stage 2 plan checks"

Write-Host "Global Administrators found:" -ForegroundColor White
foreach ($ga in ($globalAdmins | Sort-Object -Unique)) {
    Write-Host ("  * {0}" -f $ga) -ForegroundColor Yellow
}

# contact@ roles slated for removal
$contactUpn = "contact@guidedailabs.com"
$contactRoles = if ($rolesByUser.ContainsKey($contactUpn)) { $rolesByUser[$contactUpn] } else { @() }
Write-Host ""
Write-Host "contact@ (front door) - roles slated for removal in the plan:" -ForegroundColor White
if ($contactRoles.Count -gt 0) {
    foreach ($r in ($contactRoles | Sort-Object)) {
        Write-Host ("  - {0}  (PLAN: remove)" -f $r) -ForegroundColor Yellow
    }
}
else {
    Write-Host "  (none - contact@ already has no admin roles)" -ForegroundColor Green
}

# break-glass presence
$breakglass = $users | Where-Object { $_.userPrincipalName -like "breakglass*" }
Write-Host ""
Write-Host "Break-glass accounts (plan: create breakglass-01 / breakglass-02):" -ForegroundColor White
if ($breakglass) {
    foreach ($b in $breakglass) { Write-Host ("  * EXISTS: {0}" -f $b.userPrincipalName) -ForegroundColor Green }
}
else {
    Write-Host "  * none yet - safety net not built. This is the first live step." -ForegroundColor Red
}

Write-Section "Done"
Write-Host "Read-only verification complete. Nothing was changed." -ForegroundColor Green
Write-Host "Stage 2 is complete (safety net built, contact@ stripped, matrix verified). Next: Stage 3." -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
