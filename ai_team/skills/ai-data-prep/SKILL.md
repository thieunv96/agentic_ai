---
name: ai-data-prep
description: Build CV/VLM data pipelines — format conversion, splits, preprocessing, WebDataset/LMDB packing, HF Hub push
argument-hint: "<task> [--convert|--split|--pack|--validate|--push]"
agent: ai-data-engineer
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

<objective>
Build and execute data preparation pipelines for CV/VLM projects.

Pipeline stages (select via flags or describe task):
- `--convert`: Format conversion (COCO ↔ VOC ↔ YOLO ↔ HuggingFace datasets ↔ custom JSON)
- `--split`: Train/val/test splits with stratification + class balance verification
- `--pack`: Efficient storage packing (WebDataset .tar shards, LMDB for fast random access)
- `--validate`: Dataset validation (schema, corrupt images, annotation consistency, duplicates)
- `--push`: HuggingFace Hub upload with dataset card

Different from `ai-evaluate` (which evaluates models) and `ai-status` (which checks progress).
This builds the data infrastructure the model trains on.

Output: `.planning/DATA-PIPELINE.md` with pipeline code, statistics, and reproducibility notes
Commit: `data(phase-N): {description} - {N} samples {split} split`
</objective>

<execution_context>
@.github/ai/workflows/data-prep.md
@.github/ai/references/ml-data-engineering.md
</execution_context>

<context>
Task: $ARGUMENTS

Flags:
- --convert     Format conversion
- --split       Create train/val/test splits
- --pack        Pack into WebDataset or LMDB
- --validate    Dataset validation and quality check
- --push        Push to HuggingFace Hub
</context>

<process>
Execute the data-prep workflow from @.github/ai/workflows/data-prep.md end-to-end.
Always run --validate before producing final artifacts.
Document all pipeline steps for reproducibility.
</process>
