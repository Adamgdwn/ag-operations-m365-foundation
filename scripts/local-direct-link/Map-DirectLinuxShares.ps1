[CmdletBinding()]
param(
    [string]$HostAddress = "10.77.77.2",
    [hashtable]$Shares = @{
        L = "\\10.77.77.2\linux-code"
        X = "\\10.77.77.2\direct-exchange"
    }
)

$ErrorActionPreference = "Stop"

if (-not (Test-NetConnection -ComputerName $HostAddress -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue)) {
    Write-Host "Direct Linux SMB endpoint is not reachable yet at $HostAddress`:445."
    exit 2
}

foreach ($entry in $Shares.GetEnumerator()) {
    $driveName = $entry.Key.TrimEnd(":")
    $driveRoot = "$driveName`:"
    $sharePath = $entry.Value
    $existing = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction SilentlyContinue

    if ($existing -and ($existing.DisplayRoot -eq $sharePath -or $existing.Root -eq $sharePath)) {
        Write-Host "$driveRoot already mapped to $sharePath."
        continue
    }

    if ($existing) {
        net.exe use $driveRoot /delete /y | Out-Null
    }

    net.exe use $driveRoot $sharePath /persistent:yes | Out-Host
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Write-Host "$driveRoot mapped to $sharePath."
}
