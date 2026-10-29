# Agent Framework delivery-risk analyst

This portable source is adapted from Microsoft's basic hosted Responses
sample. See [third-party notices](../../THIRD-PARTY-NOTICES.md).

It explains overdue/blocked work and effort-budget attention signals from
facts supplied in a request. It has no Databricks or Genie tools and does
not produce the owner's action checklist. Percentage calculation and format are model
instructions, not a deterministic calculation tool or an enforced schema.

Follow [Lesson 10](../../docs/10-host-agent-framework.md) to configure an
existing Foundry project and model, review a deployment preview, deploy
with remote dependency build, and run the smoke test.

Both the original supplied-facts summary and the delivery-risk role passed
hosted smoke tests. Portable-source version 3 also completed native coordinator
handoffs. A fresh-clone/new-environment deployment remains unverified.
Dependency versions are not fully locked in this edition.
The cloud builder uses the included [requirements.txt](requirements.txt).
Keep it aligned with [pyproject.toml](pyproject.toml); the contributor tests
check dependency parity.

Do not commit a populated `.env` or `.azure` directory. They are local
configuration, not part of this source distribution.
