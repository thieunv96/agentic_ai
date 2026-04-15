# My ML/AI Framework

A personal, modular AI-assisted development framework for **Computer Vision** and **Vision-Language Model (VLM)** projects.

> 🇻🇳 [Đọc bằng tiếng Việt](README.VN.md)

---

## Overview

This framework provides a structured, opinionated workflow for ML/AI model development — from idea and research all the way through training, evaluation, quantization, and release. It deploys to `.github/` in any ML project and integrates directly with GitHub Copilot.

```
ai_team/  →  deploy to  →  .github/
```

---

## Quick Start

1. Copy `ai_team/` contents into `.github/` of your ML project
2. Start a new version: `/my-new-version`
3. Ingest context (papers, code refs, ideas): `/my-provide-context`
4. Follow the workflow loop below

---

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
/my-release-version <v>  → Close version with summary + git tag
```

---

## Workflow Visualization

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MY ML/AI FRAMEWORK WORKFLOW                      │
└─────────────────────────────────────────────────────────────────────┘

  /my-new-version
      Ask setup questions (each with WHY explanation)
      Ask: "Anything else to add?"
      Creates: PROJECT.md, STATE.md
      ✗ No commit

  /my-provide-context [--papers] [--refs] [--idea]
      Ingest: papers / code refs / ideas → KNOWLEDGE.md
      Ask: "Anything else to add before roadmap?"
      Ask: "Run research?" ──────────────────────────────────[Optional]
              ├─ Quick research  (recommended: topic well-known)
              ├─ Deep research   (recommended: complex/uncertain)
              └─ Skip            (recommended: context already clear)
      Creates: ROADMAP.md
      ✅ COMMIT #1 ── "docs: setup context"

  ╔══════════════════════════════════════╗
  ║         PHASE LOOP (repeat N)        ║
  ╚══════════════════════════════════════╝

  /my-discuss N
      Present decision areas (with background + trade-offs)
      Discuss each area (explain WHY before each question)
      Ask: "Anything else before locking context?"
      Creates: N-CONTEXT.md, N-DISCUSSION-LOG.md
      ✗ No commit

  /my-plan N
      Ask: "Run research for this phase?" ──────────────────[Optional]
              ├─ Quick / Deep / Skip
      Spawn my-planner → PLAN.md
      Verify with my-plan-checker
      Ask: "Anything to adjust before finalizing?"
      ✅ COMMIT #2 ── "docs: plan phase N"

  /my-implement N
      Spawn my-executor agents (wave-based parallel)
      Executors write code to disk  ✗ no per-task commits
      All waves complete → SUMMARY.md
      ✅ COMMIT #3 ── "feat/train/data(phase-N): implement ..."

  /my-evaluate N
      Check metrics vs CONTEXT.md targets
      Produces: EVALUATION.md with go/no-go
      ✗ No commit
      │
      ├─ ✅ Go  → next phase (/my-discuss N+1)
      └─ ❌ No-go → /my-debug or iterate

  └──────── repeat until all phases done ──────────────────┘

  /my-release-version vX.X.X
      Creates: VERSION-SUMMARY.md + git tag
      ✅ COMMIT ── "chore: release vX.X.X"
```

> **Commit discipline:** Only 3 commit points per phase (roadmap / plan / implementation).
> No commits during discuss, evaluate, research, debug, or status sessions.

---

## All 15 Commands

### Version Management

| Command | Description |
|---------|-------------|
| `/my-new-version` | Start a new version or milestone. Creates `.planning/` structure, PROJECT.md, STATE.md, ROADMAP.md skeleton. |
| `/my-provide-context [--papers] [--refs] [--idea] [--update]` | Ingest ML materials (papers, code refs, ideas) → KNOWLEDGE.md + initial ROADMAP.md. Asks user before running research (quick/deep/skip). |
| `/my-release-version <v>` | Close version with VERSION-SUMMARY.md, git tag, and archived planning artifacts. |

### Phase Loop

| Command | Description |
|---------|-------------|
| `/my-discuss <phase>` | Lock implementation decisions for a phase → CONTEXT.md + DISCUSSION-LOG.md. Use `--auto` for agent defaults, `--batch` for all-at-once. |
| `/my-plan <phase>` | Generate PLAN.md with tasks and verification criteria via `my-planner` agent. |
| `/my-implement <phase>` | Execute PLAN.md atomically via `my-executor` agent. Produces SUMMARY.md + per-task commits. |
| `/my-evaluate <phase> [--quick\|--full]` | Evaluate model vs CONTEXT.md targets → EVALUATION.md with go/no-go decision. |

### Debugging & Navigation

| Command | Description |
|---------|-------------|
| `/my-debug [issue]` | Scientific debugging — evidence → hypothesis → test. Persists across `/clear`. Resume with no args. |
| `/my-status` | Show current phase, latest metrics, open issues, recommended next command. |
| `/my-continue` | Resume from last checkpoint using STATE.md. |

### Research & Exploration

| Command | Description |
|---------|-------------|
| `/my-research [--quick\|--deep] <topic>` | Gray-area / frontier ML research. `--quick`: 3-5 papers + recommendation. `--deep`: full literature survey, gap analysis, synthesis. Output: `.planning/research/{slug}-RESEARCH.md` |
| `/my-map-codebase [path]` | Map an existing codebase into 7 structured docs: STACK, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING, INTEGRATIONS, CONCERNS. |

### Data Engineering

| Command | Description |
|---------|-------------|
| `/my-data-prep <task> [--convert\|--split\|--pack\|--validate\|--push]` | Build CV/VLM data pipelines. Format conversion (COCO↔VOC↔YOLO↔HF), splits with stratification, WebDataset/LMDB packing, integrity validation, HuggingFace Hub push. |

### Model Optimization

| Command | Description |
|---------|-------------|
| `/my-quantize <phase> [--fp16\|--int8\|--onnx\|--trt\|--all]` | Full quantization pipeline: FP16, INT8 calibration, ONNX export, TensorRT engine. Benchmarks accuracy-latency tradeoff. Output: `QUANTIZATION-REPORT.md`. |

### Reporting

| Command | Description |
|---------|-------------|
| `/my-report [session\|experiment\|version]` | `session`: today's work summary. `experiment`: metrics comparison table across runs. `version`: full recap with model card. |

---

## Agents

| Agent | Role |
|-------|------|
| `my-planner` | Creates PLAN.md with ML-aware task decomposition |
| `my-executor` | Implements Python/PyTorch/ML code |
| `my-roadmapper` | Creates phase roadmap from ML requirements |
| `my-researcher` | Researches CV/VLM papers, architectures, SOTA |
| `my-research-synthesizer` | Synthesizes research into actionable insights |
| `my-evaluator` | Evaluates model: metrics, benchmarks, go/no-go |
| `my-data-analyst` | Analyzes CV datasets (COCO, ImageNet, VQA, etc.) |
| `my-data-engineer` | Builds data pipelines, format conversions, packing |
| `my-debugger` | Debugs training/CUDA/data pipeline issues |
| `my-plan-checker` | Verifies plan quality before execution |
| `my-codebase-mapper` | Maps existing codebase/code references |
| `my-quantizer` | Quantizes models (FP16/INT8/ONNX/TensorRT/CoreML) |

---

## `.planning/` Structure

```
.planning/
├── PROJECT.md              # Task, dataset, target metrics, compute
├── ROADMAP.md              # Phase breakdown with goals
├── STATE.md                # Project memory — current phase, best metric
├── KNOWLEDGE.md            # Papers, code refs, key insights
├── DATA-PIPELINE.md        # Data preparation pipeline (if run)
├── VERSION-REPORT.md       # Final version summary (after release)
├── research/
│   └── {slug}-RESEARCH.md
├── reports/
│   ├── session-{date}.md
│   ├── experiments-{date}.md
│   └── version-{v}-{date}.md
├── codebase/               # Codebase map (if mapped)
│   ├── STACK.md
│   ├── ARCHITECTURE.md
│   └── ...
├── debug/
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

---

## Commit Conventions

```
train(phase-N): description    — training code
data(phase-N): description     — dataset/pipeline
model(phase-N): description    — architecture
eval(phase-N): description     — evaluation code
experiment(phase-N): desc      — experiment configs/results
docs: description              — planning docs
feat(phase-N): description     — new features
fix(phase-N): description      — bug fixes
```

---

## Repository Structure

```
ai_team/                       ← deploy contents to .github/
├── skills/my-*/SKILL.md       ← slash command entry points
├── agents/my-*.agent.md       ← specialized ML agents
├── my/
│   ├── workflows/*.md         ← workflow logic
│   ├── references/*.md        ← ML knowledge base
│   ├── templates/             ← artifact templates
│   └── bin/my-tools.cjs       ← CLI for state, commits, config
├── hooks/pre-tool-use.json    ← safety hooks
└── scripts/                   ← Python utilities
```
