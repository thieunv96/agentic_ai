# My ML/AI Framework

A personal, modular AI-assisted development framework for **Computer Vision** and **Vision-Language Model (VLM)** projects.

> 🇻🇳 [Đọc bằng tiếng Việt](README.VN.md)

---

## Overview

This framework provides a structured, opinionated workflow for ML/AI model development — from idea and research all the way through training, evaluation, quantization, and release. It deploys to `.github/` in any ML project and integrates directly with GitHub Copilot.

```
ai/  →  deploy to  →  .github/
```

---

## Quick Start

1. Copy `ai/` contents into `.github/` of your ML project
2. Start a new version: `/my-new-version`
3. Discuss first phase (context gathering is built-in): `/my-discuss 1`
4. Follow the phase loop: discuss → plan → implement → evaluate

---

## Core Workflow

```
/my-new-version          → Initialize version: .note/vX.Y/ + ROADMAP.md  [COMMIT]
/my-discuss <phase>      → Gather context + lock decisions → KNOWLEDGE.md + CONTEXT.md  [COMMIT]
/my-plan <phase>         → Create detailed phase plan → PLAN.md files
/my-implement <phase>    → Execute plan → code + per-task commits  [COMMITS]
/my-evaluate <phase>     → Evaluate metrics vs targets → EVALUATION.md
/my-doc [--phase N|--release] → Generate user-centric docs for XWiki sync
/my-debug [issue]        → Systematic debugging with persistent state
/my-status               → Current project status and next action
/my-continue             → Resume from last checkpoint
/my-release-version <v>  → Clean up intermediates, finalize docs, tag release  [COMMIT]
```

---

## Full Workflow Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MY ML/AI FRAMEWORK — FULL WORKFLOW                      │
└─────────────────────────────────────────────────────────────────────────────┘

  /my-new-version
  ├─ AskUserQuestion: project type, dataset, target metrics, compute
  ├─ Spawn: my-roadmapper
  ├─ Creates: PROJECT.md, ROADMAP.md, STATE.md
  └─ ✅ COMMIT #1 ── "docs: initialize [project] ([N] phases)"

  ╔═══════════════════════════════════════════════╗
  ║         PHASE LOOP  (repeat for each phase)   ║
  ╚═══════════════════════════════════════════════╝

  /my-discuss N ──────────────────────────────── DISCUSS & LOCK
  │
  │  ── Step 0: Context Gathering ──────────────────────────────
  │  │
  │  │  AskUserQuestion: "Any papers, code refs, or ideas to add?"
  │  │  ├─ Yes → collect papers / code refs / ideas (via AskUserQuestion)
  │  │  │        → create or update KNOWLEDGE.md
  │  │  └─ Skip → KNOWLEDGE.md already up to date
  │  │
  │  ── Step 1: Identify Decision Areas (by phase type) ─────────
  │  │
  │  │  Data Pipeline:  format · augmentation · DataLoader · splits
  │  │  Architecture:   backbone · pretrained weights · head · resolution
  │  │  Training:       optimizer · scheduler · batch · precision · LoRA
  │  │  Evaluation:     benchmarks · scripts · analysis depth
  │  │
  │  ── Step 2: Batch Decisions (DEFAULT: all areas at once) ────
  │  │
  │  │  Single AskUserQuestion for all areas together
  │  │  Each area: options + trade-offs + recommendation
  │  │  --step flag → sequential mode (one area at a time)
  │  │  --auto flag → pick all recommended defaults, skip asking
  │  │
  │  ── Step 3: Lock ─────────────────────────────────────────────
  │  │
  │  │  Creates: N-CONTEXT.md    (locked decisions for planner/executor)
  │  │  Creates: N-DISCUSSION-LOG.md  (audit trail)
  │  │
  └──└─ ✅ COMMIT #2 ── "docs: phase N context locked - [name]"

  /my-plan N ──────────────────────────────────── PLANNING
  │
  │  ── Step 1: Optional Research ───────────────────────────────
  │  │
  │  │  Auto-skip when: KNOWLEDGE.md has ≥2 relevant papers
  │  │                  AND CONTEXT.md is clear and complete
  │  │  Otherwise → AskUserQuestion:
  │  │  ├─ Quick (~10 min): scan key papers for this phase type
  │  │  ├─ Deep  (~30 min): full survey, approach comparison, gap analysis
  │  │  └─ Skip:  go straight to planning
  │  │
  │  ── Step 2: Plan — spawn my-planner ─────────────────────────
  │  │
  │  │  Decomposes phase into 2–4 PLAN.md files
  │  │  Each plan: 2–3 tasks with  files + action + verify + done
  │  │  Waves assigned by dependency graph
  │  │
  │  ── Step 3: Verify — my-plan-checker (1 pass only) ──────────
  │  │
  │  │  Issues found → my-planner gets ONE revision → proceed
  │  │
  │  ── Step 4: Adjust ───────────────────────────────────────────
  │  │
  │  │  AskUserQuestion: "Anything to adjust before finalizing?"
  │  │
  └──└─ ✗ No commit  (plans are intermediate artifacts)

  /my-implement N ─────────────────────────────── EXECUTION
  │
  │  Discover: list PLAN.md files, build dependency graph, assign waves
  │
  │  Wave 1 ─────────────────── parallel spawn ─────────────────
  │  ├─ Executor A  (plan 01)  tasks → per-task commit
  │  ├─ Executor B  (plan 02)  tasks → per-task commit
  │  └─ Executor C  (plan 03)  tasks → per-task commit
  │          Each task commit: feat/fix/train/data/model(N-P): desc
  │
  │  Wave 2 ─────────────────── parallel spawn ─────────────────
  │  ├─ Executor D  (plan 04, depends on plan 01)
  │  └─ Executor E  (plan 05, depends on plan 02)
  │  (only starts after all Wave 1 executors complete)
  │
  │  Each plan completion → metadata commit:
  │      docs(N-NN): complete [plan-name] plan
  │
  │  Deviation rules (auto-applied during execution):
  │  Rule 1: Auto-fix bugs (broken behavior, errors, incorrect output)
  │  Rule 2: Auto-add missing critical (error handling, auth, CSRF/CORS)
  │  Rule 3: Auto-fix blockers (missing deps, wrong types, broken imports)
  │  Rule 4: STOP → AskUserQuestion  (architectural changes → user decides)
  │
  └─ ✅ COMMITS ── per-task + per-plan metadata (many atomic commits)

  /my-evaluate N ──────────────────────────────── EVALUATION
  │
  │  Spawn: my-evaluator
  │  Checks: metrics vs CONTEXT.md targets
  │  Creates: EVALUATION.md  (metrics table, examples, go/no-go)
  │  ✗ No commit
  │
  ├─ ✅ GO     → /my-discuss N+1   (next phase)
  └─ ❌ NO-GO  → /my-implement N --gaps-only
                  (creates gap-closure PLAN.md files, re-executes)
                or /my-debug [issue]  (scientific investigation)

  └──────── repeat until all phases complete ───────────────────

  /my-release-version vX.X.X
  ├─ Creates: VERSION-SUMMARY.md + git tag
  └─ ✅ COMMIT ── "chore: release vX.X.X"
```

---

## Commit Discipline

Only **3 defined commit points** per project lifecycle:

| Point | When | Message format |
|-------|------|----------------|
| **#1 Version init** | After `/my-new-version` | `docs: initialize [project] ([N] phases)` |
| **#2 Context locked** | After `/my-discuss N` | `docs: phase N context locked - [name]` |
| **#3 Implementation** | After each task in `/my-implement N` | `feat/train/data(N-P): [task name]` + plan metadata |

No commits during: plan, evaluate, research, debug, status, or continue sessions.

---

## Interaction Design

All user interactions happen through **AskUserQuestion** — a structured dialog that presents options with explanations. This applies even when the user wants to explain freely:

```
Standard interaction:
  header: "Backbone"
  question: "Which backbone for Phase 2?"
  options: ["ViT-B/16 (balanced)", "ViT-L/14 (best quality)", "ConvNeXt-B (efficient)"]

When user wants to explain freely:
  header: "Tell me more"
  question: "Go ahead — what are you thinking?"
  options: ["That's all"]   ← user types freely via Other field
```

No plain-text prompts. Consistent structured interaction throughout.

---

## Model Profiles

Agents are assigned models based on the active profile. Some agents are **pinned to Claude Opus 4.7** regardless of profile because their work quality has the highest downstream impact.

| Agent | `quality` | `balanced` | `budget` | Role |
|-------|-----------|------------|----------|------|
| `my-planner` | opus | opus | sonnet | Architecture decisions |
| **`my-executor`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Real-time deviation decisions |
| **`my-debugger`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Hypothesis-driven investigation |
| **`my-quantizer`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Accuracy/latency tradeoffs |
| **`ai-phase-researcher`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Literature synthesis |
| `my-plan-checker` | sonnet | sonnet | haiku | Plan validation |
| `my-codebase-mapper` | sonnet | haiku | haiku | Exploration |

> **Pinned agents** use `claude-opus-4-7` across all profiles (fallback: `claude-opus-4-6`).
> Set profile in `.note/config.json`: `{ "model_profile": "balanced" }`

---

## All 14 Commands

### Version Management

| Command | Description |
|---------|-------------|
| `/my-new-version` | Start a new version. Creates `.note/{version}/` with PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md. Sets `current_version` in config. |
| `/my-release-version <v>` | Verify phases, generate release docs, clean up intermediate artifacts (PLAN/SUMMARY), tag release. Context files kept for traceback. |

### Phase Loop

| Command | Description |
|---------|-------------|
| `/my-discuss <phase>` | Gather context (papers, code refs, ideas → KNOWLEDGE.md) then lock decisions → CONTEXT.md + DISCUSSION-LOG.md. Batch mode by default. Use `--step` for sequential, `--auto` for agent defaults. |
| `/my-plan <phase>` | Generate PLAN.md files via `my-planner` agent. Auto-skips research when KNOWLEDGE.md is comprehensive. Verifies with `my-plan-checker` (1 pass). |
| `/my-implement <phase>` | Execute PLAN.md wave-by-wave via parallel `my-executor` agents. Per-task commits + plan metadata commits. |
| `/my-evaluate <phase> [--quick\|--full]` | Evaluate model vs CONTEXT.md targets → EVALUATION.md with go/no-go decision. |

### Documentation

| Command | Description |
|---------|-------------|
| `/my-doc --phase <N>` | Generate user-centric step-by-step docs for a completed phase. Run after `/my-evaluate N` with GO result. Output: `{docs_dir}/{version}/{N}-{phase-name}.md` |
| `/my-doc --release` | Finalize version documentation: index page + CHANGELOG update. Run automatically at `/my-release-version`. |
| `/my-doc --all` | Regenerate docs for all completed phases (useful after bulk changes). |

### Debugging & Navigation

| Command | Description |
|---------|-------------|
| `/my-debug [issue]` | Scientific debugging — evidence → hypothesis → test. Persists across `/clear`. Resume with no args. |
| `/my-status` | Show current phase, latest metrics, open issues, recommended next command. |
| `/my-continue` | Resume from last checkpoint using STATE.md. |

### Research & Exploration

| Command | Description |
|---------|-------------|
| `/my-research [--quick\|--deep] <topic>` | Gray-area / frontier ML research. `--quick`: 3-5 papers + recommendation. `--deep`: full literature survey, gap analysis, synthesis. Output: `.note/research/{slug}-RESEARCH.md` |
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

| Agent | Role | Model |
|-------|------|-------|
| `my-planner` | Creates PLAN.md with ML-aware task decomposition | opus |
| `my-executor` | Implements Python/PyTorch/ML code | **opus-4-7** |
| `my-roadmapper` | Creates phase roadmap from ML requirements | sonnet |
| `my-researcher` | Researches CV/VLM papers, architectures, SOTA | **opus-4-7** |
| `my-research-synthesizer` | Synthesizes research into actionable insights | sonnet |
| `my-evaluator` | Evaluates model: metrics, benchmarks, go/no-go | sonnet |
| `my-data-analyst` | Analyzes CV datasets (COCO, ImageNet, VQA, etc.) | sonnet |
| `my-data-engineer` | Builds data pipelines, format conversions, packing | sonnet |
| `my-debugger` | Debugs training/CUDA/data pipeline issues | **opus-4-7** |
| `my-plan-checker` | Verifies plan quality before execution | sonnet |
| `my-codebase-mapper` | Maps existing codebase/code references | haiku |
| `my-quantizer` | Quantizes models (FP16/INT8/ONNX/TensorRT/CoreML) | **opus-4-7** |

---

## `.note/` Structure

Each version gets its own subdirectory. All planning artifacts are version-scoped for full traceability.

```
.note/
├── config.json             # Shared config: current_version, docs_dir, model profile, etc.
│
├── v1.0/                   # Previous version — context preserved for traceback
│   ├── PROJECT.md          # What was built and why
│   ├── REQUIREMENTS.md     # Requirement IDs and traceability
│   ├── ROADMAP.md          # Phase breakdown
│   ├── KNOWLEDGE.md        # Papers, references, key insights
│   ├── VERSION-SUMMARY.md  # Release summary
│   └── phases/
│       └── 01-{name}/
│           ├── 01-CONTEXT.md          # Locked decisions (kept forever)
│           ├── 01-DISCUSSION-LOG.md   # Audit trail (kept forever)
│           └── EVALUATION.md          # Metrics achieved (kept forever)
│
└── v1.1/                   # Current active version
    ├── PROJECT.md
    ├── REQUIREMENTS.md
    ├── ROADMAP.md
    ├── STATE.md             # Current phase, best metric, blockers
    ├── KNOWLEDGE.md
    └── phases/
        └── 01-{name}/
            ├── 01-CONTEXT.md
            ├── 01-DISCUSSION-LOG.md
            ├── 01-01-PLAN.md          # Removed at release (intermediate)
            ├── 01-01-SUMMARY.md       # Removed at release (intermediate)
            └── EVALUATION.md
```

**After release:** PLAN.md and SUMMARY.md are cleaned up. All context files (CONTEXT.md, DISCUSSION-LOG.md, EVALUATION.md, KNOWLEDGE.md, REQUIREMENTS.md) are kept permanently for traceback.

## `docs/` Structure

Generated by `/my-doc`, stored in configurable `docs_dir` (default: `docs/`):

```
docs/
├── CHANGELOG.md            # Cross-version changes
├── v1.0/
│   ├── index.md            # Version overview + quick start
│   ├── 01-data-pipeline.md # Step-by-step phase guide
│   ├── 02-model.md
│   └── ...
└── v1.1/
    ├── index.md
    └── 01-detection.md     # Added incrementally after each phase GO
```

Each doc is clean Markdown formatted for XWiki sync. Copy `docs/{version}/` to your XWiki space.

---

## Commit Conventions

```
feat(phase-N): description     — new feature
fix(phase-N): description      — bug fix
train(phase-N): description    — training code
data(phase-N): description     — dataset/pipeline
model(phase-N): description    — architecture
eval(phase-N): description     — evaluation code
experiment(phase-N): desc      — experiment configs/results
docs(phase-N): description     — plan completion metadata
docs: description              — project-level planning docs
chore: description             — release, tooling
```

---

## Repository Structure

```
ai/                            ← deploy contents to .github/
├── skills/my-*/SKILL.md       ← slash command entry points
├── agents/my-*.agent.md       ← specialized ML agents
├── my/
│   ├── workflows/*.md         ← workflow logic (discuss, plan, implement, etc.)
│   ├── references/*.md        ← ML knowledge base (model profiles, git, TDD, etc.)
│   ├── templates/             ← artifact templates
│   └── bin/my-tools.cjs       ← CLI for state, commits, config
├── hooks/pre-tool-use.json    ← safety hooks
└── scripts/                   ← Python utilities
```
