---
name: my-map-codebase
description: Map an existing codebase into structured documents — architecture, stack, conventions, concerns
argument-hint: "[path]"
agent: my-codebase-mapper
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

<objective>
Analyze an existing codebase and produce structured reference documents in `.planning/codebase/`.
Useful before starting a new version on an existing project, or when integrating code references.

Creates 7 focused documents:
- STACK.md — languages, frameworks, dependencies
- ARCHITECTURE.md — patterns, layers, data flow
- STRUCTURE.md — directory layout, key files
- CONVENTIONS.md — coding standards, naming, patterns
- TESTING.md — test setup, patterns, coverage
- INTEGRATIONS.md — external services, model APIs, data sources
- CONCERNS.md — tech debt, known issues, anti-patterns

Usage: `/my-map-codebase` or `/my-map-codebase ./path/to/project`
</objective>

<execution_context>
@.github/my/workflows/map-codebase.md
</execution_context>

<context>
Path: $ARGUMENTS (optional — defaults to current directory)
</context>

<process>
Execute the map-codebase workflow from @.github/my/workflows/map-codebase.md end-to-end.
If a path is provided, analyze that directory. Otherwise analyze the current project root.
</process>
