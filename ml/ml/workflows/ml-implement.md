<purpose>
Execute a phase plan autonomously in wave order. No user confirmation between tasks or waves.
Command: `/ml-implement [N]` | `/ml-implement [N] --wave W` | `/ml-implement [N] --gaps-only`
Reads: `.works/[v]/[N]-CONTEXT.md`, `.works/[v]/[N]-PLAN.md`, `REQUIREMENTS.md`
Writes: source files, `.works/[v]/[N]-SUMMARY.md`
Commit: `feat(phase-N): implement [phase-name]` — this is the phase implement complete commit point
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Spawn ml-executor per wave.** Do NOT execute waves inline — spawn a fresh **ml-executor** agent for each wave to keep the main context clean. Each agent gets only the files it needs for that wave.

**Codebase map:** Instead of passing full source files to ml-executor, pass the relevant chunk files from `.works/[v]/codebase/chunks/`. Chunks are pre-parsed and < 80 lines — significantly cheaper than the original source. Query RETRIEVAL-INDEX.md to find the right chunk for each task.

**Agent spawn — ml-executor (Step 3, once per wave):**
```
<files_to_read>
- .works/[v]/[N]-CONTEXT.md
- .works/[v]/[N]-PLAN.md
- REQUIREMENTS.md
- [source files referenced in this wave's tasks]
</files_to_read>
Execute Wave [W]: [wave name]
Tasks: [list task IDs for this wave only]
Flag any R4 architecture conflicts immediately.
```

**Spawn ml-context-keeper when:**
- Completing each wave (to update STATE.md before next wave)
- Context is ~70% full

**SUMMARY.md assembly:** After all wave agents return, assemble SUMMARY.md from their reports inline — do not re-spawn for this.

</context_management>

<process>

## 1. Setup

Read the following in parallel (skip files that do not exist):

- `.works/[v]/[N]-CONTEXT.md` — locked decisions, hard constraints, success criteria
- `.works/[v]/[N]-PLAN.md` — wave structure, task list, acceptance criteria per task
- `REQUIREMENTS.md` — project-wide constraints (these are non-negotiable)
- `.works/[v]/STATE.md` — current phase and progress

Determine `VERSION` from STATE.md or from the `[N]` argument context.
Set `WORKS_DIR=.works/$VERSION/`.

Parse flags:
- `--wave W` — execute only Wave W (skip all others)
- `--gaps-only` — execute only tasks marked PARTIAL or FAILED in the existing SUMMARY.md
- No flag — execute all waves in order from Wave 1

## 2. Validate Pre-conditions

Before executing anything, verify:

- `$WORKS_DIR/[N]-CONTEXT.md` exists
- `$WORKS_DIR/[N]-PLAN.md` exists and has at least one wave defined

If any pre-condition fails, output a clear error message and stop immediately:

```
Error: Missing [filename].
To fix: run /ml-discuss [N] to create CONTEXT.md, then /ml-plan [N] to create PLAN.md.
```

Do NOT ask the user — just report the missing dependency and stop.

## 3. Execute Waves — Spawn ml-executor Per Wave

For each wave, spawn a **ml-executor** agent. Do NOT execute inline — keep the main context clean.

```
<files_to_read>
- .works/$VERSION/[N]-CONTEXT.md
- .works/$VERSION/[N]-PLAN.md
- REQUIREMENTS.md
- [list source files referenced in this wave's tasks]
</files_to_read>
Execute Wave [W]: [wave name]
Tasks: [list task IDs for this wave, e.g., 1.1, 1.2, 1.3]
Apply deviation rules R1-R3 automatically. Flag R4 conflicts immediately without proceeding.
```

The ml-executor agent returns a wave execution report:
```
Wave [W] — [N] tasks: DONE:[n] PARTIAL:[n] FAILED:[n]
Files modified: [list]
Deviations applied: [R1-R3 list or "None"]
Blockers for user: [R4 conflicts or "None"]
```

**After each wave:** spawn **ml-context-keeper** to update STATE.md before starting the next wave.

Do NOT abort on a single task failure — record and proceed to the next wave.

## 4. Write `[N]-SUMMARY.md`

After all waves complete (or after the single wave if `--wave` flag was used), write:
`.works/$VERSION/[N]-SUMMARY.md`

```markdown
# Implementation Summary: Phase [N] — [Phase Name]

**Date:** [date]
**Version:** [version]
**Status:** Complete / Partial / Has Gaps

## Waves Executed

### Wave 1: [Name]

| Task | Status | Output |
|------|--------|--------|
| [Task 1.1 title] | DONE | [output files] |
| [Task 1.2 title] | PARTIAL | [output] — gap: [description] |

### Wave 2: [Name]

| Task | Status | Output |
|------|--------|--------|
| [Task 2.1 title] | DONE | [output files] |

## Files Changed

[Alphabetical list of all files created or modified]

## Gaps / Partial Items

[List each PARTIAL or FAILED task with a description of what remains]
[Empty if all tasks are DONE]

## Next Step

Run `/ml-test [N]` to validate this implementation.
[If gaps exist: "Or run `/ml-implement [N] --gaps-only` to address the gaps first."]
```

## 5. Commit

After writing SUMMARY.md, commit all phase output as a single commit.

```
git add src/ .works/$VERSION/[N]-SUMMARY.md
git commit -m "feat(phase-[N]): implement [phase-name]"
```

Use the correct type prefix:
- `feat` — new feature or capability
- `fix` — bug fix
- `data` — data pipeline changes
- `train` — training script changes
- `eval` — evaluation changes

This is the **phase implement complete** commit point per commit discipline.
Only commit if at least one wave completed with at least one DONE task.

## 6. Auto-Proceed to Test

```
---
✓ Implementation committed — Phase [N]: [phase-name]
  Commit: feat(phase-[N]): implement [phase-name]
  Summary: .works/$VERSION/[N]-SUMMARY.md

→ Proceeding to /ml-test [N] ...
---
```

**If all tasks are DONE:** proceed automatically to `/ml-test [N]` — no user prompt.

**If any tasks are PARTIAL or FAILED:** pause and ask before proceeding:

```
ask_user:
  question: "Implementation has gaps. How do you want to proceed?"
  choices:
    - "Continue to testing anyway — /ml-test [N]"
    - "Fix gaps first — /ml-implement [N] --gaps-only"
    - "Review gaps in SUMMARY.md"
    - "Stop here"
    - "Other — I'll provide more context"
```

</process>
