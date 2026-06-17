param(
    [string]$ConfigPath = ".\config\M365_STAGE_8B_RELATIONSHIP_CRM_OPERATIONS.json",
    [string]$OutputRoot = ".\inventory\stage-8b-relationship-crm-operations"
)

# Stage 8B - local-only Relationship CRM operations packet generator.

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
New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8B_RELATIONSHIP_CRM_OPERATIONS_BUILD_GUIDE.md"
$fieldCsvPath = Join-Path $resolvedOutputRoot "stage-8b-crm-operational-field-map.csv"
$lookupCsvPath = Join-Path $resolvedOutputRoot "stage-8b-crm-lookup-field-map.csv"
$viewCsvPath = Join-Path $resolvedOutputRoot "stage-8b-crm-operational-view-map.csv"
$pageCsvPath = Join-Path $resolvedOutputRoot "stage-8b-crm-operational-page-map.csv"
$navCsvPath = Join-Path $resolvedOutputRoot "stage-8b-crm-operational-navigation-map.csv"

$fieldRows = foreach ($list in $config.lists) {
    foreach ($column in $list.columns) {
        [pscustomobject]@{
            List = [string]$list.title
            DisplayName = [string]$column.displayName
            InternalName = [string]$column.internalName
            Type = [string]$column.type
            Required = [string]$column.required
            Indexed = [string]$column.indexed
            Choices = if ($null -ne $column.choices) { (@($column.choices | ForEach-Object { [string]$_ }) -join "; ") } else { "" }
            Default = if ($null -ne $column.default) { [string]$column.default } else { "" }
        }
    }
}
$fieldRows | Export-Csv -LiteralPath $fieldCsvPath -NoTypeInformation -Encoding UTF8

$config.lookupFields | Select-Object list,displayName,internalName,targetList,targetField,indexed |
    Export-Csv -LiteralPath $lookupCsvPath -NoTypeInformation -Encoding UTF8

$viewRows = foreach ($list in $config.lists) {
    foreach ($view in $list.views) {
        [pscustomobject]@{
            List = [string]$list.title
            View = [string]$view.title
            Fields = (@($view.fields | ForEach-Object { [string]$_ }) -join "; ")
            RowLimit = [string]$view.rowLimit
            Query = [string]$view.query
        }
    }
}
$viewRows | Export-Csv -LiteralPath $viewCsvPath -NoTypeInformation -Encoding UTF8

$config.pages | Select-Object title,fileName,navGroup,role |
    Export-Csv -LiteralPath $pageCsvPath -NoTypeInformation -Encoding UTF8

$config.navigationTargets | Select-Object group,link,kind,target,expectedStatus,supersededBy,note |
    Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8B Relationship CRM Operations Build Guide")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Config: `{0}`' -f $resolvedConfigPath))
$lines.Add("")
$lines.Add("Scope: local-only packet. This does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add("## Site")
$lines.Add("")
$lines.Add("| Field | Value |")
$lines.Add("|---|---|")
$lines.Add(("| Title | {0} |" -f $config.site.title))
$lines.Add(("| URL | {0} |" -f $config.site.url))
$lines.Add(("| Purpose | {0} |" -f $config.site.purpose))
$lines.Add("")
$lines.Add("## Apply")
$lines.Add("")
$lines.Add("Dry run:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Invoke-M365Stage8BRelationshipCrmOperationalize.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("Live apply in a visible approval window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8BRelationshipCrmOperationalizeInteractive.ps1 -Apply")
$lines.Add('```')
$lines.Add("")
$lines.Add("Approval phrase:")
$lines.Add("")
$lines.Add('```text')
$lines.Add([string]$config.approvalPhrase)
$lines.Add('```')
$lines.Add("")
$lines.Add("Read-only verification:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8BVerifyRelationshipCrmOperationsInteractive.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Safety Limits")
$lines.Add("")
foreach ($limit in $config.safetyLimits) {
    $lines.Add(("- {0}" -f $limit))
}
$lines.Add("")
$lines.Add("## Lookup Fields")
$lines.Add("")
$lines.Add("| List | Field | Target |")
$lines.Add("|---|---|---|")
foreach ($lookup in $config.lookupFields) {
    $lines.Add(("| {0} | {1} (`{2}`) | {3} / {4} |" -f $lookup.list, $lookup.displayName, $lookup.internalName, $lookup.targetList, $lookup.targetField))
}
$lines.Add("")
$lines.Add("## Operational Views")
$lines.Add("")
$lines.Add("| List | View | Row limit |")
$lines.Add("|---|---|---|")
foreach ($list in $config.lists) {
    foreach ($view in $list.views) {
        $lines.Add(("| {0} | {1} | {2} |" -f $list.title, $view.title, $view.rowLimit))
    }
}
$lines.Add("")
$lines.Add("## Workflow Proof")
$lines.Add("")
foreach ($step in $config.workflowProof) {
    $lines.Add(("- {0}" -f $step))
}
$lines.Add("")
$lines.Add("## Output Files")
$lines.Add("")
$lines.Add(('- Operational field map: `{0}`' -f $fieldCsvPath))
$lines.Add(('- Lookup field map: `{0}`' -f $lookupCsvPath))
$lines.Add(('- Operational view map: `{0}`' -f $viewCsvPath))
$lines.Add(('- Page map: `{0}`' -f $pageCsvPath))
$lines.Add(('- Navigation map: `{0}`' -f $navCsvPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8B Relationship CRM operations packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
