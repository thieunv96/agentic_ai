<purpose>
Display the complete AI command reference. Output ONLY the reference content. Do NOT add project-specific analysis, git status, next-step suggestions, or any commentary beyond the reference.
</purpose>

<reference>
# AI Command Reference — ML/AI Edition

**AI** is an ML/AI development framework for Computer Vision and Vision-Language Model (VLM) projects.

## Core Workflow

```
/my-new-version          → Initialize a new version/milestone
/my-provide-context      → Ingest papers, code refs, ideas → KNOWLEDGE.md + ROADMAP.md
/my-discuss <phase>      → Discuss and lock phase decisions → CONTEXT.md
/my-plan <phase>         → Create detailed phase plan → PLAN.md
/my-implement <phase>    → Execute plan → code + commits
/my-evaluate <phase>     → Evaluate metrics vs targets → EVALUATION.md
/my-debug [issue]        → Systematic debugging with persistent state
/my-status               → Current project status and next action
/my-continue             → Resume from last checkpoint
/my-release-version      → Close version with summary + git tag
```

## Research & Exploration

```
/my-research [--quick|--deep] <topic>  → Research any ML/CV/VLM topic
/my-map-codebase [path]               → Map existing codebase structure
```

## Data & Model Optimization

```
/my-data-prep <task> [--convert|--split|--pack|--validate|--push]
    → Build data pipelines: format conversion, splits, WebDataset, LMDB, HF Hub

/my-quantize <phase> [--fp16|--int8|--onnx|--trt|--all]
    → Model quantization: FP16/INT8/ONNX/TensorRT → benchmark report
```

## Reporting

```
/my-report [session|experiment|version]
    → Generate reports: session summary / experiment comparison / version recap
```

---

## Command Details

### Version Management

**`/my-new-version`**
Start a new version or milestone.
- Sets up `.planning/` structure
- Creates PROJECT.md, STATE.md, ROADMAP.md skeleton
- Prompts for: task type, dataset, target metrics, baseline, compute

Usage: `/my-new-version`

---

**`/my-provide-context [--papers] [--refs] [--idea] [--update]`**
Ingest all ML context materials and create KNOWLEDGE.md + ROADMAP.md.

- `--papers path/`: Summarizes papers (contribution, architecture, results)
- `--refs path/`: Maps code reference repo (modules, entry points, dependencies)
- `--idea "text"`: Parses free-form requirements and design decisions
- `--update`: Adds to existing KNOWLEDGE.md without resetting roadmap

Auto-runs research after ingesting context. Creates initial phase roadmap.
Commit: `docs: setup context`

Usage: `/my-provide-context --papers ./papers/ --idea "train CLIP-style model on custom data"`

---

**`/my-release-version <version>`**
Close the current version with full summary and git tag.

- Writes VERSION-SUMMARY.md with phase outcomes and final metrics
- Creates git tag `v{version}`
- Archives planning artifacts

Usage: `/my-release-version 1.0.0`

---

### Phase Workflow

**`/my-discuss <phase>`**
Discuss and lock implementation decisions for a phase.

- Creates `{N}-CONTEXT.md` with locked choices (architecture, training, data, metrics)
- Creates `{N}-DISCUSSION-LOG.md` as audit trail
- `--auto` flag: agent picks recommended defaults
- `--batch` flag: presents all decisions at once

Commit: `docs: discuss phase {N}`

Usage: `/my-discuss 1`
Usage: `/my-discuss 2 --auto`

---

**`/my-plan <phase>`**
Create detailed execution plan for a phase.

- Spawns my-planner → reads CONTEXT.md + KNOWLEDGE.md
- Produces `{N}-01-PLAN.md` with concrete tasks and verification criteria
- Optionally spawns my-researcher for phase-specific research

Commit: `docs: plan phase {N}`

Usage: `/my-plan 1`

---

**`/my-implement <phase>`**
Execute a phase plan with atomic commits.

- Spawns my-executor → reads PLAN.md
- Implements each task with per-task commits
- Handles deviations, creates SUMMARY.md on completion
- Updates STATE.md

Usage: `/my-implement 1`

---

**`/my-evaluate <phase> [--quick|--full]`**
Evaluate model performance for a phase.

- Spawns my-evaluator
- Checks metrics vs CONTEXT.md targets
- Produces EVALUATION.md with go/no-go decision
- `--quick`: Key metrics only
- `--full`: Full error analysis + qualitative samples

Commit: `docs: evaluation phase {N} - {metric}={value}`

Usage: `/my-evaluate 1`
Usage: `/my-evaluate 2 --full`

---

**`/my-debug [issue]`**
Systematic debugging with persistent state.

- Creates `.planning/debug/{slug}.md` tracking investigation
- Scientific method: evidence → hypothesis → test
- Survives `/clear` — run with no args to resume
- Archives to `.planning/debug/resolved/` when solved

Usage: `/my-debug "training loss diverges at epoch 5"`
Usage: `/my-debug` (resume active session)

---

**`/my-status`**
Current project status and suggested next action.

- Reads STATE.md + ROADMAP.md
- Shows phase completion, latest metrics, open issues
- Recommends next command to run

Usage: `/my-status`

---

**`/my-continue`**
Resume from last checkpoint.

- Reads STATE.md to find current position
- Resumes in-progress plan or starts next pending phase
- Restores full context from planning artifacts

Usage: `/my-continue`

---

### Research & Exploration

**`/my-research [--quick|--deep] <topic>`**
Deep research on any ML/CV/VLM topic at any point in the workflow.

- **Gray-area focus**: cutting-edge / frontier research, not yet mainstream
- `--quick` (default): Fast scan → 3-5 papers, key findings, recommendation (~10 min)
- `--deep`: Full literature survey → landscape map, approach comparison, gaps, synthesis

Output: `.planning/research/{slug}-RESEARCH.md`
Adds key findings to KNOWLEDGE.md (deep mode only)

Usage: `/my-research "LoRA for vision encoders"`
Usage: `/my-research --deep "object detection head design"`

---

**`/my-map-codebase [path]`**
Map an existing codebase into structured reference documents.

- Analyzes codebase with parallel mapper agents
- Creates `.planning/codebase/` with 7 focused documents:
  STACK.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md,
  TESTING.md, INTEGRATIONS.md, CONCERNS.md
- Use before starting work on existing codebases or code references

Usage: `/my-map-codebase`
Usage: `/my-map-codebase ./reference-repo/`

---

### Data Engineering

**`/my-data-prep <task> [--convert|--split|--pack|--validate|--push]`**
Build data preparation pipelines for CV/VLM training.

- `--convert`: Format conversion (COCO ↔ VOC ↔ YOLO ↔ HuggingFace ↔ instruction JSONL)
- `--split`: Train/val/test splits with stratification and balance check
- `--pack`: Efficient storage (WebDataset `.tar` shards or LMDB)
- `--validate`: Dataset integrity check (corrupt, missing, duplicates, schema)
- `--push`: HuggingFace Hub upload with auto-generated dataset card

Output: `DATA-PIPELINE.md` + `scripts/data_prep.py`
Commit: `data(phase-N): {description}`

Usage: `/my-data-prep "convert COCO to HuggingFace and split 80/10/10 --convert --split --validate"`

---

### Model Optimization

**`/my-quantize <phase> [--fp16|--int8|--onnx|--trt|--all]`**
Model quantization and optimization pipeline.

- `--fp16`: Half-precision (fastest, <1% accuracy drop)
- `--int8`: INT8 calibration (2-4x speedup)
- `--onnx`: ONNX export + graph optimization
- `--trt`: TensorRT engine (NVIDIA GPU)
- `--all`: Full pipeline (default)

Benchmarks accuracy-latency tradeoff at each stage.
Output: `QUANTIZATION-REPORT.md` + optimized model files in `models/`
Commit: `model(phase-N): quantize to {formats}`

Usage: `/my-quantize 3 --all`
Usage: `/my-quantize 3 --fp16 --onnx`

---

### Reporting

**`/my-report [session|experiment|version]`**
Generate comprehensive project reports.

- `session` (default): What happened today — tasks, experiments, decisions, next steps
- `experiment`: Compare all experiments — metrics table, best run, config diffs, patterns found
- `version`: Full version recap — phases, final model, metrics vs targets, model card

Output: `.planning/reports/{type}-{date}.md`
`version` also creates: `.planning/VERSION-REPORT.md` (permanent)

Usage: `/my-report`
Usage: `/my-report experiment`
Usage: `/my-report version`

---

## .planning/ Structure

```
.planning/
├── PROJECT.md              # Task, dataset, target metrics, compute
├── ROADMAP.md              # Phase breakdown with goals
├── STATE.md                # Project memory — current phase, best metric
├── KNOWLEDGE.md            # Papers, code refs, key insights (central ML artifact)
├── DATA-PIPELINE.md        # Data preparation pipeline (if run)
├── VERSION-REPORT.md       # Final version summary (after release)
├── research/               # Research outputs
│   └── {slug}-RESEARCH.md
├── reports/                # Generated reports
│   ├── session-{date}.md
│   ├── experiments-{date}.md
│   └── version-{version}-{date}.md
├── codebase/               # Codebase map (if mapped)
│   ├── STACK.md
│   ├── ARCHITECTURE.md
│   └── ...
├── debug/                  # Active debug sessions
│   └── resolved/
└── phases/
    └── 01-{name}/
        ├── 01-CONTEXT.md
        ├── 01-DISCUSSION-LOG.md
        ├── 01-01-PLAN.md
        ├── 01-01-SUMMARY.md
        ├── EVALUATION.md
        └── QUANTIZATION-REPORT.md
```

## Commit Conventions

```
train(phase-N): {description}   — training code changes
data(phase-N): {description}    — dataset/pipeline changes
model(phase-N): {description}   — architecture changes
eval(phase-N): {description}    — evaluation code
experiment(phase-N): {desc}     — experiment configs/results
docs: {description}             — planning docs (context, plans, evaluations)
feat(phase-N): {description}    — new feature implementation
fix(phase-N): {description}     — bug fixes
```
</reference>
