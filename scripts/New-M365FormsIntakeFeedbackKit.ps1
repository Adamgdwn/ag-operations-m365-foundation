param(
    [string]$FormsSchemaPath = ".\config\M365_FORMS_INTAKE_FEEDBACK_KIT.json",
    [string]$OutputDirectory = ".\inventory\stage-6-operating-state\forms-intake-feedback"
)

# Microsoft Forms intake/feedback kit generator.
# This is local-only. It does not connect to Microsoft 365 and performs no tenant writes.

$ErrorActionPreference = "Stop"

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Escape-MarkdownValue {
    param([object]$Value)

    if ($null -eq $Value) {
        return ""
    }

    $text = [string]$Value
    $text = $text -replace "\|", "\|"
    $text = $text -replace "`r?`n", "<br>"
    return $text
}

function Convert-ChoicesToText {
    param([object]$Question)

    if ($null -eq $Question.choices) {
        return ""
    }

    return (($Question.choices | ForEach-Object { [string]$_ }) -join "; ")
}

function Get-PropertyPairs {
    param([object]$Object)

    if ($null -eq $Object) {
        return @()
    }

    return @($Object.PSObject.Properties | ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Value = [string]$_.Value
        }
    })
}

$resolvedSchemaPath = Resolve-WorkspacePath -Path $FormsSchemaPath
$resolvedOutputDirectory = Resolve-WorkspacePath -Path $OutputDirectory
New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null

$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json

$guidePath = Join-Path $resolvedOutputDirectory "M365_FORMS_INTAKE_FEEDBACK_BUILD_GUIDE.md"
$questionCsvPath = Join-Path $resolvedOutputDirectory "forms-question-map.csv"
$flowCsvPath = Join-Path $resolvedOutputDirectory "forms-flow-build-checklist.csv"

$questionRows = New-Object System.Collections.Generic.List[object]
$flowRows = New-Object System.Collections.Generic.List[object]

foreach ($form in $schema.forms) {
    foreach ($question in $form.questions) {
        $questionRows.Add([pscustomobject]@{
            FormId = $form.id
            FormTitle = $form.title
            Question = $question.label
            Type = $question.type
            Required = [bool]$question.required
            Choices = Convert-ChoicesToText -Question $question
            MapsTo = $question.mapsTo
            TargetList = $form.targetList
            TargetSitePath = $form.targetSitePath
        })
    }

    $step = 1
    foreach ($action in $schema.flowPattern) {
        $flowRows.Add([pscustomobject]@{
            FormId = $form.id
            FormTitle = $form.title
            Step = $step
            Action = $action
            TargetList = $form.targetList
            Notes = switch -Regex ($action) {
                "When a new response" { "Select this form as the trigger." }
                "Get response details" { "Use the response id from the trigger." }
                "Create item" { "Map questions and defaults into the target List." }
                "Condition" { $form.plannerRule }
                "Create task" { "Only create a task when the condition is true." }
                "Post message" { $form.teamsNotification }
                "Update created List item" { "Store PlannerTaskUrl after task creation when available." }
                default { "" }
            }
        })
        $step++
    }
}

$questionRows | Export-Csv -LiteralPath $questionCsvPath -NoTypeInformation -Encoding UTF8
$flowRows | Export-Csv -LiteralPath $flowCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Microsoft Forms Intake And Feedback Build Guide")
$lines.Add("")
$lines.Add(("Generated from `{0}` on {1}." -f $FormsSchemaPath, (Get-Date -Format "yyyy-MM-dd")))
$lines.Add("")
$lines.Add("Purpose: make Microsoft Forms a first-class intake and feedback front door while keeping Microsoft Lists as the operating state.")
$lines.Add("")
$lines.Add("This guide is local-only. It does not create forms, flows, external links, guests, or tenant policy changes.")
$lines.Add("")
$lines.Add("## Governance")
$lines.Add("")
$lines.Add(("Initial sharing: {0}" -f $schema.governance.initialSharing))
$lines.Add("")
$lines.Add(("External sharing decision: {0}" -f $schema.governance.externalSharingDecision))
$lines.Add("")
$lines.Add(("Phishing protection: {0}" -f $schema.governance.phishingProtection))
$lines.Add("")
$lines.Add(("Response storage: {0}" -f $schema.governance.responseStorage))
$lines.Add("")
$lines.Add(("Approval gate: {0}" -f $schema.governance.approvalGate))
$lines.Add("")
$lines.Add("Useful Microsoft references:")
$lines.Add("")
foreach ($doc in $schema.governance.sourceDocs) {
    $lines.Add(("- {0}" -f $doc))
}
$lines.Add("")
$lines.Add("## Recommended Build Order")
$lines.Add("")
$lines.Add("1. Confirm Stage 7 governance posture for external Forms collection.")
$lines.Add("2. Create the internal/test version of each form in Microsoft Forms.")
$lines.Add("3. Create the Power Automate flow for one form at a time.")
$lines.Add("4. Submit one test response and verify the target List item.")
$lines.Add("5. Add Planner task and Teams notification steps only after the List write works.")
$lines.Add("6. Publish external/client links only after Adam approves the form, flow, and sharing setting.")
$lines.Add("7. Record the production link and approval decision in the Decision Register.")
$lines.Add("")
$lines.Add("## Forms")
$lines.Add("")

foreach ($form in $schema.forms) {
    $lines.Add(("### {0}" -f $form.title))
    $lines.Add("")
    $lines.Add(('Form id: `{0}`' -f $form.id))
    $lines.Add("")
    $lines.Add("| Field | Value |")
    $lines.Add("|---|---|")
    $lines.Add(("| Audience | {0} |" -f (Escape-MarkdownValue $form.audience)))
    $lines.Add(("| Owner | {0} |" -f (Escape-MarkdownValue $form.owner)))
    $lines.Add(("| Stage | {0} |" -f (Escape-MarkdownValue $form.stage)))
    $lines.Add(("| Target List | {0} |" -f (Escape-MarkdownValue $form.targetList)))
    $lines.Add(("| Target site | {0} |" -f (Escape-MarkdownValue $form.targetSitePath)))
    $lines.Add(("| Sharing | {0} |" -f (Escape-MarkdownValue $form.sharing)))
    $lines.Add(("| Response setting | {0} |" -f (Escape-MarkdownValue $form.responseSetting)))
    $lines.Add(("| Planner rule | {0} |" -f (Escape-MarkdownValue $form.plannerRule)))
    $lines.Add(("| Teams notification | {0} |" -f (Escape-MarkdownValue $form.teamsNotification)))
    $lines.Add("")
    $lines.Add("Questions:")
    $lines.Add("")
    $lines.Add("| Done | Question | Type | Required | Choices | Maps to |")
    $lines.Add("|---|---|---|---|---|---|")

    foreach ($question in $form.questions) {
        $lines.Add(("| [ ] | {0} | {1} | {2} | {3} | {4} |" -f `
            (Escape-MarkdownValue $question.label),
            (Escape-MarkdownValue $question.type),
            (Escape-MarkdownValue $question.required),
            (Escape-MarkdownValue (Convert-ChoicesToText -Question $question)),
            (Escape-MarkdownValue $question.mapsTo)))
    }

    $lines.Add("")
    $lines.Add("List defaults:")
    $lines.Add("")
    $lines.Add("| Column | Default |")
    $lines.Add("|---|---|")

    foreach ($pair in (Get-PropertyPairs -Object $form.listDefaults)) {
        $lines.Add(("| {0} | {1} |" -f (Escape-MarkdownValue $pair.Name), (Escape-MarkdownValue $pair.Value)))
    }

    $lines.Add("")
    $lines.Add("Power Automate checklist:")
    $lines.Add("")
    $lines.Add("| Done | Step | Action | Notes |")
    $lines.Add("|---|---:|---|---|")
    $flowSteps = @($flowRows | Where-Object { $_.FormId -eq $form.id } | Sort-Object Step)
    foreach ($flowStep in $flowSteps) {
        $lines.Add(("| [ ] | {0} | {1} | {2} |" -f $flowStep.Step, (Escape-MarkdownValue $flowStep.Action), (Escape-MarkdownValue $flowStep.Notes)))
    }

    $lines.Add("")
}

$lines.Add("## Generated Companion Files")
$lines.Add("")
$lines.Add("| File | Purpose |")
$lines.Add("|---|---|")
$lines.Add("| `forms-question-map.csv` | Flat question-to-List mapping for build/review |")
$lines.Add("| `forms-flow-build-checklist.csv` | Flat Power Automate action checklist by form |")
$lines.Add("")
$lines.Add("## Safety Notes")
$lines.Add("")
$lines.Add("- Microsoft Forms links can become public collection surfaces. Treat public links as external sharing.")
$lines.Add("- Do not collect sensitive client material until Stage 7 sharing/security decisions are complete.")
$lines.Add("- Keep phishing protection enabled.")
$lines.Add("- Store operational response data in Lists, not only in the Forms response workbook.")
$lines.Add("- Prefer one form, one flow, one verified List write before expanding the pattern.")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8
Write-Host "Microsoft Forms intake/feedback kit written to: $resolvedOutputDirectory" -ForegroundColor Green
