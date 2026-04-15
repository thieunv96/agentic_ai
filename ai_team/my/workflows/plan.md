<purpose>
Create PLAN.md files for a phase using ML-aware research and planning. Spawns my-researcher then my-planner. Verifies with my-plan-checker.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `phase_dir`, `phase_number`, `phase_name`, `commit_docs`.
Read: STATE.md, ROADMAP.md, {N}-CONTEXT.md, KNOWLEDGE.md.

Check flags:
- `--skip-research`: skip researcher, go straight to planner
- `--gaps`: gap closure mode (read EVALUATION.md for failed criteria)
- `--auto`: non-interactive

## 2. Research (unless --skip-research or --gaps)

Spawn my-researcher:
```
<files_to_read>
.planning/PROJECT.md
.planning/KNOWLEDGE.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/ROADMAP.md
</files_to_read>

Task: Write RESEARCH.md for Phase [N] — [phase name].
Focus on: [phase type — data/architecture/training/evaluation]
```

## 3. Plan (my-planner)

Spawn my-planner:
```
<files_to_read>
.planning/PROJECT.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/phases/[phase-dir]/RESEARCH.md
.planning/KNOWLEDGE.md
</files_to_read>

Task: Create PLAN.md files for Phase [N] — [phase name].
ML project context: Python/PyTorch, CV/VLM task.
Decompose into 2-4 sub-plans with 2-3 tasks each.
Each task must be independently executable by an AI agent.
```

## 4. Verify (my-plan-checker)

Spawn my-plan-checker to verify plans make sense for ML work.
Iterate up to 3 times if issues found.

## 5. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: plan phase [N] - [phase-name]" --files .planning/phases/[phase-dir]/
```

## 6. Show Next Step

```
---
## ▶ Next Up

**Implement Phase [N]** — Execute the plan

`/my-implement [N]`

---
```

</process>
