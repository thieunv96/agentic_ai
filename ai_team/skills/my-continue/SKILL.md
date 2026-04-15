---
name: my-continue
description: Auto-detect the next step in the current workflow and run it
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Read STATE.md to determine where we are and automatically run the appropriate next command.
Examples:
- After new-version → runs my-provide-context
- After provide-context → runs my-discuss 1
- After discuss N → runs my-plan N
- After plan N → runs my-implement N
- After implement N → runs my-evaluate N
- After evaluate N (passed) → runs my-discuss N+1 or my-release-version
- After evaluate N (failed) → runs my-implement N --gaps-only
</objective>

<execution_context>
@.github/my/workflows/continue.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the continue workflow from @.github/my/workflows/continue.md end-to-end.
</process>
