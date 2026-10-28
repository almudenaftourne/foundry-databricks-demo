# 04. Create the lab catalog

[Previous](03-workspace-and-catalog.md) | [Home](../README.md) |
[Next: schemas and volume](05-schemas-and-raw-volume.md)

**Goal:** create an isolated governed namespace without modifying shared data.
This is a data-builder task; an administrator can prepare it for you.

**Requires:** `CREATE CATALOG`, or an approved catalog already prepared for the lab.
Azure subscription roles do not substitute for Unity Catalog privileges.

1. In **Catalog Explorer**, select **Create catalog**.
2. Name it `integration_lab`.
3. For the new Serverless workspace path, choose **Use default storage**.
4. Optionally add the comment: `Synthetic data for the Foundry and Databricks lab.`
5. Review the settings and create it.

**Expected:** `integration_lab` appears in Catalog Explorer. No data has been
uploaded and no compute is required for this step.

If the catalog already exists, confirm it is the approved lab catalog rather
than replacing it. In a shared environment, an administrator can provide a
different name; apply the [customization instructions](customization.md)
consistently.

If default storage is unavailable, use your administrator's approved managed
storage setup. Do not guess storage paths or create credentials as a shortcut.
Creating a catalog does not grant every user data access.

Keep the catalog for subsequent lessons; deletion is not a harmless reset once
it contains objects.

Reference: [create a catalog with default storage](https://learn.microsoft.com/azure/databricks/storage/default-storage#create-a-new-catalog).
