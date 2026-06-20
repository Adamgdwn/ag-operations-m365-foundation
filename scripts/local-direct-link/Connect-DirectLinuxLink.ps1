[CmdletBinding()]
param(
    [string]$LinuxUser,
    [string]$HostName = "10.77.77.2",
    [string]$HostAlias = "linux-direct",
    [string]$IdentityFile = "$env:USERPROFILE\.ssh\direct_linux_ed25519"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $IdentityFile)) {
    throw "Missing SSH identity: $IdentityFile"
}

if (-not $LinuxUser) {
    $linuxUserPath = Join-Path $PSScriptRoot "linux-user.txt"
    if (Test-Path -LiteralPath $linuxUserPath) {
        $LinuxUser = (Get-Content -Path $linuxUserPath -Raw).Trim()
    }
}

if (-not $LinuxUser) {
    throw "LinuxUser is required, or create linux-user.txt next to this script."
}

$portCheck = Test-NetConnection -ComputerName $HostName -Port 22 -InformationLevel Quiet
if (-not $portCheck) {
    throw "SSH is not reachable at ${HostName}:22 yet."
}

$sshDir = Join-Path $env:USERPROFILE ".ssh"
$knownHosts = Join-Path $sshDir "known_hosts"
$sshConfig = Join-Path $sshDir "config"
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

if (-not (Test-Path -LiteralPath $knownHosts)) {
    New-Item -ItemType File -Path $knownHosts | Out-Null
}

$knownHostContent = Get-Content -Path $knownHosts -Raw -ErrorAction SilentlyContinue
if ($knownHostContent -notmatch "(^|\n)$([regex]::Escape($HostName))[, ]") {
    ssh.exe `
        -i $IdentityFile `
        -o BatchMode=yes `
        -o ConnectTimeout=10 `
        -o StrictHostKeyChecking=accept-new `
        -o UserKnownHostsFile="$knownHosts" `
        -o KexAlgorithms=curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256 `
        "$LinuxUser@$HostName" "true"

    if ($LASTEXITCODE -ne 0) {
        throw "Could not pin or verify Linux SSH host key for $LinuxUser@$HostName."
    }
}

$configStart = "# direct-linux-link start"
$configEnd = "# direct-linux-link end"
$existingConfig = if (Test-Path -LiteralPath $sshConfig) { Get-Content -Path $sshConfig -Raw } else { "" }
$block = @"
$configStart
Host $HostAlias
    HostName $HostName
    User $LinuxUser
    IdentityFile $IdentityFile
    IdentitiesOnly yes
    BatchMode yes
    StrictHostKeyChecking yes
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256
$configEnd
"@

$pattern = "(?ms)^$([regex]::Escape($configStart)).*?$([regex]::Escape($configEnd))\r?\n?"
if ($existingConfig -match $pattern) {
    $newConfig = [regex]::Replace($existingConfig, $pattern, $block + "`r`n")
} else {
    $newConfig = ($existingConfig.TrimEnd() + "`r`n`r`n" + $block + "`r`n").TrimStart()
}
$newConfig | Set-Content -Path $sshConfig

ssh.exe $HostAlias 'echo host=$(hostname); echo user=$(id -un); ip -brief addr; test -f ~/direct-windows-link/linux-link-status.json && cat ~/direct-windows-link/linux-link-status.json'
