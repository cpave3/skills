---
name: burnlite
description: >
  Guide for interacting with the Burnlite project/task management MCP server.
  Use when the user mentions burnlite, references burnlite task XML, asks about
  project progress/estimates, or wants to create/update/plan tasks, milestones,
  subtasks, or notes in their project tracker. Also use when the user pastes a
  <burnlite> XML reference block.
---

## Data Model

Projects contain milestones, which contain tasks. Tasks have:

- **Size**: Small, Medium, Large, X-Large (effort estimate)
- **Uncertainty**: Low, Medium, High, Extreme (confidence in estimate)
- **Plan**: Markdown text field for implementation plans
- **Subtasks**: Checklist items within a task
- **Notes**: Timestamped markdown notes attached to a task
- **Actual days**: Recorded after completion for estimation calibration

## Task References

The user may paste an XML reference block:

```xml
<burnlite ref="task">
  <project id="..."/>
  <milestone id="..."/>
  <task id="..."/>
</burnlite>
```

Use `view_task_details` with the task id directly — the project/milestone ids are context only. Use `view_project_tasks` if broader context is needed.

## MCP Resources

For a quick overview without multiple tool calls:

- `burnlite://projects/summary` — all projects with stats
- `burnlite://project/{projectId}` — full project detail

Read these via the MCP resource reader when the user asks broad questions about progress or project status.

## Key Workflows

### Implementing a task

1. Fetch task details via `view_task_details`
2. Read the `plan` field if present — it contains the implementation approach
3. Review `notes` and `subtasks` for additional context
4. Implement, then mark subtasks done with `update_subtask` as you go
5. When finished, mark the task complete with `complete_task` (record `actualDays` if known)

### Planning a task

1. Fetch task details via `view_task_details`
2. Review existing `plan`, `notes`, and `subtasks`
3. Investigate the codebase and formulate an approach
4. **Ask the user** before storing — offer to save findings as the task's plan via `update_task` with the `plan` field
5. If accepted, write or update the plan. Add subtasks for discrete steps if appropriate.

### Reviewing progress

1. Read `burnlite://projects/summary` for a high-level overview
2. Use `view_project_tasks` for milestone-level breakdown
3. Summarize completion stats, in-progress work, and upcoming tasks

### Creating project structure

Use `create_project`, `create_milestone`, and `add_task_to_project` to scaffold new work. Every task requires `size` and `uncertaintyLevel` — ask the user if not obvious from context.
