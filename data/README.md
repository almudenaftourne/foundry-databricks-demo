# Synthetic project-delivery dataset

[Lab home](../README.md) | [Upload lesson](../docs/06-upload-source-files.md)

All data is fictional. Handles are role-based labels, not accounts or email
addresses. No dataset field grants access or implements a security policy.

**Snapshot/reference date: 2026-10-23.** Use this date in benchmark questions,
not the machine's current date. This is a single snapshot, not a historical
event log.

## Files and grain

| File | Grain and key | Raw rows | Expected clean rows |
| --- | --- | --- | --- |
| [teams.csv](raw/teams.csv) | One team per `team_id` | 4 | 4 |
| [projects.csv](raw/projects.csv) | One project per `project_id` | 8 | 8 |
| [work_items.csv](raw/work_items.csv) | Work-item snapshots; keep the latest `updated_at` per `work_item_id` before validation | 44 | 40 |

Relationships:

```text
teams.team_id -> projects.team_id
projects.project_id -> work_items.project_id
```

Each project has one owning team. Each clean work item has one project.
Every project has five clean work items. This small balanced fixture supports
joins and aggregation without hiding records in a large generated dataset.

## Field dictionary

CSV values are source strings; ingestion and cleaning will explicitly assign
types. Empty fields represent missing values, not literal strings such as
`"NULL"`.

### Teams

| Field | Intended clean type | Meaning |
| --- | --- | --- |
| team_id | STRING | Unique fictional team key |
| team_name | STRING | Display name |
| region | STRING | Business label, not a cloud deployment region or permission |
| manager_handle | STRING | Fictional role-based manager label |
| hourly_rate_eur | DECIMAL | Illustrative hourly effort rate for the team |

### Projects

| Field | Intended clean type | Meaning |
| --- | --- | --- |
| project_id | STRING | Unique project key |
| team_id | STRING | Owning team key |
| project_name | STRING | Display name |
| owner_handle | STRING | Fictional role-based project owner |
| priority | STRING | low, medium, or high |
| status | STRING | active, on_hold, or completed; distinct from work-item status |
| start_date | DATE | Project start, ISO yyyy-MM-dd |
| target_date | DATE | Planned project target date |
| budget_eur | DECIMAL | Illustrative project effort-cost budget |
| currency | STRING | EUR for every project; no currency conversion needed |

### Work items

| Field | Intended clean type | Meaning |
| --- | --- | --- |
| work_item_id | STRING | Business key for deduplicating snapshots |
| project_id | STRING | Parent project key |
| title | STRING | Work description |
| category | STRING | analysis, configuration, development, documentation, security, testing, design, or cleanup |
| assignee_handle | STRING, nullable | Fictional assignee; empty means unassigned |
| priority | STRING | low, medium, or high |
| status | STRING | todo, in_progress, blocked, done, or cancelled |
| created_date | DATE | Creation date |
| due_date | DATE | Work-item due date, not the project's target date |
| completed_date | DATE, nullable | Completion date for done items only |
| estimated_hours | DECIMAL | Original estimate for this item, not remaining hours |
| actual_hours | DECIMAL | Cumulative logged effort at the snapshot |
| blocked_reason | STRING, nullable | Reported blocker for blocked items; not proven root cause |
| updated_at | TIMESTAMP | Snapshot update time in UTC |

## Cleaning contract

1. Preserve all source records in Bronze. Do not repair the CSV files.
2. Parse `updated_at` and keep the newest snapshot per `work_item_id`.
   Equal newest timestamps with different values must be surfaced as ambiguous,
   not resolved using arbitrary file order.
3. Validate the retained snapshot. Quarantine invalid records with their source
   values and rejection reasons. Do not silently drop them.
4. Preserve blank assignees: they are valid data and support unassigned-work
   questions. Do not turn them into a fabricated person.
5. Parse dates and numeric fields explicitly. Invalid casts should produce
   visible quality outcomes rather than silently becoming plausible values.

Deliberate issues:

| Record | Issue | Expected treatment |
| --- | --- | --- |
| WI001, updated 2026-10-08 | Older snapshot appears after the newer row in the file | Deduplicate; retain the 2026-10-22 row with 40 actual hours |
| WI041 | Unknown status `waiting_for_magic` | Quarantine: invalid_status |
| WI042 | Unknown parent project P999 | Quarantine: unknown_project |
| WI043 | Impossible due date 2026-02-30 | Quarantine: invalid_due_date |

Reconciliation: **44 raw = 1 superseded snapshot + 3 quarantined records +
40 accepted records**. There are 43 distinct raw work-item IDs.

## Business definitions for Gold and Genie

- **Open:** work-item status is todo, in_progress, or blocked.
- **Overdue open item:** open and due_date strictly before 2026-10-23.
  Due today is not overdue. Done/cancelled items are excluded.
- **Blocked:** work-item status is blocked, whether overdue or not.
- **Unassigned open item:** open with no assignee.
- **Project effort cost:** sum of accepted work-item actual_hours multiplied by
  the owning team's hourly_rate_eur. This is modeled labor effort, not invoiced
  spend, financial transactions, or an Azure bill.
- **Over budget:** project effort cost strictly exceeds budget_eur.
- **Budget variance:** project effort cost minus budget_eur; positive means
  over budget.

Aggregate budget at project grain. Joining projects to work items repeats the
budget on each item; summing that joined column would overstate total budget.
Use decimal arithmetic for monetary values.

## Checked benchmark answers

The local validation script passes these expected values. Bronze, Silver,
and Gold checks were subsequently learner-validated in Databricks; selected
native Genie questions and the Foundry-to-Genie 21-open / 9-overdue question
also passed. This table is the full answer key, not a claim that every row
has been tested through each interface. See the
[capability matrix](../docs/capability-matrix.md) for evidence boundaries.

| Question, as of 2026-10-23 | Expected answer after cleaning |
| --- | --- |
| How many teams, projects, and work items are there? | 4 teams; 8 projects; 40 valid work items |
| How many work items are open? | 21 |
| How many open work items are overdue? | 9 |
| How many work items are blocked? | 7 |
| How many open work items are unassigned? | 7 |
| How many items are done or cancelled? | 17 done; 2 cancelled |
| What is total actual effort and modeled effort cost? | 417 hours; EUR 36,550 |
| What is the total project budget? | EUR 43,500 |
| Which projects are over budget? | P001 by EUR 2,000; P003 by EUR 200; P005 by EUR 480 |
| Which project has the highest modeled effort cost? | P003, Reporting refresh: EUR 8,200 |
| Which project has no open items? | P008, Knowledge base cleanup |

Project-level ground truth:

| Project | Open | Overdue open | Actual hours | Effort cost EUR | Budget EUR |
| --- | --- | --- | --- | --- | --- |
| P001 Workspace rollout | 3 | 2 | 100 | 8000 | 6000 |
| P002 Access review | 3 | 1 | 30 | 2400 | 4000 |
| P003 Reporting refresh | 3 | 1 | 82 | 8200 | 8000 |
| P004 Data quality checks | 3 | 2 | 40 | 4000 | 5000 |
| P005 Self-service portal | 3 | 1 | 72 | 6480 | 6000 |
| P006 Service API update | 3 | 1 | 48 | 4320 | 10000 |
| P007 Onboarding refresh | 3 | 1 | 20 | 1400 | 2000 |
| P008 Knowledge base cleanup | 0 | 0 | 25 | 1750 | 2500 |

Useful later investigations:

- Which overdue items are blocked, what reasons are recorded, and who owns them?
- Compare open work by team and business region.
- Which over-budget projects also have overdue work?
- Which items completed after their due date?
- Show the evidence behind a project-risk recommendation.

Questions the dataset cannot establish:

- Trends or status transitions over time: this is not a history dataset.
- A reliable forecast of completion date: remaining effort and capacity are absent.
- Proven root causes: recorded blockers are reports, not causal evidence.
- A user's allowed projects: real identities and Unity Catalog policies must be
  configured and tested separately.

Do not give the answer key to the agent as a substitute for querying the data.
It is for evaluation and teaching.

## Local validation

From the repository root in PowerShell:

```powershell
& .\data\validate-fixture.ps1
```

No external packages are required. The script reads the CSV files without
changing them. It checks schemas, row counts, keys, intended rejection reasons,
deduplication, and benchmark totals. It does not upload files, execute Spark,
or replace Databricks validation.
