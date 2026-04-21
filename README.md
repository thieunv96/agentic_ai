# ML Framework — AI-Assisted ML Development Lifecycle

An opinionated workflow framework for AI/ML projects that runs inside **Claude Code** (or any AI coding assistant that supports custom instructions). It turns a single command into a structured, multi-stage pipeline — from surfacing real painpoints through planning, implementation, testing, documentation, and reporting.

---

## What This Is

A set of workflow files, sub-agents, and a skill that Claude loads when you type `/ml-*` commands. Each command maps to one stage of the ML development lifecycle. The stages are connected — outputs from one stage become inputs for the next, stored in `.works/[version]/`.

**Pipeline overview:**

```
/ml-map-codebase          ← understand what already exists
       ↓
/ml-discuss [N]           ← surface real painpoints → lock requirements
       ↓
/ml-plan [N]              ← optional research → break into waves and tasks
       ↓
/ml-implement [N]         ← AUTOPILOT: execute all waves → COMMIT → auto-test
       ↓
/ml-test [N]              ← validate → GO/NO-GO → auto-docs
       ↓
/ml-doc [N]               ← generate user docs → COMMIT → auto-report
       ↓
/ml-report                ← consolidate results → next step recommendations
```

`/ml-implement`, `/ml-test`, and `/ml-doc` run in **autopilot mode** — no confirmation between steps. The pipeline only pauses when something needs your judgment: targets not met, a blocker found, or a gap in the implementation.

---

## Installation

```bash
# Into the current project (installs to .github/)
curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash

# Or explicitly
bash <(curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh)

# Install to a custom directory
curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash -s -- .my-ai

# Re-install / update
curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash
```

After installation, open your project in **Claude Code** — the `.github/` directory is automatically loaded as custom instructions.

**Requirements:** `bash`, `curl` or `wget` or `git`.

### How commands work

This framework does **not** require a plugin or CLI extension. When you type `/ml-plan 2` in Claude Code (or any AI assistant that loaded `.github/copilot-instructions.md`), the assistant reads the command-to-file mapping in those instructions and opens the correct workflow file. All intelligence lives in the workflow files — no server, no binary, no shell alias needed.

If a command returns "no command found," the instructions file is not loaded. Verify that `.github/copilot-instructions.md` exists and that your AI assistant is configured to read it (Claude Code does this automatically).

---

## Commands Reference

### `/ml-map-codebase`

Maps your ML codebase into structured artifacts that every other command uses instead of re-reading source files.

```bash
/ml-map-codebase           # Full map (first time or after major refactor)
/ml-map-codebase --update  # Re-map only files changed since last run
/ml-map-codebase --component model  # Map one pipeline stage only
```

**Output — `.works/[version]/codebase/`:**

| File | Contents |
|------|----------|
| `MANIFEST.md` | Pipeline ASCII tree, entry points, key component table |
| `COMPONENTS.md` | Datasets, models, losses, metrics — with forward signatures |
| `DEPENDENCIES.md` | config→train, data→training, model→inference linkages |
| `RETRIEVAL-INDEX.md` | "how is loss computed?" → `chunks/utils.losses.focal_loss.md` |
| `chunks/[module].[fn].md` | One chunk per function/class — used by agents instead of full source |

**Run this first** before starting a new version. Every other command is faster and more accurate when the map exists.

---

### `/ml-discuss [N]`

Deep-dive discussion to surface real painpoints and lock requirements before planning. Produces `[N]-CONTEXT.md`.

```bash
/ml-discuss 1    # Discuss phase 1
/ml-discuss      # Discuss, will ask which phase
```

**What it does:**

1. Asks which version and issue type (Work item / Bug / Version planning / Research spike)
2. Asks 5 deep-dive questions specific to the issue type — surfaces painpoints, constraints, done criteria, risks
3. Optionally spawns **ml-researcher** (Deep Research Agent) to validate assumptions before locking requirements
4. Presents recommendations and alternative approaches
5. Locks requirements into `[N]-CONTEXT.md`

**Key questions asked (Work item example):**
- What problem does a user face *today* without this feature?
- What has already been tried, and why did it fall short?
- How will you know this is done? (measurable criterion)
- What are the hard constraints? (latency / memory / dataset / framework)
- What is the riskiest assumption?

**Output:** `.works/[version]/[N]-CONTEXT.md`

---

### `/ml-plan [N]`

Creates a detailed, wave-structured implementation plan from the locked requirements. Includes an optional research pass before the plan is finalized.

```bash
/ml-plan 1    # Plan phase 1 (reads 1-CONTEXT.md automatically)
```

**What it does:**

1. Reads `[N]-CONTEXT.md` if it exists — skips re-asking context questions
2. Clarifies compute environment and primary constraint
3. **Optional research step** — offers Skip / Quick / Deep before building the plan. Spawns **ml-researcher** if chosen; findings that challenge a locked decision pause for your judgment before continuing.
4. Builds a wave-structured plan with tasks, outputs, and acceptance criteria
5. Spawns **ml-rubber-duck** agent to validate task clarity before showing you
6. Presents the plan for adjustment — no cap on rounds

**Plan structure:**

```markdown
# Plan: Phase 1 — Data Pipeline

## Objective
## Success Criteria
## Work Breakdown
  ### Wave 1: Setup & inventory
  ### Wave 2: Quality filtering
  ### Wave 3: Tokenization & stats
## Risks
## Dependencies
```

**Output:** `.works/[version]/[N]-PLAN.md`

**Note:** Does not commit. Planning is exploratory.

---

### `/ml-implement [N]`

Executes the plan wave by wave in **autopilot mode** — no confirmation between tasks or waves. Proceeds automatically to `/ml-test` on success.

```bash
/ml-implement 1            # Execute all waves
/ml-implement 1 --wave 2   # Execute only Wave 2
/ml-implement 1 --gaps-only  # Re-run PARTIAL and FAILED tasks only
```

**What it does:**

0. **Engages autopilot mode** — prints a banner and runs end-to-end without interruption on the clean-success path
1. Validates CONTEXT.md and PLAN.md exist — aborts with clear error if missing
2. Spawns **ml-executor** agent per wave (keeps main context clean)
3. Each task: reads files → applies change → verifies acceptance criteria → one auto-fix attempt → records DONE/PARTIAL/FAILED
4. Applies deviation rules automatically:
   - R1: Fix bugs that block the current task
   - R2: Add missing imports/dependencies
   - R3: Fix typos in file paths/function names
   - R4: **STOP** if a change conflicts with a locked decision — surfaces to you
5. Writes `[N]-SUMMARY.md` with full task status table
6. **Commits:** `feat(phase-N): implement [phase-name]`
7. **Auto-proceeds to `/ml-test [N]`** if all tasks DONE; pauses for gaps

**Pauses only when:**
- Pre-conditions missing (CONTEXT.md or PLAN.md not found)
- Tasks have PARTIAL/FAILED gaps
- R4 architecture conflict detected

**Output:** source files + `.works/[version]/[N]-SUMMARY.md` + commit

---

### `/ml-test [N]`

Runs three automated validation passes and produces a GO/NO-GO/CONDITIONAL decision.

```bash
/ml-test 1
```

**What it does:**

Spawns **ml-evaluator** agent which runs:

1. **Coding convention checks** — ruff/flake8, black, mypy (SKIP if not installed), import hygiene, hardcoded paths (WARNING), hardcoded credentials (**BLOCKER**)
2. **Requirements traceability** — every REQ-ID in REQUIREMENTS.md traced to a plan task and its completion status
3. **Success criteria evaluation** — runs eval scripts, checks artifact existence, runs behavioral tests — records actual vs target

**Decision logic:**
- `GO` — all criteria pass, no blockers
- `NO-GO` — any criterion fails, OR blocker found
- `CONDITIONAL` — all criteria pass, non-critical issues noted
- `BLOCKER` — hardcoded credentials found (stops everything)

**Auto-chain:**
- GO / CONDITIONAL → auto-proceeds to `/ml-doc [N]`
- NO-GO → pauses, asks how to handle failed criteria
- BLOCKER → pauses, requires fix before proceeding

**Output:** `.works/[version]/[N]-EVALUATION.md`

---

### `/ml-doc [N]`

Generates user-centric, XWiki-sync-compatible documentation.

```bash
/ml-doc 1          # Document phase 1
/ml-doc --release  # Full version index + CHANGELOG entry
/ml-doc --all      # Regenerate all completed phases
```

**What it does:**

Spawns **ml-documenter** agent which writes documentation following these rules:
- Writes for a user who will **use** the output, not someone who built it
- Zero planning jargon (no: wave, plan, executor, CONTEXT.md, SUMMARY.md)
- Every code block is copy-pasteable with realistic expected output
- XWiki-compatible: H1-H3 only, fenced code blocks with language tags, no HTML, standard pipe tables

**Documentation template:**
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

**Auto-proceeds to `/ml-report session`** after commit.

**Output:** `docs/[version]/[NN]-[phase-slug].md`

---

### `/ml-report`

Consolidates results and synthesizes 2–3 concrete next-step recommendations.

```bash
/ml-report            # Session report (today's activity)
/ml-report experiment # Compare all runs across phases
/ml-report version    # Full version retrospective + model card
```

**Session report includes:** What was accomplished (with commit refs), experiments run, key decisions locked, what was NOT completed, blockers, recommended next session commands.

**Experiment report includes:** Summary table (arch/dataset/metric), best run analysis, patterns found, recommended next experiment.

**Version report includes:** Original goal vs achieved, phase journey, final model spec, metrics, top-5 key decisions, what worked/didn't, model card, recommendations for next version.

**This is the only command that always asks** — it's the natural end of the pipeline where you decide what's next.

**Output:** `.works/reports/[type]-[date].md`

---

## Directory Structure

### Framework (installed to `.github/`)

```
.github/
├── copilot-instructions.md     ← loaded by Claude as custom instructions
│                                  includes command→file resolution table
├── agents/
│   ├── ml-researcher.agent.md      ← Deep Research Agent (5-step, cited report)
│   ├── ml-rubber-duck.agent.md     ← validate plans before execution
│   ├── ml-executor.agent.md        ← execute implementation waves
│   ├── ml-evaluator.agent.md       ← run convention + criteria checks
│   ├── ml-documenter.agent.md      ← write user-centric docs
│   ├── ml-codebase-mapper.agent.md ← AST-parse + tag ML pipeline
│   └── ml-context-keeper.agent.md  ← compress context, maintain STATE.md
├── skills/
│   └── ml-ask.md               ← beautiful user-centric question patterns
└── ml/
    ├── workflows/
    │   ├── ml-discuss.md
    │   ├── ml-planning.md
    │   ├── ml-implement.md
    │   ├── ml-test.md
    │   ├── ml-doc.md
    │   ├── ml-report.md
    │   └── ml-map-codebase.md
    ├── templates/
    └── VERSION
```

### Project state (created by the framework in your project)

```
.works/
└── [version]/                  ← e.g., v1.0, sprint-3, experiment-rag
    ├── STATE.md                ← current phase, progress, next action
    ├── KNOWLEDGE.md            ← accumulated research findings
    ├── [N]-CONTEXT.md          ← locked requirements per phase
    ├── [N]-PLAN.md             ← wave/task breakdown per phase
    ├── [N]-SUMMARY.md          ← implementation results per phase
    ├── [N]-EVALUATION.md       ← test results + GO/NO-GO per phase
    ├── SESSION-[date].md       ← session resume checkpoints
    └── codebase/
        ├── MANIFEST.md
        ├── COMPONENTS.md
        ├── DEPENDENCIES.md
        ├── RETRIEVAL-INDEX.md
        └── chunks/
            └── [module].[fn].md

docs/
└── [version]/
    ├── index.md                ← version overview + quick start
    ├── [NN]-[phase-slug].md   ← one doc per phase
    └── CHANGELOG.md

.works/
└── reports/
    ├── session-[date].md
    ├── experiments-[date].md
    └── version-[version]-[date].md
```

---

## Sub-Agents

Each agent is spawned by its parent workflow with a `<files_to_read>` block — it receives only the files it needs, keeping the main context lean.

| Agent | Spawned by | What it does |
|-------|-----------|-------------|
| `ml-researcher` | `ml-discuss` Step 5, `ml-plan` Step 5 | Deep Research Agent: breaks question into 3–5 sub-tasks, searches 5+ credible sources (Tier 1/2/3), analyzes for bias, synthesizes cited report to KNOWLEDGE.md |
| `ml-rubber-duck` | `ml-plan` Step 7 | Validates plan clarity, dependencies, failure modes — read-only |
| `ml-executor` | `ml-implement` per wave | Executes tasks, applies R1-R4 deviation rules, returns wave report |
| `ml-evaluator` | `ml-test` | Runs all checks, writes EVALUATION.md, returns GO/NO-GO decision |
| `ml-documenter` | `ml-doc` | Writes user-centric XWiki-ready docs |
| `ml-codebase-mapper` | `ml-map-codebase` | AST-parses source, tags pipeline stages, writes chunks/ |
| `ml-context-keeper` | Any workflow at ~70% context | Compresses STATE.md, writes session checkpoint |

---

## Context Management

Long ML sessions accumulate context. The framework handles this automatically:

**`<files_to_read>` protocol:** Agents receive file paths, not pasted content. This keeps spawned agents lean.

**Codebase chunks:** `ml-executor` loads `chunks/[module].[fn].md` (< 80 lines, pre-parsed) instead of full source files.

**STATE.md:** Single source of truth for "where are we now." The `ml-context-keeper` agent compresses this file at phase boundaries and when context approaches ~70%.

**Session resume:** `SESSION-[date].md` in `.works/[version]/` tells you exactly which files to load and which command to run next.

---

## Commit Discipline

Only two commit points in the entire pipeline:

| Point | Command | Message format |
|-------|---------|---------------|
| Phase implement complete | `/ml-implement` after all waves | `feat(phase-N): implement [phase-name]` |
| Phase docs complete | `/ml-doc` after writing | `docs([version]): [phase-name] documentation` |

No commits during: discuss, plan, test, report, research, debug, or status.

---

## Example Session

```bash
# 1. Map the existing codebase (run once, update after refactors)
/ml-map-codebase

# 2. Discuss Phase 2: small object detection improvement
/ml-discuss 2
# → asks 5 questions about the painpoint
# → optionally runs Deep Research Agent on multi-scale fusion approaches
#   → searches 5+ arXiv papers + HuggingFace model cards (Tier 1 sources)
#   → returns: Confirmed / Challenged / New constraint findings
# → recommends LoRA + FPN head modification
# → locks requirements to .works/v1.1/2-CONTEXT.md

# 3. Plan the implementation
/ml-plan 2
# → reads 2-CONTEXT.md (skips re-asking context)
# → asks: research before building the plan? (Skip / Quick / Deep)
# → builds 3-wave plan: setup → FPN integration → validation
# → rubber-duck validates task clarity
# → you adjust Wave 3 task, plan saved

# 4–6. Execute the pipeline (largely automatic — autopilot mode)
/ml-implement 2
# ╔══════════════════════════════════════════╗
# ║  AUTOPILOT ENGAGED — /ml-implement 2    ║
# ╚══════════════════════════════════════════╝
# → executes waves via ml-executor agents
# → commits: feat(phase-2): small object detection
# → auto-proceeds to test...
# → ml-evaluator runs: ruff PASS, mAP@0.5 = 0.47 (target 0.45) → GO
# → auto-proceeds to docs...
# → ml-documenter writes docs/v1.1/02-small-object-detection.md
# → commits: docs(v1.1): small object detection
# → auto-proceeds to report...

# 7. Report pauses, shows pipeline summary, asks what's next
/ml-report
# → session report: what was done, metrics, recommended Phase 3
```

---

## Supported ML Tasks

Optimized for **Computer Vision** and **Vision-Language Models (VLMs)**, including:

- Object detection (YOLO, DETR, RT-DETR)
- Image classification (ViT, ConvNeXt, EfficientNet)
- Vision-language models (LLaVA, InternVL, Qwen-VL, PaliGemma)
- Fine-tuning (SFT, LoRA, QLoRA, DPO)
- Quantization (GPTQ, AWQ, INT8, GGUF)
- RAG pipelines
- Custom evaluation harnesses

The framework also works for general ML (tabular, NLP, time series) but the phase templates and agent knowledge are CV/VLM-optimized.

---

## Version

Current framework version: `1.1.0`
