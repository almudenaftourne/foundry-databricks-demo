# 09. Build business-ready Gold views

[Previous](08-prepare-silver.md) | [Home](../README.md) |
[Next: Genie](10-create-genie.md) |
[SQL notebook](../notebooks/03_build_gold.sql)

**Goal:** give Genie governed data with clear grain and business definitions.

**Requires:** access to Silver, approved compute, `USE CATALOG`, `USE SCHEMA`,
and `CREATE TABLE` in the Gold schema. The view owner must retain the required
access to its dependencies.

1. Import `notebooks\03_build_gold.sql` into the Databricks lab folder.
2. Select **Serverless** and **Run all**.
3. Check that every cell succeeds and the final table has **23 checks, all PASS**.

## What this creates

| View in integration_lab.gold | Grain and use |
| --- | --- |
| work_item_detail | One row per accepted latest item: owners, blockers, dates, status |
| project_summary | One row per project: workload, effort cost, budget |
| team_summary | One row per team: project and workload totals |

These are query-backed views over Silver, not materialized copies or vector indexes.
Quarantine and audit outputs are not exposed to Genie.

## Business definitions

- **Snapshot:** 2026-10-23, not the current day.
- **Open:** todo, in_progress, or blocked.
- **Overdue:** open and due strictly before the snapshot; due today is not overdue.
- **Effort cost:** accepted logged hours times the team's hourly rate, in EUR.
  This includes logged effort on cancelled items; it is not invoices or cloud cost.
- **Budget:** aggregate at project grain, never by summing a repeated item join.

## Expected results

| Metric | Expected |
| --- | --- |
| Work items / projects / teams | 40 / 8 / 4 |
| Open / overdue / blocked / unassigned open | 21 / 9 / 7 / 7 |
| Actual hours / modeled effort cost | 417 / EUR 36,550 |
| Total budget / over-budget projects | EUR 43,500 / 3 |

The checks also compare every project/team against the
[answer key](../data/README.md). The assertion cell returns NULL on success.

The notebook creates/replaces only the three named lab views. Do not overwrite
unrelated objects. Before rerunning after custom sharing/security changes,
review replacement behavior: ownership, grants, or metadata can be affected.
Queries use chargeable compute.

**Ready when:** all 23 checks pass. Continue to Genie.

Reference: [CREATE VIEW](https://learn.microsoft.com/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-view).
