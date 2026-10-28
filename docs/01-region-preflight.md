# 01. Choose a supported region

[Previous](00-prerequisites.md) | [Home](../README.md) |
[Next: workspace](02-create-databricks-workspace.md)

**Goal:** check the requirements for the whole demo before provisioning.
The lab used **Sweden Central**; it is an example, not a requirement for every reader.

## Check current availability

| Service | Check |
| --- | --- |
| Databricks | Unity Catalog, default storage/serverless compute, SQL warehouse, Genie, and managed MCP availability |
| Foundry | Agent Service, hosted agents, MCP tools, a supported tool-calling model, and subscription quota |
| Organization | Approved previews, AI processing geography, networking, and spending |

Use the current [Databricks regional matrix](https://learn.microsoft.com/azure/databricks/resources/feature-region-support)
and [Foundry regional/model guidance](https://learn.microsoft.com/azure/foundry/agents/concepts/limits-quotas-regions).
Documented support is not a quota reservation or proof of a working integration.

## Choose the lab layout

1. Select an approved region supporting the required services. Use Sweden
   Central only if it meets your current requirements.
2. Prefer nearby/co-located resources for a simple lab. Matching locations
   is not a Genie connector requirement or an inference-residency guarantee.
3. Check model deployment type and Databricks AI geography settings separately.
4. For a new Databricks workspace, prefer **Serverless** with default storage.
   This fixture does not need classic clusters or custom storage integration.

A suitable existing Unity Catalog workspace can also be reused. Hybrid workspaces
can support serverless features; do not migrate or replace one merely for this lab.
Default-storage data requires supported serverless compute.

## One-time administrator preparation

Confirm approved Genie AI settings, the managed MCP preview if required, and
the network path from Foundry to Databricks. An ordinary builder should not
be told to bypass policy or grant themselves administrative roles.

The connection lesson uses **Managed OAuth when offered**. Microsoft's
Databricks integration guide also documents **Custom OAuth**, which requires
an authorized account administrator to register an application. These are
alternative setup paths, not a universal requirement to register your own app.
See [Lesson 13](13-connect-genie.md).

**Ready when:** an approved region, workspace approach, model availability,
and access prerequisites are established. Resource creation is the next step.

References: [serverless workspaces](https://learn.microsoft.com/azure/databricks/admin/workspace/serverless-workspaces),
[default storage](https://learn.microsoft.com/azure/databricks/storage/default-storage),
[hosted agents](https://learn.microsoft.com/azure/foundry/agents/concepts/hosted-agents).
