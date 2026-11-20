---
name: scenario-testing
description: Scenario testing for a feature by reasoning. Works out how the feature will really be used, writes concrete scenarios, traces each one through the code in its own subagent, and reports which the code handles, breaks on, or never decided. Use when the user asks to scenario test a feature, think through how it might be used, walk scenarios or use cases through the code, or find what a feature does in situations nobody planned for.
---

# Scenario Testing

A **scenario** is one concrete situation the feature will meet: who arrives, in what state, what they do, and what should happen. A **trace** is that scenario followed through the code, step by step, with the scenario's own values. Each scenario is traced in its own subagent. You frame the feature, write the scenarios, dispatch the tracers, verify what they return, and report.

Scenario testing is reasoning. The whole run leaves the repository as it found it; code and tests come afterwards, from the report, when the user asks for them.

[`TRACER.md`](TRACER.md) owns how a trace is done and reported. Read it before step 4.

## Input

`$ARGUMENTS` may name the feature, point at files, a branch, a pull request, or a spec, or carry scenarios the user already has in mind. With nothing supplied, the feature is the one the session has been working on; with no such feature, ask which one.

## Step 1: Frame the feature

Establish three things, from the conversation, the code, and the documents around it:

- **The feature**, in one sentence a user of it would recognise.
- **Entry points:** every place a person or another system reaches it, such as a route, a command, a UI action, a job, a webhook, or a public function. Give each as `path:line`.
- **The intent source:** where expected behaviour is written down. A ticket, spec, pull request description, docs, or the user's own words in this session. Tests and the code itself show what the feature does, which is the thing under test, so they are a last resort for intent.

Interview the user only when a gap here would change the scenarios: the feature's users are unknown, or nothing says what it is for. Ask those questions in one batch. Otherwise carry on.

Done when you can state all three, or have recorded the intent source as "none found".

## Step 2: Write the scenarios

Write scenarios from the outside: from the people and systems that use the feature, and from the intent source. A scenario drawn from the code can only confirm what the code already does, so leave the implementation unread until the list is written, beyond what step 1 needed.

Start with the scenarios the user supplied. Then walk each of these angles and keep every situation that could plausibly happen in real use:

- **Main paths:** the two or three things most people come to do.
- **Input:** empty, minimal, huge, malformed, duplicated, in another language or format, pasted from somewhere else.
- **State:** first-ever use, nothing there yet, a lot there already, data left by an older version, a half-finished earlier attempt.
- **Sequence:** done twice, out of order, abandoned halfway, retried after a failure, resumed later, undone.
- **Actors:** the wrong role, a lapsed permission, two people at once, the same person in two tabs, an automated client.
- **Dependencies:** a service this relies on is slow, down, or answers with something unexpected.
- **Time:** expiry, a day or timezone boundary, a long gap between steps, a clock that disagrees.
- **Neighbours:** another feature that reads or writes the same data, or that the user will combine with this one.

Aim for 6 to 12 scenarios, with stress cases outnumbering main paths. Prefer one scenario that combines pressures the way real use does (a retry, on a slow connection, by a user whose session just expired) over three that each test one in isolation. Leave single-input checks that a unit test states better to unit tests.

Write each scenario in this form:

```markdown
### S3: Retry after a timed-out upload

- Actor: a signed-in editor on a slow connection
- Starting state: a draft with two attachments already saved
- Steps:
  1. Attaches `report.pdf` (48 MB).
  2. The upload request times out after 30 s.
  3. Clicks "Retry".
- Expected:
  - The draft ends with exactly three attachments.
  - No orphaned file is left in storage.
- Expectation source: ticket, "uploads must be safe to retry"
```

- Use concrete values: `48 MB`, `2024-02-29`, `a user with no orders`. A tracer can follow a value through a branch; it cannot follow "a large file".
- State each expected outcome as something observable: a response, a stored record, a message shown, a side effect that did or did not happen.
- Give each expected outcome its source. When the intent source is silent, write the outcome a reasonable user would expect and mark its source `assumed`. Assumed expectations are how the report finds the cases nobody decided.

Done when every angle has a scenario or a recorded reason it does not apply to this feature.

## Step 3: Show the scenarios

Print the scenario list, compactly: id, title, and one line each. Then continue to step 4 in the same turn. The user can add, change, or cut scenarios at any point, and you trace only the affected ones again.

## Step 4: Dispatch the tracers

Spawn one fresh subagent per scenario, all in one parallel batch. A tracer that knows one scenario follows it honestly; one that knows the others, or your suspicions, starts confirming them.

Each brief contains exactly:

```text
Contract:     <absolute path to TRACER.md>
Feature:      <the one-sentence statement>
Entry points: <path:line for each>
Scenario:     <the scenario, verbatim>
Scratch:      <a temporary directory outside the repository, for probes>
```

Paste the contract's contents into the brief only when the platform's subagents cannot read outside the repository. On a platform without subagents, trace the scenarios yourself, one at a time, each written up before the next begins.

## Step 5: Verify

Tracer reports are claims. Before a result reaches the user:

1. For every outcome reported BROKEN or UNDECIDED, open the cited lines and follow the decisive step yourself. Reject a result that rests on a misread branch, a missed guard elsewhere in the path, or a wrong assumption about a framework or library, and record why.
2. For every UNCERTAIN outcome, settle it by reading further or with a probe (see `TRACER.md`), or keep it as uncertain with what would settle it.
3. Group results that share one root cause into one finding, and list every scenario that reaches it.
4. Spot-check one HANDLED trace per entry point, so the passes can be trusted too.

Done when every outcome that is not HANDLED is confirmed, rejected with a reason, or kept as uncertain.

## Step 6: Report

```markdown
## Scenario test: <feature>

**Result:** [n] handled, [n] broken, [n] undecided, [n] uncertain — [one sentence on what matters most]

**Traced from:** [entry points] · **Expected behaviour from:** [intent source, or "none found; expectations assumed"]

| #  | Scenario | Result |
| -- | -------- | ------ |
| S1 | [title]  | [HANDLED / BROKEN / UNDECIDED / UNCERTAIN] |

### Broken

#### <what goes wrong, in the user's terms>

- Scenarios: S3, S7
- What happens: [the path, in two or three steps, to the point it departs from the expected outcome]
- Where: `path/to/file.ext:line`
- Expected: [the outcome, and its source]
- Confirmed by: [traced | probe: what was run and what it showed]
- Fix direction: [the smallest change that would make the scenario pass]

### Undecided

[Cases where the code does something but nobody chose it. Same fields, with "Decision needed" in place of "Fix direction": the options and what the code does today.]

### Uncertain

[What could not be settled, each with what would settle it.]

### Rejected results

[Tracer claims rejected in verification, each with the reason.]
```

- A scenario's result is its worst outcome: BROKEN, then UNDECIDED, then UNCERTAIN, then HANDLED.
- Order findings by how likely the scenario is in real use and how bad the result is for the person in it.
- Omit a heading with nothing under it. Keep the table always.
- Attach full traces only on request.

End with the next moves, as one short offer:

- Fix the broken findings, with each failing scenario written as a test first.
- Decide the undecided cases, then build what was decided.
- Save this report, or the scenarios alone for a later re-run, as a file.

Take a move only when the user picks it.
