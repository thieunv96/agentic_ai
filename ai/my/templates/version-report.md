# Version Report: {version}

*Generated: {date}*
*Project: {project-name}*

---

## Overview

{2-3 sentence summary of what was built, what task was solved, and the key outcome.}

---

## Original Goal vs Achieved

| Goal | Status | Notes |
|------|--------|-------|
| {goal from PROJECT.md} | ✅ Achieved / ⚠️ Partial / ❌ Missed | {notes} |

---

## Journey: Phases

| Phase | Name | Goal | Key Decision | Primary Metric | Status |
|-------|------|------|-------------|----------------|--------|
| 1 | {name} | {goal} | {key decision made} | {metric}: {value} | ✅ Done |

---

## Final Model

- **Architecture:** {model architecture — e.g., ViT-B/16 + MLP head}
- **Task:** {classification / detection / VQA / captioning / etc.}
- **Framework:** {PyTorch / JAX / etc.}
- **Dataset:** {name} | {N} train / {N} val / {N} test samples
- **Training:**
  - Epochs: {N}
  - Optimizer: {Adam/AdamW/etc.}, LR: {value}
  - Batch size: {N} (effective: {N} with gradient accumulation)
  - Hardware: {GPU type}, {N} GPUs, {N} hours
  - Mixed precision: {FP16/BF16/FP32}
- **Best Checkpoint:** `{path/to/checkpoint.pt}`
- **Final Size:** {N} MB (FP32) / {N} MB (FP16) / {N} MB (INT8)
- **Quantized Formats:** {FP16, INT8, ONNX, TensorRT — if applicable}

---

## Metrics vs Targets

| Metric | Baseline | Target | Achieved | Delta |
|--------|----------|--------|----------|-------|
| {metric name} | {value} | {target} | **{value}** | {+/- delta} |

---

## Training Curves Summary

- **Loss convergence:** {Converged at epoch N / Still decreasing / Diverged then recovered}
- **Best val metric:** {value} at epoch {N}
- **Overfitting:** {No signs / Slight — addressed with dropout/weight decay / Significant}
- **Key inflection point:** {any notable moment in training}

---

## Key Decisions

| # | Decision | Rationale | Impact |
|---|---------|-----------|--------|
| 1 | {decision} | {why} | {what changed} |

---

## Experiments Summary

| Exp | Architecture | Config | Key Metric | Notes |
|-----|-------------|--------|------------|-------|
| v1 | {arch} | {config} | {metric}: {value} | {what it taught us} |

---

## What Worked / What Didn't

### ✅ Worked
- {technique/approach}: {why it helped, quantitative impact if possible}

### ❌ Didn't Work
- {technique/approach}: {why it failed, what we learned}

---

## Open Questions / Future Work

- [ ] {open question or experiment not yet tried}
- [ ] {known limitation to address in next version}

---

## Model Card

```
---
license: {license}
task_categories:
- {task}
language:
- {language if applicable}
tags:
- computer-vision
- {additional tags}
---

# {Model Name}

## Model Summary
{1-2 sentence description}

## Intended Use
{What this model is for and not for}

## Training Data
{Dataset description}

## Performance
| Metric | Value |
|--------|-------|
| {metric} | {value} |

## How to Use
```python
{usage example}
```

## Limitations
{Known limitations}
```

---

## Files & Artifacts

```
.note/
├── KNOWLEDGE.md              # Papers and references used
├── ROADMAP.md                # Phase breakdown
├── DATA-PIPELINE.md          # Data preparation pipeline (if run)
└── phases/
    ├── 01-{name}/
    │   ├── 01-CONTEXT.md
    │   ├── 01-01-PLAN.md
    │   ├── 01-01-SUMMARY.md
    │   └── EVALUATION.md
    └── ...

models/
├── model_best.pt             # Best checkpoint
├── model_final.pt            # Final checkpoint
├── model_fp16.pt             # FP16 (if quantized)
├── model.onnx                # ONNX export (if quantized)
└── QUANTIZATION-REPORT.md    # Quantization results (if run)
```
