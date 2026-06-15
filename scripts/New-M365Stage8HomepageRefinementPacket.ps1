param(
    [string]$ConfigPath = ".\config\M365_STAGE_8_HOMEPAGE_REFINEMENT.json",
    [string]$OutputRoot = ".\inventory\stage-8-client-workspace-reference\homepage-refinement"
)

# Stage 8 - local-only homepage refinement packet generator.
# Reads the command-center homepage config and writes build guides, CSV maps,
# and a static HTML preview. It does not connect to Microsoft 365.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function ConvertTo-HtmlText {
    param([string]$Value)

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
$resolvedOutputRoot = Resolve-WorkspacePath -Path $OutputRoot

if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

$guidePath = Join-Path $resolvedOutputRoot "STAGE_8_HOMEPAGE_REFINEMENT_BUILD_GUIDE.md"
$cardsCsvPath = Join-Path $resolvedOutputRoot "stage-8-homepage-command-cards.csv"
$activeCsvPath = Join-Path $resolvedOutputRoot "stage-8-homepage-active-work-snapshot.csv"
$pathwayCsvPath = Join-Path $resolvedOutputRoot "stage-8-homepage-client-pathway.csv"
$dashboardCsvPath = Join-Path $resolvedOutputRoot "stage-8-operational-readiness-dashboard-runway.csv"
$previewPath = Join-Path $resolvedOutputRoot "stage-8-command-center-preview.html"

$config.commandCards | Select-Object title, statusLine, pageTitle, pageFileName |
    Export-Csv -LiteralPath $cardsCsvPath -NoTypeInformation -Encoding UTF8

$config.activeWorkSnapshot | Select-Object column, purpose |
    Export-Csv -LiteralPath $activeCsvPath -NoTypeInformation -Encoding UTF8

$config.clientPathwaySnapshot | Select-Object stage, toolsetDirection |
    Export-Csv -LiteralPath $pathwayCsvPath -NoTypeInformation -Encoding UTF8

$config.operationalReadiness.dashboardRunway | Select-Object phase, shape, sourceCandidates |
    Export-Csv -LiteralPath $dashboardCsvPath -NoTypeInformation -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 8 Homepage Refinement Build Guide")
$lines.Add("")
$lines.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(('Config: `{0}`' -f $resolvedConfigPath))
$lines.Add("")
$lines.Add("Scope: local-only build guide. This packet does not connect to Microsoft 365 and performs no tenant writes.")
$lines.Add("")
$lines.Add("## Decision Summary")
$lines.Add("")
$lines.Add(("Homepage title: **{0}**" -f $config.homepage.workingTitle))
$lines.Add("")
$lines.Add(("Purpose: {0}" -f $config.homepage.purpose))
$lines.Add("")
$lines.Add(("Label style: {0}" -f $config.homepage.labelStyle))
$lines.Add("")
$lines.Add(("Routing default: {0}" -f $config.homepage.routingDefault))
$lines.Add("")
$lines.Add(("Card mode: {0}" -f $config.homepage.cardMode))
$lines.Add("")
$lines.Add(("Operational Readiness placement: {0}" -f $config.operationalReadiness.placement))
$lines.Add("")
$lines.Add("## Homepage Layout")
$lines.Add("")
foreach ($item in $config.homepage.layout) {
    $lines.Add(("- {0}" -f $item))
}
$lines.Add("")
$lines.Add("## Command Cards")
$lines.Add("")
$lines.Add("| Card | Status line | Page target | Future sources |")
$lines.Add("|---|---|---|---|")
foreach ($card in $config.commandCards) {
    $sources = (($card.futureSources | ForEach-Object { [string]$_ }) -join "; ")
    $lines.Add(("| {0} | {1} | {2} ({3}) | {4} |" -f $card.title, $card.statusLine, $card.pageTitle, $card.pageFileName, $sources))
}
$lines.Add("")
$lines.Add("## Active Work Snapshot")
$lines.Add("")
$lines.Add("| Column | Purpose |")
$lines.Add("|---|---|")
foreach ($column in $config.activeWorkSnapshot) {
    $lines.Add(("| {0} | {1} |" -f $column.column, $column.purpose))
}
$lines.Add("")
$lines.Add("## Client Pathway Snapshot")
$lines.Add("")
$lines.Add('```text')
$lines.Add((($config.clientPathwaySnapshot | ForEach-Object { [string]$_.stage }) -join " -> "))
$lines.Add('```')
$lines.Add("")
$lines.Add("| Stage | Toolset direction |")
$lines.Add("|---|---|")
foreach ($stage in $config.clientPathwaySnapshot) {
    $lines.Add(("| {0} | {1} |" -f $stage.stage, $stage.toolsetDirection))
}
$lines.Add("")
$lines.Add("## Operational Readiness Dashboard Runway")
$lines.Add("")
$lines.Add(($config.operationalReadiness.orientation))
$lines.Add("")
$lines.Add("| Phase | Shape | Source candidates |")
$lines.Add("|---|---|---|")
foreach ($phase in $config.operationalReadiness.dashboardRunway) {
    $lines.Add(("| {0} | {1} | {2} |" -f $phase.phase, $phase.shape, $phase.sourceCandidates))
}
$lines.Add("")
$lines.Add("Potential future metrics:")
$lines.Add("")
foreach ($metric in $config.operationalReadiness.futureMetrics) {
    $lines.Add(("- {0}" -f $metric))
}
$lines.Add("")
$lines.Add("## Live Apply Path")
$lines.Add("")
$lines.Add("The live operator is intentionally draft-first. It creates a review page only:")
$lines.Add("")
$lines.Add(('`{0}`' -f $config.homepage.draftFileName))
$lines.Add("")
$lines.Add("It does not replace the current homepage, change navigation, change permissions, invite guests, widen sharing, grant apps, publish public Forms links, or create automation.")
$lines.Add("")
$lines.Add("Dry run:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Invoke-M365Stage8HomepageRefinementBuild.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("Visible apply window:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8HomepageRefinementInteractive.ps1 -Apply")
$lines.Add('```')
$lines.Add("")
$lines.Add("Approval phrase:")
$lines.Add("")
$lines.Add('```text')
$lines.Add([string]$config.approvalPhrase)
$lines.Add('```')
$lines.Add("")
$lines.Add("Read-only verification after draft creation:")
$lines.Add("")
$lines.Add('```powershell')
$lines.Add(".\scripts\Start-M365Stage8VerifyHomepageRefinementInteractive.ps1")
$lines.Add('```')
$lines.Add("")
$lines.Add("## Safety Limits")
$lines.Add("")
foreach ($limit in $config.safetyLimits) {
    $lines.Add(("- {0}" -f $limit))
}
$lines.Add("")
$lines.Add("## Output Files")
$lines.Add("")
$lines.Add(("- Command cards CSV: {0}" -f $cardsCsvPath))
$lines.Add(("- Active work CSV: {0}" -f $activeCsvPath))
$lines.Add(("- Client pathway CSV: {0}" -f $pathwayCsvPath))
$lines.Add(("- Dashboard runway CSV: {0}" -f $dashboardCsvPath))
$lines.Add(("- HTML preview: {0}" -f $previewPath))
$lines.Add("")

Set-Content -LiteralPath $guidePath -Value $lines -Encoding UTF8

$cardHtml = foreach ($card in $config.commandCards) {
@"
      <article class="card">
        <h2>$(ConvertTo-HtmlText $card.title)</h2>
        <p>$(ConvertTo-HtmlText $card.statusLine)</p>
        <span>$(ConvertTo-HtmlText $card.pageTitle)</span>
      </article>
"@
}

$activeHtml = foreach ($column in $config.activeWorkSnapshot) {
@"
      <article class="panel">
        <h3>$(ConvertTo-HtmlText $column.column)</h3>
        <p>$(ConvertTo-HtmlText $column.purpose)</p>
      </article>
"@
}

$pathwayHtml = foreach ($stage in $config.clientPathwaySnapshot) {
@"
      <article class="path-step">
        <h3>$(ConvertTo-HtmlText $stage.stage)</h3>
        <p>$(ConvertTo-HtmlText $stage.toolsetDirection)</p>
      </article>
"@
}

$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$(ConvertTo-HtmlText $config.homepage.workingTitle)</title>
  <style>
    body { margin: 0; font-family: Segoe UI, Arial, sans-serif; color: #1f2933; background: #f7f8fa; }
    main { max-width: 1180px; margin: 0 auto; padding: 32px 24px 48px; }
    header { border-bottom: 1px solid #d8dde6; padding-bottom: 20px; margin-bottom: 24px; }
    h1 { font-size: 32px; margin: 0 0 8px; font-weight: 650; }
    p { line-height: 1.45; }
    .subtle { color: #52616f; max-width: 760px; }
    .cards { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 20px 0 28px; }
    .card, .panel, .path-step, .signal { background: #fff; border: 1px solid #d8dde6; border-radius: 8px; padding: 16px; }
    .card h2 { font-size: 18px; margin: 0 0 8px; }
    .card p, .panel p, .path-step p { margin: 0 0 12px; color: #52616f; }
    .card span { font-size: 12px; color: #006b6f; font-weight: 600; }
    section { margin-top: 28px; }
    section h2 { font-size: 22px; margin: 0 0 12px; }
    .panels { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; }
    .pathway { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 10px; }
    .path-step h3, .panel h3 { margin: 0 0 8px; font-size: 16px; }
    .signal { border-left: 5px solid #b7791f; }
    @media (max-width: 900px) { .cards, .panels, .pathway { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
  <main>
    <header>
      <h1>$(ConvertTo-HtmlText $config.homepage.workingTitle)</h1>
      <p class="subtle">$(ConvertTo-HtmlText $config.homepage.purpose)</p>
    </header>
    <div class="cards">
$($cardHtml -join "`n")
    </div>
    <section>
      <h2>Active Work Snapshot</h2>
      <div class="panels">
$($activeHtml -join "`n")
      </div>
    </section>
    <section>
      <h2>Client Pathway Snapshot</h2>
      <div class="pathway">
$($pathwayHtml -join "`n")
      </div>
    </section>
    <section>
      <h2>Operational Readiness</h2>
      <div class="signal">
        <p>$(ConvertTo-HtmlText $config.operationalReadiness.orientation)</p>
        <p>Dashboard counts come later after the source records are stable.</p>
      </div>
    </section>
  </main>
</body>
</html>
"@

Set-Content -LiteralPath $previewPath -Value $html -Encoding UTF8

Write-Host "Stage 8 homepage refinement packet written:" -ForegroundColor Green
Write-Host $guidePath -ForegroundColor Gray
Write-Host $previewPath -ForegroundColor Gray
