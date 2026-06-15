# Microsoft 365 Login And Account Guide

Status: live reference guide for AG Operations and Guided AI Labs.

## One Rule

If you are working, sign in as Adam Goodwin.

If you are administering the tenant, sign in as Admin.

## Account Map

| Account | Role | Use For | Daily? |
| --- | --- | --- | --- |
| `adamgoodwin@guidedailabs.com` | Daily operator and owner | Guided AI Labs SharePoint, CRM, Lists, Planner, Teams, documents, daily decisions | Yes |
| `admin@agoperations.ca` | Admin toolbelt | Microsoft 365 admin center, Entra, SharePoint admin, permissions, security, break/fix | No |
| `contact@agoperations.ca` | Future front door/contact account | Possible future intake/mail/contact routing | No |

## Source Of Truth

| Layer | Source Of Truth |
| --- | --- |
| Daily human identity | `adamgoodwin@guidedailabs.com` |
| Daily workplace | `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs` |
| CRM and active relationship work | `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs/SitePages/Relationship-CRM-Command-Center.aspx` |
| Admin authority | `admin@agoperations.ca` |
| Parent/router layer | AG Operations SharePoint surfaces |

## MFA And Auth Code Rule

| What You Are Opening | Expected Account |
| --- | --- |
| SharePoint, Teams, Planner, Lists, CRM, documents | `adamgoodwin@guidedailabs.com` |
| Microsoft 365 Admin Center, Entra, SharePoint Admin, tenant settings | `admin@agoperations.ca` |

If an authentication prompt does not clearly show which account it is for, cancel it and restart from the correct Chrome profile.

## Browser Profile Rule

| Chrome Profile | Signed-In Account |
| --- | --- |
| AG Operations - Daily | `adamgoodwin@guidedailabs.com` only |
| AG Operations - Admin | `admin@agoperations.ca` only |

Do not mix both accounts in the same Chrome profile.

## Recovery Path

1. Close mixed-account Microsoft 365 tabs.
2. Open the intended Chrome profile.
3. Sign in with only the expected account.
4. Open Guided AI Labs directly:
   `https://agoperationsltd.sharepoint.com/sites/GuidedAILabs`
5. If access looks wrong, try an InPrivate window and sign in explicitly as:
   `adamgoodwin@guidedailabs.com`

## Current Access State

Owner-level SharePoint access is granted and read-back verified for:

- `adamgoodwin@guidedailabs.com`
- `admin@agoperations.ca`

`contact@agoperations.ca` remains intentionally excluded for now.
