<purpose>
Execute phase plans with wave-based parallelization. ML-aware: handles Python/PyTorch, training scripts, experiment logging, Docker environments.
Context budget: ~15% orchestrator, 100% fresh per subagent.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init execute-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `commit_docs`, `branching_strategy`, `phase_dir`, `plans`, `incomplete_plans`.

Check flags:
- `--wave N`: execute only Wave N
- `--gaps-only`: only gap-closure plans
- `--interactive`: sequential inline, no subagents

## 2. Discover Plans

List all PLAN.md files in the phase directory.
Filter by --gaps-only if flag is set.
Analyze task dependencies → assign execution waves.

## 3. Execute Waves

For each wave, spawn my-executor subagents in parallel:
```
<files_to_read>
.planning/STATE.md
.planning/PROJECT.md
.planning/KNOWLEDGE.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/phases/[phase-dir]/[plan-dir]/PLAN.md
</files_to_read>
```

Each executor:
1. Reads context files
2. Executes tasks — writes code to disk, does NOT commit
3. Creates SUMMARY.md

## 4. Collect Results and Commit

After all waves complete:
- Check SUMMARY.md for each plan
- Update STATE.md with completion status

Commit everything as a single phase commit:

```bash
node ".github/my/bin/my-tools.cjs" commit "[type](phase-[N]): implement [phase-name]" --files .
```

Use the appropriate type prefix: `feat`, `train`, `data`, `model`, `eval` based on phase type.

## 5. Show Next Step

```
---
## ▶ Next Up

**Evaluate Phase [N]** — Check metrics and model performance

`/my-evaluate [N]`

---
```

</process>
