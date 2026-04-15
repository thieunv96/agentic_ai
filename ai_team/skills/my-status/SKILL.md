---
name: my-status
description: Show current version progress, experiment results, and what to do next
argument-hint: ""
allowed-tools: Read, Bash, Glob, Grep
---

<objective>
Show a clear status snapshot:
- Current version and phase position
- Latest experiment metrics vs targets
- Completed/remaining phases
- Any blockers or gaps
- Recommended next command
</objective>

<execution_context>
@.github/my/workflows/status.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the status workflow from @.github/my/workflows/status.md end-to-end.
</process>
