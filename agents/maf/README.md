# Agent Framework delivery-risk analyst

This portable source is adapted from Microsoft's basic hosted Responses
sample. See [third-party notices](../../THIRD-PARTY-NOTICES.md).

It explains overdue/blocked work and effort-budget attention signals from
facts supplied in a request. It has no Databricks or Genie tools and does
not produce the owner's action checklist. Percentage calculation and format are model
instructions, not a deterministic calculation tool or an enforced schema.

Follow [Lesson 14](../../docs/14-host-agent-framework.md) to configure an
existing Foundry project and model, review a deployment preview, deploy
with remote dependency build, and run the smoke test.

The original supplied-facts summary passed a hosted smoke test. The risk-analyst
instructions were added for the L100 business workflow and have **not** yet been
remotely tested. Deploying the portable layout from a fresh clone also remains
unverified. Dependency versions are not fully locked in this edition.

Do not commit a populated `.env` or `.azure` directory. They are local
configuration, not part of this source distribution.
