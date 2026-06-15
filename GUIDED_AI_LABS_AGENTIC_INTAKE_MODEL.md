# Guided AI Labs Agentic Intake Model

Status: **draft v0.1** (2026-06-14). This bridges:
[M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md](M365_STAGE_5_EXCHANGE_COMMUNICATION_ROUTING.md),
Stage 6 - Teams/Planner/Lists operating state, and Stage 9 - Agentic OS Bridge
Readiness.

This is the first practical model for letting an agent work directly with Guided
AI Labs intake while keeping the foundation governed, visible, and reversible.

---

## 1. Purpose

The agentic intake model turns external and internal signals into structured work:

```text
message arrives -> classify intent -> route to the right surface -> draft response
or task -> human approval where needed -> durable record
```

The goal is not to make email the hub. Email is the signal layer. SharePoint,
Planner, Lists, Teams, and future app identities are the operating layer.

This model should not be read as "M365 only handles documents and email." Stage 6
is intended to create a fully useful Microsoft-native operating layer: records,
work state, tasks, conversations, approvals, and agent audit. The larger agentic
central OS can then orchestrate across M365 and other systems.

Graphify/cross-system map relationship:

| Layer | Intended role |
|---|---|
| M365 | Governed operational truth for business records, tasks, decisions, and collaboration |
| Graphify map | Cross-system relationship/navigation layer across records, people, projects, repos, and tools |
| Agentic central OS | Orchestration, reasoning, memory, and multi-surface execution |

Stage 6 records should therefore include stable Microsoft links plus optional
future references such as `CentralOSLink` and `GraphNodeId`. Those hooks let the
central OS and Graphify map connect to the working records without forcing M365 to
be the only place where higher-order intelligence lives.

---

## 2. Intake identities

| Address | Role | Current posture | Agentic role |
|---|---|---|---|
| `contact@guidedailabs.com` | Guided AI Labs public front door | Licensed user mailbox, no admin roles | Primary consulting/client inquiry intake and future assistant-monitored mailbox |
| `support@changeleadershiptools.com` | Change Leadership Tools product support | Licensed user mailbox, no admin roles | Product support intake and future support triage mailbox |
| `adamgoodwin@guidedailabs.com` | Adam's daily operator mailbox/calendar | Licensed user mailbox, accepted admin risk | Human owner, reviewer, and approval point |
| `admin@agoperations.ca` | Admin/legal/backbone | Licensed admin mailbox | Not an agentic front door; legal/admin records only |

Decision: `contact@` and `support@` remain licensed user mailboxes for now so they
can keep independent mailbox/calendar/sign-in capability while the agentic model
is designed.

---

## 3. Intake lanes

| Lane | First signal | Primary owner | Durable home | Work state |
|---|---|---|---|---|
| Guided AI Labs inquiry | `contact@guidedailabs.com` | Adam | Guided AI Labs or Guided AI Journey SharePoint site | Stage 6 intake List + Planner task |
| Client discovery / readiness | `contact@guidedailabs.com` | Adam | Guided AI Journey SharePoint site | Client intake List item |
| Existing client delivery | Adam or client email | Adam | Client folder/library under the correct SharePoint site | Planner task and decision log |
| Change Leadership Tools support | `support@changeleadershiptools.com` | Adam | Change Leadership Tools SharePoint site | Support List item |
| Reusable method / IP | any intake lane | Adam | Shared Libraries site | Knowledge/reuse register |
| Admin/legal/vendor | `admin@agoperations.ca` | Adam | AG Operations SharePoint site | Admin task only if action is needed |

---

## 4. Classification model

The agent should classify each incoming item before acting.

| Class | Meaning | Default action |
|---|---|---|
| `new-inquiry` | New consulting, speaking, partnership, or client interest | Draft acknowledgement, create intake record, flag Adam |
| `client-readiness` | M365/AI readiness discovery or infrastructure question | Create discovery record and suggest next-step checklist |
| `support-request` | Product/user support for Change Leadership Tools | Create support record, draft support reply |
| `scheduling` | Meeting, booking, reschedule, calendar coordination | Draft calendar options; do not commit without Adam approval |
| `decision-or-commitment` | A promise, approval, scope decision, or dependency | Create durable record and task; request Adam confirmation |
| `knowledge-candidate` | Reusable method, lesson, template, or FAQ | Save/reference in Shared Libraries candidate queue |
| `admin-legal` | Billing, tax, legal, vendor, tenant administration | Route to AG Operations/admin lane; no agent autonomy |
| `noise-or-spam` | Marketing, irrelevant, unsafe, or low-value message | Label/ignore; no task unless Adam asks |

---

## 5. Agent permission posture

The mailbox is the interaction surface. The agent capability must remain separate.

Initial mode:

- Read/summarize selected mailbox items only after Adam-authorized sign-in.
- Draft replies, tasks, and records.
- Do not send external mail automatically.
- Do not create tenant-wide rules automatically.
- Do not delete mail or files.
- Do not grant permissions, invite guests, or change sharing.
- Use visible approval prompts for Microsoft sign-in, consent, and any write with
  tenant impact.

Future bridge mode:

- Use a dedicated app registration such as `agent-guided-intake-bridge`.
- Grant only the specific Graph permissions required for the approved workflow.
- Prefer delegated permissions first while the model is being proven.
- Move to application permissions only after Stage 7 governance is ready.
- Log every agent action into a durable audit/decision surface.

---

## 6. Stage 6 operating surfaces to create

These are the likely next build targets. Exact names can change during Stage 6.

### Microsoft Lists

| List | Site | Purpose |
|---|---|---|
| `Guided AI Labs - Intake Register` | Guided AI Labs | One row per inquiry, client discovery item, or partnership lead |
| `Change Leadership Tools - Support Register` | Change Leadership Tools | One row per product support issue |
| `Agent Action Log` | Guided AI Labs or Shared Libraries | Human-readable log of agent suggestions/actions |
| `Decision Register` | Guided AI Labs or Shared Libraries | Commitments, approvals, scope decisions, and unresolved questions |

Suggested intake register columns:

| Column | Type | Notes |
|---|---|---|
| `Title` | text | Human-readable short label |
| `SourceMailbox` | choice | `contact@`, `support@`, `adam@`, `admin@` |
| `SourceMessageId` | text | Graph/Exchange message identifier when available |
| `ReceivedDate` | date/time | Original signal date |
| `RequesterName` | text | Sender/contact name |
| `RequesterEmail` | text | Sender email |
| `Organization` | text | Client/company if known |
| `IntakeClass` | choice | Classification values from section 4 |
| `Priority` | choice | Low, Normal, High, Urgent |
| `Status` | choice | New, Triage, Waiting on Adam, Waiting on External, In Progress, Done, Archived |
| `NextAction` | text | The next concrete action |
| `Owner` | person | Usually Adam at first |
| `DurableHome` | hyperlink/text | SharePoint record location |
| `CentralOSLink` | hyperlink/text | Future central OS/Graphify record link |
| `GraphNodeId` | text | Stable external graph node/reference ID |
| `AgentConfidence` | number/text | Optional confidence or rationale |
| `HumanApprovalRequired` | yes/no | True for external send, scheduling, permissions, or commitments |

### Planner

Start with one Guided AI Labs operating plan:

```text
Guided AI Labs - Operating Plan
```

Suggested buckets:

- Intake Triage
- Client Discovery
- Active Delivery
- Content / IP
- Agent Setup
- Waiting / Follow-up

Create a separate Change Leadership Tools support plan only if the support volume
justifies it. Until then, the support List can be enough.

### Teams

Likely Stage 6 team/channel shape:

| Team | Channels |
|---|---|
| Guided AI Labs - Operating Team | General, Intake, Client Discovery, Agent Setup, Methods and IP |
| Change Leadership Tools - Support | General, Support Triage, Product Feedback |

Teams is for discussion and coordination. It should not become the durable filing
cabinet; SharePoint remains the record home.

---

## 7. First safe agent workflows

Start with workflows that create drafts and records, not autonomous external
actions.

1. **Inbox triage brief**
   - Read new `contact@` messages.
   - Classify each message.
   - Produce a daily/triggered triage summary for Adam.

2. **Draft acknowledgement**
   - Draft a polite reply for new inquiries.
   - Require Adam approval before send.

3. **Create intake record**
   - Create or propose a List row with sender, class, summary, next action, and
     durable home.

4. **Create follow-up task**
   - Create or propose Planner task when action is required.
   - Link back to the mailbox item and intake record.

5. **Support issue capture**
   - Read `support@` messages.
   - Create support register entries and draft first response.

6. **Knowledge candidate capture**
   - Flag reusable answers, methods, templates, or FAQs.
   - Route to Shared Libraries candidate queue.

Do not start with:

- auto-sending external replies;
- auto-booking meetings;
- permission or sharing changes;
- deleting/archive rules;
- broad Graph app permissions;
- unattended access to admin/legal mail.

---

## 8. Immediate build sequence

1. Finish Stage 5 by documenting:
   - `contact@` remains licensed user mailbox for now;
   - `support@` remains licensed user mailbox for now;
   - M365 group addresses are internal/collaboration surfaces, not public front doors;
   - `adamgoodwin@` is the real calendar owner unless a specific intake calendar is
     later approved.
2. Start Stage 6 with Lists before heavy Teams/Planner build:
   - create Guided AI Labs intake register design;
   - create Change Leadership Tools support register design;
   - create Agent Action Log / Decision Register design.
3. Decide the first operating Team/channel structure.
4. Build only low-risk manual/assisted workflows first.
5. Defer production app registration and broad Graph permissions until Stage 7
   governance and Stage 9 bridge readiness.

---

## 9. Open decisions

| # | Decision | Recommendation |
|---|---|---|
| A1 | Should `contact@` own an independent scheduling calendar? | Not yet; Adam remains real calendar owner until intake volume demands it |
| A2 | Should first agent work through Adam-authorized delegated access or app registration? | Delegated/manual first; app registration after governance review |
| A3 | Where should the Agent Action Log live? | Guided AI Labs site if operational; Shared Libraries if it becomes reusable method/IP |
| A4 | Should Change Leadership Tools get a separate Planner plan immediately? | Defer until support volume justifies it |
| A5 | What is the first direct agent integration surface? | Read/summarize/draft against `contact@`, with human approval for all external sends |
