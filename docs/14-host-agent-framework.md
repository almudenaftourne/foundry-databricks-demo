# Lesson 14: deploy an Agent Framework hosted specialist

[Home](../README.md) | [Previous: Genie connection](13-connect-genie.md) |
[Portable source](../agents/maf/README.md)

**Goal:** prove standalone Microsoft Agent Framework hosting before connecting
specialists to the coordinator.

**Current scope:** this lesson covers standalone hosting. The source now defines
the delivery-risk analyst, but these revised instructions still need a remote
test. Connecting it to the coordinator is subsequent work.
The [capability matrix](capability-matrix.md) distinguishes the original
remote smoke test from the not-yet-tested fresh-clone source deployment.

## What this agent does

It explains delivery attention signals from synthetic facts supplied in a request.
It does not retrieve
data from Databricks, call Genie, or know current project records.
For this tiny task, a second agent is not necessary; the purpose is to
prove framework hosting independently before adding collaboration.

The instructions live in [main.py](../agents/maf/main.py).
Formatting and arithmetic are model instructions, not a deterministic
calculation tool or enforced output schema.

## Prerequisites

- An existing Foundry project and supported deployed chat model.
- Hosted-agent availability and quota in your approved region.
- **Foundry Project Manager** at the project scope for the deployer, plus
  applicable project/agent identity prerequisites.
- Approved hosted compute, inference costs, and cloud package builds.
- Git, Azure CLI, and Azure Developer CLI with the Foundry extension.
  The lab used Python 3.13, azd 1.37.1, and Foundry extension beta.22.

For Windows developer-tool setup, follow the
[official environment guide](https://learn.microsoft.com/azure/foundry/how-to/develop/install-cli-sdk).
The hosted quickstart requires azd 1.27.1 or later.

The main path uses **source-code deployment with remote dependency build**.
It does not require successful local installation of the agent's Python
packages, Docker, or Application Insights. Use only approved dependencies
and cloud execution; this is not a way to evade an established restriction.

Authentication/role failures belong in the
[authentication annex](appendix-authentication.md). Optional local execution
and download errors belong in the [local-development annex](appendix-local-development.md).

## 1. Sign in

In PowerShell, run these separately and complete each browser sign-in:

```powershell
az login
azd auth login
```

Choose the same approved lab identity, tenant, and subscription. Portal
sign-in does not authenticate both command-line tools. Do not share device
codes, callback URLs, or tokens.

## 2. Configure this source for your existing project

From the repository root:

```powershell
Set-Location '.\agents\maf'
azd env new maf-lab
```

Use a unique environment name if that environment already exists. This
creates local configuration, not a new cloud project.

Collect these values from your approved Azure/Foundry configuration:

| Value | Meaning |
| --- | --- |
| Project endpoint | Project Home/Overview endpoint, not a model API endpoint |
| Project ARM resource ID | Existing project resource ID from Azure resource details |
| Tenant ID | Directory associated with the existing project |
| Model deployment name | Exact existing deployment name, not necessarily its model name |

Replace the placeholders before running:

```powershell
azd env set FOUNDRY_PROJECT_ENDPOINT '<your-project-endpoint>'
azd env set AZURE_AI_PROJECT_ENDPOINT '<your-project-endpoint>'
azd env set AZURE_AI_PROJECT_ID '<your-existing-project-arm-id>'
azd env set AZURE_TENANT_ID '<your-tenant-id>'
azd env set AZURE_AI_MODEL_DEPLOYMENT_NAME '<your-existing-model-deployment>'
```

The manifest references the existing project and does not declare a new
model deployment. Keep populated configuration in ignored `.azure` files.
Do not publish `azd env get-values` output; environments can contain secrets.
The example `.env.example` is optional local configuration, not required
for this remote-build route.

## 3. Preview and approve the deployment

```powershell
azd deploy maf-specialist --preview
```

Confirm the intended project/model and agent name
`foundry-dbx-maf-specialist`. The manifest requests **0.5 CPU / 1 GiB memory**
and Responses protocol **2.0.0**.

**Name collisions matter:** deploying with an existing agent name can create
a new version of that agent. Use a distinct name if you must not update one.

The preview does not validate infrastructure, package resolution, or runtime
behavior. Review current charges before proceeding.

## 4. Deploy the specialist only

```powershell
azd deploy maf-specialist
```

Do not run `azd up` or `azd provision`: this route reuses an existing project.
The tooling packages the source, uploads it, and Foundry builds dependencies
and creates a hosted version. Do not include local environments or credentials
in the uploaded package.

Wait for successful deployment and the playground/endpoint link. A package
upload alone is not the success criterion. If the build fails, preserve a
sanitized error and resolve that cause before retrying.

## 5. Test the deployed agent

Open its playground as the authorized lab user and confirm **Kind: hosted**.
Send:

```text
Summarize these supplied facts. Snapshot: 2026-10-23.
Open work items: 21. Overdue open work items: 9.
No remaining-effort, capacity, or dependency data is supplied.
Do not query external data.
```

**Expected:** at most four short bullets containing the snapshot, 21 open,
9 overdue, 42.9% overdue, and acknowledgment of missing information without
a fabricated forecast.

Inspect the hosted response and container activity. This checks remote
execution, not arbitrary-input accuracy, runtime identity propagation, or
distributed tracing. It should not request Databricks consent: it has no
Databricks tools.

## Costs and lifecycle

Current Foundry documentation describes on-demand hosted compute and
deprovisioning after an idle timeout; the documented default is 15 minutes.
The lab's actual timeout and idle behavior were not inspected.
Do not assume closing VS Code disables the hosted endpoint or that the
whole lab becomes free when compute idles.

There is no `azd ai agent stop` command in the CLI version tested.
Endpoint disablement is a separate lifecycle operation; consult the
[management guide](https://learn.microsoft.com/azure/foundry/agents/how-to/manage-hosted-agent)
before changing state. Keep shared resources and the working coordinator intact.

## Next

Continue with [Lesson 15: LangGraph hosting](15-host-langgraph.md). Test the
two distinct roles remotely before connecting them. Observability, security
boundary tests, evaluation, and resilience belong to the L300 track.

## Official references

- [Hosted-agent quickstart](https://learn.microsoft.com/azure/foundry/agents/quickstarts/quickstart-hosted-agent)
- [Source-code deployment](https://learn.microsoft.com/azure/foundry/agents/how-to/deploy-hosted-agent-code)
- [Hosted-agent permissions](https://learn.microsoft.com/azure/foundry/agents/concepts/hosted-agent-permissions)
- [Upstream sample and license](../THIRD-PARTY-NOTICES.md)
