param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_WORKSPACE_SHAPE.json",
    [string]$OutputPath = ".\inventory\stage-8-client-workspace-reference\STAGE_8_LOCAL_PREFLIGHT.md"
)

# Stage 8 - local-only preflight.
# Validates the workspace shape config, local scripts, generated packet, and
# module availability. It does not connect to Microsoft 365 or perform tenant
# writes.

$ErrorActionPreference = "Stop"

function Resolve-WorkspacePath {
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
$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputPath = Resolve-WorkspacePath -Path $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]

if (Test-Path -LiteralPath $resolvedConfigPath) {
    try {
        $config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
        Add-Result -Results $results -Check "Workspace shape parses as JSON" -Passed $true -Detail $resolvedConfigPath
    }
    catch {
        Add-Result -Results $results -Check "Workspace shape parses as JSON" -Passed $false -Detail $_.Exception.Message
        $config = $null
    }
}
else {
    Add-Result -Results $results -Check "Workspace shape config exists" -Passed $false -Detail $resolvedConfigPath
    $config = $null
}

if ($null -ne $config) {
    Add-Result -Results $results -Check "Config is Stage 8" -Passed ($config.stage -eq 8) -Detail ("Stage: {0}" -f $config.stage)
    Add-Result -Results $results -Check "Config has target site URL" -Passed (-not [string]::IsNullOrWhiteSpace([string]$config.site.url)) -Detail ([string]$config.site.url)
    Add-Result -Results $results -Check "Config has pages" -Passed (@($config.pages).Count -gt 0) -Detail ("Pages: {0}" -f @($config.pages).Count)
    Add-Result -Results $results -Check "Config has navigation groups" -Passed (@($config.navigationGroups).Count -gt 0) -Detail ("Groups: {0}" -f @($config.navigationGroups).Count)
    Add-Result -Results $results -Check "Config has live change gates" -Passed (@($config.liveChangeGates).Count -gt 0) -Detail ("Gates: {0}" -f @($config.liveChangeGates).Count)
}

$requiredFiles = @(
    "M365_STAGE_8_CLIENT_WORKSPACE_REFERENCE_PATTERN.md",
    "M365_SHAREPOINT_WORKSPACE_SHAPE_PATTERN.md",
    "M365_STAGE_8_UAOS_GRAPHIFY_SHAREPOINT_ALIGNMENT.md",
    "config\M365_STAGE_8_WORKSPACE_SHAPE.json",
    "config\M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json",
    "config\M365_STAGE_8_HOMEPAGE_REFINEMENT.json",
    "scripts\New-M365Stage8WorkspaceShapePacket.ps1",
    "scripts\Invoke-M365Stage8WorkspaceShapeBuild.ps1",
    "scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyWorkspaceShape.ps1",
    "scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1",
    "scripts\New-M365Stage8WorkspaceBackingPacket.ps1",
    "scripts\Invoke-M365Stage8WorkspaceBackingBuild.ps1",
    "scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyWorkspaceBacking.ps1",
    "scripts\Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1",
    "scripts\New-M365Stage8HomepageRefinementPacket.ps1",
    "scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1",
    "scripts\Start-M365Stage8HomepageRefinementInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyHomepageRefinement.ps1",
    "scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1",
    "scripts\Test-M365Stage8LocalPreflight.ps1",
    "inventory\stage-8-client-workspace-reference\workspace-shape\STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md",
    "inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-page-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-navigation-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-next-list-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-shape\stage-8-library-role-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\STAGE_8_WORKSPACE_BACKING_VERIFY.md",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-page-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-list-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-library-map.csv",
    "inventory\stage-8-client-workspace-reference\workspace-backing-structure\stage-8-backing-navigation-map.csv",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-command-center-preview.html",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-command-cards.csv",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-active-work-snapshot.csv",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-homepage-client-pathway.csv",
    "inventory\stage-8-client-workspace-reference\homepage-refinement\stage-8-operational-readiness-dashboard-runway.csv"
)

foreach ($relativeFile in $requiredFiles) {
    $filePath = Join-Path $workspaceRoot $relativeFile
    Add-Result -Results $results -Check ("File exists: {0}" -f $relativeFile) -Passed (Test-Path -LiteralPath $filePath) -Detail $filePath
}

$requiredScripts = @(
    "scripts\New-M365Stage8WorkspaceShapePacket.ps1",
    "scripts\Invoke-M365Stage8WorkspaceShapeBuild.ps1",
    "scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyWorkspaceShape.ps1",
    "scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1",
    "scripts\New-M365Stage8WorkspaceBackingPacket.ps1",
    "scripts\Invoke-M365Stage8WorkspaceBackingBuild.ps1",
    "scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyWorkspaceBacking.ps1",
    "scripts\Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1",
    "scripts\New-M365Stage8HomepageRefinementPacket.ps1",
    "scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1",
    "scripts\Start-M365Stage8HomepageRefinementInteractive.ps1",
    "scripts\Invoke-M365Stage8VerifyHomepageRefinement.ps1",
    "scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1",
    "scripts\Test-M365Stage8LocalPreflight.ps1"
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

$pnp = Get-Module -ListAvailable -Name PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
Add-Result -Results $results -Check "PnP.PowerShell module available" -Passed ($null -ne $pnp) -Detail ($(if ($null -ne $pnp) { ("{0} {1}" -f $pnp.Name, $pnp.Version) } else { "required for live page/navigation build" }))

$pnpCommands = @("Add-PnPPage", "Add-PnPPageTextPart", "Add-PnPPageSection", "Set-PnPPage", "Get-PnPPage", "Get-PnPHomePage", "Add-PnPNavigationNode", "Get-PnPNavigationNode", "New-PnPList", "Get-PnPList", "Add-PnPField", "Add-PnPView", "Add-PnPFolder", "Get-PnPFolder")
foreach ($commandName in $pnpCommands) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    Add-Result -Results $results -Check ("PnP command available: {0}" -f $commandName) -Passed ($null -ne $command) -Detail ($(if ($null -ne $command) { $command.Source } else { "missing" }))
}

$failed = @($results | Where-Object { -not $_.Passed })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Local Preflight")
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
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $detail = ([string]$result.Detail) -replace "\|", "\|"
    $lines.Add(("| {0} | {1} | {2} |" -f $status, $result.Check, $detail))
}

$lines.Add("")
$lines.Add("Next safe actions:")
$lines.Add("")
$lines.Add('1. Run `.\scripts\New-M365Stage8WorkspaceShapePacket.ps1` to regenerate the local build packet after any config changes.')
$lines.Add('2. Run `.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1` for a dry-run of page/navigation creation.')
$lines.Add('3. Run `.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1 -Apply` only after approving live page/navigation changes; type `apply-stage-8-workspace-shape` in the visible window.')
$lines.Add('4. Run `.\scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1` for read-only page/navigation read-back after live apply.')
$lines.Add('5. Run `.\scripts\New-M365Stage8WorkspaceBackingPacket.ps1` to regenerate the backing-structure packet after config changes.')
$lines.Add('6. Run `.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1` for a dry-run of backing pages, Lists, libraries, folders, and navigation.')
$lines.Add('7. Run `.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1 -Apply` only after approving live backing-structure changes; type `apply-stage-8-backing-structure` in the visible window.')
$lines.Add('8. Run `.\scripts\Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1` for read-only backing-structure read-back after live apply.')
$lines.Add('9. Run `.\scripts\New-M365Stage8HomepageRefinementPacket.ps1` to regenerate the command-center homepage refinement packet.')
$lines.Add('10. Run `.\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1` for a local dry-run of the draft command-center page.')
$lines.Add('11. Run `.\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply` only after approving creation of the draft review page; type `create-stage-8-command-center-draft` in the visible window.')
$lines.Add('12. Run `.\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1` for read-only draft page verification after live apply.')
$lines.Add('13. Review the Guided AI Labs site in the browser before replacing the homepage, changing navigation, adding permissions, guests, external sharing, public Forms, or client-facing automation.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8

if ($failed.Count -eq 0) {
    Write-Host "Stage 8 local preflight PASS: $resolvedOutputPath" -ForegroundColor Green
}
else {
    Write-Host ("Stage 8 local preflight FAIL ({0} issue(s)): {1}" -f $failed.Count, $resolvedOutputPath) -ForegroundColor Red
    exit 1
}
