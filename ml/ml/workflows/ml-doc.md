<purpose>
Generate user-centric, XWiki-sync-compatible documentation for a completed phase or version.
Command: `/ml-doc [N]` (phase) | `/ml-doc --release` (full version index) | `/ml-doc --all` (all completed phases)
Reads: `.works/[v]/[N]-CONTEXT.md`, `.works/[v]/[N]-SUMMARY.md`, `.works/[v]/[N]-EVALUATION.md`, `.works/[v]/KNOWLEDGE.md`
Writes: `docs/[version]/[NN]-[phase-slug].md`, `docs/[version]/index.md` (release only), `docs/CHANGELOG.md` (release only)
Commit: `docs([version]): [phase-name] documentation` — this is the phase docs complete commit point
No user confirmation between generation steps.
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Spawn ml-documenter for the actual writing.** Do NOT write docs inline — spawn **ml-documenter** to keep the main context clean and ensure XWiki rules are applied consistently.

**Agent spawn — ml-documenter:**
```
<files_to_read>
- .works/[v]/[N]-CONTEXT.md
- .works/[v]/[N]-SUMMARY.md
- .works/[v]/[N]-EVALUATION.md
- .works/[v]/KNOWLEDGE.md
</files_to_read>
Write: docs/[version]/[NN]-[phase-slug].md
Apply all XWiki rules. No planning jargon. User-centric language.
Return: file path written + key result metric documented.
```

**Spawn ml-context-keeper after:** commit, before auto-proceeding to ml-report.

**Question discipline:** Use `ml-ask` skill format for the end-of-step next-step question.

</context_management>

<process>

## 1. Setup

Parse `$ARGUMENTS`:
- `[N]` or `--phase [N]` → document phase N only
- `--release` → generate phase N doc + version index + CHANGELOG entry
- `--all` → regenerate docs for all phases with a SUMMARY.md in `.works/$VERSION/`

Read in parallel (skip files that do not exist):
- `.works/[v]/[N]-CONTEXT.md` — decisions, success criteria, constraints
- `.works/[v]/[N]-SUMMARY.md` — what was actually built, files changed
- `.works/[v]/[N]-EVALUATION.md` — results, metrics, GO/NO-GO decision
- `.works/[v]/KNOWLEDGE.md` — referenced papers and code

Determine paths:
- `VERSION` → from `.works/[v]/STATE.md` or `VERSION` file
- `DOCS_DIR` → `docs/` (default)
- `OUTPUT` → `$DOCS_DIR/$VERSION/[NN]-[phase-slug].md`
  - `[NN]` = zero-padded phase number (e.g., `01`, `02`)
  - `[phase-slug]` = kebab-case phase name (e.g., `data-pipeline`, `fine-tuning`)

Create `$DOCS_DIR/$VERSION/` if it does not exist.

If no SUMMARY.md exists for the requested phase: stop and output:
```
Error: No SUMMARY.md found for phase [N]. Run /ml-implement [N] first.
```

## 2. Spawn ml-documenter

Spawn **ml-documenter** with:

```
<files_to_read>
- .works/$VERSION/[N]-CONTEXT.md
- .works/$VERSION/[N]-SUMMARY.md
- .works/$VERSION/[N]-EVALUATION.md
- .works/$VERSION/KNOWLEDGE.md
</files_to_read>
Output: docs/$VERSION/[NN]-[phase-slug].md
Apply all XWiki rules. Write for a user who will USE the output, not build it.
Return: file path + key result metric.
```

The ml-documenter writes the file directly. The template below is the reference it follows:

## 2a. Documentation Template (reference for ml-documenter)

Write `$DOCS_DIR/$VERSION/[NN]-[phase-slug].md` using this template.
All XWiki rules from Step 3 are applied during generation — not as a post-pass.

```markdown
# [Phase Name]

> **Version:** [version] | **Status:** Complete | **Result:** [key metric = achieved value]

## What This Does

[2–3 sentences in plain language explaining what this phase built and WHY it matters.
Write for someone who will USE the output, not someone who built it.
No internal jargon: no "wave", "plan", "executor", "subagent", "CONTEXT.md".
Example: "This phase trains the detection model on your labeled dataset.
After completion, you will have a checkpoint file ready for evaluation and deployment.
It also verifies the training converged by checking loss curves and a held-out validation split."]

## Before You Start

- [Prerequisite 1 — e.g., "Data pipeline complete (see [01-data-pipeline.md](./01-data-pipeline.md))"]
- [Prerequisite 2 — e.g., "GPU with ≥ 16 GB VRAM available"]
- [Prerequisite 3 — e.g., "wandb API key set in environment: `export WANDB_API_KEY=your-key`"]

## Step-by-Step

### 1. [Step Name]

[Plain-language explanation: what this step does and why it's needed.
Avoid passive voice. Be direct: "This step downloads the base model weights and verifies their checksum."]

```bash
python scripts/[script].py \
  --config configs/[config].yaml \
  --output-dir outputs/[phase]/
```

Expected output:
```
[Paste realistic expected terminal output — trimmed to the key lines]
✓ [Key completion message]
```

### 2. [Step Name]

[Continue for each significant step]

## Key Configuration

| Parameter | Value Used | Why This Value |
|-----------|-----------|----------------|
| [param] | [value] | [plain-language reason — what breaks if you change it and in which direction] |

## Results

| Metric | Target | Achieved |
|--------|--------|---------|
| [metric] | [target from CONTEXT.md] | [actual from EVALUATION.md] |

## If Something Goes Wrong

**Problem:** [common failure mode — specific, not generic]
**Cause:** [why it happens]
**Fix:** [what to do — specific command or configuration change]

**Problem:** [second common failure]
**Cause:** [why]
**Fix:** [what to do]

## What Comes Next

[One sentence on the natural next step — e.g., "After this phase, run evaluation to measure model quality before proceeding to quantization."]

```bash
# Next step
/ml-test [N]
```
```

## 3. XWiki Sync Rules — AUTO-APPLIED DURING GENERATION

These rules are enforced during Step 2, not as a separate pass. They ensure the Markdown renders correctly when synced to XWiki.

**Structure rules:**
- Headers use `#` (H1) through `###` (H3) only — XWiki depth limit
- Each file has exactly one `#` H1 header at the top
- No blank H2/H3 headers

**Code block rules:**
- All code blocks use triple-backtick fences: ` ```bash `, ` ```python `, ` ```yaml `, ` ```text `
- Never use indented code blocks (4 spaces)
- Language hint is always specified — no bare ` ``` `

**Table rules:**
- All tables use standard Markdown pipe format
- No HTML tables

**Content rules:**
- No HTML tags anywhere in the file — XWiki rejects inline HTML in Markdown sync
- No internal path references to `.works/`, `.note/`, `CONTEXT.md`, `PLAN.md`, `SUMMARY.md`, `EVALUATION.md`
- No planning jargon: wave, plan, executor, subagent, CONTEXT, PLAN, SUMMARY, EVALUATION
- All file paths in commands are relative to the project root
- All commands are copy-pasteable — no `[placeholder]` left unfilled in bash blocks
- No cross-references to files that don't exist yet

## 4. Version Index — `--release` only

Write `$DOCS_DIR/$VERSION/index.md`:

```markdown
# [Project Name] — [Version]

> **Released:** [date] | **Task:** [ML task description] | **Dataset:** [name, size if known]

## What Was Built

[2–3 sentences for someone who was not involved in development.
Describe the deliverable in terms of what it does, not how it was built.
No planning jargon.]

## Quick Start

```bash
pip install -r requirements.txt
python infer.py --image path/to/image.jpg --checkpoint outputs/[version]/best.ckpt
```

## Phases in This Version

| # | Phase | What It Does | Key Result |
|---|-------|-------------|------------|
| 1 | [name] | [one-sentence plain description] | [metric = value] |

## Documentation

- [Phase 1: [Name]](./01-[slug].md)
- [Phase 2: [Name]](./02-[slug].md)

## Known Limitations

- [Honest limitation 1 — specific, not generic]
- [Limitation 2]
```

Also append to `$DOCS_DIR/CHANGELOG.md`:

```markdown
## [Version] — [Date]

### Added
- [Feature or capability — user-facing description]

### Performance
- [Metric]: [before] → [after]

### Known Issues
- [Any known limitations or regressions]
```

## 5. Commit

After all documentation files are written:

```bash
git add docs/$VERSION/
git commit -m "docs($VERSION): [phase-name] documentation"
```

For `--release`:
```bash
git add docs/$VERSION/ docs/CHANGELOG.md
git commit -m "docs($VERSION): release documentation"
```

This is the **phase docs complete** commit point per commit discipline.

## 6. Show XWiki Sync Tip

```
---
✓ Documentation generated:
  $DOCS_DIR/$VERSION/[NN]-[phase-slug].md
  [index.md if --release]

XWiki sync:
  Copy $DOCS_DIR/$VERSION/ → your XWiki space.
  Each .md file = one XWiki page.
  Recommended structure: [Project Name] / [Version] / [Phase name]

  Note: XWiki auto-converts Markdown on import if the Markdown macro is enabled.
  If not, use the XWiki Export tool with Markdown format selected.
---
```

## 7. Auto-Proceed to Report

```
---
✓ Documentation committed — Phase [N]: [phase-name]
  Commit: docs($VERSION): [phase-name] documentation
  Output: $DOCS_DIR/$VERSION/[NN]-[phase-slug].md

→ Proceeding to /ml-report session ...
---
```

Proceed automatically to `/ml-report session` — no user prompt.

</process>
