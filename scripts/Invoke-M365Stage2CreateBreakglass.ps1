param(
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e",
    [string[]]$Names = @("breakglass-01", "breakglass-02")
)

# Stage 2 - Identity & Admin Foundation : FIRST LIVE WRITE - create break-glass admins.
# Plan + decisions: M365_STAGE_2_IDENTITY_FOUNDATION.md (decisions 2.1, 2.7).
#
# What this does (each step narrated, every action reversible):
#   1. Sign in (device-code, YOUR MFA) requesting WRITE scopes.
#   2. READ verified domains; confirm the tenant's initial *.onmicrosoft.com domain.
#   3. For each break-glass name: if it already exists, skip; else CREATE it
#      (cloud-only, unlicensed) with a TEMPORARY password + forceChange = ON.
#   4. ASSIGN Global Administrator to each.
#   5. READ BACK each account + its roles to confirm.
#
# Credential model (decision: temp password + force change):
#   - The temporary password is generated, shown ONCE on screen, and written
#     NOWHERE. It is throwaway - you only use it for the first interactive sign-in,
#     where you set the PERMANENT password (store it offline / in a vault) and
#     register MFA. Do NOT paste the password lines back to anyone.
#
# Reversibility: a created account can be deleted; a role assignment can be removed.

$ErrorActionPreference = "Stop"

function Write-Section { param([string]$m) Write-Host ""; Write-Host "== $m ==" -ForegroundColor Cyan }
function Write-Step    { param([string]$m) Write-Host "-> $m" -ForegroundColor White }
function Write-Ok      { param([string]$m) Write-Host "   [OK] $m" -ForegroundColor Green }
function Write-Skip    { param([string]$m) Write-Host "   [SKIP] $m" -ForegroundColor Yellow }

function New-TempPassword {
    # 24-char temp password, cryptographically random, guaranteed complexity.
    $upper = "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
    $lower = "abcdefghijkmnpqrstuvwxyz".ToCharArray()
    $digit = "23456789".ToCharArray()
    $symbol = "!@#$%^&*-_=+".ToCharArray()
    $all = $upper + $lower + $digit + $symbol
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    function Pick($set) {
        $bytes = New-Object 'System.Byte[]' 1
        $rng.GetBytes($bytes)
        $set[[int]$bytes[0] % $set.Length]
    }
    $chars = New-Object System.Collections.Generic.List[char]
    $chars.Add((Pick $upper)); $chars.Add((Pick $lower)); $chars.Add((Pick $digit)); $chars.Add((Pick $symbol))
    for ($i = 0; $i -lt 20; $i++) { $chars.Add((Pick $all)) }
    # shuffle
    for ($i = $chars.Count - 1; $i -gt 0; $i--) {
        $bytes = New-Object 'System.Byte[]' 1; $rng.GetBytes($bytes); $j = [int]$bytes[0] % ($i + 1)
        $tmp = $chars[$i]; $chars[$i] = $chars[$j]; $chars[$j] = $tmp
    }
    $rng.Dispose()
    -join $chars
}

Write-Host "Microsoft 365 Stage 2 - CREATE break-glass admins (LIVE WRITE)" -ForegroundColor Cyan
Write-Host ""
Write-Host "This run WILL create accounts and assign Global Administrator." -ForegroundColor Yellow
Write-Host "It is idempotent: existing accounts are skipped, not duplicated." -ForegroundColor Yellow
Write-Host "Sign in as an admin (adamgoodwin@guidedailabs.com or admin@agoperations.ca)." -ForegroundColor Yellow

# WRITE scopes - this consent screen IS the write authorization.
$scope = @(
    "User.ReadWrite.All",
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

# --- Step 2: confirm initial onmicrosoft.com domain ---
Write-Section "Confirm tenant domain"
Write-Step "Reading verified domains..."
$domains = (Invoke-RestMethod -Method Get -Uri "$base/domains" -Headers $auth).value
$initial = $domains | Where-Object { $_.isInitial -eq $true } | Select-Object -First 1
if ($null -eq $initial) { $initial = $domains | Where-Object { $_.id -like "*.onmicrosoft.com" } | Select-Object -First 1 }
if ($null -eq $initial) { Write-Host "Could not find an onmicrosoft.com domain. Aborting." -ForegroundColor Red; Read-Host "Press Enter to close" | Out-Null; exit 1 }
$domain = $initial.id
Write-Ok ("Using initial domain: {0}" -f $domain)

# --- Global Administrator role definition (built-in template id) ---
$gaRoleId = "62e90394-69f5-4237-9190-012177145e10"

$created = New-Object System.Collections.Generic.List[object]

foreach ($name in $Names) {
    $upn = "$name@$domain"
    Write-Section "Account: $upn"

    # idempotency: does it already exist?
    $existing = $null
    try { $existing = Invoke-RestMethod -Method Get -Uri "$base/users/$upn`?`$select=id,userPrincipalName,accountEnabled" -Headers $auth } catch { $existing = $null }

    if ($existing) {
        Write-Skip "Account already exists (id $($existing.id)). Not recreating."
        $userId = $existing.id
        $tempPw = $null
    } else {
        Write-Step "Creating account (cloud-only, unlicensed, temp password, forceChange=ON)..."
        $tempPw = New-TempPassword
        $mailNick = ($name -replace '[^a-zA-Z0-9]', '')
        $bodyObj = @{
            accountEnabled    = $true
            displayName       = "Break Glass $($name.Substring($name.Length-2)) (Emergency Admin)"
            mailNickname      = $mailNick
            userPrincipalName = $upn
            passwordProfile   = @{
                password                      = $tempPw
                forceChangePasswordNextSignIn = $true
            }
        }
        $json = $bodyObj | ConvertTo-Json -Depth 5
        $newUser = Invoke-RestMethod -Method Post -Uri "$base/users" -Headers $auth -ContentType "application/json" -Body $json
        $userId = $newUser.id
        Write-Ok ("Created. id = {0}" -f $userId)
    }

    # --- Assign Global Administrator (idempotent) ---
    Write-Step "Checking / assigning Global Administrator..."
    $assignments = @()
    try {
        $assignments = (Invoke-RestMethod -Method Get -Uri "$base/roleManagement/directory/roleAssignments?`$filter=principalId eq '$userId'" -Headers $auth).value
    } catch { $assignments = @() }
    $hasGA = $assignments | Where-Object { $_.roleDefinitionId -eq $gaRoleId }
    if ($hasGA) {
        Write-Skip "Global Administrator already assigned."
    } else {
        $assignBody = @{
            "@odata.type"    = "#microsoft.graph.unifiedRoleAssignment"
            roleDefinitionId = $gaRoleId
            principalId      = $userId
            directoryScopeId = "/"
        } | ConvertTo-Json
        Invoke-RestMethod -Method Post -Uri "$base/roleManagement/directory/roleAssignments" -Headers $auth -ContentType "application/json" -Body $assignBody | Out-Null
        Write-Ok "Global Administrator assigned."
    }

    $created.Add([pscustomobject]@{ Upn = $upn; Id = $userId; TempPassword = $tempPw })
}

# --- Step 5: read back confirmation ---
Write-Section "Read-back confirmation"
foreach ($c in $created) {
    $u = Invoke-RestMethod -Method Get -Uri "$base/users/$($c.Id)?`$select=displayName,userPrincipalName,accountEnabled" -Headers $auth
    $asg = (Invoke-RestMethod -Method Get -Uri "$base/roleManagement/directory/roleAssignments?`$filter=principalId eq '$($c.Id)'" -Headers $auth).value
    $ga = if ($asg | Where-Object { $_.roleDefinitionId -eq $gaRoleId }) { "YES" } else { "NO" }
    $state = if ($u.accountEnabled) { "enabled" } else { "DISABLED" }
    Write-Host ("- {0}  [{1}]  GlobalAdmin={2}" -f $u.userPrincipalName, $state, $ga) -ForegroundColor Green
}

# --- Temp passwords: show ONCE, never stored ---
$newOnes = $created | Where-Object { $_.TempPassword }
if ($newOnes) {
    Write-Section "TEMPORARY passwords (shown ONCE - copy now, then they are gone)"
    Write-Host "These are throwaway. Use each ONCE to sign in, then you will be forced to" -ForegroundColor Yellow
    Write-Host "set a PERMANENT password (store it OFFLINE / in your vault) and register MFA." -ForegroundColor Yellow
    Write-Host "Do NOT paste these lines back to anyone. Clear this window when done." -ForegroundColor Red
    Write-Host ""
    foreach ($c in $newOnes) {
        Write-Host ("   {0}" -f $c.Upn) -ForegroundColor White
        Write-Host ("      temp password: {0}" -f $c.TempPassword) -ForegroundColor Magenta
    }
}

Write-Section "Next actions (manual, by you)"
Write-Host "1. Sign in to each break-glass account at https://portal.office.com using the temp" -ForegroundColor Gray
Write-Host "   password; set a long PERMANENT password and store it OFFLINE (vault, not git)." -ForegroundColor Gray
Write-Host "2. Register MFA when prompted; store the recovery method offline too." -ForegroundColor Gray
Write-Host "3. Confirm each can reach the admin center (https://entra.microsoft.com)." -ForegroundColor Gray
Write-Host "4. Write a short offline 'how to use in an emergency' note (NOT in git)." -ForegroundColor Gray
Write-Host ""
Write-Host "Safety-net creation complete. Re-run Invoke-M365Stage2Verify.ps1 to see them listed." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to close this window" | Out-Null
