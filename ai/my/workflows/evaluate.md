<purpose>
Evaluate ML model performance for a phase. Spawns my-evaluator. Produces EVALUATION.md with go/no-go decision. Commits evaluation results.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read: STATE.md, PROJECT.md, {N}-CONTEXT.md, all PLAN.md + SUMMARY.md in phase.

## 2. Spawn my-evaluator

Read `phase_dir` from INIT result (already version-scoped, e.g. `.note/v1.2/phases/01-name/`).

```
<files_to_read>
[planning]/PROJECT.md
[planning]/KNOWLEDGE.md
[phase_dir]/[N]-CONTEXT.md
[phase_dir]/*-PLAN.md
[phase_dir]/*-SUMMARY.md
</files_to_read>

Task: Evaluate Phase [N] — [phase name].
Run evaluation scripts, compare metrics against CONTEXT.md targets.
Produce EVALUATION.md with go/no-go decision.
```

## 3. Process Results

Read EVALUATION.md produced by evaluator.

**If GO:**
- Update STATE.md: phase N complete
- Commit with metric summary

**If NO-GO:**
- Create gap-closure PLAN.md files
- Update STATE.md: phase N has gaps
- Commit with failing metrics noted

## 4. Commit

```bash
# Extract primary metric from EVALUATION.md for commit message
node ".github/my/bin/my-tools.cjs" commit "docs: evaluation phase [N] - [metric]=[value]" --files .note/phases/[phase-dir]/EVALUATION.md .note/STATE.md
```

## 5. Show Next Step

If GO:
```
---
## ▶ Next Up

**Document Phase [N]** (recommended — user-centric docs for this phase)

`/my-doc --phase [N]`

**Or skip to next phase:**

`/my-discuss [N+1]`

<sub>`/clear` first → fresh context window</sub>

---
```

If NO-GO:
```
---
## ▶ Gaps Found

[N] criteria not met. Gap plans created.

`/my-implement [N] --gaps-only`

---
```

</process>
