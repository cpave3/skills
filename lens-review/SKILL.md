---
name: lens-review
description: Code review that runs each lens (correctness, security, architecture, consistency, tests and docs, scope) in its own subagent, then verifies the findings and merges them into one report. Use when the user asks for a code review or PR review of working changes, a branch, a commit range, or a pull request, or asks for a single lens by name.
---

# Lens Review

A **lens** is one question asked of a changeset, defined by one file in [`lenses/`](lenses/). Each selected lens runs in its own subagent with its own slice of context. You orchestrate: build the changeset manifest, select lenses, brief the reviewers, verify what they return, and report.

The lens files own everything lens-specific. [`REVIEWER.md`](REVIEWER.md) owns what every reviewer shares: the evidence bar, the severities, and the finding format, which the final report uses too. Read it before step 5.

## Input

`$ARGUMENTS` may carry, in any combination:

- a commit range (`main...HEAD`, `abc123..def456`) or a pull request number or URL;
- lens names, to run only those lenses.

## Step 1: Build the changeset manifest

The **manifest** is the exact description of what is under review. Every reviewer receives it verbatim, so every lens reviews the same thing.

Resolve the changeset:

- **Nothing supplied:** review working changes: `git diff HEAD` plus the untracked files from `git ls-files --others --exclude-standard`. When there are none, review the current branch from its merge base with the default branch. When that is empty too, report that there is nothing to review and stop.
- **Range supplied:** base is `git merge-base <from> <to>`, head is `<to>`. Diffing from the merge base keeps commits that landed on the base branch after the fork out of the review.
- **Pull request supplied:** take base and head from `gh pr view`, fetch the head if it is absent locally, and treat it as a range. Its description is a task source.

When the branch carries prerequisite commits that belong to another task, move the base past them and say so in the report.

The manifest states:

- **Base and head** as full SHAs; head is `WORKTREE` for working changes.
- **Diff command** the reviewers run, and its `--name-status` output.
- **Commits** (`git log --oneline <base>..<head>`) for a range.
- **Untracked files**, reviewed as wholly new.
- **Bulk files:** generated code, vendored code, lockfiles, and snapshots. Reviewers check that these belong and match their source, and skip line-by-line reading.
- **Read source:** the working tree when head is `WORKTREE`, or when head equals `HEAD` and the tree is clean; otherwise `git show <head>:<path>`.

When the non-bulk diff exceeds about 2,000 changed lines, split the changed paths into **partitions** by module. Each lens then gets one subagent per partition, and the report states the partition count.

Done when every changed path appears in the manifest exactly once: reviewed, untracked, or bulk.

## Step 2: Select lenses

Read the frontmatter of every file in `lenses/`.

- The user named lenses: run those.
- Otherwise: run every lens whose `runs` condition holds for this manifest. Settle a condition that depends on context, such as a task source existing, by looking for that context now.

A **task source** is a ticket, pull request description, approved plan, or specification written for this change. Find it from the branch name, commit messages, and pull request. Commit messages alone are not a task source.

Done when every lens file is recorded as run, or as skipped with the reason.

## Step 3: Gather context

Each selected lens lists the context its reviewer receives under `context` in its frontmatter. Gather the union across the selected lenses, in parallel.

A lens's list is also its limit. A reviewer that has not read the ticket judges the code on its own terms, and that independence is why the lenses are separate. Give each reviewer its own list and nothing more.

Where to look:

- **Agent guidance:** `AGENTS.md` and `CLAUDE.md` at the root and beside the changed paths, and repository skills that cover the changed code.
- **Task source and specifications:** the ticket, pull request, plan, requirements. Keep documents for this task apart from later proposals and follow-up tickets.
- **Decisions and structure:** ADRs, architecture documents, the domain glossary (`CONTEXT.md` or `GLOSSARY.md`).
- **Representative files:** two or three unchanged files beside the changed code, as living examples of local convention.
- **Test and check commands:** the documented way to run tests, lint, and type checks.

Pass repository material as paths. Paste material that lives outside the repository, such as ticket text.

Done when each selected lens has every context item it lists, or the item is recorded as not found.

## Step 4: Dispatch

Spawn one subagent per selected lens, and per partition, all in one parallel batch. Use the `review-lens` agent where the platform has it installed (Claude `review-lens`, Codex `review_lens`, Chimera `review-lens` mode); otherwise use a fresh general subagent.

The agent definitions ship with this skill in [`agents/`](agents/), one folder per platform. When the agent is missing, tell the user in the final report that copying the definition for their platform into its agent directory (for Claude Code, `~/.claude/agents/` or the project's `.claude/agents/`) gives later reviews a read-only reviewer.

Each brief contains exactly:

```text
Lens:     <absolute path to lenses/<name>.md>
Contract: <absolute path to REVIEWER.md>
Manifest: <the manifest, verbatim; for a partition, also its paths>
Context:  <this lens's context items: paths, or pasted text>
```

The reviewer reads the lens file and the contract itself. Paste their contents into the brief only when the platform's subagents cannot read outside the repository.

## Step 5: Verify

Reviewer reports are claims. Check each finding rated CRITICAL or WARNING yourself before it reaches the user:

1. Reproduce it against the source, the history, the task text, or a test run.
2. Reject it when it rests on the wrong range, a stale specification, an earlier intentional decision, or a wrong assumption about a framework or library.
3. Merge findings that describe one defect, keep the clearest evidence, and credit every lens that raised it.
4. Where two lenses disagree, decide, and explain the decision in the report.
5. Route each "For other lenses" entry: confirm it yourself, or drop it.
6. Sort what stands into fix now and valid deferral.

Done when every reviewer finding is confirmed, merged, or rejected with a reason.

## Step 6: Report

```markdown
## Code Review

**Verdict:** [Ready | Changes needed] — [one sentence]

**Reviewed:** [base..head or working changes, files changed, partitions if any]

| Lens | Result |
| ---- | ------ |
| [name] | [n critical, n warnings, n notes — or: skipped, reason] |

### Critical

### Warnings

### Notes

### Scope

- Missing: ...
- Beyond the task: ...
- Justified enabling work: ...
- Follow-ups: ...

### Rejected findings

[Reviewer claims rejected in verification, each with the reason.]
```

- The verdict is **Changes needed** when any CRITICAL or WARNING stands, otherwise **Ready**.
- Write each finding in the format from `REVIEWER.md`, with the lens that raised it.
- Omit a severity heading with nothing under it. Keep the lens table and the Scope section always; when the scope lens was skipped, the Scope section says why and what to supply to run it.
- When nothing stands, say so and list what each lens checked.
- Attach full reviewer reports only on request.

## Adding a lens

Create `lenses/<name>.md`. The orchestrator discovers it from the directory, so no other file changes.

```markdown
---
name: <name>
question: <the one question this lens answers>
runs: <always | when ...>            # a condition checkable from the manifest or the gathered context
context:                             # what the reviewer receives, and all it receives
  - <item>
---

## Look for
## Boundaries      <!-- adjacent concerns, and the lens that owns each -->
## Evidence        <!-- what a finding in this lens must show -->
## Extra report sections   <!-- optional -->
```

Give the new lens a question no existing lens answers, and add it to the Boundaries of the lenses it borders.
