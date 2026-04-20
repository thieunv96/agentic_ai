---
name: my-research
description: Deep ML/CV/VLM research — quick scan or full literature survey on any topic, gray-area or cutting-edge
argument-hint: "[--quick|--deep] <topic>"
agent: my-researcher
allowed-tools: Read, Write, Edit, Glob, Grep, Task, WebSearch, WebFetch
---

<objective>
Perform focused research on an ML/CV/VLM topic at any point in the workflow.
Two modes:
- `--quick` (default): Fast scan → 3-5 top papers/repos, key findings, recommendation. Compact RESEARCH.md.
- `--deep`: Full literature survey → landscape map, approach comparison, gap analysis, structured synthesis.

Prioritizes gray-area / frontier topics: under-explored techniques, recent papers not yet mainstream, promising directions.

Output: `.note/research/{slug}-RESEARCH.md`
</objective>

<execution_context>
@.github/my/workflows/research.md
@.github/my/references/ml-experiments.md
</execution_context>

<context>
Arguments: $ARGUMENTS

Flags:
- --quick   Fast mode: 3-5 papers, key findings, recommendation (default)
- --deep    Full survey: landscape, comparison, gaps, synthesis
Topic: remainder of $ARGUMENTS after flag
</context>

<process>
Execute the research workflow from @.github/my/workflows/research.md end-to-end.
Focus on cutting-edge / gray-area aspects of the topic.
Always produce actionable findings, not just summaries.
</process>
