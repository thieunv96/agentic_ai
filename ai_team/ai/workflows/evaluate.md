<purpose>
Evaluate ML model performance for a phase. Spawns ai-evaluator. Produces EVALUATION.md with go/no-go decision. Commits evaluation results.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read: STATE.md, PROJECT.md, {N}-CONTEXT.md, all PLAN.md + SUMMARY.md in phase.

## 2. Spawn ai-evaluator

```
<files_to_read>
.planning/PROJECT.md
.planning/KNOWLEDGE.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/phases/[phase-dir]/*/PLAN.md
.planning/phases/[phase-dir]/*/SUMMARY.md
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
node ".github/ai/bin/ai-tools.cjs" commit "docs: evaluation phase [N] - [metric]=[value]" --files .planning/phases/[phase-dir]/EVALUATION.md .planning/STATE.md
```

## 5. Show Next Step

If GO:
```
---
## ▶ Next Up

**Phase [N+1]: [Name]** — [Goal]

`/ai-discuss [N+1]`

---
```

If NO-GO:
```
---
## ▶ Gaps Found

[N] criteria not met. Gap plans created.

`/ai-implement [N] --gaps-only`

---
```

</process>
