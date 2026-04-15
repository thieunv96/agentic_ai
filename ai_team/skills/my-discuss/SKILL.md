---
name: my-discuss
description: Discuss phase decisions for CV/VLM development — locks choices into CONTEXT.md and logs discussion
argument-hint: "<phase-number> [--auto] [--batch]"
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
---

<objective>
Discuss and lock implementation decisions for a phase before planning begins.
Creates {N}-CONTEXT.md (consumed by planner) and {N}-DISCUSSION-LOG.md (audit trail).
For ML/CV/VLM phases: architecture choices, training strategy, dataset handling, evaluation metrics.
</objective>

<execution_context>
@.github/my/workflows/discuss.md
</execution_context>

<context>
Phase: $ARGUMENTS

Flags:
- --auto   Agent picks recommended defaults without asking
- --batch  Present all decisions at once
</context>

<process>
Execute the discuss workflow from @.github/my/workflows/discuss.md end-to-end.
Always generate DISCUSSION-LOG.md at the end.
</process>
