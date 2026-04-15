---
name: ai-implement
description: Execute phase plans — implement ML code with atomic commits and SUMMARY.md
argument-hint: "<phase-number> [--wave N] [--gaps-only] [--interactive]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, TodoWrite, AskUserQuestion
---

<objective>
Execute all plans in a phase using wave-based parallel execution.
ML-aware: handles Python/PyTorch code, training scripts, data pipelines, experiment logging.
Each executor spawns with fresh context. Produces SUMMARY.md per plan.
</objective>

<execution_context>
@.github/ai/workflows/implement.md
@.github/ai/references/ml-experiments.md
</execution_context>

<context>
Phase: $ARGUMENTS

Flags:
- --wave N       Execute only Wave N
- --gaps-only    Execute only gap-closure plans (after evaluate creates fix plans)
- --interactive  Sequential inline execution, pair-programming style
</context>

<process>
Execute the implement workflow from @.github/ai/workflows/implement.md end-to-end.
</process>
