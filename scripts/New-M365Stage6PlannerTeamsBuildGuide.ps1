param(
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$OutputPath = ".\inventory\stage-6-operating-state\STAGE_6_PLANNER_TEAMS_BUILD_GUIDE.md"
)

# Stage 6 - Manual Planner and Teams build guide generator.
# This does not connect to Microsoft 365. It turns the canonical Stage 6 schema
# into a human-safe checklist for the collaboration surfaces that should wrap the
# Lists after list read-back is clean.

$ErrorActionPreference = "Stop"

function Resolve-Stage6Path {
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

$resolvedSchemaPath = Resolve-Stage6Path -Path $SchemaPath
$resolvedOutputPath = Resolve-Stage6Path -Path $OutputPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json

$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$planTitle = $schema.planner.planTitle
$teamTitle = $schema.teams.teamTitle

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 6 Planner And Teams Build Guide")
$lines.Add("")
$lines.Add(('Generated from `{0}` on {1}.' -f $SchemaPath, (Get-Date -Format "yyyy-MM-dd")))
$lines.Add("")
$lines.Add("Use this after the four Stage 6 Lists exist and read-back verification is clean. Planner and Teams are useful only when the underlying operating state is already in place.")
$lines.Add("")
$lines.Add("Safety:")
$lines.Add("")
$lines.Add("- Do not create guests, external sharing links, mailbox rules, tenant policies, or automation from this guide.")
$lines.Add("- Keep this first Team internal to Adam/Guided AI Labs operating work.")
$lines.Add("- Create Planner tasks only for real next actions; do not mirror every email or List item.")
$lines.Add("- Any external send, calendar commitment, permission change, or irreversible operation still requires Adam approval.")
$lines.Add("")
$lines.Add("Recommended sequence:")
$lines.Add("")
$lines.Add("1. Confirm Stage 6 Lists exist and pass read-only verification.")
$lines.Add("2. Create or confirm the Planner plan and buckets.")
$lines.Add("3. Create or confirm the operating Team and channels.")
$lines.Add("4. Add tabs only after each target List/library/plan is available.")
$lines.Add("5. Record any deviations in the Decision Register.")
$lines.Add("")
$lines.Add("## Planner")
$lines.Add("")
$lines.Add(("- Plan name: {0}" -f $planTitle))
$lines.Add("- Scope: Guided AI Labs internal operating work")
$lines.Add("- Rule: action-bearing work only")
$lines.Add("")
$lines.Add("| Done | Bucket | Intended use |")
$lines.Add("|---|---|---|")

foreach ($bucket in $schema.planner.buckets) {
    $intendedUse = switch ($bucket) {
        "Intake Triage" { "New inquiries and triage actions from the Intake Register" }
        "Client Discovery" { "Discovery, readiness, and early client shaping work" }
        "Active Delivery" { "Current client delivery tasks with a clear next action" }
        "Content / IP" { "Reusable methods, templates, and productized knowledge work" }
        "Agent Setup" { "Agentic intake, bridge, workflow, and tooling setup" }
        "Waiting / Follow-up" { "External waits, Adam review waits, and follow-up reminders" }
        "Admin / Governance" { "Tenant setup, decisions, permissions review, and governance tasks" }
        default { "Stage 6 operating work" }
    }
    $lines.Add(("| [ ] | {0} | {1} |" -f (Escape-MarkdownValue $bucket), (Escape-MarkdownValue $intendedUse)))
}

$lines.Add("")
$lines.Add("Planner task naming convention:")
$lines.Add("")
$lines.Add('```text')
$lines.Add("[Lane] concise action - organization/person")
$lines.Add('```')
$lines.Add("")
$lines.Add("Starter tasks to create only if they are still true:")
$lines.Add("")
$lines.Add("| Done | Bucket | Task title | Notes |")
$lines.Add("|---|---|---|---|")
$lines.Add("| [ ] | Agent Setup | [Agent] Verify Stage 6 Lists read-back - Adam | Link to the verifier transcript after it passes |")
$lines.Add("| [ ] | Intake Triage | [Intake] Run first human-approved contact@ triage - Adam | Use selected messages only; no autonomous sends |")
$lines.Add("| [ ] | Admin / Governance | [Governance] Review agent-pnp-provisioning app posture - Adam | Use Entra admin center only; stop on any warning |")
$lines.Add("")
$lines.Add("## Teams")
$lines.Add("")
$lines.Add(("- Team name: {0}" -f $teamTitle))
$lines.Add("- Membership: internal only for the first version")
$lines.Add("- Durable records remain in SharePoint; Teams is for discussion and coordination")
$lines.Add("")
$lines.Add("| Done | Channel | Tabs to pin first | Purpose |")
$lines.Add("|---|---|---|---|")

foreach ($channel in $schema.teams.channels) {
    $purpose = switch ($channel.name) {
        "General" { "Low-volume operating announcements and top-level coordination" }
        "Intake" { "Daily front-door triage and discussion around new inquiries" }
        "Client Discovery" { "Readiness and discovery work before active delivery" }
        "Active Delivery" { "Current delivery coordination without making Teams the file cabinet" }
        "Agent Setup" { "Agentic intake, bridge, workflow, and tooling decisions" }
        "Methods & IP" { "Reusable methods, templates, and productized knowledge" }
        default { "Stage 6 operating coordination" }
    }
    $tabs = ($channel.tabs | ForEach-Object { [string]$_ }) -join ", "
    $lines.Add(("| [ ] | {0} | {1} | {2} |" -f (Escape-MarkdownValue $channel.name), (Escape-MarkdownValue $tabs), (Escape-MarkdownValue $purpose)))
}

$lines.Add("")
$lines.Add("Tab creation notes:")
$lines.Add("")
$lines.Add('- `Intake Register`, `Agent Log`, and `Decisions` should point to the verified Microsoft Lists.')
$lines.Add('- `Operating Plan` should point to the Planner plan above.')
$lines.Add('- `Client_Delivery`, `Automation_Workflows`, and `Templates_Methods` should point to existing SharePoint libraries only if those libraries already exist and are clean.')
$lines.Add("- Skip a tab rather than creating a confusing placeholder.")
$lines.Add("")
$lines.Add("## Verification Handoff")
$lines.Add("")
$lines.Add("After manual setup, capture screenshots or notes for any difference between the schema and the live Teams/Planner layout. If automation is later added, use this guide as the expected baseline.")
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8
Write-Host "Planner/Teams Stage 6 build guide written to: $resolvedOutputPath" -ForegroundColor Green
