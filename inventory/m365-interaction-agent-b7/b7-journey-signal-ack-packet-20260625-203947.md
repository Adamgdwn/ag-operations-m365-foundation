# B7 Journey Signal Ack Test Packet

Generated: 2026-06-25T20:39:47.3709053-06:00

Safety: No Microsoft 365 connection, no HTTP send, no CRM write, no secret transfer.

## Journey -> M365 Payload

``json
{
  "schemaVersion": "journey.crm-signal.v1",
  "source": "Guided AI Journey",
  "signalMode": "system-invite-signal",
  "eventType": "journey.invite.sent.test",
  "correlationId": "GAIL-B7-ACK-TEST-20260625",
  "journeyInviteId": "journey-invite-test-20260625",
  "journeyOrganizationId": "journey-org-internal-walkthrough",
  "journeyLeadId": "journey-lead-20260625-203947",
  "inviteRole": "person",
  "fullName": "GAIL INTERNAL CRM ACK TEST",
  "email": "adam+journey-crm-ack-20260625@guidedailabs.com",
  "organization": "Guided AI Labs Internal Walkthrough",
  "leadContext": "Internal B7 proof that Journey invite signal reaches CRM and receives an acknowledgement.",
  "heardFrom": "Guided AI Journey invite/admin trigger",
  "consent": false,
  "company": "",
  "ackRequested": true,
  "testMode": true
}
``

## Expected M365 -> Journey Ack

``json
{
  "schemaVersion": "journey.crm-receipt.v1",
  "eventType": "m365.crm_signal.received",
  "source": "Guided AI Journey",
  "correlationId": "GAIL-B7-ACK-TEST-20260625",
  "journeyInviteId": "journey-invite-test-20260625",
  "journeyOrganizationId": "journey-org-internal-walkthrough",
  "journeyLeadId": "journey-lead-20260625-203947",
  "received": true,
  "crmItemId": 0,
  "crmItemUrl": "CRM display-form URL after item exists",
  "crmTitle": "Guided AI Journey - GAIL INTERNAL CRM ACK TEST",
  "signalStatus": "New",
  "priority": "Normal",
  "receivedAt": "CRM Created timestamp",
  "ackGeneratedAt": "M365 acknowledgement timestamp"
}
``

## Next Steps

- Journey side sends payload to the existing server-side custom intake endpoint.
- M365 verifies one CRM - New Signals item contains this correlation id.
- After Journey provides an ack endpoint and secret, M365 sends expectedAck with real CRM item values.
