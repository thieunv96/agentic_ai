# AI Skills — User Guide

> **What is this?**  
> The AI framework skill system is a structured AI-assisted development workflow. Skills are invoked as slash commands (e.g. `/ai-plan-phase 1`) and orchestrate AI agents to plan, build, verify, and ship features in a reproducible way.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Context Engineering — How and Why It Works](#context-engineering--how-and-why-it-works)
3. [The Planning File System](#the-planning-file-system)
4. [Main Workflow — Full Lifecycle](#main-workflow--full-lifecycle)
5. [Step-by-Step Reference](#step-by-step-reference)
6. [Supporting Skills](#supporting-skills)
7. [Project-Specific Skills](#project-specific-skills)
8. [Agents Reference](#agents-reference)
9. [Quick Reference Card](#quick-reference-card)

---

## Core Concepts

| Term | Meaning |
|------|---------|
| **Milestone** | A versioned release cycle (e.g. `v1.0`, `v1.1`). Contains multiple phases. |
| **Phase** | A numbered unit of work (e.g. Phase 1 = "REST API endpoints"). Each phase has a plan, execution, and verification. |
| **Plan** | A `PLAN.md` file with step-by-step tasks for an executor agent to carry out. |
| **`.planning/`** | The workspace directory where all AI artifacts live (roadmap, requirements, phase plans, state). |
| **STATE.md** | Project memory — tracks current phase, completed work, and next steps. |
| **Context artifact** | Any `.md` file produced by a skill that carries decisions forward to downstream agents. |

---

## Context Engineering — How and Why It Works

### The Problem with Naive AI-Assisted Development

When you give an AI all your files and say "build this feature," you get inconsistent results. The AI:
- Re-asks questions you already answered
- Makes conflicting decisions across sessions
- Loses track of constraints decided 3 phases ago
- Has no memory of *why* something was built a certain way

This happens because AI models have a **fixed context window** — they can only see what you put in front of them *right now*. Large codebases overflow the window. Multiple sessions lose previous decisions. Parallel subagents can't share state.

### The Solution: Precision Context

AI solves this with **context engineering** — a system where each agent receives exactly the information it needs, no more. Instead of loading everything, each skill loads a targeted set of files called a **context budget**.

The key insight: **decisions flow forward through files, not through conversation history.**

```
You decide something → Written to a file → Later agent reads that file → Decision respected
```

Every artifact the system creates is designed to be a **future input** for a downstream agent.

### Why It Works: The Chain of Provenance

Every decision made in the workflow has a traceable origin:

```
Your vision
    │ captured by /ai-new-project
    ▼
PROJECT.md ──────────────────────────────► One source of truth for WHY
    │ scoped by requirements gathering
    ▼
REQUIREMENTS.md ─────────────────────────► What "done" means (checkable)
    │ structured by roadmap creation
    ▼
ROADMAP.md ──────────────────────────────► Phase sequence + success criteria
    │ project memory maintained by
    ▼
STATE.md ────────────────────────────────► Where we are NOW (read first, always)
    │ per-phase decisions by /ai-discuss-phase
    ▼
{N}-CONTEXT.md ──────────────────────────► Locked choices for THIS phase
    │ researched by ai-phase-researcher
    ▼
RESEARCH.md ─────────────────────────────► How to implement (domain knowledge)
    │ planned by ai-planner
    ▼
PLAN.md ─────────────────────────────────► Step-by-step tasks (what to build)
    │ executed by ai-executor
    ▼
SUMMARY.md ──────────────────────────────► What was actually built
    │ verified by /ai-verify-work
    ▼
{N}-UAT.md + VERIFICATION.md ────────────► Proof it works (or list of gaps)
```

Each file is a **compressed record of decisions** so no future agent ever has to re-derive them.

### Why Each File Exists

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `PROJECT.md` | `/ai-new-project` | Every skill at start | Source of truth: what, why, constraints, key decisions |
| `research/` | `/ai-new-project` | `ai-roadmapper` | Domain landscape, patterns, pitfalls, prior art |
| `REQUIREMENTS.md` | `/ai-new-project` | `ai-roadmapper`, `/ai-audit-milestone` | Checkable definition of "done" per feature |
| `ROADMAP.md` | `ai-roadmapper` | Every phase skill | Phase sequence, success criteria, requirement traceability |
| `STATE.md` | Every skill (updated) | First thing every skill reads | Current position, velocity, blockers, recent decisions |
| `codebase/` | `/ai-map-codebase` | `ai-planner`, `ai-executor` | 7 structured documents about existing code |
| `{N}-CONTEXT.md` | `/ai-discuss-phase` | `ai-phase-researcher`, `ai-planner` | Implementation decisions locked for this phase |
| `RESEARCH.md` | `ai-phase-researcher` | `ai-planner` | How to implement: patterns, APIs, libraries, risks |
| `PLAN.md` | `ai-planner` | `ai-executor` | Step-by-step tasks with dependencies |
| `SUMMARY.md` | `ai-executor` | `/ai-verify-work`, `/ai-audit-milestone` | What was built, deviations, known issues |
| `{N}-UAT.md` | `/ai-verify-work` | `/ai-audit-milestone` | Test results: passed, failed, gaps |
| `VERIFICATION.md` | `ai-verifier` | `/ai-audit-milestone` | Goal-backward: does the code deliver what was promised? |

### The `<files_to_read>` Protocol — Parallel Execution Without State Loss

When `/ai-execute-phase` runs multiple plans in parallel, each `ai-executor` subagent gets a `<files_to_read>` block:

```xml
<files_to_read>
  .planning/STATE.md
  .planning/PROJECT.md
  .planning/phases/phase-1/01-auth/PLAN.md
  .planning/phases/phase-1/1-CONTEXT.md
</files_to_read>
```

This is how AI achieves **parallelism without conflicts**: each executor has its own fresh 200k context window loaded with exactly what it needs. It doesn't share memory with other executors — it reads from shared files.

```
/ai-execute-phase 1
       │
       ├─► ai-executor (plan 01-01) ─ reads PLAN.md + CONTEXT.md + PROJECT.md
       ├─► ai-executor (plan 01-02) ─ reads PLAN.md + CONTEXT.md + PROJECT.md  
       └─► ai-executor (plan 01-03) ─ reads PLAN.md + CONTEXT.md + PROJECT.md
                            (all run in parallel, write to different files)
```

### How STATE.md Maintains Continuity

`STATE.md` is read at the start of **every single skill**. It's kept under 100 lines intentionally — it's a digest, not an archive. It contains:

- Where we are (phase N of Y, plan A of B)
- What happened last (date + action)
- Velocity (how fast things are completing)
- Active blockers and concerns
- Pointer to PROJECT.md for full decisions log

This means you can close your IDE, come back a week later, and run `/ai-progress` — the system knows exactly where it stopped.

### How Decisions Flow Through CONTEXT.md

`CONTEXT.md` is the most important single-phase artifact. It prevents **decision drift** across the discuss → plan → execute → verify pipeline.

**Without CONTEXT.md:**
```
You discuss: "use Redis for caching"
Planner forgets, plans file-based cache
Executor implements file cache
You discover mismatch only during verify
```

**With CONTEXT.md:**
```
/ai-discuss-phase 1:  writes "D-03: use Redis, not file cache" to CONTEXT.md
ai-phase-researcher:  reads CONTEXT.md → researches Redis patterns specifically
ai-planner:           reads CONTEXT.md → generates tasks using Redis
ai-executor:          reads CONTEXT.md → implements Redis, not file cache
/ai-verify-work:      reads CONTEXT.md → tests against the Redis decision
```

The decision is **written once, respected everywhere.**

### The 15% / 100% Context Budget Rule

The orchestrator (e.g. `/ai-execute-phase`) uses only ~15% of its context budget for coordination. Each subagent (`ai-executor`) gets a **fresh 100% context** via `<files_to_read>`. This means:

- Complex phases with many files don't overflow the orchestrator
- Each subagent can read large PLAN.md files without context pressure
- The orchestrator only tracks completion signals, not full execution details

---

## The Planning File System

### Full `.planning/` Directory Structure

```
.planning/
│
├── PROJECT.md              ← What we're building & why (source of truth)
├── REQUIREMENTS.md         ← Checkable definition of "done"
├── ROADMAP.md              ← Phase sequence + success criteria
├── STATE.md                ← Current position & project memory (read first)
├── config.json             ← Workflow preferences (model, granularity, etc.)
│
├── research/               ← Domain research (from /ai-new-project)
│   ├── SUMMARY.md          ← Synthesized research overview
│   ├── STACK.md            ← Tech stack analysis
│   ├── FEATURES.md         ← Feature patterns from similar products
│   ├── ARCHITECTURE.md     ← Architecture patterns
│   └── PITFALLS.md         ← Known failure modes to avoid
│
├── codebase/               ← Codebase map (from /ai-map-codebase)
│   ├── STACK.md            ← Languages, frameworks, dependencies
│   ├── ARCHITECTURE.md     ← System design & component relationships
│   ├── STRUCTURE.md        ← Directory layout & organization
│   ├── INTEGRATIONS.md     ← External services & APIs
│   ├── CONVENTIONS.md      ← Coding style & patterns used
│   ├── TESTING.md          ← Test infrastructure & coverage
│   └── CONCERNS.md         ← Tech debt, risks, known issues
│
├── phases/
│   └── phase-1-auth/       ← One directory per phase (slug from phase name)
│       ├── 1-CONTEXT.md    ← Implementation decisions (from /ai-discuss-phase 1)
│       ├── RESEARCH.md     ← How to implement this phase (from ai-phase-researcher)
│       │
│       ├── 01-01-user-model/          ← One subdirectory per plan
│       │   ├── PLAN.md               ← Step-by-step tasks
│       │   └── SUMMARY.md            ← What was built (after execution)
│       │
│       ├── 01-02-auth-endpoints/
│       │   ├── PLAN.md
│       │   └── SUMMARY.md
│       │
│       ├── 1-UAT.md                  ← Test results (from /ai-verify-work 1)
│       └── VERIFICATION.md           ← Goal-backward audit
│
├── todos/                  ← Ideas captured during sessions (/ai-add-todo)
│   ├── pending/
│   └── done/
│
├── milestones/             ← Archived milestone snapshots
│   ├── v1.0-ROADMAP.md
│   └── v1.0-REQUIREMENTS.md
│
└── v1.0-MILESTONE-AUDIT.md ← Pre-ship audit report
```

### File Lifecycle

```
Created                     Updated                     Archived/Closed
──────────                  ───────                     ───────────────
PROJECT.md       ──────────► every milestone            ─────────────────────────
REQUIREMENTS.md  ──────────► after each phase           ─► v{N}-REQUIREMENTS.md
ROADMAP.md       ──────────► after each phase/plan      ─► v{N}-ROADMAP.md
STATE.md         ──────────► after every action         (reset per milestone)
{N}-CONTEXT.md   (fixed)    ─────────────────────────────────────────────────────
RESEARCH.md      (fixed)    ─────────────────────────────────────────────────────
PLAN.md          (fixed)    ─────────────────────────────────────────────────────
SUMMARY.md       (fixed)    ─────────────────────────────────────────────────────
{N}-UAT.md       ──────────► re-run after gap fixes     (fixed after verify pass)
VERIFICATION.md  (fixed)    ─────────────────────────────────────────────────────
```

### What Agents Read (by skill)

| Skill | Files read at start |
|-------|---------------------|
| `/ai-discuss-phase N` | STATE.md, PROJECT.md, REQUIREMENTS.md, ROADMAP.md, prior CONTEXT.md files, codebase/ |
| `/ai-plan-phase N` | STATE.md, PROJECT.md, ROADMAP.md, {N}-CONTEXT.md, RESEARCH.md (if exists) |
| `/ai-execute-phase N` | STATE.md, ROADMAP.md → dispatches per-plan files_to_read to subagents |
| `ai-executor` (subagent) | STATE.md, PROJECT.md, {N}-CONTEXT.md, PLAN.md |
| `/ai-verify-work N` | STATE.md, {N}-CONTEXT.md, all PLAN.md + SUMMARY.md in phase |
| `/ai-audit-milestone` | STATE.md, PROJECT.md, REQUIREMENTS.md, ROADMAP.md, all SUMMARY.md + VERIFICATION.md |
| `/ai-complete-milestone` | STATE.md, ROADMAP.md, REQUIREMENTS.md, PROJECT.md, all phase SUMMARY.md |

---

## Main Workflow — Full Lifecycle

This is the recommended end-to-end workflow for a milestone:

```
/ai-map-codebase          (optional — existing codebases only)
        │
        ▼
/ai-new-project           (first time) OR /ai-new-milestone (subsequent milestones)
        │
        ▼
/ai-discuss-phase 1       ─┐
        │                      │  Repeat for each phase
        ▼                      │
/ai-plan-phase 1           │
        │                      │
        ▼                      │
/ai-execute-phase 1        │
        │                      │
        ▼                      │
/ai-verify-work 1         ─┘
        │
        ▼ (all phases done)
/ai-audit-milestone
        │
        ▼
/ai-complete-milestone <version>
```

> **Tip:** Use `/ai-next` at any point — it reads STATE.md and tells you exactly what to run next.

---

## Step-by-Step Reference

### 1. `/ai-map-codebase` — Understand existing code

**Use for:** Brownfield projects where you need to understand the codebase before planning.  
**Skip for:** Greenfield projects with no existing code.

```
/ai-map-codebase
/ai-map-codebase api          # focus on a specific area
```

**What it does:**
- Spawns 4 parallel mapper agents to analyze the codebase
- Writes 7 structured documents to `.planning/codebase/`:
  - `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`
  - `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`
- Commits the codebase map

**Output:** `.planning/codebase/` — codebase understanding document set  
**Next step:** `/ai-new-project` or `/ai-plan-phase`

---

### 2. `/ai-new-project` — Initialize a project

**Use for:** Starting from scratch (first time only). Sets up the full planning structure.

```
/ai-new-project
/ai-new-project --auto @requirements.md    # non-interactive with a document
```

**What it does:**
1. Asks questions about your project goals, stack, and constraints
2. Optionally runs domain research
3. Creates scoped requirements
4. Generates a phase-by-phase roadmap
5. Initializes project memory (`STATE.md`)

**Creates:**
- `.planning/PROJECT.md` — project context
- `.planning/REQUIREMENTS.md` — scoped requirements
- `.planning/ROADMAP.md` — phase breakdown
- `.planning/STATE.md` — project memory
- `.planning/config.json` — workflow preferences

**Flags:**
- `--auto` — Skip interactive questions; expects an idea document via `@file`

**Next step:** `/ai-discuss-phase 1`

---

### 3. `/ai-discuss-phase <N>` — Clarify decisions before planning

**Use for:** Surfacing and resolving gray areas (tech choices, scope, approach) before a phase is planned.

```
/ai-discuss-phase 1
/ai-discuss-phase 2 --auto     # agent picks recommended defaults
```

**What it does:**
1. Loads project context (PROJECT.md, REQUIREMENTS.md, prior decisions)
2. Scouts codebase for reusable assets
3. Identifies gray areas unique to this phase (skips already-decided questions)
4. Lets you discuss each area or accept defaults
5. Captures all decisions in a `CONTEXT.md` for the planner

**Creates:** `.planning/phases/phase-N/{N}-CONTEXT.md`

**Flags:**
- `--auto` — Agent picks all recommended defaults without asking
- `--batch` — Present all gray areas at once instead of one at a time
- `--analyze` — Deep analysis mode: more thorough gray area discovery
- `--text` — Plain text output (use for remote/terminal sessions)

**Next step:** `/ai-plan-phase N`

---

### 4. `/ai-plan-phase <N>` — Create a detailed plan

**Use for:** Generating a PLAN.md with step-by-step tasks for the executor.

```
/ai-plan-phase 1
/ai-plan-phase 1 --skip-research    # skip research, go straight to planning
/ai-plan-phase 1 --auto             # non-interactive
```

**What it does:**
1. Runs domain research (unless skipped)
2. Spawns `ai-planner` agent to create detailed task plans
3. Spawns `ai-plan-checker` to verify the plan achieves the phase goal
4. Iterates until the plan passes verification (max 3 loops)

**Creates:** `.planning/phases/phase-N/{plan-name}/PLAN.md`

**Flags:**
- `--research` — Force re-research even if RESEARCH.md exists
- `--skip-research` — Skip research, go straight to planning
- `--gaps` — Gap closure mode (reads VERIFICATION.md, skips research)
- `--skip-verify` — Skip verification loop
- `--prd <file>` — Use a PRD/requirements file instead of discuss-phase
- `--reviews` — Incorporate cross-AI review feedback from REVIEWS.md
- `--text` — Plain text output (for remote sessions)

**Next step:** `/ai-execute-phase N`

---

### 5. `/ai-execute-phase <N>` — Build the feature

**Use for:** Running the plan — actually making code changes, writing files, etc.

```
/ai-execute-phase 1
/ai-execute-phase 1 --wave 1        # execute only Wave 1
/ai-execute-phase 1 --interactive   # sequential, pair-programming style
/ai-execute-phase 1 --gaps-only     # fix gaps found by verify-work
```

**What it does:**
1. Discovers all PLAN.md files in the phase
2. Analyzes task dependencies and groups into waves
3. Spawns `ai-executor` subagents (one per plan, in parallel waves)
4. Each executor: runs tasks, creates atomic commits, handles deviations
5. Produces SUMMARY.md for each plan

**Flags:**
- `--wave N` — Execute only Wave N (useful for pacing or quota management)
- `--gaps-only` — Only execute gap-closure plans (after `verify-work` creates fix plans)
- `--interactive` — Run plans sequentially inline, no subagents; pair-programming style

**Creates:** `{plan-name}/SUMMARY.md` per plan  
**Next step:** `/ai-verify-work N`

---

### 6. `/ai-verify-work <N>` — Test what was built

**Use for:** Confirming the built feature actually works from the user's perspective.

```
/ai-verify-work 1
/ai-verify-work        # auto-detects current phase
```

**What it does:**
1. Presents UAT test cases one at a time (from PLAN.md success criteria)
2. You confirm pass/fail for each test in plain language
3. If failures found: automatically diagnoses root causes and creates fix plans
4. Fix plans are ready for `/ai-execute-phase N --gaps-only`

**Creates:** `.planning/phases/phase-N/{N}-UAT.md`  
**If issues found:** Gap-closure PLAN.md files, ready for re-execution

**Next step:** If all pass → next phase. If failures → `/ai-execute-phase N --gaps-only`, then re-verify.

---

### 7. `/ai-audit-milestone` — Verify milestone completeness

**Use for:** Checking that all phases together meet the original requirements before shipping.

```
/ai-audit-milestone
/ai-audit-milestone v1.0
```

**What it does:**
1. Reads all phase VERIFICATION.md and SUMMARY.md files
2. Aggregates tech debt and deferred gaps
3. Spawns `ai-integration-checker` to verify cross-phase wiring
4. Checks end-to-end user flows work
5. Produces milestone audit report

**Creates:** `.planning/v{version}-MILESTONE-AUDIT.md`  
**Next step:** If passed → `/ai-complete-milestone`. If gaps found → `/ai-plan-milestone-gaps`.

---

### 8. `/ai-complete-milestone <version>` — Ship and archive

**Use for:** Closing out the milestone — archiving artifacts and tagging the release.

```
/ai-complete-milestone v1.0
/ai-complete-milestone v1.1
```

**What it does:**
1. Verifies audit passed (blocks if not)
2. Gathers stats (phases, commits, LOC, timeline)
3. Archives roadmap + requirements to `.planning/milestones/`
4. Updates PROJECT.md with current state
5. Creates git tag `v{version}`
6. Prepares for next milestone

**Creates:**
- `.planning/milestones/v{version}-ROADMAP.md`
- `.planning/milestones/v{version}-REQUIREMENTS.md`
- Git tag `v{version}`

**Next step:** `/ai-new-milestone` for the next version cycle.

---

## Supporting Skills

### Navigation & Status

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-next` | Auto-detect next step and run it | `/ai-next` |
| `/ai-progress` | Show current state and what's ahead | `/ai-progress` |
| `/ai-health` | Diagnose `.planning/` integrity issues | `/ai-health` or `/ai-health --repair` |
| `/ai-do <description>` | Dispatch natural language to the right skill | `/ai-do "add a new phase for auth"` |

### Quick Tasks (no full phase overhead)

| Skill | Purpose | When to use |
|-------|---------|-------------|
| `/ai-fast <task>` | Trivial inline task, no planning | Typo fix, 1-line config change |
| `/ai-quick <task>` | Small task with commits and state tracking | Anything describable in one sentence, <30 min work |

### Phase Management

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-add-phase <description>` | Add a new phase to the roadmap | `/ai-add-phase "add Redis caching layer"` |
| `/ai-insert-phase <description>` | Insert urgent phase between existing ones (decimal numbering: 2.1) | `/ai-insert-phase "hotfix auth regression"` |
| `/ai-remove-phase <N>` | Remove a future phase from roadmap | `/ai-remove-phase 5` |
| `/ai-add-tests <N>` | Generate unit/E2E tests for a completed phase | `/ai-add-tests 3` |

### Todo & Backlog

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-add-todo <description>` | Capture an idea or task for later | `/ai-add-todo "consider switching to gRPC"` |
| `/ai-check-todos` | List pending todos and pick one to work on | `/ai-check-todos` |
| `/ai-note <text>` | Zero-friction idea capture | `/ai-note "look into CUDA memory pooling"` |
| `/ai-add-backlog <description>` | Park idea in backlog (999.x) | `/ai-add-backlog "multi-tenant support"` |

### Debugging

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-debug <issue>` | Systematic debugging with `ai-debugger` agent | `/ai-debug "segfault in tracker at line 42"` |
| `/ai-forensics` | Post-mortem investigation of failed workflows | `/ai-forensics` |

### Autonomous & Batch Execution

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-autonomous` | Run all remaining phases automatically | `/ai-autonomous` or `--from N` |
| `/ai-plan-milestone-gaps` | Create phases to close audit gaps | `/ai-plan-milestone-gaps` |

### Session & Reports

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-stats` | Project statistics (phases, commits, LOC) | `/ai-stats` |
| `/ai-session-report` | Token usage and session work summary | `/ai-session-report` |
| `/ai-pause-work` | Create handoff context for resuming later | `/ai-pause-work` |
| `/ai-resume-work` | Restore context from a paused session | `/ai-resume-work` |

### Configuration

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/ai-settings` | Configure workflow toggles | `/ai-settings` |
| `/ai-set-profile` | Switch model profile (quality/balanced/budget) | `/ai-set-profile balanced` |
| `/ai-update` | Update AI to latest version | `/ai-update` |

---

## Project-Specific Skills

These skills are tailored to the AI framework DeepStream SDK codebase.

### `/ai-codebase-visualizer` — Generate architecture diagrams

Generates Mermaid diagrams from the codebase (architecture, class hierarchy, pipeline topology, data flow, sequence diagrams).

```
/ai-codebase-visualizer architecture overview
/ai-codebase-visualizer class hierarchy of ABRCore
/ai-codebase-visualizer pipeline topology
/ai-codebase-visualizer sequence for alert generation
/ai-codebase-visualizer data flow for line_cross
```

---

### `/ai-code-review` — Multi-step code review

Produces a structured Markdown report covering readability, correctness, security, performance, error handling, and testability. Supports both C++ and Python.

```
/ai-code-review review function X in file Y
/ai-code-review review file src/tracker/tracker.cpp
/ai-code-review review the diff in file A
```

---

### `/ai-commit-messages` — Generate commit messages

Creates commit messages following project conventions (component-prefixed subject lines, imperative tone, ≤72 chars).

```
/ai-commit-messages
/ai-commit-messages feat for line_cross app
/ai-commit-messages fix in tracker
```

**Output format examples:**
```
Tracker: add re-ID fallback for occluded tracks
fix: null-check before pose buffer access
LineCross: fix hysteresis logic, Tracker: reset on scene change
```

---

### `/ai-prompt-leverage` — Strengthen prompts

Transforms a raw prompt into a well-structured, execution-ready instruction set for AI agents.

```
/ai-prompt-leverage <paste your raw prompt here>
```

---

### `/ai-pt-deploy` — Deploy AI Product

Interactive deployment guide — collects branch, config parameters, and migration strategy, then runs `update_product.sh` with confirmation gate.

```
/ai-pt-deploy
/ai-pt-deploy main          # hint the branch
/ai-pt-deploy device-name   # hint the device
```

**Key safety gate:** Asks for explicit `YES` confirmation before any deployment script runs.

---

### `/ai-pt-migration` — Migrate VAS SDK configs

Interactive guide for migrating VAS configs between container versions via `migrate.py`.

```
/ai-pt-migration
/ai-pt-migration v2.1       # hint old version
```

**Key safety gate:** Export must succeed before import is attempted.

---

## Agents Reference

Agents are spawned automatically by skills. You don't call them directly, but knowing what each does helps you understand what's happening during execution.

| Agent | Role | Spawned by |
|-------|------|-----------|
| `ai-executor` | Executes PLAN.md files with atomic commits | `ai-execute-phase` |
| `ai-planner` | Creates PLAN.md from CONTEXT.md and research | `ai-plan-phase` |
| `ai-plan-checker` | Verifies plan achieves phase goal | `ai-plan-phase` |
| `ai-phase-researcher` | Researches how to implement a phase | `ai-plan-phase` |
| `ai-verifier` | Checks built code matches phase promise | `ai-execute-phase` |
| `ai-codebase-mapper` | Explores codebase focus area, writes docs | `ai-map-codebase` |
| `ai-roadmapper` | Creates ROADMAP.md from requirements | `ai-new-project` |
| `ai-project-researcher` | Researches domain before roadmap creation | `ai-new-project` |
| `ai-research-synthesizer` | Synthesizes parallel researcher outputs | `ai-new-project` |
| `ai-debugger` | Systematic bug investigation | `ai-debug` |
| `ai-integration-checker` | Verifies cross-phase integration | `ai-audit-milestone` |
| `ai-nyquist-auditor` | Fills validation gaps, generates tests | `ai-validate-phase` |
| `ai-ui-researcher` | Creates UI design contracts (UI-SPEC.md) | `ai-ui-phase` |
| `ai-ui-checker` | Validates UI spec quality | `ai-ui-phase` |
| `ai-ui-auditor` | Retroactive visual audit of frontend code | `ai-ui-review` |
| `ai-user-profiler` | Analyzes developer behavioral profile | `ai-profile-user` |
| `ai-advisor-researcher` | Researches gray area decisions | `ai-discuss-phase` |
| `ai-assumptions-analyzer` | Deep analysis of phase assumptions | `ai-discuss-phase` |
| **Project agents** | | |
| `ai-code-tracer` | Trace C++/Python call chains from failure point to root cause | `ai-debug` |
| `ai-feature-builder` | Build features with AI SDK conventions | `ai-execute-phase` |
| `ai-fix-planner` | Plan fixes for diagnosed bugs | `ai-debug` |
| `ai-implementer` | Execute implementation tasks | `ai-execute-phase` |
| `ai-incident-investigator` | Investigate production incidents | `ai-debug` |
| `ai-issue-analyzer` | Analyze reported issues and reproduce | `ai-debug` |
| `ai-log-analyst` | Parse and interpret DeepStream/GStreamer logs | `ai-debug` |
| `ai-plan-architect` | High-level architecture planning | `ai-plan-phase` |
| `ai-planner` | Task-level planning | `ai-plan-phase` |
| `ai-reviewer` | Code review | `ai-code-review` |
| `ai-test-planner` | Test strategy planning | `ai-add-tests` |
| `ai-thorough-reviewer` | Deep, comprehensive code review | `ai-code-review` |

---

## Quick Reference Card

### New project, first milestone

```
/ai-map-codebase              # (if brownfield) understand the codebase
/ai-new-project               # initialize: requirements + roadmap
/ai-discuss-phase 1           # clarify decisions for phase 1
/ai-plan-phase 1              # create execution plan
/ai-execute-phase 1           # build it
/ai-verify-work 1             # test it
  # if failures: /ai-execute-phase 1 --gaps-only → /ai-verify-work 1
# ...repeat discuss → plan → execute → verify for phases 2, 3, ...
/ai-audit-milestone           # verify all requirements met
/ai-complete-milestone v1.0   # ship and archive
```

### Subsequent milestones

```
/ai-new-milestone v1.1        # new requirements + roadmap continuation
/ai-discuss-phase N
/ai-plan-phase N
/ai-execute-phase N
/ai-verify-work N
# ...
/ai-audit-milestone v1.1
/ai-complete-milestone v1.1
```

### Don't know where you are?

```
/ai-next       # auto-detect and run the next step
/ai-progress   # show status and route to action
/ai-health     # diagnose planning directory issues
```

### Quick task (no phase overhead)

```
/ai-fast "fix typo in README"
/ai-quick "add null check in tracker.cpp before access"
```

### Emergency phase insert

```
/ai-insert-phase "hotfix: crash on empty frame list"
/ai-discuss-phase 3.1
/ai-plan-phase 3.1
/ai-execute-phase 3.1
/ai-verify-work 3.1
```

---

*This guide covers `.github/` skills. The workflow backend lives in `.github/ai/workflows/`.*
