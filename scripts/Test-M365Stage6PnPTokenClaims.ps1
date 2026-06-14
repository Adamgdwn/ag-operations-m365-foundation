param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl = "https://agoperationsltd.sharepoint.com",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 6 - READ-ONLY PnP token claims diagnostic.
# Connects to a target site and prints decoded token metadata only. It does not
# print bearer tokens and does not create, update, or delete tenant content.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Run with PowerShell 7 on this machine."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-6-operating-state"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-6-pnp-token-claims-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
Start-Transcript -Path $transcriptPath -Force | Out-Null

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Connect-Stage6PnP {
    param([string]$SiteUrl)

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

function Show-TokenClaims {
    param(
        [string]$Label,
        [string]$ResourceUrl
    )

    Write-Section $Label
    Write-Host ("Resource: {0}" -f $ResourceUrl) -ForegroundColor Gray
    try {
        $claims = Get-PnPAccessToken -ResourceUrl $ResourceUrl -Decoded
        Write-Host ("DecodedType: {0}" -f $claims.GetType().FullName) -ForegroundColor Gray
        Write-Host ("Properties:  {0}" -f (($claims.PSObject.Properties.Name | Sort-Object) -join ", ")) -ForegroundColor Gray
        $claimMap = @{}
        foreach ($claim in $claims.Claims) {
            if ($claimMap.ContainsKey($claim.Type)) {
                $claimMap[$claim.Type] = @($claimMap[$claim.Type]) + $claim.Value
            }
            else {
                $claimMap[$claim.Type] = $claim.Value
            }
        }
        function Get-ClaimValue {
            param([string]$Name)
            if ($claimMap.ContainsKey($Name)) {
                return (@($claimMap[$Name]) -join ", ")
            }
            return ""
        }
        $safeClaims = [ordered]@{
            audiences = (($claims.Audiences | ForEach-Object { [string]$_ }) -join ", ")
            appid = Get-ClaimValue -Name "appid"
            azp = $claims.Azp
            scp = Get-ClaimValue -Name "scp"
            roles = Get-ClaimValue -Name "roles"
            upn = Get-ClaimValue -Name "upn"
            preferred_username = Get-ClaimValue -Name "preferred_username"
            tid = Get-ClaimValue -Name "tid"
            issuer = $claims.Issuer
            validFrom = $claims.ValidFrom
            validTo = $claims.ValidTo
        }
        [pscustomobject]$safeClaims | Format-List | Out-Host
    }
    catch {
        Write-Host ("FAIL: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

$root = $RootUrl.TrimEnd("/")
$siteUrl = "$root/sites/GuidedAILabs"

Write-Host "Microsoft 365 Stage 6 - PnP token claims diagnostic (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Site: $siteUrl" -ForegroundColor Gray
Write-Host "Log:  $transcriptPath" -ForegroundColor Gray
Write-Host "This diagnostic prints decoded claims only, not bearer tokens." -ForegroundColor Yellow

Connect-Stage6PnP -SiteUrl $siteUrl
$connection = Get-PnPConnection
Write-Host ("ConnectionType: {0}" -f $connection.ConnectionType) -ForegroundColor Gray
if ($connection.PSObject.Properties.Name -contains "Url") {
    Write-Host ("ConnectedUrl:    {0}" -f $connection.Url) -ForegroundColor Gray
}

Show-TokenClaims -Label "SharePoint root token" -ResourceUrl $root
Show-TokenClaims -Label "SharePoint site token" -ResourceUrl $siteUrl
Show-TokenClaims -Label "Microsoft Graph token" -ResourceUrl "https://graph.microsoft.com"

Write-Host ""
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Stop-Transcript | Out-Null
if (-not $NoPause) {
    Write-Host "Done. Press Enter to close this window."
    Read-Host | Out-Null
}
