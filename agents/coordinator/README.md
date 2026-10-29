# Delivery-review coordinator

This is a Foundry **prompt agent**, not another hosted Python service.
It retains its Genie MCP connection and uses a native Foundry Toolbox MCP
endpoint to invoke two hosted specialists through one OpenAPI definition.
The toolbox is not another agent. There is no custom proxy or local application.

- [Instructions](instructions.txt): evidence retrieval, specialist routing, and
  the concise brief/checklist.
- [OpenAPI template](specialists.openapi.json): two non-streaming operations
  inside the toolbox, using the same agent names as the hosted manifests.
- [Lesson 12](../../docs/12-connect-specialists.md): configure the real endpoint,
  project-managed-identity connection, permissions, and coordinator.

The template's server is deliberately nonfunctional. Replace it in your private
tool configuration with your existing Foundry project endpoint. If you rename
the hosted agents, update the corresponding OpenAPI paths.

Tested versions: coordinator 9, Agent Framework 3, LangGraph 2, and Toolbox 1.
Test again after changing instructions, tools, or models.
