# Lesson 04: create a catalog for the lab

[Home](../README.md) | [Previous: workspace and catalog tour](03-workspace-and-catalog.md)

**Status:** catalog existence is confirmed by a learner-provided screenshot on
2026-10-23. The learner selected `integration_lab` as the catalog for the lab;
this supersedes the earlier naming discussion. The storage selection has not
been separately confirmed. Official default-storage instructions reviewed on
2026-10-23. No personal identifiers from the screenshot are reproduced here.

**Goal:** create a separate Unity Catalog namespace for our data, leaving
Databricks samples and other existing catalogs unchanged.

## What this creates

Create one catalog named `integration_lab`, using default storage in our
Serverless workspace.

A catalog is a governed namespace, not a compute cluster or a copy of the sample
data. We will create schemas inside it in the next lesson, then a managed volume
for raw files, and eventually tables and views.

Creating the catalog does not grant every user access to it. Permission testing
and deliberate sharing come later.

## Prerequisites

- The new Serverless workspace opens successfully.
- Catalog Explorer is accessible. Seeing `samples` confirms sample browsing,
  not permission to create another catalog.
- Your Databricks identity has the Unity Catalog `CREATE CATALOG` privilege.
  The creation attempt will test this; Azure subscription Owner is not proof
  of that data-governance privilege.

No notebook, SQL query, or compute startup is required for this UI exercise.

## Step 1: open the catalog creation dialog

1. Select **Catalog** in the Databricks sidebar.
2. Find **Create catalog** in Catalog Explorer. In some UI versions it may be
   inside a **Create** menu.
3. Open the catalog creation dialog, not a create-table or file-upload dialog.

**Expected result:** a dialog asking for a catalog name and storage settings.

If the action is absent or disabled, stop and record that outcome. Do not
create a new workspace or metastore as a workaround.

## Step 2: select the name and managed storage

1. Enter `integration_lab` as the catalog name.
2. Choose **Use default storage**.
3. If an optional comment is available, use:

   ```text
   Synthetic data for the Foundry and Azure Databricks integration lab.
   ```

4. Do not supply an external storage path, create a storage credential, or
   broaden permissions for this exercise.
5. Check the name and storage selection, then select **Create**.

**Expected result:** the catalog is created and becomes visible in Catalog
Explorer. No data has been uploaded or queried by this step.

If `integration_lab` already exists, do not assume it belongs to this exercise
and do not overwrite or delete it. Inspect its ownership/context or choose an
approved unique lab name. Keep the chosen name consistent in later steps.

If the default-storage option is absent, or the form requires an external
storage location, stop and report the fields shown. Do not guess a storage
path or silently substitute a different storage architecture.

## Step 3: inspect the result

1. Refresh Catalog Explorer if necessary.
2. Open the new catalog and inspect its overview.
3. If storage and ownership information is shown, check that it matches the
   creation choice. Do not publish owner identifiers.
4. Do not run data previews, create schemas, or change grants yet.

There may be automatically created schemas or metadata objects. Their presence
does not mean our source files or lab tables have been loaded.

## Checkpoint

Report one outcome:

- `integration_lab` was created with default storage and is visible.
- The name already exists.
- Create catalog is missing or disabled.
- Creation failed, or the storage options differ.

For a failure, share only the sanitized error code/message. A permissions error
means an administrator must review the relevant Unity Catalog privileges; it
does not mean the region or the product lacks catalog support.

Do not mark this lesson complete until the newly created catalog is confirmed.
For this run, the catalog is visible; proceed to
[Lesson 05](05-schemas-and-raw-volume.md) without recreating it.

## Cost and cleanup

This exercise does not start compute or upload data. Subsequent storage and
compute usage remain subject to the agreed monitoring.

Keep the catalog for the following lessons. Do not delete samples or any
pre-existing catalogs. Catalog deletion is not a harmless reset once schemas,
tables, or volumes exist; cleanup must explicitly review the lab objects first.

## Official reference

- [Create a new catalog with default storage](https://learn.microsoft.com/azure/databricks/storage/default-storage#create-a-new-catalog)
