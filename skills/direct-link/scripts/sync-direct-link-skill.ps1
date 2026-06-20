[CmdletBinding()]
param(
    [string]$SkillRoot = "",
    [string]$SkillName = "direct-link",
    [string]$LinuxHost = $(if ($env:DIRECT_LINUX_HOST) { $env:DIRECT_LINUX_HOST } else { "linux-direct" }),
    [string]$LinuxCodeDrive = $(if ($env:DIRECT_LINUX_CODE) { $env:DIRECT_LINUX_CODE } else { "L:\" }),
    [switch]$SkipSsh
)

$ErrorActionPreference = "Stop"

$ScriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Split-Path -Parent $PSCommandPath
} else {
    $PSScriptRoot
}

if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
    $SkillRoot = Split-Path -Parent $ScriptRoot
}

function Assert-SkillRoot {
    param([string]$Path)

    $skillFile = Join-Path $Path "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile)) {
        throw "Skill root is missing SKILL.md: $Path"
    }

    $leaf = Split-Path -Leaf $Path
    if ($leaf -ne $SkillName) {
        throw "Expected skill folder '$SkillName', got '$leaf' at $Path"
    }
}

function Sync-LocalSkill {
    param(
        [string]$Source,
        [string]$Target
    )

    $targetFull = [System.IO.Path]::GetFullPath($Target)
    if ((Split-Path -Leaf $targetFull) -ne $SkillName) {
        throw "Refusing to sync to non-$SkillName target: $Target"
    }

    $parent = Split-Path -Parent $targetFull
    if ($parent -notmatch '\\\.(codex|claude)\\skills$') {
        throw "Refusing to sync outside a .codex/.claude skills directory: $Target"
    }

    New-Item -ItemType Directory -Path $parent -Force | Out-Null

    if (Test-Path -LiteralPath $targetFull) {
        Remove-Item -LiteralPath $targetFull -Recurse -Force
    }

    Copy-Item -LiteralPath $Source -Destination $targetFull -Recurse -Force
    return $targetFull
}

Assert-SkillRoot -Path $SkillRoot

$synced = New-Object System.Collections.Generic.List[string]
$windowsClaudeTarget = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
$synced.Add((Sync-LocalSkill -Source $SkillRoot -Target $windowsClaudeTarget))

if (Test-Path -LiteralPath $LinuxCodeDrive) {
    $linuxProjectCodexTarget = Join-Path $LinuxCodeDrive ".codex\skills\$SkillName"
    $linuxProjectClaudeTarget = Join-Path $LinuxCodeDrive ".claude\skills\$SkillName"
    $synced.Add((Sync-LocalSkill -Source $SkillRoot -Target $linuxProjectCodexTarget))
    $synced.Add((Sync-LocalSkill -Source $SkillRoot -Target $linuxProjectClaudeTarget))
}

if (-not $SkipSsh) {
    $sshProbe = & ssh.exe -o BatchMode=yes -o ConnectTimeout=3 $LinuxHost "printf direct-link-ok" 2>$null
    if ($LASTEXITCODE -eq 0 -and (($sshProbe -join "") -eq "direct-link-ok")) {
        $archive = Join-Path ([System.IO.Path]::GetTempPath()) ("{0}-{1}.tgz" -f $SkillName, [guid]::NewGuid().ToString("n"))
        $remoteInstaller = Join-Path ([System.IO.Path]::GetTempPath()) ("{0}-install-{1}.sh" -f $SkillName, [guid]::NewGuid().ToString("n"))
        $sourceParent = Split-Path -Parent $SkillRoot
        try {
            & tar.exe -C $sourceParent -czf $archive $SkillName
            if ($LASTEXITCODE -ne 0) {
                throw "tar failed with exit code $LASTEXITCODE"
            }

            & scp.exe -q $archive "$LinuxHost`:/tmp/$SkillName-skill.tgz"
            if ($LASTEXITCODE -ne 0) {
                throw "scp failed with exit code $LASTEXITCODE"
            }

            @"
set -euo pipefail
tmp=`$(mktemp -d)
tar -xzf /tmp/$SkillName-skill.tgz -C "`$tmp"
mkdir -p "`$HOME/.codex/skills" "`$HOME/.claude/skills" "`$HOME/code/.codex/skills" "`$HOME/code/.claude/skills"
rm -rf "`$HOME/.codex/skills/$SkillName" "`$HOME/.claude/skills/$SkillName" "`$HOME/code/.codex/skills/$SkillName" "`$HOME/code/.claude/skills/$SkillName"
cp -a "`$tmp/$SkillName" "`$HOME/.codex/skills/"
cp -a "`$tmp/$SkillName" "`$HOME/.claude/skills/"
cp -a "`$tmp/$SkillName" "`$HOME/code/.codex/skills/"
cp -a "`$tmp/$SkillName" "`$HOME/code/.claude/skills/"
chmod +x "`$HOME/.codex/skills/$SkillName/scripts/status-linux.sh" "`$HOME/.claude/skills/$SkillName/scripts/status-linux.sh" "`$HOME/code/.codex/skills/$SkillName/scripts/status-linux.sh" "`$HOME/code/.claude/skills/$SkillName/scripts/status-linux.sh" 2>/dev/null || true
rm -rf "`$tmp" /tmp/$SkillName-skill.tgz /tmp/$SkillName-install.sh
printf '%s\n' "`$HOME/.codex/skills/$SkillName" "`$HOME/.claude/skills/$SkillName" "`$HOME/code/.codex/skills/$SkillName" "`$HOME/code/.claude/skills/$SkillName"
"@ | Set-Content -LiteralPath $remoteInstaller -Encoding ASCII

            & scp.exe -q $remoteInstaller "$LinuxHost`:/tmp/$SkillName-install.sh"
            if ($LASTEXITCODE -ne 0) {
                throw "scp remote installer failed with exit code $LASTEXITCODE"
            }

            $remotePaths = & ssh.exe $LinuxHost "bash /tmp/$SkillName-install.sh"
            if ($LASTEXITCODE -ne 0) {
                throw "remote install failed with exit code $LASTEXITCODE"
            }

            foreach ($remotePath in $remotePaths) {
                if ($remotePath) {
                    $synced.Add("$LinuxHost`:$remotePath")
                }
            }
        } finally {
            if (Test-Path -LiteralPath $archive) {
                Remove-Item -LiteralPath $archive -Force
            }
            if (Test-Path -LiteralPath $remoteInstaller) {
                Remove-Item -LiteralPath $remoteInstaller -Force
            }
        }
    } else {
        Write-Warning "SSH to $LinuxHost is not available; skipped personal Linux skill install."
    }
}

[pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    skill = $SkillName
    source = $SkillRoot
    syncedTargets = $synced.ToArray()
} | ConvertTo-Json -Depth 4
