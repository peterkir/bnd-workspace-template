---
layout: default
title: Suggested Improvements
nav_exclude: true
---

# Suggested Improvements — osgi-test

Inferred recommendations — **not observed practice**. Kept strictly out of the pattern layers.

1. **bnd version lag** — repo builds with bnd 6.4.0 (7.0.0-SNAPSHOT only in a profile);
   local guidance targets bnd 7.x. When imitating build wiring, prefer current bnd 7.x
   plugin versions; the pattern structure transfers unchanged.
2. **Java 8 baseline** — library compiles at release 8 for maximum consumer reach. New
   projects without that constraint can raise `java.release` (e.g. 17/21); annotations +
   extension patterns are version-neutral.
3. **Compile-vs-runtime dependency split** (junit 5.8.2/5.10.2, assertj 3.23.1/3.24.2)
   is subtle and undocumented in-repo; document it explicitly when copying the pom
   structure or it looks like an error.
