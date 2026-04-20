<purpose>
Initialize a new ML/AI project version. Two paths: full init flow for new projects; version increment flow for existing ones. Creates PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, config.json.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init new-project)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse: `commit_docs`, `project_exists`, `has_git`, `project_path`.

- If `project_exists` is true → jump to **Exists Section** below.
- If no git repo: `git init` (explain: "Initializing git so we can track planning artifacts and phase commits.")
- Otherwise: continue to step 2.

## 2. Brownfield Check

Detect whether the repo already has substantial code (non-.note files, non-README files).

If existing code detected, ask:

> "I noticed existing code in this repo. This can affect how we set up phases and requirements.
> Would you like to map the codebase first so we have a clear picture of what's already built?
>
> *Why this matters:* A codebase map helps identify what can be reused, what needs refactoring, and avoids duplicating work in the roadmap.
>
> - **Yes, map codebase first** → run `/my-map-codebase` first, then come back
> - **No, skip** → continue with new-version setup"

If user chooses map: stop and tell them to run `/my-map-codebase`, then `/my-new-version` again.
If user chooses skip or no existing code: continue.

*(Skip this step if AUTO MODE is set in config.)*

## 3. Workflow Config

Ask the user to configure how the framework will work for this project. For each option, explain why it matters:

> "Let's configure how the framework will run for this project. I'll ask a few setup questions — you can change these later in `.note/config.json`."

Ask one at a time:

1. **Mode**
   > *Why:* INTERACTIVE mode asks for confirmation at each step (more control). AUTO mode makes decisions automatically (faster, less interruptions).
   > Which mode? **(Interactive — recommended for new/complex projects)** / Auto

2. **Granularity**
   > *Why:* Fine-grained plans have smaller tasks (easier to review, slower to run). Coarse plans have bigger tasks (faster, less visibility).
   > Plan granularity? **(Standard — recommended)** / Fine / Coarse

3. **Git tracking**
   > *Why:* Enables automatic commits at key milestones (roadmap, plan, implementation). Disable if you prefer to commit manually.
   > Enable git tracking? **(Yes — recommended)** / No

4. **Research**
   > *Why:* Research tracks scan papers/architectures before planning. Useful for complex/uncertain domains. Skip if you already know the approach.
   > Enable research steps? **(Yes — ask each time)** / Always / Never

5. **Plan verification**
   > *Why:* A plan-checker agent reviews PLAN.md before execution to catch missing steps or bad decomposition.
   > Enable plan verification? **(Yes — recommended)** / No

6. **Verifier**
   > *Why:* After implementation, a verifier checks that code actually does what the plan said.
   > Enable implementation verification? **(Yes — recommended)** / No

7. **AI model profile**
   > *Why:* Affects how agents approach tasks — research-heavy uses larger context models; fast-iteration uses quicker models.
   > Model profile? **(Standard)** / Research-heavy / Fast-iteration

Save to `.note/config.json`. Commit config:
```bash
node ".github/my/bin/my-tools.cjs" commit "chore: initialize config for [version-name]" --files .note/config.json
```

## 4. Questioning / Context

Ask the user what they want to build:

> "Now let's understand your project.
>
> *Why I need to understand this deeply:* The quality of your REQUIREMENTS.md and ROADMAP.md depends on how clearly we define the goal here. Vague goals lead to vague phases.
>
> **What do you want to build?**"

Follow up deeply until you have a clear, concrete understanding:
- Clarify vague ideas ("What does 'better detection' mean? Better mAP? Lower latency? Both?")
- Surface assumptions ("Are you using an existing architecture or designing new?")
- Understand motivation ("Why this task? What's the end use case?")
- Identify constraints ("Any hard requirements on model size, latency, or hardware?")
- Confirm ML specifics:
  - Task type (Classification / Detection / Segmentation / VLM / Generation / Other)
  - Dataset(s) — name + approximate size
  - Target metrics (specific, e.g., "mAP > 0.45 on COCO val")
  - Baseline to beat (prior work / previous version / paper — or "none")
  - Compute available (GPU type + VRAM, single/multi-GPU)
  - Model goal (from scratch / fine-tune / architecture research)

Loop until clear understanding. Then ask:

> "Here's my understanding of what you want to build:
>
> [1-paragraph summary of the project]
>
> Before I create PROJECT.md, is there anything you'd like to add or clarify?
> For example: constraints, out-of-scope items, known risks, or relevant prior work."

Incorporate any additions. Then confirm:
> "Ready to create PROJECT.md? (Yes / Adjust)"

## 5. Write PROJECT.md

Create `.note/PROJECT.md`:

```markdown
# [Version Name]

## Task
[Task type]

## Goal
[Model goal — from scratch / fine-tune / research]

## Core Value
[1 sentence: what success looks like for this project]

## Dataset
[Dataset name + size + source]

## Target Metrics
[Specific metric targets, e.g., "mAP > 0.45 on COCO val2017"]

## Baseline
[Prior work / previous version / paper result to beat — or "none"]

## Compute
[GPU resources: type, VRAM, single/multi]

## Constraints
[Hard requirements: latency, model size, deployment target, etc.]

## Requirements Status

### Validated
[Empty for new project — filled as research confirms assumptions]

### Active
[Initial hypotheses from this conversation — to be formalized in REQUIREMENTS.md]

### Out of Scope
[Explicit exclusions — features/approaches not in this version]

## Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|

## Evolution
| Version | Goal | Status |
|---------|------|--------|
| [version-name] | [goal] | Active |

---
*Initialized: [date]*
```

Commit:
```bash
node ".github/my/bin/my-tools.cjs" commit "docs: project definition for [version-name]" --files .note/PROJECT.md
```

## 6. Research (Optional)

Assess project complexity based on the conversation so far:
- Novel architecture, unfamiliar domain, or cutting-edge technique → recommend Deep research
- Known approach with clear prior art → recommend Quick research
- User already provided clear specs with paper refs → recommend Skip

Ask:
> "Before we define requirements, should I research the domain?
>
> *Why:* Research helps identify what's table-stakes (must-have for any serious project in this domain), what pitfalls to avoid, and which architecture choices have worked well for this task.
>
> [Recommendation: **{Quick|Deep|Skip}** — because {brief reason}]
>
> - **Quick research** (~10 min): scan 3-5 key papers, identify must-have features and common pitfalls
> - **Deep research** (~30 min): full literature survey, architecture comparison, gap analysis
> - **Skip research**: define requirements directly (good if approach is already clear)
>
> Which would you prefer?"

If Quick or Deep: spawn my-researcher for 4 parallel ML tracks:
```
<files_to_read>
.note/PROJECT.md
</files_to_read>

Task: Research [task type] for [project description].
Run 4 parallel research tracks:
1. ML Stack — frameworks, libraries, tooling choices for this task
2. Model Features — must-have capabilities, table stakes for this domain
3. Architecture Options — proven architectures, trade-offs, what works for this task
4. Training Pitfalls — common failure modes, data gotchas, evaluation traps
Synthesize into RESEARCH-SUMMARY.md at .note/RESEARCH-SUMMARY.md
```

Then spawn my-research-synthesizer to create `.note/RESEARCH-SUMMARY.md`. Show key findings to user:
- Recommended stack
- Table-stakes features (must be in requirements)
- Key pitfalls to avoid

If Skip: proceed to step 7.

## 7. Define Requirements v1

Use PROJECT.md + RESEARCH-SUMMARY.md (if exists) to derive requirements.

Group features into ML-relevant categories. Present to user:

> "Based on our conversation [and research findings], here are the proposed requirements for **[version-name]**:
>
> *Why we define requirements this way:* Formal requirements with IDs let us trace every roadmap phase back to a user need. This prevents scope creep and ensures 100% coverage.
>
> [Show grouped requirements by category]
>
> For each requirement, please choose:
> - **v1** — include in this version's roadmap
> - **future** — acknowledge but defer
> - **out of scope** — explicitly exclude"

In AUTO MODE: include all table-stakes features and features from the conversation. Skip confirmations.

After user selections, ask:
> "Is there anything missing from this requirements list that should be in v1?"

Create `.note/REQUIREMENTS.md` using the requirements template. Requirements must be:
- Specific and testable
- User/task-centric (what the model/system does, not how)
- Atomic (one thing per requirement)
- Tagged with category IDs (DATA-01, MODEL-01, etc.)

Confirm (INTERACTIVE MODE only):
> "Here's the final requirements list. Does this capture everything for v1? (Yes / Add more / Remove some)"

Commit:
```bash
node ".github/my/bin/my-tools.cjs" commit "docs: requirements v1 for [version-name]" --files .note/REQUIREMENTS.md .note/PROJECT.md
```

## 8. Create Roadmap

Split requirements into phases. Rules:
- Each requirement maps to **exactly one** phase
- Each phase has a clear goal + 2-5 success criteria
- Phases are in dependency order (data before model before training before eval)
- 100% of v1 requirements must be covered — no unmapped requirements

Generate:
- `.note/ROADMAP.md` with phases table
- Update `.note/REQUIREMENTS.md` traceability section
- Initialize `.note/STATE.md`

STATE.md template:
```markdown
# Project State

## Version
[version-name] — [task type]

## Current Position
Phase: Not started
Status: Ready to discuss — run /my-discuss 1

## Last Experiment
None yet

## Target Metrics
[From PROJECT.md]

## Baseline
[From PROJECT.md]

## Blockers
None
```

In INTERACTIVE MODE, ask:
> "Here's the proposed roadmap:
>
> [Show phases table with requirements per phase]
>
> Does this look right?
> - **Approve** → commit and proceed
> - **Adjust** → tell me what to change
> - **Review full ROADMAP.md** → show full content"

Loop until approved.

Commit:
```bash
node ".github/my/bin/my-tools.cjs" commit "docs: roadmap for [version-name] ([N] phases, [M] requirements)" --files .note/ROADMAP.md .note/REQUIREMENTS.md .note/STATE.md
```

## 9. Final Output

Show:
```
---
## ✅ [version-name] Initialized

**Project:** [1-line summary]
**Phases:** [N] phases | **Requirements:** [M] v1 requirements

**Files created:**
- `.note/PROJECT.md` — project definition
- `.note/REQUIREMENTS.md` — [M] requirements with IDs
- `.note/ROADMAP.md` — [N]-phase roadmap
- `.note/STATE.md` — current position
- `.note/config.json` — workflow config

## ▶ Next Step

**Phase 1: [Phase Name]** — [Phase goal]

`/my-discuss 1`

<sub>`/clear` first → fresh context window</sub>

---
**Also available:**
- `/my-provide-context` — add papers/code refs to KNOWLEDGE.md
- `/my-status` — review full roadmap
```

---

## Exists Section

*(Entered when `project_exists` is true — for starting a new version on an existing project.)*

### E1. Load Context

Read: PROJECT.md, STATE.md, ROADMAP.md (if exists), REQUIREMENTS.md (if exists).

Parse arguments:
- `--reset-phase-numbers` → reset phases to 1 in new roadmap
- remaining text → suggested version name

### E2. Gather Version Goals

Summarize the last version from PROJECT.md Evolution section.

Ask:
> "Last version: [summary from Evolution section].
>
> **What do you want to build in this new version?**
>
> *Why:* Understanding the goal clearly lets us define focused requirements and avoid feature creep from the previous version."

Follow up to clarify scope, priority, and constraints. Loop until clear.

Ask:
> "Before I define the version, is there anything else you'd like to add about goals or constraints?"

### E3. Determine Version Number

Suggest next version number based on Evolution section:
> "Based on the project history, I'd suggest: **[suggested version]**
>
> Does this work, or would you prefer a different version name?"

### E4. Confirm Understanding

Show summary:
> "Here's my understanding of the new version:
>
> **Version:** [version-name]
> **Goal:** [1 sentence]
> **Key changes from last version:** [list]
> **Target features:** [list]
>
> - **Looks good, let's go** → continue
> - **Adjust something** → tell me what to change"

### E5. Update PROJECT.md

Add new version entry to the Evolution section. Add/update "Current Version" block:
```markdown
## Current Version: [version-name]
**Goal:** [goal]
**Target Features:** [list]
```

Update the Requirements Status section (clear Active, reset Validated/Out-of-scope for new version scope).

### E6. Update STATE.md

```markdown
## Version
[version-name] — [task type]

## Current Position
Phase: Not started
Status: Defining requirements for [version-name]
```

### E7. Cleanup + Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "chore: start [version-name] — update PROJECT.md + STATE.md" --files .note/PROJECT.md .note/STATE.md
```

### E8. Optional Research

Same as step 6 above (ask → Quick/Deep/Skip → 4 parallel ML tracks → RESEARCH-SUMMARY.md).

### E9. Define Requirements

Same as step 7 above. New REQUIREMENTS.md for this version.

Note: mark requirements carried over from previous version clearly.

### E10. Create Roadmap

Same as step 8 above. Respect phase numbering:
- `--reset-phase-numbers` → start at Phase 1
- Otherwise → continue from last completed phase + 1

### E11. Final Output

Same as step 9 above, adapted for version increment.

</process>
