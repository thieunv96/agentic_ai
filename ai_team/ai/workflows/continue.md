<purpose>
Auto-detect current workflow position and run the appropriate next command.
</purpose>

<process>

## 1. Read State

```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read STATE.md. Determine current position.

## 2. Determine Next Action

Parse STATE.md status:

| Current Status | Next Action |
|----------------|-------------|
| "Ready for context" | Run: ai-provide-context |
| "Ready to discuss phase N" | Run: ai-discuss N |
| "Ready to plan phase N" | Run: ai-plan N |
| "Ready to implement phase N" | Run: ai-implement N |
| "Ready to evaluate phase N" | Run: ai-evaluate N |
| "Phase N has gaps" | Run: ai-implement N --gaps-only |
| "All phases complete" | Run: ai-release-version |
| "Phase N complete, N+1 next" | Run: ai-discuss N+1 |

## 3. Execute Next Action

Run the determined next action inline (do not spawn a subprocess — execute it directly).

</process>
