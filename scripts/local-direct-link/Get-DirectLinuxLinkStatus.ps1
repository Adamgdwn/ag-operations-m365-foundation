[CmdletBinding()]
param(
    [string]$InterfaceAlias = "Ethernet 2",
    [string]$LocalAddress = "10.77.77.1",
    [int]$PrefixLength = 30,
    [string]$PeerAddress = "10.77.77.2",
    [string]$HostAlias = "linux-direct"
)

$ErrorActionPreference = "SilentlyContinue"

$StatusPath = Join-Path $PSScriptRoot "direct-link-status.json"

$adapter = Get-NetAdapter -Name $InterfaceAlias
$ipAddress = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -eq $LocalAddress } |
    Select-Object -First 1
$defaultGateway = Get-NetRoute -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
$dns = Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4
$profile = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias
$neighbor = Get-NetNeighbor -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -eq $PeerAddress } |
    Select-Object -First 1
$peerReachable = Test-Connection -ComputerName $PeerAddress -Count 3 -Quiet
$firewallRules = Get-NetFirewallRule -Group "Direct Linux Link"

$status = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    interfaceAlias = $InterfaceAlias
    adapterStatus = $adapter.Status
    linkSpeed = $adapter.LinkSpeed
    localAddress = if ($ipAddress) { "$($ipAddress.IPAddress)/$($ipAddress.PrefixLength)" } else { $null }
    expectedLocalAddress = "$LocalAddress/$PrefixLength"
    hasDefaultGateway = [bool]$defaultGateway
    dnsServers = @($dns.ServerAddresses)
    networkCategory = $profile.NetworkCategory
    ipv4Connectivity = $profile.IPv4Connectivity
    peerAddress = $PeerAddress
    peerAlias = $HostAlias
    peerReachable = [bool]$peerReachable
    peerMacAddress = $neighbor.LinkLayerAddress
    peerNeighborState = $neighbor.State
    firewallRules = @($firewallRules | ForEach-Object {
        [ordered]@{
            name = $_.DisplayName
            enabled = $_.Enabled
            direction = $_.Direction
            action = $_.Action
        }
    })
}

$status | ConvertTo-Json -Depth 4 | Set-Content -Path $StatusPath

[pscustomobject]$status
