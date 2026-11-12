---
name: architecture
question: Does this change put the right responsibilities in the right places, at a cost the codebase can carry later?
runs: when the changeset adds, removes, or moves a module, public interface, dependency, schema, or call between modules
context:
  - ADRs and architecture documents
  - domain glossary (CONTEXT.md or GLOSSARY.md), when present
  - agent guidance sections that describe structure and layering
  - task source, when found
---

## Look for

- **Responsibility placement:** logic living in the layer or module that owns that concern; invariants enforced where the data lives.
- **Dependency direction:** imports that point against the established layering, new cycles, a low-level module learning about a high-level one.
- **Interface depth:** a deep module hides a lot behind a small interface. Flag shallow pass-through layers, interfaces that leak their implementation, and callers that must know internal ordering.
- **Seams:** whether the change can be tested and replaced at its boundary, or reaches through it.
- **Coupling:** modules that must now change together, shared mutable state, knowledge duplicated across a boundary.
- **Existing capability:** search for a module that already does this before accepting a second one.
- **Abstraction fit:** generality with one caller and no named second use, or three copies with no abstraction.
- **Data model:** schema shape, ownership of each field, where derived data is stored or recomputed.
- **Hard-to-reverse decisions:** public API shapes, persisted formats, event contracts, migrations. These deserve the closest reading.
- **Recorded decisions:** conflicts with an ADR or documented architecture.

## Boundaries

- Naming and conformance to local patterns belong to **consistency**. This lens asks whether the structure is right, including when it follows the local pattern faithfully.
- Whether the work belongs in this task belongs to **scope**.
- Behaviour that is wrong today belongs to **correctness**.

## Evidence

Each finding names the future cost: the change that becomes hard, the things that now break together, or the decision that cannot be undone, with the ADR or existing module cited where one applies.

CRITICAL is for hard-to-reverse decisions. A structure that is merely not the one you would have chosen is a NOTE at most.

## Extra report sections

- **Decisions worth recording:** architectural choices this change makes that an ADR should capture.
