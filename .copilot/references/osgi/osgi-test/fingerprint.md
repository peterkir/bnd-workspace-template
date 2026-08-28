---
layout: default
title: Fingerprint
nav_exclude: true
---

# Repository Fingerprint — osgi-test

Generated from [fingerprint.json](fingerprint.json). Do not hand-edit.

## Build system

| Aspect | Value |
|---|---|
| Primary | Maven (`mvnw` wrapper) |
| Manifest generation | `bnd-maven-plugin` |
| Integration testing | `bnd-testing-maven-plugin` — surefire disabled (`skipTests=true`) |
| Runbundle resolution | `bnd-resolver-maven-plugin` |
| API compatibility | `bnd-baseline-maven-plugin` |

## Versions

Java release 8 (compile target), bnd 6.4.0, JUnit Jupiter 5.8.2 compile / 5.10.2 runtime,
AssertJ 3.23.1 compile / 3.24.2 runtime, Awaitility 4.3.0, osgi.core 8.0.0 (buildpath, provided scope).
Compile-vs-runtime version split keeps the published API baseline low while testing against current releases.

## Module topology (BSN-as-folder)

Directory name equals Bundle-SymbolicName. 12 reactor modules:
`org.osgi.test.common` (shared utilities), `org.osgi.test.junit5` (extensions + annotations),
`org.osgi.test.junit4`, `org.osgi.test.junit5.cm`, `org.osgi.test.junit5.listeners.log.osgi`,
4× `org.osgi.test.assertj.*` assertion libraries, `org.osgi.test.bom`, plus
`org.osgi.test.junit5.featurelauncher` outside the default reactor.

`examples/` proves 3 consumption modes: bnd workspace, Gradle, Maven — each a standalone build.

## Test layout

All tests execute **inside a running OSGi framework**: `src/test/java` sources are built into
`<artifactId>-tests` bundles and launched via per-module `test.bndrun` files
(10 bndruns across the reactor). No plain-JVM unit test path.

## CI

`cibuild.yml` (library reactor), `examples-build.yml` (examples separately),
`codeql-analysis.yml`, `stale.yml`.

License: Apache-2.0.

## Knowledge graph

graphify 0.9.38 AST-only pass: **3723 nodes, 11071 edges, 245 communities**
(see [15-graph/](../15-graph/GRAPH_REPORT.md)).

God nodes (architectural hubs): `ServiceAware` (104), `MapStream` (92),
`OSGiSoftAssertions` (82), `FeatureLaunchCapture` (78), `BundleInstaller` (72),
`WithConfiguration` (66). `ServiceAware` at #1 independently confirms the canonical
`PlayerTest` selection. Surprise edges: the Maven example demos exercise `ServiceAware`
lifecycle and `junit5.cm` ConfigAdmin annotations — richer coverage than the
bndworkspace example.
