# Lesson 06: upload the synthetic source files

[Home](../README.md) | [Previous: schemas and volume](05-schemas-and-raw-volume.md) |
[Dataset dictionary and expected answers](../data/README.md)

**Status:** local fixture validation passed and the learner confirmed completing
the three-file upload on 2026-10-23. Remote file contents have not yet been
checked by notebook execution. Official upload instructions reviewed on that date.

**Goal:** land original source files in a governed volume, without automatically
creating tables or cleaning the data.

## 1. Locate and inspect the files

The repository contains:

```text
data
  raw
    teams.csv          4 records plus a header
    projects.csv       8 records plus a header
    work_items.csv     44 records plus a header
```

Open each CSV in VS Code before uploading. Notice:

1. The header defines column names.
2. Team/project IDs connect the files; these are not three unrelated tables.
3. Some assignees and completion dates are deliberately empty.
4. WI001 occurs twice, with different update timestamps.
5. The final three work-item rows contain deliberate invalid values.

Do not change or repair these records. Later we will preserve them in Bronze,
deduplicate and quarantine in Silver, and expose accepted business data in Gold.
Read the [dataset contract](../data/README.md) for exact rules and checked answers.

## 2. Open the volume upload UI

1. In Databricks, use **New > Add or upload data**.
2. Select **Upload files to a volume**, not an automatic create-table option.
   Alternatively, Catalog Explorer may offer **Add data > Upload files to a
   volume**.
3. Under **Files**, browse to the local `data\raw` folder.
4. Select only `teams.csv`, `projects.csv`, and `work_items.csv`.
5. Under **Destination volume**, select or enter:

   ```text
   /Volumes/integration_lab/raw/source_files/
   ```

6. Confirm the destination and complete the upload using the displayed action.
   The action's exact label may vary by UI version.

Do not upload the validator, dataset answer key, slide files, or the whole
repository. Those are not source data.

Uploading requires `WRITE VOLUME` on the volume plus `USE CATALOG` and
`USE SCHEMA` on its parents. If access is denied, record the sanitized error
and inspect the relevant privileges rather than granting broad access.

## 3. Check the result

1. In Catalog Explorer, open `integration_lab.raw.source_files`.
2. Confirm that all three CSV files appear at the volume root.
3. Check that none has zero size and no accidental nested upload folder was
   introduced.

Expected paths:

```text
/Volumes/integration_lab/raw/source_files/teams.csv
/Volumes/integration_lab/raw/source_files/projects.csv
/Volumes/integration_lab/raw/source_files/work_items.csv
```

If files with those names already exist, stop and inspect before overwriting.
If the upload fails, resolve the reported problem before retrying; do not assume
that every selected file completed successfully.

The presence of files does not prove their contents match the local source.
The Bronze lesson will read them and validate headers and row counts.

## Checkpoint

Confirm that the three named CSV files are visible at the expected volume path.
Do not create tables or start a notebook yet.
After confirmation, continue to [Lesson 07](07-ingest-bronze.md).

**What you have learned:** file landing and table ingestion are separate steps.
Genie will query curated tables/views, not these raw CSV files directly.

## Cost and cleanup

Upload introduces storage usage. This UI exercise does not require starting
notebook or SQL compute. Keep the original files for reproducible ingestion;
do not delete them after creating tables.

## Official reference

- [Upload files to a Unity Catalog volume](https://learn.microsoft.com/azure/databricks/volumes/volume-files#upload-files-to-a-volume)
