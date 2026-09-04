---
applyTo: "**/*.bndrun,**/bnd.bnd,**/*.bnd"
---

# OSGi / bnd Best Practices

## Core Concepts

- Every bundle is a JAR with an OSGi manifest — `bnd` generates the manifest from `bnd.bnd`
- Use BSN (Bundle-Symbolic-Name) not Maven GAV on `-buildpath` and `-runbundles`
- `cnf/` is the workspace configuration root — never delete it
- `bnd.bnd` in a project folder defines that project's bundle metadata

## bnd.bnd Essentials

```properties
Bundle-SymbolicName: com.example.mybundle
Bundle-Version:      1.0.0.${tstamp}

# Exported packages
Export-Package: com.example.api.*

# Private implementation — not exported
Private-Package: com.example.impl.*

# Build classpath (BSN, not GAV)
-buildpath: \
    osgi.annotation;version=latest,\
    org.osgi.framework;version=latest
```

## .bndrun Essentials

```properties
-standalone: true

# Repositories to search
-plugin.maven: \
    aQute.bnd.repository.maven.provider.MavenBndRepository; \
    name=Central; \
    url=https://repo1.maven.org/maven2/

# Bundles to resolve and run
-runbundles: \
    com.example.mybundle;version=latest

-runfw: org.eclipse.osgi;version=latest
-runee: JavaSE-21
```

## bnd CLI Usage

```bash
# Build all projects in workspace
java -jar ~/biz.aQute.bnd.jar build

# Build single project
java -jar ~/biz.aQute.bnd.jar build -p myproject/

# Resolve .bndrun and write back
java -jar ~/biz.aQute.bnd.jar resolve resolve -W -b myapp.bndrun

# Run
java -jar ~/biz.aQute.bnd.jar run myapp.bndrun

# Print bundle manifest
java -jar ~/biz.aQute.bnd.jar print mybundle.jar
```

## Common Pitfalls

- `-buildpath` uses BSN, not Maven GAV — use `org.apache.logging.log4j.api` not `log4j-api`
- `resolve` is a subcommand: `bnd resolve resolve -W -b file.bndrun`
- Framework API on `-buildpath`: use the pure API jar `osgi.core;version=8.0.0;maven-scope=provided` for `org.osgi.framework` (BundleContext); keep `org.eclipse.osgi` only as `-runfw`. Fallback: `org.eclipse.osgi` on buildpath when `osgi.core` is unavailable in the repo set
- `Export-Package` and `Private-Package` are mutually exclusive per package

## Tools

| Tool | Purpose |
|---|---|
| `bnd` CLI | Build, resolve, run, inspect |
| Bndtools (Eclipse) | IDE integration |
| `biz.aQute.bnd.reporter` | Bundle analysis and reporting |

## Reference Implementations

### osgi (`8c7184da`)

Full reference: [docs/languages/osgi/references/osgi/](../../../docs/languages/osgi/references/osgi/index.md) — the OSGi Specification Project monorepo (~190 bnd projects, Gradle + bnd workspace 7.1.0, Java 8).

- Specification triple: `org.osgi.service.X` (API) / `org.osgi.impl.service.X` (RI) / `org.osgi.test.cases.X` (TCK) as sibling projects; directory name == BSN
- Central `cnf/build.bnd` stamps identity/reproducibility headers once; projects compose `-include: ${includes}/jdt.bnd, ${includes}/<core|cmpn|tck>.bnd` layers — project bnd.bnd stays 8–30 lines
- Package-level semantic versioning: `package-info.java` + `@Version("x.y")`, javadoc documents consumer `[1.5,2.0)` vs provider `[1.5,1.6)` import ranges; `-diffignore: Bundle-Version` keeps baselining on package versions
- RI bundles: `Bundle-Activator` + `Export-Service` in bnd.bnd, `-privatepackage ${p}.*`, activator registers spec service often as `ServiceFactory`
- TCKs run inside the RI framework (`-runfw org.osgi.impl.framework`): tests extend `OSGiTestCase` (BundleContext injected by runner), scenario bundles `tbN.jar` built via `-make` from `bnd/tbN.bnd`, `-signaturetest` guards API signatures
- Reproducible builds: `-reproducible: true`, `-noextraheaders: true`, LICENSE/NOTICE embedded via `-includeresource.legal`

Query the knowledge graph (29331 nodes — graph.json is 65 MB) instead of re-reading the repo:

```bash
uvx --from graphifyy graphify query "<question>" --graph docs/languages/osgi/references/osgi/15-graph/graph.json
uvx --from graphifyy graphify explain "OSGiTestCase" --graph docs/languages/osgi/references/osgi/15-graph/graph.json
```

### osgi-test (`696b03cd`)

Full reference: [docs/languages/osgi/references/osgi-test/](../../../docs/languages/osgi/references/osgi-test/index.md)

- Annotation-driven test injection: `@InjectBundleContext`/`@InjectService` meta-annotated with `@ExtendWith(<Extension>.class)` — extensions self-register, no boilerplate
- Generic `InjectingExtension<A>` base implements all JUnit5 lifecycle callbacks once; subclasses supply annotation type + `resolveValue()`
- Resources in `ExtensionContext.Store` (namespace = extension class + unique test id) as `CloseableResource`; `CloseableBundleContext` proxy reverts registrations/listeners/bundles on close
- All tests run inside real OSGi framework: `-tester: biz.aQute.tester.junit-platform`, `-runrequires: bnd.identity;id='<artifact>-tests'`, `-runbundles` resolver-computed — never hand-curated
- Test discovery in bnd workspaces: `Test-Cases: ${classes;HIERARCHY_INDIRECTLY_ANNOTATED;org.junit.platform.commons.annotation.Testable;CONCRETE}`
- AssertJ pattern: `Abstract<Type>Assert` (logic) + final `<Type>Assert` (static `assertThat` + `InstanceOfAssertFactory` constant), one bundle per OSGi domain

Query the reference knowledge graph (3723 nodes) instead of re-reading the repo:

```bash
uvx --from graphifyy graphify query "<question>" --graph docs/languages/osgi/references/osgi-test/15-graph/graph.json
uvx --from graphifyy graphify explain "ServiceAware" --graph docs/languages/osgi/references/osgi-test/15-graph/graph.json
```

## Knowhow Lookup

- Language knowhow index: `docs/languages/osgi/knowhow/index.md`
- Language catalog (machine lookup): `docs/languages/osgi/knowhow/catalog.json`
- General knowhow index: `docs/general/knowhow/index.md`
- General catalog (machine lookup): `docs/general/knowhow/catalog.json`
- Before ad-hoc web recall, check language catalog first, then general catalog.

## Notes

_Project-specific notes added by setup._
