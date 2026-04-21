# ML Framework — User Guide

> **What is this?**  
> The ML framework is a structured AI-assisted ML development workflow. Commands are invoked as slash commands (e.g. `/ml-plan 1`) and orchestrate AI agents to discuss, plan, implement, test, document, and report on ML/AI phases in a reproducible way.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Context Engineering — How and Why It Works](#context-engineering--how-and-why-it-works)
3. [The Works File System](#the-works-file-system)
4. [Main Workflow — Full Lifecycle](#main-workflow--full-lifecycle)
5. [Step-by-Step Reference](#step-by-step-reference)
6. [Agents Reference](#agents-reference)
7. [Quick Reference Card](#quick-reference-card)

---

## Core Concepts

| Term | Meaning |
|------|---------|
| **Version** | A named release or experiment cycle (e.g. `v1.0`, `sprint-3`, `experiment-rag`). All artifacts live under `.works/[version]/`. |
| **Phase** | A numbered unit of work (e.g. Phase 1 = "Data Pipeline"). Each phase has a discuss, plan, implement, test, and doc stage. |
| **Wave** | A group of tasks inside a PLAN.md that can be executed in parallel. Waves are ordered by dependency. |
| **`.works/[version]/`** | The workspace directory where all ML framework artifacts live per version. |
| **STATE.md** | Project memory — tracks current phase, progress, and next action. Read first by every workflow. |
| **KNOWLEDGE.md** | Accumulated research findings — updated by `ml-researcher`, read during planning. |
| **Context artifact** | Any `.md` file produced by a workflow that carries decisions forward to downstream agents (CONTEXT.md, PLAN.md, SUMMARY.md, EVALUATION.md). |

---

## Context Engineering — How and Why It Works

### The Problem with Naive AI-Assisted ML Development

When you give an AI all your source files and say "improve this model," you get inconsistent results. The AI:
- Re-asks questions you already answered in a previous session
- Makes conflicting implementation decisions across phases
- Loses track of hard constraints (VRAM, latency, framework) decided earlier
- Has no memory of *why* a particular architecture or loss function was chosen

This happens because AI models have a **fixed context window** — they can only see what you put in front of them *right now*. Large ML codebases overflow the window. Multiple sessions lose previous decisions. Parallel subagents can't share state.

### The Solution: Precision Context

The ML framework solves this with **context engineering** — each agent receives exactly the information it needs, no more. Instead of loading everything, each workflow loads a targeted set of files.

The key insight: **decisions flow forward through files, not through conversation history.**

```
You decide something → Written to a file → Later agent reads that file → Decision respected
```

Every artifact the system creates is designed to be a **future input** for a downstream agent.

### Why It Works: The Chain of Provenance

Every decision made in the workflow has a traceable origin:

```
Your painpoint
    │ surfaced by /ml-discuss
    ▼
[N]-CONTEXT.md ──────────────────────────► Locked requirements for THIS phase
    │ researched by ml-researcher (optional)
    ▼
KNOWLEDGE.md ────────────────────────────► Validated assumptions, SOTA findings
    │ planned by /ml-plan
    ▼
[N]-PLAN.md ─────────────────────────────► Wave/task breakdown, acceptance criteria
    │ executed by ml-executor (per wave)
    ▼
[N]-SUMMARY.md ──────────────────────────► What was actually built (task status)
    │ validated by ml-evaluator
    ▼
[N]-EVALUATION.md ───────────────────────► GO/NO-GO + metric results
    │ documented by ml-documenter
    ▼
docs/[version]/[NN]-[phase-slug].md ─────► User-facing documentation
```

Each file is a **compressed record of decisions** so no future agent ever has to re-derive them.

### Why Each File Exists

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `STATE.md` | Every workflow (updated) | First thing every workflow reads | Current phase, progress, next action |
| `KNOWLEDGE.md` | `ml-researcher` | `ml-planning`, `ml-discuss` | Validated research findings and SOTA context |
| `REQUIREMENTS.md` | User / project setup | Every workflow | Project-wide constraints — non-negotiable |
| `ROADMAP.md` | User / project setup | `ml-discuss`, `ml-plan` | Phase sequence and goals |
| `codebase/` | `/ml-map-codebase` | `ml-executor`, `ml-evaluator`, `ml-planning` | Structured codebase map (MANIFEST, COMPONENTS, chunks) |
| `[N]-CONTEXT.md` | `/ml-discuss` | `ml-planning`, `ml-executor`, `ml-evaluator` | Locked decisions for this phase |
| `[N]-PLAN.md` | `/ml-plan` | `ml-executor` | Wave/task breakdown with acceptance criteria |
| `[N]-SUMMARY.md` | `ml-executor` | `/ml-test`, `/ml-doc`, `/ml-report` | Task results, files changed, deviations |
| `[N]-EVALUATION.md` | `ml-evaluator` | `/ml-doc`, `/ml-report` | GO/NO-GO decision, metric results |

### The `<files_to_read>` Protocol — Wave Execution Without State Loss

When `/ml-implement` spawns `ml-executor` agents per wave, each gets a `<files_to_read>` block:

```xml
<files_to_read>
  .works/v1.1/STATE.md
  .works/v1.1/2-CONTEXT.md
  .works/v1.1/2-PLAN.md
  .works/v1.1/codebase/chunks/utils.losses.focal_loss.md
</files_to_read>
Execute Wave 2: Feature Fusion Integration
Tasks: T2.1, T2.2, T2.3
```

This is how the framework achieves **clean execution without context overflow**: each executor has its own fresh context window loaded with exactly what it needs for its wave. It doesn't share memory with other executors — it reads from shared files.

```
/ml-implement 2
       │
       ├─► ml-executor (Wave 1) ─ reads PLAN.md + CONTEXT.md + chunk files
       ├─► ml-executor (Wave 2) ─ reads PLAN.md + CONTEXT.md + chunk files
       └─► ml-executor (Wave 3) ─ reads PLAN.md + CONTEXT.md + chunk files
                        (sequential by wave, tasks within a wave in parallel)
```

### How STATE.md Maintains Continuity

`STATE.md` is read at the start of **every single workflow**. It's kept concise — it's a digest, not an archive. It contains:

- Current version and phase
- What happened last (date + action)
- Progress across phases
- Active blockers and concerns
- Pointer to the next recommended command

This means you can close Claude Code, come back a week later, and the system knows exactly where it stopped.

### How CONTEXT.md Prevents Decision Drift

`[N]-CONTEXT.md` is the most important single-phase artifact. It prevents drift across the discuss → plan → implement → test pipeline.

**Without CONTEXT.md:**
```
You discuss: "use LoRA r=16 on the attention layers"
Planner forgets, plans full fine-tuning
Executor trains full weights → runs out of VRAM
You discover mismatch only during evaluation
```

**With CONTEXT.md:**
```
/ml-discuss 2:   writes "use LoRA r=16, attention layers only" to 2-CONTEXT.md
/ml-plan 2:      reads CONTEXT.md → generates tasks using LoRA, not full FT
ml-executor:     reads CONTEXT.md → implements LoRA correctly
ml-evaluator:    reads CONTEXT.md → validates against LoRA-specific criteria
```

The decision is **written once, respected everywhere.**

### Codebase Chunks — Context-Efficient Source Access

Instead of passing full source files to agents, the framework uses pre-parsed chunks:

- `ml-map-codebase` AST-parses your source and writes one `chunks/[module].[fn].md` per function/class
- Each chunk is < 80 lines — significantly cheaper than reading the original source
- `RETRIEVAL-INDEX.md` maps natural language queries to chunk files ("how is loss computed?" → `chunks/utils.losses.focal_loss.md`)
- Agents load only the chunks relevant to their wave's tasks

---

## The Works File System

### Full `.works/[version]/` Directory Structure

```
.works/
└── [version]/                  ← e.g., v1.0, sprint-3, experiment-rag
    │
    ├── STATE.md                ← Current phase, progress, next action (read first, always)
    ├── KNOWLEDGE.md            ← Accumulated research findings (updated by ml-researcher)
    ├── REQUIREMENTS.md         ← Project-wide constraints (non-negotiable)
    ├── ROADMAP.md              ← Phase sequence and goals
    │
    ├── codebase/               ← Codebase map (from /ml-map-codebase)
    │   ├── MANIFEST.md         ← Pipeline ASCII tree, entry points, key component table
    │   ├── COMPONENTS.md       ← Datasets, models, losses, metrics with signatures
    │   ├── DEPENDENCIES.md     ← config→train, data→training, model→inference linkages
    │   ├── RETRIEVAL-INDEX.md  ← Query → chunk file mapping
    │   └── chunks/             ← One file per function/class (< 80 lines each)
    │       └── [module].[fn].md
    │
    ├── [N]-CONTEXT.md          ← Locked requirements for phase N (from /ml-discuss)
    ├── [N]-PLAN.md             ← Wave/task breakdown for phase N (from /ml-plan)
    ├── [N]-SUMMARY.md          ← Implementation results for phase N (from /ml-implement)
    ├── [N]-EVALUATION.md       ← GO/NO-GO + metric results (from /ml-test)
    │
    └── SESSION-[date].md       ← Session resume checkpoint

docs/
└── [version]/
    ├── index.md                ← Version overview + quick start (from /ml-doc --release)
    ├── [NN]-[phase-slug].md   ← One doc per phase (from /ml-doc)
    └── CHANGELOG.md            ← Version changelog

.works/
└── reports/
    ├── session-[date].md
    ├── experiments-[date].md
    └── version-[version]-[date].md
```

### File Lifecycle

| File | Created by | Updated | Fixed after |
|------|-----------|---------|-------------|
| `STATE.md` | First workflow | After every action | Never — always current |
| `KNOWLEDGE.md` | `ml-researcher` | Each research run | Accumulates across phases |
| `[N]-CONTEXT.md` | `/ml-discuss` | Not updated — locked | Locked at creation |
| `[N]-PLAN.md` | `/ml-plan` | Not updated — locked | Locked at creation |
| `[N]-SUMMARY.md` | `ml-executor` | `--gaps-only` re-runs | After all tasks DONE |
| `[N]-EVALUATION.md` | `ml-evaluator` | Re-run after gap fixes | After GO decision |
| `docs/` | `ml-documenter` | `/ml-doc --all` | After GO + doc commit |

### What Agents Read (by workflow)

| Workflow | Files read at start |
|----------|---------------------|
| `/ml-map-codebase` | STATE.md, REQUIREMENTS.md, most recent [N]-CONTEXT.md |
| `/ml-discuss N` | STATE.md, KNOWLEDGE.md, prior [N]-CONTEXT.md, ROADMAP.md, REQUIREMENTS.md, codebase/MANIFEST.md |
| `/ml-plan N` | STATE.md, [N]-CONTEXT.md, ROADMAP.md, REQUIREMENTS.md, codebase/MANIFEST.md + COMPONENTS.md |
| `ml-executor` (per wave) | STATE.md, [N]-CONTEXT.md, [N]-PLAN.md, REQUIREMENTS.md, relevant chunk files |
| `/ml-test N` | [N]-SUMMARY.md, [N]-CONTEXT.md, [N]-PLAN.md, REQUIREMENTS.md, changed source files |
| `/ml-doc N` | [N]-CONTEXT.md, [N]-SUMMARY.md, [N]-EVALUATION.md, KNOWLEDGE.md |
| `/ml-report` | STATE.md, ROADMAP.md, EVALUATION.md files, SUMMARY.md files (scope depends on report type) |

---

## Main Workflow — Full Lifecycle

This is the recommended end-to-end workflow per phase:

```
/ml-map-codebase              (run once, or --update after major refactors)
        │
        ▼
/ml-discuss [N]               ─┐
        │                      │  Repeat for each phase
        ▼                      │  (/ml-implement, /ml-test, /ml-doc run
/ml-plan [N]                   │   autonomously and auto-chain to the next)
        │                      │
        ▼                      │
/ml-implement [N]              │  → auto-proceeds to /ml-test [N]
        │                      │
        ▼ (auto)               │
/ml-test [N]                   │  → auto-proceeds to /ml-doc [N] on GO
        │                      │
        ▼ (auto)               │
/ml-doc [N]                    │  → auto-proceeds to /ml-report session
        │                      │
        ▼ (auto)               │
/ml-report                    ─┘  → pauses, asks what's next
```

> **The pipeline only pauses when something needs your judgment:** a target not met, a blocker found, or a gap in the implementation. Otherwise it runs continuously.

### Commit Discipline

Only two commit points in the entire pipeline:

| Point | Command | Commit message format |
|-------|---------|----------------------|
| Phase implement complete | `/ml-implement` after all waves done | `feat(phase-N): implement [phase-name]` |
| Phase docs complete | `/ml-doc` after writing | `docs([version]): [phase-name] documentation` |

No commits during: discuss, plan, test, report, research, or map-codebase.

---

## Step-by-Step Reference

### 1. `/ml-map-codebase` — Map the existing codebase

**Use for:** Understanding your ML codebase before planning. Run once at project start; re-run after major refactors.  
**Skip for:** Empty/greenfield projects.

```
/ml-map-codebase                    # Full map (first time or after major refactor)
/ml-map-codebase --update           # Re-map only files changed since last run
/ml-map-codebase --component model  # Map one pipeline stage only (data/model/train/eval/inference)
```

**What it does:**
- Spawns `ml-codebase-mapper` agent to AST-parse all source files
- Tags each component with pipeline stage and role
- Builds a dependency graph (config→model, dataset→training)
- Writes structured artifacts to `.works/[version]/codebase/`

**Output — `.works/[version]/codebase/`:**

| File | Contents |
|------|----------|
| `MANIFEST.md` | Pipeline ASCII tree, entry points, key component table |
| `COMPONENTS.md` | Datasets, models, losses, metrics — with forward signatures |
| `DEPENDENCIES.md` | config→train, data→training, model→inference linkages |
| `RETRIEVAL-INDEX.md` | "how is loss computed?" → `chunks/utils.losses.focal_loss.md` |
| `chunks/[module].[fn].md` | One chunk per function/class — used by agents instead of full source |

**No commit** — codebase map is a derived artifact.  
**Next step:** `/ml-discuss 1`

---

### 2. `/ml-discuss [N]` — Surface painpoints and lock requirements

**Use for:** Deep-dive discussion to surface real problems and lock requirements before planning. Produces `[N]-CONTEXT.md`.

```
/ml-discuss 1    # Discuss phase 1
/ml-discuss      # Will ask which phase and version
```

**What it does:**
1. Identifies version and issue type (Work item / Bug / Version planning / Research spike)
2. Asks 5 deep-dive questions about the painpoint, constraints, done criteria, and risks
3. Optionally spawns `ml-researcher` to validate assumptions before locking (quick / deep / skip)
4. Presents recommendations and alternative approaches
5. Locks requirements into `[N]-CONTEXT.md`

**Key questions asked (Work item example):**
- What problem does a user face *today* without this feature?
- What has already been tried, and why did it fall short?
- How will you know this is done? (measurable criterion)
- What are the hard constraints? (VRAM / latency / dataset / framework)
- What is the riskiest assumption?

**Output:** `.works/[version]/[N]-CONTEXT.md`  
**No commit** — discussion is exploratory.  
**Next step:** `/ml-plan N`

---

### 3. `/ml-plan [N]` — Create a wave-structured implementation plan

**Use for:** Generating a PLAN.md with wave/task breakdown and acceptance criteria.

```
/ml-plan 1    # Plan phase 1 (reads 1-CONTEXT.md automatically)
```

**What it does:**
1. Reads `[N]-CONTEXT.md` — skips re-asking questions already locked
2. Clarifies compute environment and primary constraint
3. Builds a wave-structured plan with tasks, outputs, and acceptance criteria per task
4. Spawns `ml-rubber-duck` agent to validate task clarity and catch hidden dependencies
5. Applies rubber-duck feedback, presents plan for your review
6. Iterates on plan adjustments — no cap on rounds

**Plan structure:**
```markdown
# Plan: Phase N — [Phase Name]

## Objective
## Success Criteria
## Work Breakdown
  ### Wave 1: Setup & inventory
  ### Wave 2: Core implementation
  ### Wave 3: Validation & cleanup
## Risks
## Dependencies
```

**Output:** `.works/[version]/[N]-PLAN.md`  
**No commit** — planning is exploratory.  
**Next step:** `/ml-implement N`

---

### 4. `/ml-implement [N]` — Execute the plan autonomously

**Use for:** Running the plan wave by wave. No user confirmation between tasks or waves.

```
/ml-implement 1              # Execute all waves
/ml-implement 1 --wave 2    # Execute only Wave 2
/ml-implement 1 --gaps-only # Re-run PARTIAL and FAILED tasks only
```

**What it does:**
1. Validates CONTEXT.md and PLAN.md exist — aborts with clear error if missing
2. Spawns `ml-executor` agent per wave (keeps main context clean)
3. Each executor reads its wave tasks + relevant chunk files + CONTEXT.md
4. Each task: reads files → applies change → verifies acceptance criteria → one auto-fix attempt → records DONE/PARTIAL/FAILED
5. Applies deviation rules automatically:
   - **R1:** Fix bugs that block the current task
   - **R2:** Add missing imports/dependencies
   - **R3:** Fix typos in file paths/function names
   - **R4:** **STOP** if a change conflicts with a locked decision → surfaces to you
6. Writes `[N]-SUMMARY.md` with full task status table
7. **Commits:** `feat(phase-N): implement [phase-name]`
8. Auto-proceeds to `/ml-test N` if all tasks DONE; pauses for gaps

**Pauses only when:**
- Pre-conditions missing (CONTEXT.md or PLAN.md not found)
- Tasks have PARTIAL/FAILED gaps (asks how to handle)
- R4 architecture conflict detected

**Output:** source files + `.works/[version]/[N]-SUMMARY.md` + git commit  
**Auto-proceeds to:** `/ml-test N`

---

### 5. `/ml-test [N]` — Validate the implementation

**Use for:** Automated validation of a completed phase. Runs three checks and produces a GO/NO-GO decision.

```
/ml-test 1
```

**What it does:**

Spawns `ml-evaluator` agent which runs three passes:

1. **Coding convention checks** — ruff/flake8, black, mypy (SKIP if not installed), import hygiene, hardcoded paths (WARNING), hardcoded credentials (**BLOCKER**)
2. **Requirements traceability** — every requirement in REQUIREMENTS.md traced to a plan task and its completion status
3. **Success criteria evaluation** — runs eval scripts, checks artifact existence, runs behavioral tests — records actual vs target

**Decision logic:**
- `GO` — all criteria pass, no blockers → auto-proceeds to `/ml-doc N`
- `CONDITIONAL` — all criteria pass, non-critical issues noted → auto-proceeds to `/ml-doc N`
- `NO-GO` — any criterion fails → pauses, asks how to handle
- `BLOCKER` — hardcoded credentials found → stops everything, requires fix

**Output:** `.works/[version]/[N]-EVALUATION.md`  
**Auto-proceeds to:** `/ml-doc N` on GO or CONDITIONAL

---

### 6. `/ml-doc [N]` — Generate user-centric documentation

**Use for:** Writing documentation for a completed phase. Zero planning jargon — written for users who will use the output.

```
/ml-doc 1           # Document phase 1
/ml-doc --release   # Full version index + CHANGELOG entry
/ml-doc --all       # Regenerate docs for all completed phases
```

**What it does:**
- Spawns `ml-documenter` agent with CONTEXT.md, SUMMARY.md, EVALUATION.md, KNOWLEDGE.md
- Writes documentation following XWiki-compatible rules (H1-H3 only, fenced code blocks, no HTML)
- Every code block is copy-pasteable with realistic expected output
- Zero planning jargon (no: wave, plan, executor, CONTEXT.md)

**Documentation template written for each phase:**
```markdown
# [Phase Name]
> Version | Status | Key result

## What This Does
## Before You Start
## Step-by-Step
## Key Configuration
## Results
## Troubleshooting
## What Comes Next
```

**Commits:** `docs([version]): [phase-name] documentation`  
**Output:** `docs/[version]/[NN]-[phase-slug].md`  
**Auto-proceeds to:** `/ml-report session`

---

### 7. `/ml-report` — Consolidate results and recommend next steps

**Use for:** Summarizing what happened and synthesizing 2–3 concrete next-step recommendations.

```
/ml-report             # Session report (today's activity) — default
/ml-report experiment  # Compare all experiment runs across phases
/ml-report version     # Full version retrospective + model card
```

**Session report includes:** What was accomplished (with commit refs), experiments run, key decisions locked, what was NOT completed, blockers, recommended next session commands.

**Experiment report includes:** Summary table (arch/dataset/metric), best run analysis, patterns found, recommended next experiment.

**Version report includes:** Original goal vs achieved, phase journey, final model spec, metrics, top-5 key decisions, what worked/didn't, model card, recommendations for next version.

**This is the only command that always pauses** — it's the natural end of the pipeline where you decide what's next.

**Output:** `.works/reports/[type]-[date].md`  
**No commit.**

---

## Agents Reference

Agents are spawned automatically by workflows. You don't call them directly, but understanding each agent helps you follow what's happening during execution.

| Agent | Role | Spawned by |
|-------|------|-----------|
| `ml-executor` | Executes a single wave of tasks from PLAN.md; applies R1-R4 deviation rules; records DONE/PARTIAL/FAILED per task | `/ml-implement` per wave |
| `ml-rubber-duck` | Validates PLAN.md before it is shown to you — checks task clarity, hidden dependencies, failure modes; read-only | `/ml-plan` |
| `ml-researcher` | Web research on ML papers, architectures, SOTA benchmarks, and implementation patterns; updates KNOWLEDGE.md | `/ml-discuss` (optional) |
| `ml-evaluator` | Runs convention checks, requirements traceability, and success criteria evaluation; writes EVALUATION.md with GO/NO-GO decision | `/ml-test` |
| `ml-documenter` | Writes user-centric, XWiki-compatible docs from planning artifacts; zero planning jargon | `/ml-doc` |
| `ml-codebase-mapper` | AST-parses source files, tags pipeline stages, builds dependency graph, writes chunks/ | `/ml-map-codebase` |
| `ml-context-keeper` | Compresses conversation context and maintains STATE.md at phase transitions or when context is ~70% full | Any workflow at ~70% context |

---

## Quick Reference Card

### Standard phase workflow

```bash
# 1. Map the codebase (run once; --update after refactors)
/ml-map-codebase

# 2. Discuss Phase 1 — surface painpoints, lock requirements
/ml-discuss 1

# 3. Plan — wave/task breakdown, rubber-duck validated
/ml-plan 1

# 4-6. Execute the pipeline (largely automatic)
/ml-implement 1
# → executes waves via ml-executor agents
# → commits: feat(phase-1): implement [phase-name]
# → auto-proceeds to /ml-test 1...

# → ml-evaluator runs checks → GO
# → auto-proceeds to /ml-doc 1...

# → ml-documenter writes docs/[version]/01-[phase-slug].md
# → commits: docs([version]): [phase-name] documentation
# → auto-proceeds to /ml-report session...

# 7. Report pauses — shows what was done, asks what's next
/ml-report
```

### If gaps are found during /ml-test

```bash
# Evaluation returned NO-GO — fix gaps and re-run
/ml-implement 1 --gaps-only   # re-run only PARTIAL/FAILED tasks
/ml-test 1                    # re-evaluate → should be GO
/ml-doc 1                     # document after GO
```

### Execute only a specific wave

```bash
/ml-implement 1 --wave 2   # useful when Wave 1 already succeeded
```

### Generate different report types

```bash
/ml-report              # what happened today
/ml-report experiment   # compare all experiment runs
/ml-report version      # full retrospective + model card
```

### Update codebase map after changes

```bash
/ml-map-codebase --update      # re-map changed files only
/ml-map-codebase --component model  # re-map one pipeline stage
```

---

## Supported ML Tasks

The framework is optimized for **Computer Vision** and **Vision-Language Models (VLMs)**, including:

- Object detection (YOLO, DETR, RT-DETR)
- Image classification (ViT, ConvNeXt, EfficientNet)
- Vision-language models (LLaVA, InternVL, Qwen-VL, PaliGemma)
- Fine-tuning (SFT, LoRA, QLoRA, DPO)
- Quantization (GPTQ, AWQ, INT8, GGUF)
- RAG pipelines
- Custom evaluation harnesses

The framework also works for general ML (tabular, NLP, time series) but the phase templates and agent knowledge are CV/VLM-optimized.

---

*Framework version: `1.0.0`. Workflow files live in `.github/ml/workflows/`. Agents live in `.github/agents/`.*
