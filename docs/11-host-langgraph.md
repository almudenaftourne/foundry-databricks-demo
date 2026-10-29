# 11. Deploy the LangGraph action planner

[Previous](10-host-agent-framework.md) | [Home](../README.md) |
[Source](../agents/langgraph/README.md)

**Goal:** host the second framework specialist in the existing project. It
drafts a proposed owner/action checklist from supplied evidence; it does not
query Databricks, create tickets, or execute recommendations.

## Configure and preview

Use the tools, approved project/model, deployment roles, and runtime-access
requirements from [Lesson 10](10-host-agent-framework.md).
From the repository root in PowerShell:

```powershell
Set-Location '.\agents\langgraph'
azd env new langgraph-lab
azd env set FOUNDRY_PROJECT_ENDPOINT '<your-project-endpoint>'
azd env set AZURE_AI_PROJECT_ENDPOINT '<your-project-endpoint>'
azd env set AZURE_AI_PROJECT_ID '<your-existing-project-arm-id>'
azd env set AZURE_TENANT_ID '<your-tenant-id>'
azd env set AZURE_AI_MODEL_DEPLOYMENT_NAME '<your-existing-model-deployment>'
azd deploy langgraph-specialist --preview
```

Keep actual configuration private. Review the existing project/model, agent name
`foundry-dbx-langgraph-specialist`, **0.5 CPU / 1 GiB**, and remote dependency build.
The entrypoint is the hosting module, not `python main.py`: the graph is exported
in `main.py` and loaded through `langgraph.json`.
Keep [requirements.txt](../agents/langgraph/requirements.txt) in the source
package so the remote builder installs dependencies with pip.

## Deploy and test when approved

```powershell
azd deploy langgraph-specialist
```

Do not run `azd provision` or create another project/model for this route.
Wait for an active hosted version, then test in its Foundry playground:

```text
Prepare a proposed owner/action checklist from these supplied synthetic facts.
Snapshot: 2026-10-23.
Project P001, recorded owner demo_owner, has 2 overdue open items and an
effort-budget variance of +2000 EUR. No blocker details, remaining effort,
capacity, or dependency data is supplied. Do not query or change any systems.
```

**Expected:** P001, the supplied evidence/owner, a clearly proposed next step,
and missing-information caveats. No invented blocker, deadline, forecast, or
claim that an action was executed. `demo_owner` is a standalone smoke-test
label, not a fixture owner or real account.

Also ask for a project checklist without supplying project facts. Expect an
explicit missing-evidence response, not invented rows.

## Next

Test the Agent Framework analyst with project evidence as well, not only
the initial global-counts smoke prompt.

Independent responses do not demonstrate collaboration. Continue with
[Lesson 12: native specialist connections](12-connect-specialists.md) and run its
workflow test.

Reference: [official configuration-driven LangGraph sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/samples/python/hosted-agents/langgraph/responses/10-run).
