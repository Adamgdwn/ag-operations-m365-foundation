param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_WORKSPACE_SHAPE.json",
    [string]$OutputRoot = ".\inventory\stage-8-client-workspace-reference\workspace-shape"
)

# Stage 8 - local-only workspace shape packet generator.
# Reads the Stage 8 workspace shape config and writes build guides and CSV maps.
# It does not connect to Microsoft 365 and performs no tenant writes.

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

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8_WORKSPACE_SHAPE_BUILD_GUIDE.md"
$pageCsvPath = Join-Path $resolvedOutputRoot "stage-8-page-map.csv"
$navCsvPath = Join-Path $resolvedOutputRoot "stage-8-navigation-map.csv"
$listCsvPath = Join-Path $resolvedOutputRoot "stage-8-next-list-map.csv"
$libraryCsvPath = Join-Path $resolvedOutputRoot "stage-8-library-role-map.csv"

$pageRows = foreach ($page in $config.pages) {
    [pscustomobject]@{
        Title = $page.title
        FileName = $page.fileName
        NavGroup = $page.navGroup
        Role = $page.role
        SourceOfTruth = (($page.sourceOfTruth | ForEach-Object { [string]$_ }) -join "; ")
        Sections = (($page.sections | ForEach-Object { [string]$_ }) -join "; ")
    }
}
$pageRows | Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8

$navRows = foreach ($group in $config.navigationGroups) {
    $position = 0
    foreach ($link in $group.links) {
        $position++
        [pscustomobject]@{
            Group = $group.title
            Position = $position
            Link = $link
        }
    }
}
$navRows | Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$config.nextLists | Select-Object title, purpose, stage |
    Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8

$config.libraryRoles | Select-Object title, purpose, visibility |
    Export-Csv -LiteralPath $libraryCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Workspace Shape Build Guide")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Config: `{0}`' -f $resolvedConfigPath))
$lines.Add("")
$lines.Add("Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add("## Site")
$lines.Add("")
$lines.Add(("| Field | Value |"))
$lines.Add("|---|---|")
$lines.Add(("| Title | {0} |" -f $config.site.title))
$lines.Add(("| URL | {0} |" -f $config.site.url))
$lines.Add(("| Purpose | {0} |" -f $config.site.purpose))
$lines.Add("")
$lines.Add("## Operating Principle")
$lines.Add("")
$lines.Add('```text')
$lines.Add([string]$config.principle)
$lines.Add('```')
$lines.Add("")
$lines.Add("## Build Order")
$lines.Add("")
$lines.Add("1. Finish Stage 7 closeout gates: support MFA, app-grant resting-state decision, and root/legacy site sharing decision.")
$lines.Add("2. Approve the Stage 8 workspace shape before live page/navigation changes.")
$lines.Add("3. Create or update pages before changing navigation.")
$lines.Add("4. Add page-based navigation groups after target pages exist.")
$lines.Add("5. Add only the first-wave Lists needed for client workspace and handoff flow.")
$lines.Add("6. Create restricted governance/build areas before storing sensitive AI, automation, prompt, app-grant, or integration details.")
$lines.Add("7. Test one real workflow: intake -> triage -> Planner task -> decision -> handoff/readiness note.")
$lines.Add("")
$lines.Add("## Automation")
$lines.Add("")
$lines.Add("Local-only packet regeneration:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\New-M365Stage8WorkspaceShapePacket.ps1')
$lines.Add('```')
$lines.Add("")
$lines.Add("Dry-run the live SharePoint page/navigation build in a visible window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1')
$lines.Add('```')
$lines.Add("")
$lines.Add("Apply after approval in the visible window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8WorkspaceShapeBuildInteractive.ps1 -Apply')
$lines.Add('```')
$lines.Add("")
$lines.Add("Approval phrase:")
$lines.Add("")
$lines.Add('```text')
$lines.Add('apply-stage-8-workspace-shape')
$lines.Add('```')
$lines.Add("")
$lines.Add("The apply operator creates missing modern pages and adds resolvable Quick Launch navigation links. It does not change permissions, invite guests, enable sharing, revoke app grants, publish public Forms, delete pages, overwrite existing pages, or create client-facing automation.")
$lines.Add("")
$lines.Add("Read-only verification after apply:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add('.\scripts\Start-M365Stage8VerifyWorkspaceShapeInteractive.ps1')
$lines.Add('```')
$lines.Add("")
$lines.Add("## Target Pages")
$lines.Add("")
$lines.Add("| Page | File | Navigation group | Role | Source of truth |")
$lines.Add("|---|---|---|---|---|")
foreach ($page in $config.pages) {
    $sources = (($page.sourceOfTruth | ForEach-Object { [string]$_ }) -join "; ")
    $lines.Add(("| {0} | {1} | {2} | {3} | {4} |" -f $page.title, $page.fileName, $page.navGroup, $page.role, $sources))
}
$lines.Add("")
$lines.Add("## Navigation Groups")
$lines.Add("")
$lines.Add("| Group | Links |")
$lines.Add("|---|---|")
foreach ($group in $config.navigationGroups) {
    $links = (($group.links | ForEach-Object { [string]$_ }) -join "; ")
    $lines.Add(("| {0} | {1} |" -f $group.title, $links))
}
$lines.Add("")
$lines.Add("## Next Lists")
$lines.Add("")
$lines.Add("| List | Purpose | Stage |")
$lines.Add("|---|---|---|")
foreach ($list in $config.nextLists) {
    $lines.Add(("| {0} | {1} | {2} |" -f $list.title, $list.purpose, $list.stage))
}
$lines.Add("")
$lines.Add("## Library Roles")
$lines.Add("")
$lines.Add("| Library / role | Purpose | Visibility |")
$lines.Add("|---|---|---|")
foreach ($library in $config.libraryRoles) {
    $lines.Add(("| {0} | {1} | {2} |" -f $library.title, $library.purpose, $library.visibility))
}
$lines.Add("")
$lines.Add("## Live Change Gates")
$lines.Add("")
foreach ($gate in $config.liveChangeGates) {
    $lines.Add(("- {0}" -f $gate))
}
$lines.Add("")
$lines.Add("## Output Files")
$lines.Add("")
$lines.Add(('- Page map: `{0}`' -f $pageCsvPath))
$lines.Add(('- Navigation map: `{0}`' -f $navCsvPath))
$lines.Add(('- Next list map: `{0}`' -f $listCsvPath))
$lines.Add(('- Library role map: `{0}`' -f $libraryCsvPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8 workspace shape packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
