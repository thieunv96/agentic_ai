<purpose>
Close a development version. Verify all phases passed evaluation. Create summary. Archive artifacts. Tag release.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Version: $ARGUMENTS (e.g., "v1.0")
Read: STATE.md, ROADMAP.md, all EVALUATION.md files.

## 2. Pre-Release Check

Verify all phases have EVALUATION.md with GO status.
If any phase has NO-GO or missing EVALUATION.md:
- List failing phases
- Error: "Cannot release — fix gaps first with: /my-implement N --gaps-only"

## 3. Gather Stats

```bash
# Phase count
PHASES=$(ls .note/phases/ | wc -l)
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

## 5. Archive .note/

```bash
mkdir -p .note/versions/[version]
cp .note/ROADMAP.md .note/versions/[version]/
cp .note/PROJECT.md .note/versions/[version]/
cp -r .note/phases/ .note/versions/[version]/
```

## 6. Reset STATE.md for Next Version

Update STATE.md: version complete, ready for next version.

## 7. Commit + Tag

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: release [version] — [task-type] model" --files .note/
git tag [version] -m "Release [version]: [brief description]"
```

## 8. Show Completion

```
---
✅ Version [X] Released

[Key metrics achieved]

Git tag: [version]
Summary: .note/versions/[version]/VERSION-SUMMARY.md

---
**Start next version:** `/my-new-version v{X+1}`
```

</process>
