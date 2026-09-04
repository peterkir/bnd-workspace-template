---
layout: default
title: osgi — fingerprint
nav_exclude: true
---

<!-- Generated from fingerprint.json — do not hand-edit -->

# Fingerprint: osgi (osgi/osgi)

## Build system

| Aspect | Value |
|---|---|
| Primary | Gradle 8.14 + bnd workspace plugin `biz.aQute.bnd.workspace` 7.1.0 |
| Workspace model | `cnf/` config project; project set seeded by `bnd_build=osgi.build` |
| Java | javac source/target **1.8** ("We require Java 8", CONTRIBUTING.md) |
| Default task | `assemble` |
| Reproducibility | `-reproducible: true`, `-noextraheaders: true` |
| Version scheme | `osgi.version` 8.1.0 + `yyyyMMddHHmm` timestamp; `-snapshot` property flips snapshot/RC/release |

## Directory topology (top 2 levels)

| Group | Count | Purpose |
|---|---|---|
| `org.osgi.service.*` | 50 | Specification API projects |
| `org.osgi.impl.*` | 29 | Reference implementations |
| `org.osgi.test.cases.*` | 80 | TCK suites (incl. `*.secure` variants) |
| `org.osgi.test.support` / `.filter` | 2 | Shared TCK support (OSGiTestCase, collectors, signature) |
| `org.osgi.util.*` | 6 | converter, function, promise, pushstream, tracker, xml |
| Core API | 10 | framework, resource, dto, annotation.{bundle,versioning}, namespace.* |
| `osgi.*` aggregates | 9 | core, cmpn, annotation, promise, companion, specs, tck, impl, build |
| Infrastructure | 9 | cnf, licensed (binary repo), templates, xmlns, json.schema, dmforest, .design, gradle, .github |

Module naming: **directory name == Bundle-SymbolicName**.

## Entry points

```bash
./gradlew :build :publish                    # build + release into cnf/generated/repo
./gradlew :osgi.specs:specifications         # build spec documents
./gradlew :osgi.specs:core.pdf               # single spec output (also .html/.zip, cmpn.*)
./gradlew :org.osgi.test.cases.event:check   # run one TCK
```

## Test layout

- TCKs run **inside a real OSGi framework**: `-runfw org.osgi.impl.framework; version=latest`
- Tests extend `org.osgi.test.support.OSGiTestCase` / `DefaultTestBundleControl`
- Inner test bundles `tbN.jar` generated via `-make` from `bnd/tbN.bnd`, embedded with `-includeresource`
- `-signaturetest <pkg>` validates API signatures; `*.secure` projects rerun with Java security on

## CI

| Workflow | Name | Trigger |
|---|---|---|
| cibuild.yml | CI Build | push + PR (path-filtered) |
| bnd-test.yml | Test Bnd | bnd snapshot validation |
| scorecard.yml | Scorecard supply-chain security | schedule/push |
| stale.yml | Stale | schedule |
| wrapper.yml | gradle wrapper validation | wrapper changes |

Draft Core/Compendium specs published to gh-pages.

## License

Apache-2.0 (SPDX headers throughout).

## Graph signals

29331 nodes · 87299 edges · 905 communities. God nodes: `BundleContext` (1699), `Bundle` (913), `ServiceReference` (784), `BundleActivator` (703), `ServiceRegistration` (509), `ServiceTracker` (430), `DmtData` (364), `DmtSession` (346), `DefaultTestBundleControl` (321), `Promise` (299).
