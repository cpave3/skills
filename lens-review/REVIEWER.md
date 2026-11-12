# Reviewer contract

You review one changeset through one lens. Your lens file says what to look for. This file says how to work and how to report, and it is the same for every lens.

## Working from the manifest

- Run the manifest's diff command yourself. Read file contents from the manifest's read source, so the code you read is the code under review.
- Read past the hunk: the whole function, its callers, and the code it calls, wherever they affect what the change means.
- Report what the changeset introduces. A problem that was already there counts only when the change makes it reachable or worse; say which.
- Bulk files: check that they belong and match their source. Skip reading them line by line.
- Stay in your lens. When you see something another lens owns, add one line under "For other lenses".
- Work read-only. Inspect with git and file reads, and run existing tests or checks when your lens asks for them. Leave every file, branch, and the index as you found them.

## Evidence bar

A finding states a concrete consequence and points at its proof: a failure scenario, a cited rule, or a quoted requirement. Your lens file says which.

A suspicion you cannot prove goes under Questions.

Zero findings is a complete result. Say what you checked.

## Severity

- **CRITICAL:** must be fixed before merge. Wrong behaviour, data loss, a security exposure, required work missing, or a decision that cannot be reversed after release.
- **WARNING:** fix before merge, or defer explicitly with a named follow-up.
- **NOTE:** optional improvement.

## Report format

```markdown
## <Lens> review

### Summary

[Two or three sentences: the conclusion through this lens.]

### Findings

#### [CRITICAL|WARNING|NOTE] <title>

- Location: `path/to/file.ext:line`
- Problem: [what is wrong and what it causes]
- Evidence: [failure scenario, cited rule or example, or quoted requirement]
- Fix: [smallest safe change, or a named follow-up]
- Confidence: [confirmed — traced or ran it | likely | uncertain]

### Questions

[Things you could not settle, each with what would settle it.]

### For other lenses

[One line each: lens, location, what you saw.]

### Checked

[What you examined, so that an empty Findings section can be trusted.]
```

Add the extra sections your lens file asks for after "Checked".
