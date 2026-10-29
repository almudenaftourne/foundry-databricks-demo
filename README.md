# Microsoft Foundry + Azure Databricks demo

A cloud-first, introductory demo: use curated Databricks data in a Foundry
workflow with specialists built on Agent Framework and LangGraph.

This is a learning demo with synthetic data, not production certification.

## What it shows

A delivery lead asks: **Which projects need attention, why, and what should
their owners do next?**

```text
Delivery lead -> Foundry coordinator
                  |-- Genie MCP -> governed Databricks Gold views
                  `-- Foundry Toolbox
                        |-- hosted Agent Framework delivery analyst
                        `-- hosted LangGraph action planner
               -> evidence-backed brief + proposed owner/action checklist
```

Three Foundry agents, plus Genie as an external data tool. The Toolbox is tool
configuration, not an agent. Only the coordinator retrieves data; the
specialists reason over the facts it passes. Recommendations are drafts: nothing
is executed. This small task does not inherently need three agents; the design
demonstrates cross-framework composition.

See what has been tested in the [verified status](docs/capability-matrix.md).

## Set it up

Follow the lessons in order. Reuse approved resources where you can.

| Stage | Lessons |
| --- | --- |
| Environment | [00 prerequisites](docs/00-prerequisites.md), [01 Databricks workspace and catalog](docs/01-prepare-databricks.md) |
| Data | [02 upload](docs/02-upload-source-files.md), [03 Bronze](docs/03-ingest-bronze.md), [04 Silver](docs/04-prepare-silver.md), [05 Gold](docs/05-build-gold.md) |
| Genie and Foundry | [06 Genie](docs/06-create-genie.md), [07 Foundry project](docs/07-create-foundry-project.md), [08 coordinator](docs/08-create-coordinator.md), [09 connect Genie](docs/09-connect-genie.md) |
| Specialists | [10 Agent Framework](docs/10-host-agent-framework.md), [11 LangGraph](docs/11-host-langgraph.md), [12 connect specialists](docs/12-connect-specialists.md) |

Also: [customize it](docs/customization.md), [dataset and answer key](data/README.md), and
[Annex A: authentication troubleshooting](docs/appendix-authentication.md)
(only if sign-in or access goes wrong).

## Dataset

All records are fictional. The reference date is always **2026-10-23**.

```text
4 teams, 8 projects
44 raw work-item rows = 1 superseded + 3 quarantined + 40 accepted
21 open work items, including 9 overdue
```

Validate the fixture locally, with no dependencies:

```powershell
pwsh -File .\data\validate-fixture.ps1
```

The SQL notebooks in [notebooks](notebooks/) build the data layers; the lessons
tell you when to run them. Cloud compute and model inference can incur charges.

## Going further

This repository covers the basic integration. Natural next steps, none of which
are verified here: evaluation, tracing across both platforms, two-user permission
tests, approval policy, failure injection, and cost measurements.

## Safety

- Use your own endpoint, tenant, subscription, model deployment, Databricks host,
  and Genie ID. Keep secrets and populated `.env` / `.azure` files out of Git.
- No separate lakehouse replica is required, but query results are sent to Foundry.
  Do not describe this as "no data leaves Databricks".
- Use approved regions, permissions, and spending limits. Closing a browser does
  not disable a hosted endpoint or stop all billable resources.

Third-party notices: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
