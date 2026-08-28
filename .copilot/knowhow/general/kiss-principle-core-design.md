---
layout: default
title: KISS Principle
parent: Knowhow
grand_parent: General
language: general
sources:
  - ref: seed:manual-bootstrap
    title: Seed entry
    accessedAt: 2026-08-10T00:00:00Z
essence: Keep design as simple as possible while still meeting current requirements.
confidence: 0.98
generatedBy: ref-doc/1
---

# KISS Principle

## Essence

- Prefer simplest design that satisfies functional and non-functional requirements.
- Remove incidental complexity before adding abstractions.
- Delay generalization until repeated, concrete need exists.
- Optimize for readability and maintainability first.
- Keep interfaces small and explicit.

## Key concepts

- Simplicity is about lower cognitive load, not fewer lines only.
- Good decomposition reduces change blast radius.
- Complexity tax compounds over time.

## Practical checklist

- Can a new teammate explain this module in under two minutes?
- Does each abstraction remove more complexity than it adds?
- Can one requirement change be implemented by touching few files?
- Is there redundant indirection with no proven need?

## Caveats and limits

- Over-simplification can hide mandatory domain constraints.
- Simplicity today must still allow safe future change.

## Cross-links

- Prefer DRY with restraint: duplication is cheaper than wrong abstraction in early stage.
- Pair with YAGNI for scope control.

## Extraction notes

Seeded as baseline cross-language principle required by workspace bootstrap.

## Revision history

- 2026-08-10: Initial seed.
