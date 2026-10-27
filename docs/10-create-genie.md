# Lesson 10: put a curated Genie Agent over Gold

[Home](../README.md) | [Previous: Gold](09-build-gold.md) |
[Dataset contract and answer key](../data/README.md)

**Status:** in progress; Genie creation and the first two baseline answers are
learner-validated. Generated SQL was supplied for the first question only.
The forecast baseline has a correct main conclusion but unsupported details;
the learner-supplied post-instruction answer addresses those weaknesses.
The overdue-blocked detail answer is also learner-confirmed. Full-suite
validation under one consolidated configuration remains pending; the learner
chose to proceed to Foundry integration.
Official setup, tuning, and warehouse documentation reviewed on 2026-10-26.

**Learner checkpoint (2026-10-26):** the SQL Warehouses list was empty for the
learner's current user. The learner then reported successful creation of
`wh-foundry-genie-lab` following the small Serverless warehouse instructions.
The learner also confirmed that the Step 3 access query returned their signed-in
user and the expected counts: 8 projects, 4 teams, and 40 work items.
Warehouse creation and Gold query access are learner-validated. The learner
subsequently confirmed creating Genie after selecting the three Gold views.
The learner then supplied the first baseline's generated SQL and reported the
expected answer: 21 open work items, of which 9 are overdue. A later configuration
screenshot confirms the agent name **Project and Team Performance Analytics**
and warehouse `wh-foundry-genie-lab` in **Configure > About**.

**Goal:** ask natural-language questions over the validated Gold views, inspect
the generated SQL, and compare answers with known results.

**Start here:** open the Databricks workspace in your browser, not the Azure
portal. Use the same workspace where you ran the Gold notebook. Gold's
23-check stage is already learner-confirmed; you do not need to rerun it.

This tutorial checks each requirement as you go:

| Step | What you do | What it establishes |
| --- | --- | --- |
| 1 | Identify your signed-in user and open the SQL tools | Who is doing the setup; whether SQL authoring is available |
| 2 | Select or create a small SQL warehouse | Which SQL compute Genie will use |
| 3 | Run a read-only query against all three views | Whether your current user can actually query Gold on that warehouse |
| 4 | Open Genie, check feature availability, and create the agent | Whether native Genie setup is available |
| 5-7 | Add instructions, add an example, and ask questions | Whether Genie answers correctly |

Complete the steps in order. Report once at the end, unless an error prevents
you continuing. No Foundry connection, service principal, access token, or MCP
preview is required yet.

## 1. Check your signed-in user and SQL access

### 1A. Identify the user

1. In the Databricks workspace, open your profile menu in the top bar.
2. Note the signed-in account, usually shown as your email address. If it is
   not shown in the menu, Step 3 will return the querying user's identity.
3. Use this same browser session for the remaining steps.

Here, **your identity** means this signed-in Databricks user. It does not mean
the fictional project owner in our CSVs, an Azure resource's managed identity,
or an agent we have not created yet.

### 1B. Check whether you can open the SQL tools

1. Find **SQL Warehouses** and **SQL Editor** in the workspace's left sidebar;
   expand the sidebar/SQL navigation if it is collapsed.
2. Open **SQL Editor** and look for the option to create a new query. You do not
   need to run anything yet.

**Expected:** you can reach SQL authoring, not just view shared dashboards.
This is a practical first check; merely seeing a menu does not prove compute
or data permissions. Step 3 checks those through execution.

If SQL authoring is unavailable, check the **Databricks SQL access**
entitlement. An entitlement is permission to use a workspace feature; it is
separate from permission to read a particular table.

**If you are a workspace admin, inspect it as follows:**

1. Open your profile menu > **Settings**.
2. Select **Identity and access**.
3. Next to **Users**, select **Manage**.
4. Select the user identified in Step 1A.
5. Find **Databricks SQL access** in the user's entitlement settings.
6. Check that it is enabled. An enabled, grayed-out inherited setting is not
   necessarily a problem; inspect its group source if needed.

If you cannot see these admin settings, you do not need to become an admin
to continue when SQL authoring already works. If it does not work, ask a
workspace admin to check **Databricks SQL access** for your user and enable it
only if approved.

**Do not assume that Azure subscription Owner or Databricks account admin is
the same as workspace admin, or that any of those labels proves data access.**

## 2. Select a small SQL warehouse

### 2A. Look for an existing warehouse

1. Open **SQL Warehouses** in the left sidebar.
2. If a warehouse is listed, open its name and inspect its type and size.
   For this lab, prefer an approved, small **Serverless** warehouse.
3. If you can open its **Permissions** dialog, inspect your user/group access.
   **CAN USE**, or an applicable permission that includes it such as
   **CAN MANAGE**, allows warehouse use. A stopped warehouse is not an error:
   a query can start it.
4. If permission details are not visible to you, do not guess from the fact
   that the warehouse appears in the list. Step 3 is the practical use test.
5. If there is a suitable approved warehouse, note its name and go to Step 3.
   Do not change a shared warehouse's settings.

### 2B. Create one only if needed

If there is no suitable warehouse, select **Create SQL warehouse** and use:

   | Setting | Lab choice |
   | --- | --- |
   | Name | `wh-foundry-genie-lab` |
   | Type | Serverless |
   | Size | Smallest offered size; 2X-Small if available |
   | Auto Stop | 5 minutes |
   | Minimum / maximum clusters | 1 / 1, where configurable |
   | Channel | Current/standard, not Preview |

Review cost-related settings before selecting **Create**. Do not accept a large
default size: the creation documentation lists X-Large as the default.
Create the warehouse only under the existing spending approval.

**Creating a warehouse starts it automatically and can incur charges.**
Auto Stop helps with idle time; it is not a hard spending cap. Genie queries
can restart a stopped warehouse.

**Expected:** you have a warehouse name to select in the SQL Editor. Notebook
Serverless compute is separate: successfully running the Gold notebook did not
by itself select or authorize a SQL warehouse for Genie.

If creation is unavailable and you have no usable warehouse, ask a workspace
admin for **CAN USE on a suitable pro/serverless SQL warehouse**. You do not
need permission to create arbitrary compute. Do not provision a second
workspace or classic cluster as a workaround.

## 3. Verify your identity can read the Gold views

This is how to check "identity access" without having to interpret every grant.
Run an actual read-only query as your user, on the warehouse Genie will use.

1. Open **SQL Editor** in the sidebar.
2. Create a new SQL query using the new-query action shown by your editor.
3. In the editor's warehouse/compute selector, choose the warehouse from Step 2.
   If it is stopped, allow it to start. Querying can incur charges.
4. Paste this entire query:

   ```sql
   SELECT current_user() AS querying_identity,
          'work_item_detail' AS view_name, COUNT(*) AS row_count
   FROM integration_lab.gold.work_item_detail
   UNION ALL
   SELECT current_user(), 'project_summary', COUNT(*)
   FROM integration_lab.gold.project_summary
   UNION ALL
   SELECT current_user(), 'team_summary', COUNT(*)
   FROM integration_lab.gold.team_summary
   ORDER BY view_name;
   ```

5. Select **Run** and wait for the query to finish.
6. Compare the result with this table:

   | querying_identity | view_name | row_count |
   | --- | --- | --- |
   | Your signed-in user | project_summary | 8 |
   | Your signed-in user | team_summary | 4 |
   | Your signed-in user | work_item_detail | 40 |

**Pass:** three result rows, the expected counts, and the intended user.
This confirms that this user can execute reads against these three views
on this warehouse now. No data or permissions were changed.

**Why there are several permissions:** Unity Catalog generally requires
`USE CATALOG` on `integration_lab`, `USE SCHEMA` on `integration_lab.gold`,
and `SELECT` on the views, whether granted directly, inherited, or through
ownership/groups. The query tests effective access, not just one visible
grant. Querying ordinary views does not automatically require granting the
reader direct access to every underlying Silver table.

### If the query fails

| What you see | What to do |
| --- | --- |
| Warehouse unavailable or permission denied on compute | Check that the intended warehouse is selected. Ask its administrator for CAN USE if needed. |
| Missing USE CATALOG, USE SCHEMA, or SELECT | Preserve the error and ask the catalog/view owner to check the named privilege for your user/group. Request access only to the lab catalog, Gold schema, and these three views as appropriate. |
| Catalog, schema, or view not found | In **Catalog**, expand `integration_lab > gold`. Check that you are in the correct workspace and that the three names match. Missing objects can also reflect restricted visibility; do not assume they were deleted. |
| View dependency/owner error | Ask the view owner to check the view's dependencies and their permissions; do not grant yourself broad Silver access as a shortcut. |
| Query succeeds but counts differ | Stop here and preserve the output. Reconcile with the Gold checkpoint before setting up Genie. Do not edit source data to force a match. |

If you need to inspect the data privileges visually, open **Catalog**, select
`integration_lab`, then the `gold` schema, then a view, and look at each
object's **Permissions** tab where available. Grants can come from groups,
inheritance, or ownership; the successful query remains the practical check.

Do not publish an unredacted `querying_identity` value in screenshots.
This test does not establish access for another user or a future Foundry agent.

## 4. Check Genie availability and create the curated agent

### 4A. Open Genie

Open **Genie Agents** in the sidebar. Older UI versions may call it **Genie**
or refer to a Genie Space. Look for **New**.

**Expected:** you can open the creation/data-selection experience. Simply seeing
the sidebar entry does not prove that AI features are enabled or queries work.
The question tests in Step 7 establish functional behavior.

If you receive a message about disabled AI features, inspect the following
settings if you hold the relevant admin role, or ask that administrator:

| Scope | Who can check | Where to inspect |
| --- | --- | --- |
| Databricks account | Account admin | [Account console](https://accounts.azuredatabricks.net) > **Settings > Feature enablement > Enable partner-powered AI features**; also inspect whether the account enforces the setting |
| This workspace | Workspace admin | Workspace profile menu > **Settings > Workspace admin > Advanced > Partner-powered AI features** |

For the documented Genie setup, check that partner-powered AI is allowed at
both applicable levels. A workspace setting cannot override an account policy
that is enforced. Do not change organizational AI processing, cross-geography,
or compliance settings simply to remove an error. If a setting is unavailable
or locked, preserve the message and request administrator review.

If Genie opens but **New** is unavailable, revisit the SQL entitlement in
Step 1 and preserve any explicit permission error. Do not assume every Genie
problem is caused by the AI feature setting.

### 4B. Create the agent

1. Select **New**.
2. In the data selector, expand `integration_lab`, then `gold`.
3. Select exactly these three views:

   ```text
   integration_lab.gold.work_item_detail
   integration_lab.gold.project_summary
   integration_lab.gold.team_summary
   ```

4. Select **Create**.
5. In **Configure > Settings**, name it **Project Delivery Lab**, choose the
   same SQL warehouse you successfully queried in Step 3 as its default, and
   save the settings using the action shown by your UI.
6. Use a description such as:

   ```text
   Explore synthetic project delivery, overdue work, blockers, and modeled
   effort budgets. Fixed dataset reference date: 2026-10-23.
   ```

This is a curated Genie Agent, not workspace-wide Genie One. Do not add Bronze,
Silver, audit tables, or the local answer key.

**Expected:** the agent opens with a chat area. Check its configured sources
contain just the three Gold views and that the warehouse name matches Step 3.
If a source is missing from the selector despite the successful read test,
preserve the UI message rather than changing permissions speculatively.

Genie Code may suggest descriptions or setup changes. Review suggestions;
accept only appropriate metadata/instruction changes. Do not ask it to
regenerate the dataset, rewrite the Gold views, or change permissions.

### 4C. Run an initial baseline question

Before adding the manual instructions in Step 5, test the agent's existing
context. This captures a starting point, not a context-free model test: Gold
already contains descriptions and computed business metrics, and Genie may
have suggested additional context.

1. Open **Configure > Settings** and confirm the agent's default warehouse is
   `wh-foundry-genie-lab`, the warehouse tested in Step 3. Select it and save if
   necessary.
2. Return to the Genie agent's chat area, not the Genie Code setup assistant.
3. Send this question, without including its expected answer:

   ```text
   Using the dataset snapshot as of 2026-10-23, how many work items are open,
   and how many of those are overdue?
   ```

4. Expect **21 open** and **9 overdue**. The fixed date matters: the dataset is
   a teaching snapshot, not live operational data.
5. Open the response's SQL/query details if available. Check both the returned
   data and the narrative. Reading precomputed counts from a summary view or
   aggregating the appropriate detail flags can both be correct; joining
   overlapping views and multiplying counts is not.
6. Preserve the question, answer, generated SQL where available, and any
   accepted setup suggestions. If SQL cannot be inspected, record that limit.

Do not mark this baseline passed until the learner reports the result. It
tests only this question, not the full smoke suite. After adding instructions,
use a fresh conversation to repeat it and compare the results; a correct
baseline does not by itself demonstrate a later improvement.

**Observed baseline (learner-provided, 2026-10-26): PASS.** The learner reported:
"As of 2026-10-23, there are 21 open work items, of which 9 are overdue (open and
past their due date)." The generated SQL supplied by the learner was:

```sql
SELECT
  COUNT(CASE WHEN is_open THEN 1 END) AS open_work_items,
  COUNT(CASE WHEN is_open AND is_overdue THEN 1 END)
    AS overdue_open_work_items
FROM integration_lab.gold.work_item_detail
WHERE as_of_date = '2026-10-23';
```

This uses the correct work-item grain and precomputed flags. A `CASE` without
an `ELSE` returns NULL when its condition is not true; `COUNT(expression)`
counts only non-NULL values. The date filter selects the intended snapshot,
and no join multiplies the rows. The reported answer matches the fixture.
This is learner-provided execution evidence, not an assistant-run cloud query.

**Second baseline question:** "Which projects are over their effort budget, and
by how much in EUR?" Expect P001: 2000; P003: 200; P005: 480. Inspect whether
Genie uses project-grain budget metrics without multiplying budgets across
work-item rows.

**Observed second answer (learner-confirmed, 2026-10-26): PASS.** The learner
confirmed that the answer matched those expected projects and variances.
The generated SQL was not supplied, so its view selection and aggregation
have not been independently inspected.

**Third baseline question:** "Can this dataset reliably predict when P001 will
finish? Explain what information is missing." Ask this in a fresh conversation
where possible. Expect an explanation that a single snapshot cannot support a
reliable completion forecast: remaining effort, capacity, and historical
progress are missing. A recorded target date is not a prediction. Preserve any
unsupported forecast rather than marking it correct because it sounds plausible.
**Observed third answer (learner-provided, 2026-10-26): PARTIAL, not a clean
pass.** Genie correctly stated that the dataset cannot reliably predict a finish
date and identified missing remaining effort, capacity, and progress history.
However, the supplied narrative also contained these errors or unsupported
claims:

- It called 2026-10-30 "7 days from today, 2026-10-26." That interval is 4 days;
  7 days is the interval from our fixed snapshot date, 2026-10-23.
- It described approximately 40 remaining hours using 16 + 32 + 8, which sums
  to 56. Those values are original estimates, not measured remaining effort.
- It claimed WI002 had been blocked since before its due date. There is no
  blocked-since field or status-transition history to establish that.
- It invoked a critical path without dependency data and suggested the target
  was unlikely to be met without a validated forecasting basis.
- It said both completed P001 items overran estimates by 60-70%. The latest
  WI001 values are 40 actual / 24 estimated hours (66.7% over), but WI005 is
  12 / 8 hours (50% over).

The arithmetic and item values were checked against the local fixture; no
generated SQL was supplied for this third answer. A correct refusal does not
make every supporting statement correct.

## 5. Paste the business instructions

### 5A. First, correct the observed baseline weaknesses

Before adding the complete business context, make a focused change so the
learner can see what is being tuned and why.

1. Open the agent's **Instructions** panel and **Text / General instructions**
   area through its configuration controls.
2. If other instructions already exist, preserve/review them rather than
   overwriting unrelated content. Record any accepted automatic suggestions.
3. Add this block and save/apply:

   ```text
   Treat this dataset as a fixed snapshot as of 2026-10-23, not today's date.
   State that reference date in time-sensitive answers.
   A target date is a plan, not a forecast. Do not predict a finish date or
   likelihood of meeting a target without supporting forecasting data.
   estimated_hours is the original estimate, not remaining effort.
   Do not treat estimated_hours minus actual_hours as measured remaining work.
   No blocked-since history, task dependencies, or capacity data are provided.
   Do not invent blocker durations or critical paths.
   Use SQL to calculate numeric totals, date intervals, and percentages.
   Separate observed facts from unknowns and qualitative risks.
   ```

4. Start a fresh conversation in the same agent and repeat the exact third
   baseline question. Do not paste the previous answer or expected corrections.
5. Check that the answer retains the correct limitation while removing the
   unsupported claims above. Inspect any generated SQL. If numeric calculations
   appear, check them against the returned data.

**Tuning result (learner-provided, 2026-10-26): improved on this repeat; the
forecast-limitation check passes at the answer level.** The supplied response:

- Consistently used the 2026-10-23 snapshot and correctly described the target
  as seven days after that snapshot.
- Distinguished original estimates from remaining effort, explicitly rejecting
  the inference that WI003 has only four hours left.
- Identified missing blocked-since history and dependency data instead of
  inventing blocker durations or a critical path.
- Did not give a predicted finish date or measured likelihood of hitting the
  target. It labeled status-based concerns as qualitative risks.
- Reported P001's known status and EUR 2000 budget variance consistently with
  the fixture, without repeating the earlier incorrect overrun percentages.

The phrase "hitting it is already in doubt" is a qualitative risk interpretation,
not a calibrated forecast. It should not be presented as a measured probability.
The learner supplied the narrative, not this run's generated SQL or source
details. One before/after answer is useful evidence, not proof of reproducible
improvement or guaranteed accuracy.

**Observed detail test (learner-confirmed, 2026-10-26): PASS at the answer
level.** After the focused instruction change, the learner asked the overdue-
blocked item question from Step 7 and confirmed the expected five items:
WI002, WI012, WI018, WI022, and WI028, with the requested detail fields.
Generated SQL was not supplied for inspection.

**Progression decision:** the learner chose to move on to Foundry integration.
Do not record the full five-question suite as passed: the team-total question,
complete instruction consolidation, and SQL-example setup have not been
confirmed. Keep those remaining steps below for later completion. The tests
so far span the baseline and focused-instruction configurations, not a single
fully evaluated configuration.

### 5B. Consolidate the complete business context

After the focused correction is tested, consolidate its rules with the complete
context below. Replace the focused block with this complete block rather than
keeping duplicate copies; preserve any unrelated existing instructions.

1. In the agent, open its configuration area and **Instructions** panel.
2. Select the **Text / General instructions** area.
3. Paste only the following block, not the later answer-key table.
4. Save/apply using the UI's action.

```text
You answer questions about a synthetic project-delivery dataset.
Query the configured Gold views for facts; do not invent missing values.

Reference date:
- All views describe a fixed snapshot as of 2026-10-23.
- Interpret "today", overdue, and current workload relative to as_of_date,
  not the real current date. State the reference date in time-sensitive answers.

Choose the correct grain:
- work_item_detail has one row per valid latest work item. Use it for item
  lists, assignees, blocker reasons, dates, and item-status questions.
- project_summary has one row per project. Use it for project counts,
  budgets, over-budget projects, and project-level workload.
- team_summary has one row per team. Use it for team-level totals.
- These views describe the same underlying work at different grains.
  Never UNION their metrics or add their totals together.
- Prefer one view that answers the question. If a join is necessary, respect
  the keys and grain; never sum repeated project budgets after joining items.

Definitions:
- Open items have status todo, in_progress, or blocked.
- Use is_open, is_overdue, is_blocked, and is_unassigned_open in detail.
- Due on as_of_date is not overdue. Done and cancelled items are not open.
- In summary views, sum the named *_work_items columns for item counts;
  counting summary rows counts projects or teams, not work items.
- effort_cost_eur is logged actual_hours times the owning team's hourly rate.
  It includes logged effort on cancelled work. It is not invoice spend or an
  Azure bill. All monetary amounts are EUR.
- budget_variance_eur is effort cost minus budget. Positive means over budget.
- Use is_over_budget in project_summary or over_budget_projects in team_summary.
- A team under its total budget can still contain over-budget projects.

Boundaries:
- Business region and fictional owner handles do not define access rights.
  Do not claim a permission test succeeded from these labels.
- Report recorded blocker reasons as reported evidence, not proven root causes.
- This snapshot lacks historical trends, remaining effort, and team capacity.
  Say when the data cannot support a forecast or causal conclusion.
- A target date is a plan, not a forecast. Do not predict a finish date or
  likelihood of meeting a target without supporting forecasting data.
- estimated_hours is the original estimate, not remaining effort. Do not treat
  estimated_hours minus actual_hours as measured remaining work.
- No blocked-since history or task dependency data are provided. Do not invent
  blocker durations or critical paths.
- Use SQL to calculate numeric totals, date intervals, and percentages.
  Separate observed facts from unknowns and qualitative risks.
- Do not claim to create tickets, trigger jobs, or change data; this stage
  only queries the configured dataset.
```

These instructions contain definitions, not the expected benchmark answers.
They guide generation; they are not a security boundary.

## 6. Add one SQL example

1. In the **Instructions** area, open the SQL examples/query section.
2. Use its add-example action.
3. Enter the question below as the example question/title and paste the SQL
   into its query field.
4. Save the example.

**Question:** List completed projects with their owners.

```sql
SELECT project_id, project_name, project_owner_handle
FROM integration_lab.gold.project_summary
WHERE status = 'completed'
ORDER BY project_id;
```

Review any automatically suggested queries before accepting them. Do not mark
an unexecuted example as verified or trusted. Adding one example is not proof
that other generated SQL is correct.

## 7. Run the smoke test

1. Return to the agent's chat area.
2. Copy the first question below into the message box and send it. Do not paste
   its expected result.
3. Wait for the response, then compare its values with the expected result.
4. Open the response's SQL/query details using the action shown by your UI.
   Check that it reads a configured Gold view and the query result agrees with
   the answer. If you cannot find the SQL, report that as uninspected rather
   than marking SQL validation complete.
5. Repeat for the remaining questions. Use independent new conversations where
   the UI permits, so one answer does not supply numeric answers to another.

| # | Question | Expected result |
| --- | --- | --- |
| 1 | As of the dataset reference date, how many work items are open and how many of those are overdue? | 21 open; 9 overdue |
| 2 | Which projects are over their effort budget, and by how much in EUR? | P001: 2000; P003: 200; P005: 480 |
| 3 | Show each team's total effort cost and total project budget in EUR. | T01: 10400 / 10000; T02: 12200 / 13000; T03: 10800 / 16000; T04: 3150 / 4500 |
| 4 | List the overdue blocked work items with their recorded blocker reason and project owner. | Exactly WI002, WI012, WI018, WI022, WI028; reasons/owners must match the detail view |
| 5 | Can this dataset reliably predict when P001 will finish? Explain what information is missing. | Acknowledge insufficient forecasting evidence; no unsupported forecast, blocker duration, or remaining-effort claim; consistent reference date and correct arithmetic |

For questions 1-4, the generated query should use the appropriate Gold view and
must not multiply metrics across grains. Question 5 may be answered from the
dataset's documented limitations without executing a query.

Record the answer, generated SQL where present, and any error or mismatch. A
convincing narrative with incorrect SQL/results is not a pass. These are
deterministic smoke checks for our curated demo, not proof of general accuracy
or an independent held-out evaluation.

## Stage checkpoint

For the first baseline, confirm the agent exists and selected checks pass,
including the fixed-snapshot open/overdue count. Record exactly which checks
were run, their SQL where available, and any failures. A full **5/5** pass
is a useful later checkpoint, not a gate to trying the Foundry integration.
Do not label the full suite passed when only selected questions were tested.
No repeated per-question chat confirmation is needed.

This establishes the native Databricks experience only. It does not verify
Foundry integration, identity passthrough, access for a second user, or actions.

Compute access and data access differ: current documentation describes warehouse
access through the configured author's compute credentials while evaluating
data permissions for the end user. Do not describe that as each user needing
the same direct warehouse permissions.

## Cost, sharing, and cleanup

Keep the agent private to the lab's approved audience for now. Do not share
broadly or add service principals until the permissions lesson. Stop a dedicated
lab warehouse after testing if no one is using it, or allow its configured
auto-stop; do not stop a shared warehouse without authorization.

Keep the agent and views for the Foundry connector stage. Preserve sanitized
evidence, not tokens, consent URLs, or personal account details.

## Official references

Continue the integration path with [Lesson 11: prepare a Foundry project](11-create-foundry-project.md).

- [Create and manage a Genie Agent](https://learn.microsoft.com/azure/databricks/genie-agents/set-up)
- [Tune quality: instructions and SQL examples](https://learn.microsoft.com/azure/databricks/genie-agents/tune-quality)
- [Create and configure a SQL warehouse](https://learn.microsoft.com/azure/databricks/compute/sql-warehouse/create)
- [Manage entitlements: workspace admin steps](https://learn.microsoft.com/azure/databricks/security/auth/entitlements)
- [Partner-powered AI: account and workspace settings](https://learn.microsoft.com/azure/databricks/databricks-ai/partner-powered)
