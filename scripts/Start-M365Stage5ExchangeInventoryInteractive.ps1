param(
    [string]$AdminUpn = "adamgoodwin@guidedailabs.com",
    [switch]$UseDeviceCode
)

# Launches Stage 5 Exchange inventory in a visible PowerShell window so Adam can
# complete Microsoft sign-in/MFA directly. The launched window runs the local
# summarizer after a successful inventory.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$inventoryScript = Join-Path $scriptRoot "Invoke-M365Stage5ExchangeInventory.ps1"
$summaryScript = Join-Path $scriptRoot "Summarize-M365Stage5ExchangeInventory.ps1"

if (-not (Test-Path -LiteralPath $inventoryScript)) {
    throw "Inventory script not found: $inventoryScript"
}

if (-not (Test-Path -LiteralPath $summaryScript)) {
    throw "Summary script not found: $summaryScript"
}

$authArgs = if ($UseDeviceCode) {
    "-AdminUpn '$AdminUpn'"
}
else {
    "-AdminUpn '$AdminUpn' -UseWam"
}

$authLabel = if ($UseDeviceCode) {
    "device-code authentication"
}
else {
    "interactive popup/WAM authentication"
}

$command = @"
Set-Location -LiteralPath '$repoRoot'
`$ErrorActionPreference = 'Stop'
Write-Host 'Stage 5 Exchange inventory - visible authorization window' -ForegroundColor Cyan
Write-Host 'Auth mode: $authLabel' -ForegroundColor Yellow
Write-Host ''
try {
    & '$inventoryScript' $authArgs
    Write-Host ''
    Write-Host 'Generating local Markdown summary...' -ForegroundColor Cyan
    & '$summaryScript'
    Write-Host ''
    Write-Host 'Stage 5 inventory + summary complete.' -ForegroundColor Green
}
catch {
    Write-Host ''
    Write-Host 'Stage 5 interactive run stopped:' -ForegroundColor Red
    Write-Host `$_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'No Exchange writes were attempted by this inventory flow.' -ForegroundColor Yellow
}
finally {
    Write-Host ''
    Read-Host 'Press Enter to close this window'
}
"@

$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
$process = Start-Process -FilePath "pwsh.exe" `
    -ArgumentList @("-NoProfile", "-NoExit", "-EncodedCommand", $encoded) `
    -WorkingDirectory $repoRoot `
    -WindowStyle Normal `
    -PassThru

Write-Host "Started visible Stage 5 inventory window: $($process.Id)"
