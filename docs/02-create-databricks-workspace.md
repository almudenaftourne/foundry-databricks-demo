# Lesson 02: create the Databricks lab workspace

[Home](../README.md) | [Previous: region preflight](01-region-preflight.md) |
[Capability matrix](capability-matrix.md)

**Status:** user-validated on 2026-10-23 through learner confirmations. The learner
reports that review validation passed with matching settings and no unexpected
tier or warnings, deployment succeeded, and the Databricks home page opened.
This is not independent inspection of Azure or verification of data/AI features.
Instructions are based on the official serverless workspace creation guide
reviewed on 2026-10-23.

**Goal:** create an isolated Azure Databricks workspace for the lab and verify
that you can open it. You perform every portal action.

**Current walkthrough checkpoint:** workspace creation and first launch are
complete for this run. Continue to [Lesson 03](03-workspace-and-catalog.md).
New readers should still stop after Step 3 and review their own configuration
before submitting a deployment.

## Prerequisites

- [Lesson 00](00-prerequisites.md) completed: subscription, permissions, spending
  approval, and cost monitoring.
- [Lesson 01](01-region-preflight.md) completed through region selection.
- Sweden Central selected and workspace type set to Serverless.
- Permission under organizational policy to create this lab environment.

Do not change subscriptions, disable policy, or weaken required networking or
encryption to work around an error.

## Step 1: fill in the Basics fields

In the Azure Databricks workspace creation form, use:

| Field | Lab value | Explanation |
| --- | --- | --- |
| Subscription | Your approved subscription | Determines billing and applicable policies. Do not put its ID in the public guide. |
| Resource group | Create a new group: `rg-foundry-dbx-lab-swc` | Groups lab resources for identification and cost review. It is not a Databricks catalog or schema. |
| Workspace name | `dbw-foundry-genie-lab-swc` | The Azure Databricks workspace resource name, not a table namespace. |
| Region / Location | Sweden Central | The region selected in the preflight. |
| Workspace type | Serverless | Uses managed serverless compute and default storage. |

1. Confirm the subscription rather than relying on the portal's last-used value.
2. Beside **Resource group**, choose **Create new**, enter the example group
   name, and confirm it in the dialog.
3. Enter the workspace name.
4. Confirm **Sweden Central** and **Serverless** again after filling the form.

The example names are suggestions, not a requirement to create duplicate
resources. Follow required organizational naming rules. If a name is unavailable,
append a short non-sensitive suffix and record the chosen name privately.

**Expected result:** the required Basics fields are populated with no validation
errors. Entering a new resource-group name in this form is not proof that the
resource group or workspace has been deployed.

**If your form differs:** note the field labels and available choices. In
particular, if a **Pricing tier** field appears, report its selected value before
deployment. Do not select a trial or another tier merely to make the form pass.

## Step 2: review any additional settings

1. Inspect any additional tabs or sections shown by your portal.
2. Leave optional settings unchanged only when the defaults comply with your
   organization's requirements.
3. If tags are required, supply the approved values. A non-sensitive
   `purpose=foundry-dbx-lab` tag can help identify the lab if your policy permits
   it. Do not put credentials or personal information into tags.
4. If customer-managed encryption keys or specific network controls are required,
   stop and follow the approved setup rather than accepting unsuitable defaults.

Serverless does not mean unrestricted networking, free storage, or automatic
approval for AI features. We will inspect the created workspace and its AI,
MCP, data-governance, and access settings in later lessons.

**Expected result:** no unexplained or policy-conflicting settings remain.
If you are unsure about a field, stop and record it for review.

## Step 3: reach the review screen

1. Select **Review + create**.
2. Wait for portal validation to finish.
3. Check the summary against Step 1: subscription, resource group, workspace
   name, Sweden Central, and Serverless.
4. Review any displayed pricing, terms, warnings, and policy messages.
5. Stop here. Do not select the final **Create** button yet.

**Expected result:** portal validation passes and the displayed configuration is
the intended one. Validation passing is not a capacity reservation, a successful
deployment, or verification of Genie or Foundry connectivity.

Report whether validation passed and any unexpected fields, tier, or warnings.
Share only sanitized text; no subscription IDs or account details are needed.

## Step 4: submit the deployment after the review checkpoint

Run this section only after explicitly deciding to deploy the reviewed setup.
Provisioning and later usage are subject to the approved spending arrangement.

1. Select the final **Create** button.
2. Monitor the deployment's **Overview** or portal notifications.
3. Wait for the actual completion result; do not submit a second deployment
   because the first is taking time.
4. If it fails, record the sanitized error code and message. Do not repeatedly
   create replacement resources or delete a resource group to hide the failure.
5. If it succeeds, select **Go to resource**.

**Expected result:** Azure reports a successful deployment and the workspace
resource shows the intended name and region.

## Step 5: open the workspace without running compute

1. On the workspace resource's Overview page, select **Launch Workspace** or the
   equivalent open-workspace action.
2. Sign in with the approved work account if prompted.
3. Confirm that the Databricks workspace UI opens. Do not start a notebook,
   query, sample workload, or job yet.
4. Record any first-use prompts before accepting options that change account
   settings or start compute.

**Expected result:** you can access the Databricks workspace home page.
This does not establish catalog privileges, usable compute, Genie access,
Databricks account-admin privileges, or successful MCP authentication.

## Completion checkpoint

- Azure reports deployment success.
- The workspace is in Sweden Central and uses the selected workspace type.
- The learner can open the Databricks UI.
- Any unexpected settings, warnings, or first-use prompts are documented.

Mark workspace creation verified only after these outcomes are confirmed.
Foundry and Databricks integrations remain untested.

## Cost and cleanup

Do not assume an idle workspace has no associated costs. Default storage and
later workloads have their own billing behavior; use the agreed cost monitoring.

Keep the workspace for subsequent lessons. At the end of the lab, inventory the
specific lab resources and data, check retention and billing implications, and
follow the approved cleanup process. Never delete a whole resource group
without confirming every contained resource is lab-only and explicitly
approving its deletion.

## Official references

- [Create a serverless workspace](https://learn.microsoft.com/azure/databricks/admin/workspace/serverless-workspaces)
- [Default storage and its lifecycle](https://learn.microsoft.com/azure/databricks/storage/default-storage)
