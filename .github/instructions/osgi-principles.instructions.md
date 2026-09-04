# OSGi Design Principles (from enRoute 300-principles)

Source: https://github.com/osgi/v2archive.osgi.enroute.site/blob/dd783274fa7fef4d72895c29a75fec70b015adcf/_doc/300-principles.md

Always apply these principles when reasoning about OSGi system design.

---

## Time & Change

- Software lives in a continuously evolving context — design for change, not for today's snapshot.
- **Versioning** — every independently deployable artifact must carry a version.
- **Prepare for change** — keep the code base optimal for additional changes at all times.
- **Minimize cost of change** — design so changes have minimal ripple effect.
- Avoid aggregation/repackaging: it couples constituent lifecycles and forces consumers to take the fastest-moving part's release cadence.
- A revision is immutable; "maintenance" means fixing bugs or adding features, not patching wear.

---

## Less is More (Ockham's Razor for Software)

- Prefer fewer parts over more, all else being equal.
- Optimize for readability; reduce cruft and redundancy.
- **DRY** — each concept, fact, or function defined once; reference everywhere else.
- Keep the number of simultaneous concepts per scope below ~7 (chunking limit of human cognition).
- Modularity is the primary chunking mechanism — use it to bound cognitive load.

---

## Modules & Bundles

- A module provides a **fence** that chunks its constituents into a single named concept.
- Good decomposition (Parnas 1972): changes touch a small percentage of modules; bad decomposition spreads change everywhere.
- OSGi Bundles extend the JAR into a proper module: identity + exported packages + imported packages.
- **Package** is the unit of import/export, not class — respects Java's own access-control granularity.
- **No split packages** — merging packages across bundles destroys local scope and makes private changes unsafe.
- A bundle may contain multiple components when they are highly cohesive and share similar dependencies.
- Benefits of modularization:
  - **Decomposition** — minimal modules touched per change request
  - **Chunking** — easier conceptual manipulation
  - **Fewer visible parts** — developers see only their module + imports
  - **Local scope** — full impact of a local change is reviewable locally

---

## Components

| Type | Characteristics |
|---|---|
| **Library** | No internal state; wide public API = implementation. No statics/singletons. |
| **Stateful Component** | System-wide shared state (e.g. ConfigAdmin). Avoid statics — use DS/services. |
| **Abstracted Component** | API separated from implementation; provider chosen by assembler at deploy time. |
| **Extender Component** | Acts on bundle lifecycle to remove boilerplate (e.g. Declarative Services reads XML, keeps component code clean). |

---

## Dependencies

- Dependencies are **Jekyll & Hyde**: reuse is good; transitive dependency explosion is evil (JAR Hell / DLL Hell).
- **Minimize dependencies** — the cost of a dependency includes all its transitives. Sometimes rewriting 16 lines beats dragging in 36 MB.
- **Depend on API, not implementation** — breaks the transitive dependency chain:
  - Consumer depends on API only
  - Provider depends on API only
  - Neither consumer nor provider depends on the other
- Application/assembler component is the only legitimate place to aggregate all transitive deps; it must be a **leaf** in the dependency graph (nothing else depends on it).
- **Fidelity is wrong** — developers should not require their environment to mirror production. Components must be resilient to context changes they don't know about.
- Express dependencies on **packages** (not JARs): bnd reads imports from bytecode automatically.
- Use the **OSGi resolver** to satisfy requirements — it handles version ranges, backward compatibility, and avoids rigid revision-to-revision graphs.
- Dependency principles:
  - Declare all requirements formally (manifest headers, annotations)
  - Prefer version ranges over exact versions
  - Never express a dependency on a JAR you don't directly use

### Requirements & Capabilities (R&C) Model

- Every dependency is either a **Capability** (key/value attributes in a namespace) or a **Requirement** (LDAP filter asserting capability attributes).
- Namespaces keep requirement/capability matching scoped (e.g. `osgi.wiring.package`, `osgi.service`, custom namespaces).
- Use the resolver (bnd `bnd resolve resolve -W`) to compute `-runbundles` — do not hand-curate the list.
- Resolving is NOT NP-complete in practice when the candidate set is a governed, bounded repository.

---

## Standards & APIs

- Standards decouple consumer from provider — everyone talks to the spec, not to each other (linear, not exponential coupling).
- **Provider** must adapt on every spec release; **consumer** gets backward compatibility across releases.
- A quality specification delivers: spec document, binary API JAR (no impl inside), Javadoc, reference implementation, black-box TCK, and a community.
- Prefer OSGi Alliance specifications; scrutinize JCP specs for RI-contaminated JARs.

---

## Semantic Versioning

- Use OSGi semantic versioning on every exported package.
- `major.minor.micro.qualifier`
  - **micro** — bug fixes, no API change
  - **minor** — backward-compatible additions (consumer range `[1.0,2)` still works)
  - **major** — breaking change; consumers must update import range
- Provider import range: `[1.0,1.1)` (tight — must retest on every minor)
- Consumer import range: `[1.0,2.0)` (wide — backward-compatible additions are safe)

---

## Roles to Keep in Mind

| Role | Responsibility |
|---|---|
| Architect | Overall system structure & constraints |
| Designer | Component APIs and contracts |
| Coder | Component implementation + unit tests |
| Assembler | Selects components, runs resolver, produces `.bndrun` |
| Deployer | Installs assembled application into runtime |

The Assembler role is key: the resolver is the Assembler's primary tool.

---

## Anti-Patterns to Reject

- Static singletons (global state, untestable, prevents multiple instances)
- Split packages (merges package namespaces across bundles, destroys local scope)
- Depending on implementations instead of APIs (tight coupling, transitive dep explosion)
- Fidelity requirements (dev environment == production) — erodes component independence
- Hand-curated `-runbundles` without resolver verification
- Aggregating/repackaging JARs without a strong reason (increases entropy, constrains consumers)
- Adding dependencies without auditing their transitive closure
