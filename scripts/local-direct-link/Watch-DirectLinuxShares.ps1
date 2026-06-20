[CmdletBinding()]
param(
    [string]$HostAddress = "10.77.77.2",
    [int]$HostPort = 445,
    [int]$IntervalSeconds = 15,
    [int]$ConnectTimeoutMilliseconds = 1200,
    [string]$MapScript = "",
    [hashtable]$Shares = @{
        L = "\\10.77.77.2\linux-code"
        X = "\\10.77.77.2\direct-exchange"
    }
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

$LogPath = Join-Path $ScriptRoot "direct-shares-watch.log"

function Write-WatchLog {
    param([string]$Message)

    try {
        if ((Test-Path -LiteralPath $LogPath) -and ((Get-Item -LiteralPath $LogPath).Length -gt 131072)) {
            Move-Item -LiteralPath $LogPath -Destination "$LogPath.old" -Force
        }

        $line = "{0} {1}" -f (Get-Date).ToString("s"), $Message
        Add-Content -LiteralPath $LogPath -Value $line -Encoding ASCII
    } catch {
        # Logging must never interrupt the automount loop.
    }
}

function Test-TcpPort {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$TimeoutMilliseconds
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $connect = $client.BeginConnect($ComputerName, $Port, $null, $null)
        if (-not $connect.AsyncWaitHandle.WaitOne($TimeoutMilliseconds, $false)) {
            return $false
        }

        $client.EndConnect($connect)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Test-ShareMappings {
    foreach ($entry in $Shares.GetEnumerator()) {
        $driveName = $entry.Key.TrimEnd(":")
        $expectedRoot = $entry.Value
        $existing = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction SilentlyContinue

        if (-not $existing -or $existing.DisplayRoot -ne $expectedRoot) {
            return $false
        }
    }

    return $true
}

if (-not (Test-Path -LiteralPath $MapScript)) {
    Write-WatchLog "Missing map script: $MapScript"
    exit 1
}

Write-WatchLog "Watcher started for $HostAddress`:$HostPort."
$wasReachable = $null

while ($true) {
    try {
        $reachable = Test-TcpPort -ComputerName $HostAddress -Port $HostPort -TimeoutMilliseconds $ConnectTimeoutMilliseconds

        if ($reachable -ne $wasReachable) {
            Write-WatchLog "SMB reachability changed to $reachable."
            $wasReachable = $reachable
        }

        if ($reachable -and -not (Test-ShareMappings)) {
            Write-WatchLog "Share mapping repair started."
            & powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $MapScript *> $null
            Write-WatchLog "Share mapping repair completed with exit code $LASTEXITCODE."
        }
    } catch {
        Write-WatchLog "Watcher loop error: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $IntervalSeconds
}
