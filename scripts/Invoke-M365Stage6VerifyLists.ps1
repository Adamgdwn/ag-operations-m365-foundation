param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl,
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# Stage 6 - Teams, Planner, Lists & Operating State : READ-ONLY LIST VERIFY.
# Changes nothing. Reads the Stage 6 schema and checks that each expected List,
# field, and view exists on the target SharePoint sites.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-verify-lists-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

    $scriptRoot = Split-Path -Parent $PSCommandPath
    return (Resolve-Path -LiteralPath (Join-Path $scriptRoot "..\$Path")).Path
}

function Get-Stage6ClaimValue {
    param(
        [object]$Token,
        [string]$Name
    )

    $values = @($Token.Claims | Where-Object { $_.Type -eq $Name } | ForEach-Object { $_.Value })
    return ($values -join ", ")
}

function Assert-Stage6ExpectedUser {
    param([string]$SiteUrl)

    $authority = ([uri]$SiteUrl).GetLeftPart([System.UriPartial]::Authority)
    $token = Get-PnPAccessToken -ResourceUrl $authority -Decoded
    $upn = Get-Stage6ClaimValue -Token $token -Name "upn"
    if ([string]::IsNullOrWhiteSpace($upn)) {
        $upn = Get-Stage6ClaimValue -Token $token -Name "preferred_username"
    }

    Write-Host ("  Connected user: {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

function Connect-Stage6PnP {
    param([string]$SiteUrl)

    if ($UseDeviceLogin) {
        Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $Tenant -DeviceLogin
    }
    else {
        $connectParams = @{
            Url = $SiteUrl
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
    Write-Host ("  Connected using {0}" -f $connection.ConnectionType) -ForegroundColor Gray
    Assert-Stage6ExpectedUser -SiteUrl $SiteUrl

    try {
        $web = Get-PnPWeb -Includes Title,Url
        Write-Host ("  Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
    }
    catch {
        throw "Connected to $SiteUrl, but PnP cannot read the site. This usually means the provisioning app consent/scope is not usable for SharePoint site operations. Original error: $($_.Exception.Message)"
    }
}

$resolvedSchemaPath = Resolve-LocalPath -Path $SchemaPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($RootUrl)) {
    $RootUrl = $schema.rootUrl
}
$RootUrl = $RootUrl.TrimEnd("/")

Write-Host "Microsoft 365 Stage 6 - Verify operating-state Lists (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Schema: $resolvedSchemaPath" -ForegroundColor Gray
Write-Host "Root:   $RootUrl" -ForegroundColor Gray
Write-Host "Log:    $transcriptPath" -ForegroundColor Gray
if ($ForceFreshLogin) {
    Write-Host "Auth:   force fresh Microsoft sign-in enabled" -ForegroundColor Gray
}
else {
    Write-Host "Auth:   persistent PnP login enabled" -ForegroundColor Gray
}
Write-Host "User:   expected signed-in user is $ExpectedUpn" -ForegroundColor Gray
if ($UseDeviceLogin) {
    Write-Host "Auth:   device login enabled" -ForegroundColor Gray
}

$failures = 0
$grouped = $schema.lists | Group-Object -Property sitePath
foreach ($siteGroup in $grouped) {
    $sitePath = $siteGroup.Name
    $siteUrl = "$RootUrl$sitePath"
    $siteTitle = $siteGroup.Group[0].siteTitle

    Write-Section ("Site: {0} ({1})" -f $siteTitle, $siteUrl)
    try {
        Connect-Stage6PnP -SiteUrl $siteUrl
    }
    catch {
        Write-Host ("  FAIL: cannot connect to site - {0}" -f $_.Exception.Message) -ForegroundColor Red
        $failures++
        continue
    }

    foreach ($list in $siteGroup.Group) {
        $existingList = Get-PnPList -Identity $list.title -ErrorAction SilentlyContinue
        if ($null -eq $existingList) {
            Write-Host ("  FAIL: missing list '{0}'" -f $list.title) -ForegroundColor Red
            $failures++
            continue
        }

        $missingFields = @()
        foreach ($column in $list.columns) {
            $field = Get-PnPField -List $list.title -Identity $column.internalName -ErrorAction SilentlyContinue
            if ($null -eq $field) {
                $missingFields += $column.internalName
            }
        }

        $missingViews = @()
        foreach ($view in $list.views) {
            $existingView = Get-PnPView -List $list.title -Identity $view.title -ErrorAction SilentlyContinue
            if ($null -eq $existingView) {
                $missingViews += $view.title
            }
        }

        if ($missingFields.Count -eq 0 -and $missingViews.Count -eq 0) {
            Write-Host ("  OK  {0}: {1} fields, {2} views" -f $list.title, $list.columns.Count, $list.views.Count) -ForegroundColor Green
        }
        else {
            Write-Host ("  FAIL {0}: missing fields [{1}] missing views [{2}]" -f $list.title, ($missingFields -join ", "), ($missingViews -join ", ")) -ForegroundColor Red
            $failures++
        }
    }
}

Write-Section "Summary"
if ($failures -eq 0) {
    Write-Host "PASS - all Stage 6 Lists, fields, and views match the schema." -ForegroundColor Green
}
else {
    Write-Host ("FAIL - {0} issue(s) found above. Stage 6 Lists are not yet clean." -f $failures) -ForegroundColor Red
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
