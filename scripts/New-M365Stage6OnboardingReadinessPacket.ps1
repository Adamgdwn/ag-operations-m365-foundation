param(
    [string]$OutputDirectory = ".\inventory\stage-6-operating-state\onboarding-readiness",
    [string]$Owner = "adamgoodwin@guidedailabs.com"
)

# Stage 6 - onboarding readiness packet generator.
# Produces local checklists and a runbook for partner/client onboarding readiness.
# It does not connect to Microsoft 365 and does not write tenant data.

$ErrorActionPreference = "Stop"

function Resolve-Stage6Path {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    return (Join-Path $workspaceRoot $Path)
}

function Export-Stage6Csv {
    param(
        [string]$Path,
        [object[]]$Rows
    )

    $Rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
}

$resolvedOutputDirectory = Resolve-Stage6Path -Path $OutputDirectory
New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null

$now = Get-Date
$today = $now.ToString("yyyy-MM-dd")
$stamp = $now.ToString("yyyy-MM-dd HH:mm")

$partnerChecklistPath = Join-Path $resolvedOutputDirectory "partner-onboarding-checklist.csv"
$clientDiscoveryPath = Join-Path $resolvedOutputDirectory "client-readiness-discovery-checklist.csv"
$trainingPathPath = Join-Path $resolvedOutputDirectory "partner-training-path.csv"
$scorecardPath = Join-Path $resolvedOutputDirectory "operating-readiness-scorecard.csv"
$runbookPath = Join-Path $resolvedOutputDirectory "STAGE_6_ONBOARDING_READINESS_RUNBOOK.md"

$partnerChecklistRows = @(
    [pscustomobject]@{ Phase = "Decision"; Item = "Decide partner access type: internal member, external guest, or client-tenant collaborator"; Owner = $Owner; Surface = "Decision Register"; Status = "Not started"; Evidence = ""; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Decision"; Item = "Decide whether partner sees only Guided AI Labs or also AG Operations administration"; Owner = $Owner; Surface = "Decision Register"; Status = "Not started"; Evidence = ""; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Security"; Item = "Confirm MFA and no standing admin role for partner account"; Owner = $Owner; Surface = "Entra admin center"; Status = "Not started"; Evidence = ""; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Security"; Item = "Confirm no external sharing or guest access is widened before Stage 7 review"; Owner = $Owner; Surface = "SharePoint admin center"; Status = "Guardrail active"; Evidence = "Stage 3 sites created with external sharing off"; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Account"; Item = "Create or confirm partner identity in the agreed model"; Owner = $Owner; Surface = "Microsoft 365 admin center"; Status = "Not started"; Evidence = ""; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Teams"; Item = "Add partner to the Guided AI Labs operating Team only after access model is approved"; Owner = $Owner; Surface = "Teams admin center / Teams"; Status = "Not started"; Evidence = ""; RequiresApproval = "Yes" },
    [pscustomobject]@{ Phase = "Operating"; Item = "Walk through Intake Register, Operating Plan, Agent Log, and Decision Register"; Owner = $Owner; Surface = "Teams"; Status = "Not started"; Evidence = ""; RequiresApproval = "No" },
    [pscustomobject]@{ Phase = "Operating"; Item = "Create one supervised intake test item and one Planner next action"; Owner = $Owner; Surface = "Lists / Planner"; Status = "Not started"; Evidence = ""; RequiresApproval = "No" },
    [pscustomobject]@{ Phase = "Operating"; Item = "Record one onboarding decision and one agent-action log entry"; Owner = $Owner; Surface = "Decision Register / Agent Action Log"; Status = "Not started"; Evidence = ""; RequiresApproval = "No" },
    [pscustomobject]@{ Phase = "Training"; Item = "Explain approval boundaries: no sends, scheduling, access, consent, destructive action, or client commitment without Adam"; Owner = $Owner; Surface = "Onboarding runbook"; Status = "Not started"; Evidence = ""; RequiresApproval = "No" },
    [pscustomobject]@{ Phase = "Dry run"; Item = "Run one business-partner dry onboarding before using this with a real partner"; Owner = $Owner; Surface = "Onboarding runbook"; Status = "Not started"; Evidence = ""; RequiresApproval = "No" }
)

$clientDiscoveryRows = @(
    [pscustomobject]@{ Area = "Identity"; Question = "Who are the real humans, admins, front doors, support identities, guests, and service identities?"; Evidence = "User/admin role export or screenshots"; M365Surface = "Entra / M365 admin center"; Risk = "High if roles are blurry"; Notes = "" },
    [pscustomobject]@{ Area = "Records"; Question = "Where do official company, client, legal, finance, and reusable-method records live?"; Evidence = "SharePoint sites/libraries map"; M365Surface = "SharePoint"; Risk = "High if records live in email or personal OneDrive"; Notes = "" },
    [pscustomobject]@{ Area = "Mail"; Question = "Which mailboxes are signals, which are humans, and which require agent-visible intake later?"; Evidence = "Mailbox/address map"; M365Surface = "Exchange"; Risk = "Medium"; Notes = "" },
    [pscustomobject]@{ Area = "Tasks"; Question = "Where does action-bearing work live, and what should not become a task?"; Evidence = "Planner/List examples"; M365Surface = "Planner / Lists"; Risk = "Medium"; Notes = "" },
    [pscustomobject]@{ Area = "Decisions"; Question = "Where are approvals, scope decisions, commitments, and unresolved questions recorded?"; Evidence = "Decision register or equivalent"; M365Surface = "Lists / SharePoint"; Risk = "High if decisions are buried in chat"; Notes = "" },
    [pscustomobject]@{ Area = "Collaboration"; Question = "Where do conversations happen, and what belongs in Teams versus SharePoint?"; Evidence = "Teams/channel map"; M365Surface = "Teams"; Risk = "Medium"; Notes = "" },
    [pscustomobject]@{ Area = "Sharing"; Question = "Can external users access anything, and by what rule?"; Evidence = "Tenant/site sharing settings"; M365Surface = "SharePoint / Entra"; Risk = "High"; Notes = "" },
    [pscustomobject]@{ Area = "Local device"; Question = "Is the client saving official work to the right tenant and not blending accounts?"; Evidence = "OneDrive/browser profile map"; M365Surface = "OneDrive / Windows / browser"; Risk = "Medium"; Notes = "" },
    [pscustomobject]@{ Area = "AI readiness"; Question = "What may an agent read, draft, create, or update, and what requires approval?"; Evidence = "Approval boundary matrix"; M365Surface = "Graph / Lists / Teams"; Risk = "High"; Notes = "" },
    [pscustomobject]@{ Area = "Handoff"; Question = "What does the client own when Guided AI Labs leaves?"; Evidence = "Ownership/handoff note"; M365Surface = "SharePoint / admin centers"; Risk = "High"; Notes = "" }
)

$trainingRows = @(
    [pscustomobject]@{ Sequence = 1; Activity = "Open Teams and locate the Guided AI Labs operating Team"; Surface = "Teams"; CompletionSignal = "Partner can name the main channels"; Notes = "" },
    [pscustomobject]@{ Sequence = 2; Activity = "Open Intake Register and explain Attention Now"; Surface = "Microsoft Lists"; CompletionSignal = "Partner can identify active intake"; Notes = "" },
    [pscustomobject]@{ Sequence = 3; Activity = "Open Operating Plan and explain task rules"; Surface = "Planner"; CompletionSignal = "Partner can create or review one action-bearing task"; Notes = "" },
    [pscustomobject]@{ Sequence = 4; Activity = "Open Agent Action Log and explain review states"; Surface = "Microsoft Lists"; CompletionSignal = "Partner can distinguish Suggested, Approved, Completed, Rejected"; Notes = "" },
    [pscustomobject]@{ Sequence = 5; Activity = "Open Decision Register and record one harmless internal decision"; Surface = "Microsoft Lists"; CompletionSignal = "Partner can find decisions later"; Notes = "" },
    [pscustomobject]@{ Sequence = 6; Activity = "Explain where durable files live versus working chat"; Surface = "SharePoint / Teams"; CompletionSignal = "Partner can choose SharePoint or Teams correctly"; Notes = "" },
    [pscustomobject]@{ Sequence = 7; Activity = "Explain approval boundaries and escalation"; Surface = "Onboarding runbook"; CompletionSignal = "Partner can name actions that require Adam"; Notes = "" }
)

$scorecardRows = @(
    [pscustomobject]@{ Category = "Lists"; ReadyWhen = "All four Stage 6 Lists exist and read-back verification passes"; CurrentStatus = "Ready"; Evidence = "stage-6-verify-lists-20260614-135144.log"; Gap = "" },
    [pscustomobject]@{ Category = "Planner"; ReadyWhen = "Operating Plan exists with expected buckets"; CurrentStatus = "Pending live gate"; Evidence = ""; Gap = "Run Planner/Teams operator" },
    [pscustomobject]@{ Category = "Teams"; ReadyWhen = "Operating Team and channels exist with useful tabs"; CurrentStatus = "Pending live gate"; Evidence = ""; Gap = "Run Planner/Teams operator and verify tabs" },
    [pscustomobject]@{ Category = "First agent loop"; ReadyWhen = "One supervised intake item can move from signal to list row, task, decision/action log"; CurrentStatus = "Packet prepared"; Evidence = "first-run-packet"; Gap = "Run after Planner/Teams live gate" },
    [pscustomobject]@{ Category = "Partner onboarding"; ReadyWhen = "Access model, training path, dry run, and approval boundaries are documented"; CurrentStatus = "Packet prepared"; Evidence = "onboarding-readiness"; Gap = "Complete one dry onboarding" },
    [pscustomobject]@{ Category = "Client onboarding"; ReadyWhen = "Discovery checklist and ownership/handoff rules are ready to use"; CurrentStatus = "Draft ready"; Evidence = "client-readiness-discovery-checklist.csv"; Gap = "Convert into Stage 8 client workspace pattern" },
    [pscustomobject]@{ Category = "Security posture"; ReadyWhen = "External sharing, guest access, labels/retention, admin role posture reviewed"; CurrentStatus = "Stage 7 pending"; Evidence = "Roadmap Stage 7"; Gap = "Run Stage 7 before real external sharing" }
)

Export-Stage6Csv -Path $partnerChecklistPath -Rows $partnerChecklistRows
Export-Stage6Csv -Path $clientDiscoveryPath -Rows $clientDiscoveryRows
Export-Stage6Csv -Path $trainingPathPath -Rows $trainingRows
Export-Stage6Csv -Path $scorecardPath -Rows $scorecardRows

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Stage 6 Onboarding Readiness Runbook")
$lines.Add("")
$lines.Add(("Generated: {0}" -f $stamp))
$lines.Add("")
$lines.Add("Purpose: define what finished well means before bringing in a business partner or using the setup as a client onboarding pattern.")
$lines.Add("")
$lines.Add("## Readiness Ladder")
$lines.Add("")
$lines.Add("| Level | Meaning | Current posture |")
$lines.Add("|---|---|---|")
$lines.Add("| L1 | Internal operating cockpit | Lists are ready; Planner/Teams live gate is next |")
$lines.Add("| L2 | Business partner onboarding | Requires access model decision, training path, and one dry run |")
$lines.Add("| L3 | First client intake | Requires first supervised agent loop and client-readiness checklist |")
$lines.Add("| L4 | Repeatable client workspace pattern | Stage 8 output; do not pretend Stage 6 alone completes this |")
$lines.Add("")
$lines.Add("## Files")
$lines.Add("")
$lines.Add("| File | Purpose |")
$lines.Add("|---|---|")
$lines.Add("| `partner-onboarding-checklist.csv` | Concrete partner onboarding tasks and approval gates |")
$lines.Add("| `partner-training-path.csv` | The short path a partner should walk to understand the operating cockpit |")
$lines.Add("| `client-readiness-discovery-checklist.csv` | Questions to use when onboarding a client or assessing their M365 readiness |")
$lines.Add("| `operating-readiness-scorecard.csv` | Plain readiness scorecard for what is done, pending, and blocked |")
$lines.Add("")
$lines.Add("## Access Model Rule")
$lines.Add("")
$lines.Add("Choose the access model before adding anyone:")
$lines.Add("")
$lines.Add("- Internal partner: licensed internal user, MFA, least privilege, no standing admin role by default.")
$lines.Add("- External collaborator: treat as Stage 7 guest/external-sharing work, site-limited, explicitly approved.")
$lines.Add("- Client: prefer the client's own tenant for durable client-owned work; Guided AI Labs can hold templates, methods, and engagement coordination.")
$lines.Add("")
$lines.Add("## Done Well Means")
$lines.Add("")
$lines.Add("A new trusted partner can:")
$lines.Add("")
$lines.Add("1. Open Teams and find the operating Team.")
$lines.Add("2. Understand which channel to use for intake, delivery, agent setup, and methods/IP.")
$lines.Add("3. Open the Intake Register, Operating Plan, Agent Action Log, and Decision Register.")
$lines.Add("4. Create or review one test intake item, one task, one decision, and one action-log entry.")
$lines.Add("5. Explain what requires Adam approval.")
$lines.Add("6. Avoid saving official records in the wrong place.")
$lines.Add("7. Understand that external sharing, guest access, app consent, sends, scheduling, and tenant policy changes are not casual actions.")
$lines.Add("")
$lines.Add("## First Dry Run")
$lines.Add("")
$lines.Add("1. Use a harmless internal example, not a live client commitment.")
$lines.Add("2. Create one intake row.")
$lines.Add("3. Create one Planner task only if there is a real next action.")
$lines.Add("4. Log one agent or manual action.")
$lines.Add("5. Record one decision or approval boundary.")
$lines.Add("6. Confirm the partner can navigate back to all four items without help.")
$lines.Add("")
$lines.Add("## Stage Boundary")
$lines.Add("")
$lines.Add("Stage 6 can make the cockpit usable. Stage 7 must harden sharing, guest access, admin posture, labels/retention, and security before real external collaboration scales. Stage 8 turns this into the repeatable client workspace pattern.")
$lines.Add("")

Set-Content -LiteralPath $runbookPath -Value $lines -Encoding UTF8
Write-Host "Stage 6 onboarding readiness packet written to: $resolvedOutputDirectory" -ForegroundColor Green
