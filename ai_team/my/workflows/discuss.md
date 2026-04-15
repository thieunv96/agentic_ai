<purpose>
Discuss and lock implementation decisions for a phase. Creates {N}-CONTEXT.md (for planner/executor) and {N}-DISCUSSION-LOG.md (audit trail).
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `phase_dir`, `phase_number`, `phase_name`, `commit_docs`.

Read: STATE.md, PROJECT.md, ROADMAP.md, REQUIREMENTS.md, KNOWLEDGE.md, prior CONTEXT.md files.

Check --auto flag: if present, pick recommended defaults without asking.
Check --batch flag: if present, present all discussion areas at once.

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

## 3. Discuss Each Area

For each area, present it in this format (unless --auto):

```
**[Area Name]**
*Why this matters:* [1 sentence explaining impact on the project]

Options:
- **Option A** — [what it is] | Trade-off: [pros / cons]
- **Option B** — [what it is] | Trade-off: [pros / cons]
- **Option C** — [what it is] | Trade-off: [pros / cons]

Recommendation: **[Option X]** because [brief reason based on project context]

Your choice?
```

Capture the decision and rationale. Skip areas already decided in prior CONTEXT.md files.

## 4. Ask for More

After covering all standard areas, ask:

> "I've covered all the standard decision areas for Phase [N]. Is there anything else you'd like to discuss or decide before I lock the context?
> For example: edge cases, specific constraints, implementation risks, or preferences not yet covered."

Incorporate any additional decisions into the context.

## 5. Create {N}-CONTEXT.md

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

## 6. Create {N}-DISCUSSION-LOG.md

Following the discussion-log template, record:
- All options considered for each area
- User's final choice
- Any free-form notes
Mark clearly: "Audit trail only — do not use as input to planning agents"

## 7. Show Next Step

```
---
## ▶ Next Up

**Plan Phase [N]** — Create step-by-step PLAN.md

`/my-plan [N]`

---
```

</process>
