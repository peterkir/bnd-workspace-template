---
name: system-analysis
description: >
  Load workspace context at session start. Instructs Copilot to read
  workspace-context.md and apply detected environment, tools, and project facts
  to every response in this session.
---

## System Analysis — Session Context Loader

At the start of every session, read the file `.copilot/workspace-context.md`
(or the configured write target) and internalize its contents.

Apply the following from that file for the duration of the session:

- **OS / Platform**: adapt shell commands, paths, and line endings accordingly
- **Tools**: use detected tool versions and binary paths for all command suggestions
- **Languages**: treat detected languages as the primary stack; apply their instruction files
- **Persisted paths**: substitute `$VAR` references with their recorded values when relevant
- **Git remote**: use repo name and remote URL when generating commit messages, PR descriptions, or issue references

If `workspace-context.md` is missing or empty, note this once and proceed
without blocking. Suggest re-running setup:

```
curl -fsSL https://raw.githubusercontent.com/peterkir/ki/main/setup.sh | bash -s -- --reconfigure
```
