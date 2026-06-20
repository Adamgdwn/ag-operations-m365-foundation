param(
    [string]$ShortcutName = "AG Daily Routines",
    [switch]$Remove
)

# Creates (or removes) a Desktop shortcut that opens the daily routines menu.
# Reversible: delete the .lnk from the Desktop, or run with -Remove.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot
$menuScript = Join-Path $scriptRoot "Start-DailyRoutinesMenu.ps1"
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop ($ShortcutName + ".lnk")

if ($Remove) {
    if (Test-Path -LiteralPath $shortcutPath) {
        Remove-Item -LiteralPath $shortcutPath -Force
        Write-Host ("Removed shortcut: {0}" -f $shortcutPath) -ForegroundColor Green
    }
    else {
        Write-Host ("No shortcut found at: {0}" -f $shortcutPath) -ForegroundColor Yellow
    }
    return
}

if (-not (Test-Path -LiteralPath $menuScript)) {
    throw "Menu script not found: $menuScript"
}

$powerShellHost = (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)
if ($null -eq $powerShellHost) {
    $powerShellHost = (Get-Command "powershell.exe" -ErrorAction Stop)
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $powerShellHost.Source
$shortcut.Arguments = ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $menuScript)
$shortcut.WorkingDirectory = $workspaceRoot
$shortcut.Description = "Open the AG Operations daily routines menu"
$shortcut.WindowStyle = 1
# Use the PowerShell host icon if available.
$shortcut.IconLocation = ("{0},0" -f $powerShellHost.Source)
$shortcut.Save()

Write-Host ("Created shortcut: {0}" -f $shortcutPath) -ForegroundColor Green
Write-Host ("  Target: {0}" -f $powerShellHost.Source) -ForegroundColor Gray
Write-Host ("  Opens:  {0}" -f $menuScript) -ForegroundColor Gray
Write-Host "  Remove anytime with: scripts\Install-DailyRoutinesShortcut.ps1 -Remove" -ForegroundColor Gray
