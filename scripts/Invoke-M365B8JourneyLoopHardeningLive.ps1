param(
    [switch]$Apply,
    [string]$ApprovalCapturePath = "",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# B8b live schema hardening for the M365 Interaction Agent Journey loop.
# Adds only the approved first-class Journey correlation fields to
# "CRM - New Signals" and records read-back evidence. Flow updates and replay
# proof are handled by the flow-builder scripts after this schema step passes.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot
$configPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B8_JOURNEY_LOOP_HARDENING.json"
$approvalDir = Join-Path $workspaceRoot ".local\interaction-agent-approvals"
$outDir = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b8"
$siteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs"
$listTitle = "CRM - New Signals"

function Resolve-LatestApprovalCapture {
    if (-not [string]::IsNullOrWhiteSpace($ApprovalCapturePath)) {
        if ([System.IO.Path]::IsPathRooted($ApprovalCapturePath)) { return $ApprovalCapturePath }
        return (Join-Path $workspaceRoot $ApprovalCapturePath)
    }

    $latest = Get-ChildItem -LiteralPath $approvalDir -Filter "b8b-approval-*.json" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($null -eq $latest) { return "" }
    return $latest.FullName
}

function Test-JsonProperty {
    param([object]$Object, [string]$Name)
    return ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name)
}

function ConvertTo-MarkdownValue {
    param([object]$Value)
    return ([string]$Value).Replace("|", "\|").Replace("`r", " ").Replace("`n", " ")
}

function ConvertTo-WorkspaceRelativePath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetFullPath($workspaceRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    if ($fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($root.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar).Replace("\", "/")
    }

    return $Path
}

if (-not (Test-Path -LiteralPath $configPath)) { throw "B8 config not found: $configPath" }
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$approvalPath = Resolve-LatestApprovalCapture

if ([string]::IsNullOrWhiteSpace($approvalPath) -or -not (Test-Path -LiteralPath $approvalPath)) {
    throw "B8b approval capture not found. Run scripts\Start-M365InteractionAgentApprovalWindow.ps1 -Chunk B8b first."
}

$approval = Get-Content -LiteralPath $approvalPath -Raw | ConvertFrom-Json
$requiredPhrase = [string]$config.liveApprovalRequired.approvalPhrase
if (-not [bool]$approval.approved -or [string]$approval.approvalPhraseRequired -ne $requiredPhrase) {
    throw "B8b approval capture exists but is not approved for the current B8 phrase."
}

$fields = @($config.recommendedDefault.sharePointFields | ForEach-Object {
    [pscustomobject]@{
        DisplayName = [string]$_.displayName
        InternalName = [string]$_.internalName
        Type = [string]$_.type
        Required = [bool]$_.required
        Indexed = [bool]$_.indexed
        Purpose = [string]$_.purpose
    }
})

New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$planPath = Join-Path $outDir ("b8-schema-plan-{0}.md" -f $timestamp)
$proofPath = Join-Path $outDir ("b8-schema-proof-{0}.md" -f $timestamp)
$proofJsonPath = Join-Path $outDir ("b8-schema-proof-{0}.json" -f $timestamp)
$transcriptPath = Join-Path $outDir ("b8-schema-proof-{0}.log" -f $timestamp)

$planLines = New-Object System.Collections.Generic.List[string]
$planLines.Add("# B8b Schema Plan")
$planLines.Add("")
$planLines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$planLines.Add(("Mode: {0}" -f $(if ($Apply) { "APPLY" } else { "DRY RUN" })))
$planLines.Add(("Approval capture: {0}" -f (ConvertTo-WorkspaceRelativePath $approvalPath)))
$planLines.Add("")
$planLines.Add("| Field | Internal name | Type | Indexed | Purpose |")
$planLines.Add("|---|---|---|---|---|")
foreach ($field in $fields) {
    $planLines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f
        (ConvertTo-MarkdownValue $field.DisplayName),
        (ConvertTo-MarkdownValue $field.InternalName),
        (ConvertTo-MarkdownValue $field.Type),
        (ConvertTo-MarkdownValue $field.Indexed),
        (ConvertTo-MarkdownValue $field.Purpose)))
}
$planLines.Add("")
$planLines.Add("Safety: additive fields only; no delete, merge, permission, sharing, external message, QUO, or R4 work.")
Set-Content -LiteralPath $planPath -Value $planLines -Encoding UTF8

Write-Host "B8b Journey loop schema hardening" -ForegroundColor Cyan
Write-Host ("Mode: {0}" -f $(if ($Apply) { "APPLY" } else { "DRY RUN" })) -ForegroundColor $(if ($Apply) { "Yellow" } else { "Green" })
Write-Host ("Plan: {0}" -f $planPath) -ForegroundColor Gray

if (-not $Apply) {
    Write-Host "Dry run only. No tenant connection, no changes." -ForegroundColor Green
    if (-not $NoPause) { Read-Host "Press Enter to close" | Out-Null }
    exit 0
}

try { Start-Transcript -Path $transcriptPath -Force | Out-Null } catch {}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available. Install/import it or run from the established M365 shell."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{ Url = $siteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
Connect-PnPOnline @connectParams

$results = New-Object System.Collections.Generic.List[object]
foreach ($field in $fields) {
    $existing = Get-PnPField -List $listTitle -Identity $field.InternalName -Includes InternalName,Title,TypeAsString,Indexed,Hidden,Required -ErrorAction SilentlyContinue
    $action = "exists"
    if ($null -eq $existing) {
        Add-PnPField -List $listTitle -DisplayName $field.DisplayName -InternalName $field.InternalName -Type Text -AddToDefaultView:$false | Out-Null
        $action = "created"
        $existing = Get-PnPField -List $listTitle -Identity $field.InternalName -Includes InternalName,Title,TypeAsString,Indexed,Hidden,Required -ErrorAction Stop
    }

    if ($field.Indexed -and -not [bool]$existing.Indexed) {
        try {
            Set-PnPField -List $listTitle -Identity $field.InternalName -Values @{ Indexed = $true } | Out-Null
            $action = if ($action -eq "created") { "created-indexed" } else { "indexed" }
        }
        catch {
            $action = "$action-index-warn"
            Write-Host ("[warn] Could not index {0}: {1}" -f $field.InternalName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    $readBack = Get-PnPField -List $listTitle -Identity $field.InternalName -Includes InternalName,Title,TypeAsString,Indexed,Hidden,Required -ErrorAction Stop
    $results.Add([pscustomobject]@{
        displayName = [string]$readBack.Title
        internalName = [string]$readBack.InternalName
        type = [string]$readBack.TypeAsString
        indexed = [bool]$readBack.Indexed
        hidden = [bool]$readBack.Hidden
        required = [bool]$readBack.Required
        action = $action
    })
    Write-Host ("[{0}] {1} indexed={2}" -f $action, $field.InternalName, [bool]$readBack.Indexed) -ForegroundColor Green
}

$resultRows = @($results.ToArray())
$stopConditionRows = @($approval.stopConditions | ForEach-Object { [string]$_ })

try { Disconnect-PnPOnline | Out-Null } catch {}

$proof = [pscustomobject][ordered]@{
    generatedAt = (Get-Date).ToString("o")
    chunk = "B8b"
    site = $siteUrl
    listTitle = $listTitle
    approvalCapture = (ConvertTo-WorkspaceRelativePath $approvalPath)
    approvalCapturedAt = [string]$approval.capturedAt
    mode = "apply"
    fields = $resultRows
    stopConditionsObserved = $stopConditionRows
    transcript = (ConvertTo-WorkspaceRelativePath $transcriptPath)
}
$proof | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $proofJsonPath -Encoding UTF8

$proofLines = New-Object System.Collections.Generic.List[string]
$proofLines.Add("# B8b Schema Proof")
$proofLines.Add("")
$proofLines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$proofLines.Add("")
$proofLines.Add("Status: schema step applied/read-back. Flow update and replay proof are separate B8b evidence.")
$proofLines.Add("")
$proofLines.Add(("Site: {0}" -f $siteUrl))
$proofLines.Add(("List: {0}" -f $listTitle))
$proofLines.Add(("Approval capture: {0}" -f (ConvertTo-WorkspaceRelativePath $approvalPath)))
$proofLines.Add(("Transcript: {0}" -f (ConvertTo-WorkspaceRelativePath $transcriptPath)))
$proofLines.Add("")
$proofLines.Add("| Field | Internal name | Type | Indexed | Hidden | Required | Action |")
$proofLines.Add("|---|---|---|---|---|---|---|")
foreach ($result in $resultRows) {
    $proofLines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f
        (ConvertTo-MarkdownValue $result.displayName),
        (ConvertTo-MarkdownValue $result.internalName),
        (ConvertTo-MarkdownValue $result.type),
        (ConvertTo-MarkdownValue $result.indexed),
        (ConvertTo-MarkdownValue $result.hidden),
        (ConvertTo-MarkdownValue $result.required),
        (ConvertTo-MarkdownValue $result.action)))
}
$proofLines.Add("")
$proofLines.Add("Boundary: additive schema only; no delete, merge, permission, sharing, external message, QUO, or R4 work.")
Set-Content -LiteralPath $proofPath -Value $proofLines -Encoding UTF8

try { Stop-Transcript | Out-Null } catch {}

Write-Host ("B8b schema proof: {0}" -f $proofPath) -ForegroundColor Green

if (-not $NoPause) {
    Read-Host "Press Enter to close" | Out-Null
}
