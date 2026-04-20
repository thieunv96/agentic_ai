<purpose>
Close a development version. Verify all phases passed evaluation. Generate documentation. Clean up intermediate artifacts. Tag release.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Version: `$ARGUMENTS` (e.g., "v1.0")
Read in parallel: STATE.md, ROADMAP.md, all EVALUATION.md files.

Determine `version_dir` from config:
```bash
VERSION=$(node ".github/my/bin/my-tools.cjs" config get current_version)
# All .note/ paths resolve to .note/{VERSION}/ via planningPaths()
```

## 2. Pre-Release Check

Verify all phases in ROADMAP.md have EVALUATION.md with GO status.
If any phase has NO-GO or missing EVALUATION.md:
- List failing phases
- Error: "Cannot release — fix gaps first with: `/my-implement N --gaps-only`"

## 3. Gather Stats

```bash
PHASES=$(ls .note/$VERSION/phases/ | wc -l)
COMMITS=$(git log --oneline $(git log --oneline | tail -1 | awk '{print $1}')..HEAD | wc -l)
```

## 4. Create VERSION-SUMMARY.md

Create `.note/[version]/VERSION-SUMMARY.md`:

```markdown
# Version [X] Summary

## What Was Built
[Description from PROJECT.md]

## Phases Completed
| Phase | Goal | Key Result |
|-------|------|-----------|

## Key Metrics Achieved
| Metric | Target | Achieved |
|--------|--------|---------|

## Model Description
[Architecture, training approach, key design decisions from CONTEXT.md files]

## Known Limitations
[From EVALUATION.md gap analysis sections]

## Traceability
- Requirements: `.note/[version]/REQUIREMENTS.md`
- Phase decisions: `.note/[version]/phases/*/[N]-CONTEXT.md`
- Evaluation results: `.note/[version]/phases/*/EVALUATION.md`
```

## 5. Generate Documentation

Run the documentation workflow for the complete version:

```
/my-doc --release
```

This creates `{docs_dir}/[version]/index.md` synthesizing all phase docs and updates `{docs_dir}/CHANGELOG.md`.

(If `/my-doc --phase N` was not run for some phases, the release doc step will generate those too.)

## 6. Clean Up Intermediate Artifacts

Remove intermediate artifacts that are no longer needed after release. **Keep all context files for traceability.**

```bash
# Remove PLAN.md files (intermediate implementation details)
find .note/$VERSION/phases/ -name "*-PLAN.md" -delete

# Remove SUMMARY.md files (execution logs)
find .note/$VERSION/phases/ -name "*-SUMMARY.md" -delete

# Remove per-session debug files (keep knowledge-base.md)
find .note/$VERSION/debug/ -type f ! -name "knowledge-base.md" -delete 2>/dev/null || true

# Remove intermediate RESEARCH.md (phase-level, already synthesized)
find .note/$VERSION/phases/ -name "RESEARCH.md" -delete
```

**Files KEPT for traceback:**
- `PROJECT.md` — what was built and why
- `REQUIREMENTS.md` — requirement IDs and traceability
- `ROADMAP.md` — phase breakdown and goals
- `STATE.md` — final state at release
- `KNOWLEDGE.md` — papers, references, key insights
- `VERSION-SUMMARY.md` — release summary
- `phases/*/[N]-CONTEXT.md` — locked decisions (key for traceback)
- `phases/*/[N]-DISCUSSION-LOG.md` — audit trail
- `phases/*/EVALUATION.md` — metrics achieved

## 7. Clear Active Version

After cleanup, clear `current_version` so the next `/my-new-version` starts fresh:

```bash
node ".github/my/bin/my-tools.cjs" config set current_version ""
```

(New `.note/` paths will fall back to `.note/` root until next version is initialized.)

## 8. Commit + Tag

```bash
node ".github/my/bin/my-tools.cjs" commit "chore: release [version] — [task-type] model" --files .note/[version]/VERSION-SUMMARY.md .note/[version]/STATE.md .note/config.json
git tag [version] -m "Release [version]: [brief description]"
```

## 9. Show Completion

```
---
✅ Version [X] Released

[Key metrics achieved]

Git tag: [version]
Summary: .note/[version]/VERSION-SUMMARY.md
Docs:    {docs_dir}/[version]/

Context preserved at: .note/[version]/
  - Project definition, requirements, roadmap
  - Phase decisions (CONTEXT.md) and evaluation results

---
**Start next version:** `/my-new-version v{X+1}`
```

</process>
