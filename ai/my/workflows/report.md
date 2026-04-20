<purpose>
Generate structured ML project reports.
Three types: session (what happened), experiment (metrics comparison), version (full recap).
Output: .note/reports/{type}-{date}.md
</purpose>

<process>

## 1. Setup

Parse from $ARGUMENTS: type = `session` | `experiment` | `version` (default: `session`)

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init report "0")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read: STATE.md, PROJECT.md, ROADMAP.md

Create: `mkdir -p .note/reports`

Get date: `DATE=$(date +%Y-%m-%d)`

## 2. Generate Report

### Session Report

Read:
- STATE.md → recent activity section
- All SUMMARY.md files modified today (git log --since="today")
- Any EVALUATION.md files created today

Produce `.note/reports/session-{date}.md`:

```markdown
# Session Report — {date}

## What Was Done
[Chronological list of completed tasks/phases with commit refs]

## Experiments Run
[Any training runs, evaluations, quantization done today]
| Experiment | Config | Key Metric | Notes |
|-----------|--------|------------|-------|

## Decisions Made
[Key architectural, training, or data decisions]

## Files Changed
[Key files added/modified — not exhaustive, just significant ones]

## Open Questions
[Unresolved issues or decisions deferred]

## Next Session
[Natural next step based on ROADMAP.md and STATE.md]
```

### Experiment Report

Read:
- All EVALUATION.md files across all phases
- All experiment log files (wandb exports, tensorboard events if accessible)
- KNOWLEDGE.md → papers section (for context)

Produce `.note/reports/experiments-{date}.md`:

```markdown
# Experiment Comparison Report — {date}

## Project: {name} | Version: {version}

## Experiments Summary

| Phase | Experiment | Architecture | Dataset | Key Metric | Value | Config Highlights | Notes |
|-------|-----------|-------------|---------|------------|-------|------------------|-------|
[one row per experiment from EVALUATION.md files]

## Best Run
**Phase/Exp:** {ref}
**Config:** {key settings}
**Metric:** {value}
**Why it worked:** {analysis from EVALUATION.md]

## What Didn't Work
[Failed experiments with brief explanation]

## Patterns Found
[Cross-experiment insights: what hyperparams matter, what architecture choices matter]

## Recommendations
[What to try next based on patterns]
```

### Version Report

Read ALL planning artifacts:
- KNOWLEDGE.md, PROJECT.md, ROADMAP.md, STATE.md
- All phase CONTEXT.md, PLAN.md, SUMMARY.md, EVALUATION.md files
- Any QUANTIZATION-REPORT.md files

Produce `.note/VERSION-REPORT.md` (permanent) + `.note/reports/version-{version}-{date}.md`:

```markdown
# Version Report: {version}

*Generated: {date}*

## Overview
[2-3 sentence summary of what was built]

## Original Goal vs Achieved
| Goal | Status | Notes |
|------|--------|-------|
[from PROJECT.md targets]

## Journey: Phases
[For each phase: name, goal, key decision, outcome, primary metric]

## Final Model
- **Architecture:** {description}
- **Task:** {task}
- **Dataset:** {name, size, split}
- **Training:** {epochs, optimizer, LR, batch size, GPU/time}
- **Best Checkpoint:** {path}
- **Quantized Formats:** {if applicable}

## Metrics vs Targets
| Metric | Target | Achieved | Delta |
|--------|--------|----------|-------|

## Key Decisions
[5-10 most important decisions made and why]

## What Worked / What Didn't
[Honest retrospective]

## Model Card
[HuggingFace-style model card for sharing]

## References
[Papers from KNOWLEDGE.md that were actually used]
```

## 3. Output

Show summary to user:

```
---
## 📊 Report Generated

**Type:** {type}
**File:** `.note/reports/{filename}`

{brief highlights — 3-5 key points from the report}

---
```

</process>
