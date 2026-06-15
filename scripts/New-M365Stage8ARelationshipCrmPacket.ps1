param(
    [string]$ConfigPath = ".\config\M365_STAGE_8A_RELATIONSHIP_CRM.json",
    [string]$OutputRoot = ".\inventory\stage-8a-relationship-crm"
)

# Stage 8A - local-only Relationship CRM packet generator.
# Reads the CRM config and writes a build guide plus CSV maps. It does not
# connect to Microsoft 365 and performs no tenant writes.

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

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8A_RELATIONSHIP_CRM_BUILD_GUIDE.md"
$pageCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-page-map.csv"
$listCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-list-map.csv"
$fieldCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-field-map.csv"
$viewCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-view-map.csv"
$navCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-navigation-map.csv"
$workflowCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-workflow-map.csv"
$teamsCsvPath = Join-Path $resolvedOutputRoot "stage-8a-relationship-crm-teams-tab-later-map.csv"

$config.pages | Select-Object title,fileName,navGroup,role |
    Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8

$listRows = foreach ($list in $config.lists) {
    [pscustomobject]@{
        Title = [string]$list.title
        Description = [string]$list.description
        Columns = (($list.columns | ForEach-Object { [string]$_.displayName }) -join "; ")
        Views = (($list.views | ForEach-Object { [string]$_.title }) -join "; ")
    }
}
$listRows | Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8

$fieldRows = foreach ($list in $config.lists) {
    foreach ($column in $list.columns) {
        [pscustomobject]@{
            List = [string]$list.title
            DisplayName = [string]$column.displayName
            InternalName = [string]$column.internalName
            Type = [string]$column.type
            Required = [string]$column.required
            Choices = if ($null -ne $column.choices) { (@($column.choices | ForEach-Object { [string]$_ }) -join "; ") } else { "" }
            Default = if ($null -ne $column.default) { [string]$column.default } else { "" }
        }
    }
}
$fieldRows | Export-Csv -LiteralPath $fieldCsvPath -NoTypeInformation -Encoding UTF8

$viewRows = foreach ($list in $config.lists) {
    foreach ($view in $list.views) {
        [pscustomobject]@{
            List = [string]$list.title
            View = [string]$view.title
            Default = [string]$view.default
            Fields = (@($view.fields | ForEach-Object { [string]$_ }) -join "; ")
        }
    }
}
$viewRows | Export-Csv -LiteralPath $viewCsvPath -NoTypeInformation -Encoding UTF8

$config.navigationTargets | Select-Object group,link,kind,target |
    Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$workflowRows = foreach ($workflow in $config.workflows) {
    [pscustomobject]@{
        Name = [string]$workflow.name
        Steps = (@($workflow.steps | ForEach-Object { [string]$_ }) -join " -> ")
    }
}
$workflowRows | Export-Csv -LiteralPath $workflowCsvPath -NoTypeInformation -Encoding UTF8

$config.teamsTabsLater | Select-Object channel,tab,target |
    Export-Csv -LiteralPath $teamsCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8A Relationship CRM Build Guide")
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
$lines.Add("Dry-run:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Invoke-M365Stage8ARelationshipCrmBuild.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("Apply after approval in a visible window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8ARelationshipCrmBuildInteractive.ps1 -Apply")
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
$lines.Add(".\scripts\Start-M365Stage8AVerifyRelationshipCrmInteractive.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Safety Limits")
$lines.Add("")
foreach ($limit in $config.safetyLimits) {
    $lines.Add(("- {0}" -f $limit))
}
$lines.Add("")
$lines.Add("## CRM Lists")
$lines.Add("")
$lines.Add("| List | Purpose | Views |")
$lines.Add("|---|---|---|")
foreach ($list in $config.lists) {
    $views = (($list.views | ForEach-Object { [string]$_.title }) -join "; ")
    $lines.Add(("| {0} | {1} | {2} |" -f $list.title, $list.description, $views))
}
$lines.Add("")
$lines.Add("## Page")
$lines.Add("")
$lines.Add("| Page | File | Navigation group | Role |")
$lines.Add("|---|---|---|---|")
foreach ($page in $config.pages) {
    $lines.Add(("| {0} | {1} | {2} | {3} |" -f $page.title, $page.fileName, $page.navGroup, $page.role))
}
$lines.Add("")
$lines.Add("## Offer Packages")
$lines.Add("")
foreach ($package in $config.offerPackages) {
    $lines.Add(("- {0}" -f $package))
}
$lines.Add("")
$lines.Add("## Engagement Stages")
$lines.Add("")
foreach ($stage in $config.engagementStages) {
    $lines.Add(("- {0}" -f $stage))
}
$lines.Add("")
$lines.Add("## Workflows")
$lines.Add("")
$lines.Add("| Workflow | Steps |")
$lines.Add("|---|---|")
foreach ($workflow in $config.workflows) {
    $steps = (@($workflow.steps | ForEach-Object { [string]$_ }) -join " -> ")
    $lines.Add(("| {0} | {1} |" -f $workflow.name, $steps))
}
$lines.Add("")
$lines.Add("## Teams Tabs Later")
$lines.Add("")
$lines.Add("Do not create these until SharePoint CRM verification passes.")
$lines.Add("")
$lines.Add("| Channel | Tab | Target |")
$lines.Add("|---|---|---|")
foreach ($tab in $config.teamsTabsLater) {
    $lines.Add(("| {0} | {1} | {2} |" -f $tab.channel, $tab.tab, $tab.target))
}
$lines.Add("")
$lines.Add("## Agent Permission Notes")
$lines.Add("")
foreach ($note in $config.agentPermissions) {
    $lines.Add(("- {0}" -f $note))
}
$lines.Add("")
$lines.Add("## Output Files")
$lines.Add("")
$lines.Add(('- Page map: `{0}`' -f $pageCsvPath))
$lines.Add(('- List map: `{0}`' -f $listCsvPath))
$lines.Add(('- Field map: `{0}`' -f $fieldCsvPath))
$lines.Add(('- View map: `{0}`' -f $viewCsvPath))
$lines.Add(('- Navigation map: `{0}`' -f $navCsvPath))
$lines.Add(('- Workflow map: `{0}`' -f $workflowCsvPath))
$lines.Add(('- Teams tabs later map: `{0}`' -f $teamsCsvPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8A Relationship CRM packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
