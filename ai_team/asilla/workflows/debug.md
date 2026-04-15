<purpose>
Systematic debugging of ML/training/evaluation issues. Spawns asilla-debugger with context. Produces DEBUG.md with root cause and fix.
</purpose>

<process>

## 1. Classify Issue

Read $ARGUMENTS. Classify issue type:
- **Training**: loss issues (NaN, not converging, exploding), OOM, slow training
- **Data**: corrupt data, shape mismatch, augmentation bugs, dataloader errors
- **Architecture**: forward pass errors, weight loading, shape incompatibility
- **Evaluation**: metric calculation, benchmark loading, inference failures
- **Environment**: CUDA errors, dependency conflicts, Docker issues

## 2. Gather Context

```bash
# Collect relevant context automatically
INIT=$(node ".github/asilla/bin/asilla-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read: STATE.md, relevant PLAN.md, relevant SUMMARY.md, error logs if provided.

## 3. Spawn asilla-debugger

```
<files_to_read>
.planning/PROJECT.md
.planning/STATE.md
[relevant source files based on issue type]
</files_to_read>

Issue: [issue description from $ARGUMENTS]
Issue type: [classified type]
```

## 4. Apply Fix

Debugger produces:
- Root cause analysis
- Fix applied to source files
- Verification command to confirm fix

## 5. Commit Fix

```bash
node ".github/asilla/bin/asilla-tools.cjs" commit "fix([phase]): [brief description of fix]" --files [changed files]
```

## 6. Update State

Note fix in STATE.md blockers section (mark as resolved).

</process>
