---
layout: default
title: osgi — consistency report
nav_exclude: true
---

# Consistency Report: osgi (osgi/osgi)

Extraction 2026-08-10, commit `8c7184da`. Compared against
`docs/languages/osgi/index.md` and `.github/skills/osgi/instructions.md`.

## Conflicts

**None.** Zero conflicts awaiting user decision. Checks performed:

| # | Guidance statement | Repo observation | Verdict |
|---|---|---|---|
| 1 | `-buildpath` uses BSN, not Maven GAV | Confirmed: `org.osgi.service.event;version=latest`, `org.osgi.test.support;version=project` | Consistent |
| 2 | Framework API via `osgi.core;maven-scope=provided`, fallback `org.eclipse.osgi` | Repo uses `org.osgi.framework;maven-scope=provided;version=1.8` — it *builds* the framework API from source, an option only available inside the spec repo itself | No conflict — different context; consumer guidance unaffected |
| 3 | `-runfw: org.eclipse.osgi` recommended | Repo runs `-runfw = org.osgi.impl.framework; version=latest` (its own RI — the point of a TCK) | No conflict — repo-specific necessity, not a general practice |
| 4 | `Export-Package` and `Private-Package` mutually exclusive per package | Confirmed: TCK exports `${p}.service`, keeps `${p}.junit` private — disjoint packages | Consistent |
| 5 | bnd version 7.x | Repo pins bnd Gradle plugin 7.1.0 | Consistent |

## Verification checklist

| Check | Result | Detail |
|---|---|---|
| Schema | PASS | All 6 `.json` files parse; required provenance/pattern/implementation/template fields present |
| Links | PASS | Layer files + index cross-links exist; 10 permalinks commit-pinned to `8c7184dad43779668052afe5b29a2a201e527b52` |
| Completeness | PASS | All 5 layers present; 6/6 patterns have ≥1 canonical (exactly 1 primary each); 10/10 canonicals map to patterns; 6/6 templates map to patterns; provenance complete |
| Graph | PASS | `graph.json` parses (29331 nodes); smoke query `explain OSGiTestCase` returned node + 161 connections, confirming excerpt line anchor L42 |
| Conflict state | PASS | Zero conflicts in `Awaiting User Decision` before docs edits |
| Build (optional) | SKIPPED | `./gradlew :build` not run — multi-hour TCK build; out of scope for extraction |

## Notes

- Source analyzed in place (local checkout, clean tree); `graphify-out/` moved out
  and removed — source repo left untouched (verified `git status` empty).
- graphify extraction warned about 16 files with syntax errors (gradle DSL, C sources,
  JS) — expected for non-Java assets; Java coverage unaffected.
