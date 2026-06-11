param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SiteUrl  = "https://agoperationsltd.sharepoint.com/sites/AGOperations"
)

# Stage 3 - finish the metadata schema on the AG Operations pilot.
# Diagnosis (first run): the title "Sensitivity" is already used by built-in,
# HIDDEN Microsoft Information Protection sensitivity-label columns (_DisplayName,
# _IpLabelId, _EffectiveIpLabelDisplayName, _IpLabelAssignmentMethod,
# _IpLabelMetaInfo). Those are system columns - we must NOT touch them. So our
# 5th column is added under a collision-free name: "Classification"
# (Internal=Classification, values Internal/Confidential/Client-Owned/Public,
# default Confidential). This also future-proofs against enabling real sensitivity
# labels at Stage 7. The 4 already-created columns are untouched.
#
# This script makes NO deletions. It only ADDS the Classification column where
# missing, then reads back all five columns. Idempotent and safe to re-run.

$ErrorActionPreference = "Stop"

$libs    = @("Governance_Records", "Finance_Legal", "Archive")
$choices = @("Internal", "Confidential", "Client-Owned", "Public")
$wanted  = @("RecordType", "Brand", "ClientName", "RecordStatus", "Classification")

Write-Host "Connecting to $SiteUrl (sign in as adamgoodwin@)..." -ForegroundColor Yellow
Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive
Write-Host "Connected." -ForegroundColor Green

foreach ($lib in $libs) {
    Write-Host ""
    Write-Host "== $lib ==" -ForegroundColor Cyan

    $existing = Get-PnPField -List $lib -Identity "Classification" -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        Add-PnPField -List $lib -DisplayName "Classification" -InternalName "Classification" -Type Choice -Choices $choices -AddToDefaultView | Out-Null
        Set-PnPField -List $lib -Identity "Classification" -Values @{ DefaultValue = "Confidential" } | Out-Null
        Write-Host "  created 'Classification' (default Confidential)" -ForegroundColor Green
    }
    else {
        Write-Host "  'Classification' already present - nothing to do" -ForegroundColor Gray
    }

    # Best-effort: keep the built-in empty 'Sensitivity' (MIP) column out of the
    # default view so it doesn't sit confusingly next to Classification. Never fatal.
    try {
        $view = Get-PnPView -List $lib | Where-Object { $_.DefaultView } | Select-Object -First 1
        if ($view) {
            $vf = Get-PnPProperty -ClientObject $view -Property ViewFields
            if ($vf -contains "_DisplayName") {
                $view.ViewFields.Remove("_DisplayName") | Out-Null
                $view.Update()
                Invoke-PnPQuery
                Write-Host "  (tidied built-in 'Sensitivity' out of the default view)" -ForegroundColor DarkGray
            }
        }
    }
    catch { }

    $cols = Get-PnPField -List $lib | Where-Object { $_.InternalName -in $wanted } | Sort-Object Title
    Write-Host ("  columns now ({0}): {1}" -f $cols.Count, (($cols.Title) -join ', ')) -ForegroundColor White
}

Write-Host ""
Write-Host "Done. Each library should report 5 columns: Brand, Classification, Client," -ForegroundColor Green
Write-Host "Record Type, Status." -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to close this window."
Read-Host | Out-Null
