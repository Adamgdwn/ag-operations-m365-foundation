param(
    [switch]$NoClear
)

# AG Operations - daily routines menu.
# A double-clickable launcher (via the desktop shortcut) for the key daily
# operating routines. Each routine opens in its own visible window and follows
# the existing dry-run-first / typed-approval safety model. This menu performs
# no tenant write itself.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot
$guidedSiteUrl = "https://agoperationsltd.sharepoint.com/sites/GuidedAILabs"
$digestFolder = Join-Path $workspaceRoot "inventory\coordinator-daily-read"

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

function Invoke-Routine {
    param([string]$ScriptName, [switch]$Apply)
    $target = Join-Path $scriptRoot $ScriptName
    if (-not (Test-Path -LiteralPath $target)) {
        Write-Host ("Routine script not found: {0}" -f $target) -ForegroundColor Red
        return
    }
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $target)
    if ($Apply) { $argList += "-Apply" }
    Start-Process -FilePath $powerShellHost.Source -ArgumentList $argList -WorkingDirectory $workspaceRoot
    Write-Host "  Launched in a new window. Complete any sign-in there." -ForegroundColor Green
}

function Show-Menu {
    if (-not $NoClear) { Clear-Host }
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "  AG Operations - Daily Routines" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1.  Coordinator daily read  - DRY RUN (read + digest, no writes)" -ForegroundColor White
    Write-Host "  2.  Coordinator daily read  - RECORD suggestion (-Apply, single Y approval)" -ForegroundColor White
    Write-Host "  3.  Open the daily-read digest folder" -ForegroundColor White
    Write-Host "  4.  Open the Guided AI Labs workspace in the browser" -ForegroundColor White
    Write-Host ""
    Write-Host "  0.  Exit" -ForegroundColor Gray
    Write-Host ""
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Choose"
    switch ($choice) {
        "1" {
            Write-Host "Starting Coordinator daily read (dry run)..." -ForegroundColor Cyan
            Invoke-Routine -ScriptName "Start-M365CoordinatorDailyReadInteractive.ps1"
        }
        "2" {
            Write-Host "Starting Coordinator daily read (apply)..." -ForegroundColor Yellow
            Write-Host "In the new window: sign in if prompted, review the findings, then press Y to approve the single record." -ForegroundColor Yellow
            Invoke-Routine -ScriptName "Start-M365CoordinatorDailyReadInteractive.ps1" -Apply
        }
        "3" {
            if (-not (Test-Path -LiteralPath $digestFolder)) {
                New-Item -ItemType Directory -Path $digestFolder -Force | Out-Null
            }
            Invoke-Item -LiteralPath $digestFolder
            Write-Host "  Opened the digest folder." -ForegroundColor Green
        }
        "4" {
            Start-Process $guidedSiteUrl
            Write-Host "  Opened the workspace in your browser." -ForegroundColor Green
        }
        "0" { break }
        default { Write-Host "  Unrecognised choice." -ForegroundColor Yellow }
    }
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "Press Enter to return to the menu"
    }
}
