# Lesson 09: build agent-ready Gold views

[Home](../README.md) | [Previous: Silver](08-prepare-silver.md) |
[SQL notebook](../notebooks/03_build_gold.sql)

**Status:** user-validated on 2026-10-26. Following instructions to check
error-free execution and 23 passing results, the learner confirmed completion.
This is learner-reported evidence, not independently inspected workspace output.
View documentation reviewed on 2026-10-26.

## Run this stage as one batch

1. Import `notebooks\03_build_gold.sql` into your Databricks lab folder.
2. Select **Serverless** and use **Run all**.
3. If any cell fails, stop and inspect its error. Do not treat a later result
   or cached display as proof of a successful full run.
4. Expect the final table to contain **23 checks, all PASS**.

There are no per-cell chat checkpoints in this lesson. The explanations below
are available when you want to understand a specific part.

## What this stage creates

| View in integration_lab.gold | Grain | Main use |
| --- | --- | --- |
| work_item_detail | One row per valid latest work item | Investigate individual work, owners, blockers, and overdue dates |
| project_summary | One row per project | Compare workload, effort cost, and budgets |
| team_summary | One row per team | Aggregate project and workload information without repeating budgets |

These are ordinary query-backed views, not materialized tables or vector-search
indexes. They query the underlying Silver tables when used. The notebook does
not write to Bronze or Silver or expose the quarantine/audit tables.

## Key modeling decisions

- The fixed **as_of_date is 2026-10-23**. Running this notebook later must not
  change the benchmark's definition of overdue.
- Open means todo, in_progress, or blocked. Done/cancelled items are not open.
- Overdue means open and due strictly before the reference date. Two open items
  are due on the reference date and must not be counted overdue.
- Effort cost is actual logged hours times the owning team's hourly rate,
  including already logged effort on cancelled work. It is not invoice spend.
- Budget belongs to the project grain. The detail view deliberately omits the
  project budget; the team view aggregates the project view, not a repeated
  project/work-item join.
- Projects without work and teams without projects remain visible through left
  joins. Zeros represent absent child activity, not suppressed query errors.
- Comments describe the views' grain and semantics. Genie instructions and
  permission tests will still be added later.

## Expected results

| Metric | Expected |
| --- | --- |
| Work items / projects / teams | 40 / 8 / 4, with unique IDs at each grain |
| Open / overdue / blocked / unassigned open | 21 / 9 / 7 / 7 |
| Done / cancelled | 17 / 2 |
| Open items due today / late completions / overdue blocked | 2 / 2 / 5 |
| Actual hours | 417 |
| Modeled effort cost | EUR 36,550 |
| Total project budget | EUR 43,500 |
| Over-budget projects | 3 |

Checks also compare every project and team against the
[reference dataset](../data/README.md), exclude invalid work-item IDs, and check
the reference date in every view. This guards against plausible-looking global
totals hiding an incorrect join or allocation.

The assertion cell returns NULL on success. The final results table is the
single handoff checkpoint: 23 checks, all PASS, with no execution errors.

## Permissions, reruns, and cost

Creating views requires `USE CATALOG`, `USE SCHEMA`, and `CREATE TABLE` in the
target schema, plus appropriate access to source objects. The learner must
retain the access needed to own and query the view dependencies.

The notebook creates or replaces only the three named lab views. For an initial
lab setup, run it as one stage; no table replacement is involved. Do not replace
an unrelated existing object with the same name.

Before rerunning after security exercises, review the view type/runtime's
replacement behavior: replacement can affect ownership, grants, and other
metadata. Do not assume that custom grants survive. Prefer a reviewed in-place
change when preserving those controls matters.

Queries use chargeable compute. These views do not introduce another
materialized copy of the data, but evaluating them and their assertions still
uses compute.

## After this stage

Confirm the full run completed and all checks passed. Then create a curated
Genie Agent using these Gold views, with a SQL warehouse, clear instructions,
and benchmark questions. No Genie or identity-passthrough claim is established
by Gold view validation.
Continue to [Lesson 10: create and test Genie](10-create-genie.md).

## Official reference

- [CREATE VIEW: comments, privileges, and replacement behavior](https://learn.microsoft.com/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-view)
