param(
    [ValidateSet("B8b", "B9b", "B10b")]
    [string]$Chunk = "B8b",
    [switch]$Capture,
    [string]$OutputFile = "",
    [switch]$Wait,
    [int]$WaitSeconds = 240
)

# Opens a visible PowerShell window for M365 Interaction Agent approval capture.
# This helper captures Adam's typed approval phrase/scope confirmation only; it
# does not connect to Microsoft 365, Journey, QUO, or any external system.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent $scriptRoot

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

function ConvertTo-CmdArgument {
    param([string]$Argument)

    if ($Argument -match '[\s"]') {
        return '"' + ($Argument -replace '"', '\"') + '"'
    }

    return $Argument
}

function Get-ChunkApprovalProfile {
    param([string]$ChunkName)

    switch ($ChunkName) {
        "B8b" {
            $configPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B8_JOURNEY_LOOP_HARDENING.json"
            $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            $evidenceTarget = [string]$config.evidenceTargets.futureReplayProof
            if ([string]::IsNullOrWhiteSpace($evidenceTarget)) {
                $evidenceTarget = [string]$config.evidenceTargets.replayProof
            }
            return [pscustomobject]@{
                Chunk = "B8b"
                Title = "M365 Interaction Agent B8b Approval"
                ApprovalPhrase = [string]$config.liveApprovalRequired.approvalPhrase
                Scope = @($config.liveApprovalRequired.scope)
                StopConditions = @($config.liveApprovalRequired.stopConditions)
                EvidenceTarget = $evidenceTarget
                Summary = "Live Journey loop hardening: first-class PortalEventId/SourceCorrelationId storage, idempotency lookup, receipt ack for created/existing outcomes, and one no-real-client replay proof."
            }
        }
        "B9b" {
            return [pscustomobject]@{
                Chunk = "B9b"
                Title = "M365 Interaction Agent B9b Selection"
                ApprovalPhrase = ""
                StoreTypedText = $true
                Scope = @("Adam selects exact CRM item id(s) before any tenant read.", "This B9b pass is G0/R0 read-only and writes local evidence only.", "Any G1 Suggested row remains a separate per-item approval.")
                StopConditions = @("No unselected CRM reads.", "No CRM updates.", "No Agent Action Log write.", "No duplicate Suggested rows.")
                EvidenceTarget = "inventory/m365-interaction-agent-b9/b9-selected-signal-review-*.csv"
                Summary = "Selected-signal operating triage selection capture."
            }
        }
        "B10b" {
            $configPath = Join-Path $workspaceRoot "config\M365_INTERACTION_AGENT_B10_QUO_INBOUND_SOURCE_PROOF.json"
            $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            return [pscustomobject]@{
                Chunk = "B10b"
                Title = "M365 Interaction Agent B10b Approval"
                ApprovalPhrase = [string]$config.liveApprovalRequired.approvalPhrase
                Scope = @($config.liveApprovalRequired.scope)
                StopConditions = @($config.liveApprovalRequired.stopConditions)
                EvidenceTarget = [string]$config.evidenceTargets.futureLiveProof
                Summary = "Live QUO inbound-only source proof approval capture."
            }
        }
    }
}

$profile = Get-ChunkApprovalProfile -ChunkName $Chunk

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $approvalDirectory = Join-Path $workspaceRoot ".local\interaction-agent-approvals"
    New-Item -ItemType Directory -Force -Path $approvalDirectory | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputFile = Join-Path $approvalDirectory ("{0}-approval-{1}.json" -f $Chunk.ToLowerInvariant(), $timestamp)
}

if ($Capture) {
    $Host.UI.RawUI.WindowTitle = $profile.Title
    Clear-Host

    Write-Host $profile.Title -ForegroundColor Cyan
    Write-Host ""
    Write-Host $profile.Summary
    Write-Host ""
    Write-Host "Approved scope:" -ForegroundColor Yellow
    foreach ($item in $profile.Scope) {
        Write-Host (" - {0}" -f $item)
    }
    Write-Host ""
    Write-Host "Stop conditions:" -ForegroundColor Yellow
    foreach ($item in $profile.StopConditions) {
        Write-Host (" - {0}" -f $item)
    }
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($profile.ApprovalPhrase)) {
        $typedPhrase = Read-Host "Type exact CRM item id(s), comma-separated"
        $approved = -not [string]::IsNullOrWhiteSpace($typedPhrase)
    }
    else {
        Write-Host "Required approval phrase:" -ForegroundColor Yellow
        Write-Host $profile.ApprovalPhrase -ForegroundColor White
        Write-Host ""
        $typedPhrase = Read-Host "Type the exact approval phrase"
        $approved = $typedPhrase -ceq $profile.ApprovalPhrase
    }

    $record = [ordered]@{
        chunk = $profile.Chunk
        capturedAt = (Get-Date).ToString("o")
        approved = [bool]$approved
        approvalPhraseRequired = $profile.ApprovalPhrase
        typedPhraseSha256 = Get-Sha256Hex -Value $typedPhrase
        scope = @($profile.Scope)
        stopConditions = @($profile.StopConditions)
        evidenceTarget = $profile.EvidenceTarget
        note = "Approval phrase text is not stored except for the required phrase already present in repo docs/config."
    }

    if (($profile.PSObject.Properties.Name -contains "StoreTypedText") -and $profile.StoreTypedText) {
        $record.selectedScope = $typedPhrase
        $record.note = "B9b selectedScope is stored locally because it is the operator's chosen CRM item id scope. This file stays under .local and is not committed."
    }

    $record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputFile -Encoding UTF8

    Write-Host ""
    if ($approved) {
        Write-Host "Approval captured and matched." -ForegroundColor Green
    }
    else {
        Write-Host "Approval captured but did not match the required gate." -ForegroundColor Red
    }
    Write-Host ("Evidence file: {0}" -f $OutputFile) -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to close this approval window"
    return
}

$powerShellHost = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
if ($null -eq $powerShellHost) {
    $powerShellHost = Get-Command "powershell.exe" -ErrorAction Stop
}

$arguments = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-File", $PSCommandPath,
    "-Chunk", $Chunk,
    "-Capture",
    "-OutputFile", $OutputFile
)

Write-Host ("Opening visible approval window: {0}" -f $profile.Title) -ForegroundColor Cyan
Write-Host ("Approval capture file: {0}" -f $OutputFile) -ForegroundColor Gray
Write-Host "This window captures approval only; it does not perform live tenant work." -ForegroundColor Gray

$powerShellCommand = (ConvertTo-CmdArgument -Argument $powerShellHost.Source) + " " + (($arguments | ForEach-Object { ConvertTo-CmdArgument -Argument $_ }) -join " ")
$command = @(
    "title $($profile.Title)",
    "cd /d $(ConvertTo-CmdArgument -Argument $workspaceRoot)",
    "echo Ready to start $($profile.Title).",
    "echo This window captures approval only; it does not perform live tenant work.",
    "echo Review the scope and stop conditions before typing anything.",
    "pause",
    $powerShellCommand
) -join " && "

Start-Process -FilePath $env:ComSpec -ArgumentList @("/k", $command) -WorkingDirectory $workspaceRoot -WindowStyle Normal

if ($Wait) {
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-Path -LiteralPath $OutputFile) {
            $captured = Get-Content -LiteralPath $OutputFile -Raw | ConvertFrom-Json
            Write-Host ("Approval captured. approved={0}" -f $captured.approved) -ForegroundColor Cyan
            return
        }
        Start-Sleep -Seconds 2
    }

    Write-Host ("No approval capture file appeared within {0} seconds." -f $WaitSeconds) -ForegroundColor Yellow
}
