# Tested configuration

[Home](../README.md)

The steps in this tutorial were run in one environment (Sweden Central, October 2026).
This page lists what was tested there. It is not a statement about product
support in other environments.

| Area | Result | Notes |
| --- | --- | --- |
| Data pipeline through Bronze, Silver, and Gold | Worked | All 23 Gold checks pass |
| Curated Genie | Worked | Count, budget, detail, and missing-evidence questions answered as expected |
| Foundry coordinator to Genie (Managed OAuth, MCP) | Worked | 21 open / 9 overdue for the fixed snapshot; query and poll calls observed |
| Hosted Agent Framework analyst | Worked | Remote build; supplied-evidence tests passed |
| Hosted LangGraph planner | Worked | Remote build; supplied-evidence and missing-evidence tests passed |
| Coordinator calling both specialists through a Toolbox | Worked | Tested through the API and the Foundry playground, with per-call approvals |
| Incoming A2A to a hosted specialist | Did not work | See below |
| Deployment from a fresh clone into a new environment | Not tested | |
| Tracing, evaluation, failure handling | Not tested | |
| Multi-user permission and identity propagation | Not tested | |
| Databricks job actions, Teams or Microsoft 365 channels | Not tested | |

## Incoming A2A on a hosted specialist

Incoming A2A was enabled on the hosted Agent Framework analyst (version 3) with an
agent card. Agent-card discovery worked for A2A v1.0 and v0.3. Every invocation was
rejected with a hosted-agent-not-supported error that instructs the caller to use a
prompt agent as the target. The routes tried were v1.0 JSON-RPC, v0.3 JSON-RPC, and
v0.3 HTTP+JSON. The original configuration was then restored and the Responses
endpoint worked again. A null update did not remove the agent card.

The [incoming A2A guide](https://learn.microsoft.com/azure/foundry/agents/how-to/enable-agent-to-agent-endpoint)
lists a deployed prompt agent as a prerequisite. The Toolbox `a2a_preview` route in the
[a2a/01-delegation sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/samples/python/hosted-agents/agent-framework/a2a/01-delegation)
and LangGraph targets were not tested. This tutorial connects the specialists
through a Toolbox over their Responses endpoints.
