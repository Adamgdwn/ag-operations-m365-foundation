param(
    [string]$AdminUpn = "adamgoodwin@guidedailabs.com",
    [string]$OutputRoot = ".\inventory\stage-5-exchange-current-state"
)

# Stage 5 - Exchange & Communication Routing : READ-ONLY inventory.
# Changes NOTHING. Signs you into Exchange Online interactively, then exports the
# mailbox, alias, forwarding, delegate, group, recipient, and calendar-processing
# posture needed to make Stage 5 decisions.
#
# Plan: M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Export-Json {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $true)] $Data
    )
    $Data | ConvertTo-Json -Depth 20 | Out-File -FilePath $Path -Encoding utf8
}

function Invoke-InventoryStep {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [scriptblock]$ScriptBlock
    )

    Write-Section $Name
    try {
        $data = @(& $ScriptBlock)
        Export-Json -Path (Join-Path $script:OutputDir "$Name.json") -Data $data
        Write-Host "Saved $Name.json ($($data.Count) item(s))" -ForegroundColor Green
        return $data
    }
    catch {
        $errorRecord = [pscustomobject]@{
            area = $Name
            error = $_.Exception.Message
        }
        Export-Json -Path (Join-Path $script:OutputDir "$Name.error.json") -Data $errorRecord
        Write-Host "Skipped ${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

function Select-ProxyAddresses {
    param($Addresses)
    @($Addresses | ForEach-Object { [string]$_ })
}

function Get-Stage5MailboxInventory {
    try {
        Get-Mailbox -ResultSize Unlimited -ErrorAction Stop |
            Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails,HiddenFromAddressListsEnabled,WhenMailboxCreated,ForwardingSmtpAddress,ForwardingAddress,DeliverToMailboxAndForward,GrantSendOnBehalfTo,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    }
    catch {
        Write-Host "Get-Mailbox was unavailable; falling back to Get-EXOMailbox." -ForegroundColor Yellow
        Get-EXOMailbox -ResultSize Unlimited -Properties `
            EmailAddresses,ForwardingSmtpAddress,ForwardingAddress,DeliverToMailboxAndForward,HiddenFromAddressListsEnabled,GrantSendOnBehalfTo,WhenMailboxCreated |
            Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails,HiddenFromAddressListsEnabled,WhenMailboxCreated,ForwardingSmtpAddress,ForwardingAddress,DeliverToMailboxAndForward,GrantSendOnBehalfTo,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    }
}

function Get-Stage5RecipientInventory {
    try {
        Get-Recipient -ResultSize Unlimited -ErrorAction Stop |
            Select-Object DisplayName,PrimarySmtpAddress,RecipientType,RecipientTypeDetails,ExternalEmailAddress,HiddenFromAddressListsEnabled,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    }
    catch {
        Write-Host "Get-Recipient was unavailable; falling back to Get-EXORecipient." -ForegroundColor Yellow
        Get-EXORecipient -ResultSize Unlimited -Properties EmailAddresses,ExternalEmailAddress,HiddenFromAddressListsEnabled |
            Select-Object DisplayName,PrimarySmtpAddress,RecipientType,RecipientTypeDetails,ExternalEmailAddress,HiddenFromAddressListsEnabled,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$script:OutputDir = Join-Path $OutputRoot $timestamp
New-Item -ItemType Directory -Force -Path $script:OutputDir | Out-Null

Write-Host "Microsoft 365 Stage 5 - Exchange inventory (READ-ONLY)" -ForegroundColor Cyan
Write-Host "Output folder: $script:OutputDir"
Write-Host ""
Write-Host "This run is non-destructive. It only READS Exchange Online configuration." -ForegroundColor Green
Write-Host "Sign in as $AdminUpn or another account with Exchange visibility." -ForegroundColor Yellow

$exo = Get-Module -ListAvailable -Name ExchangeOnlineManagement | Sort-Object Version -Descending | Select-Object -First 1
if ($null -eq $exo) {
    Write-Host ""
    Write-Host "ExchangeOnlineManagement is not installed. Install with:" -ForegroundColor Red
    Write-Host "    Install-Module ExchangeOnlineManagement -Scope CurrentUser" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host ("Using ExchangeOnlineManagement {0}" -f $exo.Version) -ForegroundColor Gray
Import-Module ExchangeOnlineManagement

Write-Section "Connect"
Connect-ExchangeOnline -UserPrincipalName $AdminUpn -ShowBanner:$false

try {
    $mailboxes = Invoke-InventoryStep -Name "mailboxes" -ScriptBlock {
        Get-Stage5MailboxInventory
    }

    Invoke-InventoryStep -Name "recipients" -ScriptBlock {
        Get-Stage5RecipientInventory
    } | Out-Null

    Invoke-InventoryStep -Name "distribution-groups" -ScriptBlock {
        Get-DistributionGroup -ResultSize Unlimited |
            Select-Object DisplayName,PrimarySmtpAddress,RecipientTypeDetails,ManagedBy,RequireSenderAuthenticationEnabled,HiddenFromAddressListsEnabled,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    } | Out-Null

    Invoke-InventoryStep -Name "m365-groups" -ScriptBlock {
        Get-UnifiedGroup -ResultSize Unlimited |
            Select-Object DisplayName,PrimarySmtpAddress,Alias,AccessType,HiddenFromAddressListsEnabled,RequireSenderAuthenticationEnabled,
                @{ Name = "EmailAddresses"; Expression = { Select-ProxyAddresses $_.EmailAddresses } }
    } | Out-Null

    Invoke-InventoryStep -Name "mailbox-permissions" -ScriptBlock {
        foreach ($mailbox in $mailboxes) {
            $identity = [string]$mailbox.PrimarySmtpAddress
            Get-MailboxPermission -Identity $identity -ErrorAction SilentlyContinue |
                Where-Object {
                    -not $_.IsInherited -and
                    $_.User -notlike "NT AUTHORITY\SELF" -and
                    $_.User -notlike "S-1-5-*"
                } |
                Select-Object @{ Name = "Mailbox"; Expression = { $identity } }, User, AccessRights, Deny, IsInherited
        }
    } | Out-Null

    Invoke-InventoryStep -Name "recipient-permissions" -ScriptBlock {
        foreach ($mailbox in $mailboxes) {
            $identity = [string]$mailbox.PrimarySmtpAddress
            Get-RecipientPermission -Identity $identity -ErrorAction SilentlyContinue |
                Where-Object { $_.Trustee -notlike "NT AUTHORITY\SELF" } |
                Select-Object @{ Name = "Mailbox"; Expression = { $identity } }, Trustee, AccessRights, IsInherited, Deny
        }
    } | Out-Null

    Invoke-InventoryStep -Name "calendar-processing" -ScriptBlock {
        foreach ($mailbox in $mailboxes) {
            $identity = [string]$mailbox.PrimarySmtpAddress
            Get-CalendarProcessing -Identity $identity -ErrorAction SilentlyContinue |
                Select-Object Identity,AutomateProcessing,BookingWindowInDays,MaximumDurationInMinutes,AllowConflicts,AllBookInPolicy,AllRequestInPolicy,AllRequestOutOfPolicy,ResourceDelegates
        }
    } | Out-Null

    $summary = [pscustomobject]@{
        generatedAt = (Get-Date).ToString("o")
        adminUpn = $AdminUpn
        mailboxes = @($mailboxes).Count
        userMailboxes = @($mailboxes | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }).Count
        sharedMailboxes = @($mailboxes | Where-Object { $_.RecipientTypeDetails -eq "SharedMailbox" }).Count
        outputFolder = (Resolve-Path $script:OutputDir).Path
    }
    Export-Json -Path (Join-Path $script:OutputDir "summary.json") -Data $summary

    Write-Section "Summary"
    $summary | Format-List | Out-Host
}
finally {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
}

Write-Host ""
Write-Host "Stage 5 Exchange inventory complete." -ForegroundColor Green
