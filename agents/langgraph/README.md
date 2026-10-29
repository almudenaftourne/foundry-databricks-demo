# LangGraph project action planner

This source follows Microsoft's [configuration-driven Responses sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/samples/python/hosted-agents/langgraph/responses/10-run).
See [third-party notices](../../THIRD-PARTY-NOTICES.md).

The exported LangGraph graph uses LangChain `create_agent`, no tools, and
instructions to draft a project/evidence/owner/proposed-next-step table.
The hosting adapter loads it through `langgraph.json`; no custom web server
or checkpointing change is added.

It receives facts in the request, not credentials or direct Databricks access.
The table format and recommendation boundaries are model instructions, not
an enforced schema or deterministic policy engine.

**Status:** portable-source version 2 passed remote build, supplied-evidence and
missing-evidence smoke tests, and native coordinator invocation.
A fresh-clone/new-environment deployment remains unverified.
Dependencies are not fully locked.
The cloud builder uses [requirements.txt](requirements.txt), which the
contributor tests check against [pyproject.toml](pyproject.toml).
Follow [Lesson 11](../../docs/11-host-langgraph.md) for deployment and smoke tests.
