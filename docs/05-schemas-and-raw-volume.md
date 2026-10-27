# Lesson 05: schemas and the raw-file volume

[Home](../README.md) | [Previous: create the catalog](04-create-lab-catalog.md)

**Status:** a learner-provided screenshot confirms that `raw`, `bronze`,
`silver`, and `gold` exist in `integration_lab` on 2026-10-23. The schema
creation dialog was not independently observed. The learner also confirms
creating the managed `integration_lab.raw.source_files` volume and that it is
empty. Volume creation is user-validated, not independently inspected.
Official volume instructions reviewed on 2026-10-23.

**Goal:** organize the pipeline and create a governed landing place for files.
Use Catalog Explorer; no notebook or query execution is needed.

## 1. Understand the planned structure

```text
integration_lab
  raw
    source_files       managed volume: original CSV/JSON files
  bronze               tables preserving ingested source records
  silver               cleaned, validated tables
  gold                 business-ready tables and views for Genie
```

Only the catalog and schemas have been confirmed so far. The volume and tables
in this diagram are targets, not evidence of existing objects.

The schemas organize data by processing stage. A schema named `bronze` does not
automatically ingest anything or enforce data quality. We will write those
transformations explicitly.

A volume holds files. A table exposes structured rows and columns. Putting a
CSV into a volume does not automatically create a table or make it available
to Genie.

## 2. Create the schemas if starting from scratch

For this run, skip creation: the screenshot already confirms the four schemas.
For a new walkthrough:

1. Open **Catalog** and select the `integration_lab` catalog.
2. Select **Create schema**.
3. Enter `raw`, leave any optional custom storage location unspecified so the
   catalog's managed storage is inherited, and create the schema.
4. Repeat for `bronze`, `silver`, and `gold`.
5. Confirm all four names in the catalog's schema list.

If the form requires a location or access is denied, stop and inspect the
configuration instead of guessing a storage path or granting broad access.

Leave any existing `default` and system `information_schema` schemas untouched.
They are not the pipeline stages we are creating.

## 3. Create a managed volume in raw

Creating a volume requires `USE CATALOG` on the catalog and `USE SCHEMA` plus
`CREATE VOLUME` on the schema. Azure subscription Owner is not proof of these
Databricks privileges.

1. In Catalog Explorer, open **integration_lab**, then **raw**.
2. Select **Create > Volume**. Depending on the UI, the action may be labeled
   **Create volume**.
3. Enter `source_files` as the volume name.
4. Choose **Managed**, not **External**.
5. Do not enter an external storage path or configure a storage credential.
6. Check that the parent is `integration_lab.raw`, then select **Create**.

Managed volumes use the containing schema's managed storage. With the intended
default-storage setup, Databricks manages that storage. Creating a managed
volume alone does not independently verify which backing storage the catalog
uses; inspect the catalog's storage details separately if they are unclear.

**Expected result:** `source_files` appears as a volume under
`integration_lab.raw`. Open it and confirm it contains no uploaded lab files.

If the name already exists, inspect the object instead of replacing it. If
creation is blocked or only external storage is offered, record the sanitized
error or field labels and stop.

## 4. Understand the volume path

The expected Databricks file path is:

```text
/Volumes/integration_lab/raw/source_files/
```

The components after `/Volumes/` are the catalog, schema, and volume name.
This is a Databricks path, not a Windows folder, cloud storage URL, or SQL table
name. Do not try to open it directly in local Windows File Explorer.

Later we will upload synthetic source files into this volume and read them
from a notebook. Do not upload private or customer data.

## Checkpoint

- All four pipeline schemas exist in `integration_lab`.
- `integration_lab.raw.source_files` exists and is a managed volume.
- The volume contains no uploaded lab files yet.

Report the result before uploading anything. This validates the landing
structure, not ingestion, transformations, or Genie.

## Cost and cleanup

This metadata exercise does not require starting compute. Files uploaded later
will incur storage usage. Keep the schemas and volume for the next lesson.
Dropping a managed volume affects its contained files; do not use deletion as
a routine troubleshooting step.

## Official references

- [Create and manage Unity Catalog volumes](https://learn.microsoft.com/azure/databricks/volumes/utility-commands)
- [Default storage](https://learn.microsoft.com/azure/databricks/storage/default-storage)
