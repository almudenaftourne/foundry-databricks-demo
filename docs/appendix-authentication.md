# Annex A: authentication and access troubleshooting

[Home](../README.md) | [Genie integration](13-connect-genie.md) |
[Hosted specialist](14-host-agent-framework.md)

The main tutorial assumes an approved organizational identity and correctly
configured access. This annex covers issues that can occur; it is not a
mandatory sequence of workarounds. The lab encountered some of these issues,
but that does not make them universal product limitations.
They have not been established as exclusive to internal users.
Normal sign-in, same-tenant requirements, consent, and required access remain
in the main tutorial.

No actual user names, account addresses, tenant/subscription IDs, workspace
hosts, OAuth credentials, or raw authentication screenshots are included here.

## 1. Distinguish the permission systems

| Layer | What it controls |
| --- | --- |
| Azure resource RBAC | Resource visibility, provisioning, and authorized role assignment |
| Foundry roles | Project development, model/tool use, and hosted-agent deployment |
| Entra directory roles | Tenant administration, not automatic data access |
| Databricks account roles | Account-wide administration, such as custom OAuth app registration |
| Databricks workspace roles | Workspace administration and membership |
| Unity Catalog privileges | Access to governed data objects |
| Genie and warehouse permissions | Access to the curated analytics experience and its compute |

Azure Owner is not a substitute for every data-plane role. Databricks
workspace admin does not automatically grant SELECT on an unrelated catalog.
Do not grant subscription Owner or Global Administrator to fix an unexplained
access error.

## 2. Confirm identity before changing roles

1. Check the Azure/Foundry account and tenant.
2. Check the Databricks profile.
3. In a new SQL query, verify effective SQL identity:

   ```sql
   SELECT current_user();
   ```

4. Confirm it is the intended user before granting access or claiming a
   permission test passed.

Browser profile text and effective SQL identity disagreed during one lab
attempt. Relaunching the workspace through Azure with the intended user
restored the expected SQL identity. The precise cause was not established.
If the mismatch persists, investigate query execution context and identity
mapping rather than granting more access.

Edge InPrivate windows share their InPrivate session; two such windows do not
isolate two identities. Use genuinely separate browser profiles where needed.

## 3. Personal accounts, guests, and tenant selection

An `.onmicrosoft.com` domain is a normal Entra tenant domain. It does not imply
ownership by a particular employer. A `#EXT#` principal is an external identity
representation, not a separate mailbox or password. Member/Guest type and
authentication provider are different properties.

Inspect the user's **Identities / Sign-in identifiers** to distinguish
MicrosoftAccount, another Entra directory, or another provider. A personal
Microsoft account can use a non-Microsoft email address as its sign-in name.

One personal-account sign-in flow in this lab failed in an unexpected tenant
context; a directory-native lab identity later completed Managed OAuth.
That observation does not establish a general ban on personal accounts or
prove that every guest scenario will fail. Do not prescribe a new tenant or
subscription transfer as the first fix.

If a new lab identity is explicitly approved, it needs its own resource,
workspace, data, and Foundry access. Creating the user does not inherit the
original user's permissions. Never use an unrecognized account, reset its
password, or change its roles simply because its name sounds administrative.

## 4. A new user cannot open the workspace

Azure Reader grants resource visibility, not Databricks workspace membership.
An authorized workspace admin can use:

**Settings > Identity and access > Users > Manage > Add user**

Add the intended identity, selecting **Add new** if appropriate and supported.
Keep an ordinary learner out of the workspace `admins` group unless its
administrative task specifically requires that role. A privileged lab
operator is not evidence of least-privilege end-user behavior.

## 5. Genie warns about missing SELECT

An authorized object owner/grantor can run the following, substituting the
intended principal. Run it from the grantor's verified SQL session:

```sql
GRANT USE CATALOG ON CATALOG integration_lab TO `<lab-user-or-group>`;
GRANT USE SCHEMA ON SCHEMA integration_lab.gold TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.work_item_detail TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.project_summary TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.team_summary TO `<lab-user-or-group>`;
```

`USE CATALOG` / `USE SCHEMA` do not grant SELECT on every child object.
`ON TABLE` is also used for the view privileges shown here.
Do not grant ALL PRIVILEGES, schema-wide SELECT, or ownership merely to
remove the warning. Warehouse or Genie sharing errors are separate checks.

If the grant fails because the executing principal lacks MANAGE, verify
the grantor and object ownership. Do not accept an editor suggestion to
grant catalog MANAGE to the target reader.

## 6. Foundry access or deployment role is missing

- For coordinator development, inspect the documented **Foundry User**
  assignments and project-identity requirements.
- For hosted deployment, inspect **Foundry Project Manager** at the
  intended project scope.
- An authorized role-assignment administrator makes changes; allow for
  propagation, then refresh the intended user's session.
- Record the exact error, principal, and scope privately. Do not switch to
  shared keys or grant broader roles without a grounded requirement.

## 7. CLI sign-in differs from portal sign-in

`az` and `azd` have separate authentication sessions:

```powershell
az login
azd auth login
azd auth login --check-status
```

If browser account selection is ambiguous, a supported explicit-tenant
device-code flow is:

```powershell
azd auth login --tenant-id '<your-lab-tenant-id>' --use-device-code
```

Complete it yourself, with the intended identity. Never share the device
code or authentication URL. Successful authentication does not establish
deployment permissions.

## 8. Consent warnings and repeated approval

Verify connection ownership, initiating project, target endpoint, and
requested access before accepting a cross-organization warning.
The warning observed in the lab was not independently explained.
Do not dismiss a warning because a familiar service name appears.

Connection consent is different from tool-call approval. Query and polling
tools can each require approval. Approve once applies to a call, not a
whole user question. Review narrowly scoped standing approvals only after
the tools are understood; their persistence was not verified in this lab.

## 9. Account console and Custom OAuth

Account administration is not required to register your own application
when the Managed OAuth option is available and used.
Workspace access, account-console access, and account-admin status are
different checks. A redirect to a workspace does not prove account admin.

Custom OAuth is the alternative described in the current
[Databricks integration guide](https://learn.microsoft.com/azure/databricks/integrations/microsoft-foundry).
It is a normal setup path where Managed OAuth is unavailable or not appropriate,
not an authentication-error workaround:

1. Have an authorized Databricks account administrator
   [register the OAuth application](https://learn.microsoft.com/azure/databricks/integrations/enable-disable-oauth#enable-custom-app-ui).
2. Use the exact callback supplied by Foundry and the required scopes; do not
   guess callbacks or create dummy credentials.
3. In the Foundry Genie connector's Custom OAuth form, supply the application
   client ID, secret if applicable, and authorization/token/refresh URLs from
   the approved registration and provider documentation.
4. Store credentials only in the approved connection/secret store, not source.
5. Connect it, then return to [Lesson 13](13-connect-genie.md) for normal user
   consent, tool approval, and an actual benchmark call.

Initial Databricks account-admin bootstrap has separate documented Entra
administrator requirements. Do not automatically grant those roles to the
demo user. The lab's Custom OAuth path was not completed.

## References

- [Foundry RBAC](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry)
- [Hosted-agent permissions](https://learn.microsoft.com/azure/foundry/agents/concepts/hosted-agent-permissions)
- [Databricks users](https://learn.microsoft.com/azure/databricks/admin/users-groups/users)
- [Unity Catalog privileges](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/manage-privileges/)
- [Account console and first account admin](https://learn.microsoft.com/azure/databricks/admin/admin-concepts)
- [External identity properties](https://learn.microsoft.com/entra/external-id/user-properties)
- [Foundry MCP authentication](https://learn.microsoft.com/azure/foundry/agents/how-to/mcp-authentication)
