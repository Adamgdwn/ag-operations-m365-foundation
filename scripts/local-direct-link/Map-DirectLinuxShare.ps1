[CmdletBinding()]
param(
    [string]$DriveLetter = "X",
    [string]$SharePath = "\\10.77.77.2\direct-exchange",
    [string]$HostAddress = "10.77.77.2"
)

$ErrorActionPreference = "Stop"

$driveName = $DriveLetter.TrimEnd(":")
$driveRoot = "$driveName`:"

if (-not (Test-NetConnection -ComputerName $HostAddress -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue)) {
    Write-Host "SMB share is not reachable yet at $HostAddress`:445."
    exit 2
}

$existing = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction SilentlyContinue
if ($existing -and $existing.Root -eq $SharePath) {
    Write-Host "$driveRoot already mapped to $SharePath."
    exit 0
}

if ($existing) {
    net.exe use $driveRoot /delete /y | Out-Null
}

net.exe use $driveRoot $SharePath /persistent:yes | Out-Host

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "$driveRoot mapped to $SharePath."
