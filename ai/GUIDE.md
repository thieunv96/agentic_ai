# AI Skills — User Guide

> **What is this?**  
> The AI framework skill system is a structured AI-assisted development workflow. Skills are invoked as slash commands (e.g. `/my-plan-phase 1`) and orchestrate AI agents to plan, build, verify, and ship features in a reproducible way.

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
| **`.note/`** | The workspace directory where all AI artifacts live (roadmap, requirements, phase plans, state). |
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
    │ captured by /my-new-project
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
    │ per-phase decisions by /my-discuss-phase
    ▼
{N}-CONTEXT.md ──────────────────────────► Locked choices for THIS phase
    │ researched by ai-phase-researcher
    ▼
RESEARCH.md ─────────────────────────────► How to implement (domain knowledge)
    │ planned by my-planner
    ▼
PLAN.md ─────────────────────────────────► Step-by-step tasks (what to build)
    │ executed by my-executor
    ▼
SUMMARY.md ──────────────────────────────► What was actually built
    │ verified by /my-verify-work
    ▼
{N}-UAT.md + VERIFICATION.md ────────────► Proof it works (or list of gaps)
```

Each file is a **compressed record of decisions** so no future agent ever has to re-derive them.

### Why Each File Exists

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `PROJECT.md` | `/my-new-project` | Every skill at start | Source of truth: what, why, constraints, key decisions |
| `research/` | `/my-new-project` | `my-roadmapper` | Domain landscape, patterns, pitfalls, prior art |
| `REQUIREMENTS.md` | `/my-new-project` | `my-roadmapper`, `/my-audit-milestone` | Checkable definition of "done" per feature |
| `ROADMAP.md` | `my-roadmapper` | Every phase skill | Phase sequence, success criteria, requirement traceability |
| `STATE.md` | Every skill (updated) | First thing every skill reads | Current position, velocity, blockers, recent decisions |
| `codebase/` | `/my-map-codebase` | `my-planner`, `my-executor` | 7 structured documents about existing code |
| `{N}-CONTEXT.md` | `/my-discuss-phase` | `my-phase-researcher`, `my-planner` | Implementation decisions locked for this phase |
| `RESEARCH.md` | `my-phase-researcher` | `my-planner` | How to implement: patterns, APIs, libraries, risks |
| `PLAN.md` | `my-planner` | `my-executor` | Step-by-step tasks with dependencies |
| `SUMMARY.md` | `my-executor` | `/my-verify-work`, `/my-audit-milestone` | What was built, deviations, known issues |
| `{N}-UAT.md` | `/my-verify-work` | `/my-audit-milestone` | Test results: passed, failed, gaps |
| `VERIFICATION.md` | `my-verifier` | `/my-audit-milestone` | Goal-backward: does the code deliver what was promised? |

### The `<files_to_read>` Protocol — Parallel Execution Without State Loss

When `/my-execute-phase` runs multiple plans in parallel, each `my-executor` subagent gets a `<files_to_read>` block:

```xml
<files_to_read>
  .note/STATE.md
  .note/PROJECT.md
  .note/phases/phase-1/01-auth/PLAN.md
  .note/phases/phase-1/1-CONTEXT.md
</files_to_read>
```

This is how AI achieves **parallelism without conflicts**: each executor has its own fresh 200k context window loaded with exactly what it needs. It doesn't share memory with other executors — it reads from shared files.

```
/my-execute-phase 1
       │
       ├─► my-executor (plan 01-01) ─ reads PLAN.md + CONTEXT.md + PROJECT.md
       ├─► my-executor (plan 01-02) ─ reads PLAN.md + CONTEXT.md + PROJECT.md  
       └─► my-executor (plan 01-03) ─ reads PLAN.md + CONTEXT.md + PROJECT.md
                            (all run in parallel, write to different files)
```

### How STATE.md Maintains Continuity

`STATE.md` is read at the start of **every single skill**. It's kept under 100 lines intentionally — it's a digest, not an archive. It contains:

- Where we are (phase N of Y, plan A of B)
- What happened last (date + action)
- Velocity (how fast things are completing)
- Active blockers and concerns
- Pointer to PROJECT.md for full decisions log

This means you can close your IDE, come back a week later, and run `/my-progress` — the system knows exactly where it stopped.

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
/my-discuss-phase 1:  writes "D-03: use Redis, not file cache" to CONTEXT.md
ai-phase-researcher:  reads CONTEXT.md → researches Redis patterns specifically
my-planner:           reads CONTEXT.md → generates tasks using Redis
my-executor:          reads CONTEXT.md → implements Redis, not file cache
/my-verify-work:      reads CONTEXT.md → tests against the Redis decision
```

The decision is **written once, respected everywhere.**

### The 15% / 100% Context Budget Rule

The orchestrator (e.g. `/my-execute-phase`) uses only ~15% of its context budget for coordination. Each subagent (`my-executor`) gets a **fresh 100% context** via `<files_to_read>`. This means:

- Complex phases with many files don't overflow the orchestrator
- Each subagent can read large PLAN.md files without context pressure
- The orchestrator only tracks completion signals, not full execution details

---

## The Planning File System

### Full `.note/` Directory Structure

```
.note/
│
├── PROJECT.md              ← What we're building & why (source of truth)
├── REQUIREMENTS.md         ← Checkable definition of "done"
├── ROADMAP.md              ← Phase sequence + success criteria
├── STATE.md                ← Current position & project memory (read first)
├── config.json             ← Workflow preferences (model, granularity, etc.)
│
├── research/               ← Domain research (from /my-new-project)
│   ├── SUMMARY.md          ← Synthesized research overview
│   ├── STACK.md            ← Tech stack analysis
│   ├── FEATURES.md         ← Feature patterns from similar products
│   ├── ARCHITECTURE.md     ← Architecture patterns
│   └── PITFALLS.md         ← Known failure modes to avoid
│
├── codebase/               ← Codebase map (from /my-map-codebase)
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
│       ├── 1-CONTEXT.md    ← Implementation decisions (from /my-discuss-phase 1)
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
│       ├── 1-UAT.md                  ← Test results (from /my-verify-work 1)
│       └── VERIFICATION.md           ← Goal-backward audit
│
├── todos/                  ← Ideas captured during sessions (/my-add-todo)
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
| `/my-discuss-phase N` | STATE.md, PROJECT.md, REQUIREMENTS.md, ROADMAP.md, prior CONTEXT.md files, codebase/ |
| `/my-plan-phase N` | STATE.md, PROJECT.md, ROADMAP.md, {N}-CONTEXT.md, RESEARCH.md (if exists) |
| `/my-execute-phase N` | STATE.md, ROADMAP.md → dispatches per-plan files_to_read to subagents |
| `my-executor` (subagent) | STATE.md, PROJECT.md, {N}-CONTEXT.md, PLAN.md |
| `/my-verify-work N` | STATE.md, {N}-CONTEXT.md, all PLAN.md + SUMMARY.md in phase |
| `/my-audit-milestone` | STATE.md, PROJECT.md, REQUIREMENTS.md, ROADMAP.md, all SUMMARY.md + VERIFICATION.md |
| `/my-complete-milestone` | STATE.md, ROADMAP.md, REQUIREMENTS.md, PROJECT.md, all phase SUMMARY.md |

---

## Main Workflow — Full Lifecycle

This is the recommended end-to-end workflow for a milestone:

```
/my-map-codebase          (optional — existing codebases only)
        │
        ▼
/my-new-project           (first time) OR /my-new-milestone (subsequent milestones)
        │
        ▼
/my-discuss-phase 1       ─┐
        │                      │  Repeat for each phase
        ▼                      │
/my-plan-phase 1           │
        │                      │
        ▼                      │
/my-execute-phase 1        │
        │                      │
        ▼                      │
/my-verify-work 1         ─┘
        │
        ▼ (all phases done)
/my-audit-milestone
        │
        ▼
/my-complete-milestone <version>
```

> **Tip:** Use `/my-next` at any point — it reads STATE.md and tells you exactly what to run next.

---

## Step-by-Step Reference

### 1. `/my-map-codebase` — Understand existing code

**Use for:** Brownfield projects where you need to understand the codebase before planning.  
**Skip for:** Greenfield projects with no existing code.

```
/my-map-codebase
/my-map-codebase api          # focus on a specific area
```

**What it does:**
- Spawns 4 parallel mapper agents to analyze the codebase
- Writes 7 structured documents to `.note/codebase/`:
  - `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`
  - `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`
- Commits the codebase map

**Output:** `.note/codebase/` — codebase understanding document set  
**Next step:** `/my-new-project` or `/my-plan-phase`

---

### 2. `/my-new-project` — Initialize a project

**Use for:** Starting from scratch (first time only). Sets up the full planning structure.

```
/my-new-project
/my-new-project --auto @requirements.md    # non-interactive with a document
```

**What it does:**
1. Asks questions about your project goals, stack, and constraints
2. Optionally runs domain research
3. Creates scoped requirements
4. Generates a phase-by-phase roadmap
5. Initializes project memory (`STATE.md`)

**Creates:**
- `.note/PROJECT.md` — project context
- `.note/REQUIREMENTS.md` — scoped requirements
- `.note/ROADMAP.md` — phase breakdown
- `.note/STATE.md` — project memory
- `.note/config.json` — workflow preferences

**Flags:**
- `--auto` — Skip interactive questions; expects an idea document via `@file`

**Next step:** `/my-discuss-phase 1`

---

### 3. `/my-discuss-phase <N>` — Clarify decisions before planning

**Use for:** Surfacing and resolving gray areas (tech choices, scope, approach) before a phase is planned.

```
/my-discuss-phase 1
/my-discuss-phase 2 --auto     # agent picks recommended defaults
```

**What it does:**
1. Loads project context (PROJECT.md, REQUIREMENTS.md, prior decisions)
2. Scouts codebase for reusable assets
3. Identifies gray areas unique to this phase (skips already-decided questions)
4. Lets you discuss each area or accept defaults
5. Captures all decisions in a `CONTEXT.md` for the planner

**Creates:** `.note/phases/phase-N/{N}-CONTEXT.md`

**Flags:**
- `--auto` — Agent picks all recommended defaults without asking
- `--batch` — Present all gray areas at once instead of one at a time
- `--analyze` — Deep analysis mode: more thorough gray area discovery
- `--text` — Plain text output (use for remote/terminal sessions)

**Next step:** `/my-plan-phase N`

---

### 4. `/my-plan-phase <N>` — Create a detailed plan

**Use for:** Generating a PLAN.md with step-by-step tasks for the executor.

```
/my-plan-phase 1
/my-plan-phase 1 --skip-research    # skip research, go straight to planning
/my-plan-phase 1 --auto             # non-interactive
```

**What it does:**
1. Runs domain research (unless skipped)
2. Spawns `my-planner` agent to create detailed task plans
3. Spawns `my-plan-checker` to verify the plan achieves the phase goal
4. Iterates until the plan passes verification (max 3 loops)

**Creates:** `.note/phases/phase-N/{plan-name}/PLAN.md`

**Flags:**
- `--research` — Force re-research even if RESEARCH.md exists
- `--skip-research` — Skip research, go straight to planning
- `--gaps` — Gap closure mode (reads VERIFICATION.md, skips research)
- `--skip-verify` — Skip verification loop
- `--prd <file>` — Use a PRD/requirements file instead of discuss-phase
- `--reviews` — Incorporate cross-AI review feedback from REVIEWS.md
- `--text` — Plain text output (for remote sessions)

**Next step:** `/my-execute-phase N`

---

### 5. `/my-execute-phase <N>` — Build the feature

**Use for:** Running the plan — actually making code changes, writing files, etc.

```
/my-execute-phase 1
/my-execute-phase 1 --wave 1        # execute only Wave 1
/my-execute-phase 1 --interactive   # sequential, pair-programming style
/my-execute-phase 1 --gaps-only     # fix gaps found by verify-work
```

**What it does:**
1. Discovers all PLAN.md files in the phase
2. Analyzes task dependencies and groups into waves
3. Spawns `my-executor` subagents (one per plan, in parallel waves)
4. Each executor: runs tasks, creates atomic commits, handles deviations
5. Produces SUMMARY.md for each plan

**Flags:**
- `--wave N` — Execute only Wave N (useful for pacing or quota management)
- `--gaps-only` — Only execute gap-closure plans (after `verify-work` creates fix plans)
- `--interactive` — Run plans sequentially inline, no subagents; pair-programming style

**Creates:** `{plan-name}/SUMMARY.md` per plan  
**Next step:** `/my-verify-work N`

---

### 6. `/my-verify-work <N>` — Test what was built

**Use for:** Confirming the built feature actually works from the user's perspective.

```
/my-verify-work 1
/my-verify-work        # auto-detects current phase
```

**What it does:**
1. Presents UAT test cases one at a time (from PLAN.md success criteria)
2. You confirm pass/fail for each test in plain language
3. If failures found: automatically diagnoses root causes and creates fix plans
4. Fix plans are ready for `/my-execute-phase N --gaps-only`

**Creates:** `.note/phases/phase-N/{N}-UAT.md`  
**If issues found:** Gap-closure PLAN.md files, ready for re-execution

**Next step:** If all pass → next phase. If failures → `/my-execute-phase N --gaps-only`, then re-verify.

---

### 7. `/my-audit-milestone` — Verify milestone completeness

**Use for:** Checking that all phases together meet the original requirements before shipping.

```
/my-audit-milestone
/my-audit-milestone v1.0
```

**What it does:**
1. Reads all phase VERIFICATION.md and SUMMARY.md files
2. Aggregates tech debt and deferred gaps
3. Spawns `my-integration-checker` to verify cross-phase wiring
4. Checks end-to-end user flows work
5. Produces milestone audit report

**Creates:** `.note/v{version}-MILESTONE-AUDIT.md`  
**Next step:** If passed → `/my-complete-milestone`. If gaps found → `/my-plan-milestone-gaps`.

---

### 8. `/my-complete-milestone <version>` — Ship and archive

**Use for:** Closing out the milestone — archiving artifacts and tagging the release.

```
/my-complete-milestone v1.0
/my-complete-milestone v1.1
```

**What it does:**
1. Verifies audit passed (blocks if not)
2. Gathers stats (phases, commits, LOC, timeline)
3. Archives roadmap + requirements to `.note/milestones/`
4. Updates PROJECT.md with current state
5. Creates git tag `v{version}`
6. Prepares for next milestone

**Creates:**
- `.note/milestones/v{version}-ROADMAP.md`
- `.note/milestones/v{version}-REQUIREMENTS.md`
- Git tag `v{version}`

**Next step:** `/my-new-milestone` for the next version cycle.

---

## Supporting Skills

### Navigation & Status

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-next` | Auto-detect next step and run it | `/my-next` |
| `/my-progress` | Show current state and what's ahead | `/my-progress` |
| `/my-health` | Diagnose `.note/` integrity issues | `/my-health` or `/my-health --repair` |
| `/my-do <description>` | Dispatch natural language to the right skill | `/my-do "add a new phase for auth"` |

### Quick Tasks (no full phase overhead)

| Skill | Purpose | When to use |
|-------|---------|-------------|
| `/my-fast <task>` | Trivial inline task, no planning | Typo fix, 1-line config change |
| `/my-quick <task>` | Small task with commits and state tracking | Anything describable in one sentence, <30 min work |

### Phase Management

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-add-phase <description>` | Add a new phase to the roadmap | `/my-add-phase "add Redis caching layer"` |
| `/my-insert-phase <description>` | Insert urgent phase between existing ones (decimal numbering: 2.1) | `/my-insert-phase "hotfix auth regression"` |
| `/my-remove-phase <N>` | Remove a future phase from roadmap | `/my-remove-phase 5` |
| `/my-add-tests <N>` | Generate unit/E2E tests for a completed phase | `/my-add-tests 3` |

### Todo & Backlog

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-add-todo <description>` | Capture an idea or task for later | `/my-add-todo "consider switching to gRPC"` |
| `/my-check-todos` | List pending todos and pick one to work on | `/my-check-todos` |
| `/my-note <text>` | Zero-friction idea capture | `/my-note "look into CUDA memory pooling"` |
| `/my-add-backlog <description>` | Park idea in backlog (999.x) | `/my-add-backlog "multi-tenant support"` |

### Debugging

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-debug <issue>` | Systematic debugging with `my-debugger` agent | `/my-debug "segfault in tracker at line 42"` |
| `/my-forensics` | Post-mortem investigation of failed workflows | `/my-forensics` |

### Autonomous & Batch Execution

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-autonomous` | Run all remaining phases automatically | `/my-autonomous` or `--from N` |
| `/my-plan-milestone-gaps` | Create phases to close audit gaps | `/my-plan-milestone-gaps` |

### Session & Reports

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-stats` | Project statistics (phases, commits, LOC) | `/my-stats` |
| `/my-session-report` | Token usage and session work summary | `/my-session-report` |
| `/my-pause-work` | Create handoff context for resuming later | `/my-pause-work` |
| `/my-resume-work` | Restore context from a paused session | `/my-resume-work` |

### Configuration

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/my-settings` | Configure workflow toggles | `/my-settings` |
| `/my-set-profile` | Switch model profile (quality/balanced/budget) | `/my-set-profile balanced` |
| `/my-update` | Update AI to latest version | `/my-update` |

---

## Project-Specific Skills

These skills are tailored to the AI framework DeepStream SDK codebase.

### `/my-codebase-visualizer` — Generate architecture diagrams

Generates Mermaid diagrams from the codebase (architecture, class hierarchy, pipeline topology, data flow, sequence diagrams).

```
/my-codebase-visualizer architecture overview
/my-codebase-visualizer class hierarchy of ABRCore
/my-codebase-visualizer pipeline topology
/my-codebase-visualizer sequence for alert generation
/my-codebase-visualizer data flow for line_cross
```

---

### `/my-code-review` — Multi-step code review

Produces a structured Markdown report covering readability, correctness, security, performance, error handling, and testability. Supports both C++ and Python.

```
/my-code-review review function X in file Y
/my-code-review review file src/tracker/tracker.cpp
/my-code-review review the diff in file A
```

---

### `/my-commit-messages` — Generate commit messages

Creates commit messages following project conventions (component-prefixed subject lines, imperative tone, ≤72 chars).

```
/my-commit-messages
/my-commit-messages feat for line_cross app
/my-commit-messages fix in tracker
```

**Output format examples:**
```
Tracker: add re-ID fallback for occluded tracks
fix: null-check before pose buffer access
LineCross: fix hysteresis logic, Tracker: reset on scene change
```

---

### `/my-prompt-leverage` — Strengthen prompts

Transforms a raw prompt into a well-structured, execution-ready instruction set for AI agents.

```
/my-prompt-leverage <paste your raw prompt here>
```

---

### `/my-pt-deploy` — Deploy AI Product

Interactive deployment guide — collects branch, config parameters, and migration strategy, then runs `update_product.sh` with confirmation gate.

```
/my-pt-deploy
/my-pt-deploy main          # hint the branch
/my-pt-deploy device-name   # hint the device
```

**Key safety gate:** Asks for explicit `YES` confirmation before any deployment script runs.

---

### `/my-pt-migration` — Migrate VAS SDK configs

Interactive guide for migrating VAS configs between container versions via `migrate.py`.

```
/my-pt-migration
/my-pt-migration v2.1       # hint old version
```

**Key safety gate:** Export must succeed before import is attempted.

---

## Agents Reference

Agents are spawned automatically by skills. You don't call them directly, but knowing what each does helps you understand what's happening during execution.

| Agent | Role | Spawned by |
|-------|------|-----------|
| `my-executor` | Executes PLAN.md files with atomic commits | `my-execute-phase` |
| `my-planner` | Creates PLAN.md from CONTEXT.md and research | `my-plan-phase` |
| `my-plan-checker` | Verifies plan achieves phase goal | `my-plan-phase` |
| `my-phase-researcher` | Researches how to implement a phase | `my-plan-phase` |
| `my-verifier` | Checks built code matches phase promise | `my-execute-phase` |
| `my-codebase-mapper` | Explores codebase focus area, writes docs | `my-map-codebase` |
| `my-roadmapper` | Creates ROADMAP.md from requirements | `my-new-project` |
| `my-project-researcher` | Researches domain before roadmap creation | `my-new-project` |
| `my-research-synthesizer` | Synthesizes parallel researcher outputs | `my-new-project` |
| `my-debugger` | Systematic bug investigation | `my-debug` |
| `my-integration-checker` | Verifies cross-phase integration | `my-audit-milestone` |
| `my-nyquist-auditor` | Fills validation gaps, generates tests | `my-validate-phase` |
| `my-ui-researcher` | Creates UI design contracts (UI-SPEC.md) | `my-ui-phase` |
| `my-ui-checker` | Validates UI spec quality | `my-ui-phase` |
| `my-ui-auditor` | Retroactive visual audit of frontend code | `my-ui-review` |
| `my-user-profiler` | Analyzes developer behavioral profile | `my-profile-user` |
| `my-advisor-researcher` | Researches gray area decisions | `my-discuss-phase` |
| `my-assumptions-analyzer` | Deep analysis of phase assumptions | `my-discuss-phase` |
| **Project agents** | | |
| `my-code-tracer` | Trace C++/Python call chains from failure point to root cause | `my-debug` |
| `my-feature-builder` | Build features with AI SDK conventions | `my-execute-phase` |
| `my-fix-planner` | Plan fixes for diagnosed bugs | `my-debug` |
| `my-implementer` | Execute implementation tasks | `my-execute-phase` |
| `my-incident-investigator` | Investigate production incidents | `my-debug` |
| `my-issue-analyzer` | Analyze reported issues and reproduce | `my-debug` |
| `my-log-analyst` | Parse and interpret DeepStream/GStreamer logs | `my-debug` |
| `my-plan-architect` | High-level architecture planning | `my-plan-phase` |
| `my-planner` | Task-level planning | `my-plan-phase` |
| `my-reviewer` | Code review | `my-code-review` |
| `my-test-planner` | Test strategy planning | `my-add-tests` |
| `my-thorough-reviewer` | Deep, comprehensive code review | `my-code-review` |

---

## Quick Reference Card

### New project, first milestone

```
/my-map-codebase              # (if brownfield) understand the codebase
/my-new-project               # initialize: requirements + roadmap
/my-discuss-phase 1           # clarify decisions for phase 1
/my-plan-phase 1              # create execution plan
/my-execute-phase 1           # build it
/my-verify-work 1             # test it
  # if failures: /my-execute-phase 1 --gaps-only → /my-verify-work 1
# ...repeat discuss → plan → execute → verify for phases 2, 3, ...
/my-audit-milestone           # verify all requirements met
/my-complete-milestone v1.0   # ship and archive
```

### Subsequent milestones

```
/my-new-milestone v1.1        # new requirements + roadmap continuation
/my-discuss-phase N
/my-plan-phase N
/my-execute-phase N
/my-verify-work N
# ...
/my-audit-milestone v1.1
/my-complete-milestone v1.1
```

### Don't know where you are?

```
/my-next       # auto-detect and run the next step
/my-progress   # show status and route to action
/my-health     # diagnose planning directory issues
```

### Quick task (no phase overhead)

```
/my-fast "fix typo in README"
/my-quick "add null check in tracker.cpp before access"
```

### Emergency phase insert

```
/my-insert-phase "hotfix: crash on empty frame list"
/my-discuss-phase 3.1
/my-plan-phase 3.1
/my-execute-phase 3.1
/my-verify-work 3.1
```

---

*This guide covers `.github/` skills. The workflow backend lives in `.github/my/workflows/`.*
