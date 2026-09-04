---
layout: default
title: osgi — architecture patterns
nav_exclude: true
---

<!-- Generated from patterns.json — do not hand-edit -->

# Architecture Patterns: osgi (osgi/osgi)

Observed facts only. Six patterns.

## 1. `spec-api-impl-tck-triple` — Specification triple

Each spec = up to 3 sibling projects: `org.osgi.service.<spec>` (API),
`org.osgi.impl.service.<spec>` (RI), `org.osgi.test.cases.<spec>` (TCK). TCK
`-runbundles` wires the RI; some RIs are prebuilt binaries in `licensed/repo`.

Evidence: `org.osgi.service.prefs/`, `org.osgi.impl.service.prefs/bnd.bnd`, `org.osgi.test.cases.event/bnd.bnd`, `licensed/repo/`

Rules: API exports spec packages only · impl fully private · TCK names impl with `version=latest` · dir name == BSN.

## 2. `central-cnf-includes-config` — cnf/build.bnd + includes layers

Cross-cutting config once in `cnf/build.bnd`; projects start with
`-include: ${includes}/jdt.bnd, ${includes}/<layer>.bnd` (core/cmpn/tck/promise),
keeping project bnd.bnd 8–30 lines.

Evidence: `cnf/build.bnd`, `cnf/includes/*.bnd`, `org.osgi.service.log/bnd.bnd`

Rules: identity headers stamped centrally · reproducible (`-reproducible`, `-noextraheaders`, embedded LICENSE/NOTICE) · `-diffignore: Bundle-Version`.

## 3. `semantic-package-versioning` — @Version package-info

Every exported package: `package-info.java` with `@Version("x.y")`; javadoc gives
consumer `[1.5,2.0)` vs provider `[1.5,1.6)` import ranges. Bundle versions are
timestamps excluded from baselining — package version is the contract.

Evidence: `org.osgi.service.log/src/org/osgi/service/log/package-info.java`, `cnf/build.bnd`

## 4. `tck-in-framework-junit` — TCK in real framework

Tests extend `org.osgi.test.support.OSGiTestCase` (BundleContext injected by OSGi
JUnit runner), run under `-runfw org.osgi.impl.framework`. Scenario bundles
`tbN.jar` built by `-make` recipes from `bnd/tbN.bnd`, embedded via
`-includeresource`. `-signaturetest` checks API signatures. Security = sibling
`*.secure` project.

Evidence: `org.osgi.test.cases.event/bnd.bnd`, `.../junit/EventTests.java`, `org.osgi.test.support/.../OSGiTestCase.java`

## 5. `impl-activator-servicefactory` — RI service registration

`Bundle-Activator` + `Export-Service` in bnd.bnd; activator registers spec service,
often as `ServiceFactory` for per-bundle scoping; all impl packages private.

Evidence: `org.osgi.impl.service.prefs/bnd.bnd`, `.../prefs/Activator.java`

## 6. `bsn-gradle-bnd-workspace` — single bnd-workspace Gradle build

`settings.gradle` applies `biz.aQute.bnd.workspace` (pinned 7.1.0); project set
seeded from `bnd_build=osgi.build`. Aggregates assemble via bnd `-make`, not Gradle
logic. `-workingset` partitions Build/Companion/Implementations/TCKs.

Evidence: `settings.gradle`, `gradle.properties`, `cnf/build.bnd`
