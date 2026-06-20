[CmdletBinding()]
param(
    [string]$InterfaceAlias = "Ethernet 2",
    [string]$LocalAddress = "10.77.77.1",
    [int]$PrefixLength = 30,
    [string]$PeerAddress = "10.77.77.2",
    [string]$DirectSubnet = "10.77.77.0/30",
    [string]$HostAlias = "linux-direct"
)

$ErrorActionPreference = "Stop"
$InstallLogPath = Join-Path $PSScriptRoot "install-direct-link.log"

function Write-InstallLog {
    param([string]$Message)

    $line = "{0} {1}" -f (Get-Date).ToString("s"), $Message
    Add-Content -Path $InstallLogPath -Value $line
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-InstallLog "Requesting elevation through UAC."

    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "-InterfaceAlias", "`"$InterfaceAlias`"",
        "-LocalAddress", $LocalAddress,
        "-PrefixLength", $PrefixLength,
        "-PeerAddress", $PeerAddress,
        "-DirectSubnet", $DirectSubnet,
        "-HostAlias", $HostAlias
    ) -join " "

    $process = Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs -Wait -PassThru
    Write-InstallLog "Elevated process returned to non-admin launcher with exit code $($process.ExitCode)."
    exit $process.ExitCode
}

Write-InstallLog "Running elevated installer."

$ensureScript = Join-Path $PSScriptRoot "Ensure-DirectLinuxLink.ps1"
if (-not (Test-Path -LiteralPath $ensureScript)) {
    Write-InstallLog "Missing ensure script: $ensureScript"
    throw "Missing $ensureScript"
}

$ensureArguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -InterfaceAlias "{1}" -LocalAddress {2} -PrefixLength {3} -PeerAddress {4} -DirectSubnet {5} -HostAlias {6}' -f
    $ensureScript, $InterfaceAlias, $LocalAddress, $PrefixLength, $PeerAddress, $DirectSubnet, $HostAlias

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $ensureArguments
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -MultipleInstances IgnoreNew `
    -StartWhenAvailable

Write-InstallLog "Creating scheduled task DirectLinuxLink-AtStartup."
Register-ScheduledTask `
    -TaskName "DirectLinuxLink-AtStartup" `
    -Action $action `
    -Trigger (New-ScheduledTaskTrigger -AtStartup) `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null

Write-InstallLog "Creating scheduled task DirectLinuxLink-AtLogon."
Register-ScheduledTask `
    -TaskName "DirectLinuxLink-AtLogon" `
    -Action $action `
    -Trigger (New-ScheduledTaskTrigger -AtLogon) `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null

Write-InstallLog "Creating scheduled task DirectLinuxLink-OnNetworkConnect."
$escapedArguments = [Security.SecurityElement]::Escape($ensureArguments)
$networkEventTaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Reapply the direct Windows-to-Linux Ethernet link when Windows reports a network connection.</Description>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[EventID=10000]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT5M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>$escapedArguments</Arguments>
    </Exec>
  </Actions>
</Task>
"@
Register-ScheduledTask `
    -TaskName "DirectLinuxLink-OnNetworkConnect" `
    -Xml $networkEventTaskXml `
    -Force | Out-Null

Write-InstallLog "Creating scheduled task DirectLinuxLink-Periodic."
$periodicTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5)
Register-ScheduledTask `
    -TaskName "DirectLinuxLink-Periodic" `
    -Action $action `
    -Trigger $periodicTrigger `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null

foreach ($taskName in @(
    "DirectLinuxLink-AtStartup",
    "DirectLinuxLink-AtLogon",
    "DirectLinuxLink-OnNetworkConnect",
    "DirectLinuxLink-Periodic"
)) {
    try {
        $registeredTask = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        Write-InstallLog "Verified scheduled task $taskName at path '$($registeredTask.TaskPath)' with state '$($registeredTask.State)'."
    } catch {
        Write-InstallLog "Scheduled task verification failed for ${taskName}: $($_.Exception.Message)"
        throw
    }
}

Write-InstallLog "Running immediate configuration."
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ensureScript `
    -InterfaceAlias $InterfaceAlias `
    -LocalAddress $LocalAddress `
    -PrefixLength $PrefixLength `
    -PeerAddress $PeerAddress `
    -DirectSubnet $DirectSubnet `
    -HostAlias $HostAlias

Write-InstallLog "Install completed."

Write-Host ""
Write-Host "Direct Linux link is installed."
Write-Host "Windows side: $LocalAddress/$PrefixLength on $InterfaceAlias"
Write-Host "Expected Linux side: $PeerAddress/$PrefixLength"
Write-Host "Firewall allow-list: $DirectSubnet on $InterfaceAlias"
Write-Host "Peer alias: $HostAlias"
Write-Host "Status file: $(Join-Path $PSScriptRoot 'direct-link-status.json')"
