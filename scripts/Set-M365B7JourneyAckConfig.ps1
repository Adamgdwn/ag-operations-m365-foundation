param(
    [ValidateSet("Status", "Prepare", "SetSecret", "ClearSecret")]
    [string]$Mode = "Status",

    [string]$Endpoint = "https://www.guidedaijourney.com/api/crm/lifecycle/ack",
    [string]$HeaderName = "x-m365-ack-secret",

    [switch]$UseEnvironmentSecret,
    [switch]$PromptForSecret,
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $scriptRoot
$configDir = Join-Path $repoRoot ".local\flow-builder"
$endpointFile = Join-Path $configDir "journey-crm-ack-endpoint.txt"
$secretFile = Join-Path $configDir "journey-crm-ack-secret.txt"
$headerFile = Join-Path $configDir "journey-crm-ack-secret-header.txt"

function Write-LocalText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Read-SecretFromPrompt {
    $secure = Read-Host "Enter Journey CRM ack secret for local Power Automate config" -AsSecureString
    if ($secure.Length -eq 0) { throw "Secret was empty." }
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Get-Readiness {
    $hasEndpoint = Test-Path -LiteralPath $endpointFile
    $hasSecret = Test-Path -LiteralPath $secretFile
    $hasHeader = Test-Path -LiteralPath $headerFile

    $state = if ($hasEndpoint -and $hasSecret) {
        "READY_FOR_FLOW_BUILD"
    }
    elseif ($hasEndpoint -and -not $hasSecret) {
        "PENDING_ACK_SECRET"
    }
    elseif (-not $hasEndpoint -and $hasSecret) {
        "INCOMPLETE_REMOVE_SECRET_OR_PREPARE_ENDPOINT"
    }
    else {
        "NOT_PREPARED"
    }

    [pscustomobject]@{
        state = $state
        endpointFile = $endpointFile
        endpointConfigured = $hasEndpoint
        secretFile = $secretFile
        secretConfigured = $hasSecret
        headerFile = $headerFile
        headerConfigured = $hasHeader
        headerName = if ($hasHeader) { (Get-Content -LiteralPath $headerFile -Raw).Trim() } else { "x-m365-ack-secret" }
        nextCommand = if ($hasEndpoint -and $hasSecret) {
            "pwsh -NoProfile -File .\scripts\flow-builder\Start-FlowBuilder.ps1 -Phase http-intake -State Started"
        }
        elseif ($hasEndpoint -and -not $hasSecret) {
            "Set JOURNEY_CRM_ACK_SECRET in this terminal, then run: pwsh -NoProfile -File .\scripts\Set-M365B7JourneyAckConfig.ps1 -Mode SetSecret -UseEnvironmentSecret -NoPause"
        }
        else {
            "pwsh -NoProfile -File .\scripts\Set-M365B7JourneyAckConfig.ps1 -Mode Prepare -NoPause"
        }
    }
}

if (-not ($Endpoint -match '^https://')) {
    throw "Endpoint must be an https URL."
}
if (-not ($HeaderName -match '^[A-Za-z0-9-]+$')) {
    throw "Header name must be a simple HTTP header token."
}

New-Item -ItemType Directory -Path $configDir -Force | Out-Null

switch ($Mode) {
    "Prepare" {
        Write-LocalText -Path $endpointFile -Value $Endpoint
        Write-LocalText -Path $headerFile -Value $HeaderName
        if ($UseEnvironmentSecret -or $PromptForSecret) {
            $secret = if ($UseEnvironmentSecret) { $env:JOURNEY_CRM_ACK_SECRET } else { Read-SecretFromPrompt }
            if ([string]::IsNullOrWhiteSpace($secret)) { throw "JOURNEY_CRM_ACK_SECRET is empty or missing." }
            Write-LocalText -Path $secretFile -Value $secret.Trim()
            Write-Host "Ack secret stored locally in .local only." -ForegroundColor Green
        }
        Write-Host "Ack endpoint/header prepared locally." -ForegroundColor Green
    }
    "SetSecret" {
        if (-not (Test-Path -LiteralPath $endpointFile)) {
            Write-LocalText -Path $endpointFile -Value $Endpoint
        }
        if (-not (Test-Path -LiteralPath $headerFile)) {
            Write-LocalText -Path $headerFile -Value $HeaderName
        }
        $secret = if ($UseEnvironmentSecret) { $env:JOURNEY_CRM_ACK_SECRET } elseif ($PromptForSecret) { Read-SecretFromPrompt } else { $null }
        if ([string]::IsNullOrWhiteSpace($secret)) {
            throw "Use -UseEnvironmentSecret with JOURNEY_CRM_ACK_SECRET set, or use -PromptForSecret."
        }
        Write-LocalText -Path $secretFile -Value $secret.Trim()
        Write-Host "Ack secret stored locally in .local only." -ForegroundColor Green
    }
    "ClearSecret" {
        if (Test-Path -LiteralPath $secretFile) {
            Remove-Item -LiteralPath $secretFile -Force
            Write-Host "Removed local ack secret file." -ForegroundColor Yellow
        }
        else {
            Write-Host "No local ack secret file exists." -ForegroundColor Yellow
        }
    }
    "Status" {}
}

$readiness = Get-Readiness
$readiness | ConvertTo-Json -Depth 4

if (-not $NoPause) {
    Read-Host "Press Enter to close"
}
