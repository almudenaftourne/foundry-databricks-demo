# Annex A: authentication and access troubleshooting

[Home](../README.md) | [Genie connection](09-connect-genie.md) |
[Hosted specialist](10-host-agent-framework.md)

The main tutorial assumes an approved organizational identity and normal
sign-in. Use this annex only if something goes wrong. These issues occurred in
the lab; they are not universal product limitations. No real account names,
tenant IDs, hosts, or credentials are included.

## 1. Which permission system is involved?

| Layer | Controls |
| --- | --- |
| Azure RBAC | Resource visibility, provisioning, role assignment |
| Foundry roles | Project development, tool use, hosted-agent deployment |
| Databricks account/workspace roles | Account administration, workspace membership |
| Unity Catalog privileges | Access to governed data objects |
| Genie and warehouse permissions | Access to Genie and its compute |

Azure Owner does not grant data access, and workspace admin does not grant
SELECT on an unrelated catalog. Do not grant Owner or Global Administrator to
fix an unexplained error.

## 2. Confirm identity before changing roles

Check the Azure/Foundry tenant, the Databricks profile, and the effective SQL
identity (`SELECT current_user();`). If the profile and SQL identity disagree,
relaunch the workspace from the Azure portal with the intended user rather than
granting more access. InPrivate windows share one session; use separate browser
profiles to isolate identities.

## 3. Personal accounts, guests, and tenant selection

An `.onmicrosoft.com` domain is a normal Entra tenant domain, and a `#EXT#`
principal is an external-identity representation. In the lab, a personal-account
sign-in failed with an unexpected tenant context, while a directory-native lab
identity completed Managed OAuth. That does not prove every personal or guest
account fails. Use an approved identity in the same tenant as the Foundry project;
a new identity needs its own resource, workspace, data, and Foundry access.

## 4. A new user cannot open the workspace

Azure Reader gives resource visibility, not Databricks membership. A workspace
admin can add the user under **Settings > Identity and access > Users**. Do not
add ordinary learners to the `admins` group.

## 5. Genie warns about missing SELECT

An authorized grantor can run, with the intended principal:

```sql
GRANT USE CATALOG ON CATALOG integration_lab TO `<lab-user-or-group>`;
GRANT USE SCHEMA ON SCHEMA integration_lab.gold TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.work_item_detail TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.project_summary TO `<lab-user-or-group>`;
GRANT SELECT ON TABLE integration_lab.gold.team_summary TO `<lab-user-or-group>`;
```

Do not grant ALL PRIVILEGES, schema-wide SELECT, ownership, or catalog MANAGE
just to remove the warning.

## 6. Foundry role is missing

Coordinator development needs **Foundry User**; hosted deployment needs
**Foundry Project Manager** at project scope. An authorized administrator
assigns them; allow time to propagate and refresh the session. Do not switch to
shared keys or grant broader roles without a grounded need.

## 7. CLI sign-in differs from portal sign-in

`az` and `azd` have separate sessions:

```powershell
az login
azd auth login
azd auth login --check-status
```

If account selection is ambiguous, use
`azd auth login --tenant-id '<your-lab-tenant-id>' --use-device-code` yourself,
and never share the device code or URL.

## 8. Consent warnings and repeated approvals

Before accepting a cross-organization warning, verify the connection owner,
initiating project, target endpoint, and requested access. Connection consent is
separate from tool-call approval: query and polling tools can each ask, and
"Approve once" covers one call, not the whole question.

## 9. Custom OAuth (alternative to Managed OAuth)

Custom OAuth is a normal setup where Managed OAuth is unavailable, not an
error workaround. A Databricks account administrator
[registers the OAuth application](https://learn.microsoft.com/azure/databricks/integrations/enable-disable-oauth#enable-custom-app-ui)
using the exact callback shown by Foundry. Enter the client ID, secret if
applicable, and endpoints in the Genie connector's Custom OAuth form, store
credentials only in the approved secret store, then return to
[Lesson 09](09-connect-genie.md) for consent and the benchmark. Do not guess
callbacks or create dummy credentials. The lab did not complete this path.

## References

[Foundry RBAC](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry) ·
[Hosted-agent permissions](https://learn.microsoft.com/azure/foundry/agents/concepts/hosted-agent-permissions) ·
[Unity Catalog privileges](https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/manage-privileges/) ·
[Databricks users](https://learn.microsoft.com/azure/databricks/admin/users-groups/users)
