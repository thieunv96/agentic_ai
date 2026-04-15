---
name: ai-evaluate
description: Evaluate ML model performance — metrics vs targets, error analysis, go/no-go decision
argument-hint: "<phase-number> [--quick] [--full]"
agent: ai-evaluator
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Evaluate the model built in a phase against target metrics and baseline.
Creates EVALUATION.md with:
- Quantitative metrics (accuracy, mAP, BLEU, etc.) vs targets from CONTEXT.md
- Training convergence analysis (loss curves, if applicable)
- Qualitative examples (model output samples)
- Go/no-go decision + gap closure plans if needed
Commit: "docs: evaluation phase {N} - {metric}={value}"
</objective>

<execution_context>
@.github/ai/workflows/evaluate.md
@.github/ai/references/ml-verification.md
@.github/ai/references/ml-experiments.md
</execution_context>

<context>
Phase: $ARGUMENTS

Flags:
- --quick  Fast evaluation (key metrics only, no qualitative analysis)
- --full   Comprehensive evaluation including error analysis and qualitative samples
</context>

<process>
Execute the evaluate workflow from @.github/ai/workflows/evaluate.md end-to-end.
</process>
