# 07. Ingest Bronze

[Previous](06-upload-source-files.md) | [Home](../README.md) |
[Next: Silver](08-prepare-silver.md) |
[SQL notebook](../notebooks/01_ingest_bronze.sql)

**Goal:** create source-preserving Delta tables from the uploaded CSVs.

**Requires:** access to approved serverless notebook compute, source `READ VOLUME`,
parent `USE CATALOG` / `USE SCHEMA`, and `CREATE TABLE` on the Bronze schema.
Execution starts chargeable compute; writes use storage.

## Run the notebook

1. In Databricks **Workspace**, open an approved lab folder and select **Import**.
2. Import `notebooks\01_ingest_bronze.sql`. Confirm it opens as a multi-cell
   SQL notebook.
3. Select **Serverless** compute.
4. Run the first SQL preview cell. Expect four teams, T01 through T04.
5. After checking that preview, run the remaining cells in order. Stop at
   an execution error rather than rerunning the whole notebook.

The notebook creates three managed tables in `integration_lab.bronze`.
All business columns remain strings so invalid source dates/statuses stay visible.
`source_file` and `ingested_at` record provenance. This preserves parsed field
values, not byte-for-byte CSV formatting; the original files remain in the volume.

## Check the result

| Check | Expected |
| --- | --- |
| Teams / projects / work-item rows | 4 / 8 / 44 |
| Distinct work-item IDs | 43 |
| WI001 snapshots | 2 |
| Dirty-record inspection | Both WI001 rows plus WI041, WI042, and WI043 |
| Reconciliation and provenance assertions | Both succeed |

`assert_true` returns NULL on success; an execution error is failure.
Successful table creation can show no result rows without meaning the table is empty.

This is a one-time fixture load, not incremental ingestion. `CREATE TABLE`
deliberately fails if a target already exists: inspect partial/existing outputs
before choosing recovery. Do not append, replace, or delete tables blindly.

**Ready when:** all checks pass. Keep the files and Bronze tables for Silver.

References: [notebook import](https://learn.microsoft.com/azure/databricks/notebooks/notebook-export-import),
[read_files](https://learn.microsoft.com/azure/databricks/sql/language-manual/functions/read_files).
