[CmdletBinding()]
param(
    [string]$HostAlias = "linux-direct",
    [string]$WindowsStatusScript
)

$ErrorActionPreference = "Stop"

if (-not $WindowsStatusScript) {
    $WindowsStatusScript = Join-Path $PSScriptRoot "Get-DirectLinuxLinkStatus.ps1"
}

if (-not (Test-Path -LiteralPath $WindowsStatusScript)) {
    throw "Missing Windows status script: $WindowsStatusScript"
}

$windowsStatus = & $WindowsStatusScript
$sshProbe = & ssh.exe $HostAlias 'echo ssh_ok; hostname; id -un' 2>&1
$sshExit = $LASTEXITCODE

$linuxStatusRaw = $null
$linuxStatus = $null
if ($sshExit -eq 0) {
    $linuxStatusRaw = & ssh.exe $HostAlias 'cat ~/direct-windows-link/linux-link-status.json' 2>$null
    if ($linuxStatusRaw) {
        $linuxStatus = ($linuxStatusRaw -join "`n") | ConvertFrom-Json
    }
}

$smbReachable = Test-NetConnection -ComputerName 10.77.77.2 -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue
$codeDrive = Get-PSDrive -Name "L" -PSProvider FileSystem -ErrorAction SilentlyContinue
$exchangeDrive = Get-PSDrive -Name "X" -PSProvider FileSystem -ErrorAction SilentlyContinue

$result = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    mission = "direct-windows-linux-cable-link"
    windows = [ordered]@{
        interface = $windowsStatus.interfaceAlias
        localAddress = $windowsStatus.localAddress
        peerAddress = $windowsStatus.peerAddress
        peerReachable = [bool]$windowsStatus.peerReachable
        noDefaultGateway = -not [bool]$windowsStatus.hasDefaultGateway
        noDirectDns = @($windowsStatus.dnsServers).Count -eq 0
        peerMacAddress = $windowsStatus.peerMacAddress
    }
    linux = if ($linuxStatus) {
        [ordered]@{
            host = ($sshProbe | Select-Object -Index 1)
            user = ($sshProbe | Select-Object -Index 2)
            interface = $linuxStatus.interface
            linuxAddress = $linuxStatus.linuxAddress
            windowsAddress = $linuxStatus.windowsAddress
            windowsReachable = [bool]$linuxStatus.windowsReachable
            sshListening = [bool]$linuxStatus.sshListening
            observedWindowsMac = $linuxStatus.observedWindowsMac
            passwordAuthentication = $linuxStatus.sshSecurity.passwordAuthentication
            permitRootLogin = $linuxStatus.sshSecurity.permitRootLogin
            allowedUser = $linuxStatus.sshSecurity.allowedUser
        }
    } else {
        $null
    }
    ssh = [ordered]@{
        alias = $HostAlias
        reachable = $sshExit -eq 0
    }
    sharedWorkspace = [ordered]@{
        codeDrive = "L:"
        codeUncPath = "\\10.77.77.2\linux-code"
        exchangeDrive = "X:"
        exchangeUncPath = "\\10.77.77.2\direct-exchange"
        smbReachable = [bool]$smbReachable
        codeDriveMapped = [bool]$codeDrive
        codeDriveRoot = if ($codeDrive) { $codeDrive.Root } else { $null }
        exchangeDriveMapped = [bool]$exchangeDrive
        exchangeDriveRoot = if ($exchangeDrive) { $exchangeDrive.Root } else { $null }
        linuxCodePath = "/home/adamgoodwin/code"
        linuxExchangePath = "/home/adamgoodwin/DirectLink/Exchange"
        status = if ($codeDrive -and $exchangeDrive) { "mounted" } elseif ($smbReachable) { "available-not-mounted" } else { "not-yet-installed-or-offline" }
    }
    healthy = (
        [bool]$windowsStatus.peerReachable -and
        (-not [bool]$windowsStatus.hasDefaultGateway) -and
        (@($windowsStatus.dnsServers).Count -eq 0) -and
        ($sshExit -eq 0) -and
        $linuxStatus -and
        [bool]$linuxStatus.windowsReachable -and
        [bool]$linuxStatus.sshListening
    )
}

$result | ConvertTo-Json -Depth 5
