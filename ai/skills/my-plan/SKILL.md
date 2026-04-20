---
name: my-plan
description: Create detailed PLAN.md for a phase with ML-aware task decomposition
argument-hint: "<phase-number> [--skip-research] [--gaps] [--auto]"
agent: my-planner
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch
---

<objective>
Create executable PLAN.md files for a phase. Spawns my-planner with ML context.
Default flow: Research (via my-researcher) → Plan → Verify with my-plan-checker → Done
Commit: "docs: plan phase {N} - {name}"
</objective>

<execution_context>
@.github/my/workflows/plan.md
@.github/my/references/ml-experiments.md
</execution_context>

<context>
Phase: $ARGUMENTS

Flags:
- --skip-research  Skip research, go straight to planning
- --gaps           Gap closure mode (reads EVALUATION.md for failed criteria)
- --auto           Non-interactive, pick best defaults
</context>

<process>
Execute the plan workflow from @.github/my/workflows/plan.md end-to-end.
</process>
