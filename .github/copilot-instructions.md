# Copilot Instructions — copilot_teams (AI Framework)

## What This Repository Is

This repo contains the **AI development framework** — a structured, AI-assisted workflow system optimized for Computer Vision and Vision-Language Model (VLM) development. The `ai_team/` directory deploys to `.github/` in target ML projects.

Current version: `ai_team/my/VERSION`

## Architecture

### Deployment Model

`ai_team/` maps directly to `.github/` in any project where The AI framework is installed:
```
ai_team/
├── skills/my-*/SKILL.md     → entry points (slash commands)
├── agents/*.agent.md            → subagent prompt definitions
├── my/workflows/*.md        → workflow implementations
├── my/references/*.md       → shared ML knowledge
├── my/templates/            → artifact templates
├── my/bin/my-tools.cjs  → CLI for commits, state, config
├── scripts/                     → Python hooks
└── hooks/pre-tool-use.json      → Claude Code PreToolUse hook
```

### The 10 Commands

| Command | Purpose |
|---------|---------|
| `my-new-version <name>` | Init version with ML project template |
| `my-provide-context` | Ingest papers/code refs → research → roadmap |
| `my-discuss <phase>` | Discuss phase decisions → CONTEXT.md + log |
| `my-plan <phase>` | Create PLAN.md (ML-aware) |
| `my-implement <phase>` | Execute phase code |
| `my-evaluate <phase>` | Evaluate model metrics → EVALUATION.md |
| `my-debug <issue>` | Debug training/evaluation issues |
| `my-status` | Show progress + metrics |
| `my-continue` | Auto-run next step |
| `my-release-version <v>` | Close version, archive, tag |

### The 10 Agents

| Agent | Role |
|-------|------|
| `my-planner` | Creates PLAN.md with ML-aware task decomposition |
| `my-executor` | Implements Python/PyTorch/ML code |
| `my-roadmapper` | Creates phase roadmap from ML requirements |
| `my-researcher` | Researches CV/VLM papers, architectures, SOTA |
| `my-research-synthesizer` | Synthesizes research into actionable insights |
| `my-evaluator` | Evaluates model: metrics, benchmarks, go/no-go |
| `my-data-analyst` | Analyzes CV datasets (COCO, ImageNet, VQA, etc.) |
| `my-debugger` | Debugs training/CUDA/data pipeline issues |
| `my-plan-checker` | Verifies plan quality before execution |
| `my-codebase-mapper` | Maps existing codebase/code references |

## Key Conventions

### Skill Frontmatter
Every `SKILL.md` has YAML frontmatter:
```yaml
---
name: my-evaluate
description: Evaluate ML model performance...
argument-hint: "<phase-number> [--quick] [--full]"
agent: my-evaluator
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---
```

### ai-tools CLI Pattern
Always handle `@file:*` response:
```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init execute-phase "1")
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
1. Create `skills/my-{name}/SKILL.md` with frontmatter
2. Create matching `my/workflows/{name}.md` with workflow logic
3. Update `my-file-manifest.json` with checksums
4. Reference ML-specific docs in `<execution_context>` if relevant
