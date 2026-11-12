---
name: clean-ui
description: Rules for clean UI, applied to any user interface work. Use when building, changing, or reviewing a screen, page, component, dialog, or the text inside one, in any framework, and when the user states a UI preference that should become a rule.
---

# Clean UI

Each rule is one file in [`references/`](references/). This file routes: it says when each rule applies. The rule file owns the rule itself, its test, and its examples.

## Rules

| Rule | Read it when |
| --- | --- |
| [Reassuring copy](references/reassuring-copy.md) | The work adds or changes any text a user sees: headings, subtitles, helper text, empty states, tooltips, badges, footers, dialogs. |

## Applying the rules

1. Before you write UI code, read every rule whose condition matches the work.
2. Build to those rules from the start.
3. Before you hand the work back, run each rule's check against what you changed. The work is done when every matching rule's check passes on every element you added or changed.

When the task is a review, run the same checks against the changeset and report each failure with its file and line, the rule it breaks, and the fix.

A rule yields to an explicit instruction in the current request. Say which rule you set aside.

## Adding a rule

When the user states a UI preference that should outlast the task, write it as a new file in `references/` with the same sections as the existing rules (the rule, the test, where it shows up, the fix, the check), and add a row to the table above. The row's condition is the pointer: name the kind of work that should trigger the rule, in the words the user uses for it.
