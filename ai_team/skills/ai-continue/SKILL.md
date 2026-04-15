---
name: ai-continue
description: Auto-detect the next step in the current workflow and run it
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Read STATE.md to determine where we are and automatically run the appropriate next command.
Examples:
- After new-version → runs ai-provide-context
- After provide-context → runs ai-discuss 1
- After discuss N → runs ai-plan N
- After plan N → runs ai-implement N
- After implement N → runs ai-evaluate N
- After evaluate N (passed) → runs ai-discuss N+1 or ai-release-version
- After evaluate N (failed) → runs ai-implement N --gaps-only
</objective>

<execution_context>
@.github/ai/workflows/continue.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the continue workflow from @.github/ai/workflows/continue.md end-to-end.
</process>
