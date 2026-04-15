---
name: my-release-version
description: Close a version — verify all phases passed, archive artifacts, create summary, tag release
argument-hint: "<version> (e.g. v1.0)"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---

<objective>
Close out a development version:
1. Verify all phases have passing evaluations
2. Create VERSION-SUMMARY.md with: phases completed, key metrics achieved, model description
3. Archive .planning/ artifacts to .planning/versions/v{X}/
4. Create git tag v{X}
5. Update STATE.md for next version or project completion
Blocks if any phase has a failing evaluation — must fix gaps first.
</objective>

<execution_context>
@.github/my/workflows/release-version.md
</execution_context>

<context>
Version: $ARGUMENTS
</context>

<process>
Execute the release-version workflow from @.github/my/workflows/release-version.md end-to-end.
</process>
