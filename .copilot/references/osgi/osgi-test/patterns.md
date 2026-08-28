---
layout: default
title: Architecture Patterns
nav_exclude: true
---

# Architecture Patterns — osgi-test

Generated from [patterns.json](patterns.json). Observed patterns only — no speculation.

## 1. Annotation-driven test injection (`annotation-driven-injection`)

Tests declare needs via `@InjectBundleContext` / `@InjectService` on fields or parameters.
Key trick: each annotation is meta-annotated `@ExtendWith(<Extension>.class)`, so the
extension self-registers — user code needs no explicit `@ExtendWith`.

Rules: FIELD+PARAMETER targets, RUNTIME retention, `@Inherited`; config (filter,
cardinality, timeout) lives as annotation members with defaults; injected fields must
not be `final` or `private`.

## 2. Generic `InjectingExtension` base (`generic-injecting-extension`)

One abstract base implements BeforeAll/BeforeEach/ParameterResolver/AfterAll/AfterEach
plus all reflection plumbing. Concrete extensions pass annotation class + target types
to the constructor and override a single `resolveValue()` factory method.

## 3. Store-scoped cleanup (`store-scoped-cleanup`)

Resources live in `ExtensionContext.Store` under `Namespace.create(ExtensionClass, uniqueId)`,
wrapped as `CloseableResource`. `CloseableBundleContext` proxies the real context and
reverts service registrations, listeners, and installed bundles on close. Nested test
classes resolve the parent context by walking up the `ExtensionContext` hierarchy.

## 4. In-framework testing via bndrun (`in-framework-testing`)

No framework mocks. Test sources become `<artifactId>-tests` bundles launched by
`biz.aQute.tester.junit-platform` inside Equinox (`-runfw: org.eclipse.osgi`).
`-runrequires: bnd.identity;id='${project.artifactId}-tests'` is the only hand-written
requirement — the resolver computes `-runbundles`. Surefire is disabled reactor-wide.

## 5. AssertJ module per OSGi domain (`assertj-per-domain-module`)

Four assertion bundles (framework, feature, log, promise). Per asserted type:
`Abstract<Type>Assert` (logic, protected constructor) + final `<Type>Assert`
(static `assertThat`, `InstanceOfAssertFactory` constant).

## 6. Triple example consumption proof (`triple-example-consumption`)

Same api+impl+test example shipped as bnd workspace, Gradle, and Maven builds,
verified by a dedicated CI workflow — consumption modes fail loudly on drift.
