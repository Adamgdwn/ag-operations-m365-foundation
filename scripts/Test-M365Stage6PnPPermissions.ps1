param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl = "https://agoperationsltd.sharepoint.com",
    [string]$Tenant = "AGOperationsLtd.onmicrosoft.com",
    [string]$ExpectedUpn = "adamgoodwin@guidedailabs.com",
    [switch]$ForceFreshLogin,
    [switch]$UseDeviceLogin,
    [switch]$NoPause
)

# Stage 6 - READ-ONLY PnP permission diagnostic.
# Connects to the two Stage 6 target sites and reports what the connected
# identity can read about the web, lists, and current user. It does not create,
# update, or delete anything.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run with PowerShell 7 on this machine."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-pnp-permissions-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
Start-Transcript -Path $transcriptPath -Force | Out-Null

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

    Write-Host ("Connected user:  {0}" -f $upn) -ForegroundColor Gray
    if ($ExpectedUpn -and ($upn -ne $ExpectedUpn)) {
        throw "Wrong signed-in user. Expected '$ExpectedUpn' but token is for '$upn'. Re-run with -UseDeviceLogin and choose the expected account."
    }
}

Write-Host "Microsoft 365 Stage 6 - PnP permission diagnostic (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Root: $RootUrl" -ForegroundColor Gray
Write-Host "Log:  $transcriptPath" -ForegroundColor Gray
Write-Host "Expected signed-in user: $ExpectedUpn" -ForegroundColor Gray
if ($UseDeviceLogin) {
    Write-Host "Auth: device login enabled" -ForegroundColor Gray
}

$sites = @(
    @{ Title = "Change Leadership Tools"; Url = "$($RootUrl.TrimEnd('/'))/sites/ChangeLeadershipTools" },
    @{ Title = "Guided AI Labs"; Url = "$($RootUrl.TrimEnd('/'))/sites/GuidedAILabs" }
)

foreach ($site in $sites) {
    Write-Host ""
    Write-Host ("== {0} ({1}) ==" -f $site.Title, $site.Url) -ForegroundColor Cyan
    try {
        Connect-Stage6PnP -SiteUrl $site.Url
        $connection = Get-PnPConnection
        Write-Host ("ConnectionType: {0}" -f $connection.ConnectionType) -ForegroundColor Gray
        if ($connection.PSObject.Properties.Name -contains "Url") {
            Write-Host ("ConnectedUrl:    {0}" -f $connection.Url) -ForegroundColor Gray
        }
        Assert-Stage6ExpectedUser -SiteUrl $site.Url

        $web = Get-PnPWeb -Includes Title,Url,CurrentUser,EffectiveBasePermissions,AssociatedOwnerGroup,AssociatedMemberGroup
        Write-Host ("Web:             {0}" -f $web.Title) -ForegroundColor White
        Write-Host ("CurrentUser:     {0}" -f $web.CurrentUser.LoginName) -ForegroundColor White
        Write-Host ("Owners group:    {0}" -f $web.AssociatedOwnerGroup.Title) -ForegroundColor White
        Write-Host ("Members group:   {0}" -f $web.AssociatedMemberGroup.Title) -ForegroundColor White

        $lists = Get-PnPList | Where-Object { -not $_.Hidden } | Sort-Object Title | Select-Object -First 10
        Write-Host ("Visible lists:   {0}" -f (($lists.Title) -join ", ")) -ForegroundColor White

        $addListXml = '<View Scope="RecursiveAll"><Query><Where><Eq><FieldRef Name="Title"/><Value Type="Text">__permission_probe_no_create__</Value></Eq></Where></Query></View>'
        Write-Host "Read-only diagnostic complete for this site." -ForegroundColor Green
        $null = $addListXml
    }
    catch {
        Write-Host ("FAIL: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Stop-Transcript | Out-Null
if (-not $NoPause) {
    Write-Host "Done. Press Enter to close this window."
    Read-Host | Out-Null
}
