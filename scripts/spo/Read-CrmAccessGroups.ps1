param(
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\crm-access",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# CRM recovery V6 - read-only access-group read-back.
#
# The CRM Onboarding Package records the role->level decision (A2 employee /
# A3 trusted partner) but deliberately does NOT guess live group names. Before
# granting anyone CRM access we read back the LIVE SharePoint / Microsoft 365
# groups and permission levels. This script never creates, updates, deletes,
# invites, shares, consents, or sends mail. It only reads.
#
# Run it in the same signed-in session as the V1 baseline export (the token is
# usually still cached, so no second sign-in). Output lands in
# inventory/crm-access/CRM_ACCESS_GROUPS.md for pasting into
# docs/CRM_ONBOARDING_PACKAGE.md "Exact access-group notes".

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function Resolve-WorkspacePath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

$outputDir = Resolve-WorkspacePath $OutputRoot
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}
$outputFile = Join-Path $outputDir "CRM_ACCESS_GROUPS.md"

Write-Host "CRM access-group read-back (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Site:   $SiteUrl" -ForegroundColor Gray
Write-Host "Output: $outputFile" -ForegroundColor Gray

if (-not (Get-Module -ListAvailable -Name "PnP.PowerShell")) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through a host that has the PnP module (the same one used for the V1 baseline export)."
}

$connectParams = @{
    Url         = $SiteUrl
    ClientId    = $ClientId
    Interactive = $true
}
if ($ForceFreshLogin) { $connectParams["ForceAuthentication"] = $true }

Connect-PnPOnline @connectParams

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# CRM Access Groups - live read-back (V6)")
$lines.Add("")
$lines.Add("Read-only capture. Source of truth for onboarding grants. No writes occurred.")
$lines.Add("")
$lines.Add(("Site: {0}" -f $SiteUrl))
$lines.Add("")

# --- SharePoint site groups + members ---------------------------------------
$lines.Add("## SharePoint site groups")
$lines.Add("")
try {
    $groups = Get-PnPGroup -ErrorAction Stop
    foreach ($g in ($groups | Sort-Object Title)) {
        $lines.Add(("### {0}" -f $g.Title))
        $lines.Add(("- Id: {0}" -f $g.Id))
        $lines.Add(("- OwnerTitle: {0}" -f $g.OwnerTitle))
        try {
            $members = Get-PnPGroupMember -Group $g.Title -ErrorAction Stop
            if ($null -eq $members -or $members.Count -eq 0) {
                $lines.Add("- Members: (none)")
            } else {
                $lines.Add("- Members:")
                foreach ($m in $members) {
                    $lines.Add(("    - {0}  <{1}>  [{2}]" -f $m.Title, $m.Email, $m.LoginName))
                }
            }
        } catch {
            $lines.Add(("- Members: (could not read: {0})" -f $_.Exception.Message))
        }
        $lines.Add("")
    }
} catch {
    $lines.Add(("(Could not enumerate site groups: {0})" -f $_.Exception.Message))
    $lines.Add("")
}

# --- Permission levels (role definitions) -----------------------------------
$lines.Add("## Permission levels (role definitions)")
$lines.Add("")
try {
    $roleDefs = Get-PnPRoleDefinition -ErrorAction Stop
    foreach ($r in ($roleDefs | Sort-Object Name)) {
        $lines.Add(("- {0}  (Id {1})" -f $r.Name, $r.Id))
    }
} catch {
    $lines.Add(("(Could not read role definitions: {0})" -f $_.Exception.Message))
}
$lines.Add("")

# --- Site collection administrators -----------------------------------------
$lines.Add("## Site collection administrators")
$lines.Add("")
try {
    $admins = Get-PnPSiteCollectionAdmin -ErrorAction Stop
    foreach ($a in $admins) {
        $lines.Add(("- {0}  <{1}>  [{2}]" -f $a.Title, $a.Email, $a.LoginName))
    }
} catch {
    $lines.Add(("(Could not read site collection admins: {0})" -f $_.Exception.Message))
}
$lines.Add("")

# --- Microsoft 365 group behind the site (best effort) ----------------------
$lines.Add("## Microsoft 365 group association (best effort)")
$lines.Add("")
try {
    $web = Get-PnPWeb -Includes Title,Url -ErrorAction Stop
    $lines.Add(("- Web title: {0}" -f $web.Title))
    $lines.Add(("- Web url: {0}" -f $web.Url))
    $lines.Add("- Note: confirm the exact M365 group (e.g. GuidedAILabs@agoperations.ca)")
    $lines.Add("  in the M365 admin / Entra portal; PnP site-group names above are the")
    $lines.Add("  SharePoint permission groups used for A2/A3 grants.")
} catch {
    $lines.Add(("(Could not read web: {0})" -f $_.Exception.Message))
}
$lines.Add("")

Set-Content -LiteralPath $outputFile -Value ($lines -join "`r`n") -Encoding UTF8
Write-Host "Wrote: $outputFile" -ForegroundColor Green

try { Disconnect-PnPOnline | Out-Null } catch {}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Done (read-only). Press Enter to close." -ForegroundColor Cyan
    [void](Read-Host)
}
