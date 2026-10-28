# Capability matrix

[Back to the lab](../README.md)

This matrix records evidence from the lab environment, not a general product support
statement. Prerequisites, Databricks workspace deployment, and first access are
user-validated. Integration experiments have the individual statuses below;
sign-in or tool discovery alone does not establish end-to-end success.

| ID | Experiment | Success criterion | Status | Evidence |
| --- | --- | --- | --- | --- |
| P00 | Beginner prerequisites | The learner completes the account, access, and cost checkpoint without provisioning resources. | Verified working | [Lesson 00](00-prerequisites.md); learner confirmations on 2026-10-23, not independent Azure inspection |
| P01 | From-scratch setup | A learner provisions the required lab resources using the documented steps and verifies prerequisites for subsequent lessons. | Not tested | None |
| P02 | Regional compatibility preflight | Official sources cover the required regional building blocks; subscription and end-to-end checks remain separate. | Documented but untested | [Lesson 01](01-region-preflight.md); sources reviewed on 2026-10-23 |
| P03 | Databricks workspace creation | Portal review passes, deployment succeeds, and the learner opens the new Databricks workspace. | Verified working | [Lesson 02](02-create-databricks-workspace.md); learner confirmations on 2026-10-23, not independent Azure inspection |
| P04 | Lab catalog and schemas | The selected lab catalog contains raw, bronze, silver, and gold schemas. | Verified working | [Lesson 05](05-schemas-and-raw-volume.md); screenshot confirms object presence on 2026-10-23, not backing storage or permission behavior |
| P05 | Raw-file landing volume | A managed integration_lab.raw.source_files volume exists and is empty before upload. | Verified working | [Lesson 05](05-schemas-and-raw-volume.md); learner confirmation on 2026-10-23 |
| P06 | Foundry agent-creation access | The learner has effective Foundry development access and can create/save the coordinator in the project. | Verified working | [Lesson 12](12-create-coordinator.md); later screenshot on 2026-10-26 shows saved coordinator version 2 responding. The earlier blocker is no longer observed; exact IAM changes were not reported |
| P07 | Optional Databricks account-console access | An authorized account admin can open App connections for a Custom OAuth path. | Blocked | Account administration was not established; not required for the working Managed OAuth baseline. See the [authentication annex](appendix-authentication.md) |
| D00 | Local synthetic fixture | CSV schemas, counts, relationships, cleaning outcomes, and expected query totals pass local validation. | Verified working | [Dataset contract](../data/README.md) and local PowerShell validator passed on 2026-10-23; not Databricks execution |
| D00U | Source-file upload | All three original CSV files are visible at the expected volume paths. | Verified working | [Lesson 06](06-upload-source-files.md); learner confirmation on 2026-10-23, remote content verification follows during ingestion |
| D00R | First notebook file read | The imported SQL notebook reads teams.csv on serverless compute and returns four rows without creating a table. | Verified working | [Lesson 07](07-ingest-bronze.md); learner reports four preview rows on 2026-10-26, not independent inspection of output |
| D01 | Raw data ingestion | Synthetic files load into Bronze Delta tables with matching row counts and ingestion metadata. | Verified working | [Lesson and notebook](07-ingest-bronze.md); learner confirms 4/8/44 rows and both assertions; screenshot shows retained dirty records on 2026-10-26 |
| D02 | Data preparation | Silver validation checks pass; Gold aggregates match independently calculated expected values. | Verified working | [Silver](08-prepare-silver.md) and [Gold](09-build-gold.md) completed with learner-confirmed checks on 2026-10-26 |
| D02S | Silver typing and quarantine | Typed teams/projects and 40 valid latest work items are persisted alongside 3 quarantined and 1 superseded record; assertions pass. | Verified working | [Lesson 08](08-prepare-silver.md); learner supplied correct WI001 types and confirms all counts/assertions on 2026-10-26 |
| D02G | Gold business views | Three views at work-item/project/team grain pass all 23 reference checks, including per-project/team budgets and costs. | Verified working | [Lesson 09](09-build-gold.md); learner confirmed completion after the 23-PASS checkpoint on 2026-10-26 |
| G01 | Curated Genie analytics | Benchmark questions return expected results; underlying SQL is inspected where available. | In progress | [Lesson 10](10-create-genie.md); learner confirms creation, correct count/budget/detail answers, and improved forecast-limitation answer on 2026-10-26. Only the first question's SQL was supplied; team totals and full-suite validation pending. Learner chose to proceed to Foundry |
| G02 | Genie context handling | Standalone and follow-up questions establish what context must be supplied on each invocation. | In progress | An earlier invented nonempty conversation ID caused an ownership error. Toolbox rehearsals used fresh self-contained queries and actual returned polling IDs; an empty optional ID was also accepted as a fresh query. General follow-up/context behavior remains untested. Do not repair invented IDs with broader permissions |
| F00 | Coordinator without data access | The saved coordinator responds to a dataset question without inventing a count when the Genie tool is unavailable. | Verified working | [Lesson 12](12-create-coordinator.md); learner screenshot shows the expected refusal through gpt-5.4-mini on 2026-10-26. Tool inventory/traces were not expanded |
| F01 | Foundry to Genie | A Foundry agent discovers and invokes the Genie tool and returns a result matching the benchmark. | Verified working | [Lesson 13](13-connect-genie.md); on 2026-10-27 response history shows a completed response, successful poll_response call, and correct 21 open/9 overdue answer. Expanded poll output exposes generated Gold SQL, fixed snapshot, and statement state SUCCEEDED; result rows are clipped. Initial completed query call, distributed trace, and effective query principal remain unverified |
| F01M | Alternate-account authentication experiment | Authorization completes and a Genie query succeeds. | Tested and failed | A tenant-context sign-in failure was observed; the [authentication annex](appendix-authentication.md) covers diagnosis. This is not a general product support restriction |
| F01N | Managed OAuth with the directory-native lab identity | Managed OAuth authorizes the new identity and permits a Genie query with successful response-level tool activity matching the benchmark. | Verified working | [Lesson 13](13-connect-genie.md); native Genie and Foundry baseline 21 open/9 overdue confirmed on 2026-10-27, with successful poll_response tool activity visible. Earlier query_space request plus later poll support a query/poll workflow; exact approval-to-call mapping, approval persistence, distributed trace, and runtime principal unverified |
| H01 | Microsoft Agent Framework hosting | A deployed Foundry hosted agent responds to an authenticated remote request; local-only execution does not qualify. | Verified working | [Lesson 14](14-host-agent-framework.md); learner screenshot on 2026-10-27 shows version 1, kind hosted, returning four bullets with snapshot 2026-10-23, 21 open/9 overdue, 42.9%, and missing-data caveat. Remote-build deployment learner-reported. Runtime principal, distributed tracing, collaboration, and fresh-clone deployment of the portable layout remain unverified |
| H01P | Portable Agent Framework source | The public source layout remotely builds and explains supplied business evidence. | Verified working | [Lesson 14](14-host-agent-framework.md); hosted version 3 returned the four global counts, 42.9%, positive budget signals, and missing-evidence caveats. requirements.txt selects the remote pip build path; a fresh-clone/new-environment deployment remains unverified |
| H02 | LangGraph hosting | A deployed Foundry hosted agent responds to an authenticated remote request with a grounded proposed owner/action checklist. | Verified working | [Lesson 15](15-host-langgraph.md); portable-source hosted version 2 passed supplied-evidence and missing-evidence requests. No invented blocker/deadline or executed action |
| H03 | Distinct business-specialist roles | The revised Agent Framework analyst explains supplied project attention signals, and LangGraph drafts grounded proposed owner actions. | Verified working | Actual hosted versions 3 and 2 passed business-role smoke tests and native project-identity invocations; downstream Responses status and agent references inspected, not just coordinator prose |
| A01 | L100 agent collaboration | One remote coordinator request retrieves Genie evidence, invokes both deployed specialists, and returns a grounded delivery brief and proposed owner/action checklist. | Verified working | [Lesson 16](16-connect-specialists.md); coordinator version 9 uses native Toolbox version 1. Three fresh remote reviews returned all four counts, 42.9%, seven correct recorded owners, positive overruns, and no P008 checklist row. Actual hosted references were MAF 3 and LangGraph 2. Earlier direct-agent OpenAPI trials were not reliable in the playground and are not the main path |
| A01R | Recording readiness | Three fresh current-version requests pass the business checks, including a successful intended-user playground rehearsal. | Verified working | On 2026-10-28, two API rehearsals and one Foundry playground rehearsal passed with coordinator 9 / Toolbox 1. Persisted playground conversation items confirm Genie reached COMPLETED before both actual hosted specialists (MAF 3 / LangGraph 2). Normal per-call approvals were used; no broad approval-policy change. Main-question baseline is ready for capture; video not recorded, optional follow-up and fresh-environment deployment not covered |
| A02 | L300 collaboration resilience | An injected specialist failure is surfaced explicitly without a success-shaped replacement answer. | Not tested | Separate from L100 completion; no failure injection performed |
| I01 | Identity and data permissions | Two differently scoped users receive the expected allowed and denied results; the principal at each hop is evidenced. | Not tested | None |
| J01 | Databricks Job action | An approved request starts one harmless job and monitors its terminal status; a rejected request starts none. | Not tested | None |
| O01 | Tracing | A test request can be followed across observable agent and tool boundaries; correlation gaps are recorded. | Not tested | [Lesson 13](13-connect-genie.md); response-level tool activity observed on 2026-10-27, but the UI explicitly states distributed traces are absent and Application Insights must be connected. Cross-service tracing and correlation remain untested |
| E01 | Evaluation and improvement | A baseline and a revised configuration run against the same benchmark, with measured results. | In progress | [Lesson 10](10-create-genie.md); one learner-supplied before/after forecast response shows qualitative improvement following focused instructions. Repeated, full-benchmark evaluation pending |
| R01 | User channel | A chosen channel invokes the deployed workflow; its authentication and consent behavior are tested independently. | Not tested | None |

## Status meanings

- **Not tested:** no experiment has been run.
- **In progress:** execution has begun, but the full success criterion has not
  yet been confirmed.
- **Documented but untested:** a current source supports the capability, but we
  have not demonstrated it.
- **Verified working:** the success criterion passed in the recorded environment.
- **Tested and failed:** an attempt failed; record the error and configuration.
  This does not establish that the capability is unsupported.
- **Blocked:** a prerequisite prevents a meaningful test; record what is missing.

If a current authoritative source explicitly excludes a configuration, record
that restriction with its source and date. Do not infer a product restriction
from a single failed experiment.

## Evidence required for a result

For each experiment, add a walkthrough containing:

- Date, region, relevant service settings, and runtime/package versions.
- Source links and the date they were checked.
- Prerequisites, exact steps, and sanitized configuration.
- Expected output, actual output, and pass/fail checks.
- Identity, permissions, and authentication method at each relevant hop.
- Sanitized errors, trace references, and known limitations.
- Cost considerations and cleanup steps.

Only link sanitized, shareable evidence from the published manual.
