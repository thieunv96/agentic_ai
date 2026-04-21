<purpose>
Create a detailed implementation plan for an AI/LLM project phase.
Command: `/ml-plan [N]` or `/ml-plan [phase-name]`
Style: Claude Code plan mode — clarify, explore, plan, validate, then act.
Reads: `.works/[v]/[N]-CONTEXT.md` (if exists), `ROADMAP.md`, `REQUIREMENTS.md`, source files
Writes: `.works/[v]/[N]-PLAN.md`
Commit: none — per commit discipline
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Load from files first.** Read STATE.md and [N]-CONTEXT.md before building the plan. Do not ask the user for information that is already locked in files.

**Codebase map:** If `.works/[v]/codebase/MANIFEST.md` exists, read MANIFEST.md + COMPONENTS.md instead of running glob/grep during Step 2 Explore. For individual task planning, load the relevant chunk file from `chunks/` rather than the original source file — it's pre-parsed and context-efficient. If the map doesn't exist, suggest running `/ml-map-codebase` first.

**Spawn ml-context-keeper when:** context window is ~70% full, or before the rubber-duck validation step if the plan + context files are large.

**Agent spawn — ml-rubber-duck (Step 6):**
```
<files_to_read>
- .works/[v]/[N]-PLAN.md
- .works/[v]/[N]-CONTEXT.md
- REQUIREMENTS.md
</files_to_read>
Review this plan for task executability, hidden dependencies, failure modes, and context alignment.
```
Apply the rubber-duck feedback before showing the plan to the user. Suppress feedback that is over-engineering or scope expansion.

**Question discipline:** Use `ml-ask` skill format — context panel → WHY → question → choices with tradeoffs.

</context_management>

<process>

## 1. Clarify the Phase

If the phase is not specified, ask:

```
ask_user:
  question: "Which phase do you want to plan?"
  choices:
    - "Data — curation, tokenization, quality filtering"
    - "Pretraining — from-scratch LLM training"
    - "Fine-tuning — SFT / LoRA / QLoRA / PEFT"
    - "Alignment — RLHF / DPO / PPO"
    - "RAG — retrieval pipeline, chunking, indexing"
    - "Evaluation — benchmarks, human eval, red-teaming"
    - "Inference & Serving — quantization, batching, latency"
    - "Other — I'll describe"
```

If "Other" or more detail is needed:

```
ask_user:
  question: "Describe the goal of this phase in one or two sentences."
  allow_freeform: true
```

## 2. Explore the Project

First, check whether `.works/[v]/[N]-CONTEXT.md` exists (from a prior `/ml-discuss [N]` session).

**If `[N]-CONTEXT.md` exists:** display a summary of the locked context and skip directly to Step 3 (Confirm Scope):

```
---
Context from /ml-discuss detected:
  Problem: [problem statement from CONTEXT.md — one sentence]
  Success criteria: [list]
  Hard constraints: [list]
  Riskiest assumption: [one sentence]
---
```

**If `[N]-CONTEXT.md` does not exist:** read these files in parallel (skip any that don't exist):

- `ROADMAP.md` — where this phase fits in the overall project
- `REQUIREMENTS.md` — technical constraints, target metrics, compute budget
- `.works/[v]/KNOWLEDGE.md` — papers, code refs, and insights already collected
- Relevant source files — use `glob`/`grep` to find existing scripts, configs, and model code

Note what is already in place and what is missing before planning.

## 3. Confirm Scope

Summarize your understanding of the phase, then ask:

```
ask_user:
  question: "Is this the scope you want to plan?"
  choices:
    - "Yes, proceed"
    - "Scope needs adjustment"
    - "Missing context — I'll add more first (run /ml-discuss [N])"
    - "Other — I want to add context before proceeding"
```

## 4. Clarify Constraints

Ask only what is not already clear from step 2 or the CONTEXT.md:

```
ask_user:
  question: "What compute environment are you targeting?"
  choices:
    - "Single GPU — RTX 3090 / 4090 / A6000"
    - "Multi-GPU — 2–8× A100 / H100"
    - "Cloud cluster — TPU Pod / multi-node"
    - "CPU inference only"
    - "Not decided yet"
    - "Other — I'll describe my setup"
```

```
ask_user:
  question: "What is the primary constraint for this phase?"
  choices:
    - "Speed — working prototype first, optimize later"
    - "Quality — hit target metrics before moving on"
    - "Cost — minimize GPU hours and API calls"
    - "No special constraint"
    - "Other — I'll describe"
```

## 5. Optional Research Before Planning

Before building the plan, offer research. This is the last cheap moment to validate architecture/approach assumptions — a bad assumption caught here costs minutes; caught during implement it costs hours.

Skip this step automatically if:
- A recent `## Research: [date] — ...` section exists in `.works/[v]/KNOWLEDGE.md` that covers the same architecture/approach for this phase (within the last 14 days)
- `/ml-discuss [N]` already ran research for this phase (check CONTEXT.md for a "Research informed by" note)

Otherwise ask:

```
ask_user:
  context: |
    About to build the plan for Phase [N]: [phase-name].
    Key approach assumptions from CONTEXT.md (or inferred):
      • [architecture / technique 1]
      • [architecture / technique 2]
  why: |
    Research now validates architecture/technique choices before they get baked
    into waves and tasks. Skipping is fine when the approach is well-trodden;
    research pays off when there are recent SOTA shifts or unproven combinations.
  question: "Run research before building the plan?"
  recommendation: "[Skip / Quick / Deep] — [one-line reasoning based on how novel or risky the approach looks]"
  choices:
    - "Skip — approach is well-understood, build the plan now"
    - "Quick — scan for recent SOTA / known pitfalls (5–10 min)"
    - "Deep — full survey of architectures, benchmarks, reference implementations (20–30 min)"
    - "Other — I'll specify a narrower research question"
```

If Quick or Deep: spawn **ml-researcher** with the specific research question.

```
<files_to_read>
- .works/[v]/[N]-CONTEXT.md
- .works/[v]/KNOWLEDGE.md
- REQUIREMENTS.md
</files_to_read>
Research question: [question tied to the riskiest approach assumption for Phase N].
Depth: [Quick / Deep]
Return: findings that would change wave structure, technique choice, or acceptance criteria.
```

After the agent returns:
1. Surface 2–4 key findings inline (Confirmed / Challenged / New constraint / Recommended).
2. If any finding **challenges** a CONTEXT.md decision, pause and ask before continuing:

```
ask_user:
  question: "Research challenged [specific assumption]. How to handle?"
  choices:
    - "Update CONTEXT.md with the new decision, then plan"
    - "Note it as a risk in the plan but keep the original decision"
    - "Go back to /ml-discuss [N] to re-lock requirements"
    - "Other — I'll describe"
```

3. If findings **confirm** the approach: proceed to Step 6 with no interruption.

## 6. Build the Plan

Using all collected context, generate a structured plan:

```markdown
# Plan: Phase [N] — [Phase Name]

## Objective
[1–2 sentences describing the concrete, measurable outcome of this phase]

## Success Criteria
- [ ] [Measurable criterion — metric value, artifact produced, test passing]
- [ ] ...

## Work Breakdown

### Wave 1: [Name — usually foundation / setup]
- **Task 1.1** — [What to do] | Output: [specific file or result] | Acceptance: [verifiable check]
- **Task 1.2** — [What to do] | Output: [specific file or result] | Acceptance: [verifiable check]

### Wave 2: [Name — usually core implementation]
- **Task 2.1** — [What to do] | Output: [specific file or result] | Acceptance: [verifiable check]
- **Task 2.2** — [What to do] | Output: [specific file or result] | Acceptance: [verifiable check]

### Wave 3: [Name — usually validation / tuning]
- **Task 3.1** — [What to do] | Output: [specific file or result] | Acceptance: [verifiable check]

## Risks
| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| [Risk] | High/Med/Low | [How to handle] |

## Dependencies
- Requires: [phase or task that must be done first]
- Unblocks: [phase or task that follows]
```

**Phase-specific wave templates:**

**Data:**
- Wave 1: Source inventory, deduplication, format normalization
- Wave 2: Quality filtering (perplexity, heuristics, classifier)
- Wave 3: Tokenization, packing, dataset statistics report

**Pretraining:**
- Wave 1: Model config, tokenizer, data loader sanity check (1 step)
- Wave 2: Training loop — gradient checkpointing, mixed precision, logging
- Wave 3: Loss curve analysis, checkpoint resume, scaling check

**Fine-tuning (SFT / LoRA / QLoRA):**
- Wave 1: Base model load, PEFT config, 1-batch overfit test
- Wave 2: Full fine-tuning loop — lr schedule, gradient clipping, WandB
- Wave 3: Adapter merge, generation quality spot-check

**Alignment (RLHF / DPO / PPO):**
- Wave 1: Preference dataset prep, reward model baseline
- Wave 2: Policy training loop — KL penalty, reference model, logging
- Wave 3: Win-rate eval vs SFT baseline, safety check

**RAG:**
- Wave 1: Document ingestion, chunking strategy, embedding model
- Wave 2: Vector store indexing, retrieval pipeline, relevance eval
- Wave 3: End-to-end QA eval — faithfulness, answer relevance, latency

**Evaluation:**
- Wave 1: Benchmark harness setup (lm-eval / HELM / custom)
- Wave 2: Run target benchmarks — MMLU, MT-Bench, domain-specific
- Wave 3: Failure case analysis, comparison table vs baseline

**Inference & Serving:**
- Wave 1: Quantization (GPTQ / AWQ / INT8) + perplexity delta check
- Wave 2: Serving setup (vLLM / TGI) — throughput and latency benchmark
- Wave 3: Continuous batching tuning, KV cache profiling, cost estimate

## 7. Validate the Plan — Spawn ml-rubber-duck

Before showing the plan to the user, spawn the **ml-rubber-duck** agent:

```
<files_to_read>
- .works/[v]/[N]-PLAN.md
- .works/[v]/[N]-CONTEXT.md
- REQUIREMENTS.md
</files_to_read>
Review this plan. Return: blockers (vague tasks, missing acceptance criteria, hidden dependencies, constraint violations), warnings (should-fix but not blocking), and a READY/NEEDS FIXES verdict.
```

Apply feedback that prevents real execution failures. Discard feedback that expands scope or over-engineers.

## 8. Present & Adjust

Show the full plan, then ask:

```
ask_user:
  question: "How does the plan look? Anything to adjust?"
  choices:
    - "Good — finalize and save"
    - "Reorder tasks or waves"
    - "Add a task"
    - "Remove or simplify a task"
    - "Explain a section more"
    - "Other — I'll describe the change"
```

Iterate until the user confirms. No cap on adjustment rounds.

## 9. Save the Plan

Save the plan to: `.works/[v]/[N]-PLAN.md`

The PLAN.md is the primary artifact. No SQL or external tracking needed.

Do **not** commit at this stage — per commit discipline (only commit at phase implement complete and phase docs complete).

## 10. Offer Next Step

```
---
▶ Plan saved to .works/[v]/[N]-PLAN.md

To start implementation:
  /ml-implement [N]

To check overall status:
  /ml-status
---
```

```
ask_user:
  question: "What would you like to do next?"
  choices:
    - "Start implementing — /ml-implement [N]"
    - "Review the full plan once more"
    - "Discuss a specific wave in more detail"
    - "Stop here"
    - "Other — I'll describe what I need"
```

</process>
