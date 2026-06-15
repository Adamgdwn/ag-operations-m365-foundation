# SharePoint Owner Access - All Sites

Run: 20260615-151849
Result: CHECK
Admin URL: https://agoperationsltd-admin.sharepoint.com
Users: adamgoodwin@guidedailabs.com, admin@agoperations.ca
Targeted sites: 10
Successful user-site grants/read-backs: 16
Failed user-site grants/read-backs: 4
Transcript: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\access-repair\sharepoint-owner-access-all-sites-20260615-151849.log
Site inventory CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\access-repair\sharepoint-owner-access-site-inventory-20260615-151849.csv
Result CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\access-repair\sharepoint-owner-access-all-sites-results-20260615-151849.csv

## Boundary

This grants only the named internal user accounts owner-level SharePoint access. It does not add contact@agoperations.ca, invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.

## Site Summary

| Site | Template | User | Added to owners | Added as site collection admin | Success |
| --- | --- | --- | ---: | ---: | ---: |
| https://agoperationsltd.sharepoint.com/ | SitePagePublishing#0 | adamgoodwin@guidedailabs.com | False | False | True |
| https://agoperationsltd.sharepoint.com/ | SitePagePublishing#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/search | SRCHCEN#0 | adamgoodwin@guidedailabs.com | True | True | True |
| https://agoperationsltd.sharepoint.com/search | SRCHCEN#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/A.G.OperationsLtd | GROUP#0 | adamgoodwin@guidedailabs.com | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/A.G.OperationsLtd | GROUP#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/AGOperations | SITEPAGEPUBLISHING#0 | adamgoodwin@guidedailabs.com | False | False | True |
| https://agoperationsltd.sharepoint.com/sites/AGOperations | SITEPAGEPUBLISHING#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/allcompany | GROUP#0 | adamgoodwin@guidedailabs.com | False | False | False |
| https://agoperationsltd.sharepoint.com/sites/allcompany | GROUP#0 | admin@agoperations.ca | False | False | False |
| https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools | GROUP#0 | adamgoodwin@guidedailabs.com | True | False | True |
| https://agoperationsltd.sharepoint.com/sites/ChangeLeadershipTools | GROUP#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273 | GROUP#0 | adamgoodwin@guidedailabs.com | False | False | False |
| https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273 | GROUP#0 | admin@agoperations.ca | False | False | False |
| https://agoperationsltd.sharepoint.com/sites/GuidedAIJourney | SITEPAGEPUBLISHING#0 | adamgoodwin@guidedailabs.com | False | False | True |
| https://agoperationsltd.sharepoint.com/sites/GuidedAIJourney | SITEPAGEPUBLISHING#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/GuidedAILabs | GROUP#0 | adamgoodwin@guidedailabs.com | False | False | True |
| https://agoperationsltd.sharepoint.com/sites/GuidedAILabs | GROUP#0 | admin@agoperations.ca | True | True | True |
| https://agoperationsltd.sharepoint.com/sites/SharedLibraries | SITEPAGEPUBLISHING#0 | adamgoodwin@guidedailabs.com | False | False | True |
| https://agoperationsltd.sharepoint.com/sites/SharedLibraries | SITEPAGEPUBLISHING#0 | admin@agoperations.ca | True | True | True |

## Failures

- https://agoperationsltd.sharepoint.com/sites/allcompany / adamgoodwin@guidedailabs.com: Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))
- https://agoperationsltd.sharepoint.com/sites/allcompany / admin@agoperations.ca: Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))
- https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273 / adamgoodwin@guidedailabs.com: Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))
- https://agoperationsltd.sharepoint.com/sites/groupforanswersinvivaengagedonotdelete1521570944958464273 / admin@agoperations.ca: Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))
