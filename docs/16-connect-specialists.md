# 16. Connect the coordinator to both hosted specialists

[Home](../README.md) | [Agent Framework](14-host-agent-framework.md) |
[LangGraph](15-host-langgraph.md) | [Video runbook](demo-video.md)

**Goal:** one coordinator request retrieves Genie evidence, delegates to both
cloud-hosted specialists, and returns a delivery brief and proposed checklist.

This uses a native **Foundry Toolbox** containing an **OpenAPI tool** for the
hosted **Responses endpoints**. The coordinator consumes its MCP endpoint.
The toolbox is managed tool configuration, not a fourth agent or custom proxy.
No A2A support or locally running application is required.
Three fresh Toolbox-backed remote reviews have passed in the lab, including
the intended-user Foundry playground. Repeat the checks with your own setup.

## Before you start

- Both specialists are active and pass their standalone smoke tests.
- The coordinator can retrieve Genie facts using the intended demo user's
  normal sign-in, consent, and tool approvals.
- A builder has the required project-connection/agent configuration permissions.
- An authorized administrator can prepare the project identity's target access.
  Do not grant the demo user subscription-wide or workspace-admin access for this step.
- Review inference and hosted-compute costs.

## 1. Prepare invocation access once

In the Azure resource details for the **Foundry project**, identify its
system-assigned managed identity. This is not the parent Foundry account's
identity and not the deployer's user account.

Have an authorized administrator assign **Foundry Agent Consumer** to that
identity, scoped to this existing Foundry project. This role permits agent
invocation; it does not grant Databricks access or role administration.
Allow normal role propagation before testing.

This is a setup prerequisite, not a workaround for an authentication incident.
The Genie connection continues using its own configured authentication.
Do not claim that the project identity is the end user's identity.

## 2. Create the specialist toolbox

In the project menu, choose **Build**, then **Tools > Toolboxes > Create toolbox**.
Name it **`delivery-specialists`** and describe its read-only analyst/planner role.
Under **Included**, choose **Add > Add tool > Custom > OpenAPI tool > Create**:

1. Use tool name **`delivery_specialists`** and a description explaining the
   delivery analyst and action planner.
2. Copy the [OpenAPI template](../agents/coordinator/specialists.openapi.json).
   Replace only its example server URL with your existing **project endpoint**,
   such as `https://<account>.services.ai.azure.com/api/projects/<project>`.
3. Keep the two specialist names in the paths aligned with their deployed
   manifest `name` values. Keep `api-version=v1` and `stream=false`.
4. Choose **Managed identity** and create an OpenAPI project connection:
   - Connection name: for example, `delivery-specialists`.
   - Target URL: the same project endpoint used in the OpenAPI server.
   - Audience: **`https://ai.azure.com`**, not the project URL.
5. Create the OpenAPI tool, review the toolbox's included tool, and create the
   toolbox. Its first version becomes the default automatically. For later
   versions, test and explicitly select/promote the intended default.

One OpenAPI tool exposes two operations, invoking two separate hosted agents.
In this toolbox their MCP names are **`delivery_specialists___analyze_delivery`**
and **`delivery_specialists___plan_actions`** (three underscores before the operation).
Do not insert API keys, bearer tokens, or populated private configuration into the template.

For programmatic setup, the connection properties are `category: "OpenAPI"`,
`authType: "ProjectManagedIdentity"`, `target`, and `audience`.
Use its full ARM connection resource ID in the tool's
`auth.security_scheme.project_connection_id`, with `auth.type: "project_connection"`.
Use SDK **`OpenApiToolboxTool`**, not the direct-agent `OpenApiTool`, with
`project.toolboxes.create_version`. The lab used `default_params: ["api-version"]`.
See the [official OpenAPI guide](https://learn.microsoft.com/azure/foundry/agents/how-to/tools/openapi)
and [toolbox guide](https://learn.microsoft.com/azure/foundry/agents/how-to/tools/toolbox)
for complete connection and SDK examples.

## 3. Connect the coordinator to the toolbox

Open the toolbox and copy **Call this toolbox > Endpoint**. Its consumer URL is:

```text
<your-project-endpoint>/toolboxes/delivery-specialists/mcp?api-version=v1
```

In the coordinator's **Setup > Tools > Add > Add tools > Custom**, choose
**Model Context Protocol (MCP) > Create**. Complete the form:

- **Name:** `delivery_specialists`.
- **Remote MCP Server endpoint:** the copied toolbox MCP endpoint, not a
  hosted agent's Responses endpoint.
- **Authentication:** **Microsoft Entra**.
- **Type:** **Project Managed Identity**, not the default **Agent Identity**.
- **Audience:** **`https://ai.azure.com`**.

Choose **Connect**, review the tool, and save the coordinator configuration.
Keep normal tool approvals; do not select "always approve all" for the recording.

Keep the existing Genie tool and its authentication unchanged.
For SDK setup, this is `MCPTool` with `server_label`, `server_url`,
`project_connection_id`, and `require_approval: "always"`. Its project connection
uses `category: "RemoteTool"` and `authType: "ProjectManagedIdentity"`.

## 4. Apply the coordinator instructions

Replace the initial coordinator instructions with the
[workflow instructions](../agents/coordinator/instructions.txt), then save
a new agent version. Keep the existing deployed model and Genie connection.
Under **Setup > Parameters**, use **medium reasoning effort** for the lab's
reasoning-model baseline. Allow **16,000 max output tokens** for rehearsals:
this budget includes reasoning and tool-call arguments, not just the short
visible answer. If you customize to a model without reasoning settings,
omit unsupported settings and verify its tool behavior separately.

The instructions require fresh, self-contained Genie queries, actual returned
IDs for polling, all four headline counts, and positive overruns rather than
all nonzero budget variances. Specialists receive evidence, never credentials.

Source changes alone do not update a saved Foundry prompt agent.

## 5. Rehearse one real conversation

Start a new coordinator playground conversation and use the
[main recording question](demo-video.md#main-question).
Approve the requested read-only Genie and specialist calls under your normal policy.

Check actual activity, not just the final prose:

- Genie queries complete; if pending, polling uses IDs returned by that query.
- Both `delivery_specialists___analyze_delivery` and
  `delivery_specialists___plan_actions` complete through the toolbox.
- The downstream results identify the actual hosted agents/versions.
- The brief matches the fixture: **21 open, 9 overdue, 7 blocked, 7 unassigned**,
  with **42.9%** overdue. The dataset has **8 projects**, **7** needing attention.
- P001/P003/P005 have positive modeled effort-budget variance. Healthy P008
  must not enter the action checklist only because it is below budget.
- Project owners are recorded handles and next steps are clearly proposed.

Complete the [recording-readiness checks](demo-video.md#recording-readiness-checks)
before calling the video ready. A successful response is not proof of least
privilege, distributed tracing, or end-to-end user identity propagation.
