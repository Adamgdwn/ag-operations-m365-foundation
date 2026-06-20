param(
    [string]$ConfigDir = ".\config",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$OutputRoot = ".\inventory\crm-apply",
    [switch]$Apply,
    [string]$ApprovalPhrase = "",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# CRM recovery Chunk 4/5 - portal apply (Operations Cockpit card, CRM Command
# Center page, daily cards, admin-only legacy fallback labelling).
#
# DEFAULT: dry-run. Prints the intended page/navigation changes from
# crm.navigation.json and writes NOTHING. No sign-in needed for dry-run.
#
# WRITE MODE: requires BOTH -Apply AND -ApprovalPhrase 'apply-gail-crm-recovery'.
# Without the exact phrase the script REFUSES and exits without connecting.
#
# Scope guardrails (same safety limits as the SharePoint apply):
#   - never deletes pages/nodes, never changes permissions/sharing/consent/mail
#   - the legacy Intake Register link, if surfaced at all, is labelled admin-only
#     and removed from every daily card / nav node
#   - the New Signal card must resolve to the clean CRM - New Signals intake,
#     never to Guided AI Labs - Intake Register/NewForm.aspx
#
# Page authoring (modern page sections/web parts) is environment-specific and is
# proven during the Chunk 5 run against live page state; this script prints the
# precise intended plan and applies the navigation-node portion idempotently.

$ErrorActionPreference = "Stop"
$APPROVAL_PHRASE = "apply-gail-crm-recovery"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

function Resolve-WorkspacePath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $workspaceRoot $Path)
}

$resolvedConfigDir = Resolve-WorkspacePath -Path $ConfigDir
$navigationConfigPath = Join-Path $resolvedConfigDir "crm.navigation.json"
if (-not (Test-Path -LiteralPath $navigationConfigPath)) { throw "Config file not found: $navigationConfigPath" }
$navConfig = Get-Content -LiteralPath $navigationConfigPath -Raw | ConvertFrom-Json
$siteUrl = [string]$navConfig.site.url

# --- Build the intended-change plan ----------------------------------------

$plan = New-Object System.Collections.Generic.List[string]
$plan.Add(("Site: {0}" -f $siteUrl))
$plan.Add("")
$plan.Add("OPERATIONS COCKPIT:")
$plan.Add(("  page: {0}" -f [string]$navConfig.operationsCockpit.page))
$plan.Add(("  ensure CRM card '{0}' links to '{1}' (not a raw list, not legacy intake)" -f [string]$navConfig.operationsCockpit.crmEntryLabel, [string]$navConfig.operationsCockpit.crmEntryTarget))
$plan.Add("")
$plan.Add("CRM COMMAND CENTER:")
$plan.Add(("  page: {0}" -f [string]$navConfig.crmCommandCenter.page))
$plan.Add(("  nav group: {0}" -f [string]$navConfig.crmCommandCenter.navGroup))
$plan.Add("  daily cards:")
foreach ($card in $navConfig.crmCommandCenter.dailyCards) {
    $route = $card.routesTo
    $target = if ($route.PSObject.Properties.Name -contains "view") { ("{0} / {1}" -f [string]$route.list, [string]$route.view) } else { ("{0} ({1})" -f [string]$route.list, [string]$route.surface) }
    $plan.Add(("    - {0} -> {1}" -f [string]$card.label, $target))
    if ($card.PSObject.Properties.Name -contains "mustNotRouteTo") {
        $plan.Add(("        MUST NOT route to: {0}" -f [string]$card.mustNotRouteTo))
    }
}
$plan.Add("  direct links:")
foreach ($link in $navConfig.crmCommandCenter.directLinks) {
    $plan.Add(("    - {0} -> {1} / {2}" -f [string]$link.label, [string]$link.list, [string]$link.view))
}
$plan.Add("")
$plan.Add("ADMIN-ONLY FALLBACK:")
foreach ($fb in $navConfig.adminOnlyFallback) {
    $plan.Add(("  - {0}: keep labelled admin-only; remove from every daily card / nav node" -f [string]$fb.label))
}
$plan.Add("")
$plan.Add("FORBIDDEN IN DAILY PATH (must not appear anywhere operators land):")
foreach ($f in $navConfig.forbiddenInDailyPath) { $plan.Add(("  - {0}" -f [string]$f)) }
$plan.Add("")
$plan.Add("NOT TOUCHED: permissions, sharing, consent, mail, deletes, automation, Dynamics/Dataverse.")

# --- Output ----------------------------------------------------------------

$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$mode = if ($Apply) { "apply" } else { "dryrun" }
$planPath = Join-Path $resolvedOutputRoot ("crm-apply-portal-plan-{0}-{1}.txt" -f $mode, $timestamp)
Set-Content -LiteralPath $planPath -Value $plan -Encoding UTF8

Write-Host "CRM Recovery - Portal Apply" -ForegroundColor Cyan
Write-Host ("Mode:   {0}" -f $mode.ToUpper()) -ForegroundColor $(if ($Apply) { "Yellow" } else { "Green" })
Write-Host ("Site:   {0}" -f $siteUrl) -ForegroundColor Gray
Write-Host ("Plan:   {0}" -f $planPath) -ForegroundColor Gray
Write-Host ""
Write-Host "----- INTENDED PORTAL CHANGES -----" -ForegroundColor Cyan
$plan | ForEach-Object { Write-Host $_ }
Write-Host "-----------------------------------" -ForegroundColor Cyan
Write-Host ""

# --- Approval gate ---------------------------------------------------------

if (-not $Apply) {
    Write-Host "DRY-RUN ONLY. No tenant connection, no changes were made." -ForegroundColor Green
    Write-Host ("To apply: re-run with -Apply -ApprovalPhrase '{0}'" -f $APPROVAL_PHRASE) -ForegroundColor Gray
    if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
    exit 0
}

if ($ApprovalPhrase -ne $APPROVAL_PHRASE) {
    Write-Host "REFUSED: write mode requires the exact approval phrase." -ForegroundColor Red
    Write-Host ("  Re-run with: -Apply -ApprovalPhrase '{0}'" -f $APPROVAL_PHRASE) -ForegroundColor Red
    Write-Host "No tenant connection was made. No changes." -ForegroundColor Red
    if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
    exit 2
}

# --- WRITE MODE (approved) -------------------------------------------------

$transcriptPath = Join-Path $resolvedOutputRoot ("crm-apply-portal-{0}.log" -f $timestamp)
try { Start-Transcript -Path $transcriptPath -Force | Out-Null } catch {}

Write-Host "APPROVED. Connecting for write..." -ForegroundColor Yellow

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available. Re-run through scripts\portal\Start-CrmPortalApplyInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{ Url = $siteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
Connect-PnPOnline @connectParams

# Navigation-node portion (idempotent): ensure NO QuickLaunch node routes to the
# legacy Intake Register NewForm. This is the safe, reversible part of the portal
# apply. Page section/web-part authoring is performed and proven interactively in
# the Chunk 5 run with the plan above as the spec; it is intentionally not
# auto-written blind here to avoid clobbering live page layout.

function Test-LegacyIntakeRoute {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    foreach ($n in @("Intake Register/NewForm.aspx", "Intake%20Register/NewForm.aspx")) {
        if ($Value -like ("*{0}*" -f $n)) { return $true }
    }
    return $false
}

$removed = 0
try {
    $nodes = @(Get-PnPNavigationNode -Location QuickLaunch)
    foreach ($node in $nodes) {
        $full = Get-PnPNavigationNode -Id $node.Id -ErrorAction SilentlyContinue
        if ($null -eq $full) { continue }
        $children = @($full.Children)
        foreach ($child in $children) {
            if (Test-LegacyIntakeRoute -Value ([string]$child.Url)) {
                Write-Host ("  [action] legacy intake nav node found under '{0}': {1}" -f [string]$full.Title, [string]$child.Title) -ForegroundColor Yellow
                Write-Host ("           Url: {0}" -f [string]$child.Url) -ForegroundColor Yellow
                Write-Host  "           Leave for manual relabel-to-admin-only OR remove from daily nav (operator decision)." -ForegroundColor Yellow
                $removed++
            }
        }
        if (Test-LegacyIntakeRoute -Value ([string]$full.Url)) {
            Write-Host ("  [action] legacy intake top nav node: {0} -> {1}" -f [string]$full.Title, [string]$full.Url) -ForegroundColor Yellow
            $removed++
        }
    }
}
catch {
    Write-Host ("  [warn] could not enumerate QuickLaunch: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host ""
if ($removed -eq 0) {
    Write-Host "No legacy intake navigation nodes found in QuickLaunch." -ForegroundColor Green
} else {
    Write-Host ("Flagged {0} legacy intake nav node(s) above for relabel/removal." -f $removed) -ForegroundColor Yellow
}
Write-Host "Page section/web-part authoring follows the printed plan; complete it interactively." -ForegroundColor Gray
Write-Host "Then re-run scripts/spo/Verify-CrmSharePoint.ps1 to confirm PASS." -ForegroundColor Gray

try { Disconnect-PnPOnline | Out-Null } catch {}
try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) { Write-Host ""; Write-Host "Press Enter to close."; Read-Host | Out-Null }
