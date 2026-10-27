# Microsoft Foundry + Azure Databricks demo

A progressive, hands-on lab: curate synthetic data in Databricks, connect
Foundry to Genie, then host specialists built with different agent frameworks.

**First edition, 2026-10-27.** This is the ongoing source repository, not a
production reference architecture or a claim that every planned capability
has been tested. Previews, APIs, portal labels, models, and regional support
can change.

## What works today

| Building block | Observed result |
| --- | --- |
| Synthetic data through Bronze, Silver, and Gold | Fixture and data-layer validation passed |
| Curated Databricks Genie | Selected count, budget, detail, and missing-evidence questions validated |
| Foundry coordinator calling Genie through Managed OAuth/MCP | 21 open / 9 overdue for the fixed snapshot; successful polling and SQL statement observed |
| Standalone Microsoft Agent Framework hosted specialist | Hosted version 1 returned the supplied-facts summary: 21 open, 9 overdue, 42.9%, with missing-data caveat |
| LangGraph hosted specialist | Not yet tested |
| Coordinator-to-specialist collaboration | Not yet tested |

The first two agent capabilities are **independent demonstrations**:

```text
User -> Foundry coordinator -> curated Genie MCP -> Databricks Gold views

User -> Foundry hosted Agent Framework specialist
        (summarizes facts supplied in the request; no data tools)
```

Connecting the coordinator to both framework specialists is the next
architecture milestone, not an already implemented feature.

Evidence comes from operator-executed checks and screenshots, with boundaries
recorded in the [capability matrix](docs/capability-matrix.md). Raw screenshots,
the original presentation, local cloud configuration, and authentication
history are deliberately not published.

## Follow the main tutorial

The main path assumes an approved organizational identity and functioning
authentication. Establish the stated permissions, then follow the numbered
lessons. Exceptional authentication/network investigations are annexes,
not mandatory setup workarounds.

| Stage | Lessons |
| --- | --- |
| Accounts, regions, and workspace | [00: prerequisites](docs/00-prerequisites.md), [01: region preflight](docs/01-region-preflight.md), [02: create workspace](docs/02-create-databricks-workspace.md), [03: workspace tour](docs/03-workspace-and-catalog.md) |
| Prepare data | [04: catalog](docs/04-create-lab-catalog.md), [05: schemas and volume](docs/05-schemas-and-raw-volume.md), [06: upload](docs/06-upload-source-files.md), [07: Bronze](docs/07-ingest-bronze.md), [08: Silver](docs/08-prepare-silver.md), [09: Gold](docs/09-build-gold.md) |
| Curate and connect Genie | [10: native Genie](docs/10-create-genie.md), [11: Foundry project](docs/11-create-foundry-project.md), [12: coordinator](docs/12-create-coordinator.md), [13: Managed Genie connection](docs/13-connect-genie.md) |
| Host a specialist | [14: Agent Framework cloud build and smoke test](docs/14-host-agent-framework.md), [portable source](agents/maf/README.md) |

Additional resources:

- [Synthetic dataset, definitions, and answer key](data/README.md).
- [Learning path: baseline first, L300 later](docs/learning-path.md).
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

The next work item is the standalone **LangGraph hosted specialist**, followed
by collaboration. Keep using this repository for those additions.

## Configuration and publication safety

- Use your own project endpoint, tenant, subscription, model deployment,
  Databricks hostname, and Genie ID. Public examples use placeholders.
- Keep secrets and populated `.env` / `.azure` configuration local and ignored.
- The portable source in `agents/maf` is separate from the original lab's
  machine-specific scaffold. It has not yet been deployed from a fresh clone.
- The source summarizes supplied facts, not confidential business data.
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
