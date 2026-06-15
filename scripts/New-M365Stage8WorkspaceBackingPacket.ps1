param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_WORKSPACE_BACKING_STRUCTURE.json",
    [string]$OutputRoot = ".\inventory\stage-8-client-workspace-reference\workspace-backing-structure"
)

# Stage 8 - local-only workspace backing structure packet generator.
# Reads the backing-structure config and writes a build guide plus CSV maps. It
# does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8_WORKSPACE_BACKING_BUILD_GUIDE.md"
$pageCsvPath = Join-Path $resolvedOutputRoot "stage-8-backing-page-map.csv"
$listCsvPath = Join-Path $resolvedOutputRoot "stage-8-backing-list-map.csv"
$libraryCsvPath = Join-Path $resolvedOutputRoot "stage-8-backing-library-map.csv"
$navCsvPath = Join-Path $resolvedOutputRoot "stage-8-backing-navigation-map.csv"

$config.pages | Select-Object title,fileName,navGroup,role |
    Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8

$listRows = foreach ($list in $config.lists) {
    [pscustomobject]@{
        Title = $list.title
        Description = $list.description
        Columns = (($list.columns | ForEach-Object { [string]$_.displayName }) -join "; ")
        Views = (($list.views | ForEach-Object { [string]$_.title }) -join "; ")
    }
}
$listRows | Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8

$libraryRows = foreach ($library in $config.libraries) {
    [pscustomobject]@{
        Title = $library.title
        Description = $library.description
        Folders = (($library.folders | ForEach-Object { [string]$_ }) -join "; ")
    }
}
$libraryRows | Export-Csv -LiteralPath $libraryCsvPath -NoTypeInformation -Encoding UTF8

$config.navigationTargets | Select-Object group,link,kind,target |
    Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Workspace Backing Structure Build Guide")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Config: `{0}`' -f $resolvedConfigPath))
$lines.Add("")
$lines.Add("Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add("## Site")
$lines.Add("")
$lines.Add("| Field | Value |")
$lines.Add("|---|---|")
$lines.Add(("| Title | {0} |" -f $config.site.title))
$lines.Add(("| URL | {0} |" -f $config.site.url))
$lines.Add(("| Purpose | {0} |" -f $config.site.purpose))
$lines.Add("")
$lines.Add("## Live Apply")
$lines.Add("")
$lines.Add("Dry-run in a visible window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1')
$lines.Add('```')
$lines.Add("")
$lines.Add("Apply after approval in the visible window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8WorkspaceBackingBuildInteractive.ps1 -Apply')
$lines.Add('```')
$lines.Add("")
$lines.Add("Approval phrase:")
$lines.Add("")
$lines.Add('```text')
$lines.Add([string]$config.approvalPhrase)
$lines.Add('```')
$lines.Add("")
$lines.Add("Read-only verification after apply:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8VerifyWorkspaceBackingInteractive.ps1')
$lines.Add('```')
$lines.Add("")
$lines.Add("## Safety Limits")
$lines.Add("")
foreach ($limit in $config.safetyLimits) {
    $lines.Add(("- {0}" -f $limit))
}
$lines.Add("")
$lines.Add("## Routing Pages")
$lines.Add("")
$lines.Add("| Page | File | Navigation group | Role |")
$lines.Add("|---|---|---|---|")
foreach ($page in $config.pages) {
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $page.title, $page.fileName, $page.navGroup, $page.role))
}
$lines.Add("")
$lines.Add("## Lists")
$lines.Add("")
$lines.Add("| List | Columns | Views |")
$lines.Add("|---|---|---|")
foreach ($list in $config.lists) {
    $columns = (($list.columns | ForEach-Object { [string]$_.displayName }) -join "; ")
    $views = (($list.views | ForEach-Object { [string]$_.title }) -join "; ")
    $lines.Add(("| {0} | {1} | {2} |" -f $list.title, $columns, $views))
}
$lines.Add("")
$lines.Add("## Libraries")
$lines.Add("")
$lines.Add("| Library | Folders |")
$lines.Add("|---|---|")
foreach ($library in $config.libraries) {
    $folders = (($library.folders | ForEach-Object { [string]$_ }) -join "; ")
    $lines.Add(("| {0} | {1} |" -f $library.title, $folders))
}
$lines.Add("")
$lines.Add("## Navigation Targets")
$lines.Add("")
$lines.Add("| Group | Link | Kind | Target |")
$lines.Add("|---|---|---|---|")
foreach ($target in $config.navigationTargets) {
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $target.group, $target.link, $target.kind, $target.target))
}
$lines.Add("")
$lines.Add("## Output Files")
$lines.Add("")
$lines.Add(('- Page map: `{0}`' -f $pageCsvPath))
$lines.Add(('- List map: `{0}`' -f $listCsvPath))
$lines.Add(('- Library map: `{0}`' -f $libraryCsvPath))
$lines.Add(('- Navigation map: `{0}`' -f $navCsvPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8 workspace backing structure packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
