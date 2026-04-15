# Copilot Instructions — copilot_teams (Asilla ML/AI Framework)

## What This Repository Is

This repo contains the **Asilla ML/AI development framework** — a structured, AI-assisted workflow system optimized for Computer Vision and Vision-Language Model (VLM) development. The `ai_team/` directory deploys to `.github/` in target ML projects.

Current version: `ai_team/asilla/VERSION`

## Architecture

### Deployment Model

`ai_team/` maps directly to `.github/` in any project where Asilla is installed:
```
ai_team/
├── skills/asilla-*/SKILL.md     → entry points (slash commands)
├── agents/*.agent.md            → subagent prompt definitions
├── asilla/workflows/*.md        → workflow implementations
├── asilla/references/*.md       → shared ML knowledge
├── asilla/templates/            → artifact templates
├── asilla/bin/asilla-tools.cjs  → CLI for commits, state, config
├── scripts/                     → Python hooks
└── hooks/pre-tool-use.json      → Claude Code PreToolUse hook
```

### The 10 Commands

| Command | Purpose |
|---------|---------|
| `asilla-new-version <name>` | Init version with ML project template |
| `asilla-provide-context` | Ingest papers/code refs → research → roadmap |
| `asilla-discuss <phase>` | Discuss phase decisions → CONTEXT.md + log |
| `asilla-plan <phase>` | Create PLAN.md (ML-aware) |
| `asilla-implement <phase>` | Execute phase code |
| `asilla-evaluate <phase>` | Evaluate model metrics → EVALUATION.md |
| `asilla-debug <issue>` | Debug training/evaluation issues |
| `asilla-status` | Show progress + metrics |
| `asilla-continue` | Auto-run next step |
| `asilla-release-version <v>` | Close version, archive, tag |

### The 10 Agents

| Agent | Role |
|-------|------|
| `asilla-planner` | Creates PLAN.md with ML-aware task decomposition |
| `asilla-executor` | Implements Python/PyTorch/ML code |
| `asilla-roadmapper` | Creates phase roadmap from ML requirements |
| `asilla-ml-researcher` | Researches CV/VLM papers, architectures, SOTA |
| `asilla-research-synthesizer` | Synthesizes research into actionable insights |
| `asilla-ml-evaluator` | Evaluates model: metrics, benchmarks, go/no-go |
| `asilla-data-analyst` | Analyzes CV datasets (COCO, ImageNet, VQA, etc.) |
| `asilla-debugger` | Debugs training/CUDA/data pipeline issues |
| `asilla-plan-checker` | Verifies plan quality before execution |
| `asilla-codebase-mapper` | Maps existing codebase/code references |

## Key Conventions

### Skill Frontmatter
Every `SKILL.md` has YAML frontmatter:
```yaml
---
name: asilla-evaluate
description: Evaluate ML model performance...
argument-hint: "<phase-number> [--quick] [--full]"
agent: asilla-ml-evaluator
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---
```

### asilla-tools CLI Pattern
Always handle `@file:*` response:
```bash
INIT=$(node ".github/asilla/bin/asilla-tools.cjs" init execute-phase "1")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

### Commit Format (ML Edition)
```
{type}({phase}-{plan}): {description}
```
ML-specific types: `train`, `data`, `model`, `eval`, `experiment`  
Standard types: `feat`, `fix`, `refactor`, `chore`, `docs`

### Context Budget Rule
Orchestrators use ~15% context budget. Each spawned subagent gets a fresh 100% context via `<files_to_read>` blocks.

### Key Planning Artifacts
- `.planning/KNOWLEDGE.md` — papers, code refs, key insights (created by provide-context)
- `.planning/{N}-CONTEXT.md` — locked decisions per phase (consumed by planner/executor)
- `.planning/{N}-DISCUSSION-LOG.md` — audit trail (always committed)
- `.planning/phases/{phase}/EVALUATION.md` — model evaluation results (committed with metrics)

### Pre-tool Hook
`hooks/pre-tool-use.json` → runs `scripts/check_dangerous_command.py`. Exit 2 = hard block on dangerous shell commands.

### Adding a New Skill
1. Create `skills/asilla-{name}/SKILL.md` with frontmatter
2. Create matching `asilla/workflows/{name}.md` with workflow logic
3. Update `asilla-file-manifest.json` with checksums
4. Reference ML-specific docs in `<execution_context>` if relevant
