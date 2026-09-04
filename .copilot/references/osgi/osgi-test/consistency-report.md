---
layout: default
title: Consistency Report
nav_exclude: true
---

# Consistency Report — osgi-test extraction

Extraction commit `696b03cd` · refreshed 2026-08-10 (graph layer added) · initial 2026-08-09

## Conflicts

### C1 — buildpath framework API guidance

| Aspect | Detail |
|---|---|
| Existing text | ".github/skills/osgi/instructions.md — Common Pitfalls: 'Need `org.eclipse.osgi` on `-buildpath` for `org.osgi.framework` (BundleContext)'" |
| Repo evidence | Example test project buildpath uses `osgi.core;version=8.0.0;maven-scope=provided` for framework API (examples/osgi-test-example-bndworkspace/org.osgi.test.example.player.test/bnd.bnd L12); `org.eclipse.osgi` appears only as `-runfw`, never on buildpath |
| Issue | Existing guidance recommends a concrete framework implementation on the buildpath; upstream reference compiles against the pure `osgi.core` API JAR (provided scope) and uses the framework only at runtime — cleaner API/implementation separation consistent with principles.md "Depend on API, not implementation" |
| Option A | Adopt repo practice: recommend `osgi.core;maven-scope=provided` on `-buildpath` for framework API; keep `org.eclipse.osgi` only as `-runfw`. Note `org.eclipse.osgi` on buildpath as fallback when `osgi.core` unavailable in repo set |
| Option B | Keep existing text unchanged (workspace-specific repos may lack `osgi.core`) |
| Recommended | **Option A** — aligns with reference implementation and existing design principles |
| Status | Resolved: Option A (user decision 2026-08-09) — pitfall guidance updated in .github/skills/osgi/instructions.md |

## Verification

| Check | Result | Notes |
|---|---|---|
| Schema | PASS | 5 JSON files parse; required fields present |
| Links | PASS | Internal links resolve; permalinks commit-pinned to `696b03cd` |
| Completeness | PASS | 5 layers present (graph added 2026-08-10); 6 patterns each ≥1 canonical (9 total, 6 primary); 4 templates map to patterns; provenance complete |
| Graph | PASS | graph.json parses (3723 nodes, 11071 edges, 245 communities); smoke query "service injection" returned 77 nodes; god node `ServiceAware` confirms canonical selection |
| Conflict state | PASS | C1 resolved (Option A); refresh surfaced no new conflicts — surprise edges consistent with known patterns and flagged gaps |
| Build/test (optional) | SKIPPED | Full maven reactor build too heavy for extraction pass |
