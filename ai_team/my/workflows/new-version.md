<purpose>
Initialize a new ML/AI development version. Asks ML-focused setup questions, creates .planning/ structure with ML-specific templates.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init new-project)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `commit_docs`, `project_exists`, `has_git`, `project_path`.

If `project_exists` is true: Error — version already initialized. Use my-status.

## 2. Ask ML Setup Questions

Ask the user one at a time. For each question, include a brief explanation of why it's needed:

1. **Version name**
   > *Why:* Used to label all planning files, git tags, and reports for this development cycle.
   > What is this version called? (e.g., "v1.0", "baseline-vlm", "efficientdet-v2")

2. **Task type**
   > *Why:* Determines which phase templates, evaluation metrics, and agent prompts are most relevant.
   > What ML task are you working on? (Image Classification / Object Detection / Semantic Segmentation / VLM / Image Generation / Video Understanding / Other)

3. **Model goal**
   > *Why:* Shapes the phase breakdown — "new from scratch" needs architecture + training phases; "fine-tuning" can skip some early phases.
   > What is your model goal? (building new from scratch / fine-tuning an existing model / architecture research)

4. **Dataset**
   > *Why:* Affects data pipeline phase complexity and augmentation strategy decisions.
   > What dataset(s) will you use? (Name + approximate size, e.g., "COCO 2017, ~120k images")

5. **Target metrics**
   > *Why:* These become the go/no-go criteria in every evaluation phase.
   > What metrics define success? (e.g., "mAP > 0.45 on COCO val", "VQA Accuracy > 75%")

6. **Baseline**
   > *Why:* Gives the evaluator a reference point. Without a baseline, it's hard to judge if results are good.
   > Is there a baseline to beat? (prior work / previous version / paper result — or "none")

7. **Compute**
   > *Why:* Affects batch size recommendations, training time estimates, and whether distributed training is needed.
   > What GPU resources are available? (single GPU / multi-GPU / TPU / cloud — include VRAM if known)

## 2b. Ask for More

After all 7 questions, ask:

> "I have all the core setup information. Is there anything else you'd like to include in the project setup?
> For example: additional constraints, out-of-scope items, known risks, team preferences, or relevant prior work to be aware of."

Incorporate any additional information into PROJECT.md under an "Additional Notes" section.

## 3. Create Planning Structure

Create `.planning/` directory with:
- `PROJECT.md` — ML project context (see ML template)
- `STATE.md` — initial state
- `config.json` — default config with `commit_docs: true`

PROJECT.md ML template:
```markdown
# [Version Name]

## Task
[Task type from step 2]

## Goal
[Model goal from step 3]

## Dataset
[Dataset info from step 4]

## Target Metrics
[Metrics from step 5]

## Baseline
[Baseline info from step 6]

## Compute
[GPU resources from step 7]

## Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|

---
*Initialized: [date]*
```

## 4. Initialize STATE.md

```markdown
# Project State

## Version
[Version name] — [task type]

## Current Position
Phase: Not started
Status: Ready for context — run /my-provide-context

## Last Experiment
None yet

## Target Metrics
[From PROJECT.md]

## Baseline
[From PROJECT.md]

## Blockers
None
```

## 5. Git Init + Initial Commit

```bash
[ -d .git ] || git init
node ".github/my/bin/my-tools.cjs" commit "docs: initialize [version-name] ([task-type])" --files .planning/
```

## 6. Show Next Step

```
---
## ▶ Next Up

**Provide context** — Add papers, code references, and ideas to generate research + roadmap

`/my-provide-context`

---
```

</process>
