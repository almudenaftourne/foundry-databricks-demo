# 08. Clean and validate Silver

[Previous](07-ingest-bronze.md) | [Home](../README.md) |
[Next: Gold](09-build-gold.md) |
[SQL notebook](../notebooks/02_prepare_silver.sql)

**Goal:** select the latest snapshots, assign types, and make rejected data visible.

**Requires:** access to Bronze, approved notebook compute, and the privileges
to create tables in `integration_lab.silver`.

## Run the notebook

1. Import `notebooks\02_prepare_silver.sql` into the Databricks lab folder.
2. Select **Serverless**.
3. Run the first preview. WI001's latest row must be `done`, with 40 actual
   hours and update time `2026-10-22T09:00:00Z`; its older row has 18 hours.
4. Run the preflight assertions and temporary-view cells in order.
5. Check the rejection preview and **40 accepted / 3 quarantined / 1 superseded**
   reconciliation before running the five persistent `CREATE TABLE` cells.
6. Run the remaining validation cells. Stop at any error.

No chat confirmation is needed between steps. This notebook runs in one session:
temporary views must be recreated after a restart, without blindly rerunning
successful persistent writes.

## Understand the outputs

| Table in integration_lab.silver | Expected rows |
| --- | --- |
| teams | 4 |
| projects | 8 |
| work_items | 40 |
| work_items_quarantine | 3 |
| work_items_superseded | 1 |

The cleaning contract:

- Parse update times and keep the latest snapshot per work-item ID.
- Reject ambiguous key/update-time ties instead of selecting by file order.
- Validate business fields and relationships; do not silently accept failed casts.
- Quarantine WI041 (`invalid_status`), WI042 (`unknown_project`), and
  WI043 (`invalid_due_date`) with their original values.
- Preserve blank assignees as missing, not fabricated users.
- Retain the superseded WI001 row for audit.

## Check the result

All assertions must succeed. WI001 must be `done` with **40.00** actual hours;
`due_date` is DATE, `actual_hours` is DECIMAL(12,2), and `updated_at` is TIMESTAMP.
Bronze stays at 44 work-item rows.

The reconciliation is **44 = 1 superseded + 3 quarantined + 40 accepted**.
The fixture's reference date remains **2026-10-23**.

Persistent writes deliberately fail if targets already exist. These are separate
writes, not an atomic transaction or production incremental pipeline. Keep
Bronze unchanged and inspect existing outputs before recovery.

**Ready when:** counts, rejection reasons, latest-row checks, and types match.
Keep all outputs; compute and storage remain chargeable.

References: [try_cast](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/try_cast),
[row_number](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/row_number).
