# 02. Create or reuse a Databricks workspace

[Previous](01-region-preflight.md) | [Home](../README.md) |
[Next: workspace tour](03-workspace-and-catalog.md)

**Goal:** open an approved workspace with Unity Catalog and the required features.
Resource creation is an administrator/provisioner task, not a requirement for
every person consuming the demo.

## Reuse an existing workspace

Confirm it meets [the region and feature checks](01-region-preflight.md), you
may run the lab there, and an isolated lab namespace is available. Then open
it and continue to Lesson 03. Do not change shared compute or network settings.

## Create a dedicated workspace

1. In the [Azure portal](https://portal.azure.com), find **Azure Databricks**
   and select **Create**.
2. Review these settings:

   | Field | Example |
   | --- | --- |
   | Subscription | Your approved subscription |
   | Resource group | `rg-foundry-dbx-lab` |
   | Workspace name | `dbw-foundry-dbx-lab` |
   | Region | The approved region from Lesson 01 |
   | Workspace type | Serverless |

3. Review networking, encryption, required tags, terms, and costs. Accept defaults
   only when they meet organizational requirements.
4. Select **Review + create**, inspect the complete summary, then **Create**
   when approved.
5. Wait for successful deployment. Open the resource and **Launch Workspace**.
6. Confirm the intended user can open the Databricks UI.

Example names can be changed to meet naming rules. If the required workspace
type or settings are unavailable, review the supported environment with the
administrator rather than silently switching architecture.

**Expected:** the workspace opens. This does not yet verify data access,
compute execution, or Genie connectivity.

Keep the workspace for later lessons. Do not delete a resource group as a reset:
it can contain shared resources. Monitor storage and compute costs throughout.

References: [create a serverless workspace](https://learn.microsoft.com/azure/databricks/admin/workspace/serverless-workspaces),
[workspace requirements](https://learn.microsoft.com/azure/databricks/admin/workspace/).
