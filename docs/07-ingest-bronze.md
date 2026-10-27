# Lesson 07: read raw files and create Bronze tables

[Home](../README.md) | [Previous: upload the files](06-upload-source-files.md) |
[SQL notebook](../notebooks/01_ingest_bronze.sql)

**Status:** user-validated on 2026-10-26. The learner confirms the
first preview and Bronze row counts of 4 teams, 8 projects, and 44 work-item
rows. A supplied screenshot confirms both WI001 snapshots and the three
deliberately invalid business records remain in Bronze. The learner confirms
both reconciliation and provenance assertions succeeded and returned NULL.
This is learner-provided execution evidence, not independent workspace access. Notebook import,
serverless compute, and `read_files` documentation reviewed on 2026-10-23.

**Goal:** distinguish files from tables and create a source-preserving Delta
layer. The learner imports the notebook and runs the cells.

## Before starting

- Three source CSV files are uploaded at the paths from Lesson 06.
- `integration_lab.bronze` exists.
- The notebook requires `USE CATALOG`, `USE SCHEMA`, `READ VOLUME` for the source,
  and `CREATE TABLE` for the Bronze schema.
- Executing cells uses chargeable serverless compute and writing tables uses
  storage. This is the first compute execution in the guided walkthrough.

This notebook is a one-time batch load for our fixed fixture, not a production
incremental ingestion pipeline.

## 1. Understand what Bronze preserves

The notebook explicitly reads all CSV business columns as `STRING`. This keeps
an invalid date such as `2026-02-30` visible instead of losing the source value
during a failed conversion. Blank fields may become SQL NULL.

It adds:

| Column | Meaning |
| --- | --- |
| source_file | Databricks-reported source-file path |
| ingested_at | Timestamp when the table-loading query ran |

Bronze preserves parsed source field values, not byte-for-byte CSV formatting.
The original files stay in the volume as source evidence.

Each file is read separately with an explicit schema and checked headers.
Malformed CSV structure fails explicitly. Invalid business values are retained
because we intentionally defer date, status, and relationship validation.

## 2. Import the notebook

1. In Databricks, select **Workspace**.
2. Choose your user folder or an approved lab folder.
3. Right-click the folder and select **Import**. Alternatively, use its
   three-dot menu and select **Import**.
4. Browse to the local repository's `notebooks\01_ingest_bronze.sql`.
5. Import it as a notebook and open it. Its title may omit `.sql`.
6. Confirm it opens as a multi-cell SQL notebook, not a single plain-text file.
   The source header and `COMMAND` separators define the notebook cells.
7. In the notebook's compute selector, choose **Serverless**. Do not create a
   classic cluster or a new SQL warehouse for this exercise.

If import produces a file rather than a notebook, or Serverless is unavailable,
stop and report what the UI shows.

## 3. Run only the first SQL cell

1. Read the opening Markdown cell.
2. Run the first SQL cell only, using its run action or **Shift+Enter**.
3. Do not select **Run all**.

That query reads `teams.csv` from the volume and returns its columns. It creates
no table.

**Expected result:** four rows, T01 through T04:

| team_id | team_name | region | manager_handle | hourly_rate_eur |
| --- | --- | --- | --- | --- |
| T01 | Platform Services | Europe | platform_lead | 80 |
| T02 | Data Services | Europe | data_lead | 100 |
| T03 | Application Services | North America | apps_lead | 90 |
| T04 | Business Operations | Asia Pacific | operations_lead | 70 |

**Stop here for the initial checkpoint.** Confirm the result before continuing
to table creation. This checks file access, parsing, and compute execution
independently from write permissions.

## 4. Create three managed Delta tables

Continue only after the preview result has been checked:

1. Read the notebook's checkpoint explanation.
2. Run the `CREATE TABLE integration_lab.bronze.teams` cell.
3. Run the corresponding projects cell.
4. Run the corresponding work-items cell.

`USING DELTA` specifies the table format. `AS SELECT` writes the query result
into a persistent managed table; it is not just a temporary file preview.

**Expected cell output:** successful `CREATE TABLE` commands may show no result
rows. This does not mean the created table is empty. Confirm that each cell
finished without an error, then use the row-count query in Step 5 to verify the
stored records. Do not rerun the creation cells merely to get a data preview.

The commands deliberately do not use `OR REPLACE`, append, or silently skip
existing tables. If a target exists, stop and inspect it. On a partial failure,
do not rerun every creation cell or drop tables blindly. Record which steps
completed and resolve the specific failure.

The three writes are separate operations, not a single transaction across
all three tables.

## 5. Validate the Bronze result

Run the remaining SQL cells in order:

1. Row-count summary: expected counts are 4, 8, and 44.
2. Reconciliation assertion: also checks 43 distinct work-item IDs and two
   snapshots for WI001.
3. Provenance assertion: every row needs an ingestion timestamp and its expected
   source filename on a non-null file path. Databricks may report a backing
   storage URI rather than the logical `/Volumes/` path.
4. Dirty-record inspection: five rows should remain, including both WI001
   snapshots and WI041/WI042/WI043.

`assert_true` returns NULL when a check passes and raises an error when it
fails. A NULL cell is expected here; a failed execution is not success.

In Catalog Explorer, refresh `integration_lab.bronze` to see the three tables.
Stop before Silver transformations.
After confirming this checkpoint, continue to
[Lesson 08: prepare Silver](08-prepare-silver.md).

## Troubleshooting

- **File not found:** compare the exact volume paths with the uploaded files;
  check for an accidental extra directory.
- **Permission denied:** inspect the privilege relevant to the failing read or
  write. Azure Owner does not replace Unity Catalog privileges.
- **Header/schema mismatch:** compare the uploaded file with the provided CSV;
  do not disable header checking just to make the read succeed.
- **Table already exists:** inspect it before deciding how to recover.
- **Count or provenance assertion fails:** preserve the result and investigate;
  do not change the expected counts to conceal a mismatch.

## Cost and cleanup

Keep the files, notebook, and Bronze tables for the next lesson. Stop active
execution when finished; do not leave experiments running. In a later lesson,
we will make ingestion repeatable without duplicating or overwriting data
blindly.

## Official references

- [Import and export notebooks](https://learn.microsoft.com/azure/databricks/notebooks/notebook-export-import)
- [Serverless compute for notebooks](https://learn.microsoft.com/azure/databricks/compute/serverless/notebooks)
- [read_files SQL function](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/read_files)
