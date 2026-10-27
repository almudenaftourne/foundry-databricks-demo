# Lesson 03: understand the workspace and data hierarchy

[Home](../README.md) | [Previous: create the workspace](02-create-databricks-workspace.md)

**Status:** sample browsing user-confirmed on 2026-10-23. The learner reports
seeing tables under the `samples` catalog. This confirms Catalog Explorer
access, not privileges to create catalogs or schemas.

**Goal:** distinguish development assets, governed data, and execution resources.
Inspect metadata only; do not run compute or create data objects yet.

## 1. Learn the map

| Area or object | Purpose | Example in our lab |
| --- | --- | --- |
| Workspace resource | The Azure resource you deployed and the Databricks environment it opens | The new Serverless workspace in Sweden Central |
| Workspace browser | Organizes development assets such as notebooks and folders | A notebook we will write to ingest raw files |
| Catalog Explorer | Browses governed data and related objects | Catalogs, schemas, tables, views, and volumes |
| Compute | Executes workloads | Serverless notebook/job compute and a SQL warehouse |
| Genie Agent | Natural-language analytics over selected governed datasets | A curated agent over our future Gold views |

A notebook is code, not a table. A table is a governed data object, not a
compute resource. A SQL warehouse executes SQL; it is not the storage location
for your tables. Serverless manages infrastructure, but it does not remove
these distinctions.

## 2. Understand Unity Catalog names

The simplified data hierarchy is:

```text
Unity Catalog metastore
  catalog
    schema
      tables
      views
      volumes
```

- A **metastore** is the top-level container for Unity Catalog metadata. It can
  serve multiple workspaces in its region; a new workspace is not necessarily
  a new metastore.
- A **catalog** is the first level of the table namespace.
- A **schema** groups objects within a catalog.
- A **table** contains structured data. Our managed tables will use Delta.
- A **view** defines a saved query; an ordinary view does not store a separate
  materialized result.
- A **volume** governs access to files, such as the raw CSV/JSON files we will
  upload.

The following is an illustrative table name, not an object created by this
lesson:

```text
integration_lab.bronze.work_items
^^^^^^^^^^^^^^^ ^^^^^^ ^^^^^^^^^^
catalog         schema table
```

We will create an approved lab namespace later. Do not rename or remove
pre-existing catalogs or schemas.

## 3. Inspect Catalog Explorer

1. In your Databricks workspace, select **Catalog** in the sidebar. If navigation
   differs, look for **Catalog Explorer** or a catalog/data entry in the menu.
2. Inspect the list of catalogs available to your identity.
3. If possible, expand one catalog, then one schema. Inspect the object categories
   without running a query, opening a data preview that starts compute, or
   changing permissions.
4. Check whether catalogs other than `hive_metastore` are visible.

**Expected result:** you can recognize the catalog/schema hierarchy and tell
whether non-legacy catalogs are available to your identity.

`hive_metastore`, if present, is the legacy namespace; it is not the namespace
we intend to use for this Unity Catalog lab. Catalog Explorer's presence alone
does not prove the required catalog privileges exist. Likewise, an empty or
restricted list does not by itself prove Unity Catalog is disabled.

## Checkpoint

Report one of:

- Catalogs other than `hive_metastore` are visible.
- Only `hive_metastore` is visible, or the list is empty.
- Catalog Explorer is unavailable or access is denied.

Do not share personal catalog names or screenshots containing account details.
We will use the outcome to decide the next permission and namespace checks.
For this run, continue to [Lesson 04: create the lab catalog](04-create-lab-catalog.md).

## Troubleshooting

If the list is empty, restricted, or unexpected, do not create a metastore or
grant broad permissions as a workaround. First check the workspace's Unity
Catalog setup and your privileges with the appropriate administrator.

## Cleanup

None. This lesson only inspects metadata and does not create objects.

## Official references

- [Unity Catalog overview](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/)
- [Get started with Unity Catalog](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/get-started)
