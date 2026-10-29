# Verified status

[Back to the lab](../README.md)

What has actually been run in the lab environment (Sweden Central, October 2026).
This is evidence from one environment, not a product support statement or
production certification.

| Area | Status | Notes |
| --- | --- | --- |
| Synthetic data through Bronze, Silver, Gold | Verified working | All three Gold views pass the 23 reference checks |
| Curated Genie | Verified working | Count, budget, detail, and missing-evidence questions answered correctly |
| Foundry coordinator to Genie (Managed OAuth, MCP) | Verified working | 21 open / 9 overdue for the fixed snapshot; query and poll calls observed |
| Hosted Agent Framework analyst | Verified working | Remote build; supplied-evidence smoke tests passed |
| Hosted LangGraph planner | Verified working | Remote build; supplied-evidence and missing-evidence tests passed |
| Coordinator calling both specialists through a Toolbox | Verified working | Full Genie-to-specialists reviews passed, including a Foundry playground run with normal approvals |
| Incoming A2A to a hosted specialist | Tested and failed | See below |
| Fresh-clone deployment into a new environment | Not tested | Only the existing lab environment was used |
| Distributed tracing, evaluation, failure injection | Not tested | Outside this baseline |
| Two-user permission and identity tests | Not tested | Outside this baseline |
| Databricks job actions, Teams/Microsoft 365 channels | Not tested | Separate extensions |

## Incoming A2A on a hosted specialist

On 2026-10-29, incoming A2A was enabled on the existing hosted Agent Framework
analyst (version 3). Agent-card discovery worked for both A2A v1.0 and v0.3, but
every invocation was rejected: v1.0 JSON-RPC, v0.3 JSON-RPC, and v0.3 HTTP+JSON all
returned a hosted-agent-not-supported error that tells the caller to use a prompt
agent as the target. The original configuration was restored and the Responses
endpoint was confirmed working again. An inert `agent_card` remained because a null
update does not remove it.

The Toolbox `a2a_preview` route used by the official
[a2a/01-delegation sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/samples/python/hosted-agents/agent-framework/a2a/01-delegation)
and LangGraph targets were not tested. The
[incoming A2A guide](https://learn.microsoft.com/azure/foundry/agents/how-to/enable-agent-to-agent-endpoint)
lists a deployed prompt agent as a prerequisite. This demo therefore connects the
specialists through a Toolbox over their Responses endpoints. This is a result for the
tested configuration, not a statement that A2A fails in general.

## Status meanings

- **Verified working:** the success criterion passed in the recorded environment.
- **Tested and failed:** an attempt failed; this does not prove the capability is unsupported.
- **Not tested:** no experiment has been run.
