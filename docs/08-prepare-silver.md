# Lesson 08: make source records trustworthy in Silver

[Home](../README.md) | [Previous: Bronze](07-ingest-bronze.md) |
[SQL notebook](../notebooks/02_prepare_silver.sql)

**Status:** user-validated on 2026-10-26. The learner supplied the
final type-inspection result: WI001 is done, due_date is DATE, actual_hours is
DECIMAL(12,2) with value 40.00, and updated_at is TIMESTAMP at
2026-10-22T09:00:00.000+00:00. The learner also confirms persisted counts of
4 teams, 8 projects, 40 work items, 3 quarantined records, and 1 superseded
record, with every assertion passing. This is learner-provided execution
evidence, not independent workspace inspection. SQL function documentation
reviewed on 2026-10-26.

**Goal:** learn snapshot selection, type conversion, validation, and quarantine
without changing Bronze or silently losing rejected records.

## 1. Understand the outputs

| Output in integration_lab.silver | Expected rows | Purpose |
| --- | --- | --- |
| teams | 4 | Validated teams with decimal hourly rates |
| projects | 8 | Validated projects with dates and decimal budgets |
| work_items | 40 | Latest valid work items with typed dates, effort, and update timestamps |
| work_items_quarantine | 3 | Invalid latest records, raw values, and explicit rejection reasons |
| work_items_superseded | 1 | The older WI001 snapshot, retained for audit |

Reconciliation:

```text
44 Bronze work-item rows
  = 1 superseded snapshot
  + 3 quarantined latest records
  + 40 accepted latest records
```

The audit tables belong to the pipeline, not the business dataset exposed to
Genie. We will select the appropriate Gold datasets later.

## 2. Import and run the first preview only

1. In Databricks **Workspace**, use your lab/user folder's **Import** action.
2. Select the local `notebooks\02_prepare_silver.sql` source file.
3. Open the imported multi-cell SQL notebook and select **Serverless**.
4. Run only the first SQL cell. Do not select **Run all**.

Expected WI001 result:

| snapshot_rank | status | actual_hours | updated_at |
| --- | --- | --- | --- |
| 1 | done | 40 | 2026-10-22T09:00:00Z |
| 2 | in_progress | 18 | 2026-10-08T09:00:00Z |

`PARTITION BY work_item_id` gives each work item its own ranking.
`ORDER BY` parsed update time descending puts the newest snapshot first.
File order is irrelevant. The preview does not delete the older row.

**Stop here for the first checkpoint.** Confirm both rows and ranks before
continuing.

## 3. Run the preflight checks

After the preview is confirmed, run the next SQL cells in order:

1. Set the session time zone to UTC.
2. Validate team keys, labels, and positive rates.
3. Validate project keys, parent teams, enums, dates, and budgets.
4. Check work-item keys and parseable update times.
5. Reject timestamp ties for the same work-item key.

All assertion cells should succeed and return NULL. Stop at any error.

Why reject ties? `row_number` cannot reliably pick between rows with the same
ordering value. This teaching pipeline conservatively stops on any repeated
key/update-time pair, even identical records. Missing keys or timestamps also
stop selection rather than causing an arbitrary winner.

Team and project data are expected to be valid in this fixture; problems there
fail the batch explicitly. Work-item business validation, by contrast, routes
invalid latest records to quarantine.

## 4. Build session-local views and inspect rejection reasons

Run the two **CREATE OR REPLACE TEMP VIEW** cells in order:

- `lab_silver_ranked` ranks snapshots but retains all 44 Bronze rows.
- `lab_silver_checked` examines only the 43 latest snapshots and adds parsed
  fields and a `rejection_reasons` array.

These temporary views do not replace persistent tables. They exist in the
current notebook execution session and must be recreated after a restart.

Then run the rejection preview:

| work_item_id | Raw issue | rejection_reasons |
| --- | --- | --- |
| WI041 | Unknown status | [invalid_status] |
| WI042 | Project P999 does not exist | [unknown_project] |
| WI043 | Due date 2026-02-30 | [invalid_due_date] |

`try_cast` returns NULL for malformed supported conversions. We do not accept
that NULL silently: the validation rules record it as a rejection. Quarantine
retains the original strings, including the impossible date.

The notebook additionally checks required fields, allowed priorities/categories,
non-negative effort, date ordering, completion dates, and blocker consistency.
Blank assignees remain valid and become NULL, not a fabricated owner.

Run the outcome-count preview and pre-write assertion. Expect **40 accepted,
3 quarantined, and 1 superseded**. Stop before writes if anything differs.

## 5. Persist the five outputs

After checking the previews, run the five **CREATE TABLE** cells one at a time.
They create new managed Delta tables in `integration_lab.silver`.

- Accepted business columns have DATE, TIMESTAMP, or DECIMAL types where needed.
- Source-file and ingestion metadata are retained; processing timestamps are added.
- Quarantine and superseded tables retain the source-valued business columns.
- No statement modifies Bronze or removes the original CSV files.

The notebook intentionally fails if a persistent target exists. Do not append,
replace, drop, or rerun everything blindly to recover. These are five separate
writes, not one atomic transaction.

Keep Bronze unchanged during this exercise. Temporary views evaluate their
underlying queries when used; this simple fixed-fixture notebook does not
provide snapshot pinning against concurrent source changes.

## 6. Validate what was persisted

Run the remaining SQL cells in order:

1. Count summary: **4 / 8 / 40 / 3 / 1**.
2. Persisted-count/key-uniqueness assertion, including Bronze remaining at 44.
3. Exact quarantine IDs and reasons.
4. WI001 keeps its latest done snapshot with 40 hours.
5. The superseded table contains its older 18-hour snapshot.
6. Type inspection for WI001: DATE, DECIMAL(12,2), and TIMESTAMP.

Successful assertions return NULL. Creation cells may show no result rows;
that is not an empty-table result.

Timestamp display may include fractional seconds and an explicit UTC offset.
`2026-10-22T09:00:00.000+00:00` and `2026-10-22T09:00:00Z` represent the same
instant. A decimal value displayed as `40.00` is the expected result of the
DECIMAL(12,2) conversion, not a change in effort.

## Completion checkpoint

Report the summary, assertion outcomes, and type inspection. Only then mark
Silver verified. Gold metrics and Genie remain untested.
After confirmation, proceed to [Lesson 09: build Gold](09-build-gold.md) as a
single notebook batch.

The reference date for later overdue-work questions remains **2026-10-23**,
not the day the notebook runs. Silver preserves source dates; it does not
recalculate benchmark dates or forecast completion.

## Troubleshooting and cleanup

- A failed preflight means the fixture or source assumptions need investigation.
  Do not suppress the error or loosen rules to match a desired count.
- If a temporary view is missing, recreate session-local setup in order without
  rerunning successful persistent table-creation cells.
- If an output already exists, inspect the specific table before choosing a
  recovery procedure.
- Keep all outputs for the next lesson. Execution and additional storage incur
  costs under the existing lab monitoring arrangement.

This is a transparent batch exercise, not a production change-data-capture,
history, or incremental-upsert implementation.

## Official references

- [try_cast](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/try_cast)
- [row_number and non-unique ordering](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/row_number)
- [filter an array with a lambda](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/filter)
