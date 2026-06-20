[CmdletBinding()]
param(
    [string]$DriveLetter = "X",
    [string]$SharePath = "\\10.77.77.2\direct-exchange",
    [string]$CredentialTarget = "10.77.77.2",
    [string]$LinuxUser = "directlink",
    [switch]$SkipCredentialPrompt
)

$ErrorActionPreference = "Stop"

$mapScript = Join-Path $PSScriptRoot "Map-DirectLinuxShare.ps1"
if (-not (Test-Path -LiteralPath $mapScript)) {
    throw "Missing $mapScript"
}

if (-not $SkipCredentialPrompt) {
    $securePassword = Read-Host -Prompt "Samba password for $LinuxUser@$CredentialTarget" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        cmdkey.exe /add:$CredentialTarget /user:$LinuxUser /pass:$plainPassword | Out-Null
    } finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
        $plainPassword = $null
    }
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mapScript -DriveLetter $DriveLetter -SharePath $SharePath

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$mapScript`" -DriveLetter $DriveLetter -SharePath `"$SharePath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$periodicTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -StartWhenAvailable

Register-ScheduledTask -TaskName "DirectLinuxShare-AtLogon" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Register-ScheduledTask -TaskName "DirectLinuxShare-Periodic" -Action $action -Trigger $periodicTrigger -Settings $settings -Force | Out-Null

Write-Host "Direct Linux share mapping installed."
Write-Host "Drive: $DriveLetter`: -> $SharePath"
Write-Host "Tasks: DirectLinuxShare-AtLogon, DirectLinuxShare-Periodic"
