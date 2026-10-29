# 06. Curate Genie over Gold

[Previous](05-build-gold.md) | [Home](../README.md) |
[Next: Foundry project](07-create-foundry-project.md)

**Goal:** turn governed business data into a reusable natural-language analytics tool.

## Prerequisites

- The three Gold views and their 23 passing checks.
- Databricks SQL authoring access and an approved pro/serverless SQL warehouse.
- `USE CATALOG`, `USE SCHEMA`, and `SELECT` on the three Gold views.
- Approved Genie/partner-powered AI settings, prepared by the relevant
  administrator if needed.

You do not need workspace-admin status just to query the data. A feature
entitlement, warehouse permission, and data permission are different controls.
Use the [authentication/access annex](appendix-authentication.md) for missing
access or unexpected account problems.

## 1. Select the warehouse

Reuse a suitable approved warehouse. If an authorized builder must create one,
open **SQL Warehouses > Create** and review:

| Setting | Example |
| --- | --- |
| Name | `wh-foundry-genie-lab` |
| Type | Serverless |
| Size | Smallest suitable offered size |
| Auto Stop | 5 minutes |
| Clusters | 1 / 1 where configurable |
| Channel | Current/standard |

Review current charges before creation: creating a warehouse can start it.
Auto Stop is not a spending cap. Do not change a shared warehouse to match
these settings.

## 2. Check Gold access

In **SQL Editor**, select the warehouse and run:

```sql
SELECT 'work_item_detail' AS view_name, COUNT(*) AS row_count
FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'project_summary', COUNT(*)
FROM integration_lab.gold.project_summary
UNION ALL
SELECT 'team_summary', COUNT(*)
FROM integration_lab.gold.team_summary;
```

Expect **40 items / 8 projects / 4 teams**. Resolve any error or mismatch before
continuing. This proves this user's current reads, not access for all users.

## 3. Create the curated Genie Agent

1. Open **Genie Agents** / **Genie** and select **New**.
2. Select exactly `integration_lab.gold.work_item_detail`,
   `integration_lab.gold.project_summary`, and `integration_lab.gold.team_summary`.
3. Create it, name it **Project Delivery Lab**, and select the warehouse above
   in its configuration. Portal labels can vary.
4. Describe it as synthetic project delivery, overdue work, blockers, and modeled
   effort budgets with reference date **2026-10-23**.

Do not add Bronze, Silver, audit tables, or the local answer key. This is a
curated Genie Agent, not workspace-wide Genie One.

## 4. Add business instructions

Open the agent's text/general **Instructions**, review any existing context,
then save one consistent block:

```text
Answer questions about the synthetic project-delivery dataset by querying
the configured Gold views. Do not invent missing values.

Snapshot:
- All views describe 2026-10-23, not today's date.
- Interpret time-sensitive questions relative to as_of_date and state it.

Choose the correct grain:
- work_item_detail: one row per valid latest item; use for item lists,
  assignees, recorded blockers, dates, and status.
- project_summary: one row per project; use for budgets, owners, effort
  cost, over-budget projects, and project-level workload.
- team_summary: one row per team; use for team totals.
- These views describe the same work at different grains. Never add their
  totals together or sum project budgets repeated by an item join.
- Prefer one view that answers the question; respect keys/grain when joining.

Definitions:
- Open means todo, in_progress, or blocked. Done/cancelled are not open.
- Use the detail flags is_open, is_overdue, is_blocked, is_unassigned_open.
- Due on as_of_date is not overdue.
- In summary views, sum *_work_items for item totals; row counts count
  projects or teams.
- effort_cost_eur is actual logged hours times the team's hourly rate,
  including logged effort on cancelled items. It is not invoices or cloud cost.
- All monetary amounts are EUR.
- budget_variance_eur is effort cost minus budget; positive means over budget.
- Use is_over_budget in project_summary, or over_budget_projects in team_summary.
- A team under its total budget can contain over-budget projects.

Boundaries:
- Fictional owner handles and business regions do not define access rights.
- Recorded blocker reasons are reports, not proven root causes.
- No historical progress, remaining effort, capacity, blocked-since history,
  or dependency graph is provided. Do not invent forecasts or critical paths.
- A target date is a plan, not a forecast.
- estimated_hours is an original estimate, not remaining effort. Do not
  infer remaining work by subtracting actual hours.
- Use SQL for numeric calculations. Separate facts, interpretations, and unknowns.
- Query only; do not claim to create tickets, run jobs, or change records.
```

Instructions guide answers; they are not an authorization boundary.
For customization, see [what to change](customization.md).

## 5. Add an example, if useful

In the SQL examples area, add:

**Question:** List completed projects with their owners.

```sql
SELECT project_id, project_name, project_owner_handle
FROM integration_lab.gold.project_summary
WHERE status = 'completed'
ORDER BY project_id;
```

Run/review the example before marking it trusted. Do not paste the answer key
into the instructions.

## 6. Check the answers

Ask questions in the agent chat, not a setup/code assistant. Do not include
the expected answers in the question.

| Question | Expected |
| --- | --- |
| As of 2026-10-23, how many items are open and how many are overdue? | 21 open / 9 overdue |
| Which projects are over their effort budget, and by how much in EUR? | P001: 2,000; P003: 200; P005: 480 |
| List overdue blocked items with recorded blocker and project owner. | WI002, WI012, WI018, WI022, WI028; details match the view |
| Can this snapshot reliably predict when P001 will finish? | Insufficient forecasting data; no invented remaining effort or finish date |

Inspect generated SQL where available: correct view/grain, fixed date, and
returned values matching the narrative. Use a fresh conversation when checking
independent questions. The [full answer key](../data/README.md) supports additional
checks.

## Sharing and costs

For another approved demo user, have the authorized owner share the Genie with
the appropriate run permission and ensure the underlying Gold data is accessible.
Do not add the user to workspace admins merely to make the demo work.
Warehouse author credentials and end-user data authorization are distinct;
follow the current Genie permission documentation.

Keep the Genie and views for Foundry. Queries use chargeable compute; allow
configured auto-stop or stop a dedicated warehouse when finished, not a shared one.

References: [Genie setup](https://learn.microsoft.com/azure/databricks/genie-agents/set-up),
[curation](https://learn.microsoft.com/azure/databricks/genie-agents/tune-quality),
[warehouses](https://learn.microsoft.com/azure/databricks/compute/sql-warehouse/create).
