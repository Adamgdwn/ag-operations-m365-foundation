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

# Stage 6 - Teams, Planner, Lists & Operating State : LIST PROVISIONING.
# Live write. Creates the four Stage 6 Microsoft Lists, their columns, and their
# first useful views from config/M365_STAGE_6_OPERATING_STATE_SCHEMA.json.
#
# This script does not create Teams, Planner plans, mailbox rules, permissions,
# guests, external sharing, or automation. It signs Adam in interactively and has
# a typed confirmation gate before any tenant write.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage6ListsProvisioningInteractive.ps1, which prefers pwsh.exe."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-provision-lists-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
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

function Test-JsonProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    return ($Object.PSObject.Properties.Name -contains $Name)
}

function Add-Stage6Field {
    param(
        [string]$ListTitle,
        [object]$Column
    )

    $existing = Get-PnPField -List $ListTitle -Identity $Column.internalName -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] Field exists: {0}" -f $Column.displayName) -ForegroundColor Gray
        return
    }

    $params = @{
        List = $ListTitle
        DisplayName = $Column.displayName
        InternalName = $Column.internalName
        Type = $Column.type
        AddToDefaultView = $true
    }

    if ($Column.required -eq $true) {
        $params.Required = $true
    }

    if ($Column.type -eq "Choice") {
        $params.Choices = @($Column.choices)
    }

    Add-PnPField @params | Out-Null
    Write-Host ("  [OK] Field created: {0}" -f $Column.displayName) -ForegroundColor Green

    if (Test-JsonProperty -Object $Column -Name "default") {
        try {
            Set-PnPField -List $ListTitle -Identity $Column.internalName -Values @{ DefaultValue = [string]$Column.default } | Out-Null
        }
        catch {
            Write-Host ("  [warn] Could not set default for {0}: {1}" -f $Column.displayName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

function Add-Stage6View {
    param(
        [string]$ListTitle,
        [object]$View
    )

    $existing = Get-PnPView -List $ListTitle -Identity $View.title -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] View exists: {0}" -f $View.title) -ForegroundColor Gray
        return
    }

    $params = @{
        List = $ListTitle
        Title = $View.title
        Fields = @($View.fields)
    }

    if ((Test-JsonProperty -Object $View -Name "default") -and $View.default -eq $true) {
        $params.SetAsDefault = $true
    }

    try {
        Add-PnPView @params | Out-Null
        Write-Host ("  [OK] View created: {0}" -f $View.title) -ForegroundColor Green
    }
    catch {
        Write-Host ("  [warn] Could not create view {0}: {1}" -f $View.title, $_.Exception.Message) -ForegroundColor Yellow
    }
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

    Write-Host ("Connected user: {0}" -f $upn) -ForegroundColor Gray
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
    Write-Host ("Connected to {0} using {1}" -f $SiteUrl, $connection.ConnectionType) -ForegroundColor Gray
    Assert-Stage6ExpectedUser -SiteUrl $SiteUrl

    try {
        $web = Get-PnPWeb -Includes Title,Url
        Write-Host ("Preflight OK: readable site '{0}'" -f $web.Title) -ForegroundColor Green
    }
    catch {
        throw "Connected to $SiteUrl, but PnP cannot read the site. This usually means the provisioning app consent/scope is not usable for SharePoint site operations. Do not retry writes until agent-pnp-provisioning has been reviewed in Entra admin center. Original error: $($_.Exception.Message)"
    }
}

$resolvedSchemaPath = Resolve-LocalPath -Path $SchemaPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($RootUrl)) {
    $RootUrl = $schema.rootUrl
}
$RootUrl = $RootUrl.TrimEnd("/")

Write-Host "Microsoft 365 Stage 6 - Provision operating-state Lists" -ForegroundColor Cyan
Write-Host ""
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
Write-Host ""
Write-Host "This will create or update these Microsoft Lists:" -ForegroundColor Yellow
foreach ($list in $schema.lists) {
    Write-Host ("- {0} ({1}{2})" -f $list.title, $RootUrl, $list.sitePath) -ForegroundColor White
}
Write-Host ""
Write-Host "It will NOT create Teams, Planner plans, guest access, external sharing, mailbox rules, or automation." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type 'yes' to create/update these Stage 6 Lists now (anything else aborts)"
if ($confirm -ne "yes") {
    Write-Host "Aborted. Nothing was created." -ForegroundColor Yellow
    exit 0
}

$grouped = $schema.lists | Group-Object -Property sitePath
foreach ($siteGroup in $grouped) {
    $sitePath = $siteGroup.Name
    $siteUrl = "$RootUrl$sitePath"
    $siteTitle = $siteGroup.Group[0].siteTitle

    Write-Section ("Site: {0} ({1})" -f $siteTitle, $siteUrl)
    Write-Host "A Microsoft sign-in window may open. Sign in as adamgoodwin@guidedailabs.com. PnP persistent login is enabled." -ForegroundColor Yellow
    Connect-Stage6PnP -SiteUrl $siteUrl

    foreach ($list in $siteGroup.Group) {
        Write-Section ("List: {0}" -f $list.title)
        $existingList = Get-PnPList -Identity $list.title -ErrorAction SilentlyContinue
        if ($null -eq $existingList) {
            New-PnPList -Title $list.title -Template GenericList -OnQuickLaunch:$list.quickLaunch | Out-Null
            Write-Host ("  [OK] List created: {0}" -f $list.title) -ForegroundColor Green
        }
        else {
            Write-Host ("  [skip] List exists: {0}" -f $list.title) -ForegroundColor Gray
        }

        if (Test-JsonProperty -Object $list -Name "description") {
            Set-PnPList -Identity $list.title -Description $list.description | Out-Null
        }

        foreach ($column in $list.columns) {
            Add-Stage6Field -ListTitle $list.title -Column $column
        }

        foreach ($view in $list.views) {
            Add-Stage6View -ListTitle $list.title -View $view
        }
    }
}

Write-Section "Done"
Write-Host "Stage 6 Lists provisioning finished. Run scripts\Invoke-M365Stage6VerifyLists.ps1 next for read-back verification." -ForegroundColor Green
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
