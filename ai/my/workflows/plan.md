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
Read all required files **in parallel**: STATE.md, ROADMAP.md, REQUIREMENTS.md, {N}-CONTEXT.md, KNOWLEDGE.md.

Check flags:
- `--gaps`: gap closure mode (read EVALUATION.md for failed criteria)
- `--auto`: non-interactive

## 2. Optional Research

Assess KNOWLEDGE.md and {N}-CONTEXT.md for confidence level:

**Auto-skip (no prompt needed) if ALL of the following are true:**
- KNOWLEDGE.md has ≥2 papers covering this phase type (data / architecture / training / evaluation)
- {N}-CONTEXT.md is complete with clear locked decisions
- No explicit gaps or uncertainties noted in CONTEXT.md

**Ask the user only if there are genuine gaps:**

> "Should I run research before creating the plan for Phase [N] — [phase name]?
>
> [Recommendation: **{Quick|Deep|Skip}** — {brief reason, e.g., "Phase context is clear and KNOWLEDGE.md already covers this" / "This phase involves [technique] which isn't well covered yet"}]
>
> Options:
> - **Quick** (~10 min): scan key papers relevant to this phase
> - **Deep** (~30 min): full survey for this phase type
> - **Skip**: go straight to planning (good if context is already solid)
>
> Which would you prefer?"

If Quick or Deep: spawn my-researcher with:
```
<files_to_read>
.note/PROJECT.md
.note/KNOWLEDGE.md
.note/phases/[phase-dir]/[N]-CONTEXT.md
.note/ROADMAP.md
</files_to_read>

Task: Write RESEARCH.md for Phase [N] — [phase name].
Focus on: [phase type — data/architecture/training/evaluation]
```

If Skip (or auto-skipped): proceed to planning directly.

## 3. Plan (my-planner)

Spawn my-planner:
```
<files_to_read>
.note/PROJECT.md
.note/REQUIREMENTS.md
.note/phases/[phase-dir]/[N]-CONTEXT.md
.note/phases/[phase-dir]/RESEARCH.md
.note/KNOWLEDGE.md
</files_to_read>

Task: Create PLAN.md files for Phase [N] — [phase name].
ML project context: Python/PyTorch, CV/VLM task.
Decompose into 2-4 sub-plans with 2-3 tasks each.
Each task must be independently executable by an AI agent.
```

## 4. Verify (my-plan-checker)

Spawn my-plan-checker to verify plans make sense for ML work.

**1 iteration only.** If plan-checker finds issues, give my-planner one revision pass, then proceed regardless. Do not loop more than once.

## 5. Ask for Adjustments

Show a summary of the plan to the user, then ask:

> "Here's the plan for Phase [N] — [phase name]. Is there anything you'd like to adjust, add, or clarify before I finalize it?
> For example: task order changes, scope adjustments, additional constraints, or anything that seems missing."

Incorporate any feedback. If changes are significant, re-verify with my-plan-checker (still 1 pass only).

## 6. Show Next Step

```
---
## ▶ Next Up

**Implement Phase [N]** — Execute the plan

`/my-implement [N]`

---
```

</process>
