# B6 Guided AI Journey Intake Proof

- Generated: 2026-06-25T18:07:37.1068877-06:00
- Mode: local-prep
- Entry point: Direct Journey Microsoft Form link
- Safety: No tenant write is performed by this script. B6 live source proof requires a manual/client-style form submission through an existing create-only intake path.

## Local Evidence
- B5 evidence: recorded: Decision Register #6; Agent Action Log #10
- Journey flow: GAIL — Guided AI Journey intake to CRM (create-only)
- Journey flow state: Started
- Target list id: a64ef810-ad45-407b-b1ea-516533a8611d
- Microsoft Form URL: https://forms.office.com/Pages/ResponsePage.aspx?id=9SqpHP8h40KHrjvenCzFASrxRIPpTrVLlUoFbsCgkAhUNjVFTjAyQzFYTUFQTUxCV0ZLRzdVTU5JNC4u
- Custom form contract: RELEASED — endpoint LIVE + verified; build the branded form against this contract

## Dummy Submission Values
- Full name: GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY
- Email: adam+gail-b6-journey-20260625-180736@guidedailabs.com
- Organization: Guided AI Labs Internal Walkthrough
- What are you looking for: GAIL-INTERNAL-WALKTHROUGH-B6-JOURNEY 20260625-180736 - verifying Guided AI Journey client invite intake creates one CRM New Signal for M365 Interaction Agent triage.
- What best describes your situation: My team - I want to build team capability
- How did you hear about us: Internal B6 source proof after B5 Decision Register #6.
- Consent: I agree

## Verify After Manual Submission

```powershell
.\scripts\Start-M365B6JourneyIntakeProofInteractive.ps1 -Verify -ForceFreshLogin
```

This verification reads CRM only. It does not write a CRM item, Agent Action Log row, Teams message, task, email, permission, app, guest, sharing setting, or tenant policy.
