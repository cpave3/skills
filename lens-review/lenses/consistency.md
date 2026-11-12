---
name: consistency
question: Does the change follow the conventions this codebase has already settled on?
runs: when the changeset touches executable code or configuration
context:
  - agent guidance (AGENTS.md, CLAUDE.md) and repository skills that cover the changed code
  - two or three unchanged representative files beside the changed code
---

## Look for

Agent guidance and the representative files are your ground truth. Search for further examples when they do not settle a point.

- **Naming:** functions, variables, types, and files against the patterns in use.
- **Established patterns:** error handling, dependency injection, data access, logging, validation, done the way neighbouring code does them.
- **File organisation:** location of new files, export structure.
- **Interface conventions:** parameter order, return shapes, error signalling, matched to existing public interfaces.
- **Explicit rules:** every applicable rule in agent guidance and in the relevant skills.

## Boundaries

- Whether the established structure is itself right belongs to **architecture**.
- Whether the logic works belongs to **correctness**.
- Conventions for writing tests belong to **tests-docs**.

## Evidence

Each finding cites the written rule, or an existing example at `file:line`, and shows how the change departs from it. A preference with nothing to cite stays out of the report.

Where the codebase itself is split between two patterns, say so under Questions.

## Extra report sections

- **Conventions referenced:** the rules and example files you compared against.
