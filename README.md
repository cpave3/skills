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
| `release-note-trailers` | Release notes kept as `Release-Note:` git trailers, written on the commit by whoever made the change and collected from the commit range at release time |
| `scenario-testing` | Works out how a feature will really be used, writes concrete scenarios, traces each one through the code in its own subagent, and reports which the code handles, breaks on, or never decided |

## Examples

```bash
npx -y skills install cpave3/skills/clean-ui
npx -y skills install cpave3/skills/lens-review
npx -y skills install cpave3/skills/release-note-trailers
npx -y skills install cpave3/skills/scenario-testing
```
