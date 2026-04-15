---
name: asilla-provide-context
description: Ingest papers, code references, ideas, and knowledge base → auto research + create phase roadmap
argument-hint: "[--papers @file] [--refs path/] [--idea 'text'] [--update]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch, AskUserQuestion
---

<objective>
Ingest ML context (papers, code references, ideas, knowledge base) and automatically:
1. Organize into .planning/KNOWLEDGE.md
2. Run quick research (summarize papers, identify key approaches and challenges)
3. Create or update .planning/ROADMAP.md with ML phases
4. Commit: "docs: setup context for {version}"
5. Prompt user to discuss Phase 1

Use --update flag when adding more context to an existing version mid-cycle.
</objective>

<execution_context>
@.github/asilla/workflows/provide-context.md
@.github/asilla/references/ml-experiments.md
</execution_context>

<context>
Arguments: $ARGUMENTS

Flags:
- --papers @file.pdf  — Attach a paper PDF or markdown summary
- --refs path/        — Point to code reference directory
- --idea "text"       — Free-form idea or requirement text
- --update            — Update existing KNOWLEDGE.md (don't reset phases)
</context>

<process>
Execute the provide-context workflow from @.github/asilla/workflows/provide-context.md end-to-end.
</process>
