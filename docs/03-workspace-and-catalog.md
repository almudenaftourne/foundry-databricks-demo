# 03. Find your way around Databricks

[Previous](02-create-databricks-workspace.md) | [Home](../README.md) |
[Next: catalog](04-create-lab-catalog.md)

**Goal:** distinguish code, governed data, and compute.

| Object | Purpose |
| --- | --- |
| Workspace browser | Organizes notebooks and other development assets |
| Catalog Explorer | Browses governed catalogs, schemas, tables, views, and volumes |
| Notebook | Code you run; it is not a table |
| SQL warehouse / notebook compute | Executes queries; it is not where table names are registered |
| Genie Agent | Natural-language analytics over selected governed data |

The Unity Catalog hierarchy is:

```text
metastore
  catalog: integration_lab
    schema: bronze
      table: work_items
```

A **volume** governs files; a **table** exposes structured rows; a **view**
defines a saved query. Serverless manages infrastructure, not these distinctions.

1. Open **Catalog** / **Catalog Explorer** in the workspace.
2. Expand an available catalog and schema.
3. Locate the categories for tables, views, and volumes.

Browsing `samples` does not prove you may create a catalog. An empty list does
not by itself prove Unity Catalog is disabled. `hive_metastore`, if present,
is the legacy namespace and is not the target for this tutorial.

**Expected:** you can identify the hierarchy. Do not alter existing objects.
If access is missing, have the environment administrator check the setup.

Reference: [Unity Catalog overview](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/).
