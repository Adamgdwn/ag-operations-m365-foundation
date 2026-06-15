# SharePoint Owner Access Repair

Run: 20260615-144518
User: adamgoodwin@guidedailabs.com
Transcript: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\access-repair\sharepoint-owner-access-repair-20260615-144518.log
CSV: C:\Users\adamg\01. Code Projects\AG Operations Workspace Setup\inventory\access-repair\sharepoint-owner-access-repair-20260615-144518.csv

## Scope

This repair grants only the named internal owner account access to the listed SharePoint sites.
It does not invite guests, widen external sharing, create anonymous links, change tenant policy, alter CRM records, send mail, or create automation.

## Results

| Site | Owners group | Added to owners | Added as site collection admin |
| --- | --- | ---: | ---: |
| https://agoperationsltd.sharepoint.com | Communication site Owners | True | True |
| https://agoperationsltd.sharepoint.com/sites/GuidedAILabs | Guided AI Labs Owners | True | False |
