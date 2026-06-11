# Microsoft 365 Stage 1 Current-State Inventory

Generated from Microsoft Graph REST inventory on 2026-06-10.

Source folder:

```text
inventory/stage-1-current-state/20260610-173554
```

## Executive Summary

The tenant inventory completed successfully for the core read-only Microsoft Graph surfaces.

Current high-level state:

| Area | Count / Finding |
|---|---:|
| Organization | A.G. Operations Ltd |
| Verified domains | 4 |
| Users | 4 |
| Groups | 3 |
| Subscribed SKUs | 1 |
| Active directory roles inventoried | 12 |
| Directory role assignments found | 14 |
| SharePoint sites found | 5 |
| App registrations | 1 |
| Enterprise applications | 169 |

Important immediate finding:

```text
contact@guidedailabs.com is currently a Global Administrator.
```

This should not be changed casually, but it should be addressed in Stage 2 after a proper backup/break-glass admin plan exists.

## Tenant And Domains

Tenant:

```text
A.G. Operations Ltd
```

Domains found:

| Domain | Default | Initial | Verified |
|---|---:|---:|---:|
| agoperations.ca | Yes | No | Yes |
| AGOperationsLtd.onmicrosoft.com | No | Yes | Yes |
| guidedailabs.com | No | No | Yes |
| changeleadershiptools.com | No | No | Yes |

Notes:

- The tenant does still have an initial `onmicrosoft.com` domain: `AGOperationsLtd.onmicrosoft.com`.
- `agoperations.ca` is the default domain.
- The expected custom domains are verified.

## Users

Users found:

| Display name | User principal name | Mail | Enabled | Type | Licenses |
|---|---|---|---:|---|---:|
| Adam Goodwin | admin@agoperations.ca | admin@agoperations.ca | Yes | Member | 1 |
| Adam Goodwin | adamgoodwin@guidedailabs.com | adamgoodwin@guidedailabs.com | Yes | Member | 1 |
| contact | contact@guidedailabs.com | contact@guidedailabs.com | Yes | Member | 1 |
| Support at ChangeTools | support@changeleadershiptools.com | support@changeleadershiptools.com | Yes | Member | 1 |

Notes:

- The four expected accounts are present and enabled.
- All four accounts currently have one assigned license.
- No guest users were found in this inventory pass.

## Licensing

Graph returned one subscribed SKU:

| SKU part number | Consumed | Enabled | Status |
|---|---:|---:|---|
| O365_BUSINESS_PREMIUM | 4 | 25 | Enabled |

Notes:

- **Verified 2026-06-11:** `O365_BUSINESS_PREMIUM` (GUID
  `f245ecc8-75af-4f8e-b61f-27d8114de5f3`) maps to **Microsoft 365 Business
  Standard** per Microsoft's official licensing-service-plan reference. The legacy
  internal name is misleading — the *actual* Microsoft 365 Business Premium is a
  different SKU (`SPB`, GUID `cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46`), which this
  tenant does **not** have.
- Implication: the tenant is on Business Standard, so it does **not** include
  Intune, Defender for Business, or Entra ID P1 (conditional access). A move to
  **Business Premium is a genuine Stage 7 security-posture decision**, not a
  relabel.
- 4 of 25 enabled seats are consumed.

## Groups

Groups found:

| Display name | Mail |
|---|---|
| A.G. Operations Ltd | A.G.OperationsLtd@AGOperationsLtd.onmicrosoft.com |
| All Company | allcompany@AGOperationsLtd.onmicrosoft.com |
| Group for Answers in Viva Engage - DO NOT DELETE 1521570944958464 | groupforanswersinvivaengagedonotdelete... |

Notes:

- There are only three groups, which is manageable.
- Some groups appear system/default generated.
- Group structure will likely need to be intentionally redesigned during SharePoint/Teams setup.

## Admin Roles

Directory role assignments found:

| Role | Member |
|---|---|
| Global Administrator | admin@agoperations.ca |
| Global Administrator | adamgoodwin@guidedailabs.com |
| Global Administrator | contact@guidedailabs.com |
| Global Reader | adamgoodwin@guidedailabs.com |
| Global Reader | contact@guidedailabs.com |
| AI Administrator | adamgoodwin@guidedailabs.com |
| AI Administrator | contact@guidedailabs.com |
| Exchange Administrator | adamgoodwin@guidedailabs.com |
| SharePoint Administrator | adamgoodwin@guidedailabs.com |
| Teams Administrator | adamgoodwin@guidedailabs.com |
| User Administrator | adamgoodwin@guidedailabs.com |
| User Experience Success Manager | adamgoodwin@guidedailabs.com |
| Service Support Administrator | adamgoodwin@guidedailabs.com |
| Helpdesk Administrator | adamgoodwin@guidedailabs.com |

Stage 2 implications:

- There are three Global Administrators.
- `contact@guidedailabs.com` is a front-door/assistant candidate and should not remain Global Administrator long term.
- `adamgoodwin@guidedailabs.com` has broad daily-user administrative roles.
- `admin@agoperations.ca` is correctly present as a Global Administrator.
- Do not remove any admin access until a break-glass/recovery plan is created and tested.

## SharePoint Sites

Sites found:

| Name | Display name |
|---|---|
| A.G.OperationsLtd | A.G. Operations Ltd |
| allcompany | All Company |
| agoperationsltd.sharepoint.com | Communication site |
| contentTypeHub | Team Site |
| groupforanswersinvivaengagedonotdelete... | Group for Answers in Viva Engage - DO NOT DELETE... |

Notes:

- The current SharePoint footprint is small.
- The existing sites look mostly default/system-generated plus a tenant/company site.
- The proposed AG Operations / Guided AI Labs / Shared Libraries / Change Leadership Tools architecture has not yet been built out as explicit clean sites.

## App Registrations

App registrations found:

| Display name | App/client ID | Audience |
|---|---|---|
| AG Operations Agentic Partner | 2d0c6ba1-1ad9-494e-8583-5442f84c4199 | AzureADMyOrg |

Notes:

- The app registration is single-tenant, which is correct for the current setup/helper use case.
- This should remain a setup/helper app for now, not a broad unattended Agentic OS bridge.
- Future production bridge access should likely use a separate app registration with separate permissions and audit expectations.

## Enterprise Applications

Graph returned 169 enterprise applications/service principals.

Notes:

- This number is normal in Microsoft tenants because many Microsoft first-party services appear as service principals.
- A later security pass should review non-Microsoft/third-party enterprise applications and granted permissions.
- This is not the first cleanup priority unless suspicious third-party apps appear.

## Stage 1 Assessment

What looks good:

- Tenant is identifiable and accessible.
- Expected domains are verified.
- Expected four core user accounts exist and are licensed.
- The tenant is still small enough to cleanly structure.
- App registration exists and is single-tenant.
- SharePoint footprint is not yet sprawling.

Main risks:

- `contact@guidedailabs.com` is a Global Administrator.
- `adamgoodwin@guidedailabs.com` has many admin roles while also being the daily working identity.
- No break-glass/recovery admin plan is documented yet.
- SharePoint has not yet been shaped into the intended information architecture.
- The groups/Teams/Sites model appears mostly default rather than designed.
- License display/name needs verification before relying on Business Premium security assumptions.

## Recommended Next Step

Proceed to Stage 2:

```text
Identity And Admin Foundation
```

Stage 2 should produce:

- account role matrix
- admin role plan
- break-glass admin plan
- decision on future admin removal from `contact@guidedailabs.com`
- decision on which accounts remain licensed users versus future shared mailbox/alias candidates
- naming standard for future service/agent identities

Do not remove admin roles yet.

