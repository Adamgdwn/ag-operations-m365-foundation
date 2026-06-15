param(
    [string]$BaselinePath = ".\config\M365_STAGE_7_GOVERNANCE_BASELINE.json",
    [string]$OutputPath = ".\inventory\stage-7-security-governance\STAGE_7_LOCAL_PREFLIGHT.md"
)

# Stage 7 - local-only preflight.
# Validates local docs, baseline config, script parsing, and optional module
# availability. It does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

function Resolve-Stage7Path {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Results,
        [string]$Check,
        [bool]$Passed,
        [string]$Detail
    )

    $Results.Add([pscustomobject]@{
        Check = $Check
        Passed = $Passed
        Detail = $Detail
    })
}

function Test-ScriptParse {
    param([string]$Path)

    $parseErrors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw -LiteralPath $Path), [ref]$parseErrors)
    return @($parseErrors)
}

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$resolvedBaselinePath = Resolve-Stage7Path -Path $BaselinePath
$resolvedOutputPath = Resolve-Stage7Path -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

if (Test-Path -LiteralPath $resolvedBaselinePath) {
    try {
        $baseline = Get-Content -LiteralPath $resolvedBaselinePath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Baseline parses as JSON" -Passed $true -Detail $resolvedBaselinePath
    }
    catch {
        Add-Result -Results $results -Check "Baseline parses as JSON" -Passed $false -Detail $_.Exception.Message
        $baseline = $null
    }
}
else {
    Add-Result -Results $results -Check "Baseline exists" -Passed $false -Detail $resolvedBaselinePath
    $baseline = $null
}

if ($null -ne $baseline) {
    Add-Result -Results $results -Check "Baseline is Stage 7" -Passed ($baseline.stage -eq 7) -Detail ("Stage: {0}" -f $baseline.stage)
    Add-Result -Results $results -Check "Baseline has governance areas" -Passed ($baseline.baseline.Count -ge 8) -Detail ("Areas: {0}" -f $baseline.baseline.Count)
    Add-Result -Results $results -Check "Baseline has exit criteria" -Passed ($baseline.stageExitCriteria.Count -gt 0) -Detail ("Criteria: {0}" -f $baseline.stageExitCriteria.Count)
    Add-Result -Results $results -Check "Baseline has read-only scopes" -Passed ($baseline.readOnlyInventory.graphScopes.Count -gt 0) -Detail (($baseline.readOnlyInventory.graphScopes | ForEach-Object { [string]$_ }) -join ", ")
}

$requiredFiles = @(
    "M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md",
    "config\M365_STAGE_7_GOVERNANCE_BASELINE.json",
    "scripts\Invoke-M365Stage7SecurityInventory.ps1",
    "scripts\Start-M365Stage7SecurityInventoryInteractive.ps1",
    "scripts\Invoke-M365Stage7SharePointSharingInventory.ps1",
    "scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1",
    "scripts\Invoke-M365Stage7GovernanceWriteWindow.ps1",
    "scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1",
    "scripts\Invoke-M365Stage7RecordGovernanceDecision.ps1",
    "scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1",
    "scripts\Invoke-M365Stage7GovernanceReviewPack.ps1",
    "scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1",
    "scripts\Invoke-M365Stage7SiteSharingExceptionWindow.ps1",
    "scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1",
    "scripts\Summarize-M365Stage7SecurityInventory.ps1",
    "scripts\Test-M365Stage7LocalPreflight.ps1",
    "inventory\stage-7-security-governance\STAGE_7_CLOSEOUT_ACTION_PLAN.md"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\Invoke-M365Stage7SecurityInventory.ps1",
    "scripts\Start-M365Stage7SecurityInventoryInteractive.ps1",
    "scripts\Invoke-M365Stage7SharePointSharingInventory.ps1",
    "scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1",
    "scripts\Invoke-M365Stage7GovernanceWriteWindow.ps1",
    "scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1",
    "scripts\Invoke-M365Stage7RecordGovernanceDecision.ps1",
    "scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1",
    "scripts\Invoke-M365Stage7GovernanceReviewPack.ps1",
    "scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1",
    "scripts\Invoke-M365Stage7SiteSharingExceptionWindow.ps1",
    "scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1",
    "scripts\Summarize-M365Stage7SecurityInventory.ps1",
    "scripts\Test-M365Stage7LocalPreflight.ps1"
)

foreach ($relativeScript in $requiredScripts) {
    $scriptPath = Join-Path $workspaceRoot $relativeScript
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed $false -Detail "missing"
        continue
    }

    $errors = Test-ScriptParse -Path $scriptPath
    Add-Result -Results $results -Check ("Script parses: {0}" -f $relativeScript) -Passed ($errors.Count -eq 0) -Detail ($(if ($errors.Count -eq 0) { "parse-ok" } else { ($errors | ForEach-Object { $_.Message }) -join "; " }))
}

$pwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
Add-Result -Results $results -Check "PowerShell 7 host available" -Passed ($null -ne $pwsh) -Detail ($(if ($null -ne $pwsh) { $pwsh.Source } else { "pwsh.exe not found" }))

$graphAuth = Get-Module -ListAvailable -Name Microsoft.Graph.Authentication | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "Microsoft.Graph.Authentication module available" -Passed ($null -ne $graphAuth) -Detail ($(if ($null -ne $graphAuth) { ("{0} {1}" -f $graphAuth.Name, $graphAuth.Version) } else { "required module not found" }))

$graphSignIns = Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "Microsoft.Graph.Identity.SignIns module available" -Passed ($null -ne $graphSignIns) -Detail ($(if ($null -ne $graphSignIns) { ("{0} {1}" -f $graphSignIns.Name, $graphSignIns.Version) } else { "optional module not found" }))

$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "PnP.PowerShell module available" -Passed ($null -ne $pnp) -Detail ($(if ($null -ne $pnp) { ("{0} {1}" -f $pnp.Name, $pnp.Version) } else { "required for focused SharePoint sharing read-back" }))

$spo = Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "SharePoint Online Management Shell module available" -Passed ($null -ne $spo) -Detail ($(if ($null -ne $spo) { ("{0} {1}" -f $spo.Name, $spo.Version) } else { "optional module not found; -IncludeSharePointAdmin will skip/fail gracefully" }))

$failed = @($results | Where-Object { -not $_.Passed -and $_.Check -notlike "SharePoint Online Management Shell module available" })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 7 Local Preflight")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add("")
$lines.Add("Scope: local-only validation. This preflight does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add(("Result: {0}" -f ($(if ($failed.Count -eq 0) { "PASS" } else { "FAIL" }))))
$lines.Add("")
$lines.Add("| Status | Check | Detail |")
$lines.Add("|---|---|---|")

foreach ($result in $results) {
    $status = if ($result.Passed) { "PASS" } else { "WARN" }
    if (-not $result.Passed -and $result.Check -notlike "SharePoint Online Management Shell module available") {
        $status = "FAIL"
    }
    $detail = ([string]$result.Detail) -replace "\|", "\|"
    $lines.Add(("| {0} | {1} | {2} |" -f $status, $result.Check, $detail))
}

$lines.Add("")
$lines.Add("Next safe actions:")
$lines.Add("")
$lines.Add('1. Run `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1` for read-only Graph inventory through browser/WAM auth when Adam is ready to sign in.')
$lines.Add('2. If browser/WAM auth fails, run `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -UseDeviceCode` as the fallback.')
$lines.Add('3. Run `.\scripts\Start-M365Stage7SharePointSharingInventoryInteractive.ps1` for focused read-only SharePoint tenant/site sharing inventory.')
$lines.Add('4. Run `.\scripts\Start-M365Stage7GovernanceWriteWindowInteractive.ps1` for a dry-run of the approval-gated governance write batch.')
$lines.Add('5. Run `.\scripts\Start-M365Stage7RecordGovernanceDecisionInteractive.ps1 -Apply` to record the approved Stage 7 governance decision in the Decision Register and Agent Action Log.')
$lines.Add('6. Run `.\scripts\Invoke-M365Stage7GovernanceReviewPack.ps1` to generate the local-only app grant, MFA, and site sharing exception review pack.')
$lines.Add('7. Run `.\scripts\Invoke-M365Stage7AppGrantRestingStatePlan.ps1` to generate the local-only broad app grant resting-state plan.')
$lines.Add('8. Run `.\scripts\Start-M365Stage7SiteSharingExceptionWindowInteractive.ps1` for a dry-run of the root/legacy site sharing cleanup batch.')
$lines.Add('9. Run `.\scripts\Start-M365Stage7SecurityInventoryInteractive.ps1 -IncludeSharePointAdmin` only if the legacy SharePoint Online module is installed and a second admin prompt is acceptable.')
$lines.Add('10. Summarize a completed inventory with `.\scripts\Summarize-M365Stage7SecurityInventory.ps1`.')
$lines.Add('11. Use `M365_STAGE_7_SECURITY_GOVERNANCE_EXTERNAL_SHARING.md` to record the Security Defaults / Conditional Access and external sharing decisions.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 7 local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 7 local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
