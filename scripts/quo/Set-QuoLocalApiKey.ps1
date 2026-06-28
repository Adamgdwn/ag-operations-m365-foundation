param(
    [switch]$Window,
    [switch]$Capture,
    [switch]$Wait,
    [int]$WaitSeconds = 240,
    [string]$SecretDirectory = "",
    [string]$MetadataPath = "",
    [string]$SourceTextFile = "",
    [switch]$Force
)

# Captures the QUO API key into a local Windows DPAPI-encrypted file.
# This script does not call QUO, Microsoft 365, CRM, Teams, or any webhook.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

if ([string]::IsNullOrWhiteSpace($SecretDirectory)) {
    $SecretDirectory = Join-Path $workspaceRoot ".local\quo-ingress"
}

if ([string]::IsNullOrWhiteSpace($MetadataPath)) {
    $MetadataPath = Join-Path $SecretDirectory "quo-api-key.metadata.json"
}

$secretPath = Join-Path $SecretDirectory "quo-api-key.secret"

function ConvertTo-CmdArgument {
    param([string]$Argument)

    if ($Argument -match '[\s"]') {
        return '"' + ($Argument -replace '"', '\"') + '"'
    }

    return $Argument
}

function Get-Sha256Hex {
    param([string]$Value)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $hash = $sha.ComputeHash($bytes)
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha.Dispose()
    }
}

function Get-ApiKeyCandidateFromTextFile {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "SourceTextFile was not provided."
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "QUO API key source text file not found: $Path"
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    $lines = @($raw -split "\r?\n" | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($lines.Count -eq 0) {
        throw "QUO API key source text file is empty: $Path"
    }

    $candidate = $lines[0]
    foreach ($line in $lines) {
        if ($line -match "(?i)(quo|api|key|token|authorization)") {
            $candidate = $line
            break
        }
    }

    if ($candidate -match "^\s*[^:=]{1,60}(api|key|token|authorization)[^:=]{0,60}[:=]\s*(.+)$") {
        $candidate = $Matches[2].Trim()
    }
    elseif ($candidate -match "^\s*QUO_API_KEY\s*=\s*(.+)$") {
        $candidate = $Matches[1].Trim()
    }

    $candidate = $candidate.Trim().Trim('"').Trim("'")
    if ($candidate.Length -lt 8) {
        throw "QUO API key candidate is unexpectedly short. Nothing was stored."
    }

    return $candidate
}

if ($Window -and -not $Capture) {
    New-Item -ItemType Directory -Force -Path $SecretDirectory | Out-Null

    $powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
    if ($null -eq $powerShellHost) {
        $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
    }

    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-NoExit",
        "-File", $PSCommandPath,
        "-Capture",
        "-SecretDirectory", $SecretDirectory,
        "-MetadataPath", $MetadataPath
    )

    if ($Force) {
        $arguments += "-Force"
    }

    if (-not [string]::IsNullOrWhiteSpace($SourceTextFile)) {
        $arguments += @("-SourceTextFile", $SourceTextFile)
    }

    Write-Host "Opening visible QUO API key capture window." -ForegroundColor Cyan
    Write-Host ("Secret file: {0}" -f $secretPath) -ForegroundColor Gray
    Write-Host "The key is captured locally only; it will not be printed here." -ForegroundColor Gray

    $powerShellCommand = (ConvertTo-CmdArgument -Argument $powerShellHost.Source) + " " + (($arguments | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")
    $command = @(
        "title M365 Interaction Agent B10c QUO API Key Capture",
        "cd /d $(ConvertTo-CmdArgument -Argument $workspaceRoot)",
        "echo Ready to capture the QUO API key locally.",
        "echo This stores an encrypted local secret only and performs no API call.",
        "echo Review the window scope before pasting the key.",
        "pause",
        $powerShellCommand
    ) -join " && "

    Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $workspaceRoot -WindowStyle Normal

    if ($Wait) {
        $deadline = (Get-Date).AddSeconds($WaitSeconds)
        while ((Get-Date) -lt $deadline) {
            if ((Test-Path -LiteralPath $secretPath) -and (Test-Path -LiteralPath $MetadataPath)) {
                Write-Host "QUO API key capture metadata found." -ForegroundColor Cyan
                return
            }
            Start-Sleep -Seconds 2
        }

        Write-Host ("No QUO key capture metadata appeared within {0} seconds." -f $WaitSeconds) -ForegroundColor Yellow
    }

    return
}

if (-not $Capture) {
    $Capture = $true
}

New-Item -ItemType Directory -Force -Path $SecretDirectory | Out-Null

if ((Test-Path -LiteralPath $secretPath) -and -not $Force) {
    throw "QUO API key secret already exists. Re-run with -Force to replace it: $secretPath"
}

if (-not [string]::IsNullOrWhiteSpace($SourceTextFile)) {
    $keyCandidate = Get-ApiKeyCandidateFromTextFile -Path $SourceTextFile
    $secureKey = ConvertTo-SecureString -String $keyCandidate -AsPlainText -Force
    $encrypted = ConvertFrom-SecureString -SecureString $secureKey
    Set-Content -LiteralPath $secretPath -Value $encrypted -Encoding UTF8

    $sourceItem = Get-Item -LiteralPath $SourceTextFile
    $metadata = [ordered]@{
        createdAt = (Get-Date).ToString("o")
        chunk = "B10c.0"
        sourceSystem = "QUO"
        secretPath = $secretPath
        secretStorage = "Windows DPAPI CurrentUser encrypted SecureString via ConvertFrom-SecureString"
        apiBaseUrl = "https://api.quo.com"
        noApiCallPerformed = $true
        outboundBlocked = $true
        keyValueStoredInMetadata = $false
        importedFromTextFile = $true
        sourceFileName = $sourceItem.Name
        sourceFileLength = $sourceItem.Length
        sourceFileLastWriteTime = $sourceItem.LastWriteTime.ToString("o")
        nextProbeScript = "scripts/quo/Test-QuoApiKeyReadiness.ps1"
        note = "Imported from a local text file without printing the key. This metadata is local-only under .local. The secret value is not present."
    }

    $metadata | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $MetadataPath -Encoding UTF8

    Write-Host "QUO API key imported into local encrypted storage." -ForegroundColor Green
    Write-Host ("Secret file:   {0}" -f $secretPath) -ForegroundColor Gray
    Write-Host ("Metadata file: {0}" -f $MetadataPath) -ForegroundColor Gray
    Write-Host "No API call was made." -ForegroundColor Gray
    return
}

$Host.UI.RawUI.WindowTitle = "M365 Interaction Agent B10c QUO API Key Capture"
Clear-Host

Write-Host "M365 Interaction Agent B10c QUO API Key Capture" -ForegroundColor Cyan
Write-Host ""
Write-Host "Scope:" -ForegroundColor Yellow
Write-Host " - Store the QUO API key in a local Windows DPAPI-encrypted file."
Write-Host " - Write local metadata without the secret value."
Write-Host " - Do not call QUO, Microsoft 365, CRM, Teams, or any webhook."
Write-Host ""
Write-Host "Stop conditions:" -ForegroundColor Yellow
Write-Host " - Do not paste the key into chat, docs, config, inventory, or git."
Write-Host " - Do not use this key for outbound SMS, calls, replies, webhook creation, or CRM writes."
Write-Host " - Run a separate read-only readiness probe only after explicitly approving that live read."
Write-Host ""
Write-Host "Required confirmation phrase:" -ForegroundColor Yellow
Write-Host "STORE QUO KEY LOCAL ONLY" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Type the exact confirmation phrase"
if ($confirmation -cne "STORE QUO KEY LOCAL ONLY") {
    throw "Confirmation phrase did not match. No key was stored."
}

$secureKey = Read-Host "Paste QUO API key (input hidden)" -AsSecureString
if ($secureKey.Length -lt 8) {
    throw "The captured value is unexpectedly short. No key was stored."
}

$encrypted = ConvertFrom-SecureString -SecureString $secureKey
Set-Content -LiteralPath $secretPath -Value $encrypted -Encoding UTF8

$metadata = [ordered]@{
    createdAt = (Get-Date).ToString("o")
    chunk = "B10c.0"
    sourceSystem = "QUO"
    secretPath = $secretPath
    secretStorage = "Windows DPAPI CurrentUser encrypted SecureString via ConvertFrom-SecureString"
    apiBaseUrl = "https://api.quo.com"
    noApiCallPerformed = $true
    outboundBlocked = $true
    keyValueStoredInMetadata = $false
    confirmationSha256 = Get-Sha256Hex -Value $confirmation
    nextProbeScript = "scripts/quo/Test-QuoApiKeyReadiness.ps1"
    note = "This metadata is local-only under .local. The secret value is not present."
}

$metadata | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $MetadataPath -Encoding UTF8

Write-Host ""
Write-Host "QUO API key stored locally." -ForegroundColor Green
Write-Host ("Secret file:   {0}" -f $secretPath) -ForegroundColor Gray
Write-Host ("Metadata file: {0}" -f $MetadataPath) -ForegroundColor Gray
Write-Host "No API call was made." -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to close this capture window"
