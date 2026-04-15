# Copilot Instructions — copilot_teams (AI Framework)

## What This Repository Is

This repo contains the **AI development framework** — a structured, AI-assisted workflow system optimized for Computer Vision and Vision-Language Model (VLM) development. The `ai_team/` directory deploys to `.github/` in target ML projects.

Current version: `ai_team/ai/VERSION`

## Architecture

### Deployment Model

`ai_team/` maps directly to `.github/` in any project where The AI framework is installed:
```
ai_team/
├── skills/ai-*/SKILL.md     → entry points (slash commands)
├── agents/*.agent.md            → subagent prompt definitions
├── ai/workflows/*.md        → workflow implementations
├── ai/references/*.md       → shared ML knowledge
├── ai/templates/            → artifact templates
├── ai/bin/ai-tools.cjs  → CLI for commits, state, config
├── scripts/                     → Python hooks
└── hooks/pre-tool-use.json      → Claude Code PreToolUse hook
```

### The 10 Commands

| Command | Purpose |
|---------|---------|
| `ai-new-version <name>` | Init version with ML project template |
| `ai-provide-context` | Ingest papers/code refs → research → roadmap |
| `ai-discuss <phase>` | Discuss phase decisions → CONTEXT.md + log |
| `ai-plan <phase>` | Create PLAN.md (ML-aware) |
| `ai-implement <phase>` | Execute phase code |
| `ai-evaluate <phase>` | Evaluate model metrics → EVALUATION.md |
| `ai-debug <issue>` | Debug training/evaluation issues |
| `ai-status` | Show progress + metrics |
| `ai-continue` | Auto-run next step |
| `ai-release-version <v>` | Close version, archive, tag |

### The 10 Agents

| Agent | Role |
|-------|------|
| `ai-planner` | Creates PLAN.md with ML-aware task decomposition |
| `ai-executor` | Implements Python/PyTorch/ML code |
| `ai-roadmapper` | Creates phase roadmap from ML requirements |
| `ai-researcher` | Researches CV/VLM papers, architectures, SOTA |
| `ai-research-synthesizer` | Synthesizes research into actionable insights |
| `ai-evaluator` | Evaluates model: metrics, benchmarks, go/no-go |
| `ai-data-analyst` | Analyzes CV datasets (COCO, ImageNet, VQA, etc.) |
| `ai-debugger` | Debugs training/CUDA/data pipeline issues |
| `ai-plan-checker` | Verifies plan quality before execution |
| `ai-codebase-mapper` | Maps existing codebase/code references |

## Key Conventions

### Skill Frontmatter
Every `SKILL.md` has YAML frontmatter:
```yaml
---
name: ai-evaluate
description: Evaluate ML model performance...
argument-hint: "<phase-number> [--quick] [--full]"
agent: ai-evaluator
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
---
```

### ai-tools CLI Pattern
Always handle `@file:*` response:
```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" init execute-phase "1")
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
1. Create `skills/ai-{name}/SKILL.md` with frontmatter
2. Create matching `ai/workflows/{name}.md` with workflow logic
3. Update `ai-file-manifest.json` with checksums
4. Reference ML-specific docs in `<execution_context>` if relevant
