---
name: scope
question: Does the changeset deliver what the task asked for, all of it and only it?
runs: when a task source exists
context:
  - task source (ticket, pull request description, approved plan)
  - product specifications, decisions, and explicit exclusions for this task
  - known follow-up tickets and what each owns
---

## Look for

Check both directions against the task source.

- **Under-scope:** every acceptance criterion and required behaviour, each matched to the code that delivers it. List the ones with no match or a partial match.
- **Over-scope:** product behaviour the task did not ask for, work that belongs to a later ticket, refactoring wider than the task needs.

Sort everything beyond the literal task into one of:

- **enabling work:** needed for the task to function, such as tests, generated artifacts, build wiring, migrations, seeds, and documentation;
- **incidental cleanup:** small, adjacent, low-risk;
- **future seam:** structure added for a capability the task does not deliver;
- **follow-up work:** named in the task source as belonging elsewhere.

Size alone is not over-scope. Large enabling work in proportion to the task is justified.

## Boundaries

- Implemented behaviour that works incorrectly belongs to **correctness**. Out-of-scope code can be correct, and missing scope can have no code defect.
- Whether added structure is well designed belongs to **architecture**.

## Evidence

Each finding quotes the line of the task source it rests on and gives the `file:line` that delivers, or should have delivered, it.

Where the task source leaves ownership unclear, raise it under Questions.

## Extra report sections

- **Justified enabling work:** so that it is not mistaken for over-scope.
- **Follow-ups:** work to defer, with the ticket that owns it or a note that none exists.
