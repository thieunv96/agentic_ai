<purpose>
Generate user-centric, step-by-step documentation for a phase or a full version release. Stores output in the configured docs directory (default: docs/). Formatted as clean Markdown for easy XWiki sync.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init plan-phase "$PHASE" 2>/dev/null || node ".github/my/bin/my-tools.cjs" state load)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse from INIT: `phase_dir`, `phase_name`, `phase_number`, `commit_docs`.

Read config for:
```bash
VERSION=$(node ".github/my/bin/my-tools.cjs" config get current_version)
DOCS_DIR=$(node ".github/my/bin/my-tools.cjs" config get docs_dir)
DOCS_DIR=${DOCS_DIR:-docs}
```

Parse `$ARGUMENTS` flag:
- `--phase N` → document phase N
- `--release` → finalize version docs
- `--all` → regenerate all completed phases

Create output directory:
```bash
mkdir -p ${DOCS_DIR}/${VERSION}
```

## 2. Source Files

Read all relevant context for the phase(s) being documented, **in parallel**:

**For `--phase N`:**
- `[phase_dir]/[N]-CONTEXT.md` — locked decisions (backbone, optimizer, etc.)
- `[phase_dir]/[N]-DISCUSSION-LOG.md` — rationale audit trail
- `[phase_dir]/*-SUMMARY.md` — what was actually implemented
- `[phase_dir]/EVALUATION.md` — results and metrics
- `[planning]/KNOWLEDGE.md` — papers and references used
- `[planning]/PROJECT.md` — project goal, dataset, constraints

**For `--release`:**
- All the above for every completed phase
- `[planning]/VERSION-SUMMARY.md`
- `[planning]/REQUIREMENTS.md`
- Existing `${DOCS_DIR}/${VERSION}/` phase docs (if already generated)

## 3. Spawn my-documenter

Spawn `my-documenter` agent:

```
<files_to_read>
[All source files from Step 2]
</files_to_read>

<task>
Generate documentation for [phase name / version].
Mode: [--phase N | --release | --all]
Output path: ${DOCS_DIR}/${VERSION}/[output-file]
Docs directory: ${DOCS_DIR}/${VERSION}/

Rules:
- User-centric: write for someone who wants to USE what was built, not rebuild it
- Step-by-step: numbered steps with code examples and expected output
- Plain language: no internal planning jargon, no agent/framework terminology
- XWiki-ready: clean Markdown, standard tables, fenced code blocks only
- Incremental: each phase section is standalone — no prior phases required to understand
</task>
```

## 4. Phase Documentation (`--phase N`)

The agent generates `${DOCS_DIR}/${VERSION}/[NN]-[phase-slug].md` using the phase-doc template:

```markdown
# [Phase Name]

> **Version:** [version] | **Status:** Complete | **Metrics:** [key metric = value]

## Overview

[What this phase does and why it matters — 2-3 sentences. No jargon.]

## Prerequisites

- [What needs to be ready before this phase]
- [Environment, dependencies, data]

## Step-by-Step Guide

### 1. [Step Name — e.g., "Prepare the Dataset"]

[Clear explanation of what and why]

```bash
# Code example with comments
python scripts/prepare_data.py \
  --input data/raw/ \
  --output data/processed/ \
  --format coco
```

Expected output:
```
Processing 5,432 images...
✓ Train: 4,345 | Val: 1,087
Saved to data/processed/
```

### 2. [Step Name]

[Continue for each major step...]

## Configuration

Key settings used in this phase:

| Parameter | Value | Why |
|-----------|-------|-----|
| backbone | ViT-B/16 | Best accuracy/speed for this dataset size |
| optimizer | AdamW | Standard for ViT fine-tuning |
| learning_rate | 1e-4 | Tuned for this batch size |

## Results

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| [metric] | [target] | [value] | ✅ / ❌ |

## Common Issues

**Issue:** [Description]
**Fix:** [Solution with code if needed]

## Next Steps

After completing this phase: [what comes next]
```

## 5. Release Documentation (`--release`)

The agent generates `${DOCS_DIR}/${VERSION}/index.md` as the version landing page:

```markdown
# [Project Name] — [Version]

> **Released:** [date] | **Task:** [ML task type] | **Dataset:** [dataset name]

## Overview

[What was built and why — 2-3 sentences for someone who wasn't involved.]

## Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Download model
python scripts/download_model.py --version [version]

# 3. Run inference
python infer.py --image path/to/image.jpg
```

## What's Included

| Phase | Topic | Key Achievement |
|-------|-------|----------------|
| 1 | [Phase name] | [Key result] |
| 2 | [Phase name] | [Key result] |

## Performance

| Metric | Target | Achieved |
|--------|--------|---------|

## Documentation

- [Phase 1: Data Pipeline](./01-data-pipeline.md)
- [Phase 2: Model Architecture](./02-model-architecture.md)
- [Phase 3: Training](./03-training.md)
- [Phase 4: Evaluation](./04-evaluation.md)

## Known Limitations

[Honest list of what doesn't work well or is out of scope]

## Changelog

See [CHANGELOG.md](../CHANGELOG.md) for changes from previous versions.
```

Also update `${DOCS_DIR}/CHANGELOG.md`:
```markdown
## [Version] — [Date]

### Added
- [Feature 1 from requirements]
- [Feature 2]

### Changed
- [What changed from previous version, if applicable]

### Performance
- [Key metric]: [previous] → [achieved]
```

## 6. Commit Documentation

```bash
node ".github/my/bin/my-tools.cjs" commit "docs([version]): [phase-name | release] documentation" --files ${DOCS_DIR}/${VERSION}/
```

## 7. Show Result

```
---
✅ Documentation generated

Output: ${DOCS_DIR}/${VERSION}/[file(s)]

XWiki sync tip:
  Copy files from ${DOCS_DIR}/${VERSION}/ to your XWiki space.
  Each .md file maps to one XWiki page.
  Recommended space structure: [Project]/[Version]/[Phase]

---
```

</process>
