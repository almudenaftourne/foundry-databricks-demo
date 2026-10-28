# 05. Create schemas and a landing volume

[Previous](04-create-lab-catalog.md) | [Home](../README.md) |
[Next: upload data](06-upload-source-files.md)

**Goal:** organize the pipeline and create a governed location for raw files.

```text
integration_lab
  raw.source_files     managed volume containing the original CSVs
  bronze               source-preserving tables
  silver               typed, validated tables and audit outputs
  gold                 business-ready views for Genie
```

**Requires:** `USE CATALOG` and `CREATE SCHEMA` on the catalog to create schemas;
`USE CATALOG`, `USE SCHEMA`, and `CREATE VOLUME` to create the volume. An
authorized administrator can prepare these objects instead.

## Create the objects

1. In **Catalog Explorer**, open `integration_lab`.
2. Select **Create schema**, enter `raw`, and leave custom storage unspecified.
3. Repeat for `bronze`, `silver`, and `gold`.
4. Open `raw`, select **Create > Volume**, and name it `source_files`.
5. Choose **Managed**, review the parent `integration_lab.raw`, and create it.
6. Open the volume and check that it is empty for a new lab run.

Reuse approved existing lab objects; do not replace them or remove `default`
and system schemas.

The upload destination is:

```text
/Volumes/integration_lab/raw/source_files/
```

This is a Databricks path, not a local Windows directory. A volume stores files;
uploading a CSV does not automatically create a table.

**Expected:** four schemas and the managed landing volume exist. No compute
execution is required. Keep them for the next lesson.

Reference: [Unity Catalog volumes](https://learn.microsoft.com/azure/databricks/volumes/utility-commands).
