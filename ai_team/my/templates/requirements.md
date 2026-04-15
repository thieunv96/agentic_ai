# Requirements Template

Template for `.planning/REQUIREMENTS.md` — formal ML/AI project requirements with IDs for traceability.

<template>

```markdown
# Requirements: [Project Name] — [Version]

**Defined:** [date]
**Task:** [ML task type]
**Core Value:** [from PROJECT.md — what success looks like]

## v1 Requirements

Requirements for this version. Each maps to exactly one roadmap phase.

### Data (DATA)

- [ ] **DATA-01**: [Dataset is loaded and split into train/val/test with reproducible splits]
- [ ] **DATA-02**: [Preprocessing pipeline handles [specific transforms] without information leakage]
- [ ] **DATA-03**: [DataLoader achieves [N] samples/sec throughput on [hardware]]

### Model (MODEL)

- [ ] **MODEL-01**: [Model accepts [input shape] and produces [output shape] correctly]
- [ ] **MODEL-02**: [Model architecture implements [specific component] as defined in PROJECT.md]
- [ ] **MODEL-03**: [Model parameter count is within [target] for [deployment constraint]]

### Training (TRAIN)

- [ ] **TRAIN-01**: [Training loop converges — loss decreasing monotonically after warmup]
- [ ] **TRAIN-02**: [Validation metrics computed after every epoch with early stopping]
- [ ] **TRAIN-03**: [Checkpoint saving/loading works — training can be resumed]

### Evaluation (EVAL)

- [ ] **EVAL-01**: [[Primary metric] > [target value] on [benchmark] test set]
- [ ] **EVAL-02**: [Evaluation runs in < [N] seconds per image/batch]
- [ ] **EVAL-03**: [Qualitative results visualized for [N] representative samples]

### Infrastructure (INFRA)

- [ ] **INFRA-01**: [Training runs on [hardware spec] without OOM errors]
- [ ] **INFRA-02**: [Experiment tracking logs metrics, hyperparameters, and artifacts]

### [Additional Category]

- [ ] **[CAT]-01**: [Requirement description]

## Future Requirements

Acknowledged but deferred to later versions. Not in current roadmap.

### [Category]

- **[CAT]-01**: [Requirement description — why deferred]
- **[CAT]-02**: [Requirement description — why deferred]

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| [Feature] | [Why excluded — e.g., "Out of compute budget for v1"] |
| [Feature] | [Why excluded — e.g., "Requires labeled data not yet available"] |

## Traceability

Each v1 requirement maps to exactly one phase. Updated during roadmap creation.

| Requirement ID | Description | Phase | Status |
|----------------|-------------|-------|--------|
| DATA-01 | [brief description] | Phase 1 | Pending |
| DATA-02 | [brief description] | Phase 1 | Pending |
| MODEL-01 | [brief description] | Phase 2 | Pending |
| TRAIN-01 | [brief description] | Phase 3 | Pending |
| EVAL-01 | [brief description] | Phase 4 | Pending |

**Coverage:**
- v1 requirements: [X] total
- Mapped to phases: [Y]
- Unmapped: [Z] ⚠️

---
*Requirements defined: [date]*
*Last updated: [date] — [trigger: e.g., "after Phase 2 complete"]*
```

</template>

<guidelines>

**Requirement Format:**
- ID: `[CATEGORY]-[NUMBER]` (DATA-01, MODEL-02, TRAIN-03, EVAL-01, INFRA-01)
- Description: Task/system-centric, testable, atomic — what the model/system does, not how
- Checkbox: Only for v1 requirements (future are not yet actionable)

**ML Requirement Categories:**
- **DATA**: Dataset loading, preprocessing, augmentation, splits, dataloader performance
- **MODEL**: Architecture, input/output shapes, components, parameter constraints
- **TRAIN**: Training loop, convergence, checkpointing, hyperparameters, logging
- **EVAL**: Metrics on benchmarks, speed, qualitative results, comparison to baseline
- **INFRA**: Hardware utilization, experiment tracking, deployment, reproducibility
- Add domain-specific categories as needed (e.g., **VLM**, **DET**, **SEG**)

**v1 vs Future:**
- v1: Committed scope, will be in roadmap phases
- Future: Acknowledged but deferred — important for roadmap but not now
- Moving Future → v1 requires roadmap update

**Out of Scope:**
- Explicit exclusions with reasoning (prevents "why didn't you include X?")
- Common ML anti-features: perfect accuracy, real-time on CPU without quantization, etc.

**Traceability:**
- Empty initially, populated during roadmap creation in `/my-new-version`
- Each requirement maps to **exactly one** phase
- Unmapped requirements = roadmap gap (must fix before proceeding)
- Update status as phases complete: Pending → In Progress → Complete

**Requirement quality checklist:**
- Specific: includes concrete targets (numbers, benchmarks, hardware)
- Testable: can be verified by running code or checking output
- Atomic: one thing per requirement (not "model trains AND evaluates")
- Task-centric: describes what the model/system achieves, not implementation details

</guidelines>

<evolution>

**After each phase completes:**
1. Mark covered requirements as Complete (update checkbox + traceability status)
2. Note any requirements that changed scope (with date + reason)

**After roadmap updates:**
1. Verify all v1 requirements still mapped to a phase
2. Add new requirements if scope expanded (with new IDs)
3. Move requirements to Future/Out-of-scope if descoped (with reason)

**Requirement completion criteria:**
- Requirement is "Complete" when:
  - Feature/metric is implemented
  - Verified (tests pass, metrics checked, manual review done)
  - Committed to repository

</evolution>

<example>

```markdown
# Requirements: ObjectDetector — v1.0

**Defined:** 2025-03-10
**Task:** Object Detection (COCO benchmark)
**Core Value:** Real-time object detector that beats YOLOv8-s on COCO mAP while running at 60fps on RTX 3080

## v1 Requirements

### Data (DATA)

- [ ] **DATA-01**: COCO 2017 train/val/test loaded and split with fixed random seed (42)
- [ ] **DATA-02**: Augmentation pipeline: random flip, mosaic, color jitter — no val leakage
- [ ] **DATA-03**: DataLoader achieves ≥500 img/sec throughput on RTX 3080 (batch=32)

### Model (MODEL)

- [ ] **MODEL-01**: Model accepts (B, 3, 640, 640) input, outputs [(B, N, 85)] predictions
- [ ] **MODEL-02**: Backbone is EfficientNet-B3 pretrained on ImageNet
- [ ] **MODEL-03**: Total model < 20M parameters (for real-time constraint)

### Training (TRAIN)

- [ ] **TRAIN-01**: SGD with cosine LR, warmup 3 epochs — loss converges by epoch 50
- [ ] **TRAIN-02**: Validation mAP@0.5 computed each epoch, early stop if no improvement ×10
- [ ] **TRAIN-03**: Checkpoint every 5 epochs, resume from checkpoint works correctly

### Evaluation (EVAL)

- [ ] **EVAL-01**: COCO val2017 mAP@0.5 > 0.48 (beats YOLOv8-s baseline of 0.447)
- [ ] **EVAL-02**: Inference speed ≥ 60 FPS on RTX 3080 (batch=1, FP16)
- [ ] **EVAL-03**: Qualitative results: visualized predictions on 20 val images per class

### Infrastructure (INFRA)

- [ ] **INFRA-01**: Full training run (300 epochs) completes on single RTX 3080 without OOM
- [ ] **INFRA-02**: MLflow logs: loss curves, mAP history, hyperparams, checkpoint paths

## Future Requirements

### Deployment

- **INFRA-03**: ONNX export for production inference
- **INFRA-04**: TensorRT optimization for edge deployment

### Data

- **DATA-04**: Custom dataset support (non-COCO format ingestion)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Real-time video stream inference | Separate system concern, v2 |
| Multi-GPU training | Single GPU sufficient for COCO scale |
| Transformer backbone | Too slow for 60fps constraint with current hardware |

## Traceability

| Requirement ID | Description | Phase | Status |
|----------------|-------------|-------|--------|
| DATA-01 | COCO data loading + splits | Phase 1 | Pending |
| DATA-02 | Augmentation pipeline | Phase 1 | Pending |
| DATA-03 | DataLoader throughput | Phase 1 | Pending |
| MODEL-01 | Input/output shapes | Phase 2 | Pending |
| MODEL-02 | EfficientNet-B3 backbone | Phase 2 | Pending |
| MODEL-03 | Parameter count < 20M | Phase 2 | Pending |
| TRAIN-01 | Training convergence | Phase 3 | Pending |
| TRAIN-02 | Validation + early stop | Phase 3 | Pending |
| TRAIN-03 | Checkpoint resume | Phase 3 | Pending |
| EVAL-01 | mAP@0.5 > 0.48 | Phase 4 | Pending |
| EVAL-02 | 60 FPS inference | Phase 4 | Pending |
| EVAL-03 | Qualitative visualization | Phase 4 | Pending |
| INFRA-01 | Single GPU no OOM | Phase 3 | Pending |
| INFRA-02 | MLflow experiment tracking | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 14 total
- Mapped to phases: 14
- Unmapped: 0 ✓

---
*Requirements defined: 2025-03-10*
*Last updated: 2025-03-10 — initial definition*
```

</example>
