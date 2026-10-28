# Learning path

[Home](../README.md) | [Setup](00-prerequisites.md) |
[Evidence](capability-matrix.md) | [Video runbook](demo-video.md)

## L100: one useful cloud workflow

**Scenario:** a delivery lead needs a concise review of projects needing
attention, with evidence and proposed next steps for their owners.

The target is **three Foundry agents**, plus Genie as their external data tool:

| Component | Role |
| --- | --- |
| Foundry coordinator | Receives the question, retrieves Genie facts, delegates, and assembles the answer |
| Agent Framework specialist | Explains delivery concerns from the supplied evidence |
| LangGraph specialist | Produces a structured, evidence-based owner/action checklist |
| Curated Databricks Genie | Queries governed Gold data; it is not a fourth Foundry agent |

Only the coordinator needs the Genie connection. Specialists receive the
relevant returned facts, not direct Databricks access or user credentials.
Proposed actions are drafts; no ticket creation, job execution, or data writes
are part of this version.

### Build in this order

1. **Prepare the environment:** [00](00-prerequisites.md) through
   [05](05-schemas-and-raw-volume.md). Reuse approved resources where suitable.
2. **Prepare trusted data:** [06](06-upload-source-files.md) through
   [09](09-build-gold.md). Validate the fixed synthetic fixture.
3. **Curate and connect:** [10](10-create-genie.md) through
   [13](13-connect-genie.md). Obtain real query/poll results through Foundry.
4. **Host specialists:** [14](14-host-agent-framework.md) proves Agent Framework
   hosting. [15](15-host-langgraph.md) covers the prepared LangGraph planner.
   Both revised business roles still require remote verification.
5. **Connect and rehearse:** verify the supported coordinator-to-specialist
   mechanism remotely, then run the [video acceptance checks](demo-video.md).

The completion criterion is a working remote workflow deployed from the
public repository, not three unrelated playground conversations or generated code.
Keep unfinished capabilities labeled pending in the matrix.

### Main-path conventions

- Cloud runtime and remote dependency build; local execution/debugging is optional.
- One stage-sized instruction batch with expected results, not chat confirmations
  after each click.
- Required sign-in, access, consent, and cost review remain visible.
- Account/tenant anomalies and network diagnosis live in annexes.
- A privileged lab run is not proof of least-privilege user access.

## L300: deepen the verified baseline

Later work includes distributed tracing, runtime-principal verification,
two-user authorization tests, approval persistence/revocation, repeatable
evaluations, injected failures, retries, latency, and cost measurements.
Deferring these tests is not a passing result or production certification.

Databricks Job actions, Teams/Microsoft 365 channels, Agent 365, and a custom
application are separate extensions. Each needs its own setup and verification;
none is implied by a successful Foundry playground demo.
