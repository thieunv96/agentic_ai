<purpose>
Close a development version. Verify all phases passed evaluation. Create summary. Archive artifacts. Tag release.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Version: $ARGUMENTS (e.g., "v1.0")
Read: STATE.md, ROADMAP.md, all EVALUATION.md files.

## 2. Pre-Release Check

Verify all phases have EVALUATION.md with GO status.
If any phase has NO-GO or missing EVALUATION.md:
- List failing phases
- Error: "Cannot release — fix gaps first with: /ai-implement N --gaps-only"

## 3. Gather Stats

```bash
# Phase count
PHASES=$(ls .planning/phases/ | wc -l)
# Commit count since init
COMMITS=$(git log --oneline --since=$(git log --oneline | tail -1 | cut -d' ' -f1) | wc -l)
```

## 4. Create VERSION-SUMMARY.md

```markdown
# Version [X] Summary

## What Was Built
[Description from PROJECT.md]

## Phases Completed
[Table of phases with their goals]

## Key Metrics Achieved
| Metric | Target | Achieved |
|--------|--------|---------|

## Model Description
[Architecture, training approach, key design decisions]

## Known Limitations
[From EVALUATION.md gap analysis]
```

## 5. Archive .planning/

```bash
mkdir -p .planning/versions/[version]
cp .planning/ROADMAP.md .planning/versions/[version]/
cp .planning/PROJECT.md .planning/versions/[version]/
cp -r .planning/phases/ .planning/versions/[version]/
```

## 6. Reset STATE.md for Next Version

Update STATE.md: version complete, ready for next version.

## 7. Commit + Tag

```bash
node ".github/ai/bin/ai-tools.cjs" commit "docs: release [version] — [task-type] model" --files .planning/
git tag [version] -m "Release [version]: [brief description]"
```

## 8. Show Completion

```
---
✅ Version [X] Released

[Key metrics achieved]

Git tag: [version]
Summary: .planning/versions/[version]/VERSION-SUMMARY.md

---
**Start next version:** `/ai-new-version v{X+1}`
```

</process>
