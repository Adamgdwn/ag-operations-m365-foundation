[CmdletBinding()]
param(
    [string]$DirectLinkHome = $env:DIRECT_LINK_HOME,
    [string]$LinuxHost = $(if ($env:DIRECT_LINUX_HOST) { $env:DIRECT_LINUX_HOST } else { "linux-direct" }),
    [string]$LinuxIp = $(if ($env:DIRECT_LINUX_IP) { $env:DIRECT_LINUX_IP } else { "10.77.77.2" }),
    [string]$CodeDrive = $(if ($env:DIRECT_LINUX_CODE) { $env:DIRECT_LINUX_CODE } else { "L:\" }),
    [string]$ExchangeDrive = $(if ($env:DIRECT_LINUX_EXCHANGE) { $env:DIRECT_LINUX_EXCHANGE } else { "X:\" })
)

$ErrorActionPreference = "Stop"

if (-not $DirectLinkHome) {
    $DirectLinkHome = "C:\Users\adamg\DirectLink"
}

$auditScript = Join-Path $DirectLinkHome "Test-DirectLinuxLink.ps1"
if (Test-Path -LiteralPath $auditScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $auditScript
    exit $LASTEXITCODE
}

$result = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    linuxIp = $LinuxIp
    linuxHost = $LinuxHost
    ping = $false
    ssh = $false
    codeDrive = (Test-Path -LiteralPath $CodeDrive)
    exchangeDrive = (Test-Path -LiteralPath $ExchangeDrive)
}

$result.ping = Test-Connection -ComputerName $LinuxIp -Count 1 -Quiet -ErrorAction SilentlyContinue

$sshOutput = & ssh.exe -o BatchMode=yes -o ConnectTimeout=3 $LinuxHost "printf direct-link-ok" 2>$null
if ($LASTEXITCODE -eq 0 -and ($sshOutput -join "") -eq "direct-link-ok") {
    $result.ssh = $true
}

$result.healthy = $result.ping -and $result.ssh -and $result.codeDrive -and $result.exchangeDrive
$result | ConvertTo-Json -Depth 4

if ($result.healthy) {
    exit 0
}

exit 1
