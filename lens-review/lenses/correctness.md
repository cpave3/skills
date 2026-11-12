---
name: correctness
question: Does the changed code behave correctly for every input and state it can meet?
runs: when the changeset touches executable code or configuration
context:
  - task source and behavioural specification, when found
---

## Look for

- **Logic:** conditionals, boundaries, off-by-one, wrong operator, empty and null cases, error paths.
- **Regressions:** behaviour that existing callers depend on. Search the call sites of every function whose signature, return value, or error behaviour changed.
- **State and persistence:** transactions, partial failure, retries and idempotency, migrations that corrupt or lose existing data, cache invalidation.
- **Concurrency:** races, ordering, locking, unawaited or overlapping async work.
- **Data flow:** transformations, type and unit mismatches, time zones, encoding.
- **Intended behaviour:** where a task source is supplied, the cases the code implements do what it says.

## Boundaries

- Required behaviour that is absent altogether belongs to **scope**.
- A flaw that needs a hostile actor belongs to **security**. Report it here when honest input also triggers it.
- Missing or weak tests belong to **tests-docs**.
- Naming, style, and local patterns belong to **consistency**.

## Evidence

Each finding gives a failure scenario: the input or state, what the code does, and what it should do.
