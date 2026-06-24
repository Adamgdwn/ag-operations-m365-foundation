# Microsoft 365 API Access Reference

Captured on 2026-06-10.

## Short Answer

The highest-level Microsoft 365 API surface is:

```text
Microsoft Graph
```

But the real access model is not "get one big API key."

The model is:

```text
Adam / admin account
  authenticates through Microsoft Entra
  grants scoped consent
  to Microsoft Graph permissions
  used by scripts, tools, apps, or the future Agentic OS bridge
```

## The Three Access Layers

### 1. Human/Admin Authority

This is Adam acting as the tenant owner/admin.

Used for:

- tenant setup
- licenses
- domains
- admin roles
- app registrations
- consent decisions
- security policy decisions
- emergency recovery

This is not an API key. It is a Microsoft 365 / Entra admin identity.

Likely account:

```text
admin@agoperations.ca
```

Important:

- protect with strong MFA
- do not use as the daily working identity
- create a break-glass/recovery admin plan before removing admin from other accounts

### 2. Codex-Assisted Setup Access

This is the practical near-term layer for inventory and configuration help.

Use:

```text
Microsoft Graph PowerShell SDK
```

Pattern:

```powershell
Connect-MgGraph -Scopes "scope.one","scope.two"
```

Adam signs in interactively. Codex can then help run inventory/configuration commands from the authenticated local session.

This is best for:

- current-state inventory
- user/license/group/domain reporting
- SharePoint/Teams/Exchange discovery where supported
- repeatable setup scripts
- exporting configuration reports

### 3. Future Agentic OS Bridge Access

This is not the first setup step, but the foundation should be designed for it.

Use:

```text
Microsoft Entra app registration
Microsoft Graph delegated permissions first
application permissions only where justified later
```

The future bridge should be scoped by:

- purpose
- site/library/mailbox/team/task surface
- read versus write
- human approval gates
- auditability
- reversibility

## Recommended Starting API Direction

For the next phase, do not create a broad "do everything" app.

Start with a delegated, human-supervised inventory/setup path.

Recommended first tool path:

```text
Microsoft Graph PowerShell SDK
```

Recommended first access style:

```text
Delegated permissions
```

Meaning:

```text
The tool can only do what the signed-in Adam/admin account can do,
and only within the granted scopes.
```

## Initial Inventory Scopes To Consider

Use the minimum needed for the task.

Likely read-only starting scopes:

```text
User.Read
Organization.Read.All
Domain.Read.All
Directory.Read.All
Group.Read.All
Sites.Read.All
Files.Read.All
Calendars.Read
Mail.ReadBasic
Team.ReadBasic.All
Tasks.Read
```

Notes:

- `Directory.Read.All` is powerful but often useful for tenant inventory.
- `Sites.Read.All` and `Files.Read.All` are broad; use for inventory only, then narrow later.
- `Mail.ReadBasic` is safer than full mailbox read when only message metadata is needed.
- Do not start with write permissions unless there is a specific configuration task.

## Permissions To Avoid At The Start

Avoid these until there is a specific, approved use case:

```text
Directory.ReadWrite.All
RoleManagement.ReadWrite.Directory
User.ReadWrite.All
Group.ReadWrite.All
Sites.ReadWrite.All
Files.ReadWrite.All
Mail.ReadWrite
MailboxSettings.ReadWrite
Application.ReadWrite.All
AppRoleAssignment.ReadWrite.All
```

These are not "never" permissions. They are "not casually" permissions.

## What "If It Was Me" Means

If the API should act as Adam:

```text
Use delegated Microsoft Graph permissions.
```

That means the API/tool is acting on behalf of the signed-in Adam/admin identity.

Good for:

- setup scripts
- inventory
- guided administration
- human-reviewed actions
- early Agentic OS bridge experiments

If the API should act without Adam signed in:

```text
Use application permissions.
```

That is more powerful and riskier.

Good for later:

- background sync
- scheduled indexing
- mailbox or SharePoint monitoring
- production Agentic OS bridge services

Application permissions should be scoped tightly, ideally by resource where possible.

## Practical Next Step

Before building apps, run a Microsoft 365 inventory with delegated Graph PowerShell.

Output:

```text
M365 current-state inventory
```

Inventory should include:

- tenant organization info
- verified domains
- users
- licenses
- admin roles
- groups
- SharePoint sites
- Teams
- mailboxes / aliases
- app registrations / enterprise apps
- current granted API permissions

After that, decide whether to create:

```text
AG Ops M365 Inventory App
AG Ops M365 Setup App
Future Agentic OS Bridge App
```

Keep these separate if their permissions are materially different.

## Design Principle

Do not ask Microsoft 365 for "maximum access."

Ask:

```text
What is the smallest permission that lets this specific tool do this specific job?
```

That is the access model the future Agentic OS should inherit.
