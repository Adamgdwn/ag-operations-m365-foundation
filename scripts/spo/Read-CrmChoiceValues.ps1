param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$SiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs",
    [string]$ListTitle = "CRM - New Signals",
    [switch]$ForceFreshLogin
)

# READ ONLY. Dumps the allowed Choice values for the columns the Path B intake
# flow must stamp, so V7 can be built without a mid-session surprise. Writes
# nothing to the tenant.

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is not available."
}
Import-Module PnP.PowerShell -ErrorAction Stop

$connectParams = @{ Url = $SiteUrl; ClientId = $ClientId; Interactive = $true; PersistLogin = $true }
if ($ForceFreshLogin) { $connectParams.ForceAuthentication = $true }
Connect-PnPOnline @connectParams

# Constants the Path B flow will set (must be allowed choices, except free-text
# IntakeSource which is a Choice that must include the two brand values).
$expected = @{
    "SignalType"   = @("Website")
    "IntakeSource" = @("Guided AI Labs", "Guided AI Journey")
    "SignalStatus" = @("New")
    "Priority"     = @("Normal")
}

Write-Host "=== CRM - New Signals : Choice column values (READ ONLY) ==="
foreach ($fieldName in $expected.Keys) {
    $field = Get-PnPField -List $ListTitle -Identity $fieldName -ErrorAction SilentlyContinue
    if ($null -eq $field) {
        Write-Host ("[MISSING FIELD] {0}" -f $fieldName)
        continue
    }
    $choices = @()
    try { $choices = @($field.Choices) } catch { $choices = @() }
    Write-Host ""
    Write-Host ("Field: {0}  (type={1})" -f $fieldName, $field.TypeAsString)
    Write-Host ("  Allowed: {0}" -f ($(if ($choices.Count) { $choices -join " | " } else { "(none / not a choice field)" })))
    foreach ($needed in $expected[$fieldName]) {
        $present = $choices -contains $needed
        Write-Host ("  Need '{0}': {1}" -f $needed, $(if ($present) { "PRESENT" } else { "ADD REQUIRED" }))
    }
}
Write-Host ""
Write-Host "=== done ==="
Disconnect-PnPOnline
