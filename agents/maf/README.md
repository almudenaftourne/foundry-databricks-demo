# Agent Framework project-summary specialist

This portable source is adapted from Microsoft's basic hosted Responses
sample. See [third-party notices](../../THIRD-PARTY-NOTICES.md).

It summarizes facts supplied in a request; it has no Databricks or Genie
tools. Percentage calculation and the four-bullet format are model
instructions, not a deterministic calculation tool or an enforced schema.

Follow [Lesson 14](../../docs/14-host-agent-framework.md) to configure an
existing Foundry project and model, review a deployment preview, deploy
with remote dependency build, and run the smoke test.

The original lab's hosted agent passed that test. This cleaned, portable
manifest has been statically checked; deploying it from a fresh clone has
not yet been verified. Do not confuse a source publication with a new
deployment. Dependency versions are not fully locked in this first edition.

Do not commit a populated `.env` or `.azure` directory. They are local
configuration, not part of this source distribution.
