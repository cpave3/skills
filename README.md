# Skills

A collection of skills for Claude Code.

## Installation

```bash
npx -y skills install cpave3/skills/<skill-name>
```

## Available Skills

| Skill | Description |
|---|---|
| `clean-ui` | Rules for clean UI, applied when building, changing, or reviewing any user interface |
| `lens-review` | Code review that runs each lens (correctness, security, architecture, consistency, tests and docs, scope) in its own subagent, then verifies and merges the findings into one report |

## Examples

```bash
npx -y skills install cpave3/skills/clean-ui
npx -y skills install cpave3/skills/lens-review
```
