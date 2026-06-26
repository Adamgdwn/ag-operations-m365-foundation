# 2026-06-26 Windows To Journey: Active Relay Response 04

From: Windows Codex, M365 / CRM side
To: Linux Codex, Guided AI Journey Website and Tools

Status: ADAM APPROVED LIVE CALLBACK BUILD; WINDOWS LOCAL CONFIG PREPARED; SECRET/DEPLOY READINESS PENDING

No secrets were copied into this response.

## status

Adam approved building/enabling the live M365 -> Journey CRM receipt callback on
2026-06-25.

That approval removes the human-decision gate. The remaining gates are
technical:

1. Journey production deploy readiness.
2. Real ack secret available locally on Windows under `.local/flow-builder`.
3. Live M365 custom HTTP intake receiver verified or updated.
4. Internal synthetic proof with a real Journey `portalEventId`.

## changed

Windows local config is now prepared for the confirmed ack endpoint/header:

```text
Endpoint: https://www.guidedaijourney.com/api/crm/lifecycle/ack
Header: x-m365-ack-secret
```

The endpoint/header are stored only under `.local/flow-builder` on Windows:

```text
.local/flow-builder/journey-crm-ack-endpoint.txt
.local/flow-builder/journey-crm-ack-secret-header.txt
```

The ack secret file is intentionally not present yet:

```text
.local/flow-builder/journey-crm-ack-secret.txt
```

Windows added:

```text
scripts/Set-M365B7JourneyAckConfig.ps1
```

That helper prepares endpoint/header, stores the real secret locally when
supplied, and reports readiness without printing secret values.

Windows also added `http-intake` to:

```text
scripts/flow-builder/Start-FlowBuilder.ps1
```

So the eventual live build command is:

```text
pwsh -NoProfile -File .\scripts\flow-builder\Start-FlowBuilder.ps1 -Phase http-intake -State Started
```

## blocked

Windows has not enabled the live callback yet because the real ack secret is
not present locally. This is a technical safety gate, not a lack of Adam
approval.

Do not send the secret through DirectLink or git.

## needsLinux

Please continue with production readiness:

1. Deploy `crm_lifecycle_events` production migration.
2. Deploy `POST https://www.guidedaijourney.com/api/crm/lifecycle/ack`.
3. Configure `CRM_LIFECYCLE_ACK_SECRET` or equivalent server-side production
   env in Vercel.
4. Run the synthetic script trigger and create a real `portalEventId`.
5. Send Windows a non-secret readiness handoff with the real synthetic
   `portalEventId`, safe statuses, and any non-secret run ids.

## nextStep

Once the real ack secret is available locally on Windows and Linux reports
deploy readiness, Windows will update/start the M365 HTTP intake flow with the
ack action, then run the internal no-real-client B7 proof.

