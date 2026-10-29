# 01. Prepare Databricks

[Home](../README.md) | [Previous](00-prerequisites.md) |
[Next: upload data](02-upload-source-files.md)

**Goal:** a Databricks workspace with Unity Catalog and an empty lab namespace:

```text
integration_lab
  raw.source_files     managed volume for the original CSVs
  bronze               source-preserving tables
  silver               typed, validated tables
  gold                 business-ready views for Genie
```

The tutorial was written using **Sweden Central**; use any approved region that supports the
services below. Documented support is not a quota reservation.

| Service | Check before you start |
| --- | --- |
| Databricks | Unity Catalog, serverless compute, SQL warehouse, Genie, managed MCP |
| Foundry | Agent Service, hosted agents, MCP tools, a tool-calling model, quota |

See the [Databricks regional matrix](https://learn.microsoft.com/azure/databricks/resources/feature-region-support)
and [Foundry regions and quotas](https://learn.microsoft.com/azure/foundry/agents/concepts/limits-quotas-regions).

## 1. Open a workspace

**Reuse** an approved Unity Catalog workspace if you have one; do not change its
shared compute or network settings. Otherwise **create** one:

1. In the [Azure portal](https://portal.azure.com), create an **Azure Databricks** resource.
2. Choose your subscription, resource group, a workspace name, the approved
   region, and workspace type **Serverless**.
3. Review networking, tags, terms, and costs, then **Create**.
4. When deployment finishes, **Launch Workspace**.

## 2. Create the catalog, schemas, and volume

Requires `CREATE CATALOG` (or an administrator-prepared catalog), `CREATE SCHEMA`,
and `CREATE VOLUME`. Azure roles do not substitute for Unity Catalog privileges.

1. In **Catalog Explorer**, select **Create catalog**, name it `integration_lab`,
   and use **default storage**.
2. Open it, create the schemas `raw`, `bronze`, `silver`, and `gold`.
3. In `raw`, select **Create > Volume**, name it `source_files`, and choose **Managed**.

If objects already exist, reuse approved ones; do not replace them. In a shared
environment you can use other names; apply the [customization guide](customization.md)
consistently.

**Expected:** `integration_lab` with four schemas and an empty `raw.source_files`
volume. The upload path is `/Volumes/integration_lab/raw/source_files/`.

Continue with [Lesson 02: upload the data](02-upload-source-files.md).

References: [serverless workspaces](https://learn.microsoft.com/azure/databricks/admin/workspace/serverless-workspaces),
[default storage](https://learn.microsoft.com/azure/databricks/storage/default-storage),
[Unity Catalog volumes](https://learn.microsoft.com/azure/databricks/volumes/utility-commands).
