-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Gold: agent-ready business views
-- MAGIC Run this entire stage with Run all on Serverless; stop on any error.
-- MAGIC Databricks execution is not yet verified. Source: validated Silver tables.
-- MAGIC Only the three named Gold views are created/replaced; no source table is changed.
-- MAGIC Do not replace unrelated views or rerun after custom grants without reviewing
-- MAGIC ownership/metadata implications. All business dates use 2026-10-23.

-- COMMAND ----------

SELECT assert_true(
  (SELECT count(*) FROM integration_lab.silver.teams) = 4
  AND (SELECT count(*) FROM integration_lab.silver.projects) = 8
  AND (SELECT count(*) FROM integration_lab.silver.work_items) = 40,
  'Gold requires the validated fixed-fixture Silver tables: 4 teams, 8 projects, 40 work items.'
) AS silver_preflight;

-- COMMAND ----------

CREATE OR REPLACE VIEW integration_lab.gold.work_item_detail
COMMENT 'One row per accepted latest work item. Fixed as-of date 2026-10-23. Open means todo/in_progress/blocked; overdue means open and due before as-of date. Effort cost is logged hours times owning team rate, not invoiced spend. Business region is not an access policy.'
AS
SELECT
  DATE '2026-10-23' AS as_of_date,
  w.work_item_id,
  w.project_id,
  p.project_name,
  p.owner_handle AS project_owner_handle,
  p.status AS project_status,
  p.priority AS project_priority,
  p.team_id,
  t.team_name,
  t.region,
  t.manager_handle,
  w.title,
  w.category,
  w.assignee_handle,
  w.priority,
  w.status,
  w.created_date,
  w.due_date,
  w.completed_date,
  w.estimated_hours,
  w.actual_hours,
  t.hourly_rate_eur,
  cast(w.actual_hours * t.hourly_rate_eur AS DECIMAL(18, 2)) AS effort_cost_eur,
  w.blocked_reason,
  w.updated_at,
  w.status IN ('todo', 'in_progress', 'blocked') AS is_open,
  w.status IN ('todo', 'in_progress', 'blocked')
    AND w.due_date < DATE '2026-10-23' AS is_overdue,
  w.status = 'blocked' AS is_blocked,
  w.status IN ('todo', 'in_progress', 'blocked')
    AND w.assignee_handle IS NULL AS is_unassigned_open,
  w.status = 'done' AND w.completed_date > w.due_date AS completed_late
FROM integration_lab.silver.work_items w
JOIN integration_lab.silver.projects p ON w.project_id = p.project_id
JOIN integration_lab.silver.teams t ON p.team_id = t.team_id;

-- COMMAND ----------

CREATE OR REPLACE VIEW integration_lab.gold.project_summary
COMMENT 'One row per project. Budget occurs once at project grain; do not sum it after a work-item join. Effort cost includes logged effort on all accepted items including cancelled items. Positive budget_variance_eur means over budget. Fixed as-of date 2026-10-23.'
AS
WITH work AS (
  SELECT
    project_id,
    count(*) AS total_work_items,
    count_if(is_open) AS open_work_items,
    count_if(is_overdue) AS overdue_work_items,
    count_if(is_blocked) AS blocked_work_items,
    count_if(is_unassigned_open) AS unassigned_open_work_items,
    sum(actual_hours) AS actual_hours,
    sum(effort_cost_eur) AS effort_cost_eur
  FROM integration_lab.gold.work_item_detail
  GROUP BY project_id
),
summary AS (
  SELECT
    DATE '2026-10-23' AS as_of_date,
    p.project_id,
    p.project_name,
    p.owner_handle AS project_owner_handle,
    p.priority,
    p.status,
    p.team_id,
    t.team_name,
    t.region,
    p.start_date,
    p.target_date,
    p.currency,
    p.budget_eur,
    coalesce(w.total_work_items, 0) AS total_work_items,
    coalesce(w.open_work_items, 0) AS open_work_items,
    coalesce(w.overdue_work_items, 0) AS overdue_work_items,
    coalesce(w.blocked_work_items, 0) AS blocked_work_items,
    coalesce(w.unassigned_open_work_items, 0) AS unassigned_open_work_items,
    cast(coalesce(w.actual_hours, 0) AS DECIMAL(18, 2)) AS actual_hours,
    cast(coalesce(w.effort_cost_eur, 0) AS DECIMAL(18, 2)) AS effort_cost_eur
  FROM integration_lab.silver.projects p
  JOIN integration_lab.silver.teams t ON p.team_id = t.team_id
  LEFT JOIN work w ON p.project_id = w.project_id
)
SELECT
  *,
  effort_cost_eur - budget_eur AS budget_variance_eur,
  effort_cost_eur > budget_eur AS is_over_budget
FROM summary;

-- COMMAND ----------

CREATE OR REPLACE VIEW integration_lab.gold.team_summary
COMMENT 'One row per team, aggregated from project_summary at project grain to avoid duplicate budgets. A team can be under its total budget while containing an over-budget project. Fixed as-of date 2026-10-23. No user-specific access filtering is implemented by this view.'
AS
WITH projects AS (
  SELECT
    team_id,
    count(*) AS total_projects,
    count_if(is_over_budget) AS over_budget_projects,
    sum(total_work_items) AS total_work_items,
    sum(open_work_items) AS open_work_items,
    sum(overdue_work_items) AS overdue_work_items,
    sum(blocked_work_items) AS blocked_work_items,
    sum(unassigned_open_work_items) AS unassigned_open_work_items,
    sum(actual_hours) AS actual_hours,
    sum(effort_cost_eur) AS effort_cost_eur,
    sum(budget_eur) AS budget_eur
  FROM integration_lab.gold.project_summary
  GROUP BY team_id
)
SELECT
  DATE '2026-10-23' AS as_of_date,
  t.team_id,
  t.team_name,
  t.region,
  t.manager_handle,
  coalesce(p.total_projects, 0) AS total_projects,
  coalesce(p.over_budget_projects, 0) AS over_budget_projects,
  coalesce(p.total_work_items, 0) AS total_work_items,
  coalesce(p.open_work_items, 0) AS open_work_items,
  coalesce(p.overdue_work_items, 0) AS overdue_work_items,
  coalesce(p.blocked_work_items, 0) AS blocked_work_items,
  coalesce(p.unassigned_open_work_items, 0) AS unassigned_open_work_items,
  cast(coalesce(p.actual_hours, 0) AS DECIMAL(18, 2)) AS actual_hours,
  cast(coalesce(p.effort_cost_eur, 0) AS DECIMAL(18, 2)) AS effort_cost_eur,
  cast(coalesce(p.budget_eur, 0) AS DECIMAL(18, 2)) AS budget_eur,
  cast(coalesce(p.effort_cost_eur, 0) - coalesce(p.budget_eur, 0) AS DECIMAL(18, 2)) AS budget_variance_eur
FROM integration_lab.silver.teams t
LEFT JOIN projects p ON t.team_id = p.team_id;

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW lab_gold_checks AS
WITH expected_projects AS (
  SELECT * FROM VALUES
    ('P001', 3, 2, 100, 8000, 6000),
    ('P002', 3, 1, 30, 2400, 4000),
    ('P003', 3, 1, 82, 8200, 8000),
    ('P004', 3, 2, 40, 4000, 5000),
    ('P005', 3, 1, 72, 6480, 6000),
    ('P006', 3, 1, 48, 4320, 10000),
    ('P007', 3, 1, 20, 1400, 2000),
    ('P008', 0, 0, 25, 1750, 2500)
  AS e(project_id, open_items, overdue_items, hours, effort_cost, budget)
),
expected_teams AS (
  SELECT * FROM VALUES
    ('T01', 6, 3, 130, 10400, 10000),
    ('T02', 6, 3, 122, 12200, 13000),
    ('T03', 6, 2, 120, 10800, 16000),
    ('T04', 3, 1, 45, 3150, 4500)
  AS e(team_id, open_items, overdue_items, hours, effort_cost, budget)
)
SELECT 'work_item_rows' AS metric, cast(count(*) AS DECIMAL(20, 2)) AS actual, cast(40 AS DECIMAL(20, 2)) AS expected
FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'distinct_work_item_ids', count(DISTINCT work_item_id), 40 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'project_rows', count(*), 8 FROM integration_lab.gold.project_summary
UNION ALL
SELECT 'distinct_project_ids', count(DISTINCT project_id), 8 FROM integration_lab.gold.project_summary
UNION ALL
SELECT 'team_rows', count(*), 4 FROM integration_lab.gold.team_summary
UNION ALL
SELECT 'distinct_team_ids', count(DISTINCT team_id), 4 FROM integration_lab.gold.team_summary
UNION ALL
SELECT 'open_work_items', count_if(is_open), 21 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'overdue_work_items', count_if(is_overdue), 9 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'blocked_work_items', count_if(is_blocked), 7 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'unassigned_open_work_items', count_if(is_unassigned_open), 7 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'done_work_items', count_if(status = 'done'), 17 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'cancelled_work_items', count_if(status = 'cancelled'), 2 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'due_today_open_items', count_if(is_open AND due_date = as_of_date), 2 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'late_completions', count_if(completed_late), 2 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'overdue_blocked_items', count_if(is_overdue AND is_blocked), 5 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'actual_hours', sum(actual_hours), 417 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'effort_cost_eur', sum(effort_cost_eur), 36550 FROM integration_lab.gold.work_item_detail
UNION ALL
SELECT 'project_budget_eur', sum(budget_eur), 43500 FROM integration_lab.gold.project_summary
UNION ALL
SELECT 'over_budget_projects', count_if(is_over_budget), 3 FROM integration_lab.gold.project_summary
UNION ALL
SELECT 'project_benchmark_mismatches', count(*), 0
FROM expected_projects e
FULL OUTER JOIN integration_lab.gold.project_summary p ON e.project_id = p.project_id
WHERE e.project_id IS NULL OR p.project_id IS NULL
  OR NOT (p.open_work_items <=> e.open_items)
  OR NOT (p.overdue_work_items <=> e.overdue_items)
  OR NOT (p.actual_hours <=> e.hours)
  OR NOT (p.effort_cost_eur <=> e.effort_cost)
  OR NOT (p.budget_eur <=> e.budget)
UNION ALL
SELECT 'team_benchmark_mismatches', count(*), 0
FROM expected_teams e
FULL OUTER JOIN integration_lab.gold.team_summary t ON e.team_id = t.team_id
WHERE e.team_id IS NULL OR t.team_id IS NULL
  OR NOT (t.total_projects <=> 2)
  OR NOT (t.open_work_items <=> e.open_items)
  OR NOT (t.overdue_work_items <=> e.overdue_items)
  OR NOT (t.actual_hours <=> e.hours)
  OR NOT (t.effort_cost_eur <=> e.effort_cost)
  OR NOT (t.budget_eur <=> e.budget)
UNION ALL
SELECT 'invalid_items_exposed', count(*), 0
FROM integration_lab.gold.work_item_detail
WHERE work_item_id IN ('WI041', 'WI042', 'WI043')
UNION ALL
SELECT 'incorrect_reference_dates', count(*), 0
FROM (
  SELECT as_of_date FROM integration_lab.gold.work_item_detail
  UNION ALL SELECT as_of_date FROM integration_lab.gold.project_summary
  UNION ALL SELECT as_of_date FROM integration_lab.gold.team_summary
) dates
WHERE as_of_date IS NULL OR as_of_date <> DATE '2026-10-23';

-- COMMAND ----------

SELECT assert_true(
  count(*) = 23 AND count_if(NOT (actual <=> expected)) = 0,
  'Gold benchmark failure: inspect lab_gold_checks for actual/expected mismatches.'
) AS gold_validation
FROM lab_gold_checks;

-- COMMAND ----------

SELECT metric, actual, expected,
  CASE WHEN actual <=> expected THEN 'PASS' ELSE 'FAIL' END AS result
FROM lab_gold_checks
ORDER BY metric;
