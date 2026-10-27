-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Raw CSV files to Bronze Delta tables
-- MAGIC Draft: not yet executed in Databricks. Run one SQL cell at a time.
-- MAGIC This notebook starts chargeable compute when executed. Initially run only
-- MAGIC the preview cell below, then stop for the first checkpoint.
-- MAGIC Source fields stay STRING. Blank CSV fields may read as NULL.
-- MAGIC No deduplication, date conversion, or business filtering happens here.

-- COMMAND ----------

SELECT *
FROM read_files(
  '/Volumes/integration_lab/raw/source_files/teams.csv',
  format => 'csv',
  header => true,
  schema => 'team_id STRING, team_name STRING, region STRING, manager_handle STRING, hourly_rate_eur STRING',
  schemaEvolutionMode => 'none',
  mode => 'FAILFAST',
  enforceSchema => false
)
ORDER BY team_id
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Checkpoint: stop before writing tables
-- MAGIC The preview must contain four teams, T01 through T04, with the correct
-- MAGIC column names. Continue only after checking that result.
-- MAGIC The next three cells create managed Delta tables. They intentionally fail
-- MAGIC if a target already exists: do not replace a table or append data blindly.
-- MAGIC CSV structural errors fail explicitly; invalid business dates and statuses
-- MAGIC remain readable because source fields are STRING.

-- COMMAND ----------

CREATE TABLE integration_lab.bronze.teams
USING DELTA
AS
SELECT
  *,
  _metadata.file_path AS source_file,
  current_timestamp() AS ingested_at
FROM read_files(
  '/Volumes/integration_lab/raw/source_files/teams.csv',
  format => 'csv',
  header => true,
  schema => 'team_id STRING, team_name STRING, region STRING, manager_handle STRING, hourly_rate_eur STRING',
  schemaEvolutionMode => 'none',
  mode => 'FAILFAST',
  enforceSchema => false
);

-- COMMAND ----------

CREATE TABLE integration_lab.bronze.projects
USING DELTA
AS
SELECT
  *,
  _metadata.file_path AS source_file,
  current_timestamp() AS ingested_at
FROM read_files(
  '/Volumes/integration_lab/raw/source_files/projects.csv',
  format => 'csv',
  header => true,
  schema => 'project_id STRING, team_id STRING, project_name STRING, owner_handle STRING, priority STRING, status STRING, start_date STRING, target_date STRING, budget_eur STRING, currency STRING',
  schemaEvolutionMode => 'none',
  mode => 'FAILFAST',
  enforceSchema => false
);

-- COMMAND ----------

CREATE TABLE integration_lab.bronze.work_items
USING DELTA
AS
SELECT
  *,
  _metadata.file_path AS source_file,
  current_timestamp() AS ingested_at
FROM read_files(
  '/Volumes/integration_lab/raw/source_files/work_items.csv',
  format => 'csv',
  header => true,
  schema => 'work_item_id STRING, project_id STRING, title STRING, category STRING, assignee_handle STRING, priority STRING, status STRING, created_date STRING, due_date STRING, completed_date STRING, estimated_hours STRING, actual_hours STRING, blocked_reason STRING, updated_at STRING',
  schemaEvolutionMode => 'none',
  mode => 'FAILFAST',
  enforceSchema => false
);

-- COMMAND ----------

SELECT 'teams' AS table_name, count(*) AS actual_rows, 4 AS expected_rows
FROM integration_lab.bronze.teams
UNION ALL
SELECT 'projects', count(*), 8
FROM integration_lab.bronze.projects
UNION ALL
SELECT 'work_items', count(*), 44
FROM integration_lab.bronze.work_items;

-- COMMAND ----------

SELECT assert_true(
  (SELECT count(*) FROM integration_lab.bronze.teams) = 4
  AND (SELECT count(*) FROM integration_lab.bronze.projects) = 8
  AND (SELECT count(*) FROM integration_lab.bronze.work_items) = 44
  AND (SELECT count(DISTINCT work_item_id) FROM integration_lab.bronze.work_items) = 43
  AND (SELECT count(*) FROM integration_lab.bronze.work_items WHERE work_item_id = 'WI001') = 2,
  'Bronze reconciliation failed: expected 4 teams, 8 projects, 44 work-item rows, 43 distinct work-item IDs, and 2 WI001 snapshots.'
) AS row_count_check;

-- COMMAND ----------

WITH provenance AS (
  SELECT source_file, ingested_at, 'teams.csv' AS expected_file
  FROM integration_lab.bronze.teams
  UNION ALL
  SELECT source_file, ingested_at, 'projects.csv'
  FROM integration_lab.bronze.projects
  UNION ALL
  SELECT source_file, ingested_at, 'work_items.csv'
  FROM integration_lab.bronze.work_items
)
SELECT assert_true(
  count_if(
    source_file IS NULL
    OR ingested_at IS NULL
    OR NOT endswith(source_file, concat('/', expected_file))
  ) = 0,
  'Bronze provenance is missing or refers to an unexpected source file.'
) AS provenance_check
FROM provenance;

-- COMMAND ----------

SELECT work_item_id, project_id, status, due_date, actual_hours, updated_at
FROM integration_lab.bronze.work_items
WHERE work_item_id IN ('WI001', 'WI041', 'WI042', 'WI043')
ORDER BY work_item_id, updated_at;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Completion checkpoint
-- MAGIC Counts must be 4 / 8 / 44, both assertion cells must succeed, and the last
-- MAGIC result must show five records: two WI001 snapshots and all three invalid
-- MAGIC business records. assert_true returns NULL on success; an error is failure.
-- MAGIC The original files remain in the volume. Bronze does not prove Silver,
-- MAGIC Gold, or Genie accuracy. Stop before implementing cleaning.
