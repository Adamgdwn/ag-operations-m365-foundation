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

$LogPath = Join-Path $PSScriptRoot "direct-link.log"
$StatusPath = Join-Path $PSScriptRoot "direct-link-status.json"

function Write-DirectLinkLog {
    param([string]$Message)

    $line = "{0} {1}" -f (Get-Date).ToString("s"), $Message
    Add-Content -Path $LogPath -Value $line
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-DirectLinkLog "ERROR Script must run as Administrator."
    throw "Ensure-DirectLinuxLink.ps1 must run as Administrator."
}

Write-DirectLinkLog "Starting direct-link configuration for '$InterfaceAlias'."

$adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop

if ($adapter.Status -eq "Disabled") {
    Enable-NetAdapter -Name $InterfaceAlias -Confirm:$false
    Start-Sleep -Seconds 2
    $adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
}

Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -Dhcp Disabled
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -AutomaticMetric Disabled -InterfaceMetric 5 -ErrorAction SilentlyContinue

Get-NetRoute -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
    Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue

$addresses = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue
foreach ($address in $addresses) {
    $isTargetAddress = $address.IPAddress -eq $LocalAddress -and $address.PrefixLength -eq $PrefixLength
    if (-not $isTargetAddress) {
        Remove-NetIPAddress -InputObject $address -Confirm:$false -ErrorAction SilentlyContinue
    }
}

$targetAddress = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $LocalAddress -and $_.PrefixLength -eq $PrefixLength } |
    Select-Object -First 1

if (-not $targetAddress) {
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $LocalAddress -PrefixLength $PrefixLength -Type Unicast | Out-Null
}

Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses -ErrorAction SilentlyContinue
netsh.exe interface ipv4 set dnsservers name="$InterfaceAlias" source=static address=none validate=no | Out-Null

try {
    Set-NetConnectionProfile -InterfaceIndex $adapter.ifIndex -NetworkCategory Private -ErrorAction Stop
} catch {
    Write-DirectLinkLog "Network profile was not ready for Private classification: $($_.Exception.Message)"
}

$firewallRules = @(
    @{
        DisplayName = "Direct Linux Link - Allow inbound"
        Direction = "Inbound"
    },
    @{
        DisplayName = "Direct Linux Link - Allow outbound"
        Direction = "Outbound"
    }
)

foreach ($rule in $firewallRules) {
    Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue |
        Remove-NetFirewallRule -ErrorAction SilentlyContinue

    New-NetFirewallRule `
        -DisplayName $rule.DisplayName `
        -Group "Direct Linux Link" `
        -Direction $rule.Direction `
        -Action Allow `
        -Enabled True `
        -Profile Any `
        -InterfaceAlias $InterfaceAlias `
        -LocalAddress $LocalAddress `
        -RemoteAddress $DirectSubnet `
        -Protocol Any | Out-Null
}

try {
    $power = Get-NetAdapterPowerManagement -Name $InterfaceAlias -ErrorAction Stop
    if ($power.AllowComputerToTurnOffDevice -ne "Unsupported") {
        Disable-NetAdapterPowerManagement -Name $InterfaceAlias -ErrorAction SilentlyContinue
    }
} catch {
    Write-DirectLinkLog "Power-management settings not changed: $($_.Exception.Message)"
}

try {
    $hostsPath = Join-Path $env:SystemRoot "System32\drivers\etc\hosts"
    $hostsContent = Get-Content -Path $hostsPath -Raw -ErrorAction SilentlyContinue
    $hostPattern = "(?m)^\s*$([regex]::Escape($PeerAddress))\s+$([regex]::Escape($HostAlias))(\s|$)"
    if ($hostsContent -notmatch $hostPattern) {
        Add-Content -Path $hostsPath -Value ("`r`n{0}`t{1}" -f $PeerAddress, $HostAlias)
    }
} catch {
    Write-DirectLinkLog "Hosts alias not changed: $($_.Exception.Message)"
}

$adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
$peerReachable = Test-Connection -ComputerName $PeerAddress -Count 1 -Quiet -ErrorAction SilentlyContinue

$status = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    interfaceAlias = $InterfaceAlias
    adapterStatus = $adapter.Status
    linkSpeed = $adapter.LinkSpeed
    localAddress = "$LocalAddress/$PrefixLength"
    directSubnet = $DirectSubnet
    peerAddress = $PeerAddress
    peerAlias = $HostAlias
    peerReachable = [bool]$peerReachable
}

$status | ConvertTo-Json | Set-Content -Path $StatusPath

Write-DirectLinkLog ("Configured {0}/{1}; peer {2} reachable: {3}." -f $LocalAddress, $PrefixLength, $PeerAddress, $peerReachable)
