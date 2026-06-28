param(
    [switch]$LiveReadApproved,
    [switch]$StoreRawLocal,
    [string]$ApiBaseUrl = "https://api.quo.com",
    [string]$SecretPath = "",
    [string]$OutputDirectory = "",
    [string]$RawOutputDirectory = "",
    [int]$TimeoutSeconds = 30
)

# Read-only QUO API key readiness probe.
# Default mode is dry-run: it checks local setup only and performs no API call.
# Live mode uses GET /v1/phone-numbers, writes sanitized evidence, and performs
# no QUO writes, webhook setup, SMS/call/reply action, M365 write, or Teams post.

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)

if ([string]::IsNullOrWhiteSpace($SecretPath)) {
    $SecretPath = Join-Path $workspaceRoot ".local\quo-ingress\quo-api-key.secret"
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $workspaceRoot "inventory\m365-interaction-agent-b10"
}

if ([string]::IsNullOrWhiteSpace($RawOutputDirectory)) {
    $RawOutputDirectory = Join-Path $workspaceRoot ".local\quo-ingress\raw"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$summaryJsonPath = Join-Path $OutputDirectory ("b10c-quo-api-key-readiness-{0}.json" -f $stamp)
$summaryMdPath = Join-Path $OutputDirectory ("b10c-quo-api-key-readiness-{0}.md" -f $stamp)
$rawJsonPath = Join-Path $RawOutputDirectory ("quo-phone-numbers-raw-{0}.json" -f $stamp)

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

function Get-PlainTextFromSecureString {
    param([securestring]$SecureValue)

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Get-QuoApiKey {
    if (-not [string]::IsNullOrWhiteSpace($env:QUO_API_KEY)) {
        return [pscustomobject]@{
            Source = "env:QUO_API_KEY"
            Value = $env:QUO_API_KEY
        }
    }

    if (-not (Test-Path -LiteralPath $SecretPath)) {
        throw "No QUO API key found. Run scripts/quo/Set-QuoLocalApiKey.ps1 -Window first, or set QUO_API_KEY for this process."
    }

    $encrypted = Get-Content -LiteralPath $SecretPath -Raw
    $secure = ConvertTo-SecureString -String $encrypted
    return [pscustomobject]@{
        Source = $SecretPath
        Value = Get-PlainTextFromSecureString -SecureValue $secure
    }
}

function Get-PropertyValue {
    param(
        [object]$Object,
        [string[]]$Names
    )

    if ($null -eq $Object) { return $null }
    $properties = @($Object.PSObject.Properties)
    foreach ($name in $Names) {
        $property = $properties | Where-Object { $_.Name -ieq $name } | Select-Object -First 1
        if ($null -ne $property) {
            return $property.Value
        }
    }

    return $null
}

function Redact-Phone {
    param([object]$Value)

    if ($null -eq $Value) { return $null }
    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) { return "" }

    $digits = $text -replace "\D", ""
    if ($digits.Length -ge 4) {
        return ("redacted-last4-{0}" -f $digits.Substring($digits.Length - 4))
    }

    return "redacted"
}

function ConvertTo-SanitizedPhoneNumberRecord {
    param([object]$Record)

    $id = Get-PropertyValue -Object $Record -Names @("id", "phoneNumberId", "uuid")
    $number = Get-PropertyValue -Object $Record -Names @("phoneNumber", "number", "e164", "value")
    $name = Get-PropertyValue -Object $Record -Names @("name", "label", "friendlyName", "displayName")
    $status = Get-PropertyValue -Object $Record -Names @("status", "state")
    $type = Get-PropertyValue -Object $Record -Names @("type", "kind")
    $capabilities = Get-PropertyValue -Object $Record -Names @("capabilities", "features")

    [pscustomobject][ordered]@{
        id = if ($null -eq $id) { $null } else { [string]$id }
        numberRedacted = Redact-Phone -Value $number
        hasDisplayName = -not [string]::IsNullOrWhiteSpace([string]$name)
        status = if ($null -eq $status) { $null } else { [string]$status }
        type = if ($null -eq $type) { $null } else { [string]$type }
        capabilities = $capabilities
        fieldNames = @($Record.PSObject.Properties.Name)
    }
}

function Get-RecordsFromResponse {
    param([object]$Response)

    if ($null -eq $Response) { return @() }
    if ($Response -is [array]) { return @($Response) }

    foreach ($name in @("data", "phoneNumbers", "items", "results", "value")) {
        $value = Get-PropertyValue -Object $Response -Names @($name)
        if ($null -ne $value) {
            if ($value -is [array]) { return @($value) }
            return @($value)
        }
    }

    return @($Response)
}

$summary = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    chunk = "B10c.0"
    sourceSystem = "QUO"
    mode = if ($LiveReadApproved) { "live-read-approved" } else { "dry-run-no-api-call" }
    authority = if ($LiveReadApproved) { "G3/R3 restricted read-only source readiness" } else { "G0/R0 local readiness" }
    apiBaseUrl = $ApiBaseUrl
    endpoint = "/v1/phone-numbers"
    method = "GET"
    liveSystemsTouched = $false
    keyPresent = (-not [string]::IsNullOrWhiteSpace($env:QUO_API_KEY)) -or (Test-Path -LiteralPath $SecretPath)
    keySource = if (-not [string]::IsNullOrWhiteSpace($env:QUO_API_KEY)) { "env:QUO_API_KEY" } elseif (Test-Path -LiteralPath $SecretPath) { $SecretPath } else { "missing" }
    outboundBlocked = $true
    crmTouched = $false
    teamsTouched = $false
    webhookTouched = $false
    rawStored = $false
    rawLocalPath = $null
    responseStatus = $null
    responseDigest = $null
    phoneNumberCount = 0
    sanitizedPhoneNumbers = @()
    error = $null
    notes = @(
        "Default mode performs no API call.",
        "Live mode uses a read-only phone-number inventory endpoint for key validation.",
        "Committed evidence is sanitized; raw payload storage requires -StoreRawLocal and stays under .local.",
        "No outbound QUO action, CRM write, Teams post, or webhook setup is performed."
    )
}

if ($LiveReadApproved) {
    $keyRecord = Get-QuoApiKey
    $headers = @{
        "Authorization" = $keyRecord.Value
        "Accept" = "application/json"
        "User-Agent" = "GuidedAILabs-M365InteractionAgent-B10cKeyReadiness/1.0"
    }
    $uri = $ApiBaseUrl.TrimEnd("/") + "/v1/phone-numbers"

    try {
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -TimeoutSec $TimeoutSeconds
        $summary.liveSystemsTouched = $true
        $summary.responseStatus = "success"

        $rawJson = $response | ConvertTo-Json -Depth 32
        $summary.responseDigest = "sha256:{0}" -f (Get-Sha256Hex -Value $rawJson)

        if ($StoreRawLocal) {
            New-Item -ItemType Directory -Force -Path $RawOutputDirectory | Out-Null
            Set-Content -LiteralPath $rawJsonPath -Value $rawJson -Encoding UTF8
            $summary.rawStored = $true
            $summary.rawLocalPath = $rawJsonPath
        }

        $records = @(Get-RecordsFromResponse -Response $response)
        $summary.phoneNumberCount = $records.Count
        $summary.sanitizedPhoneNumbers = @($records | ForEach-Object { ConvertTo-SanitizedPhoneNumberRecord -Record $_ })
    }
    catch {
        $summary.liveSystemsTouched = $true
        $statusCode = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }

        $summary.responseStatus = "error"
        $summary.error = [ordered]@{
            type = $_.Exception.GetType().FullName
            message = $_.Exception.Message
            statusCode = $statusCode
            note = "No API key or raw response body is stored in committed evidence."
        }
    }
}

$summary | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $summaryJsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# B10c QUO API Key Readiness")
$lines.Add("")
$lines.Add(("Generated: {0}" -f $summary.generatedAt))
$lines.Add(("Mode: {0}" -f $summary.mode))
$lines.Add(("Authority: {0}" -f $summary.authority))
$lines.Add("")
$lines.Add("## Result")
$lines.Add("")
$lines.Add(("- Key present: {0}" -f $summary.keyPresent))
$lines.Add(("- Key source: {0}" -f $summary.keySource))
$lines.Add(("- Live systems touched: {0}" -f $summary.liveSystemsTouched))
$lines.Add(("- Response status: {0}" -f $summary.responseStatus))
$lines.Add(("- Phone number count: {0}" -f $summary.phoneNumberCount))
$lines.Add(("- Raw stored: {0}" -f $summary.rawStored))
if ($summary.rawStored) {
    $lines.Add(('- Raw local path: `{0}`' -f $summary.rawLocalPath))
}
$lines.Add("")
$lines.Add("## Boundaries")
$lines.Add("")
$lines.Add("- No outbound QUO SMS, call, callback, reply, or send action.")
$lines.Add("- No QUO webhook creation or mutation.")
$lines.Add("- No Microsoft 365, CRM, or Teams write.")
$lines.Add("- Committed evidence is sanitized.")
$lines.Add("")
$lines.Add("## Sanitized Phone Numbers")
$lines.Add("")
if ($summary.sanitizedPhoneNumbers.Count -eq 0) {
    $lines.Add("No phone-number records are included in this evidence.")
}
else {
    $lines.Add("| Id | Number | Has display name | Status | Type |")
    $lines.Add("|---|---|---|---|---|")
    foreach ($record in @($summary.sanitizedPhoneNumbers)) {
        $lines.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $record.id, $record.numberRedacted, $record.hasDisplayName, $record.status, $record.type))
    }
}

if ($null -ne $summary.error) {
    $lines.Add("")
    $lines.Add("## Error")
    $lines.Add("")
    $lines.Add(("- Type: {0}" -f $summary.error.type))
    $lines.Add(("- Message: {0}" -f $summary.error.message))
    $lines.Add(("- Status code: {0}" -f $summary.error.statusCode))
}

$lines | Set-Content -LiteralPath $summaryMdPath -Encoding UTF8

Write-Host "QUO API key readiness evidence written." -ForegroundColor Cyan
Write-Host ("JSON: {0}" -f $summaryJsonPath)
Write-Host ("MD:   {0}" -f $summaryMdPath)
Write-Host ("Mode: {0}" -f $summary.mode)
if ($summary.responseStatus -eq "error") {
    Write-Host ("Response error: {0}" -f $summary.error.message) -ForegroundColor Yellow
}
