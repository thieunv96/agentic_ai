<purpose>
Map the ML codebase into structured artifacts that every pipeline stage can read for context.
Command: `/ml-map-codebase` | `/ml-map-codebase [version]` | `/ml-map-codebase --update`
Reads: all source files in the project (src/, scripts/, configs/, notebooks/)
Writes: `.works/[version]/codebase/` — MANIFEST.md, COMPONENTS.md, DEPENDENCIES.md, RETRIEVAL-INDEX.md, chunks/
Commit: none — codebase map is a derived artifact, not a source change
Re-run anytime the codebase changes significantly (new files, refactor, after implement).
</purpose>

<context_management>

## Context Rules

**Spawn ml-codebase-mapper for the full analysis.** This workflow is a thin orchestrator — all the actual parsing and writing is done by the agent.

**Agent spawn — ml-codebase-mapper:**
```
<files_to_read>
- .works/[v]/STATE.md           (version and current phase context)
- REQUIREMENTS.md               (target task, dataset, model constraints)
- .works/[v]/[N]-CONTEXT.md     (if exists — locked decisions affect what to highlight)
</files_to_read>
Root directory: [project root]
Output directory: .works/[version]/codebase/
Scope: [full | --update (changed files only) | --component data|model|train|eval]
```

**Who reads the codebase map:**
- `ml-discuss` Step 3 — load MANIFEST.md to understand current baseline before asking questions
- `ml-planning` Step 2 — load COMPONENTS.md and DEPENDENCIES.md instead of grep/glob exploration
- `ml-implement` / `ml-executor` — load specific chunks/ files for the tasks in their wave
- `ml-test` / `ml-evaluator` — load COMPONENTS.md to find eval scripts and metrics
- `ml-report` — load MANIFEST.md for architecture summary in version report

**Context saving:** Instead of reading many source files inline, other workflows should read `.works/[v]/codebase/MANIFEST.md` (< 200 lines) first. Only load individual chunk files when working on a specific function.

</context_management>

<process>

## 1. Identify Version and Scope

Determine `VERSION` from STATE.md or from the `[version]` argument.
Set `CODEBASE_DIR=.works/$VERSION/codebase/`.

Parse flags:
- No flag → full map of all source files
- `--update` → only re-map files changed since last map (check git log since MANIFEST.md last modified)
- `--component [data|model|train|eval|inference]` → map only files tagged with that pipeline stage

```
ask_user:
  WHY: A full map takes 5-15 minutes on a large codebase. If you've just added one new
       module, --update is faster and gives the same result for daily use.
  question: "What scope do you want for this codebase map?"
  choices:
    - "Full map — scan everything (first time or after major refactor)"
    - "Update only — re-map files changed since last map"
    - "Single component — data / model / train / eval / inference"
    - "Other — I'll describe"
```

## 2. Spawn ml-codebase-mapper

Spawn **ml-codebase-mapper** with:

```
<files_to_read>
- .works/$VERSION/STATE.md
- REQUIREMENTS.md
- .works/$VERSION/[N]-CONTEXT.md   (most recent, if exists)
</files_to_read>
Root: [project root]
Output: .works/$VERSION/codebase/
Scope: [full / update / component=X]
Tasks:
  1. Discover source files → tag with pipeline stage
  2. AST-parse each file → extract functions, classes, imports
  3. Tag each component with: pipeline stage + role
  4. Build dependency graph (config→model, dataset→training)
  5. Write MANIFEST.md, COMPONENTS.md, DEPENDENCIES.md, RETRIEVAL-INDEX.md
  6. Write chunks/ directory — one file per function/class
```

## 3. Display Map Summary

After the agent completes, show a concise summary:

```
---
✓ Codebase map written → .works/$VERSION/codebase/

Pipeline coverage:
  Data:       [N files] — [entry point examples]
  Model:      [N files] — [entry point examples]
  Training:   [N files] — [entry point examples]
  Evaluation: [N files] — [entry point examples]
  Inference:  [N files] — [entry point examples]

Components found:
  [N] datasets/dataloaders
  [N] model architectures
  [N] loss functions
  [N] training loops
  [N] evaluation scripts

Chunks written: [N] (in .works/$VERSION/codebase/chunks/)

To explore:
  Read .works/$VERSION/codebase/MANIFEST.md
  Query: /ml-map-codebase --query "how is loss computed?"
---
```

## 4. Optional: Semantic Query

If the user wants to query the map immediately:

```
ask_user:
  question: "Would you like to query the codebase map now?"
  choices:
    - "Yes — ask a question about the codebase"
    - "No — I'll use it later via other commands"
    - "Other — I'll describe what I need"
```

If yes: take the user's question, search `RETRIEVAL-INDEX.md` for matching chunks by pipeline tag + function name, load the 2-3 most relevant chunk files, and answer with file references.

## 5. Offer Next Step

```
ask_user:
  question: "Codebase map is ready. What next?"
  choices:
    - "Discuss a new phase — /ml-discuss [N]"
    - "Plan a phase using this map — /ml-plan [N]"
    - "Query: show me how [component] works"
    - "Update after recent changes — /ml-map-codebase --update"
    - "Other — I'll describe what I need"
```

</process>
