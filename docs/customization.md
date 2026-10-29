# Customize the tutorial

[Home](../README.md) | [Start setup](00-prerequisites.md)

Keep the provided fixture for a first run. Separate environment configuration
from business changes so an unexpected result is easier to diagnose.

## Configure your environment

| Value | Where you use it |
| --- | --- |
| Subscription, tenant, approved region | Azure/azd sign-in and environment configuration |
| Existing Foundry project endpoint and ARM ID | Hosted specialist's ignored `.azure` environment; [Lesson 10](10-host-agent-framework.md) |
| Exact model deployment name | Coordinator model selection and `AZURE_AI_MODEL_DEPLOYMENT_NAME` |
| Databricks workspace hostname and Genie ID | Genie tool connection in [Lesson 09](09-connect-genie.md) |
| Catalog/schema/volume names | All notebook references, volume paths, Genie sources, example SQL, and data-grant examples |
| Hosted service/agent names | Service keys and `name` in `azure.yaml`, deployment commands, and OpenAPI paths in [Lesson 12](12-connect-specialists.md) |
| Specialist toolbox and connections | Toolbox MCP endpoint and its project-identity connection; keep these separate from Genie's OAuth connection |

Use private, ignored configuration for actual resource values. Never put tokens,
secrets, or populated environment files in Git. `.env.example` contains placeholders.
Changing agent names can create a separate agent; reusing one can create a new
version. Review existing resources before deployment.

## Change business behavior

- **Genie definitions and boundaries:** edit the instruction block in
  [Lesson 06](06-create-genie.md), then apply it to the actual Genie.
- **Coordinator behavior:** start with [Lesson 08](08-create-coordinator.md),
  then apply the [workflow instructions](../agents/coordinator/instructions.txt)
  and connections in [Lesson 12](12-connect-specialists.md). Keep fresh-query
  context, returned-ID polling, and both specialist completion checks.
- **Agent Framework behavior:** edit [main.py](../agents/maf/main.py).
- **LangGraph workflow:** edit `INSTRUCTIONS` in
  [main.py](../agents/langgraph/main.py). The hosting adapter loads its exported
  graph through [langgraph.json](../agents/langgraph/langgraph.json).

Source edits alone do not update a hosted agent. Review the build/deployment,
then test the new remote version. Use returned Genie facts; do not place
expected answers in agent prompts.

## Change the dataset after the tutorial works end to end

The example's **2026-10-23** date is intentionally fixed. Changing it, the CSVs,
or business rules requires updating and revalidating:

1. The source fixture and [validation script](../data/validate-fixture.ps1).
2. Notebook cleaning rules, Gold definitions, and SQL assertions.
3. Genie context/examples and coordinator/specialist inputs.
4. The [answer key](../data/README.md) and your test questions.

If you change an existing lab, inspect tables and grants before rerunning
creation/replacement statements. Do not delete shared objects as a reset.

Use only synthetic data in any shared copy of this lab.
