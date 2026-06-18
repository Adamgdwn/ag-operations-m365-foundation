param(
    [string]$ConfigPath = ".\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json",
    [string]$OutputRoot = ".\inventory\stage-8c-relationship-crm-operator-workflow"
)

# Stage 8C - local-only Relationship CRM operator workflow packet generator.

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

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW_BUILD_GUIDE.md"
$listCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-list-map.csv"
$fieldCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-field-map.csv"
$lookupCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-lookup-map.csv"
$viewCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-view-map.csv"
$pageCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-page-map.csv"
$stagePathCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-command-center-stage-path.csv"
$intakeCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-frictionless-intake-map.csv"
$navCsvPath = Join-Path $resolvedOutputRoot "stage-8c-crm-workflow-navigation-map.csv"

$config.lists | Select-Object title,description,quickLaunch |
    Export-Csv -LiteralPath $listCsvPath -NoTypeInformation -Encoding UTF8

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

$lookupRows = foreach ($list in $config.lists) {
    foreach ($lookup in $list.lookupFields) {
        [pscustomobject]@{
            List = [string]$list.title
            DisplayName = [string]$lookup.displayName
            InternalName = [string]$lookup.internalName
            TargetList = [string]$lookup.targetList
            TargetField = [string]$lookup.targetField
            Indexed = [string]$lookup.indexed
        }
    }
}
$lookupRows | Export-Csv -LiteralPath $lookupCsvPath -NoTypeInformation -Encoding UTF8

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

$stagePathRows = foreach ($page in $config.pages) {
    foreach ($stage in $page.stagePath) {
        [pscustomobject]@{
            Page = [string]$page.title
            Label = [string]$stage.label
            Description = [string]$stage.description
            List = [string]$stage.list
            View = [string]$stage.view
        }
    }
}
$stagePathRows | Export-Csv -LiteralPath $stagePathCsvPath -NoTypeInformation -Encoding UTF8

if ($config.PSObject.Properties.Name -contains "intakeExperience") {
    $intakeRows = New-Object System.Collections.Generic.List[object]
    foreach ($field in $config.intakeExperience.friendlyFieldNames) {
        $intakeRows.Add([pscustomobject]@{
            Area = "Friendly field label"
            List = [string]$config.intakeExperience.list
            Item = [string]$field.internalName
            Value = [string]$field.displayName
        })
    }
    foreach ($section in $config.intakeExperience.formSections) {
        $intakeRows.Add([pscustomobject]@{
            Area = "Form section"
            List = [string]$config.intakeExperience.list
            Item = [string]$section.displayName
            Value = (@($section.fields | ForEach-Object { [string]$_ }) -join "; ")
        })
    }
    foreach ($fieldName in $config.intakeExperience.readOnlySystemFields) {
        $intakeRows.Add([pscustomobject]@{
            Area = "Hidden system field"
            List = [string]$config.intakeExperience.list
            Item = [string]$fieldName
            Value = "Retained as system/source metadata; not shown in the first business-development intake pass"
        })
    }
    $intakeRows | Export-Csv -LiteralPath $intakeCsvPath -NoTypeInformation -Encoding UTF8
}

$config.navigationTargets | Select-Object group,link,kind,target |
    Export-Csv -LiteralPath $navCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8C Relationship CRM Operator Workflow Build Guide")
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
$lines.Add(".\scripts\Invoke-M365Stage8CRelationshipCrmOperatorWorkflow.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("Live apply in a visible approval window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1 -Apply")
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
$lines.Add(".\scripts\Start-M365Stage8CVerifyRelationshipCrmOperatorWorkflowInteractive.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Safety Limits")
$lines.Add("")
foreach ($limit in $config.safetyLimits) {
    $lines.Add(("- {0}" -f $limit))
}
$lines.Add("")
$lines.Add("## Operator Workflow Lists")
$lines.Add("")
$lines.Add("| List | Purpose |")
$lines.Add("|---|---|")
foreach ($list in $config.lists) {
    $lines.Add(("| {0} | {1} |" -f $list.title, $list.description))
}
$lines.Add("")
$lines.Add("## Workflow Views")
$lines.Add("")
$lines.Add("| List | View | Row limit |")
$lines.Add("|---|---|---|")
foreach ($list in $config.lists) {
    foreach ($view in $list.views) {
        $lines.Add(("| {0} | {1} | {2} |" -f $list.title, $view.title, $view.rowLimit))
    }
}
$lines.Add("")
$lines.Add("## CRM Command Center Stage Path")
$lines.Add("")
$lines.Add("| Stage | List | View |")
$lines.Add("|---|---|---|")
foreach ($page in $config.pages) {
    foreach ($stage in $page.stagePath) {
        $lines.Add(("| {0} | {1} | {2} |" -f $stage.label, $stage.list, $stage.view))
    }
}
$lines.Add("")
$lines.Add("## Frictionless Intake")
$lines.Add("")
if ($config.PSObject.Properties.Name -contains "intakeExperience") {
    $lines.Add(('List: `{0}`' -f $config.intakeExperience.list))
    $lines.Add("")
    $lines.Add("| Section | Fields |")
    $lines.Add("|---|---|")
    $friendlyFieldLabelByInternalName = @{}
    foreach ($field in $config.intakeExperience.friendlyFieldNames) {
        $friendlyFieldLabelByInternalName[[string]$field.internalName] = [string]$field.displayName
    }
    foreach ($section in $config.intakeExperience.formSections) {
        $displayFields = @($section.fields | ForEach-Object {
            $internalName = [string]$_
            if ($friendlyFieldLabelByInternalName.ContainsKey($internalName)) {
                $friendlyFieldLabelByInternalName[$internalName]
            }
            else {
                $internalName
            }
        })
        $lines.Add(("| {0} | {1} |" -f $section.displayName, ($displayFields -join "; ")))
    }
    $lines.Add("")
    $lines.Add("System/source/automation fields are kept on the record for later capture or audit, but are not shown in the first business-development intake pass.")
}
else {
    $lines.Add("No frictionless intake experience is configured.")
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
$lines.Add(('- List map: `{0}`' -f $listCsvPath))
$lines.Add(('- Field map: `{0}`' -f $fieldCsvPath))
$lines.Add(('- Lookup map: `{0}`' -f $lookupCsvPath))
$lines.Add(('- View map: `{0}`' -f $viewCsvPath))
$lines.Add(('- Page map: `{0}`' -f $pageCsvPath))
$lines.Add(('- Command center stage path: `{0}`' -f $stagePathCsvPath))
$lines.Add(('- Frictionless intake map: `{0}`' -f $intakeCsvPath))
$lines.Add(('- Navigation map: `{0}`' -f $navCsvPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

Write-Host "Stage 8C Relationship CRM operator workflow packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
