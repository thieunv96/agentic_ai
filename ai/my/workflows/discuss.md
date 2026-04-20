<purpose>
Discuss and lock implementation decisions for a phase. Gathers context (papers, code refs, ideas) into KNOWLEDGE.md, then locks decisions into {N}-CONTEXT.md (for planner/executor) and {N}-DISCUSSION-LOG.md (audit trail). Commits both at the end.
</purpose>

<process>

## 0. Context Gathering

Before any setup, check whether `.note/KNOWLEDGE.md` exists and has content relevant to this phase.

**If KNOWLEDGE.md is missing or sparse:**

Use AskUserQuestion:
- header: "Add context?"
- question: "Do you have papers, code references, or ideas to add before discussing Phase [N] — [phase name]?"
- options:
  - "Yes, add context" — I have papers, code refs, or ideas to share
  - "Skip — proceed to decisions"

**If KNOWLEDGE.md already has content:**

Use AskUserQuestion:
- header: "Knowledge status"
- question: "KNOWLEDGE.md already has existing context. Anything new to add before Phase [N]?"
- options:
  - "Yes, add more" — new papers, code refs, or ideas since last update
  - "No, let's proceed"

**If user selects "Yes":** Ask what type(s) using AskUserQuestion (multiSelect: true):
- header: "Context type"
- question: "What would you like to add?"
- options: ["Papers / research", "Code references", "Ideas & requirements", "All of the above"]

For each selected type, use AskUserQuestion to gather input (paths, summaries, or freeform text via Other field). Process all inputs and create/update `.note/KNOWLEDGE.md`:

```markdown
# Knowledge Base

*Last updated: [date]*

## Papers
[For each paper: title, key contribution, architecture insights, results]

## Code References
[For each ref: repo/path, purpose, key components]

## Ideas & Requirements
[Organized requirements and design decisions from user input]

## Key Insights
[3-7 cross-cutting insights that should inform all phases]
```

Repeat "Anything else to add?" until user confirms done.

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `phase_dir`, `phase_number`, `phase_name`, `commit_docs`.

Read all required files **in parallel**: STATE.md, PROJECT.md, ROADMAP.md, REQUIREMENTS.md, KNOWLEDGE.md, prior CONTEXT.md files.

Check flags:
- `--auto`: pick recommended defaults without asking, skip all questions
- `--step`: present decision areas one at a time (legacy sequential behavior)
- Default (no flag): **batch mode** — present all areas in one combined interaction

## 2. Identify Discussion Areas

For ML/CV/VLM phases, typical areas by phase type:

**Data Pipeline phase:**
- Dataset format (raw files vs preprocessed tensors)
- Augmentation strategy (which transforms, intensity)
- DataLoader settings (batch size, num_workers, prefetch)
- Train/val split strategy

**Architecture phase:**
- Backbone choice (ViT-B/16 vs ViT-L/14 vs ConvNeXt, etc.)
- Pre-trained weights source (CLIP / ImageNet / from scratch)
- Head/connector design
- Input resolution

**Training phase:**
- Optimizer (AdamW / SGD / etc.) and learning rate
- Scheduler (cosine / linear warmup / etc.)
- Batch size and gradient accumulation
- Mixed precision (fp16 / bf16)
- LoRA vs full fine-tuning
- Experiment tracking (wandb project name, run config)

**Evaluation phase:**
- Benchmarks to run (VQA v2, TextVQA, COCO, etc.)
- Evaluation scripts to use
- Quantitative vs qualitative analysis depth

Skip areas already decided in prior CONTEXT.md files.

## 3. Discuss All Areas (Batch Mode)

**Default behavior (batch mode):** Present ALL decision areas in a single AskUserQuestion interaction. For each area, show the recommendation and options. The user reviews and decides all at once.

Format for each area within the batch:

```
**[Area Name]**
*Why this matters:* [1 sentence explaining impact]

Options:
- **Option A** — [what it is] | Trade-off: [pros / cons]
- **Option B** — [what it is] | Trade-off: [pros / cons]
- **Option C** — [what it is] | Trade-off: [pros / cons]

Recommendation: **[Option X]** because [brief reason based on project context]
```

Use one AskUserQuestion per decision area (grouped into a single message with multiple questions, one per area). Include a final "Anything else?" question in the same batch.

If `--auto`: pick recommended defaults for all areas without asking.
If `--step`: present each area as a separate AskUserQuestion (old sequential behavior).

**IMPORTANT:** All interactions MUST use AskUserQuestion. When the user selects "Let me explain" or wants to provide freeform input, use an open-ended AskUserQuestion (header: "Tell me more", question: "Go ahead — what are you thinking?", options: ["That's all"]). Never break to plain text.

Capture the decision and rationale for each area.

## 4. Create {N}-CONTEXT.md

```markdown
# Phase [N] Context: [Phase Name]

**Date:** [date]
**Phase:** [phase slug]

## Locked Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| D-01 | [Decision] | [Why] |
| D-02 | [Decision] | [Why] |

## Implementation Constraints
[Any hard constraints from PROJECT.md relevant to this phase]

## Success Criteria
[How to know this phase is done — measurable criteria]

## Target Metrics (if evaluation phase)
[Specific metric targets]
```

## 5. Create {N}-DISCUSSION-LOG.md

Following the discussion-log template, record:
- All options considered for each area
- User's final choice
- Any free-form notes
Mark clearly: "Audit trail only — do not use as input to planning agents"

## 6. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "docs: phase [N] context locked - [phase-name]" --files .note/KNOWLEDGE.md .note/phases/[phase-dir]/
```

(Skip `.note/KNOWLEDGE.md` if it was not created or modified in Step 0.)

## 7. Show Next Step

```
---
## ▶ Next Up

**Plan Phase [N]** — Create step-by-step PLAN.md

`/my-plan [N]`

---
```

</process>
