# QUO API Key Readiness

Date: 2026-06-28

Status: B10c.0 local key import complete; dry-run readiness check passed. This
is local credential readiness and optional read-only validation only. It is not
full QUO source ingestion.

Owner: Adam.

Related active plan:
`docs/2026-06-28_M365_INTERACTION_AGENT_ACTIVE_BUILD_PLAN.md`

Source contract:
`docs/2026-06-28_QUO_INBOUND_SOURCE_CONTRACT.md`

Config:
`config/M365_INTERACTION_AGENT_B10C_QUO_API_KEY_READINESS.json`

## Purpose

Adam now has a QUO API key, so the next safe move is to integrate the key
without opening the whole phone/SMS source lane at once.

B10c.0 does three things:

- captures the QUO API key into an encrypted local-only file;
- provides a dry-run readiness check that performs no API call;
- provides an explicit read-only live probe for `GET /v1/phone-numbers` when
  Adam approves that source read.

It does not create a QUO webhook, process calls/SMS/voicemail, write CRM rows,
post Teams alerts, or send any outbound QUO action.

Current result:

- key imported from Adam's local text file into encrypted local storage;
- dry-run readiness evidence written under
  `inventory/m365-interaction-agent-b10/`;
- no QUO API call was made during the import or dry-run check.

## Current QUO API Facts

Verified against QUO API docs on 2026-06-28:

| Fact | Current value |
|---|---|
| API base | `https://api.quo.com` |
| API version path | `/v1` |
| Authentication | `Authorization` header contains the API key value |
| Read-only readiness probe | `GET /v1/phone-numbers` |
| Webhooks | Later B10c gate; not enabled by this readiness step |

Reference docs:

- `https://www.quo.com/docs/mdx/api-reference/introduction`
- `https://www.quo.com/docs/mdx/api-reference/authentication`
- `https://www.quo.com/docs/mdx/api-reference/phone-numbers/list-phone-numbers`
- `https://www.quo.com/docs/mdx/api-reference/webhooks/create-a-new-webhook`

## Local Secret Storage

Primary storage:

```text
.local/quo-ingress/quo-api-key.secret
```

Metadata:

```text
.local/quo-ingress/quo-api-key.metadata.json
```

The secret file is encrypted with Windows DPAPI for the current Windows user via
PowerShell `ConvertFrom-SecureString`. The `.local/` directory is ignored by git.

Fallback for temporary shell sessions:

```powershell
$env:QUO_API_KEY = "<local process only>"
```

Do not put `QUO_API_KEY` in committed docs, config, inventory, screenshots, or
chat. If a local environment file is used, it must be an ignored `*.local.env`
file.

## Commands

Open the visible key capture window:

```powershell
.\scripts\quo\Set-QuoLocalApiKey.ps1 -Window
```

Dry-run readiness check with no API call:

```powershell
.\scripts\quo\Test-QuoApiKeyReadiness.ps1
```

Read-only live key validation after approval:

```powershell
.\scripts\quo\Test-QuoApiKeyReadiness.ps1 -LiveReadApproved
```

Optional raw response retention, local only:

```powershell
.\scripts\quo\Test-QuoApiKeyReadiness.ps1 -LiveReadApproved -StoreRawLocal
```

Raw storage stays under `.local/quo-ingress/raw/` and must not be committed.

## Readiness Probe Behavior

The live probe:

- calls only `GET https://api.quo.com/v1/phone-numbers`;
- uses the API key in the `Authorization` header;
- writes sanitized evidence to
  `inventory/m365-interaction-agent-b10/b10c-quo-api-key-readiness-*.json`;
- redacts phone numbers to last four digits;
- reduces display names to `hasDisplayName`;
- stores no API key and no raw response body in committed evidence by default.

## Blocked Until Later B10c Approval

- QUO webhook creation or mutation.
- Webhook signing secret setup.
- Call log, SMS body, voicemail transcript, recording, or real client payload
  ingestion.
- CRM `CRM - New Signals` writes.
- New Signal Teams posts.
- Automatic SMS replies, callbacks, outbound calls, or QUO send actions.
- Any unattended source bridge.

## Next Gate

After key readiness, B10c still needs Adam to choose:

- exact QUO business number or internal test number;
- first event class;
- ingress pattern;
- webhook secret/signature storage and revoke path;
- raw payload retention/redaction;
- dedupe rule;
- owner and visible disable path;
- no-real-client/internal test scope;
- confirmation that outbound QUO actions remain blocked.

Until that gate is complete, QUO remains integrated only as a local credential
and optional read-only inventory probe.
