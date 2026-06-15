param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$RootUrl,
    [string]$GroupDisplayName = "Guided AI Labs",
    [switch]$UseDeviceCode,
    [switch]$PreserveGraphConnection,
    [switch]$NoPause
)

# Stage 6 - Planner/Teams read-only verifier.
# Uses Microsoft Graph with the already-approved Stage 6 app registration.
# It does not create, update, delete, invite, send, or change membership.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw "Microsoft.Graph.Authentication is not available in this PowerShell host. Install Microsoft.Graph or run the local preflight first."
}
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-verify-planner-teams-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Resolve-LocalPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Resolve-Path -LiteralPath (Join-Path $workspaceRoot $Path)).Path
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

function Connect-Stage6Graph {
    $scopes = @(
        "User.Read",
        "Group.ReadWrite.All",
        "Tasks.ReadWrite",
        "Channel.Create",
        "TeamsTab.Create"
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

function Get-Stage6Group {
    param([string]$DisplayName)

    $escaped = $DisplayName.Replace("'", "''")
    $filter = [uri]::EscapeDataString("displayName eq '$escaped'")
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=$filter&`$select=id,displayName,mail,mailEnabled,securityEnabled,groupTypes,visibility"
    $groups = @(Get-GraphCollection -Uri $uri)
    if ($groups.Count -eq 0) {
        throw "Microsoft 365 group not found: $DisplayName"
    }
    if ($groups.Count -gt 1) {
        throw "Multiple Microsoft 365 groups found with displayName '$DisplayName'. Refine -GroupDisplayName before running writes."
    }
    return $groups[0]
}

function Get-Stage6PlannerPlan {
    param(
        [string]$GroupId,
        [string]$PlanTitle
    )

    $plans = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/planner/plans")
    return @($plans | Where-Object { $_.title -eq $PlanTitle } | Select-Object -First 1)
}

function Get-Stage6ChannelPurpose {
    param([string]$Name)

    switch ($Name) {
        "General" { "Low-volume operating announcements and top-level coordination" }
        "Intake" { "Daily front-door triage and discussion around new inquiries" }
        "Client Discovery" { "Readiness and discovery work before active delivery" }
        "Active Delivery" { "Current delivery coordination" }
        "Agent Setup" { "Agentic intake, bridge, workflow, and tooling decisions" }
        "Methods and IP" { "Reusable methods, templates, and productized knowledge" }
        default { "Stage 6 operating coordination" }
    }
}

$resolvedSchemaPath = Resolve-LocalPath -Path $SchemaPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json
$failures = 0

Write-Host "Microsoft 365 Stage 6 - Verify Planner/Teams (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Schema: $resolvedSchemaPath" -ForegroundColor Gray
Write-Host "Log:    $transcriptPath" -ForegroundColor Gray
Write-Host "Group:  $GroupDisplayName" -ForegroundColor Gray
Write-Host "User:   expected signed-in user is $ExpectedUpn" -ForegroundColor Gray
Write-Host ""

try {
    Connect-Stage6Graph

    Write-Section "Microsoft 365 group"
    $group = Get-Stage6Group -DisplayName $GroupDisplayName
    Write-Host ("PASS: group found: {0} ({1})" -f $group.displayName, $group.id) -ForegroundColor Green
    Write-Host ("      mail: {0}; visibility: {1}; groupTypes: {2}" -f $group.mail, $group.visibility, (($group.groupTypes | ForEach-Object { [string]$_ }) -join ", ")) -ForegroundColor Gray

    Write-Section "Planner"
    $planTitle = [string]$schema.planner.planTitle
    $plannerReadFailed = $false
    try {
        $plan = Get-Stage6PlannerPlan -GroupId $group.id -PlanTitle $planTitle
    }
    catch {
        $failures++
        $plannerReadFailed = $true
        Write-Host ("FAIL: Planner plans are not readable for this signed-in user/app context: {0}" -f $_.Exception.Message) -ForegroundColor Red
        Write-Host "      The live provision step will perform the group membership/owner check before attempting Planner writes." -ForegroundColor Yellow
        $plan = $null
    }

    if ($null -ne $plan -and -not [string]::IsNullOrWhiteSpace($plan.id)) {
        try {
            Write-Host ("PASS: Planner plan found: {0} ({1})" -f $plan.title, $plan.id) -ForegroundColor Green
            $buckets = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/planner/plans/$($plan.id)/buckets")
            foreach ($bucketName in $schema.planner.buckets) {
                $bucket = @($buckets | Where-Object { $_.name -eq [string]$bucketName } | Select-Object -First 1)
                if ($bucket.Count -eq 0) {
                    $failures++
                    Write-Host ("FAIL: bucket missing: {0}" -f $bucketName) -ForegroundColor Red
                }
                else {
                    Write-Host ("PASS: bucket found: {0}" -f $bucketName) -ForegroundColor Green
                }
            }
        }
        catch {
            $failures++
            Write-Host ("FAIL: Planner buckets are not readable for this signed-in user/app context: {0}" -f $_.Exception.Message) -ForegroundColor Red
        }
    }
    elseif (-not $plannerReadFailed -and ($null -eq $plan -or [string]::IsNullOrWhiteSpace($plan.id))) {
        $failures++
        Write-Host ("FAIL: Planner plan missing or inaccessible: {0}" -f $planTitle) -ForegroundColor Red
    }

    Write-Section "Teams"
    $team = Invoke-GraphGetOrNull -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)"
    if ($null -eq $team) {
        $failures++
        Write-Host ("FAIL: group is not team-enabled yet: {0}" -f $GroupDisplayName) -ForegroundColor Red
    }
    else {
        Write-Host ("PASS: Team found for existing group: {0}" -f $team.displayName) -ForegroundColor Green
        if ($team.displayName -ne $schema.teams.teamTitle) {
            Write-Host ("NOTE: Teams inherits the existing group name '{0}'. Schema operating label is '{1}'." -f $team.displayName, $schema.teams.teamTitle) -ForegroundColor Yellow
        }

        $channels = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)/channels")
        foreach ($channelSpec in $schema.teams.channels) {
            $channelName = [string]$channelSpec.name
            $channel = @($channels | Where-Object { $_.displayName -eq $channelName } | Select-Object -First 1)
            if ($channel.Count -eq 0) {
                $failures++
                Write-Host ("FAIL: channel missing: {0}" -f $channelName) -ForegroundColor Red
                continue
            }

            Write-Host ("PASS: channel found: {0} - {1}" -f $channelName, (Get-Stage6ChannelPurpose -Name $channelName)) -ForegroundColor Green
            $tabs = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$($group.id)/channels/$($channel[0].id)/tabs")
            foreach ($tabName in $channelSpec.tabs) {
                $tab = @($tabs | Where-Object { $_.displayName -eq [string]$tabName } | Select-Object -First 1)
                if ($tab.Count -eq 0) {
                    Write-Host ("WARN: tab not pinned yet: {0} / {1}" -f $channelName, $tabName) -ForegroundColor Yellow
                }
                else {
                    Write-Host ("PASS: tab found: {0} / {1}" -f $channelName, $tabName) -ForegroundColor Green
                }
            }
        }
    }
}
finally {
    if (-not $PreserveGraphConnection) {
        try { Disconnect-MgGraph | Out-Null } catch { }
    }
    try { Stop-Transcript | Out-Null } catch { }
}

Write-Host ""
if ($failures -eq 0) {
    Write-Host "Stage 6 Planner/Teams read-only verification PASS." -ForegroundColor Green
}
else {
    Write-Host ("Stage 6 Planner/Teams read-only verification found {0} required gap(s)." -f $failures) -ForegroundColor Yellow
}
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Done. Press Enter to close this window."
    Read-Host | Out-Null
}
