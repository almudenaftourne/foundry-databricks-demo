# Lesson 08: deploy a model and create the coordinator

[Home](../README.md) | [Previous: Foundry project](07-create-foundry-project.md)

**Goal:** create a Foundry-managed coordinator before connecting its data tool.
This is a prompt agent, not the Python hosted specialist built later.

**Evidence:** a saved coordinator correctly declined to invent data when Genie
was unavailable. The subsequent Genie integration also passed its first
benchmark. See the [capability matrix](capability-matrix.md).

## Prerequisites

- The Foundry project from Lesson 07.
- Foundry User access for the developer and the applicable project-identity
  permissions, following [Foundry RBAC](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry).
- Approved model availability, quota, pricing, and processing geography.

The main path assumes these prerequisites work. For permission banners or
account mismatches, use the [authentication annex](appendix-authentication.md).

## 1. Select or deploy a model

1. Open the existing project in [Foundry](https://ai.azure.com).
2. Under **Models**, inspect existing deployments before creating another.
3. If needed, use the model catalog to deploy a supported chat/tool-calling
   model. The observed lab used **gpt-5.4-mini**, deployment
   `gpt-5.4-mini`, **Global Standard**.
4. Review the current model version, quota, pricing, and deployment type
   before deployment. Availability can change by subscription and region.
5. Record your exact deployment name privately; later configuration must use
   the deployment name, which need not equal the model name.

**Global Standard is not a regional inference guarantee.** If the lab requires
regional processing, choose an approved supported deployment type instead.
Do not purchase provisioned capacity or create extra models just to match
an example name. Rate limits are not spending caps.

## 2. Create the coordinator

1. Open **Build > Agents** and create a prompt agent.
2. Name it `foundry-dbx-coordinator`.
3. Select the model deployment from Step 1.
4. Add these instructions:

   ```text
   You are the coordinator for a synthetic project-delivery integration lab.
   Use the Databricks Genie tool for facts about projects, teams, and work items.
   If that tool is not configured or a call fails, say that you cannot retrieve
   the data; do not invent values or answer from memory.
   The dataset reference date is 2026-10-23.
   Never claim to have queried Databricks unless a tool call actually succeeded.
   ```

5. Save the agent. Leave external tools unconnected for this first check.

## 3. Check the no-data boundary

Start a conversation and ask:

```text
How many open work items are there as of the dataset snapshot?
```

**Expected:** an explicit statement that the data cannot be retrieved because
the Genie tool is unavailable. The agent should not produce a count.
This is an answer-level behavior check, not a security guarantee.

Keep the saved coordinator. Do not publish a user-facing endpoint yet.

## Next

Continue with [Lesson 09: connect Genie](09-connect-genie.md).

## Official references

- [Foundry models and tool support](https://learn.microsoft.com/azure/foundry/agents/concepts/limits-quotas-regions)
- [Foundry roles](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry)
