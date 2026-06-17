param(
    [string]$ConfigPath = ".\config\M365_STAGE_8C_RELATIONSHIP_CRM_OPERATOR_WORKFLOW.json",
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [switch]$Apply,
    [switch]$ForceFreshLogin,
    [switch]$NoPause
)

# Stage 8C - approval-gated Relationship CRM operator workflow builder.

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$transcriptRoot = Join-Path $workspaceRoot "inventory\stage-8c-relationship-crm-operator-workflow"
New-Item -ItemType Directory -Path $transcriptRoot -Force | Out-Null
$transcriptPath = Join-Path $transcriptRoot ("stage-8c-crm-operator-workflow-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

function Resolve-WorkspacePath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $workspaceRoot $Path)
}

function Test-JsonProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    return ($Object.PSObject.Properties.Name -contains $Name)
}

function ConvertTo-HtmlText {
    param([string]$Value)

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function ConvertTo-XmlAttributeText {
    param([string]$Value)

    return [System.Security.SecurityElement]::Escape($Value)
}

function Get-SiteRelativeUrl {
    param(
        [string]$SiteUrl,
        [string]$Target
    )

    $siteUri = [System.Uri]$SiteUrl
    $path = $siteUri.AbsolutePath.TrimEnd("/")
    if ($path -eq "") {
        return "/$($Target.TrimStart('/'))"
    }

    return "$path/$($Target.TrimStart('/'))"
}

function Get-ListUrl {
    param([string]$Title)

    $list = Get-PnPList -Identity $Title -Includes DefaultViewUrl,RootFolder
    if (-not [string]::IsNullOrWhiteSpace([string]$list.DefaultViewUrl)) {
        return [string]$list.DefaultViewUrl
    }

    return ([string]$list.RootFolder.ServerRelativeUrl)
}

function Get-ListViewUrl {
    param(
        [string]$ListTitle,
        [string]$ViewTitle
    )

    $view = Get-PnPView -List $ListTitle -Identity $ViewTitle -ErrorAction SilentlyContinue
    if ($null -ne $view) {
        $viewUrl = [string]$view.ServerRelativeUrl
        if (-not [string]::IsNullOrWhiteSpace($viewUrl)) {
            return $viewUrl
        }
    }

    return Get-ListUrl -Title $ListTitle
}

function Get-ListNewFormUrl {
    param([string]$Title)

    $list = Get-PnPList -Identity $Title -Includes RootFolder
    return "$([string]$list.RootFolder.ServerRelativeUrl)/NewForm.aspx"
}

function Ensure-Stage8CList {
    param([object]$List)

    $title = [string]$List.title
    $existing = Get-PnPList -Identity $title -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] List exists: {0}" -f $title) -ForegroundColor Gray
        return
    }

    $onQuickLaunch = $false
    if ((Test-JsonProperty -Object $List -Name "quickLaunch") -and $List.quickLaunch -eq $true) {
        $onQuickLaunch = $true
    }

    New-PnPList -Title $title -Template GenericList -OnQuickLaunch:$onQuickLaunch | Out-Null
    if (-not [string]::IsNullOrWhiteSpace([string]$List.description)) {
        Set-PnPList -Identity $title -Description ([string]$List.description) | Out-Null
    }

    Write-Host ("  [OK] List created: {0}" -f $title) -ForegroundColor Green
}

function Add-Stage8CField {
    param(
        [string]$ListTitle,
        [object]$Column
    )

    $existing = Get-PnPField -List $ListTitle -Identity ([string]$Column.internalName) -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] Field exists: {0}" -f $Column.displayName) -ForegroundColor Gray
    }
    else {
        $params = @{
            List = $ListTitle
            DisplayName = [string]$Column.displayName
            InternalName = [string]$Column.internalName
            Type = [string]$Column.type
            AddToDefaultView = $true
        }

        if ((Test-JsonProperty -Object $Column -Name "required") -and $Column.required -eq $true) {
            $params.Required = $true
        }

        if ([string]$Column.type -eq "Choice") {
            $params.Choices = @($Column.choices | ForEach-Object { [string]$_ })
        }

        Add-PnPField @params | Out-Null
        Write-Host ("  [OK] Field created: {0}" -f $Column.displayName) -ForegroundColor Green
    }

    if (Test-JsonProperty -Object $Column -Name "default") {
        try {
            Set-PnPField -List $ListTitle -Identity ([string]$Column.internalName) -Values @{ DefaultValue = [string]$Column.default } | Out-Null
        }
        catch {
            Write-Host ("  [warn] Could not set default for {0}: {1}" -f $Column.displayName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    if ((Test-JsonProperty -Object $Column -Name "indexed") -and $Column.indexed -eq $true) {
        try {
            Set-PnPField -List $ListTitle -Identity ([string]$Column.internalName) -Values @{ Indexed = $true } | Out-Null
            Write-Host ("  [OK] Field indexed: {0}" -f $Column.displayName) -ForegroundColor Green
        }
        catch {
            Write-Host ("  [warn] Could not index {0}: {1}" -f $Column.displayName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

function Add-Stage8CLookupField {
    param(
        [string]$ListTitle,
        [object]$Lookup
    )

    $internalName = [string]$Lookup.internalName
    $existing = Get-PnPField -List $ListTitle -Identity $internalName -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host ("  [skip] Lookup exists: {0} / {1}" -f $ListTitle, $Lookup.displayName) -ForegroundColor Gray
    }
    else {
        $targetList = Get-PnPList -Identity ([string]$Lookup.targetList)
        $displayName = ConvertTo-XmlAttributeText -Value ([string]$Lookup.displayName)
        $safeName = ConvertTo-XmlAttributeText -Value $internalName
        $targetId = [string]$targetList.Id
        $showField = ConvertTo-XmlAttributeText -Value ([string]$Lookup.targetField)
        $fieldXml = "<Field Type='Lookup' DisplayName='$displayName' Name='$safeName' StaticName='$safeName' List='{$targetId}' ShowField='$showField' Required='FALSE' />"
        Add-PnPFieldFromXml -List $ListTitle -FieldXml $fieldXml | Out-Null
        Write-Host ("  [OK] Lookup created: {0} / {1}" -f $ListTitle, $Lookup.displayName) -ForegroundColor Green
    }

    if ((Test-JsonProperty -Object $Lookup -Name "indexed") -and $Lookup.indexed -eq $true) {
        try {
            Set-PnPField -List $ListTitle -Identity $internalName -Values @{ Indexed = $true } | Out-Null
            Write-Host ("  [OK] Lookup indexed: {0} / {1}" -f $ListTitle, $Lookup.displayName) -ForegroundColor Green
        }
        catch {
            Write-Host ("  [warn] Could not index lookup {0} / {1}: {2}" -f $ListTitle, $Lookup.displayName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

function Set-Stage8CView {
    param(
        [string]$ListTitle,
        [object]$View
    )

    $fields = @($View.fields | ForEach-Object { [string]$_ })
    $existing = Get-PnPView -List $ListTitle -Identity ([string]$View.title) -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        $params = @{
            List = $ListTitle
            Title = [string]$View.title
            Fields = $fields
            Query = [string]$View.query
            Paged = $true
        }

        if ((Test-JsonProperty -Object $View -Name "rowLimit") -and -not [string]::IsNullOrWhiteSpace([string]$View.rowLimit)) {
            $params.RowLimit = [uint32]$View.rowLimit
        }

        Add-PnPView @params | Out-Null
        Write-Host ("  [OK] View created: {0}" -f $View.title) -ForegroundColor Green
    }
    else {
        $values = @{
            ViewQuery = [string]$View.query
            Paged = $true
        }
        if ((Test-JsonProperty -Object $View -Name "rowLimit") -and -not [string]::IsNullOrWhiteSpace([string]$View.rowLimit)) {
            $values.RowLimit = [uint32]$View.rowLimit
        }

        Set-PnPView -List $ListTitle -Identity ([string]$View.title) -Fields $fields -Values $values | Out-Null
        Write-Host ("  [OK] View updated: {0}" -f $View.title) -ForegroundColor Green
    }

    if ((Test-JsonProperty -Object $View -Name "default") -and $View.default -eq $true) {
        try {
            Set-PnPView -List $ListTitle -Identity ([string]$View.title) -Values @{ DefaultView = $true } | Out-Null
        }
        catch {
            Write-Host ("  [warn] Could not set default view {0}: {1}" -f $View.title, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

function New-CommandCenterPageHtml {
    param([object]$Config)

    $page = $Config.pages[0]
    $title = ConvertTo-HtmlText -Value ([string]$page.title)
    $role = ConvertTo-HtmlText -Value ([string]$page.role)
    $intakeList = [string]$Config.intakeExperience.list
    $newIntakeUrl = Get-ListNewFormUrl -Title $intakeList
    $intakeViewUrl = Get-ListViewUrl -ListTitle $intakeList -ViewTitle "Attention Now"
    $qualificationUrl = Get-ListViewUrl -ListTitle "CRM - Qualification" -ViewTitle "Qualification Triage"
    $actionsUrl = Get-ListViewUrl -ListTitle "CRM - Action Queue" -ViewTitle "Open CRM Actions"
    $pipelineUrl = Get-ListViewUrl -ListTitle "CRM - Engagements" -ViewTitle "Pipeline by Stage"
    $deliveryUrl = Get-ListViewUrl -ListTitle "CRM - Engagements" -ViewTitle "Delivery Control"
    $evidenceUrl = Get-ListViewUrl -ListTitle "CRM - Artifacts" -ViewTitle "Handoff Evidence"

    $actionCards = @(
        @{ Label = "Add intake signal"; Url = $newIntakeUrl; Note = "Start here when a new relationship, referral, support signal, or discovery note appears." }
        @{ Label = "Review intake queue"; Url = $intakeViewUrl; Note = "Clear what is waiting, what matters, and what Adam needs to review." }
        @{ Label = "Qualify next"; Url = $qualificationUrl; Note = "Decide fit, urgency, recommended package, and next action." }
        @{ Label = "Work open actions"; Url = $actionsUrl; Note = "Follow-ups, proposals, blockers, meetings, handoff, and relationship work." }
    )

    $actionCardHtml = foreach ($card in $actionCards) {
        $label = ConvertTo-HtmlText -Value ([string]$card.Label)
        $url = ConvertTo-HtmlText -Value ([string]$card.Url)
        $note = ConvertTo-HtmlText -Value ([string]$card.Note)
        "<td style=""width:25%;vertical-align:top;padding:8px;""><div style=""border:1px solid #d0d7de;border-top:5px solid #0f766e;border-radius:6px;padding:12px;min-height:135px;background:#ffffff;""><h3 style=""margin:0 0 8px 0;font-size:18px;""><a href=""$url"">$label</a></h3><p style=""margin:0;color:#475569;"">$note</p></div></td>"
    }

    $stagePathHtml = @()
    if (Test-JsonProperty -Object $page -Name "stagePath") {
        $stagePathHtml = foreach ($stage in $page.stagePath) {
            $label = ConvertTo-HtmlText -Value ([string]$stage.label)
            $description = ConvertTo-HtmlText -Value ([string]$stage.description)
            $listTitle = [string]$stage.list
            $viewTitle = [string]$stage.view
            $url = Get-ListViewUrl -ListTitle $listTitle -ViewTitle $viewTitle
            $encodedUrl = ConvertTo-HtmlText -Value $url
            "<tr><td style=""vertical-align:top;padding:8px;border-bottom:1px solid #e5e7eb;""><strong><a href=""$encodedUrl"">$label</a></strong></td><td style=""vertical-align:top;padding:8px;border-bottom:1px solid #e5e7eb;"">$description</td></tr>"
        }
    }

    $linkHtml = foreach ($link in $page.directLinks) {
        $label = ConvertTo-HtmlText -Value ([string]$link.label)
        $listTitle = [string]$link.list
        $viewTitle = [string]$link.view
        $url = Get-ListViewUrl -ListTitle $listTitle -ViewTitle $viewTitle
        $encodedUrl = ConvertTo-HtmlText -Value $url
        "<li><a href=""$encodedUrl"">$label</a></li>"
    }

    return @"
<h2>$title</h2>
<p><strong>Role:</strong> $role</p>
<p>Use this as the CRM workspace, not a reference page. Start with one of the four action tiles, then move the record through the stage path only when the next decision is clear.</p>
<table style="width:100%;border-collapse:collapse;margin:10px 0 18px 0;"><tr>$($actionCardHtml -join '')</tr></table>
<h3>CRM stage path</h3>
<table style="width:100%;border-collapse:collapse;margin-bottom:18px;">$($stagePathHtml -join '')</table>
<table style="width:100%;border-collapse:collapse;">
  <tr>
    <td style="width:50%;vertical-align:top;padding-right:12px;">
      <h3>Today</h3>
      <ul>
        <li><a href="$(ConvertTo-HtmlText -Value $pipelineUrl)">Pipeline by Stage</a></li>
        <li><a href="$(ConvertTo-HtmlText -Value $deliveryUrl)">Delivery Control</a></li>
        <li><a href="$(ConvertTo-HtmlText -Value $evidenceUrl)">Handoff Evidence</a></li>
      </ul>
    </td>
    <td style="width:50%;vertical-align:top;padding-left:12px;">
      <h3>More queues</h3>
      <ul>$($linkHtml -join '')</ul>
    </td>
  </tr>
</table>
<p><em>Generated from the Stage 8C CRM operator workflow config. This page does not create permissions, guests, sharing, app consent, mail sends, public forms, item deletions, Dynamics, Dataverse, or unattended automation.</em></p>
"@
}

function New-IntakeFormFormatterJson {
    param([object]$IntakeExperience)

    $sections = foreach ($section in $IntakeExperience.formSections) {
        [ordered]@{
            displayname = [string]$section.displayName
            fields = @($section.fields | ForEach-Object { [string]$_ })
        }
    }

    $fieldSettings = foreach ($fieldName in $IntakeExperience.readOnlySystemFields) {
        [ordered]@{
            name = [string]$fieldName
            readonly = $true
        }
    }

    $formatter = [ordered]@{
        sections = @($sections)
        fieldsettings = @($fieldSettings)
    }

    return ($formatter | ConvertTo-Json -Depth 8)
}

function Set-IntakeFieldExperience {
    param([object]$IntakeExperience)

    $listTitle = [string]$IntakeExperience.list
    Write-Host ("Configuring frictionless intake form: {0}" -f $listTitle) -ForegroundColor Cyan

    foreach ($field in $IntakeExperience.friendlyFieldNames) {
        try {
            Set-PnPField -List $listTitle -Identity ([string]$field.internalName) -Values @{ Title = [string]$field.displayName } | Out-Null
            Write-Host ("  [OK] Field label: {0} -> {1}" -f $field.internalName, $field.displayName) -ForegroundColor Green
        }
        catch {
            Write-Host ("  [warn] Could not set field label {0}: {1}" -f $field.internalName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    foreach ($fieldName in $IntakeExperience.notRequiredFields) {
        try {
            Set-PnPField -List $listTitle -Identity ([string]$fieldName) -Values @{ Required = $false } | Out-Null
            Write-Host ("  [OK] Field no longer blocks manual intake: {0}" -f $fieldName) -ForegroundColor Green
        }
        catch {
            Write-Host ("  [warn] Could not relax required flag for {0}: {1}" -f $fieldName, $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    $formatterJson = New-IntakeFormFormatterJson -IntakeExperience $IntakeExperience
    $clientContext = Get-PnPContext
    $contentType = Get-PnPContentType -List $listTitle | Where-Object { $_.Name -eq [string]$IntakeExperience.contentTypeName } | Select-Object -First 1
    if ($null -eq $contentType) {
        throw "Could not find content type '$($IntakeExperience.contentTypeName)' on list '$listTitle'."
    }

    $clientContext.Load($contentType)
    $clientContext.ExecuteQuery()
    $wasReadOnly = [bool]$contentType.ReadOnly
    if ($wasReadOnly) {
        $contentType.ReadOnly = $false
        $contentType.Update($false)
        $clientContext.ExecuteQuery()
    }

    $contentType.ClientFormCustomFormatter = $formatterJson
    $contentType.Update($false)
    $clientContext.ExecuteQuery()

    if ($wasReadOnly) {
        $contentType.ReadOnly = $true
        $contentType.Update($false)
        $clientContext.ExecuteQuery()
    }

    Write-Host "  [OK] Intake form layout applied" -ForegroundColor Green
}

function Set-CommandCenterPageHtml {
    param(
        [string]$PageFileName,
        [string]$Title,
        [string]$Html
    )

    $components = @()
    try {
        $components = @(Get-PnPPageComponent -Page $PageFileName -ErrorAction SilentlyContinue)
    }
    catch {
        $components = @()
    }

    $matchingComponent = @($components | Where-Object {
        [string]$_.Type -like "*PageText*" -or [string]$_.ControlType -eq "4"
    } | Select-Object -First 1)

    if ($matchingComponent.Count -gt 0) {
        try {
            Set-PnPPageTextPart -Page $PageFileName -InstanceId ([guid]$matchingComponent[0].InstanceId) -Text $Html | Out-Null
            Set-PnPPage -Identity $PageFileName -Title $Title -Publish | Out-Null
            Write-Host ("  [OK] Command center text refreshed: {0}" -f $PageFileName) -ForegroundColor Green
            return
        }
        catch {
            Write-Host ("  [warn] Could not update existing text part; adding a fresh stage-path text part: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    try {
        Add-PnPPageTextPart -Page $PageFileName -Section 1 -Column 1 -Order 1 -Text $Html | Out-Null
    }
    catch {
        Add-PnPPageSection -Page $PageFileName -SectionTemplate OneColumn -Order 1 | Out-Null
        Add-PnPPageTextPart -Page $PageFileName -Section 1 -Column 1 -Order 1 -Text $Html | Out-Null
    }

    Set-PnPPage -Identity $PageFileName -Title $Title -Publish | Out-Null
    Write-Host ("  [OK] Command center stage-path text added: {0}" -f $PageFileName) -ForegroundColor Green
}

function Resolve-NavigationUrl {
    param(
        [object]$Config,
        [object]$Target
    )

    $kind = [string]$Target.kind
    $value = [string]$Target.target

    switch ($kind) {
        "Page" {
            $page = @($Config.pages | Where-Object { [string]$_.title -eq $value } | Select-Object -First 1)
            if ($page.Count -eq 0) {
                throw "Navigation target page is not defined in config: $value"
            }
            return Get-SiteRelativeUrl -SiteUrl ([string]$Config.site.url) -Target ("SitePages/{0}" -f $page[0].fileName)
        }
        "List" {
            return Get-ListUrl -Title $value
        }
        default {
            throw "Unknown navigation target kind: $kind"
        }
    }
}

$resolvedConfigPath = Resolve-WorkspacePath -Path $ConfigPath
if (-not (Test-Path -LiteralPath $resolvedConfigPath)) {
    throw "Config file not found: $resolvedConfigPath"
}

$config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
}
catch {
    Write-Host ("[warn] Could not start transcript: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host "Microsoft 365 Stage 8C - Relationship CRM Operator Workflow" -ForegroundColor Cyan
Write-Host "Mode:       $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })" -ForegroundColor Yellow
Write-Host "Site:       $($config.site.url)" -ForegroundColor Gray
Write-Host "Config:     $resolvedConfigPath" -ForegroundColor Gray
Write-Host "Transcript: $transcriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Planned workflow additions:" -ForegroundColor Cyan
Write-Host ("- New operator lists: {0}" -f @($config.lists).Count) -ForegroundColor White
Write-Host ("- Workflow lookup fields: {0}" -f ((@($config.lists | ForEach-Object { @($_.lookupFields).Count }) | Measure-Object -Sum).Sum)) -ForegroundColor White
Write-Host ("- Workflow views: {0}" -f ((@($config.lists | ForEach-Object { @($_.views).Count }) | Measure-Object -Sum).Sum)) -ForegroundColor White
Write-Host ("- Command center page: {0}" -f $config.pages[0].fileName) -ForegroundColor White
if (Test-JsonProperty -Object $config -Name "intakeExperience") {
    Write-Host ("- Frictionless intake form: {0}" -f $config.intakeExperience.list) -ForegroundColor White
}
Write-Host ""
Write-Host "Safety limits:" -ForegroundColor Yellow
foreach ($limit in $config.safetyLimits) {
    Write-Host ("- {0}" -f $limit) -ForegroundColor Yellow
}
Write-Host ""

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply and type the approval phrase to build Stage 8C." -ForegroundColor Green
    try { Stop-Transcript | Out-Null } catch {}
    if (-not $NoPause) {
        Write-Host ""
        Write-Host "Press Enter to close this window."
        Read-Host | Out-Null
    }
    exit 0
}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available in this PowerShell host. Re-run through scripts\Start-M365Stage8CRelationshipCrmOperatorWorkflowInteractive.ps1."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$approvalPhrase = [string]$config.approvalPhrase
$approval = Read-Host "Type '$approvalPhrase' to add Stage 8C CRM workflow lists, fields, views, page, and navigation"
if ($approval -ne $approvalPhrase) {
    Write-Host "Approval phrase did not match. Nothing was changed." -ForegroundColor Yellow
    try { Stop-Transcript | Out-Null } catch {}
    if (-not $NoPause) {
        Write-Host ""
        Write-Host "Press Enter to close this window."
        Read-Host | Out-Null
    }
    exit 0
}

Write-Host ""
Write-Host "Connecting to Guided AI Labs SharePoint site..." -ForegroundColor Cyan
$connectParams = @{
    Url = [string]$config.site.url
    ClientId = $ClientId
    Interactive = $true
    PersistLogin = $true
}
if ($ForceFreshLogin) {
    $connectParams.ForceAuthentication = $true
}
Connect-PnPOnline @connectParams

Write-Host ""
Write-Host "Creating CRM operator workflow lists..." -ForegroundColor Cyan
foreach ($list in $config.lists) {
    Ensure-Stage8CList -List $list
}

foreach ($list in $config.lists) {
    Write-Host ""
    Write-Host ("Configuring workflow list: {0}" -f $list.title) -ForegroundColor Cyan
    foreach ($column in $list.columns) {
        Add-Stage8CField -ListTitle ([string]$list.title) -Column $column
    }

    foreach ($lookup in $list.lookupFields) {
        Add-Stage8CLookupField -ListTitle ([string]$list.title) -Lookup $lookup
    }

    foreach ($view in $list.views) {
        Set-Stage8CView -ListTitle ([string]$list.title) -View $view
    }
}

if (Test-JsonProperty -Object $config -Name "intakeExperience") {
    Write-Host ""
    Set-IntakeFieldExperience -IntakeExperience $config.intakeExperience
}

foreach ($page in $config.pages) {
    $existingPage = $null
    try {
        $existingPage = Get-PnPPage -Identity ([string]$page.fileName) -ErrorAction Stop
    }
    catch {
        $existingPage = $null
    }

    if ($null -ne $existingPage) {
        Write-Host ("Refreshing command center page content: {0}" -f $page.fileName) -ForegroundColor Cyan
        Set-CommandCenterPageHtml -PageFileName ([string]$page.fileName) -Title ([string]$page.title) -Html (New-CommandCenterPageHtml -Config $config)
        continue
    }

    Write-Host ("Creating command center page: {0}" -f $page.fileName) -ForegroundColor Cyan
    Add-PnPPage -Name ([string]$page.fileName) -LayoutType Article -HeaderLayoutType NoImage -CommentsEnabled:$false | Out-Null
    Add-PnPPageSection -Page ([string]$page.fileName) -SectionTemplate OneColumn -Order 1 | Out-Null
    Add-PnPPageTextPart -Page ([string]$page.fileName) -Section 1 -Column 1 -Order 1 -Text (New-CommandCenterPageHtml -Config $config) | Out-Null
    Set-PnPPage -Identity ([string]$page.fileName) -Title ([string]$page.title) -Publish | Out-Null
    Write-Host ("  [OK] {0}" -f $page.title) -ForegroundColor Green
}

$topNodes = @(Get-PnPNavigationNode -Location QuickLaunch)
foreach ($target in $config.navigationTargets) {
    $groupTitle = [string]$target.group
    $linkTitle = [string]$target.link
    $url = Resolve-NavigationUrl -Config $config -Target $target

    $groupNode = @($topNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1)
    if ($groupNode.Count -eq 0) {
        Write-Host ("Creating navigation group: {0}" -f $groupTitle) -ForegroundColor Cyan
        $groupNode = Add-PnPNavigationNode -Location QuickLaunch -Title $groupTitle -Url ([string]$config.site.url)
        $topNodes += $groupNode
    }
    else {
        $groupNode = $groupNode[0]
    }

    $nodeWithChildren = Get-PnPNavigationNode -Id $groupNode.Id -ErrorAction SilentlyContinue
    $existingChildren = @()
    if ($null -ne $nodeWithChildren -and $null -ne $nodeWithChildren.Children) {
        $existingChildren = @($nodeWithChildren.Children)
    }

    $existingLink = @($existingChildren | Where-Object { $_.Title -eq $linkTitle } | Select-Object -First 1)
    if ($existingLink.Count -gt 0) {
        Write-Host ("Navigation link exists; leaving unchanged: {0} / {1}" -f $groupTitle, $linkTitle) -ForegroundColor Yellow
        continue
    }

    Write-Host ("Adding navigation link: {0} / {1} -> {2}" -f $groupTitle, $linkTitle, $url) -ForegroundColor Cyan
    Add-PnPNavigationNode -Location QuickLaunch -Title $linkTitle -Url $url -Parent $groupNode | Out-Null
    Write-Host ("  [OK] {0}" -f $linkTitle) -ForegroundColor Green
}

try { Disconnect-PnPOnline | Out-Null } catch {}

Write-Host ""
Write-Host "Stage 8C Relationship CRM operator workflow apply complete. Run read-only verification next." -ForegroundColor Green

try { Stop-Transcript | Out-Null } catch {}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Press Enter to close this window."
    Read-Host | Out-Null
}
