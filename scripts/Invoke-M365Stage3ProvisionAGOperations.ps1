param(
    [string]$ClientId   = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$AdminUrl    = "https://agoperationsltd-admin.sharepoint.com",
    [string]$SiteUrl     = "https://agoperationsltd.sharepoint.com/sites/AGOperations",
    [string]$SiteTitle   = "AG Operations"
)

# Stage 3 - SharePoint Information Architecture : provision the AG Operations PILOT.
# This is the pilot from the agreed design (decisions 3.1-3.6b). It creates ONE
# Communication site with the Hybrid library/folder layout + the 3.2b metadata
# columns. You sign in interactively (your MFA) as adamgoodwin@; every write runs as
# you. A typed-'yes' gate sits before any creation, and the script reads the result
# back at the end.
#
# Reversible: a newly created site can be deleted in the SharePoint admin center
# (recycle bin) - it touches no existing content.
#
# Plan + decisions + execution log: M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md

$ErrorActionPreference = "Stop"

# ---- The pilot structure (Hybrid: few libraries, shallow folders) ----
$Libraries = [ordered]@{
    "Governance_Records" = @("00_Admin", "01_Corporate_Records", "06_Tenant_Governance", "07_Master_Strategy", "08_Decision_Logs")
    "Finance_Legal"      = @("02_Finance_Tax", "03_Legal_Contracts", "04_Insurance_Risk", "05_Banking_Vendors")
    "Archive"            = @("09_Archive")
}

# ---- The 3.2b metadata schema (applied to every library) ----
$Columns = @(
    @{ Display = "Record Type"; Internal = "RecordType"; Type = "Choice"; Choices = @("Contract", "Invoice", "Method", "Deliverable", "Decision", "Asset", "Policy", "Note"); Default = $null }
    @{ Display = "Brand";       Internal = "Brand";      Type = "Choice"; Choices = @("AG Operations", "Guided AI Labs", "Guided AI Journey", "Change Leadership Tools", "Shared"); Default = "AG Operations" }
    @{ Display = "Client";      Internal = "ClientName"; Type = "Text";   Choices = $null; Default = $null }
    @{ Display = "Status";      Internal = "RecordStatus"; Type = "Choice"; Choices = @("Draft", "Active", "Final", "Superseded", "Archived"); Default = "Active" }
    @{ Display = "Classification"; Internal = "Classification"; Type = "Choice"; Choices = @("Internal", "Confidential", "Client-Owned", "Public"); Default = "Confidential" }
)

function Write-Section { param([string]$m) Write-Host ""; Write-Host "== $m ==" -ForegroundColor Cyan }

Write-Host "Microsoft 365 Stage 3 - Provision AG Operations (PILOT)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Site to create : $SiteTitle" -ForegroundColor White
Write-Host "URL            : $SiteUrl" -ForegroundColor White
Write-Host "Type           : Communication site (groupless), external sharing OFF" -ForegroundColor White
Write-Host "Libraries      : $($Libraries.Keys -join ', ')" -ForegroundColor White
Write-Host "Columns        : $($Columns.Display -join ', ')" -ForegroundColor White
Write-Host ""

# ---- Connect to the SharePoint admin endpoint (you sign in) ----
Write-Section "Sign in"
Write-Host "A browser will open. Sign in as adamgoodwin@guidedailabs.com." -ForegroundColor Yellow
Connect-PnPOnline -Url $AdminUrl -ClientId $ClientId -Interactive
Write-Host "Connected to admin endpoint." -ForegroundColor Green

# ---- Safety check: does the target site already exist? ----
Write-Section "Pre-flight check"
$existing = Get-PnPTenantSite -Identity $SiteUrl -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    Write-Host "A site already exists at $SiteUrl :" -ForegroundColor Red
    Write-Host ("    {0}  (status: {1})" -f $existing.Title, $existing.Status) -ForegroundColor Red
    Write-Host "Aborting so nothing is overwritten. Remove/rename it first if this is intended." -ForegroundColor Red
    exit 1
}
Write-Host "No site at that URL yet - safe to create." -ForegroundColor Green

# ---- Typed confirmation gate (first SharePoint write) ----
Write-Host ""
$confirm = Read-Host "Type 'yes' to create the AG Operations pilot site now (anything else aborts)"
if ($confirm -ne "yes") {
    Write-Host "Aborted. Nothing was created." -ForegroundColor Yellow
    exit 0
}

# ---- Create the Communication site ----
Write-Section "Creating site"
New-PnPSite -Type CommunicationSite -Title $SiteTitle -Url $SiteUrl -Wait | Out-Null
Write-Host "[OK] Communication site created: $SiteUrl" -ForegroundColor Green

# ---- Enforce external sharing OFF on this site (decision 3.4) ----
try {
    Set-PnPTenantSite -Identity $SiteUrl -SharingCapability Disabled -ErrorAction Stop
    Write-Host "[OK] External sharing set to Disabled on this site." -ForegroundColor Green
}
catch {
    Write-Host "[warn] Could not set SharingCapability automatically: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "       Set it manually in the SharePoint admin center if needed." -ForegroundColor Yellow
}

# ---- Reconnect to the new site for content creation ----
Write-Section "Building structure"
Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive

foreach ($lib in $Libraries.Keys) {
    # Create the document library if it doesn't already exist
    $list = Get-PnPList -Identity $lib -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        New-PnPList -Title $lib -Template DocumentLibrary -OnQuickLaunch | Out-Null
        Write-Host ("[OK] Library created: {0}" -f $lib) -ForegroundColor Green
    }
    else {
        Write-Host ("[skip] Library already exists: {0}" -f $lib) -ForegroundColor Gray
    }

    # Add the metadata columns to this library
    foreach ($c in $Columns) {
        $exists = Get-PnPField -List $lib -Identity $c.Internal -ErrorAction SilentlyContinue
        if ($null -eq $exists) {
            if ($c.Type -eq "Choice") {
                Add-PnPField -List $lib -DisplayName $c.Display -InternalName $c.Internal -Type Choice -Choices $c.Choices -AddToDefaultView | Out-Null
            }
            else {
                Add-PnPField -List $lib -DisplayName $c.Display -InternalName $c.Internal -Type $c.Type -AddToDefaultView | Out-Null
            }
            if ($null -ne $c.Default) {
                Set-PnPField -List $lib -Identity $c.Internal -Values @{ DefaultValue = $c.Default } | Out-Null
            }
        }
    }
    Write-Host ("       columns ensured: {0}" -f ($Columns.Display -join ', ')) -ForegroundColor Gray

    # Create the folders inside this library
    foreach ($folder in $Libraries[$lib]) {
        Add-PnPFolder -Name $folder -Folder $lib -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host ("       folders ensured: {0}" -f ($Libraries[$lib] -join ', ')) -ForegroundColor Gray
}

# ---- Read back the result ----
Write-Section "Read-back verification"
Write-Host "Site: $SiteTitle ($SiteUrl)" -ForegroundColor White
foreach ($lib in $Libraries.Keys) {
    Write-Host ("- Library: {0}" -f $lib) -ForegroundColor White
    $folders = Get-PnPFolderItem -FolderSiteRelativeUrl $lib -ItemType Folder -ErrorAction SilentlyContinue | Sort-Object Name
    Write-Host ("    folders: {0}" -f (($folders.Name) -join ', ')) -ForegroundColor Gray
    $fields = Get-PnPField -List $lib | Where-Object { $_.InternalName -in $Columns.Internal } | Sort-Object Title
    Write-Host ("    columns: {0}" -f (($fields.Title) -join ', ')) -ForegroundColor Gray
}

Write-Section "Done"
Write-Host "AG Operations pilot provisioned. Review it in the browser, then we template" -ForegroundColor Green
Write-Host "the remaining four sites. Record this run in the Stage 3 §8 execution log." -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
