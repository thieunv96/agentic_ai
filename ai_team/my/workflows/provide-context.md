<purpose>
Ingest ML context (papers, code refs, ideas) → organize into KNOWLEDGE.md → optional research → update STATE.md → commit. KNOWLEDGE.md enrichment only; ROADMAP.md is created by /my-new-version. If no ROADMAP.md exists yet, creates a basic one as fallback.
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

## 4. Ask to Add More Context

After processing all inputs, ask the user:

> "I've finished processing your context. Is there anything else you'd like to add before I create the roadmap?
> For example: additional papers, code references, known constraints, design decisions, or challenges to be aware of."

Wait for response. If the user provides more, process it and update KNOWLEDGE.md. Repeat if needed until user confirms they're done.

## 5. Optional Research

Assess the KNOWLEDGE.md created so far:
- If knowledge gaps are apparent or the approach is uncertain → recommend research
- If papers/refs already cover the approach clearly → recommend skip

Ask the user:

> "Should I run research before creating the roadmap?
> 
> [Recommendation: {Quick|Deep|Skip} — because {brief reason}]
>
> Options:
> - **Quick research** (~10 min): scan 3-5 key papers, get a fast recommendation
> - **Deep research** (~30 min): full literature survey, approach comparison, gap analysis
> - **Skip research**: proceed directly to roadmap (good if context already covers the approach)
>
> Which would you prefer?"

If user chooses Quick or Deep: spawn my-researcher accordingly (see research.md for task format).
If user chooses Skip: proceed to next step.

Only recommend research when there is genuine uncertainty. If KNOWLEDGE.md already contains sufficient papers and a clear approach, recommend Skip.

## 6. Update STATE.md or Create ROADMAP.md

Check whether `.planning/ROADMAP.md` exists:

**If ROADMAP.md already exists** (created by `/my-new-version`):
- Update STATE.md to add pointer to KNOWLEDGE.md
- Note any new insights from context that may affect existing phases

**If no ROADMAP.md** (user ran provide-context before new-version — fallback mode):
- Create `.planning/ROADMAP.md` from the knowledge gathered:
```markdown
# Roadmap — [Version Name]

## Goal
[From PROJECT.md or inferred from context]

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

Update STATE.md:
- Status: "Ready to discuss — run /my-discuss 1"
- Add pointer to KNOWLEDGE.md and ROADMAP.md

## 7. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: update context for [version-name]" --files .planning/KNOWLEDGE.md .planning/STATE.md
```

(Include `.planning/ROADMAP.md` in commit only if ROADMAP.md was newly created in fallback mode.)

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
