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
- `--gaps`: gap closure mode (read EVALUATION.md for failed criteria)
- `--auto`: non-interactive

## 2. Optional Research

Read the phase CONTEXT.md to assess confidence level:
- If CONTEXT.md is clear and backed by existing KNOWLEDGE.md → recommend Skip
- If phase involves novel architecture, unfamiliar techniques, or gaps in KNOWLEDGE.md → recommend research

Ask the user:

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
.planning/PROJECT.md
.planning/KNOWLEDGE.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/ROADMAP.md
</files_to_read>

Task: Write RESEARCH.md for Phase [N] — [phase name].
Focus on: [phase type — data/architecture/training/evaluation]
```

If Skip: proceed to planning directly.

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

## 5. Ask for Adjustments

Show a summary of the plan to the user, then ask:

> "Here's the plan for Phase [N] — [phase name]. Is there anything you'd like to adjust, add, or clarify before I finalize it?
> For example: task order changes, scope adjustments, additional constraints, or anything that seems missing."

Incorporate any feedback. If changes are significant, re-verify with my-plan-checker.

## 6. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: plan phase [N] - [phase-name]" --files .planning/phases/[phase-dir]/
```

## 7. Show Next Step

```
---
## ▶ Next Up

**Implement Phase [N]** — Execute the plan

`/my-implement [N]`

---
```

</process>
