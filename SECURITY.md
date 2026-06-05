# Security Policy

## Reporting a Vulnerability

LanGuard runs un-sandboxed and toggles network interfaces, so security reports are taken
seriously. Please **do not** open a public issue for security problems.

Instead, use GitHub's private vulnerability reporting
(**Security → Report a vulnerability**) or email **roypadina@gmail.com**.

You'll get an acknowledgement within a few days. Once a fix is available it will be released
and the report disclosed, with credit unless you prefer otherwise.

## Scope

LanGuard requests no special privileges, runs entirely on-device, and makes no network
connections of its own. Relevant areas: Wi-Fi power control (CoreWLAN), login-item
registration (SMAppService), and removal of the legacy LaunchAgent.
