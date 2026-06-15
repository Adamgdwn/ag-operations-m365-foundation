param(
    [string]$InventoryRoot = ".\inventory\stage-7-security-governance",
    [string]$InventoryPath,
    [string]$OutputPath
)

# Stage 7 - local-only app grant resting-state plan.
# Reads saved Stage 7 inventory and writes a decision artifact. It does not
# connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-Stage7Path {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Read-Stage7Json {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    return ($raw | ConvertFrom-Json)
}

function Get-Stage7LatestInventoryPath {
    param([string]$Root)

    $resolvedRoot = Resolve-Stage7Path -Path $Root
    if (-not (Test-Path -LiteralPath $resolvedRoot)) {
        throw "Inventory root was not found: $resolvedRoot"
    }

    $candidate = Get-ChildItem -LiteralPath $resolvedRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "oauth2-permission-grants.json") } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if ($null -eq $candidate) {
        throw "No Stage 7 inventory folder with oauth2-permission-grants.json was found under $resolvedRoot"
    }

    return $candidate.FullName
}

function Get-Stage7DisplayName {
    param(
        [hashtable]$AppsByObjectId,
        [string]$ObjectId
    )

    if ($AppsByObjectId.ContainsKey($ObjectId)) {
        return $AppsByObjectId[$ObjectId]
    }

    return $ObjectId
}

function Get-Stage7GrantPosture {
    param(
        [string]$AppName,
        [string[]]$Scopes
    )

    $scopeText = ($Scopes -join " ")

    if ($AppName -eq "agent-pnp-provisioning") {
        return [pscustomobject]@{
            OwnerAction = "Keep active only while Stage 8 build automation is underway; then revoke delegated grants or disable the service principal."
            ProposedRestingState = "Time-boxed active setup helper"
            ReviewDate = "After Stage 8 page/navigation and client workspace pattern are built"
            AutomationStance = "No automatic revoke without Adam approval"
        }
    }

    if ($AppName -eq "Microsoft Graph Command Line Tools") {
        return [pscustomobject]@{
            OwnerAction = "Keep for supervised admin inventory/write windows; remove or reduce admin-write scopes when the setup phase closes."
            ProposedRestingState = "Supervised admin tool, not unattended automation"
            ReviewDate = "After Stage 7 closeout and before first client/partner onboarding"
            AutomationStance = "No automatic revoke without Adam approval"
        }
    }

    if ($AppName -eq "SharePoint Online Web Client Extensibility") {
        return [pscustomobject]@{
            OwnerAction = "Treat as Microsoft first-party; verify dependency before any revoke."
            ProposedRestingState = "Accepted pending dependency verification"
            ReviewDate = "Before changing SharePoint/Forms/Graph connector functionality"
            AutomationStance = "Do not revoke through this project without a separate Microsoft-first-party dependency review"
        }
    }

    if ($AppName -eq "Thunderbird") {
        return [pscustomobject]@{
            OwnerAction = "Confirm whether Thunderbird is still needed for a named mailbox workflow; otherwise retire legacy mail protocol access."
            ProposedRestingState = "Owner decision required"
            ReviewDate = "Before partner/client onboarding"
            AutomationStance = "No revoke until mailbox use is confirmed"
        }
    }

    if ($AppName -eq "Calendly") {
        return [pscustomobject]@{
            OwnerAction = "Accept if scheduling workflow is active; document owner and review cadence for calendar read/write access."
            ProposedRestingState = "Accepted if actively used"
            ReviewDate = "Quarterly or before changing scheduling workflow"
            AutomationStance = "No revoke unless scheduling workflow is retired"
        }
    }

    if ($scopeText -match "ReadWrite|FullControl|RoleManagement|Policy\.ReadWrite|SMTP|EWS|IMAP|POP|offline_access") {
        return [pscustomobject]@{
            OwnerAction = "Review business need and document owner before expanding partner/client access."
            ProposedRestingState = "Needs owner review"
            ReviewDate = "Before partner/client onboarding"
            AutomationStance = "No automatic revoke"
        }
    }

    return [pscustomobject]@{
        OwnerAction = "No immediate action from this Stage 7 closeout pass."
        ProposedRestingState = "Low concern in current inventory"
        ReviewDate = "Routine audit"
        AutomationStance = "No action"
    }
}

if ([string]::IsNullOrWhiteSpace($InventoryPath)) {
    $resolvedInventoryPath = Get-Stage7LatestInventoryPath -Root $InventoryRoot
}
else {
    $resolvedInventoryPath = Resolve-Stage7Path -Path $InventoryPath
}

if (-not (Test-Path -LiteralPath $resolvedInventoryPath)) {
    throw "Inventory path was not found: $resolvedInventoryPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutputPath = Join-Path $resolvedInventoryPath "stage-7-app-grant-resting-state-plan.md"
}
else {
    $resolvedOutputPath = Resolve-Stage7Path -Path $OutputPath
}

$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$apps = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "enterprise-applications.json"))
$grants = @(Read-Stage7Json -Path (Join-Path $resolvedInventoryPath "oauth2-permission-grants.json"))

$appsByObjectId = @{}
foreach ($app in $apps) {
    if ($null -ne $app.id -and -not $appsByObjectId.ContainsKey([string]$app.id)) {
        $appsByObjectId[[string]$app.id] = [string]$app.displayName
    }
}

$riskyScopePatterns = @(
    "AllSites.FullControl",
    "Sites.FullControl.All",
    "RoleManagement.ReadWrite.Directory",
    "Policy.ReadWrite.Authorization",
    "Directory.ReadWrite.All",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All",
    "Group.ReadWrite.All",
    "User.ReadWrite.All",
    "Files.ReadWrite.All",
    "Sites.ReadWrite.All",
    "TermStore.ReadWrite.All",
    "ExternalConnection.ReadWrite.All",
    "Calendars.ReadWrite",
    "Calendars.ReadWrite.Shared",
    "Tasks.ReadWrite",
    "Forms.ReadWrite",
    "SMTP.Send",
    "EWS.AccessAsUser.All",
    "IMAP.AccessAsUser.All",
    "POP.AccessAsUser.All",
    "offline_access"
)

$rows = New-Object System.Collections.Generic.List[object]
foreach ($grant in $grants) {
    $scopes = @(([string]$grant.scope) -split "\s+" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $matched = @($scopes | Where-Object { $riskyScopePatterns -contains $_ })
    if ($matched.Count -eq 0) {
        continue
    }

    $appName = Get-Stage7DisplayName -AppsByObjectId $appsByObjectId -ObjectId ([string]$grant.clientId)
    $resourceName = Get-Stage7DisplayName -AppsByObjectId $appsByObjectId -ObjectId ([string]$grant.resourceId)
    $posture = Get-Stage7GrantPosture -AppName $appName -Scopes $matched

    $rows.Add([pscustomobject]@{
        App = $appName
        Resource = $resourceName
        ConsentType = [string]$grant.consentType
        MatchedScopes = ($matched -join ", ")
        ProposedRestingState = $posture.ProposedRestingState
        OwnerAction = $posture.OwnerAction
        ReviewDate = $posture.ReviewDate
        AutomationStance = $posture.AutomationStance
    })
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 7 App Grant Resting-State Plan")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Inventory folder: `{0}`' -f $resolvedInventoryPath))
$lines.Add("")
$lines.Add("Scope: local-only plan from saved Stage 7 inventory. This file does not connect to Microsoft 365, revoke grants, disable apps, or change tenant policy.")
$lines.Add("")
$lines.Add("## Recommendation")
$lines.Add("")
$lines.Add("Keep broad setup/admin grants only while they are actively helping finish the governed build. Before partner/client onboarding, record which grants are still needed, which are accepted as product dependencies, and which should be retired.")
$lines.Add("")
$lines.Add("The practical near-term posture is:")
$lines.Add("")
$lines.Add('- `agent-pnp-provisioning`: time-boxed active setup helper while Stage 8 SharePoint build work is still active.')
$lines.Add('- `Microsoft Graph Command Line Tools`: supervised admin tool for inventory and explicit write windows only.')
$lines.Add("- Microsoft first-party SharePoint extensibility grants: review dependency before touching.")
$lines.Add("- Thunderbird / Calendly: keep only if there is a named mailbox or scheduling workflow.")
$lines.Add("")
$lines.Add("## Decision Table")
$lines.Add("")
if ($rows.Count -eq 0) {
    $lines.Add("No risky OAuth delegated grants were found in the saved inventory.")
}
else {
    $lines.Add("| App | Resource | Consent | Matched scopes | Proposed resting state | Owner action | Review date | Automation stance |")
    $lines.Add("|---|---|---|---|---|---|---|---|")
    foreach ($row in ($rows | Sort-Object App, Resource, ConsentType)) {
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |" -f $row.App, $row.Resource, $row.ConsentType, $row.MatchedScopes, $row.ProposedRestingState, $row.OwnerAction, $row.ReviewDate, $row.AutomationStance))
    }
}
$lines.Add("")
$lines.Add("## Stage 7 Closeout Decision")
$lines.Add("")
$lines.Add("Recommended decision record:")
$lines.Add("")
$lines.Add('```text')
$lines.Add("Broad setup/admin grants remain active only for supervised Stage 8 build work.")
$lines.Add("Before any partner or client guest onboarding, the grant table must be reviewed")
$lines.Add("again. Any grant without a named workflow owner, active dependency, or build")
$lines.Add("need should be revoked, reduced, or disabled through a separate approval-gated")
$lines.Add("operator.")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Explicit Non-Actions")
$lines.Add("")
$lines.Add("- Do not revoke Microsoft first-party SharePoint extensibility grants from this plan alone.")
$lines.Add("- Do not revoke Graph PowerShell scopes while an approved admin inventory/write window is in progress.")
$lines.Add('- Do not leave `agent-pnp-provisioning` broad setup scopes unreviewed after Stage 8.')
$lines.Add("- Do not create a future UAOS/M365 production bridge by reusing the setup helper app.")
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

Write-Host "Stage 7 app grant resting-state plan written:" -ForegroundColor Green
Write-Host $resolvedOutputPath -ForegroundColor Gray
