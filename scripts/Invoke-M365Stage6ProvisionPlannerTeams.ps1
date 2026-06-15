param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$TenantId = "1ca92af5-21ff-42e3-87ae-3bde9c2cc501",
    [string]$TenantDomain = "AGOperationsLtd.onmicrosoft.com",
    [string]$RootUrl,
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$GroupDisplayName = "Guided AI Labs",
    [switch]$UseDeviceCode,
    [switch]$PreserveGraphConnection,
    [switch]$SkipWebTabs,
    [switch]$NoPause
)

# Stage 6 - Planner/Teams provisioning.
# Creates only the approved internal collaboration surfaces:
# - one Planner plan in the existing Guided AI Labs Microsoft 365 group;
# - the expected Planner buckets;
# - Teams-backing for the existing group if missing;
# - standard internal channels;
# - website tabs to the verified Lists/libraries/Planner plan, unless -SkipWebTabs.
#
# It does NOT create guests, external sharing links, mailbox rules, sends,
# calendar commitments, tenant policies, or group membership changes.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw "Microsoft.Graph.Authentication is not available in this PowerShell host. Install Microsoft.Graph or run the local preflight first."
}
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-provision-planner-teams-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Invoke-GraphJson {
    param(
        [ValidateSet("POST", "PATCH", "PUT")]
        [string]$Method,
        [string]$Uri,
        [hashtable]$Body
    )

    $json = $Body | ConvertTo-Json -Depth 20
    return Invoke-MgGraphRequest -Method $Method -Uri $Uri -Body $json -ContentType "application/json" -OutputType PSObject
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
        throw "Microsoft 365 group not found: $DisplayName. This script will not create a duplicate group."
    }
    if ($groups.Count -gt 1) {
        throw "Multiple Microsoft 365 groups found with displayName '$DisplayName'. Refine -GroupDisplayName before running writes."
    }
    return $groups[0]
}

function Ensure-ExpectedUserCanCreateGroupPlanner {
    param([string]$GroupId)

    $user = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/me?`$select=id,userPrincipalName,displayName" -OutputType PSObject
    $members = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/members?`$select=id,userPrincipalName,displayName")
    $owners = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/owners?`$select=id,userPrincipalName,displayName")
    $isMember = @($members | Where-Object { $_.id -eq $user.id }).Count -gt 0
    $isOwner = @($owners | Where-Object { $_.id -eq $user.id }).Count -gt 0

    Write-Host ("Signed-in user group role: member={0}; owner={1}" -f $isMember, $isOwner) -ForegroundColor Gray
    if ($isMember) {
        return $false
    }

    if (-not $isOwner) {
        throw "Planner plan creation requires the signed-in user to be a member of the target Microsoft 365 group. The signed-in user is not currently a member or owner."
    }

    Write-Host ""
    Write-Host "Planner requires the signed-in owner account to also be a member of the Microsoft 365 group." -ForegroundColor Yellow
    Write-Host ("This will add {0} as a member of the existing '{1}' group." -f $user.userPrincipalName, $GroupDisplayName) -ForegroundColor Yellow
    Write-Host "It will not add guests, external users, or change any other memberships." -ForegroundColor Yellow
    $confirmMembership = Read-Host "Type 'add-owner-as-member' to make this internal membership repair now (anything else aborts)"
    if ($confirmMembership -ne "add-owner-as-member") {
        throw "Membership repair was not approved. Planner provisioning cannot continue."
    }

    $body = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.id)"
    }
    Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/members/`$ref" -Body $body | Out-Null
    Write-Host ("[created] Added {0} as a member of {1}" -f $user.userPrincipalName, $GroupDisplayName) -ForegroundColor Green
    return $true
}

function Get-Stage6PlannerPlan {
    param(
        [string]$GroupId,
        [string]$PlanTitle
    )

    $plans = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/planner/plans")
    return @($plans | Where-Object { $_.title -eq $PlanTitle } | Select-Object -First 1)
}

function Ensure-Stage6PlannerPlan {
    param(
        [string]$GroupId,
        [string]$PlanTitle
    )

    $plan = $null
    for ($attempt = 1; $attempt -le 6; $attempt++) {
        try {
            $plan = Get-Stage6PlannerPlan -GroupId $GroupId -PlanTitle $PlanTitle
            break
        }
        catch {
            if ($_.Exception.Message -notmatch "403|Forbidden|required permissions|access this item" -or $attempt -eq 6) {
                throw
            }

            Write-Host ("[wait] Planner still reports access is not ready after membership repair; retry {0}/6 in 30 seconds." -f $attempt) -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }

    if ($null -ne $plan -and -not [string]::IsNullOrWhiteSpace($plan.id)) {
        Write-Host ("[skip] Planner plan exists: {0} ({1})" -f $plan.title, $plan.id) -ForegroundColor Gray
        return $plan
    }

    $body = @{
        container = @{
            url = "https://graph.microsoft.com/v1.0/groups/$GroupId"
        }
        title = $PlanTitle
    }
    $plan = Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/planner/plans" -Body $body
    Write-Host ("[OK] Planner plan created: {0} ({1})" -f $plan.title, $plan.id) -ForegroundColor Green
    return $plan
}

function Ensure-Stage6PlannerBuckets {
    param(
        [string]$PlanId,
        [object[]]$BucketNames
    )

    $existing = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/planner/plans/$PlanId/buckets")
    foreach ($bucketName in $BucketNames) {
        $name = [string]$bucketName
        $bucket = @($existing | Where-Object { $_.name -eq $name } | Select-Object -First 1)
        if ($bucket.Count -gt 0) {
            Write-Host ("[skip] Bucket exists: {0}" -f $name) -ForegroundColor Gray
            continue
        }

        $body = @{
            name = $name
            planId = $PlanId
            orderHint = " !"
        }
        $created = Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/planner/buckets" -Body $body
        Write-Host ("[OK] Bucket created: {0}" -f $created.name) -ForegroundColor Green
    }
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

function Wait-Stage6Team {
    param(
        [string]$GroupId,
        [int]$TimeoutSeconds = 300
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        $team = Invoke-GraphGetOrNull -Uri "https://graph.microsoft.com/v1.0/teams/$GroupId"
        if ($null -ne $team) {
            return $team
        }

        Write-Host "  waiting for Teams provisioning..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
    } while ((Get-Date) -lt $deadline)

    throw "Timed out waiting for Teams provisioning for group $GroupId."
}

function Ensure-Stage6Team {
    param([string]$GroupId)

    $team = Invoke-GraphGetOrNull -Uri "https://graph.microsoft.com/v1.0/teams/$GroupId"
    if ($null -ne $team) {
        Write-Host ("[skip] Team already exists for group: {0}" -f $team.displayName) -ForegroundColor Gray
        return $team
    }

    $body = @{
        "template@odata.bind" = "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
        "group@odata.bind" = "https://graph.microsoft.com/v1.0/groups('$GroupId')"
        memberSettings = @{
            allowCreateUpdateChannels = $true
            allowDeleteChannels = $false
            allowAddRemoveApps = $false
            allowCreateUpdateRemoveTabs = $true
            allowCreateUpdateRemoveConnectors = $false
        }
        messagingSettings = @{
            allowUserEditMessages = $true
            allowUserDeleteMessages = $false
        }
        funSettings = @{
            allowGiphy = $false
            allowStickersAndMemes = $false
            allowCustomMemes = $false
        }
    }

    Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/teams" -Body $body | Out-Null
    Write-Host "[OK] Team provisioning started for existing Microsoft 365 group." -ForegroundColor Green
    return Wait-Stage6Team -GroupId $GroupId
}

function Ensure-Stage6Channels {
    param(
        [string]$TeamId,
        [object[]]$ChannelSpecs
    )

    $channels = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels")
    foreach ($channelSpec in $ChannelSpecs) {
        $name = [string]$channelSpec.name
        $channel = @($channels | Where-Object { $_.displayName -eq $name } | Select-Object -First 1)
        if ($channel.Count -gt 0) {
            Write-Host ("[skip] Channel exists: {0}" -f $name) -ForegroundColor Gray
            continue
        }
        if ($name -eq "General") {
            Write-Host "[skip] General channel is created by Teams." -ForegroundColor Gray
            continue
        }

        $body = @{
            displayName = $name
            description = Get-Stage6ChannelPurpose -Name $name
            membershipType = "standard"
        }
        $created = Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels" -Body $body
        Write-Host ("[OK] Channel created: {0}" -f $created.displayName) -ForegroundColor Green
        $channels += $created
    }

    return @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels")
}

function ConvertTo-Stage6UrlEncodedPathSegment {
    param([string]$Value)
    return [uri]::EscapeDataString($Value).Replace("+", "%20")
}

function Get-Stage6ListUrl {
    param([string]$ListTitle)

    $encodedTitle = ConvertTo-Stage6UrlEncodedPathSegment -Value $ListTitle
    return "$RootUrl/sites/GuidedAILabs/Lists/$encodedTitle/AllItems.aspx"
}

function Get-Stage6TabUrl {
    param(
        [string]$TabName,
        [string]$GroupId,
        [string]$PlanId
    )

    switch ($TabName) {
        "Operating Plan" {
            return "https://tasks.office.com/$TenantDomain/Home/Planner/#/plantaskboard?groupId=$GroupId&planId=$PlanId"
        }
        "Intake Register" {
            return Get-Stage6ListUrl -ListTitle "Guided AI Labs - Intake Register"
        }
        "Agent Log" {
            return Get-Stage6ListUrl -ListTitle "Agent Action Log"
        }
        "Decisions" {
            return Get-Stage6ListUrl -ListTitle "Decision Register"
        }
        "Client_Delivery" {
            return "$RootUrl/sites/GuidedAILabs/Client_Delivery"
        }
        "Automation_Workflows" {
            return "$RootUrl/sites/GuidedAILabs/Operating/05_Automation_Workflows"
        }
        "Templates_Methods" {
            return "$RootUrl/sites/GuidedAILabs/Templates_Methods"
        }
        default {
            return $null
        }
    }
}

function Ensure-Stage6WebTabs {
    param(
        [string]$TeamId,
        [object[]]$ChannelSpecs,
        [object[]]$Channels,
        [string]$GroupId,
        [string]$PlanId
    )

    foreach ($channelSpec in $ChannelSpecs) {
        $channelName = [string]$channelSpec.name
        $channel = @($Channels | Where-Object { $_.displayName -eq $channelName } | Select-Object -First 1)
        if ($channel.Count -eq 0) {
            Write-Host ("[warn] Cannot add tabs; channel missing: {0}" -f $channelName) -ForegroundColor Yellow
            continue
        }

        $tabs = @(Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$($channel[0].id)/tabs")
        foreach ($tabNameObject in $channelSpec.tabs) {
            $tabName = [string]$tabNameObject
            $existing = @($tabs | Where-Object { $_.displayName -eq $tabName } | Select-Object -First 1)
            if ($existing.Count -gt 0) {
                Write-Host ("[skip] Tab exists: {0} / {1}" -f $channelName, $tabName) -ForegroundColor Gray
                continue
            }

            $url = Get-Stage6TabUrl -TabName $tabName -GroupId $GroupId -PlanId $PlanId
            if ([string]::IsNullOrWhiteSpace($url)) {
                Write-Host ("[warn] No URL mapping for tab: {0} / {1}" -f $channelName, $tabName) -ForegroundColor Yellow
                continue
            }

            $body = @{
                displayName = $tabName
                "teamsApp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps('com.microsoft.teamspace.tab.web')"
                configuration = @{
                    entityId = $null
                    contentUrl = $url
                    websiteUrl = $url
                    removeUrl = $null
                }
            }

            try {
                $created = Invoke-GraphJson -Method POST -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$($channel[0].id)/tabs" -Body $body
                Write-Host ("[OK] Web tab pinned: {0} / {1}" -f $channelName, $created.displayName) -ForegroundColor Green
            }
            catch {
                Write-Host ("[warn] Could not pin tab '{0}' in channel '{1}': {2}" -f $tabName, $channelName, $_.Exception.Message) -ForegroundColor Yellow
            }
        }
    }
}

$resolvedSchemaPath = Resolve-LocalPath -Path $SchemaPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($RootUrl)) {
    $RootUrl = $schema.rootUrl
}
$RootUrl = $RootUrl.TrimEnd("/")

Write-Host "Microsoft 365 Stage 6 - Provision Planner/Teams" -ForegroundColor Cyan
Write-Host "Schema: $resolvedSchemaPath" -ForegroundColor Gray
Write-Host "Root:   $RootUrl" -ForegroundColor Gray
Write-Host "Log:    $transcriptPath" -ForegroundColor Gray
Write-Host "Group:  $GroupDisplayName" -ForegroundColor Gray
Write-Host "User:   expected signed-in user is $ExpectedUpn" -ForegroundColor Gray
Write-Host ""
Write-Host "This will create or confirm:" -ForegroundColor White
Write-Host ("- Planner plan: {0}" -f $schema.planner.planTitle) -ForegroundColor White
Write-Host ("- Planner buckets: {0}" -f (($schema.planner.buckets | ForEach-Object { [string]$_ }) -join ", ")) -ForegroundColor White
Write-Host ("- Team-enabled existing group: {0}" -f $GroupDisplayName) -ForegroundColor White
Write-Host ("- Standard channels: {0}" -f (($schema.teams.channels | ForEach-Object { [string]$_.name }) -join ", ")) -ForegroundColor White
if ($SkipWebTabs) {
    Write-Host "- Web tabs: skipped by parameter" -ForegroundColor Yellow
}
else {
    Write-Host "- Web tabs: best-effort website tabs for Lists, Planner, and existing libraries" -ForegroundColor White
}
Write-Host ""
Write-Host "It will NOT create guests, external sharing, mailbox rules, sends, calendar commitments, or tenant policies." -ForegroundColor Yellow
Write-Host "If Adam is an owner but not a member of the target group, it may ask for a separate typed approval to add Adam as an internal group member so Planner can work." -ForegroundColor Yellow
Write-Host "Teams will inherit the existing Microsoft 365 group name; this avoids creating a duplicate group/team." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Type 'planner-teams' to provision these Stage 6 Planner/Teams surfaces now (anything else aborts)"
if ($confirm -ne "planner-teams") {
    Write-Host "Aborted. Nothing was changed." -ForegroundColor Yellow
    try { Stop-Transcript | Out-Null } catch { }
    if (-not $NoPause) {
        Write-Host "Press Enter to close this window."
        Read-Host | Out-Null
    }
    exit 0
}

try {
    Connect-Stage6Graph

    Write-Section "Microsoft 365 group"
    $group = Get-Stage6Group -DisplayName $GroupDisplayName
    Write-Host ("[OK] Target group: {0} ({1})" -f $group.displayName, $group.id) -ForegroundColor Green
    $membershipWasRepaired = Ensure-ExpectedUserCanCreateGroupPlanner -GroupId $group.id
    if ($membershipWasRepaired) {
        Write-Host "[wait] Waiting 60 seconds for Microsoft 365 group membership to propagate to Planner." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
        Write-Host "[auth] Reconnecting Graph so the current process sees the updated membership state." -ForegroundColor Gray
        try { Disconnect-MgGraph | Out-Null } catch { }
        Connect-Stage6Graph
    }

    Write-Section "Planner"
    $plan = Ensure-Stage6PlannerPlan -GroupId $group.id -PlanTitle ([string]$schema.planner.planTitle)
    Ensure-Stage6PlannerBuckets -PlanId $plan.id -BucketNames $schema.planner.buckets

    Write-Section "Teams"
    $team = Ensure-Stage6Team -GroupId $group.id
    if ($team.displayName -ne $schema.teams.teamTitle) {
        Write-Host ("[note] Team display name is '{0}' because Teams inherits the existing group name. Schema operating label is '{1}'." -f $team.displayName, $schema.teams.teamTitle) -ForegroundColor Yellow
    }
    $channels = Ensure-Stage6Channels -TeamId $group.id -ChannelSpecs $schema.teams.channels

    if (-not $SkipWebTabs) {
        Write-Section "Teams tabs"
        Ensure-Stage6WebTabs -TeamId $group.id -ChannelSpecs $schema.teams.channels -Channels $channels -GroupId $group.id -PlanId $plan.id
    }
}
finally {
    if (-not $PreserveGraphConnection) {
        try { Disconnect-MgGraph | Out-Null } catch { }
    }
    try { Stop-Transcript | Out-Null } catch { }
}

Write-Host ""
Write-Host "Stage 6 Planner/Teams provisioning finished." -ForegroundColor Green
Write-Host ("Transcript: {0}" -f $transcriptPath) -ForegroundColor Gray

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Done. Press Enter to close this window."
    Read-Host | Out-Null
}
