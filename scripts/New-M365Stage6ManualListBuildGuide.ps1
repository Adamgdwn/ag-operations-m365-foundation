param(
    [string]$SchemaPath = ".\config\M365_STAGE_6_OPERATING_STATE_SCHEMA.json",
    [string]$OutputPath = ".\inventory\stage-6-operating-state\STAGE_6_MANUAL_LIST_BUILD_GUIDE.md",
    [string]$RootUrl
)

# Stage 6 - Manual Microsoft Lists build guide generator.
# This is the safe fallback when PnP can authenticate but cannot perform
# SharePoint site operations. It keeps the manual SharePoint UI path aligned with
# the same schema used by the automated provisioner and verifier.

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

function Get-ManualFieldType {
    param([string]$SchemaType)

    switch ($SchemaType) {
        "Boolean" { return "Yes/No" }
        "Choice" { return "Choice" }
        "DateTime" { return "Date and time" }
        "Note" { return "Multiple lines of text" }
        "Number" { return "Number" }
        "Text" { return "Single line of text" }
        "URL" { return "Hyperlink" }
        "User" { return "Person" }
        default { return $SchemaType }
    }
}

function Get-ColumnNotes {
    param([object]$Column)

    $notes = @()
    if ($Column.PSObject.Properties.Name -contains "choices") {
        $notes += ("Choices: {0}" -f (($Column.choices | ForEach-Object { [string]$_ }) -join ", "))
    }
    if ($Column.PSObject.Properties.Name -contains "default") {
        $notes += ("Default: {0}" -f $Column.default)
    }
    if ($Column.internalName -ne $Column.displayName) {
        $notes += ("Internal name: {0}" -f $Column.internalName)
    }
    return ($notes -join "<br>")
}

$resolvedSchemaPath = Resolve-Stage6Path -Path $SchemaPath
$resolvedOutputPath = Resolve-Stage6Path -Path $OutputPath
$schema = Get-Content -LiteralPath $resolvedSchemaPath -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($RootUrl)) {
    $RootUrl = $schema.rootUrl
}
$RootUrl = $RootUrl.TrimEnd("/")

$outputDirectory = Split-Path -Parent $resolvedOutputPath
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 6 Manual Microsoft Lists Build Guide")
$lines.Add("")
$lines.Add(('Generated from `{0}` on {1}.' -f $SchemaPath, (Get-Date -Format "yyyy-MM-dd")))
$lines.Add("")
$lines.Add("Use this guide only when the automated PnP provisioning path is blocked or intentionally deferred. The read-only verifier should still be run afterward so the tenant state is checked against the canonical schema.")
$lines.Add("")
$lines.Add("Safety:")
$lines.Add("")
$lines.Add("- Do not approve raw Microsoft admin-consent URLs.")
$lines.Add("- Do not approve any page showing phishing, risky-app, unknown-publisher, suspicious-consent, or unexpected permission warnings.")
$lines.Add('- Manual list creation through the target SharePoint sites is the safer fallback while the `agent-pnp-provisioning` app is under review.')
$lines.Add("")
$lines.Add("After the Lists are created, run:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage6ListsProvisioningInteractive.ps1 -VerifyOnly")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Manual Creation Summary")
$lines.Add("")
$lines.Add("| Done | Site | List | Site contents |")
$lines.Add("|---|---|---|---|")

foreach ($list in $schema.lists) {
    $siteUrl = "$RootUrl$($list.sitePath)"
    $siteContentsUrl = "$siteUrl/_layouts/15/viewlsts.aspx"
    $lines.Add(("| [ ] | {0} | {1} | {2} |" -f (Escape-MarkdownValue $list.siteTitle), (Escape-MarkdownValue $list.title), $siteContentsUrl))
}

$lines.Add("")
$lines.Add("Creation pattern for each List:")
$lines.Add("")
$lines.Add("1. Open the site contents link.")
$lines.Add("2. Choose New > List > Blank list.")
$lines.Add("3. Use the exact List name below.")
$lines.Add("4. Create each column with the displayed name and field type below.")
$lines.Add("5. Apply choices/defaults where shown.")
$lines.Add("6. Create the listed views and set the default view when marked.")
$lines.Add("7. Run the read-only verifier.")
$lines.Add("")

foreach ($list in $schema.lists) {
    $siteUrl = "$RootUrl$($list.sitePath)"
    $siteContentsUrl = "$siteUrl/_layouts/15/viewlsts.aspx"

    $lines.Add(("## {0}" -f $list.title))
    $lines.Add("")
    $lines.Add(("- Site: {0}" -f $list.siteTitle))
    $lines.Add(("- Site URL: {0}" -f $siteUrl))
    $lines.Add(("- Site contents: {0}" -f $siteContentsUrl))
    $lines.Add(("- Description: {0}" -f $list.description))
    $lines.Add(("- Show in site navigation: {0}" -f $list.quickLaunch))
    $lines.Add("")
    $lines.Add("### Columns")
    $lines.Add("")
    $lines.Add("| Done | Display name | SharePoint UI type | Required | Notes |")
    $lines.Add("|---|---|---|---|---|")

    foreach ($column in $list.columns) {
        $manualType = Get-ManualFieldType -SchemaType $column.type
        $required = if ($column.required -eq $true) { "Yes" } else { "No" }
        $notes = Get-ColumnNotes -Column $column
        $lines.Add(("| [ ] | {0} | {1} | {2} | {3} |" -f (Escape-MarkdownValue $column.displayName), (Escape-MarkdownValue $manualType), $required, (Escape-MarkdownValue $notes)))
    }

    $lines.Add("")
    $lines.Add("### Views")
    $lines.Add("")
    $lines.Add("| Done | View | Default | Columns |")
    $lines.Add("|---|---|---|---|")

    foreach ($view in $list.views) {
        $isDefault = if (($view.PSObject.Properties.Name -contains "default") -and $view.default -eq $true) { "Yes" } else { "No" }
        $fields = ($view.fields | ForEach-Object { [string]$_ }) -join ", "
        $lines.Add(("| [ ] | {0} | {1} | {2} |" -f (Escape-MarkdownValue $view.title), $isDefault, (Escape-MarkdownValue $fields)))
    }

    $lines.Add("")
}

$lines.Add("## Verification Handoff")
$lines.Add("")
$lines.Add('The manual path is complete only when the verifier can read each target site and reports all expected Lists, fields, and views as present. If PnP verification still cannot read the site, keep the tenant write automation paused and review the `agent-pnp-provisioning` app in Entra admin center.')
$lines.Add("")

Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8
Write-Host "Manual Stage 6 build guide written to: $resolvedOutputPath" -ForegroundColor Green
