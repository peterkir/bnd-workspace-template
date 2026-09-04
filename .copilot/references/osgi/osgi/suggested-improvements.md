---
layout: default
title: osgi — suggested improvements
nav_exclude: true
---

# Suggested Improvements (inferred — not observed facts)

For the **ki** docs/instructions, derived from osgi/osgi observations:

1. **Include-layer composition**: `.github/skills/osgi/instructions.md` shows a
   monolithic `bnd.bnd`. For multi-project workspaces, the osgi/osgi
   `-include: ${includes}/<layer>.bnd` composition keeps project files under 30
   lines — worth adding as a scaling practice.
2. **Package-level semantic versioning**: instructions cover bundle metadata but not
   `package-info.java` + `@Version` + consumer/provider import ranges — the OSGi-native
   API evolution mechanism.
3. **Reproducible-build flags**: `-reproducible: true`, `-noextraheaders: true`,
   `-diffignore: Bundle-Version` are compact, high-value defaults for any bnd workspace.

For the **reference storage** itself:

4. **graph.json size**: 65 MB (29k nodes) — near GitHub's 50 MB soft limit.
   *Resolved 2026-08-10*: tracked via Git LFS (`docs/languages/**/15-graph/graph.json`
   in `.gitattributes`). Excluding `licensed/` JS assets from extraction remains an
   option to shrink the graph itself (they contribute noise, e.g. the fop.js
   surprise edge).
5. **LLM community labeling**: 905 communities are unlabeled (`Community N`
   placeholders). An opt-in `graphify label` pass would make graph queries
   substantially more navigable.

For **osgi/osgi upstream** (observations, not actionable here):

6. TCK support library predates `org.osgi.test` (JUnit3-style `OSGiTestCase` vs the
   modern annotation-driven osgi-test project already referenced in these docs) — when
   writing *new* OSGi tests outside TCK context, prefer the osgi-test patterns.
