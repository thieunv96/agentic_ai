<purpose>
Show current version progress, experiment results, and recommended next step.
</purpose>

<process>

## 1. Load State

```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read: STATE.md, ROADMAP.md, PROJECT.md. Check for EVALUATION.md files in each phase.

## 2. Build Status Report

```
# Status — [Version Name]

## Progress
[░░░░░░░░░░] X/Y phases complete

| Phase | Status | Key Metric |
|-------|--------|------------|
| 1 - Data Pipeline | ✅ Complete | - |
| 2 - Architecture  | ✅ Complete | Forward pass OK |
| 3 - Training      | 🔄 In progress | loss=0.43 |
| 4 - Evaluation    | ⏳ Pending | - |

## Target vs Current
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| VQA Accuracy | > 75% | 68.2% | ⚠️ Below |
| mAP@50 | > 0.45 | - | ⏳ |

## Blockers
[Any active blockers from STATE.md]

## Next Step
→ [Recommended command based on current position]
```

</process>
