# Lesson 13: connect Foundry to curated Databricks Genie

[Home](../README.md) | [Previous: coordinator](12-create-coordinator.md)

**Goal:** have the coordinator retrieve a real benchmark answer through the
curated Genie MCP tool.

**Verified baseline:** Managed OAuth, tool discovery, a successful Genie
polling call, generated Gold SQL with statement state `SUCCEEDED`, and
**21 open / 9 overdue** for **2026-10-23** were observed in the lab.
This is response-level evidence, not distributed tracing or proof of the
effective principal at every service hop.

## Prerequisites

- The saved coordinator and a supported model deployment.
- The curated Genie from Lesson 10 and a successful native Genie baseline.
- An approved organizational identity with access to the intended Foundry
  project, Databricks workspace, Genie, and Gold data.
- Preview use, data processing, and transfer to the agent approved for the lab.

Use the same intended lab identity consistently during setup and consent.
This main path assumes normal access and sign-in work. If they do not,
use the [authentication annex](appendix-authentication.md); do not broaden
permissions, create replacement tenants, or copy another person's credentials.

## 1. Enable the documented MCP prerequisite

As an authorized workspace administrator:

1. In Databricks, open profile/settings **Previews**.
2. Enable **Managed MCP Servers**, if required and not already enabled.
3. Accept preview terms only under your organization's approved policy.

UI labels and preview requirements may change. The native connector was
Public Preview when this lab was tested.

## 2. Identify the curated endpoint

1. Open the existing Genie, not workspace-wide Genie One.
2. Open **Configure > About > About this agent > Agent ID**.
   Documentation may call this the **Genie space ID**.
3. Copy the workspace hostname from its URL.
4. Construct the endpoint:

   ```text
   https://<workspace-hostname>/api/2.0/mcp/genie/<genie-space-id>
   ```

Keep the actual hostname/ID in your private lab configuration. You do not
deploy a custom MCP server or publish Genie as a model for this step.

## 3. Create the Managed OAuth connection

1. In Foundry, open the existing project and coordinator.
2. Use **Tools > Add** and select **Azure Databricks Genie**.
3. Choose **Managed** OAuth.
4. Fill the endpoint parameters shown by the form:

   | Parameter | Value |
   | --- | --- |
   | `workspace-hostname` | Your hostname only, without `https://` |
   | `genie_space_id` | Your curated Genie's Agent ID |

5. Give the connection a descriptive name, such as `databricks-genie-lab`.
6. Connect/attach it to the coordinator and save.

Do not create a Custom OAuth application or supply a client secret on the
main path. Managed and Custom are different configurations; do not attach
both for the same controlled test.

## 4. Complete connection consent

In a new coordinator conversation, ask:

```text
Use the Databricks Genie tool to report how many open work items and overdue
open work items there are for the snapshot of 2026-10-23.
```

1. Open the requested sign-in/consent action.
2. Verify the initiating Foundry project, connection, target workspace/Genie,
   expected identity, and requested access.
3. Complete sign-in using the intended lab identity.
4. Review and allow access only for a request you initiated and trust.

A service name alone is not proof of legitimacy. If you see a
**different organization** or unexpected consent warning, stop and verify its
provenance using the annex; the warning is not an instruction to accept it.
Never share callback URLs containing codes/state, access tokens, or secrets.

## 5. Approve the tool calls

After sign-in, the agent can request a call to `query_space_<space-id>`.
Review the tool and arguments, then select **Approve once** for the first
controlled test. A `poll_response_<space-id>` call can then retrieve the
result; review and approve that call too if requested.

Connection consent and tool-call approval are different controls:

- Consent authorizes use of the signed-in connection identity.
- Tool approval authorizes an operation proposed by the agent.
- Databricks permissions still control accessible data.

One user question may require multiple calls and multiple approvals.
The lab showed query discovery and polling, and two approval prompts were
reported. The exact mapping of every prompt to a call was not captured.

| Playground option | Appropriate use |
| --- | --- |
| Approve once | First controlled test or a sensitive/unfamiliar operation. Approves the displayed call, not the entire user question. |
| Always approve this tool | A specific reviewed tool used repeatedly. Review both query and polling tools individually; the query tool can accept questions beyond this exact benchmark. |
| Always approve all Azure Databricks Genie tools | Broad approval across the connected server's tools. Not the default recommendation for this lab. |

The persistence/revocation of playground preferences across reloads,
conversations, agent versions, and users has not been tested. For production,
use explicit application policies, tool allowlists, least-privilege
permissions, and approval logs. Keep approval for high-impact writes or
sensitive exports. Read-only data can still be sensitive.

## 6. Verify the benchmark

**Expected final answer:** 21 open work items, 9 overdue open work items.

Open the response's tool details:

1. Confirm a successful Genie tool entry, not only "Sign in successful".
2. Inspect polling **Input + Output** where available.
3. Confirm generated SQL reads a configured Gold object and uses the fixed
   snapshot date **2026-10-23**.
4. Confirm statement success and compare returned data with the answer.

The observed lab output included Gold SQL, named result columns, and
`SUCCEEDED`; a screenshot clipped the actual result rows, while a separate
completed response showed the correct answer.

The response-history view explicitly stated that it did not contain
distributed traces. Application Insights setup is deferred to L300; it is
not a prerequisite for this baseline.

## Data and capability boundaries

- The curated endpoint is read-only, not an action/job interface.
- Results leave Databricks and are supplied to the agent.
- This endpoint does not pass conversation history to Genie; test
  follow-up context separately.
- Successful sign-in does not prove runtime identity propagation.
- This baseline is not a two-user security test or a full evaluation.

Continue with [Lesson 14: host the Agent Framework specialist](14-host-agent-framework.md).

## Official references

- [Genie in Microsoft Foundry](https://learn.microsoft.com/azure/databricks/integrations/microsoft-foundry)
- [Curated Genie MCP endpoint](https://learn.microsoft.com/azure/databricks/agents/mcp-tools/genie-agent)
- [Foundry MCP authentication](https://learn.microsoft.com/azure/foundry/agents/how-to/mcp-authentication)
- [MCP tool approval and security practices](https://learn.microsoft.com/azure/foundry/agents/how-to/tools/model-context-protocol)
