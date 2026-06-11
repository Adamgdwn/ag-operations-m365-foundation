param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$RootUrl  = "https://agoperationsltd.sharepoint.com"
)

# Stage 3 - SharePoint Information Architecture : READ-ONLY re-inventory.
# Changes NOTHING. Signs you in (interactive, your MFA), then walks all five Stage 3
# sites and confirms each library, its folders, and the five metadata columns match
# the design. Prints a PASS/FAIL summary. This is the closure check for Stage 3,
# mirroring the Stage 2 §5.4 re-inventory.
# Plan + execution log: M365_STAGE_3_SHAREPOINT_ARCHITECTURE.md

$ErrorActionPreference = "Stop"
$wantedCols = @("RecordType", "Brand", "ClientName", "RecordStatus", "Classification")

# ---- Expected estate (the Stage 3 design) ----
$Expected = [ordered]@{
    "AG Operations|/sites/AGOperations" = [ordered]@{
        "Governance_Records" = @("00_Admin", "01_Corporate_Records", "06_Tenant_Governance", "07_Master_Strategy", "08_Decision_Logs")
        "Finance_Legal"      = @("02_Finance_Tax", "03_Legal_Contracts", "04_Insurance_Risk", "05_Banking_Vendors")
        "Archive"            = @("09_Archive")
    }
    "Guided AI Labs|/sites/GuidedAILabs" = [ordered]@{
        "Operating"         = @("00_Admin", "01_Strategy", "02_Sales_Marketing", "04_AI_Governance", "05_Automation_Workflows")
        "Client_Delivery"   = @("03_Client_Delivery")
        "Templates_Methods" = @("06_Templates_Methods", "07_Knowledge_Graph_Exports", "08_Assets")
        "Archive"           = @("09_Archive")
    }
    "Change Leadership Tools|/sites/ChangeLeadershipTools" = [ordered]@{
        "Product" = @("00_Admin", "01_Product_Strategy", "06_Supabase_Notes", "07_Website_Content", "08_Assets")
        "Support" = @("02_User_Support", "03_Tool_Downloads", "04_Account_Help", "05_Knowledge_Base")
        "Archive" = @("09_Archive")
    }
    "Shared Libraries|/sites/SharedLibraries" = [ordered]@{
        "Templates_Assets"  = @("01_Templates", "02_Brand_Assets")
        "Standards_Methods" = @("03_AI_Governance_Standards", "04_Workflow_Maps", "05_Client_Delivery_Methods", "06_Coding_Agent_Briefs")
        "Research_Logs"     = @("07_Research_References", "08_Reusable_Decision_Logs")
        "Archive"           = @("09_Archive")
    }
    "Guided AI Journey|/sites/GuidedAIJourney" = [ordered]@{
        "Method"      = @("00_Admin", "01_Product_Strategy", "02_Client_Portal_Method", "07_UX_Content", "08_Assets")
        "Engagements" = @("03_Assessments", "04_Readiness_Scans", "05_Client_Workspace_Templates", "06_Transfer_Packages")
        "Archive"     = @("09_Archive")
    }
}

Write-Host "Microsoft 365 Stage 3 - SharePoint re-inventory (READ-ONLY)" -ForegroundColor Cyan
Write-Host "This run is non-destructive. Sign in as adamgoodwin@guidedailabs.com." -ForegroundColor Yellow

$fail = 0
foreach ($siteKey in $Expected.Keys) {
    $title, $path = $siteKey.Split("|")
    $url = "$RootUrl$path"
    Write-Host ""
    Write-Host ("== {0}  ({1}) ==" -f $title, $url) -ForegroundColor Cyan

    try {
        Connect-PnPOnline -Url $url -ClientId $ClientId -Interactive
    }
    catch {
        Write-Host ("  FAIL: cannot connect to site - {0}" -f $_.Exception.Message) -ForegroundColor Red
        $fail++
        continue
    }

    foreach ($lib in $Expected[$siteKey].Keys) {
        $list = Get-PnPList -Identity $lib -ErrorAction SilentlyContinue
        if ($null -eq $list) {
            Write-Host ("  FAIL: missing library '{0}'" -f $lib) -ForegroundColor Red
            $fail++
            continue
        }

        $foundFolders = (Get-PnPFolderItem -FolderSiteRelativeUrl $lib -ItemType Folder -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "Forms" }).Name
        $missingFolders = $Expected[$siteKey][$lib] | Where-Object { $_ -notin $foundFolders }

        $foundCols = (Get-PnPField -List $lib | Where-Object { $_.InternalName -in $wantedCols }).InternalName
        $missingCols = $wantedCols | Where-Object { $_ -notin $foundCols }

        if ($missingFolders.Count -eq 0 -and $missingCols.Count -eq 0) {
            Write-Host ("  OK  {0}: {1} folders, 5 columns" -f $lib, $Expected[$siteKey][$lib].Count) -ForegroundColor Green
        }
        else {
            Write-Host ("  FAIL {0}: missing folders [{1}] missing columns [{2}]" -f $lib, ($missingFolders -join ', '), ($missingCols -join ', ')) -ForegroundColor Red
            $fail++
        }
    }
}

Write-Host ""
Write-Host "== Summary ==" -ForegroundColor Cyan
if ($fail -eq 0) {
    Write-Host "PASS - all five sites match the Stage 3 design. Stage 3 can be closed." -ForegroundColor Green
}
else {
    Write-Host ("FAIL - {0} issue(s) found above. Stage 3 not yet clean." -f $fail) -ForegroundColor Red
}
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
