# Microsoft Foundry + Azure Databricks demo

A cloud-first, introductory demo: use curated Databricks data in a Foundry
workflow combining specialists built with Agent Framework and LangGraph.

**L100 version in progress, updated 2026-10-28.** The data/Genie connection and
initial Agent Framework hosting test work. The complete three-agent business
workflow is not yet verified. This is a learning demo, not production certification.

## What the finished demo will show

A delivery lead asks: **Which projects need attention, why, and what should
their owners do next?**

```text
Delivery lead -> Foundry coordinator
                  |-- Genie MCP -> governed Databricks Gold views
                  |-- hosted Agent Framework delivery analyst
                  `-- hosted LangGraph action planner
               -> evidence-backed brief + proposed owner/action checklist
```

That is **three Foundry agents**, plus Genie as an external data tool.
Only the coordinator retrieves data; specialists receive relevant returned facts.
Recommendations are drafts, not tickets, job runs, or data updates.

The value is combining governed business context, framework choice, and cloud
execution in one user request. This small task does not inherently require
three agents; the design deliberately demonstrates cross-framework composition.

## What works today

| Building block | Observed result |
| --- | --- |
| Synthetic data through Bronze, Silver, and Gold | Fixture and data-layer validation passed |
| Curated Databricks Genie | Selected count, budget, detail, and missing-evidence questions validated |
| Foundry coordinator calling Genie through Managed OAuth/MCP | 21 open / 9 overdue for the fixed snapshot; successful polling and SQL statement observed |
| Standalone Microsoft Agent Framework hosted specialist | Hosted version 1 returned the supplied-facts summary: 21 open, 9 overdue, 42.9%, with missing-data caveat |
| LangGraph hosted specialist | Not yet tested |
| Distinct analyst/planner business roles | Source prepared; remote verification pending |
| Coordinator-to-specialist collaboration | Not yet tested |

The first two agent capabilities are **independent demonstrations**:

```text
User -> Foundry coordinator -> curated Genie MCP -> Databricks Gold views

User -> Foundry hosted Agent Framework specialist
        (summarizes facts supplied in the request; no data tools)
```

Source for both roles is prepared. The deployed Agent Framework smoke test
still reflects the earlier supplied-counts task; the new roles require remote testing.

Evidence comes from operator-executed checks and screenshots, with boundaries
recorded in the [capability matrix](docs/capability-matrix.md). Raw screenshots,
the original presentation, local cloud configuration, and authentication
history are deliberately not published.

## Start here

The main path assumes an approved organizational identity and functioning
authentication. [Start with setup and cloning](docs/00-prerequisites.md), then
follow the stages below. Reuse approved resources where suitable.
One-time administrator preparation is separate from builder and demo-user access.
Exceptional authentication/network diagnosis belongs in annexes, not every setup.

| Stage | Lessons |
| --- | --- |
| Accounts, regions, and workspace | [00: prerequisites](docs/00-prerequisites.md), [01: region preflight](docs/01-region-preflight.md), [02: create workspace](docs/02-create-databricks-workspace.md), [03: workspace tour](docs/03-workspace-and-catalog.md) |
| Prepare data | [04: catalog](docs/04-create-lab-catalog.md), [05: schemas and volume](docs/05-schemas-and-raw-volume.md), [06: upload](docs/06-upload-source-files.md), [07: Bronze](docs/07-ingest-bronze.md), [08: Silver](docs/08-prepare-silver.md), [09: Gold](docs/09-build-gold.md) |
| Curate and connect Genie | [10: native Genie](docs/10-create-genie.md), [11: Foundry project](docs/11-create-foundry-project.md), [12: coordinator](docs/12-create-coordinator.md), [13: OAuth Genie connection](docs/13-connect-genie.md) |
| Host the specialists | [14: Agent Framework](docs/14-host-agent-framework.md), [15: LangGraph](docs/15-host-langgraph.md), [analyst source](agents/maf/README.md), [planner source](agents/langgraph/README.md) |

Additional resources:

- [Synthetic dataset, definitions, and answer key](data/README.md).
- [Learning path: baseline first, L300 later](docs/learning-path.md).
- [Configuration and customization](docs/customization.md).
- [Cloud video runbook and recording-readiness checks](docs/demo-video.md)
  (target sequence; not recording-ready).
- [Annex A: authentication and access troubleshooting](docs/appendix-authentication.md).
- [Annex B: optional local development and download issues](docs/appendix-local-development.md).
- [Third-party notices](THIRD-PARTY-NOTICES.md).

## Reproducible dataset

All records are fictional teams, projects, and work items. Handles are
role-based labels, not real users. The reference date is always
**2026-10-23**, not today's date.

```text
4 teams, 8 projects
44 raw work-item rows = 1 superseded + 3 quarantined + 40 accepted
21 open work items, including 9 overdue
```

Validate the fixture locally without Python dependencies:

```powershell
pwsh -File .\data\validate-fixture.ps1
```

The SQL notebooks in [notebooks](notebooks/) implement the data layers.
Follow the lessons before running them: cloud compute and model inference
can incur charges.

## Baseline and L300

**Baseline:** prove data preparation, native Genie, Foundry-to-Genie,
standalone Agent Framework and LangGraph hosting, then a small supported
coordinator/specialist workflow. Use actual remote smoke tests, not only
source generation or local execution.

**L300:** add distributed tracing, runtime identity verification, two-user
permission tests, approval policy/persistence, evaluations, injected
failures, retries, latency, and cost measurements. These remain unverified
until tested; observability setup is not a gate for the first baseline.

Next: specialize the business tasks, complete LangGraph hosting, then verify
one coordinator request invoking both specialists. The recorded demo uses the
Foundry web playground, not a local server. Teams/M365, Agent 365, and real
actions are separate extensions.

## Configuration and publication safety

- Use your own project endpoint, tenant, subscription, model deployment,
  Databricks hostname, and Genie ID. Public examples use placeholders.
- Keep secrets and populated `.env` / `.azure` configuration local and ignored.
- The portable source in `agents/maf` is separate from the original lab's
  machine-specific scaffold. It has not yet been deployed from a fresh clone.
- The source summarizes supplied facts, not confidential business data.
- The revised business-role instructions and new LangGraph source still need
  remote verification; local source tests do not establish hosting or output quality.
- No separate lakehouse replica is required, but query results are sent to
  Foundry. Do not describe the integration as "no data leaves Databricks."
- Do not publish raw consent URLs, tokens, private keys, logs, original
  screenshots, or presentation files. Review the exact Git diff before pushes;
  ignore rules do not remove secrets already committed.
- Use approved dependencies, regions, permissions, and spending limits.
  Prompts are not authorization boundaries; read-only data can be sensitive.
- Remote compute can scale down when idle, but closing a browser or VS Code
  does not disable a hosted endpoint or remove all billable resources.

## Contributing updates

Keep the main path short, sequential, and independently reproducible.
Put exceptional diagnosis in an annex. Update the capability matrix with
specific observed evidence, distinguishing documented, operator-confirmed,
and untested claims. Preserve the fixed fixture and expected answers.

The repository is for demonstration and learning; it is not production
certification or a guarantee of service availability.

Contributor source checks (Python 3.13, no third-party packages required):

```powershell
python -m unittest discover -s agents\tests -v
```

These tests use dependency doubles to check startup wiring and explicit
configuration errors; they do not call models or prove remote hosting,
recommendation quality, or end-to-end collaboration.
