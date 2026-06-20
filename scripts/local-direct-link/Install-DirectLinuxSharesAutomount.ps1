[CmdletBinding()]
param(
    [string]$MapScript,
    [string]$WatchScript
)

$ErrorActionPreference = "Stop"
$ScriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Split-Path -Parent $PSCommandPath
} else {
    $PSScriptRoot
}

if ([string]::IsNullOrWhiteSpace($MapScript)) {
    $MapScript = Join-Path $ScriptRoot "Map-DirectLinuxShares.ps1"
}

if ([string]::IsNullOrWhiteSpace($WatchScript)) {
    $WatchScript = Join-Path $ScriptRoot "Watch-DirectLinuxShares.ps1"
}

foreach ($requiredPath in @($MapScript, $WatchScript)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Missing direct-link share script: $requiredPath"
    }
}

& powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $MapScript

$startupFolder = [Environment]::GetFolderPath("Startup")
$desktopFolder = [Environment]::GetFolderPath("Desktop")
$oldStartupScript = Join-Path $startupFolder "Map-DirectLinuxShares.cmd"
if (Test-Path -LiteralPath $oldStartupScript) {
    Remove-Item -LiteralPath $oldStartupScript -Force
}

$wsh = New-Object -ComObject WScript.Shell
$watchShortcut = $wsh.CreateShortcut((Join-Path $startupFolder "Direct Linux Shares Watcher.lnk"))
$watchShortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$watchShortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$WatchScript`""
$watchShortcut.WorkingDirectory = $ScriptRoot
$watchShortcut.WindowStyle = 7
$watchShortcut.Description = "Automatically reconnect the direct Linux shared drives when the cable link is available."
$watchShortcut.Save()

foreach ($shortcutSpec in @(
    @{ Name = "Linux Direct Exchange.lnk"; Target = "X:\"; Description = "Shared direct exchange folder on the Linux laptop." },
    @{ Name = "Linux Code.lnk"; Target = "L:\"; Description = "Linux code folder over the direct Ethernet link." }
)) {
    $shortcut = $wsh.CreateShortcut((Join-Path $desktopFolder $shortcutSpec.Name))
    $shortcut.TargetPath = $shortcutSpec.Target
    $shortcut.WorkingDirectory = $shortcutSpec.Target
    $shortcut.Description = $shortcutSpec.Description
    $shortcut.Save()
}

$watcher = Get-CimInstance Win32_Process -Filter "name = 'powershell.exe'" |
    Where-Object { $_.CommandLine -like "*Watch-DirectLinuxShares.ps1*" }

if (-not $watcher) {
    Start-Process -FilePath powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$WatchScript`""
}

Write-Host "Direct Linux shares automount installed."
Write-Host "No daily command is required after sign-in."
Write-Host "L: -> \\10.77.77.2\linux-code"
Write-Host "X: -> \\10.77.77.2\direct-exchange"
Write-Host "Startup watcher: $(Join-Path $startupFolder 'Direct Linux Shares Watcher.lnk')"
Write-Host "Desktop shortcuts: Linux Direct Exchange, Linux Code"
