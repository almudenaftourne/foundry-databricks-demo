# Learning path

[Back to the lab](../README.md) | [Capability matrix](capability-matrix.md)

This is the planned lesson sequence. The learner performs the setup and
execution while the assistant writes the walkthrough and explains the results.
Each lesson includes prerequisites, numbered actions, expected results,
troubleshooting, a checkpoint, and cleanup where applicable. Draft instructions
are distinct from instructions validated by the learner.

The interaction uses stage-sized batches: explain the purpose and give
actionable steps directly in chat, then record the reproducible procedure and
evidence in the guide. The learner reports completion, errors, or differences
without per-click confirmations. Earlier lessons retain their original
checkpoints as a record of the introductory walkthrough.

The default published path starts without lab-specific cloud resources.
Existing-resource shortcuts will be documented separately. We build the guide
incrementally rather than present untested future chapters as finished.

## Delivery levels

**Learner decision (2026-10-27):** prove the basic elements first, then build
a separate L300 version with observability and deeper testing. L300 is the
advanced lab track, not a claim of production certification.

### Baseline: prove the integration building blocks

1. Prepare the synthetic data and curated Genie.
2. Obtain a correct Foundry-to-Genie answer with successful tool activity.
   The first 21-open/9-overdue benchmark is verified at response-history
   level in [Lesson 13](13-connect-genie.md).
3. Build, deploy, and remotely invoke one minimal Microsoft Agent Framework
   specialist as a Foundry hosted agent.
4. Do the equivalent for a minimal LangGraph specialist.
5. Connect the coordinator to the specialists using a verified supported
   mechanism and demonstrate one small successful workflow.

Use simple, deterministic tasks and the smallest useful smoke checks.
Preserve visible errors and verify actual remote execution; a local-only
response does not prove hosted-agent support. Record the configured identity
and known access requirements, but label untested identity propagation
explicitly. Do not block this track on Application Insights, exhaustive
benchmarks, approval-persistence experiments, load tests, or injected failures.
Basic access controls, credential handling, and cost approval still apply.

### L300: instrument, test, and harden the working baseline

- Configure Application Insights/distributed tracing and investigate
  cross-service correlation and gaps.
- Verify effective identities, two-user authorization, and data boundaries.
- Test approval scope, persistence, revocation, and application policy.
- Add repeatable evaluations, SQL/result checks, and regression cases.
- Exercise failures, timeouts, retries, and recovery.
- Measure latency and cost using a defined workload.

Actions, additional channels, and production deployment are separate
extensions, not prerequisites for completing the baseline. Keep their tests
and acceptance criteria explicit if included later. Record evidence as work
is done in both tracks; deferring advanced tests is not a passing result.

## 0. Prepare accounts, permissions, and cost controls

Follow [Lesson 00](00-prerequisites.md). Locate the intended Azure subscription,
check access, understand the cost boundary, and choose whether to create a
dedicated lab workspace or reuse an approved one.

Later resource-creation lessons will cover Databricks and Foundry setup rather
than assuming those resources already exist. Choose supported regions and
deployment options before creating resources.

**Exit check:** the learner can identify the intended subscription, explain who
may provision resources, and identify who approves lab spending. No resources
have been created by this lesson.

## 1. Understand the Databricks environment

Start with [the region preflight](01-region-preflight.md), which reviews the
requirements for the whole lab rather than Databricks alone. Regional support
does not establish account readiness or successful integration.

Learn the difference between a workspace, compute, a SQL warehouse, a Unity
Catalog catalog, a schema, a volume, a table, and a view.

Identify existing resources and permissions before creating anything. Establish
where the synthetic files and tables may live, what compute is available, and
which operations incur costs.
For the from-scratch path, write and follow the workspace-creation steps before
continuing; for reuse, validate the existing workspace against the same
requirements.

**Exit check:** explain where files live, where tables are registered, what
executes queries, and who may access each resource.

## 2. Follow raw data into Bronze

Design a small, readable fixture with teams, projects, and work items. Define
keys, table grain, timestamps, a fixed reference date, and expected counts.
Include deliberate duplicates and invalid records for the next lesson.

Land CSV/JSON files in an approved Unity Catalog volume and ingest them into
Bronze Delta tables, preserving source values and recording ingestion metadata.

**Exit check:** reconcile source and ingested row counts and inspect individual
records.

## 3. Build Silver and Gold

Clean types and identifiers, handle duplicates using an explicit rule, and
surface invalid records rather than silently dropping them. Validate
relationships before joining tables.

Create curated analytical views or tables with clear business definitions.
Bronze/Silver/Gold is a teaching structure, not a requirement to make three
physical copies of every dataset.

**Exit check:** independently calculate open-item counts and overdue-project
results, then compare them with Gold queries.

## 4. Add and evaluate Genie

Verify the currently supported curated Genie setup. Select relevant datasets,
describe columns and relationships, and provide instructions and example SQL.
Distinguish natural-language SQL analytics from document or vector search.

Test both answerable and insufficient-evidence questions. Inspect generated SQL
where available. Measure the effect of a deliberate curation improvement.

**Baseline exit check:** obtain a correct benchmark answer and record known
failure modes. Full evaluations and repeated curation comparisons belong to
the L300 track; they do not gate the initial external-agent connection.

## 5. Connect Foundry to Genie

Verify current connector prerequisites, endpoint format, network reachability,
and authentication. Record whether the request uses a user or service identity.
Do not substitute workspace-wide Genie functionality for the curated connector
without a separate compatibility test.

**Baseline exit check:** the Foundry tool call returns a benchmark result with
successful tool activity, and the configured access requirements are recorded.
Effective runtime identity propagation and distributed traces are separate
L300 checks, not assumptions.

## 6. Host each framework independently

Build one minimal Microsoft Agent Framework agent and one minimal LangGraph
agent. Test each locally, deploy each as a Foundry hosted agent, then perform
authenticated remote invocations.

Use equivalent small tasks for the baseline deployment and remote invocation
checks. Compare deeper session behavior, identity, and observability in L300.

**Exit check:** both hosted deployments work independently, or a reproducible
failure/blocker is documented for each.

## 7. Test collaboration and identity

Choose a supported invocation mechanism based on current documentation and
successful experiments. Connect the coordinator to the specialists. Define
request and result contracts, context boundaries, timeouts, and failure behavior.

For L300, use differently scoped test identities to verify allowed and denied data access.
Avoid granting specialists direct data access unless their role requires it.
Do not treat passing user-filtered evidence as proof of end-to-end identity
delegation.

**Baseline exit check:** one small coordinator-to-specialist workflow completes
with observable tool/agent activity and explicit result contracts. Failures
remain visible; cross-service trace correlation and injected-failure tests
are L300 work. Claims about identity must match observed behavior in both tracks.

## 8. Add an action and a consumption channel

Keep Genie analytics separate from a harmless Databricks Job action. Require
approval, prevent duplicate submissions, and report the actual terminal result.

Then choose and test a user channel, such as a custom app or Teams. Re-test
authentication and consent in that channel rather than assuming parity with a
development playground.

**Exit check:** approval and rejection paths behave correctly; the selected
channel reaches the deployed workflow.

## 9. Publish the reproducible result

Update the capability matrix, document setup and cleanup, and separate verified
results from untested product claims. Review content for credentials, personal
identifiers, tenant details, and other unsuitable publication material.

Choose the GitHub repository and visibility before publishing. Link the
presentation to the landing page, with a dated tested configuration so future
readers can distinguish the recorded result from later product changes.
