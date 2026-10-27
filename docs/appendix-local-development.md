# Annex B: optional local development

[Home](../README.md) | [Hosted specialist](14-host-agent-framework.md)

Local debugging is optional for the first hosted baseline. The main path
uses the supported Foundry remote-build workflow. Do not confuse a failed
local package download with failure of hosted-agent support.

## Prepare Python dependencies

In the portable specialist directory, with Python 3.13 installed:

```powershell
py -3.13 -m venv .venv
& '.\.venv\Scripts\Activate.ps1'
python -m pip install uv
```

Use the current supported local-run flow for the chosen template/tool
version. A template with `uv.lock` requires uv for synchronization.
Do not remove the lockfile or add packages globally to conceal missing
tooling. If activation is blocked, use your approved device configuration;
do not change machine-wide execution policy indiscriminately.

## Package-download TLS failures

The original lab could reach `pypi.org`, but downloads from
`files.pythonhosted.org` failed with TLS handshake errors in uv, Windows curl,
and Python. Local dependency installation did not complete.

This evidence does not establish the exact network/security cause or prove
the dependencies are prohibited. Use approved proxy, certificate, or package
repository configuration where available. Do not disable certificate
verification, organizational controls, or use unapproved mirrors.

The lab's supported alternative was to upload source and let Foundry build
and run it in Azure; the remote smoke test succeeded. Cloud builds and
dependencies still need to comply with organizational policy. An established
dependency prohibition is not resolved by moving installation elsewhere.

## Local server versus deployed agent

`azd ai agent run --no-client` starts a local server; it does not prove hosted
deployment. A local server can still call the real Foundry model and incur
inference charges. Stop local processes you started after testing and do not
run two servers on the same port.

The first edition does not include machine-specific VS Code debug settings,
absolute filesystem paths, local environments, or session logs. Use the
specialist's own virtual environment when preparing local debugging.

## Service-name errors

`azd deploy` selects the service key under `services:` in `azure.yaml`, not
necessarily the remote agent's name. In the portable public layout:

```powershell
azd deploy maf-specialist
```

Inspect your actual manifest rather than rerunning initialization when a
service name is misspelled.

## References

- [Prepare the development environment](https://learn.microsoft.com/azure/foundry/how-to/develop/install-cli-sdk)
- [Hosted-agent source-code deployment](https://learn.microsoft.com/azure/foundry/agents/how-to/deploy-hosted-agent-code)
