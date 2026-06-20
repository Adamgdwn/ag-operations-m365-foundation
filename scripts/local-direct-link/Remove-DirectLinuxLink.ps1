[CmdletBinding()]
param(
    [string]$InterfaceAlias = "Ethernet 2",
    [string]$LocalAddress = "10.77.77.1"
)

$ErrorActionPreference = "Stop"

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "-InterfaceAlias", "`"$InterfaceAlias`"",
        "-LocalAddress", $LocalAddress
    ) -join " "

    Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs -Wait
    exit $LASTEXITCODE
}

foreach ($taskName in @(
    "DirectLinuxLink-AtStartup",
    "DirectLinuxLink-AtLogon",
    "DirectLinuxLink-OnNetworkConnect",
    "DirectLinuxLink-Periodic",
    "\DirectLinuxLink\AtStartup",
    "\DirectLinuxLink\AtLogon",
    "\DirectLinuxLink\OnNetworkConnect"
)) {
    schtasks.exe /Delete /TN $taskName /F 2>$null | Out-Null
}

Get-NetFirewallRule -DisplayName "Direct Linux Link - Allow inbound" -ErrorAction SilentlyContinue |
    Remove-NetFirewallRule -ErrorAction SilentlyContinue

Get-NetFirewallRule -DisplayName "Direct Linux Link - Allow outbound" -ErrorAction SilentlyContinue |
    Remove-NetFirewallRule -ErrorAction SilentlyContinue

Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $LocalAddress } |
    Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -Dhcp Enabled -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses -ErrorAction SilentlyContinue

Write-Host "Direct Linux link removed from $InterfaceAlias. IPv4 DHCP is enabled again."
