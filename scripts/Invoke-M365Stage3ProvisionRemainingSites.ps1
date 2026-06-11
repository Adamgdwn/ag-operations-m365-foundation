param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$AdminUrl = "https://agoperationsltd-admin.sharepoint.com",
    [string]$RootUrl  = "https://agoperationsltd.sharepoint.com"
)

# Stage 3 - provision the remaining FOUR sites from the verified pilot template.
# Guided AI Labs + Change Leadership Tools = group-connected Team sites; Shared
# Libraries + Guided AI Journey = Communication sites (decision 3.2c). Each gets the
# Hybrid library/folder layout + the 3.2b metadata columns (with the Sensitivity ->
# Classification fix already baked in). You sign in interactively; one typed-'yes'
# gate covers the batch; every site is read back. Idempotent: existing sites/columns/
# folders are skipped. Reversible: delete any new site via the SP admin recycle bin.
#
# Plan + decisions + execution log: M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md

$ErrorActionPreference = "Stop"

function Write-Section { param([string]$m) Write-Host ""; Write-Host "== $m ==" -ForegroundColor Cyan }

# ---- Column schema (Brand default is set per-site) ----
function Set-StandardColumns {
    param([string]$Lib, [string]$BrandDefault)
    $defs = @(
        @{ D = "Record Type";   I = "RecordType";    T = "Choice"; C = @("Contract", "Invoice", "Method", "Deliverable", "Decision", "Asset", "Policy", "Note"); Def = $null }
        @{ D = "Brand";         I = "Brand";         T = "Choice"; C = @("AG Operations", "Guided AI Labs", "Guided AI Journey", "Change Leadership Tools", "Shared"); Def = $BrandDefault }
        @{ D = "Client";        I = "ClientName";    T = "Text";   C = $null; Def = $null }
        @{ D = "Status";        I = "RecordStatus";  T = "Choice"; C = @("Draft", "Active", "Final", "Superseded", "Archived"); Def = "Active" }
        @{ D = "Classification"; I = "Classification"; T = "Choice"; C = @("Internal", "Confidential", "Client-Owned", "Public"); Def = "Confidential" }
    )
    foreach ($c in $defs) {
        if ($null -eq (Get-PnPField -List $Lib -Identity $c.I -ErrorAction SilentlyContinue)) {
            if ($c.T -eq "Choice") {
                Add-PnPField -List $Lib -DisplayName $c.D -InternalName $c.I -Type Choice -Choices $c.C -AddToDefaultView | Out-Null
            }
            else {
                Add-PnPField -List $Lib -DisplayName $c.D -InternalName $c.I -Type $c.T -AddToDefaultView | Out-Null
            }
            if ($null -ne $c.Def) { Set-PnPField -List $Lib -Identity $c.I -Values @{ DefaultValue = $c.Def } | Out-Null }
        }
    }
}

# ---- Site definitions (Hybrid clustering per decision 3.2 + brief s8) ----
$Sites = @(
    @{
        Title = "Guided AI Labs"; Type = "TeamSite"; Alias = "GuidedAILabs"
        Url = "$RootUrl/sites/GuidedAILabs"; Brand = "Guided AI Labs"
        Libraries = [ordered]@{
            "Operating"         = @("00_Admin", "01_Strategy", "02_Sales_Marketing", "04_AI_Governance", "05_Automation_Workflows")
            "Client_Delivery"   = @("03_Client_Delivery")
            "Templates_Methods" = @("06_Templates_Methods", "07_Knowledge_Graph_Exports", "08_Assets")
            "Archive"           = @("09_Archive")
        }
    },
    @{
        Title = "Change Leadership Tools"; Type = "TeamSite"; Alias = "ChangeLeadershipTools"
        Url = "$RootUrl/sites/ChangeLeadershipTools"; Brand = "Change Leadership Tools"
        Libraries = [ordered]@{
            "Product" = @("00_Admin", "01_Product_Strategy", "06_Supabase_Notes", "07_Website_Content", "08_Assets")
            "Support" = @("02_User_Support", "03_Tool_Downloads", "04_Account_Help", "05_Knowledge_Base")
            "Archive" = @("09_Archive")
        }
    },
    @{
        Title = "Shared Libraries"; Type = "CommunicationSite"; Alias = $null
        Url = "$RootUrl/sites/SharedLibraries"; Brand = "Shared"
        Libraries = [ordered]@{
            "Templates_Assets"  = @("01_Templates", "02_Brand_Assets")
            "Standards_Methods" = @("03_AI_Governance_Standards", "04_Workflow_Maps", "05_Client_Delivery_Methods", "06_Coding_Agent_Briefs")
            "Research_Logs"     = @("07_Research_References", "08_Reusable_Decision_Logs")
            "Archive"           = @("09_Archive")
        }
    },
    @{
        Title = "Guided AI Journey"; Type = "CommunicationSite"; Alias = $null
        Url = "$RootUrl/sites/GuidedAIJourney"; Brand = "Guided AI Journey"
        Libraries = [ordered]@{
            "Method"      = @("00_Admin", "01_Product_Strategy", "02_Client_Portal_Method", "07_UX_Content", "08_Assets")
            "Engagements" = @("03_Assessments", "04_Readiness_Scans", "05_Client_Workspace_Templates", "06_Transfer_Packages")
            "Archive"     = @("09_Archive")
        }
    }
)

Write-Host "Microsoft 365 Stage 3 - Provision remaining four sites" -ForegroundColor Cyan
Write-Host ""
foreach ($s in $Sites) {
    Write-Host ("- {0}  [{1}]  {2}" -f $s.Title, $s.Type, $s.Url) -ForegroundColor White
    Write-Host ("    libraries: {0}" -f ($s.Libraries.Keys -join ', ')) -ForegroundColor Gray
}

# ---- Sign in (admin endpoint) ----
Write-Section "Sign in"
Write-Host "A browser will open. Sign in as adamgoodwin@guidedailabs.com." -ForegroundColor Yellow
Connect-PnPOnline -Url $AdminUrl -ClientId $ClientId -Interactive
Write-Host "Connected to admin endpoint." -ForegroundColor Green

# ---- Pre-flight: which sites already exist? ----
Write-Section "Pre-flight check"
foreach ($s in $Sites) {
    $exists = Get-PnPTenantSite -Identity $s.Url -ErrorAction SilentlyContinue
    $s.Exists = ($null -ne $exists)
    if ($s.Exists) { Write-Host ("  EXISTS (will skip create): {0}" -f $s.Url) -ForegroundColor Yellow }
    else { Write-Host ("  new: {0}" -f $s.Url) -ForegroundColor Green }
}

# ---- Typed confirmation gate (batch) ----
Write-Host ""
$confirm = Read-Host "Type 'yes' to provision the sites above now (anything else aborts)"
if ($confirm -ne "yes") {
    Write-Host "Aborted. Nothing was created." -ForegroundColor Yellow
    exit 0
}

# ---- Provision each site ----
foreach ($s in $Sites) {
    Write-Section ("Site: {0}" -f $s.Title)

    # Ensure we are on the admin endpoint for tenant-level operations
    Connect-PnPOnline -Url $AdminUrl -ClientId $ClientId -Interactive

    $siteUrl = $s.Url
    if (-not $s.Exists) {
        if ($s.Type -eq "TeamSite") {
            $siteUrl = New-PnPSite -Type TeamSite -Title $s.Title -Alias $s.Alias -Wait
        }
        else {
            $siteUrl = New-PnPSite -Type CommunicationSite -Title $s.Title -Url $s.Url -Wait
        }
        Write-Host ("[OK] {0} created: {1}" -f $s.Type, $siteUrl) -ForegroundColor Green

        try {
            Set-PnPTenantSite -Identity $siteUrl -SharingCapability Disabled -ErrorAction Stop
            Write-Host "[OK] External sharing Disabled." -ForegroundColor Green
        }
        catch {
            Write-Host "[warn] Could not set SharingCapability: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[skip] Site already exists - ensuring structure only." -ForegroundColor Gray
    }

    # Build structure on the site
    Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -Interactive
    foreach ($lib in $s.Libraries.Keys) {
        if ($null -eq (Get-PnPList -Identity $lib -ErrorAction SilentlyContinue)) {
            New-PnPList -Title $lib -Template DocumentLibrary -OnQuickLaunch | Out-Null
            Write-Host ("[OK] Library: {0}" -f $lib) -ForegroundColor Green
        }
        else {
            Write-Host ("[skip] Library exists: {0}" -f $lib) -ForegroundColor Gray
        }
        Set-StandardColumns -Lib $lib -BrandDefault $s.Brand
        foreach ($folder in $s.Libraries[$lib]) {
            Add-PnPFolder -Name $folder -Folder $lib -ErrorAction SilentlyContinue | Out-Null
        }
    }

    # Read back
    Write-Host "Read-back:" -ForegroundColor White
    foreach ($lib in $s.Libraries.Keys) {
        $folders = Get-PnPFolderItem -FolderSiteRelativeUrl $lib -ItemType Folder -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "Forms" } | Sort-Object Name
        $cols = Get-PnPField -List $lib | Where-Object { $_.InternalName -in @("RecordType", "Brand", "ClientName", "RecordStatus", "Classification") } | Sort-Object Title
        Write-Host ("  {0}: folders [{1}] | columns [{2}]" -f $lib, (($folders.Name) -join ', '), (($cols.Title) -join ', ')) -ForegroundColor Gray
    }
}

Write-Section "Done"
Write-Host "All four sites provisioned. Five sites now match the Stage 3 design." -ForegroundColor Green
Write-Host "Record this run in the Stage 3 §8 execution log, then re-inventory to close Stage 3." -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
