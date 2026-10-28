-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze to Silver: select, validate, and type
-- MAGIC Run the SQL cells in order on Serverless. Check the preview below
-- MAGIC before continuing to validation and persistent writes.
-- MAGIC Bronze stays unchanged. All persistent writes target integration_lab.silver.
-- MAGIC This fixed-fixture batch is not an incremental production pipeline.

-- COMMAND ----------

SELECT
  work_item_id,
  status,
  actual_hours,
  updated_at,
  row_number() OVER (
    PARTITION BY work_item_id
    ORDER BY try_cast(updated_at AS TIMESTAMP) DESC
  ) AS snapshot_rank
FROM integration_lab.bronze.work_items
WHERE work_item_id = 'WI001'
ORDER BY snapshot_rank;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## First checkpoint
-- MAGIC Expect two WI001 rows: rank 1 is done / 40 hours / 2026-10-22;
-- MAGIC rank 2 is in_progress / 18 hours / 2026-10-08. Both still exist in Bronze.
-- MAGIC Stop here until the result has been checked.
-- MAGIC Later preflight assertions reject invalid keys, timestamps, and timestamp
-- MAGIC ties before we rely on row_number for persistent outputs.

-- COMMAND ----------

SET TIME ZONE 'UTC';

-- COMMAND ----------

SELECT assert_true(
  count(*) = 4
  AND count(DISTINCT team_id) = 4
  AND count_if(
    nullif(trim(team_id), '') IS NULL
    OR nullif(trim(team_name), '') IS NULL
    OR nullif(trim(region), '') IS NULL
    OR nullif(trim(manager_handle), '') IS NULL
    OR try_cast(hourly_rate_eur AS DECIMAL(12, 2)) IS NULL
    OR try_cast(hourly_rate_eur AS DECIMAL(12, 2)) <= 0
  ) = 0,
  'Team preflight failed: expected four unique teams with required labels and positive numeric rates.'
) AS teams_preflight
FROM integration_lab.bronze.teams;

-- COMMAND ----------

SELECT assert_true(
  count(*) = 8
  AND count(DISTINCT p.project_id) = 8
  AND count_if(
    nullif(trim(p.project_id), '') IS NULL
    OR t.team_id IS NULL
    OR nullif(trim(p.project_name), '') IS NULL
    OR nullif(trim(p.owner_handle), '') IS NULL
    OR p.priority IS NULL OR p.priority NOT IN ('low', 'medium', 'high')
    OR p.status IS NULL OR p.status NOT IN ('active', 'on_hold', 'completed')
    OR p.currency IS NULL OR p.currency <> 'EUR'
    OR try_cast(p.start_date AS DATE) IS NULL
    OR try_cast(p.target_date AS DATE) IS NULL
    OR try_cast(p.target_date AS DATE) < try_cast(p.start_date AS DATE)
    OR try_cast(p.budget_eur AS DECIMAL(12, 2)) IS NULL
    OR try_cast(p.budget_eur AS DECIMAL(12, 2)) <= 0
  ) = 0,
  'Project preflight failed: check keys, parent teams, required labels, enums, dates, and positive EUR budgets.'
) AS projects_preflight
FROM integration_lab.bronze.projects p
LEFT JOIN integration_lab.bronze.teams t ON p.team_id = t.team_id;

-- COMMAND ----------

SELECT assert_true(
  count(*) = 44
  AND count_if(
    nullif(trim(work_item_id), '') IS NULL
    OR try_cast(updated_at AS TIMESTAMP) IS NULL
  ) = 0,
  'Work-item preflight failed: expected 44 rows with usable business keys and update timestamps.'
) AS snapshot_preflight
FROM integration_lab.bronze.work_items;

-- COMMAND ----------

SELECT assert_true(
  count(*) = 0,
  'Ambiguous snapshots: repeated work-item ID and parsed update time. Inspect before selecting a winner.'
) AS timestamp_tie_check
FROM (
  SELECT work_item_id, try_cast(updated_at AS TIMESTAMP) AS parsed_updated_at
  FROM integration_lab.bronze.work_items
  GROUP BY work_item_id, try_cast(updated_at AS TIMESTAMP)
  HAVING count(*) > 1
) ties;

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW lab_silver_ranked AS
SELECT
  *,
  try_cast(updated_at AS TIMESTAMP) AS parsed_updated_at,
  row_number() OVER (
    PARTITION BY work_item_id
    ORDER BY try_cast(updated_at AS TIMESTAMP) DESC
  ) AS snapshot_rank
FROM integration_lab.bronze.work_items;

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW lab_silver_checked AS
WITH typed AS (
  SELECT
    *,
    try_cast(created_date AS DATE) AS parsed_created_date,
    try_cast(due_date AS DATE) AS parsed_due_date,
    try_cast(completed_date AS DATE) AS parsed_completed_date,
    try_cast(estimated_hours AS DECIMAL(12, 2)) AS parsed_estimated_hours,
    try_cast(actual_hours AS DECIMAL(12, 2)) AS parsed_actual_hours
  FROM lab_silver_ranked
  WHERE snapshot_rank = 1
)
SELECT
  w.*,
  filter(array(
    CASE WHEN p.project_id IS NULL THEN 'unknown_project' END,
    CASE WHEN w.status IS NULL OR w.status NOT IN
      ('todo', 'in_progress', 'blocked', 'done', 'cancelled')
      THEN 'invalid_status' END,
    CASE WHEN w.parsed_due_date IS NULL THEN 'invalid_due_date' END,
    CASE WHEN w.parsed_created_date IS NULL THEN 'invalid_created_date' END,
    CASE WHEN w.parsed_due_date < w.parsed_created_date THEN 'due_before_created' END,
    CASE WHEN w.parsed_created_date > cast(w.parsed_updated_at AS DATE)
      THEN 'created_after_updated' END,
    CASE WHEN nullif(trim(w.title), '') IS NULL THEN 'missing_title' END,
    CASE WHEN w.category IS NULL OR w.category NOT IN
      ('analysis', 'configuration', 'development', 'documentation', 'security', 'testing', 'design', 'cleanup')
      THEN 'invalid_category' END,
    CASE WHEN w.priority IS NULL OR w.priority NOT IN ('low', 'medium', 'high')
      THEN 'invalid_priority' END,
    CASE WHEN w.parsed_estimated_hours IS NULL OR w.parsed_estimated_hours < 0
      THEN 'invalid_estimated_hours' END,
    CASE WHEN w.parsed_actual_hours IS NULL OR w.parsed_actual_hours < 0
      THEN 'invalid_actual_hours' END,
    CASE WHEN w.status = 'done' AND (
      w.parsed_completed_date IS NULL
      OR w.parsed_completed_date < w.parsed_created_date
      OR w.parsed_completed_date > cast(w.parsed_updated_at AS DATE)
    ) THEN 'invalid_completed_date' END,
    CASE WHEN w.status <> 'done' AND nullif(trim(w.completed_date), '') IS NOT NULL
      THEN 'unexpected_completed_date' END,
    CASE WHEN w.status = 'blocked' AND nullif(trim(w.blocked_reason), '') IS NULL
      THEN 'missing_blocked_reason' END,
    CASE WHEN w.status <> 'blocked' AND nullif(trim(w.blocked_reason), '') IS NOT NULL
      THEN 'unexpected_blocked_reason' END
  ), reason -> reason IS NOT NULL) AS rejection_reasons
FROM typed w
LEFT JOIN integration_lab.bronze.projects p ON w.project_id = p.project_id;

-- COMMAND ----------

SELECT
  work_item_id,
  project_id,
  status,
  due_date,
  rejection_reasons
FROM lab_silver_checked
WHERE size(rejection_reasons) > 0
ORDER BY work_item_id;

-- COMMAND ----------

SELECT 'accepted_latest' AS outcome, count(*) AS actual_rows, 40 AS expected_rows
FROM lab_silver_checked WHERE size(rejection_reasons) = 0
UNION ALL
SELECT 'quarantined_latest', count(*), 3
FROM lab_silver_checked WHERE size(rejection_reasons) > 0
UNION ALL
SELECT 'superseded_snapshots', count(*), 1
FROM lab_silver_ranked WHERE snapshot_rank > 1;

-- COMMAND ----------

SELECT assert_true(
  (SELECT count(*) FROM lab_silver_checked WHERE size(rejection_reasons) = 0) = 40
  AND (SELECT count(*) FROM lab_silver_checked WHERE size(rejection_reasons) > 0) = 3
  AND (SELECT count(*) FROM lab_silver_ranked WHERE snapshot_rank > 1) = 1,
  'Pre-write reconciliation failed: expected 40 accepted, 3 quarantined, and 1 superseded snapshot.'
) AS pre_write_check;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Checkpoint before persistent writes
-- MAGIC Check the three rejection reasons and the 40 / 3 / 1 split.
-- MAGIC Everything so far is read-only against Bronze or session-local state.
-- MAGIC The following five CREATE TABLE cells persist Silver and audit outputs.
-- MAGIC They intentionally fail if a target table already exists. Do not use Run all
-- MAGIC to recover from a failure. Temporary views must be recreated after a session
-- MAGIC restart; Bronze and already-created Delta tables remain persistent.

-- COMMAND ----------

CREATE TABLE integration_lab.silver.teams
USING DELTA
AS
SELECT
  team_id,
  team_name,
  region,
  manager_handle,
  cast(hourly_rate_eur AS DECIMAL(12, 2)) AS hourly_rate_eur,
  source_file,
  ingested_at,
  current_timestamp() AS processed_at
FROM integration_lab.bronze.teams;

-- COMMAND ----------

CREATE TABLE integration_lab.silver.projects
USING DELTA
AS
SELECT
  project_id,
  team_id,
  project_name,
  owner_handle,
  priority,
  status,
  cast(start_date AS DATE) AS start_date,
  cast(target_date AS DATE) AS target_date,
  cast(budget_eur AS DECIMAL(12, 2)) AS budget_eur,
  currency,
  source_file,
  ingested_at,
  current_timestamp() AS processed_at
FROM integration_lab.bronze.projects;

-- COMMAND ----------

CREATE TABLE integration_lab.silver.work_items
USING DELTA
AS
SELECT
  work_item_id,
  project_id,
  title,
  category,
  nullif(trim(assignee_handle), '') AS assignee_handle,
  priority,
  status,
  parsed_created_date AS created_date,
  parsed_due_date AS due_date,
  parsed_completed_date AS completed_date,
  parsed_estimated_hours AS estimated_hours,
  parsed_actual_hours AS actual_hours,
  nullif(trim(blocked_reason), '') AS blocked_reason,
  parsed_updated_at AS updated_at,
  source_file,
  ingested_at,
  current_timestamp() AS processed_at
FROM lab_silver_checked
WHERE size(rejection_reasons) = 0;

-- COMMAND ----------

CREATE TABLE integration_lab.silver.work_items_quarantine
USING DELTA
AS
SELECT
  * EXCEPT (
    parsed_updated_at, snapshot_rank, parsed_created_date, parsed_due_date,
    parsed_completed_date, parsed_estimated_hours, parsed_actual_hours
  ),
  current_timestamp() AS quarantined_at
FROM lab_silver_checked
WHERE size(rejection_reasons) > 0;

-- COMMAND ----------

CREATE TABLE integration_lab.silver.work_items_superseded
USING DELTA
AS
SELECT
  * EXCEPT (parsed_updated_at, snapshot_rank),
  'superseded_snapshot' AS superseded_reason,
  current_timestamp() AS processed_at
FROM lab_silver_ranked
WHERE snapshot_rank > 1;

-- COMMAND ----------

SELECT 'teams' AS table_name, count(*) AS actual_rows, 4 AS expected_rows
FROM integration_lab.silver.teams
UNION ALL
SELECT 'projects', count(*), 8 FROM integration_lab.silver.projects
UNION ALL
SELECT 'work_items', count(*), 40 FROM integration_lab.silver.work_items
UNION ALL
SELECT 'work_items_quarantine', count(*), 3 FROM integration_lab.silver.work_items_quarantine
UNION ALL
SELECT 'work_items_superseded', count(*), 1 FROM integration_lab.silver.work_items_superseded;

-- COMMAND ----------

SELECT assert_true(
  (SELECT count(*) FROM integration_lab.silver.teams) = 4
  AND (SELECT count(DISTINCT team_id) FROM integration_lab.silver.teams) = 4
  AND (SELECT count(*) FROM integration_lab.silver.projects) = 8
  AND (SELECT count(DISTINCT project_id) FROM integration_lab.silver.projects) = 8
  AND (SELECT count(*) FROM integration_lab.silver.work_items) = 40
  AND (SELECT count(DISTINCT work_item_id) FROM integration_lab.silver.work_items) = 40
  AND (SELECT count(*) FROM integration_lab.silver.work_items_quarantine) = 3
  AND (SELECT count(*) FROM integration_lab.silver.work_items_superseded) = 1
  AND (SELECT count(*) FROM integration_lab.bronze.work_items) = 44,
  'Persisted Silver counts or key uniqueness differ from the fixture, or Bronze row count changed.'
) AS persisted_counts_check;

-- COMMAND ----------

SELECT assert_true(
  count(*) = 3
  AND concat_ws(',', sort_array(collect_list(
    concat(work_item_id, ':', concat_ws(';', rejection_reasons))
  ))) = 'WI041:invalid_status,WI042:unknown_project,WI043:invalid_due_date',
  'Quarantine IDs or rejection reasons differ from the expected three cases.'
) AS quarantine_check
FROM integration_lab.silver.work_items_quarantine;

-- COMMAND ----------

SELECT assert_true(
  count(*) = 1
  AND count_if(
    status = 'done'
    AND actual_hours = 40
    AND updated_at = TIMESTAMP '2026-10-22 09:00:00'
  ) = 1,
  'WI001 did not retain the latest done snapshot with 40 actual hours.'
) AS latest_snapshot_check
FROM integration_lab.silver.work_items
WHERE work_item_id = 'WI001';

-- COMMAND ----------

SELECT assert_true(
  count(*) = 1
  AND count_if(work_item_id = 'WI001' AND actual_hours = '18') = 1,
  'Superseded audit table should contain only the older WI001 snapshot.'
) AS superseded_check
FROM integration_lab.silver.work_items_superseded;

-- COMMAND ----------

SELECT
  work_item_id,
  status,
  due_date,
  typeof(due_date) AS due_date_type,
  actual_hours,
  typeof(actual_hours) AS actual_hours_type,
  updated_at,
  typeof(updated_at) AS updated_at_type
FROM integration_lab.silver.work_items
WHERE work_item_id = 'WI001';

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Completion checkpoint
-- MAGIC Expect persisted counts 4 / 8 / 40 / 3 / 1 and successful assertions.
-- MAGIC WI001 must be done with 40 hours; due_date is DATE, actual_hours is
-- MAGIC DECIMAL(12,2), and updated_at is TIMESTAMP. Bronze stays at 44 work-item rows.
-- MAGIC The three invalid latest records and one older snapshot remain auditable.
-- MAGIC Stop before creating Gold business metrics or connecting Genie.
