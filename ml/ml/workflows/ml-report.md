<purpose>
Consolidate session, experiment, or version results into a structured report.
Synthesize 2–3 concrete next-step recommendations based on findings.
Command: `/ml-report` (session, default) | `/ml-report experiment` | `/ml-report version`
Reads: `.works/[v]/STATE.md`, `ROADMAP.md`, relevant EVALUATION.md and SUMMARY.md files
Writes: `.works/reports/[type]-[date].md`, `.works/VERSION-REPORT.md` (version type only)
Commit: none — per commit discipline
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Load from STATE.md first, not from conversation.** STATE.md is the single source of truth for session history. Read it before reading any EVALUATION.md or SUMMARY.md files.

**Read only what you need per report type:**
- `session` → only files modified today (from git log --since=midnight)
- `experiment` → all EVALUATION.md files in .works/[v]/
- `version` → everything in .works/[v]/

**Spawn ml-context-keeper at start** if STATE.md is stale or missing. A current STATE.md makes the report faster and more accurate.

**Context volume warning:** Version reports read many files. If the total file content would exceed 50% of context, spawn ml-context-keeper first to get a compressed STATE.md, then read only STATE.md + EVALUATION.md files (skip PLAN.md and CONTEXT.md files — their key facts are already in STATE.md).

**Question discipline:** The end-of-pipeline question (Step 6) uses `ml-ask` Type 5 (Next Step) format — show the full pipeline status summary before asking.

</context_management>

<process>

## 1. Setup

Parse `$ARGUMENTS` (default to `session` if not specified):
- `session` → report on today's activity only
- `experiment` → compare all experiment runs across phases
- `version` → full version retrospective

Read in parallel (skip missing):
- `.works/[v]/STATE.md` — current phase, version, last run info
- `ROADMAP.md` — planned phases and goals for the version
- `VERSION` file — current version string

Create `.works/reports/` if it does not exist.
Set `DATE=$(date +%Y-%m-%d)`.

## 2. Session Report

Scope: today's activity only.

Collect input:
- All SUMMARY.md and EVALUATION.md files modified today:
  ```bash
  git log --since="midnight" --name-only --pretty=format: | grep -E "SUMMARY|EVALUATION"
  ```
- Commit messages from today: `git log --since="midnight" --oneline`

Write `.works/reports/session-$DATE.md`:

```markdown
# Session Report — [date]

**Version:** [version]
**Duration:** [start time if known – end time]

## What Was Accomplished

| Phase | Activity | Commit | Status |
|-------|----------|--------|--------|
| [N] | [implement / test / doc / discuss] | [short hash] | Done / Partial |

## Experiments Run

| Phase | Run | Key Config Change | Metric | Result |
|-------|-----|-------------------|--------|--------|
| [N] | [run label] | [what was different] | [metric] | [value] |

[If no experiments: "No evaluation runs recorded today."]

## Key Decisions Made

[From CONTEXT.md files modified or created today]
- [Decision 1 — what was locked and why]
- [Decision 2]

[If none: "No requirements locked today."]

## What Was NOT Completed

[Honest accounting of planned items that weren't finished]
- [Item 1 — what and why it wasn't done]

[If all items done: "All planned items for this session were completed."]

## Blockers and Open Questions

[Issues that need resolution before next session]
- [Blocker 1 — what it is and what's needed to unblock]

[If none: "No blockers."]

## Recommended Next Session

Based on current `STATE.md` and `ROADMAP.md`:

1. **[Next action]** — because [reason from today's findings]
   Command: `/ml-[command] [args]`

2. **[Alternative if a blocker isn't resolved]**
   Command: `/ml-[command] [args]`
```

## 3. Experiment Report

Scope: all experiment runs across all phases for this version.

Collect input:
- All `$WORKS_DIR/*-EVALUATION.md` files in chronological order
- `$WORKS_DIR/KNOWLEDGE.md` → papers/refs section

Write `.works/reports/experiments-$DATE.md`:

```markdown
# Experiment Comparison — [date]

**Version:** [version]
**Total runs:** [count]

## Summary Table

| Phase | Run Label | Architecture / Key Change | Dataset / Split | Metric | Value | vs Baseline |
|-------|-----------|--------------------------|-----------------|--------|-------|-------------|

## Best Run

**Config:** [key settings that differentiate this run]
**Metric:** [value]
**Why it worked:** [analysis — what was different and why it mattered]

## What Did Not Work

| Run | What Was Tried | Result | Root Cause |
|-----|---------------|--------|-----------|

## Cross-Experiment Patterns

[Insights that appear across multiple runs]
- [Pattern 1 — e.g., "LR above 3e-4 consistently degrades small-object mAP"]
- [Pattern 2]

## Recommended Next Experiment

Based on the patterns above:

**Try:** [specific config change]
**Expected:** [what metric you expect to move and in which direction]
**Command:** `/ml-implement [N] --wave [W]` after updating `[N]-PLAN.md` with the change
```

## 4. Version Report

Scope: everything in the current version — full retrospective.

Collect input: read ALL of the following:
- `ROADMAP.md`, `REQUIREMENTS.md`, `.works/[v]/STATE.md`
- All `$WORKS_DIR/[N]-CONTEXT.md` files (in phase order)
- All `$WORKS_DIR/[N]-PLAN.md` files
- All `$WORKS_DIR/[N]-SUMMARY.md` files
- All `$WORKS_DIR/[N]-EVALUATION.md` files
- `VERSION` file

Write `.works/reports/version-$VERSION-$DATE.md` AND `.works/VERSION-REPORT.md` (permanent):

```markdown
# Version Report: [version]

*Generated: [date]*

## Original Goal vs Achieved

| Goal | Target | Achieved | Delta | Status |
|------|--------|----------|-------|--------|
| [goal from ROADMAP] | [metric target] | [actual] | [+/-] | Met / Not met |

## Phase Journey

| # | Phase | Original Goal | Key Decision | Outcome | Primary Metric |
|---|-------|--------------|-------------|---------|---------------|
| 1 | [name] | [what was planned] | [most important choice made] | [result] | [value] |

## Final Model

- **Architecture:** [description]
- **Training:** [epochs, optimizer, LR schedule, batch size, hardware, wall-clock time]
- **Best Checkpoint:** [path]
- **Quantized Formats:** [e.g., INT8 ONNX at outputs/v1.0/model-int8.onnx, or "none"]

## Metrics Summary

| Metric | Baseline | Target | Achieved | Status |
|--------|----------|--------|----------|--------|

## Key Decisions — Top 5

1. **[Decision]** — [why it mattered, what it enabled or prevented]
2. ...

## What Worked Well

- [Thing 1 — specific, not generic]
- [Thing 2]

## What Did Not Work

- [Thing 1 — what was tried, why it failed, what was learned]
- [Thing 2]

## Recommendations for Next Version

1. **[Recommendation]** — because [evidence from this version]
2. **[Recommendation]** — because [evidence from this version]

## Model Card

**Model name:** [name]
**Task:** [task description]
**Input:** [format, size, dtype]
**Output:** [format, structure]
**Performance:** [key metrics]
**Limitations:** [known failure modes]
**Training data:** [dataset, size, source]
**Checkpoint:** [path]
```

## 5. Synthesize Next Steps

After the report is written, analyze the content and produce 2–3 concrete, actionable next steps — not generic advice.

Display them prominently:

```
---
Report saved: .works/reports/[filename]

Recommended next steps based on findings:

1. [Specific action] — [reason grounded in report findings]
   → /ml-[command] [args]

2. [Specific action] — [reason]
   → /ml-[command] [args]

3. [Optional third if warranted]
   → /ml-[command] [args]
---
```

**No commit** — per commit discipline.

## 6. Ask User — End of Pipeline

The report is the final stage of the implement → test → doc → report pipeline.
The pipeline pauses here because what comes next requires a human decision:
start a new phase, a new version, or stop.

```
ask_user:
  question: |
    Pipeline complete for Phase [N].

    Summary:
    • Implementation: committed (feat(phase-[N]))
    • Evaluation: [GO / CONDITIONAL]
    • Documentation: committed (docs($VERSION))
    • Report: .works/reports/session-[date].md

    Recommended next steps:
    1. [Recommendation 1 from Step 5 — specific command]
    2. [Recommendation 2 from Step 5 — specific command]

    What would you like to do?
  choices:
    - "[Recommendation 1 — shown with command]"
    - "[Recommendation 2 — shown with command]"
    - "Start next phase — /ml-discuss [N+1]"
    - "Start next version — /ml-new-version"
    - "Stop here"
    - "Other — I'll describe what I need"
```

</process>
