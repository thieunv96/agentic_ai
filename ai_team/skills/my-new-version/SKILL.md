---
name: my-new-version
description: Initialize a new ML/AI development version with PROJECT.md, requirements, and STATE
argument-hint: "<version-name>"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Initialize a new ML/AI project version. Creates the .planning/ structure, asks ML-focused questions (task type, dataset, target metrics, compute), and prepares STATE.md for the first context-providing step.
</objective>

<execution_context>
@.github/my/workflows/new-version.md
</execution_context>

<context>
Version name: $ARGUMENTS
</context>

<process>
Execute the new-version workflow from @.github/my/workflows/new-version.md end-to-end.
</process>
