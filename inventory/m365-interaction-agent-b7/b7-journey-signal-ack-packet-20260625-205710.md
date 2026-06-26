# B7 Journey Signal Ack Test Packet

Generated: 2026-06-25T20:57:10.3881097-06:00

Safety: No Microsoft 365 connection, no HTTP send, no CRM write, no secret transfer.

## Journey -> M365 Payload

``json
{
  "schemaVersion": "journey.crm-signal.v1",
  "source": "Guided AI Journey",
  "signalMode": "portal-lifecycle-event",
  "eventType": "organization_setup_saved",
  "portalEventId": "GAIL-B7-PORTAL-EVENT-20260625",
  "correlationId": "GAIL-B7-PORTAL-EVENT-20260625",
  "companyId": "journey-company-internal-walkthrough",
  "engagementId": "journey-engagement-internal-walkthrough",
  "inviteId": "journey-invite-test-20260625",
  "journeyInviteId": "journey-invite-test-20260625",
  "journeyOrganizationId": "journey-org-internal-walkthrough",
  "journeyLeadId": "journey-lead-20260625-205710",
  "inviteRole": "person",
  "sourceAction": "admin_invited_person",
  "portalDeepLink": "https://www.guidedaijourney.com/dashboard/internal-walkthrough",
  "eventTimestamp": "2026-06-26T02:57:10.3828103Z",
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
  "receivedEventType": "organization_setup_saved",
  "source": "Guided AI Journey",
  "portalEventId": "GAIL-B7-PORTAL-EVENT-20260625",
  "correlationId": "GAIL-B7-PORTAL-EVENT-20260625",
  "companyId": "journey-company-internal-walkthrough",
  "engagementId": "journey-engagement-internal-walkthrough",
  "inviteId": "journey-invite-test-20260625",
  "journeyInviteId": "journey-invite-test-20260625",
  "journeyOrganizationId": "journey-org-internal-walkthrough",
  "journeyLeadId": "journey-lead-20260625-205710",
  "crmStatus": "created",
  "received": true,
  "crmRecordId": "sharepoint-list-item-id",
  "crmRecordUrl": "CRM display-form URL after item exists",
  "crmItemId": 0,
  "crmItemUrl": "CRM display-form URL after item exists",
  "crmTitle": "Guided AI Journey - GAIL INTERNAL CRM ACK TEST",
  "signalStatus": "New",
  "priority": "Normal",
  "flowRunId": "optional Power Automate run id",
  "receivedAt": "CRM Created timestamp",
  "processedAt": "M365 acknowledgement timestamp",
  "ackGeneratedAt": "M365 acknowledgement timestamp",
  "message": "CRM - New Signals item created in Microsoft 365."
}
``

## Next Steps

- Journey side sends payload to the existing server-side custom intake endpoint.
- M365 verifies one CRM - New Signals item contains this portalEventId/correlation id.
- After Journey provides an ack endpoint and secret, M365 sends expectedAck with real CRM item values.
