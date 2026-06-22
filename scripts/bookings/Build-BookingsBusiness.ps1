<#
.SYNOPSIS
  Build (and publish) the "Guided AI Labs" Microsoft Bookings calendar AGENTICALLY via
  the Microsoft Graph Bookings API, authenticated with a DELEGATED token through
  Microsoft's first-party "Microsoft Graph Command Line Tools" public client
  (Connect-MgGraph) -- NO custom app registration, no secret, acts as the signed-in user.

.DESCRIPTION
  Read-gates-write in a single run:
    1. Connect-MgGraph -Scopes Bookings.ReadWrite.All  (Adam consents once, in a browser).
    2. GET /solutions/bookingBusinesses  (read) -- proves the scope works before any write.
    3. -Probe stops here. Otherwise create/patch: business + Adam as staff #1
       (free/busy honored) + 2 services (Teams online, staff-assigned, staff-selection ON)
       + custom questions + business hours, then PUBLISH and capture the public page URL.
  Idempotent by displayName (re-runs reuse + patch in place). Result ->
  inventory/forms-build/bookings-result.json.

.NOTES
  Governance: scoped, logged unlock -- delegated Bookings.ReadWrite.All only, acting as
  Adam, reversible by revoking consent. NOT an app registration / no app-only permission.
#>
param(
  [switch]$Probe,
  [switch]$UseDeviceCode
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outDir = Join-Path $repo 'inventory\forms-build'
$capDir = Join-Path $repo '.local\bookings-builder\capture'
New-Item -ItemType Directory -Force -Path $outDir, $capDir | Out-Null
$resultPath = Join-Path $outDir 'bookings-result.json'
function Log($m) { Write-Host ("[{0}] {1}" -f (Get-Date -Format o), $m) }

# ---- Desired calendar (sensible defaults; trivially adjustable) ----------------
$BusinessName = 'Guided AI Labs'
$OwnerEmail   = 'adamgoodwin@guidedailabs.com'
$WebSite      = 'https://guidedailabs.com'
$workdays = 'monday','tuesday','wednesday','thursday','friday'
$businessHours = $workdays | ForEach-Object {
  @{ day = $_; timeSlots = @(@{ startTime = '09:00:00.0000000'; endTime = '17:00:00.0000000' }) }
}
$schedulingPolicy = @{
  timeSlotInterval         = 'PT30M'
  minimumLeadTime          = 'PT24H'
  maximumAdvance           = 'P30D'
  sendConfirmationsToOwner = $true
  allowStaffSelection      = $true     # "book with a specific person" (selector appears once >1 staff)
}
$services = @(
  @{ displayName = 'Intro call (30 min)';       defaultDuration = 'PT30M'; postBuffer = 'PT10M'; notes = 'A short introductory call.' }
  @{ displayName = 'Working session (60 min)';  defaultDuration = 'PT1H';  postBuffer = 'PT15M'; notes = 'A focused working session.' }
)
$questions = @(
  @{ displayName = 'Organization (optional)';        answerInputType = 'text' }
  @{ displayName = 'What would you like to cover?';  answerInputType = 'text' }
)

# ---- 1. Connect (delegated) ----------------------------------------------------
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
Log 'connecting to Graph (delegated Bookings.ReadWrite.All) -- a browser/consent may appear ONCE...'
$connectArgs = @{ Scopes = 'Bookings.ReadWrite.All'; NoWelcome = $true }
if ($UseDeviceCode) { $connectArgs['UseDeviceAuthentication'] = $true }
Connect-MgGraph @connectArgs
$ctx = Get-MgContext
if (-not $ctx) { throw 'Connect-MgGraph produced no context.' }
Log ("connected as {0}; scopes: {1}" -f $ctx.Account, ($ctx.Scopes -join ','))
if ($ctx.Scopes -notcontains 'Bookings.ReadWrite.All') {
  Log 'WARNING: Bookings.ReadWrite.All not in granted scopes -- writes will likely 403.'
}

function GraphGet  ($u) { Invoke-MgGraphRequest -Method GET  -Uri $u -OutputType Hashtable }
function GraphPost ($u, $b) { Invoke-MgGraphRequest -Method POST  -Uri $u -Body ($b | ConvertTo-Json -Depth 12) -ContentType 'application/json' -OutputType Hashtable }
function GraphPatch($u, $b) { Invoke-MgGraphRequest -Method PATCH -Uri $u -Body ($b | ConvertTo-Json -Depth 12) -ContentType 'application/json' -OutputType Hashtable }

# ---- 2. READ (gates write) -----------------------------------------------------
$base = 'https://graph.microsoft.com/v1.0/solutions/bookingBusinesses'
$list = GraphGet "$base`?`$select=id,displayName"
$existing = @($list.value | Where-Object { $_.displayName -and ($_.displayName.Trim().ToLower() -eq $BusinessName.ToLower()) })
Log ("read OK: {0} business(es) exist; '{1}' present: {2}" -f @($list.value).Count, $BusinessName, [bool]$existing.Count)
$existing | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $capDir '00-list-businesses.json')

if ($Probe) {
  @{ probe = $true; account = $ctx.Account; scopes = $ctx.Scopes; businessCount = @($list.value).Count; existing = $existing } |
    ConvertTo-Json -Depth 8 | Set-Content $resultPath
  Log "PROBE OK -> $resultPath (no writes performed)"
  Disconnect-MgGraph | Out-Null
  return
}

$errors = [System.Collections.Generic.List[string]]::new()

# ---- 3. Business (create or reuse) --------------------------------------------
if ($existing.Count -ge 1) {
  $bizId = $existing[0].id
  Log "reusing business: $bizId"
  try { GraphPatch "$base/$bizId" @{ businessHours = $businessHours; schedulingPolicy = $schedulingPolicy; webSiteUrl = $WebSite } | Out-Null }
  catch { $errors.Add("patch business: $($_.Exception.Message)") }
} else {
  Log "creating business '$BusinessName'..."
  $created = GraphPost $base @{
    displayName        = $BusinessName
    businessType       = 'Other'
    email              = $OwnerEmail
    webSiteUrl         = $WebSite
    languageTag        = 'en-US'
    defaultCurrencyIso = 'CAD'
    businessHours      = $businessHours
    schedulingPolicy   = $schedulingPolicy
  }
  $bizId = $created.id
  if (-not $bizId) {
    $rl = GraphGet "$base`?`$select=id,displayName"
    $bizId = (@($rl.value | Where-Object { $_.displayName.Trim().ToLower() -eq $BusinessName.ToLower() })[0]).id
  }
  Log "business id: $bizId"
}
if (-not $bizId) { throw 'no business id resolved' }
$B = "$base/$bizId"

# ---- 4. Staff (idempotent by email) -------------------------------------------
$staffId = $null
try {
  $sl = GraphGet "$B/staffMembers"
  $staffId = (@($sl.value | Where-Object { $_.emailAddress -and ($_.emailAddress.ToLower() -eq $OwnerEmail.ToLower()) })[0]).id
} catch { $errors.Add("list staff: $($_.Exception.Message)") }
if (-not $staffId) {
  try {
    $sc = GraphPost "$B/staffMembers" @{
      '@odata.type'                            = '#microsoft.graph.bookingStaffMember'
      displayName                              = 'Adam Goodwin'
      emailAddress                             = $OwnerEmail
      role                                     = 'administrator'
      useBusinessHours                         = $true
      availabilityIsAffectedByPersonalCalendar = $true
    }
    $staffId = $sc.id
    Log "created staff: $staffId"
  } catch { $errors.Add("create staff: $($_.Exception.Message)") }
} else { Log "reusing staff: $staffId" }

# ---- 5. Custom questions (idempotent by displayName) --------------------------
$existingQ = @{}
try { (GraphGet "$B/customQuestions").value | ForEach-Object { $existingQ[$_.displayName.ToLower()] = $_.id } } catch {}
$questionIds = @()
foreach ($q in $questions) {
  $qid = $existingQ[$q.displayName.ToLower()]
  if (-not $qid) {
    try { $qc = GraphPost "$B/customQuestions" $q; $qid = $qc.id; Log "created question: $($q.displayName)" }
    catch { $errors.Add("question '$($q.displayName)': $($_.Exception.Message)") }
  }
  if ($qid) { $questionIds += $qid }
}

# ---- 6. Services (idempotent by displayName) ----------------------------------
$existingSvc = @{}
try { (GraphGet "$B/services`?`$select=id,displayName").value | ForEach-Object { $existingSvc[$_.displayName.ToLower()] = $_.id } } catch {}
$builtServices = @()
foreach ($svc in $services) {
  $body = @{
    displayName           = $svc.displayName
    defaultDuration       = $svc.defaultDuration
    preBuffer             = 'PT0M'
    postBuffer            = $svc.postBuffer
    isLocationOnline      = $true                # auto Teams meeting link
    notes                 = $svc.notes
    maximumAttendeesCount = 1
    staffMemberIds        = @($staffId | Where-Object { $_ })
    schedulingPolicy      = $schedulingPolicy
    defaultReminders      = @(@{ offset = 'P1D'; recipients = 'allAttendees'; message = 'Reminder: your session is tomorrow.' })
    customQuestions       = @($questionIds | ForEach-Object { @{ questionId = $_; isRequired = $false } })
  }
  $sid = $existingSvc[$svc.displayName.ToLower()]
  try {
    if ($sid) { GraphPatch "$B/services/$sid" $body | Out-Null; Log "patched service: $($svc.displayName)" }
    else { $r = GraphPost "$B/services" $body; $sid = $r.id; Log "created service: $($svc.displayName)" }
  } catch { $errors.Add("service '$($svc.displayName)': $($_.Exception.Message)") }
  $builtServices += @{ displayName = $svc.displayName; id = $sid }
}

# ---- 7. Publish ----------------------------------------------------------------
try { Invoke-MgGraphRequest -Method POST -Uri "$B/publish" -OutputType Hashtable | Out-Null; Log 'published.' }
catch { $errors.Add("publish: $($_.Exception.Message)") }

# ---- 8. Resolve public URL + SMTP ---------------------------------------------
$final = GraphGet "$B`?`$select=id,displayName,email,publicUrl,isPublished,webSiteUrl,defaultTimeZone"
$final | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $capDir '06-final-business.json')
$smtp = if ($final.email) { $final.email } else { $bizId }
$result = [ordered]@{
  account      = $ctx.Account
  businessId   = $bizId
  businessSmtp = $smtp
  displayName  = $final.displayName
  publicUrl    = $final.publicUrl
  isPublished  = $final.isPublished
  defaultTimeZone = $final.defaultTimeZone
  staffId      = $staffId
  services     = $builtServices
  questionIds  = $questionIds
  errors       = @($errors)
}
$result | ConvertTo-Json -Depth 8 | Set-Content $resultPath
Log ("RESULT: business={0} published={1} publicUrl={2}" -f $bizId, $final.isPublished, $final.publicUrl)
if ($errors.Count) { Log ("NOTE: {0} sub-step error(s) -- see bookings-result.json" -f $errors.Count) }
Log "wrote $resultPath"
Disconnect-MgGraph | Out-Null
