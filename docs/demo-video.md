# L100 cloud demo: recording runbook

[Home](../README.md) | [Setup](00-prerequisites.md) |
[Learning path](learning-path.md) | [Evidence](capability-matrix.md)

**Status: target runbook, not recording-ready.** Genie integration and the
initial Agent Framework hosting test passed. Both business-specialist source
roles are prepared; their remote output, LangGraph hosting, and three-agent
collaboration still require verification. Do not present this sequence as
already working.

## Audience and message

A 5-7 minute introductory demonstration for application and data teams:

**Use trusted Databricks business context in a Foundry-hosted workflow,
combining specialists built with different frameworks into one useful answer.**

The video shows browser-based cloud execution, not local servers, package
installation, or a full infrastructure walkthrough. The repository teaches setup.

## Components to show

```text
Delivery lead
    |
Foundry coordinator
    |-- Curated Genie MCP --> Unity Catalog Gold views
    |-- Hosted Agent Framework delivery analyst
    `-- Hosted LangGraph action planner
    |
Evidence-backed delivery brief + proposed owner/action checklist
```

There are **three Foundry agents**. Genie is an additional Databricks agent
used as a data tool. Only the coordinator retrieves data; specialists work
with supplied query results. No credentials are passed in those facts.

Framework diversity is the teaching objective, not a claim that this small
business task inherently requires a multi-agent design.

## Suggested recording sequence

| Time | Show | Explain |
| --- | --- | --- |
| 0:00-0:30 | The delivery-review question | A lead wants evidence and next steps, not several disconnected analytics chats. |
| 0:30-1:00 | The architecture above | Databricks supplies business data/semantics; Foundry hosts and coordinates the specialists. |
| 1:00-1:45 | Three Gold views and the curated Genie | Clear definitions and data quality underpin the answer. Show a small synthetic sample, not the whole pipeline. |
| 1:45-2:15 | The three agents in Foundry | Identify the coordinator, Agent Framework analyst, and LangGraph planner; show hosted deployment details. |
| 2:15-4:30 | One coordinator conversation | Retrieve Genie evidence, invoke both specialists, and produce the brief/checklist. |
| 4:30-5:30 | Actual tool activity and final output | Point to source results, distinct specialist calls, owner handles, and the snapshot date. |
| 5:30-6:00 | Repository and boundary statement | Learners can reproduce/customize it; channels, actions, and advanced governance are later extensions. |

These are timing targets, not measured latency.

## Main question

```text
Using the dataset snapshot as of 2026-10-23, prepare a project delivery review.
Identify projects needing attention because of overdue or blocked work and
modeled effort-budget overruns. Explain the evidence and propose a concise
next-step checklist for the recorded project owners.
Use Genie for the facts and both specialists for their respective tasks.
Separate observed facts, recommendations, and missing information.
Do not change any records or claim to execute the recommendations.
```

The final answer should contain a short delivery brief and a table with
**project, evidence, recorded owner, proposed next step**, plus relevant unknowns.
This is a target output contract, not an already enforced schema.

Optional short follow-up:

```text
Can this snapshot reliably predict when P001 will finish?
```

It must acknowledge missing forecasting evidence. Any new Genie call must
include sufficient context: do not assume the curated MCP endpoint retains
the previous conversation.

## Recording-readiness checks

- Deploy from the public source and record which remote versions are used.
- In three fresh remote conversations, the main question must obtain actual
  Genie query/poll success and invoke **both** hosted specialists.
- Verify returned facts against the fixture, including the fixed date,
  open/overdue totals if reported, and project-budget variances.
- Each recommendation must refer to returned evidence and a recorded owner.
  Do not invent owners, causes, remaining hours, or completion dates.
- Confirm distinct analyst/planner outputs, no manual copying between agents,
  and no direct Databricks tools on the specialists.
- A tool error is not a completed workflow. Resolve it and rerun before recording;
  never replace a failed live result with a fabricated successful response.
- Run normal consent/approvals with the intended user. Do not weaken permissions
  or broadly disable approval just to make the recording smoother.

These are small demo acceptance checks, not a full evaluation or security audit.

## Keep the recording safe and honest

- Use only synthetic records. Crop/mask personal account details, real resource
  identifiers, browser URLs, authentication dialogs, and any secrets.
- Prepare tabs and authenticate privately before recording; rehearsal does not
  prove that another user will have identical access.
- Use a new conversation and review visible history before capture.
- Disclose cuts or time-compressed waits. Do not imply measured latency from editing.
- Say **no separate lakehouse replica is required**, not "no data leaves
  Databricks": returned query results are sent to Foundry and its models.
- Show response/tool activity, not claims of distributed traces unless configured.
- Describe Unity Catalog as the governing data layer; do not claim this demo
  has verified identity propagation or differently scoped users.
- Do not imply Teams/M365 publishing, Agent 365, automatic ticket creation,
  Databricks Job execution, or production certification is included.

## Finish with a practical handoff

Open the repository, point to setup and customization, and state what was
actually demonstrated. Keep the original slides and private screenshots out
of the public assets. A future recording can cover L300 verification and
additional channels without enlarging this introductory walkthrough.
