<purpose>
Ingest ML context (papers, code refs, ideas) → organize into KNOWLEDGE.md → auto research → create ROADMAP.md with phases → commit.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "0")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Read STATE.md and PROJECT.md.

Parse flags from $ARGUMENTS:
- `--papers` — file path(s) to paper summaries
- `--refs` — path to code reference directory
- `--idea` — free-form idea text
- `--update` — update existing KNOWLEDGE.md (don't reset roadmap)

## 2. Collect Context

For each input type:

**Papers:** Read content, extract:
- Core contribution / novelty
- Architecture description
- Training procedure
- Key results/metrics
- Implementation notes

**Code refs:** Map structure, extract:
- Main modules and their purpose
- Key classes/functions
- Dependencies used
- Training/inference entry points

**Ideas:** Parse free-form text for:
- Requirements and constraints
- Architectural preferences
- Dataset choices
- Evaluation criteria

## 3. Create KNOWLEDGE.md

Create `.planning/KNOWLEDGE.md`:
```markdown
# Knowledge Base

*Last updated: [date]*

## Papers
[For each paper: title, key contribution, architecture insights, results, links]

## Code References  
[For each ref: repo/path, purpose, key components, how to use]

## Ideas & Requirements
[Organized requirements and design decisions from user input]

## Key Insights
[3-7 cross-cutting insights that should inform all phases]
```

## 4. Quick Research (via my-researcher)

Spawn my-researcher with:
```
<files_to_read>
.planning/PROJECT.md
.planning/KNOWLEDGE.md
</files_to_read>

Task: Generate RESEARCH-OVERVIEW.md — a high-level research summary covering:
1. Recommended overall approach based on provided papers/refs
2. Identified technical challenges
3. Suggested phase breakdown (data prep / architecture / training / evaluation)
4. Key libraries and tools needed
5. Estimated effort per phase
```

## 5. Create ROADMAP.md

Based on research, create `.planning/ROADMAP.md`:
```markdown
# Roadmap — [Version Name]

## Goal
[From PROJECT.md]

## Phases

| # | Phase | Goal | Target Metric |
|---|-------|------|---------------|
| 1 | Data Pipeline | Clean, preprocessed dataset ready | Dataset loaded, N samples/sec |
| 2 | Model Architecture | Model forward pass working | Forward pass output shape correct |
| 3 | Training | Model trains and converges | Loss decreasing, no NaN |
| 4 | Evaluation | Quantitative evaluation | [target metric] > [target value] |

## Success Criteria
[All phases complete + final evaluation passing all target metrics]
```

(Adapt phases based on the actual ML task from PROJECT.md)

## 6. Update STATE.md

Update STATE.md:
- Status: "Ready to discuss — run /my-discuss 1"
- Add pointer to KNOWLEDGE.md and ROADMAP.md

## 7. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: setup context for [version-name]" --files .planning/KNOWLEDGE.md .planning/ROADMAP.md .planning/STATE.md
```

## 8. Show Next Step

```
---
## ▶ Next Up

**Phase 1: [Phase Name]** — [Phase goal]

`/my-discuss 1`

<sub>`/clear` first → fresh context window</sub>

---
**Also available:**
- `/my-status` — review full roadmap
```

</process>
