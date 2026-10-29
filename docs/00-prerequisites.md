# 00. Before you start

[Home](../README.md) | [Next: Databricks](01-prepare-databricks.md)

**Goal:** have approved access, a spending owner, and a copy of the tutorial.
You can create dedicated resources or reuse an approved environment.

## Get the source

Install [Git](https://git-scm.com/downloads), then run in PowerShell:

```powershell
git clone https://github.com/almudenaftourne/foundry-databricks-demo.git
Set-Location '.\foundry-databricks-demo'
```

Use the repository files, not a separately downloaded framework sample.
The [customization guide](customization.md) explains what to change.

## Agree who does what

You do not need to be an administrator for every part of the lab.
An authorized administrator can prepare the environment for a normal builder.

| Who | Required preparation |
| --- | --- |
| Environment administrator | Approves regions, previews, networking, costs, and resource creation. Provides Azure deployment access and authorized role assignments where needed. |
| Databricks data builder | Workspace access, approved compute, and privileges to create the lab catalog/schemas/volume/tables/views. An administrator can create the namespace instead. |
| Agent builder | Foundry User for development and Foundry Project Manager for hosted deployment; the documented project/runtime identity permissions also apply. |
| Demo user | Access to the Foundry project, Genie, and the intended Gold data. Foundry Agent Consumer is the least-privilege OAuth consumer role; builders can use their development role. |

Azure resource roles, Databricks workspace roles, and Unity Catalog privileges
are separate. Subscription Owner, Global Administrator, and workspace admin
are **not** ordinary participant requirements. A privileged operator's
successful demo does not establish least-privilege end-user behavior.

## Check the environment

1. Sign in to the [Azure portal](https://portal.azure.com) with your approved
   work identity and select the intended directory/subscription.
2. Confirm who may provision resources and assign required roles.
3. Agree spending approval, cost monitoring, and a cleanup owner.
4. Choose **create dedicated lab resources** or **reuse approved resources**.
   Do not recreate working resources to match an example name.

For Foundry OAuth identity passthrough, the user's Entra tenant must match the
Foundry project's tenant. Normal sign-in and consent are part of the tutorial;
unexpected tenant/account errors belong in the
[authentication annex](appendix-authentication.md).

## Tools and costs

Data preparation uses the Databricks browser UI and SQL notebooks. For hosted
deployment, install [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli),
[Azure Developer CLI and the Foundry extension](https://learn.microsoft.com/azure/foundry/how-to/develop/install-cli-sdk)
before [Lesson 10](10-host-agent-framework.md).
Python package installation and local debugging are not main-path steps.

Compute, storage, inference, and hosted runtime can incur charges. Budget alerts
are not a hard cap; closing a browser does not disable deployed endpoints.
Use only synthetic data and keep populated configuration and consent URLs private.

**Ready when:** the environment and costs are approved, access is available,
and you have the source. Continue with Lesson 01.

References: [Foundry roles](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry),
[OAuth requirements](https://learn.microsoft.com/azure/foundry/agents/how-to/mcp-authentication),
[Unity Catalog setup](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/get-started).
