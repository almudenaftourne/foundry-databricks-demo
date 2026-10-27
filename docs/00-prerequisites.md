# Lesson 00: accounts, access, and costs

[Home](../README.md) | [Learning path](learning-path.md) |
[Capability matrix](capability-matrix.md)

**Status:** user-validated on 2026-10-23 through learner confirmations, not
independent inspection of Azure. The learner reports a visible, active
subscription, Owner at subscription scope, and existing spending approval and
cost monitoring. The selected path is a new dedicated Databricks lab workspace.
No workspace deployment has been performed in this walkthrough. Region,
organizational deployment restrictions, and service availability remain to be
checked before resource creation.

**Goal:** identify where you can build the lab and who may approve its costs.
This lesson does not create resources, start compute, or run model requests.

## How to use this guide

You perform the steps yourself. Read the explanation, complete the numbered
actions, and check the expected result. Stop if a checkpoint fails; do not
continue with guessed settings or broader permissions.

The published guide will have two paths:

- **From scratch:** create dedicated lab resources in an approved subscription.
- **Reuse:** use existing resources after checking the same prerequisites.

Using the reuse path does not verify the from-scratch creation instructions.
If we do not execute those instructions, they remain explicitly untested.

## What the terms mean

| Term | Meaning in this lab |
| --- | --- |
| Microsoft Entra tenant | The identity directory containing your user and application identities. |
| Azure subscription | The resource, billing, and policy boundary where Azure resources are deployed. |
| Resource group | A grouping of related Azure resources; not a separate identity directory or billing account. |
| Azure Databricks workspace | The environment where you use notebooks, SQL, jobs, and data tools. |
| Unity Catalog | Databricks governance for data objects, permissions, and related metadata. |
| Compute | Resources that execute notebooks, queries, jobs, or agents and can incur charges. |
| Foundry project | The project context for the models, agents, and connections used later in the lab. |

Azure resource-management permissions and Databricks data permissions are
different. Permission to create a workspace does not establish that every user
can access every table in it.

## Before you begin

- A browser and a work account approved for the intended Azure environment.
- Access to an Azure subscription, or an administrator who can provide the
  required access and provision resources for you.
- An understanding of your organization's rules for previews, networking,
  resource locations, and publishing technical material.

No local Python installation, access token, client secret, or Databricks compute
is needed for this lesson.

## Step 1: identify your Azure subscription

1. Open the [Azure portal](https://portal.azure.com/) and sign in.
2. Check the signed-in account and directory in the account menu. If your
   organization has several directories, use the one approved for this lab.
3. Use the portal search box to open **Subscriptions**.
4. Open the intended subscription and check that it is active.
5. Keep its name and directory in your private notes. Do not put subscription
   IDs or tenant details into the public guide.

**Expected result:** you can identify the intended subscription and directory.

**If it does not work:** an empty list may mean the wrong directory or missing
access. Ask your subscription administrator rather than creating a personal
subscription or changing billing settings to work around organizational policy.

## Step 2: check your resource-management access

1. In the subscription, open **Access control (IAM)**.
2. Look for **View my access** or the **Check access** action for your own user.
   Labels may differ with portal updates.
3. Inspect your role assignments and their scopes. If your organization uses
   time-limited role activation, check its approved activation process.
4. Establish whether you may create the lab resources yourself or must have an
   administrator create them.

**Expected result:** you know who can provision resources and at what scope.
Do not assume a role name at one resource grants access across the subscription.

If the portal shows **Account admin** or **Account Administrator**, do not treat
that label alone as proof of deployment permissions. Check the Azure RBAC role
assignments under the subscription's IAM view. Billing/account administration,
directory administration, and resource-management roles are distinct.

For Databricks workspace creation, the official requirements describe
subscription-level Contributor or Owner access, or a suitable custom role.
Do not request Owner simply to complete this lab; use your organization's
approved least-privilege provisioning process. Databricks administration,
Unity Catalog privileges, and later application registrations require separate
checks in the relevant lessons.

**If it does not work:** record the missing permission and contact the
administrator. Do not change role assignments as part of this lesson.

## Step 3: establish the cost boundary

1. Identify the person or team approving lab spending.
2. Open **Cost Management + Billing**, then the cost-management view for the
   intended subscription or approved scope, if you have access.
3. Inspect existing budgets and alerts. If you cannot view them, ask the cost
   owner how lab usage will be monitored.
4. Agree on a spending expectation and a cleanup owner before resource creation.
5. Note the types of usage we will introduce later: Databricks compute and
   storage, model inference, hosted-agent runtime, and monitoring. Other costs
   depend on the architecture selected.

**Expected result:** you know who approves spending, how usage will be monitored,
and who stops or removes lab-only resources.

**Important:** Azure budget alerts are not a hard spending cap. Do not start a
warehouse, notebook compute, job, or hosted agent merely to check that it exists.
Exact prices and supported configurations will be checked before provisioning.

## Step 4: choose your setup path

1. Decide whether this run will create a dedicated lab workspace or reuse an
   approved existing workspace.
2. For a new workspace, confirm that resource creation and its costs are
   approved. Do not choose a region or pricing tier yet; we will check feature
   availability and organizational constraints first.
3. For reuse, confirm that experiments may be run there and that a separate
   lab namespace can be used without changing existing data or policies.
4. Keep the workspace details private. Never share tokens, passwords, client
   secrets, authorization headers, or unredacted consent links.

**Expected result:** the setup path is explicit. The manual will retain a
from-scratch path even if your personal run uses existing resources.

## Checkpoint: stop here

Report only these non-sensitive outcomes:

- Intended subscription visible: yes/no.
- Resource creation: self-service / administrator-assisted / not yet known.
- Spending approval and monitoring: agreed / pending.
- Setup path: create dedicated lab resources / reuse approved resources.

Do not mark this lesson complete until those outcomes have been checked.
An unresolved permission or cost prerequisite is a blocker, not a reason to
silently skip the step.

## Cleanup

None: this lesson only inspects access and settings. If you started compute or
created a resource outside these instructions, identify that specific resource
and follow its approved shutdown or cleanup procedure.

## Official references

Documentation consulted on 2026-10-23. Product requirements and portal labels can
change; source review is not evidence that this walkthrough has been executed.

- [Create an Azure Databricks workspace](https://learn.microsoft.com/azure/databricks/admin/workspace/)
- [Get started with Unity Catalog](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/get-started)
- [Azure Databricks pricing](https://azure.microsoft.com/pricing/details/databricks/)
- [Azure Cost Management budgets](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
