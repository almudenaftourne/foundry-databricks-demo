# Lesson 07: prepare a Foundry project

[Home](../README.md) | [Previous: native Genie](06-create-genie.md)

**Goal:** open a dedicated project before adding the coordinator.

## Understand the objects

- **Resource group:** groups Azure resources for management and cost tracking.
- **Foundry resource:** the Azure parent resource hosting Foundry capability.
- **Foundry project:** the working scope for agents, connections, and evaluations.
- **Model deployment:** the callable model used by an agent. Project creation
  alone does not establish model availability or quota.

Use the current Foundry project type for this path, not a classic hub-based
project. Reuse an approved existing project if appropriate; do not create a
duplicate simply because the portal or VS Code has not selected it.

## 1. Review access, region, and costs

Sign in with the intended organizational identity and select the approved
subscription and directory. Follow [Lesson 00](00-prerequisites.md) for access
requirements and [Lesson 01](01-prepare-databricks.md) for regional checks.

The tutorial was written using Sweden Central. Check current availability of
Agent Service and hosted agents in your region, your subscription quota, and
your chosen models.
Co-locating with Databricks is optional: it is not a Genie connector
requirement or an inference-residency guarantee. Model deployment
type also affects processing geography.

Review network access, identity, storage, additional resources, and charges
before deployment.
Do not put Foundry resources in a Databricks-managed resource group.

## 2. Create the resource and project, if needed

1. In the [Azure portal](https://portal.azure.com), choose **Create a resource**.
2. Find the Microsoft-published **Microsoft Foundry** service and select
   **Create**, not an Azure OpenAI-only resource or classic hub.
3. Review subscription, lab resource group, location, and unique resource name.
4. If the wizard offers a first project, give it a distinct, meaningful name.
5. Review the complete configuration and costs, then create the approved
   resource/project.

The [Foundry portal](https://ai.azure.com) also offers a project wizard that can
create the parent resource. This is an alternative, not a second required
creation route. After either route, inspect what already exists.

Example names such as `foundry-dbx-lab` and `foundry-dbx-lab-project` are
illustrative.
Resource creation can incur charges.

## 3. Open and verify the project

1. From the completed deployment, open the resource and check its name/location.
2. Launch [Foundry](https://ai.azure.com) with the intended account.
3. Use the project picker to select the project under the correct parent.
4. Confirm the project opens and record its project endpoint privately.
5. Inspect existing model deployments before creating another one.

If a project is missing from a picker, verify account, directory, subscription,
and permissions first. A VS Code "no selected project" message does not prove
that Azure has no projects. Use the
[authentication annex](appendix-authentication.md) for exceptional failures.

**Checkpoint:** the intended project opens. Model access, actual tool calls,
and hosted-agent execution each have their own later checks.

Next: [create the coordinator and choose its model](08-create-coordinator.md).

## Official references

- [Create a Foundry project](https://learn.microsoft.com/azure/foundry/how-to/create-projects)
- [Agent Service regions and limits](https://learn.microsoft.com/azure/foundry/agents/concepts/limits-quotas-regions)
