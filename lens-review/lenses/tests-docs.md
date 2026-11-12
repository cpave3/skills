---
name: tests-docs
question: Would the tests catch this change breaking, and does the documentation still tell the truth?
runs: always
context:
  - test standards and the documented test, lint, and type-check commands
  - existing tests for the changed modules
  - module documentation for the changed modules
  - agent guidance (AGENTS.md, CLAUDE.md)
---

## Look for

### Tests

- **Run them.** Run the tests that cover the changed paths, and the lint and type checks when each is one documented command. When a run needs services you lack or would take more than a few minutes, name the command you would run.
- **Coverage:** each changed behaviour is reached by a test through a real caller path.
- **Meaning:** each test would fail if the behaviour were removed or broken. Flag assertions that only prove the code ran.
- **Boundaries:** edge cases and error paths of non-trivial logic.
- **Regression:** a bug fix comes with a test that fails without the fix.
- **Coupling:** mocks at real boundaries; tests that assert behaviour and survive a refactor.
- **End to end:** at least one test exercises the feature the way a user or caller reaches it, where the repository has that kind of test.
- **Conventions:** naming, setup, helpers, and assertion style match the module's existing tests.

Judge whether the important paths are tested. Full coverage is not the bar.

### Documentation

- **Module and API documentation** reflects changed public behaviour, interfaces, and configuration.
- **Contracts:** generated schemas, API specifications, and types are regenerated and match the code.
- **Agent guidance:** a new convention or architectural decision is recorded in `AGENTS.md` or `CLAUDE.md`.
- **Comments:** changed code leaves no comment stating something now false; complex sections are explained.

## Boundaries

- A defect in production code that you find while reading tests belongs to **correctness**.
- Whether a behaviour should exist at all belongs to **scope**.

## Evidence

Each test finding names the behaviour that could break unnoticed and the specific test to add or change. Each documentation finding quotes the statement that is now wrong, or names the fact that is missing.

## Extra report sections

- **Commands run:** each command and its result, and each command you could not run.
- **Agent guidance update:** yes or no, with the text to add.
