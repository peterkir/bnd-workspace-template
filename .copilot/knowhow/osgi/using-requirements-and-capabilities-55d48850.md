---
layout: default
title: Using Requirements and Capabilities
parent: Knowhow
grand_parent: OSGi
language: osgi
sources:
  - ref: https://blog.osgi.org/2015/12/using-requirements-and-capabilities.html
    title: Using Requirements and Capabilities
    author: Ray Auge
    publishedAt: 2015-12-01
    accessedAt: 2026-08-10T00:00:00Z
essence: OSGi Requirements and Capabilities define contracts in namespaces and match requirements to capabilities with LDAP filters, enabling deterministic resolver-driven wiring and early detection of unsatisfied dependencies.
confidence: 0.95
generatedBy: ref-doc/1
---

# Using Requirements and Capabilities

## Source metadata

- URL: https://blog.osgi.org/2015/12/using-requirements-and-capabilities.html
- Title: Using Requirements and Capabilities
- Author: Ray Auge
- Published: 2015-12-01
- Accessed: 2026-08-10T00:00:00Z

## Essence

- Requirements and Capabilities generalize bundle manifest contract modeling into a reusable constraint language.
- Contracts start with a unique namespace plus agreed attributes and directives.
- Providers publish capabilities, consumers declare requirements using LDAP filters over capability attributes.
- Resolver computes satisfiable wiring sets and blocks resources with unsatisfied requirements before unsafe runtime behavior.
- Model unifies older header-specific semantics and supports custom namespaces for domain-specific contracts.
- bnd annotations and OSGi manifest annotation efforts reduce manual manifest work by generating contract metadata.

## Key concepts

- Namespace as contract boundary and semantic scope.
- Capability as provided contract instance with typed attributes.
- Requirement as query constraint over capabilities.
- LDAP filter matching for requirement selection.
- Deterministic resolver behavior from OSGi R4.3+ frameworks.
- Unsatisfied requirements as explicit, reproducible failure mode.

## Practical patterns and checklist

- Define one clear namespace per contract domain.
- Specify minimal, typed capability attributes needed for matching.
- Express consumer needs as strict-but-meaningful LDAP filters.
- Test unsatisfied requirement scenarios intentionally; verify resolver failure is explicit.
- Prefer resolver-computed runtime sets over manually curated wiring.
- Use bnd or manifest annotations where possible to reduce metadata drift.

## Caveats and limits

- Overly broad filters can produce unintended provider matches.
- Overly strict filters can make deployment brittle across environments.
- Custom namespaces need governance, or contract semantics drift across teams.
- Resolver success does not replace functional validation of chosen providers.

## Cross-links to language guidance

- OSGi language guidance: ../../index.md
- OSGi reference implementations: ../references/osgi/index.md
- OSGi bnd instruction set: ../../../../.github/skills/osgi/instructions.md

## Conflict notes

- No conflicts observed for this single-source extraction.

## Extraction notes

- Article uses pet grooming analogy to demonstrate namespace + attributes + LDAP filter matching.
- Examples map directly to `Provide-Capability` and `Require-Capability` headers.

## Revision history

- 2026-08-10: Initial extraction from source URL.
