param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$GroupDisplayName = "Guided AI Labs",
    [string]$ChannelName = "New Signal",
    [string]$ChannelDescription = "Immediate internal alerts when new CRM signals land.",
    [switch]$Apply,
    [switch]$UseDeviceCode,
    [switch]$PreserveGraphConnection,
    [switch]$NoPause
)

# Ensures the internal Guided AI Labs Teams channel used by the first-minute CRM
# signal alert lane. Without -Apply this is read-only. With -Apply it creates
# only one standard internal channel after a typed confirmation.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw "Microsoft.Graph.Authentication is not available in this PowerShell host. Install Microsoft.Graph or run the local preflight first."
}
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$outputRoot = Join-Path $workspaceRoot "inventory\new-signal-alert"
$flowOutputRoot = Join-Path $workspaceRoot "inventory\forms-build"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
New-Item -ItemType Directory -Path $flowOutputRoot -Force | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$transcriptPath = Join-Path $outputRoot ("new-signal-teams-channel-{0}.log" -f $stamp)
$resultPath = Join-Path $flowOutputRoot "new-signal-teams-channel.json"

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

function Get-GraphCollection {
    param([string]$Uri)

    $items = New-Object System.Collections.Generic.List[object]
    $next = $Uri
    while ($next) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $next -OutputType PSObject
        if ($null -ne $response.value) {
            foreach ($item in $response.value) {
                $items.Add($item)
            }
            $next = $response.'@odata.nextLink'
        }
        else {
            $items.Add($response)
            $next = $null
        }
    }

    return $items.ToArray()
}

function Invoke-GraphGetOrNull {
    param([string]$Uri)

    try {
        return Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject
    }
    catch {
        $message = $_.Exception.Message
        if ($message -match "404|NotFound|Not Found") {
            return $null
        }
        throw
    }
}

function Invoke-GraphJson {
    param(
        [ValidateSet("POST")]
        [string]$Method,
        [string]$Uri,
        [hashtable]$Body
    )

    $json = $Body | ConvertTo-Json -Depth 20
    return Invoke-MgGraphRequest -Method $Method -Uri $Uri -Body $json -ContentType "application/json" -OutputType PSObject
}

function Connect-NewSignalGraph {
    $scopes = @(
        "User.Read",
        "Group.ReadWrite.All",
        "Channel.Create"
    )

    $params = @{
        ClientId = $ClientId
        TenantId = $TenantId
        Scopes = $scopes
        ContextScope = "Process"
        NoWelcome = $true
    }
    if ($UseDeviceCode) {
        $params.UseDeviceCode = $true
    }

    Connect-MgGraph @params | Out-Null
    $context = Get-MgContext
    Write-Host ("Connected Graph account: {0}" -f $context.Account) -ForegroundColor Gray
    Write-Host ("Graph scopes: {0}" -f (($context.Scopes | Sort-Object) -join ", ")) -ForegroundColor Gray

    if ($ExpectedUpn -and ($context.Account -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but Graph connected as '$($context.Account)'. Re-run with -UseDeviceCode and choose the expected account."
    }
}

function Get-TargetGroup {
    param([string]$DisplayName)

    $escaped = $DisplayName.Replace("'", "''")
    $filter = [uri]::EscapeDataString("displayName eq '$escaped'")
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=$filter&`$select=id,displayName,mail,visibility,groupTypes"
    $groups = @(Get-GraphCollection -Uri $uri)
    if ($groups.Count -eq 0) {
        throw "Microsoft 365 group not found: $DisplayName"
    }
    if ($groups.Count -gt 1) {
        throw "Multiple Microsoft 365 groups found with displayName '$DisplayName'. Refine -GroupDisplayName before running writes."
    }
    return $groups[0]
}

function Write-ChannelResult {
    param(
        [object]$Group,
        [object]$Team,
        [object]$Channel,
        [string]$Status
    )

    $result = [ordered]@{
        purpose = "new CRM signal Teams alert target"
        status = $Status
        groupDisplayName = [string]$Group.displayName
        groupId = [string]$Group.id
        teamDisplayName = [string]$Team.displayName
        channelDisplayName = [string]$Channel.displayName
        channelId = [string]$Channel.id
        channelWebUrl = [string]$Channel.webUrl
        transcript = $transcriptPath
        updatedAt = (Get-Date).ToString("o")
    }

    $result | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $resultPath -Encoding UTF8
    Write-Host ("Wrote channel target: {0}" -f $resultPath) -ForegroundColor Green
}

Write-Host "M365 New Signal Teams channel setup" -ForegroundColor Cyan
Write-Host ("Group:   {0}" -f $GroupDisplayName) -ForegroundColor Gray
Write-Host ("Channel: {0}" -f $ChannelName) -ForegroundColor Gray
Write-Host ("Mode:    {0}" -f ($(if ($Apply) { "Apply" } else { "Read-only" }))) -ForegroundColor Gray
Write-Host "Safety: creates only one standard internal channel when -Apply is used." -ForegroundColor Yellow
Write-Host "No guests, external sharing, permission broadening, tenant policy changes, posts, flows, mail, or CRM data changes." -ForegroundColor Yellow
Write-Host ""

try {
    Connect-NewSignalGraph

    $group = Get-TargetGroup -DisplayName $GroupDisplayName
    Write-Host ("PASS: group found: {0} ({1})" -f $group.displayName, $group.id) -ForegroundColor Green

    $team = Invoke-GraphGetOrNull -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)"
    if ($null -eq $team) {
        throw "Group '$GroupDisplayName' is not team-enabled. Run the Stage 6 Planner/Teams provision gate first."
    }
    Write-Host ("PASS: Team found: {0}" -f $team.displayName) -ForegroundColor Green

    $channels = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)/channels")
    $channel = @($channels | Where-Object { $_.displayName -eq $ChannelName } | Select-Object -First 1)

    if ($channel.Count -eq 0) {
        if (-not $Apply) {
            Write-Host ("MISSING: channel '{0}' does not exist yet." -f $ChannelName) -ForegroundColor Yellow
            Write-Host "Re-run with -Apply when ready to create the internal alert channel." -ForegroundColor Yellow
            exit 2
        }

        Write-Host ""
        Write-Host ("This will create the standard internal Teams channel '{0}' in '{1}'." -f $ChannelName, $GroupDisplayName) -ForegroundColor Yellow
        $confirm = Read-Host "Type 'create-new-signal-channel' to create it now (anything else aborts)"
        if ($confirm -ne "create-new-signal-channel") {
            throw "New Signal channel creation was not approved."
        }

        $body = @{
            displayName = $ChannelName
            description = $ChannelDescription
            membershipType = "standard"
        }
        $created = Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)/channels" -Body $body
        Write-Host ("CREATED: channel {0} ({1})" -f $created.displayName, $created.id) -ForegroundColor Green
        Start-Sleep -Seconds 5
        $channels = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)/channels")
        $channel = @($channels | Where-Object { $_.displayName -eq $ChannelName } | Select-Object -First 1)
    }
    else {
        Write-Host ("PASS: channel exists: {0} ({1})" -f $channel[0].displayName, $channel[0].id) -ForegroundColor Green
    }

    if ($channel.Count -eq 0) {
        throw "Channel '$ChannelName' was not found after creation/read-back."
    }

    Write-ChannelResult -Group $group -Team $team -Channel $channel[0] -Status ($(if ($Apply) { "ready-after-apply" } else { "ready-readback" }))
}
finally {
    if (-not $PreserveGraphConnection) {
        try { Disconnect-MgGraph | Out-Null } catch { }
    }
    try { Stop-Transcript | Out-Null } catch { }
}

Write-Host ""
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray
if (-not $NoPause) {
    Write-Host ""
    Write-Host "Done. Press Enter to close this window."
    Read-Host | Out-Null
}
