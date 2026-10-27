# Lesson 01: choose a region for the whole lab

[Home](../README.md) | [Learning path](learning-path.md) |
[Capability matrix](capability-matrix.md)

**Status:** official documentation reviewed on 2026-10-23. The learner confirms
Sweden Central is selectable in the Databricks creation form. Deployment,
capacity, model quota, and end-to-end feature availability remain untested.

**Prerequisite:** complete [Lesson 00](00-prerequisites.md).

**Goal:** avoid creating a Databricks workspace in a region that cannot support
the later agent experiments. This lesson does not deploy resources.

## 1. Understand the three different checks

1. **Regional support:** does the product list this feature in this region?
2. **Environment readiness:** do the account settings, permissions, policies,
   quotas, and network configuration allow us to use it?
3. **End-to-end verification:** does an actual authenticated request work?

A documentation check only answers the first question. A successful workspace
deployment does not establish that Genie, OAuth passthrough, or hosted-agent
collaboration works.

## 2. Compare the candidates

Use **Sweden Central** (`swedencentral`) as the proposed primary region.
**West Europe** (`westeurope`) is a documented fallback, not a tested deployment.
Do not silently switch regions if a deployment fails; record the failure and
review any residency or policy implications first.

| Requirement | Sweden Central | West Europe | What still needs checking |
| --- | --- | --- | --- |
| Unity Catalog | Supported; the requirements page says all Databricks regions support it | Supported | Verify the new workspace's catalog setup, storage, and privileges. |
| Serverless notebooks, jobs, and SQL warehouses | Listed | Listed | Workspace/account eligibility, policies, and actual availability. |
| Databricks MCP servers | Listed through Custom Model Serving regional support | Listed through Custom Model Serving regional support | Enable the required Managed MCP Servers preview and verify the endpoint. We do not need to deploy a custom model just because the regional lists align. |
| Curated Genie Agent | Required regional building blocks are listed | Required regional building blocks are listed | Unity Catalog data, pro/serverless SQL warehouse, Databricks SQL entitlement, partner-powered AI settings, and Genie/data permissions. |
| Foundry Agent Service MCP tool | Listed in the tool-by-region matrix | Listed in the tool-by-region matrix | Choose a compatible deployed model and test the native connector. |
| Foundry hosted agents | Listed | Listed | Resource permissions, runtime configuration, session capacity, and deployment. |
| Microsoft Agent Framework and LangGraph | Both frameworks are supported by the hosted-agent platform | Same | Build, deploy, and invoke each independently; framework support is not proof that our application works. |
| Foundry model deployment | Not selected or subscription-verified | Not selected or subscription-verified | Model/version, deployment type, available quota, tool compatibility, and processing geography. |

The reviewed Genie setup and connector pages do not provide a separate
Genie-to-Foundry regional compatibility matrix. The evidence above establishes
documented prerequisites, not a guarantee that every feature combination works.

Plan to colocate the Databricks workspace and new Foundry resources in the
primary region where practical. This is a lab simplification, not a claim that
MCP requires colocation. Resource location alone also does not prove where all
AI processing occurs: review Databricks AI geography settings and the Foundry
model deployment type separately.

## 3. Understand the non-regional gates

Check these at the appropriate setup steps:

- **Databricks AI settings:** Genie requires partner-powered AI features enabled
  at the relevant account and workspace levels. Follow organizational policy;
  do not enable cross-geography processing just to bypass an error.
- **Managed MCP Servers:** the curated Genie MCP documentation requires a
  workspace administrator to enable this preview.
- **OAuth application:** the native Foundry integration requires a custom OAuth
  application registered in the Databricks account. Confirm who can register it.
  Azure subscription Owner is not proof of Databricks account-admin access.
- **Data and compute permissions:** Genie/data access and SQL warehouse access
  are distinct. The chosen warehouse must be pro or serverless.
- **Foundry access and quota:** Azure resource creation, project operations,
  model deployment, and hosted-agent operation have distinct requirements.
- **Network path:** Foundry must reach the Databricks MCP endpoint. IP access
  lists, private endpoints, and organizational network policy can block this
  despite both products supporting the region.
- **Collaboration:** invocation protocols and identity at each agent hop remain
  separate experiments, not something regional support establishes.
- **Optional channels and fleet governance:** Teams/Microsoft 365 publishing and
  Agent 365 features may have tenant, licensing, consent, and administrative
  prerequisites. Do not promise them from this region check.

## 4. Check the creation form without deploying

You perform these actions:

1. Open the [Azure portal](https://portal.azure.com/).
2. Search for **Azure Databricks** and open the Azure Databricks service.
3. Select **Create** to open the workspace creation form. Opening the form is
   not the same as deploying a workspace.
4. Select the approved subscription.
5. Find the **Region** or **Location** dropdown and check whether **Sweden
   Central** is offered.
6. Do not select the final **Create** action or submit a deployment yet. The
   next walkthrough will cover the resource group, workspace type, pricing
   tier, networking, and review screen.

**Expected result:** you can see Sweden Central in the creation form, or you
have a specific policy/availability message to investigate.

**If the region is missing or blocked:** record the sanitized message. We may
consider West Europe after checking policy and availability; do not assume the
same policy permits it.

## Checkpoint

Report one outcome:

- Sweden Central is selectable.
- Sweden Central is missing.
- A policy or other error prevents selection.

This check does not validate model quota, serverless execution, or MCP access.
All of those remain open until their own tests run. Stop here before deployment.

## Cleanup

Cancel or leave the unfinished creation form. No resources should have been
created and no compute should have been started.

## Next decision: workspace type

For this lab, the recommended starting point is a **Serverless** workspace.
The learner has no workspace-type preference; this recommendation is based on
the planned workload, not on a successful deployment.

Our planned Databricks work uses SQL/Python, uploaded files in managed Unity
Catalog volumes, managed Delta tables, curated views, a serverless SQL
warehouse for Genie, and a small serverless job. We do not currently need
classic clusters, RDD APIs, custom cluster images, or cluster-level tuning.
The Microsoft Agent Framework and LangGraph agents run in Foundry, not on
Databricks clusters.

Default storage supports managed tables, managed volumes, file uploads,
notebooks, SQL, and jobs. This removes the need to start by configuring our own
storage account and storage access integration. It does not remove Unity
Catalog governance or the need to learn catalogs, schemas, permissions, tables,
and volumes.

Choose **Hybrid** instead if the learning objective expands to classic compute,
customer-managed infrastructure, or workloads incompatible with serverless.
Hybrid workspaces can also use serverless features when enabled; "Hybrid" does
not mean "no serverless." For this lab, those infrastructure exercises are
optional extensions, not prerequisites.

Important tradeoffs:

- Default-storage assets require serverless compute; classic compute cannot
  access them directly.
- Serverless notebook/job compute has API and configuration restrictions,
  including no Spark RDD APIs. Use supported SQL/DataFrame operations.
- Serverless is not free and is not a spending cap. Compute and storage still
  incur usage charges. Default-storage recovery retention can continue storage
  billing after an object is dropped.
- Genie, MCP preview settings, OAuth, and networking still need separate
  verification. Workspace type does not prove any of these integrations.
- Do not assume conversion to another workspace type is available. Reassess
  the setup if later requirements change.

**Next learner action:** select **Serverless** in the creation form, leaving
Sweden Central selected. Do not submit the deployment; review the remaining
settings in [Lesson 02](02-create-databricks-workspace.md). If Serverless is not
offered, record that fact rather than silently substituting Hybrid.

## Official sources

Reviewed on 2026-10-23. Recheck these before reproducing the lab later.

1. [Unity Catalog requirements: region support](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/requirements#region-support)
2. [Unity Catalog setup overview](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/get-started)
3. [Databricks feature availability: serverless and MCP](https://learn.microsoft.com/azure/databricks/resources/feature-region-support)
4. [Create and manage a Genie Agent: requirements](https://learn.microsoft.com/azure/databricks/genie-agents/set-up)
5. [Genie Agent MCP server](https://learn.microsoft.com/azure/databricks/agents/mcp-tools/genie-agent)
6. [Native Foundry and Databricks Genie integration](https://learn.microsoft.com/azure/databricks/integrations/microsoft-foundry)
7. [Foundry hosted agents: frameworks and regions](https://learn.microsoft.com/azure/foundry/agents/concepts/hosted-agents)
8. [Foundry Agent Service: regional tool support and quotas](https://learn.microsoft.com/azure/foundry/agents/concepts/limits-quotas-regions)
9. [Create a serverless workspace](https://learn.microsoft.com/azure/databricks/admin/workspace/serverless-workspaces)
10. [Default storage: supported tasks and limitations](https://learn.microsoft.com/azure/databricks/storage/default-storage)
11. [Serverless notebook and job limitations](https://learn.microsoft.com/azure/databricks/compute/serverless/limitations)
