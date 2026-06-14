param(
    [string]$InventoryRoot = ".\inventory\stage-5-exchange-current-state",
    [string]$RunPath,
    [string]$OutputPath
)

# Stage 5 - Exchange & Communication Routing : local JSON summarizer.
# Reads a completed inventory run and writes a Markdown summary for decisions.

$ErrorActionPreference = "Stop"

function Get-LatestInventoryRun {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root)) {
        throw "Inventory root not found: $Root"
    }

    $runsWithSummary = Get-ChildItem -LiteralPath $Root -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "summary.json") } |
        Sort-Object Name -Descending

    if ($runsWithSummary) {
        return $runsWithSummary[0].FullName
    }

    $runs = Get-ChildItem -LiteralPath $Root -Directory | Sort-Object Name -Descending
    if (-not $runs) {
        throw "No inventory run folders found under: $Root"
    }

    return $runs[0].FullName
}

function Read-JsonArray {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [switch]$Optional
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($Optional) {
            return @()
        }
        throw "Required JSON file not found: $Path"
    }

    $file = Get-Item -LiteralPath $Path
    if ($file.Length -eq 0) {
        return @()
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @()
    }

    $value = $raw | ConvertFrom-Json
    if ($null -eq $value) {
        return @()
    }

    return @($value)
}

function Format-Field {
    param($Value)

    if ($null -eq $Value) {
        return "-"
    }

    $items = @($Value) |
        Where-Object { $null -ne $_ -and [string]$_ -ne "" } |
        ForEach-Object { [string]$_ }

    if (-not $items) {
        return "-"
    }

    return (($items | Select-Object -Unique) -join ", ")
}

function Escape-MarkdownCell {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "-"
    }

    return ($Value -replace "\|", "\|")
}

function Add-MarkdownTable {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string[]]$Headers,
        [object[]]$Rows
    )

    $Lines.Add("| " + ($Headers -join " | ") + " |")
    $Lines.Add("| " + (($Headers | ForEach-Object { "---" }) -join " | ") + " |")

    foreach ($row in $Rows) {
        $cells = foreach ($header in $Headers) {
            Escape-MarkdownCell ([string]$row.$header)
        }
        $Lines.Add("| " + ($cells -join " | ") + " |")
    }

    if (-not $Rows -or $Rows.Count -eq 0) {
        $Lines.Add("| " + (($Headers | ForEach-Object { "-" }) -join " | ") + " |")
    }

    $Lines.Add("")
}

if (-not $RunPath) {
    $RunPath = Get-LatestInventoryRun -Root $InventoryRoot
}

$resolvedRun = (Resolve-Path -LiteralPath $RunPath).Path
if (-not $OutputPath) {
    $OutputPath = Join-Path $resolvedRun "stage-5-exchange-current-state-summary.md"
}

$summary = Read-JsonArray -Path (Join-Path $resolvedRun "summary.json") -Optional |
    Select-Object -First 1
$mailboxes = Read-JsonArray -Path (Join-Path $resolvedRun "mailboxes.json") -Optional
$recipients = Read-JsonArray -Path (Join-Path $resolvedRun "recipients.json") -Optional
$mailboxPermissions = Read-JsonArray -Path (Join-Path $resolvedRun "mailbox-permissions.json") -Optional
$recipientPermissions = Read-JsonArray -Path (Join-Path $resolvedRun "recipient-permissions.json") -Optional
$calendarProcessing = Read-JsonArray -Path (Join-Path $resolvedRun "calendar-processing.json") -Optional
$calendarRowsHaveMailbox = @($calendarProcessing | Where-Object { $_.PSObject.Properties.Name -contains "Mailbox" }).Count -gt 0
$distributionGroups = Read-JsonArray -Path (Join-Path $resolvedRun "distribution-groups.json") -Optional
$m365Groups = Read-JsonArray -Path (Join-Path $resolvedRun "m365-groups.json") -Optional
$errorFiles = Get-ChildItem -LiteralPath $resolvedRun -Filter "*.error.json" -File -ErrorAction SilentlyContinue

$decisionAddresses = @(
    "admin@agoperations.ca",
    "adamgoodwin@guidedailabs.com",
    "contact@guidedailabs.com",
    "support@changeleadershiptools.com"
)

$mailboxRows = foreach ($address in $decisionAddresses) {
    $mailbox = $mailboxes | Where-Object {
        [string]$_.PrimarySmtpAddress -ieq $address -or
        [string]$_.UserPrincipalName -ieq $address -or
        @($_.EmailAddresses | ForEach-Object { [string]$_ }) -match "(?i)^smtp:$([regex]::Escape($address))$"
    } | Select-Object -First 1

    if ($null -eq $mailbox) {
        [pscustomobject]@{
            Address = $address
            "Display name" = "not found"
            Type = "-"
            Aliases = "-"
            Forwarding = "-"
            "Full access" = "-"
            "Send as" = "-"
            "Send behalf" = "-"
            Calendar = "-"
        }
        continue
    }

    $primary = [string]$mailbox.PrimarySmtpAddress
    $aliases = @($mailbox.EmailAddresses | ForEach-Object { [string]$_ }) |
        Where-Object { $_ -like "smtp:*" } |
        ForEach-Object { $_.Substring(5) } |
        Where-Object { $_ -ine $primary }

    $forwarding = @(
        $mailbox.ForwardingSmtpAddress
        $mailbox.ForwardingAddress
        if ($mailbox.DeliverToMailboxAndForward) { "deliver-and-forward" }
    )

    $fullAccess = $mailboxPermissions |
        Where-Object { [string]$_.Mailbox -ieq $primary } |
        ForEach-Object { "{0} ({1})" -f $_.User, (Format-Field $_.AccessRights) }

    $sendAs = $recipientPermissions |
        Where-Object { [string]$_.Mailbox -ieq $primary } |
        ForEach-Object { "{0} ({1})" -f $_.Trustee, (Format-Field $_.AccessRights) }

    $calendar = $calendarProcessing |
        Where-Object {
            [string]$_.Mailbox -ieq $primary -or
            [string]$_.UserPrincipalName -ieq [string]$mailbox.UserPrincipalName -or
            [string]$_.Identity -like "*$primary*" -or
            [string]$_.Identity -like "*$($mailbox.UserPrincipalName)*"
        } |
        Select-Object -First 1

    [pscustomobject]@{
        Address = $address
        "Display name" = Format-Field $mailbox.DisplayName
        Type = Format-Field $mailbox.RecipientTypeDetails
        Aliases = Format-Field $aliases
        Forwarding = Format-Field $forwarding
        "Full access" = Format-Field $fullAccess
        "Send as" = Format-Field $sendAs
        "Send behalf" = Format-Field $mailbox.GrantSendOnBehalfTo
        Calendar = if ($calendar) {
            Format-Field $calendar.AutomateProcessing
        }
        elseif ($calendarProcessing.Count -gt 0 -and -not $calendarRowsHaveMailbox) {
            "exported; unmapped"
        }
        else {
            "-"
        }
    }
}

$openGroupRows = @(
    $distributionGroups | Where-Object { $_.RequireSenderAuthenticationEnabled -eq $false } |
        ForEach-Object {
            [pscustomobject]@{
                Type = "Distribution group"
                Name = Format-Field $_.DisplayName
                Address = Format-Field $_.PrimarySmtpAddress
                "External senders" = "allowed"
            }
        }
    $m365Groups | Where-Object { $_.RequireSenderAuthenticationEnabled -eq $false } |
        ForEach-Object {
            [pscustomobject]@{
                Type = "Microsoft 365 group"
                Name = Format-Field $_.DisplayName
                Address = Format-Field $_.PrimarySmtpAddress
                "External senders" = "allowed"
            }
        }
)

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Stage 5 Exchange Current-State Summary")
$lines.Add("")
$lines.Add("Inventory run: ``$resolvedRun``")
if ($summary) {
    $generatedAt = if ($summary.generatedAt -is [datetime]) {
        $summary.generatedAt.ToString("o")
    }
    else {
        [string]$summary.generatedAt
    }
    $lines.Add("Generated at: ``$generatedAt``")
    $lines.Add("Admin UPN: ``$($summary.adminUpn)``")
}
$lines.Add("")
$lines.Add("This summary is generated from local inventory JSON. It makes no tenant changes.")
$lines.Add("")

$lines.Add("## Counts")
$lines.Add("")
$lines.Add("- Mailboxes: $(($mailboxes).Count)")
$lines.Add("- User mailboxes: $(($mailboxes | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }).Count)")
$lines.Add("- Shared mailboxes: $(($mailboxes | Where-Object { $_.RecipientTypeDetails -eq "SharedMailbox" }).Count)")
$lines.Add("- Recipients: $(($recipients).Count)")
$lines.Add("- Distribution groups: $(($distributionGroups).Count)")
$lines.Add("- Microsoft 365 groups: $(($m365Groups).Count)")
$lines.Add("- Error files: $(($errorFiles).Count)")
$lines.Add("")

$lines.Add("## Decision Addresses")
$lines.Add("")
Add-MarkdownTable -Lines $lines -Headers @(
    "Address",
    "Display name",
    "Type",
    "Aliases",
    "Forwarding",
    "Full access",
    "Send as",
    "Send behalf",
    "Calendar"
) -Rows @($mailboxRows)

$lines.Add("## Groups Accepting External Senders")
$lines.Add("")
Add-MarkdownTable -Lines $lines -Headers @(
    "Type",
    "Name",
    "Address",
    "External senders"
) -Rows @($openGroupRows)

$lines.Add("## Inventory Errors")
$lines.Add("")
if ($errorFiles) {
    foreach ($file in $errorFiles) {
        $errorData = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        $lines.Add("- ``$($file.Name)``: $($errorData.error)")
    }
}
else {
    $lines.Add("- None found.")
}
$lines.Add("")

$lines.Add("## Pending Decisions")
$lines.Add("")
$lines.Add("- 5.1: Decide mailbox type/license posture for ``contact@guidedailabs.com``.")
$lines.Add("- 5.2: Decide mailbox type/license posture for ``support@changeleadershiptools.com``.")
$lines.Add("- 5.3: Decide alias/group/shared-mailbox map.")
$lines.Add("- 5.4: Decide calendar ownership.")
$lines.Add("- 5.5: Decide intake routing and durable record capture.")
$lines.Add("")

$lines | Out-File -LiteralPath $OutputPath -Encoding utf8

Write-Host "Wrote Stage 5 summary:"
Write-Host (Resolve-Path -LiteralPath $OutputPath).Path
