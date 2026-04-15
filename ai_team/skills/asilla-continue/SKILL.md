---
name: asilla-continue
description: Auto-detect the next step in the current workflow and run it
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Read STATE.md to determine where we are and automatically run the appropriate next command.
Examples:
- After new-version → runs asilla-provide-context
- After provide-context → runs asilla-discuss 1
- After discuss N → runs asilla-plan N
- After plan N → runs asilla-implement N
- After implement N → runs asilla-evaluate N
- After evaluate N (passed) → runs asilla-discuss N+1 or asilla-release-version
- After evaluate N (failed) → runs asilla-implement N --gaps-only
</objective>

<execution_context>
@.github/asilla/workflows/continue.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the continue workflow from @.github/asilla/workflows/continue.md end-to-end.
</process>
