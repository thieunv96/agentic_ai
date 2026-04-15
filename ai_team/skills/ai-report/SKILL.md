---
name: ai-report
description: Generate comprehensive ML project reports — session summary, experiment comparison, or full version recap
argument-hint: "[session|experiment|version]"
allowed-tools: Read, Write, Edit, Glob, Grep, Task
---

<objective>
Generate a structured Markdown report summarizing ML work.

Three report types:
- `session` (default): What happened in this session — files changed, experiments run, decisions made, open questions
- `experiment`: Compare all experiments across phases — metrics table, best run, config diffs, what worked/didn't
- `version`: Full version recap — from KNOWLEDGE.md to final model — phases, evaluations, key decisions, model card

Output: `.planning/reports/{type}-{date}.md`
For `version` reports also creates: `.planning/VERSION-REPORT.md` (permanent artifact)
</objective>

<execution_context>
@.github/ai/workflows/report.md
</execution_context>

<context>
Type: $ARGUMENTS (one of: session, experiment, version — defaults to session)
</context>

<process>
Execute the report workflow from @.github/ai/workflows/report.md end-to-end.
Always produce actionable insights beyond just listing what happened.
</process>
