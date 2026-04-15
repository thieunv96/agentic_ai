---
name: ai-debug
description: Systematic debugging of ML/training/evaluation issues
argument-hint: "<issue description>"
agent: ai-debugger
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

<objective>
Diagnose and fix ML development issues:
- Training issues: loss not converging, NaN/inf, OOM errors, slow training
- Data pipeline issues: corrupt data, shape mismatches, augmentation bugs
- Model issues: architecture errors, weight loading, inference failures
- Evaluation issues: metric calculation errors, benchmark mismatches
Produces DEBUG.md with root cause + fix applied.
</objective>

<execution_context>
@.github/ai/workflows/debug.md
</execution_context>

<context>
Issue: $ARGUMENTS
</context>

<process>
Execute the debug workflow from @.github/ai/workflows/debug.md end-to-end.
</process>
